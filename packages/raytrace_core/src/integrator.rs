//! RK4 / Adams-Moulton integrator (internal).
#![allow(clippy::needless_range_loop)]
#![allow(clippy::too_many_arguments)]

use crate::hamiltonian::hamltn;
use crate::params::ModelParams;

pub(crate) const NN: usize = 8;

pub(crate) struct IntegratorState {
    pub y: [f64; NN],
    pub dydt: [f64; NN],
    pub yu: [[f64; NN]; 6],
    pub fv: [[f64; NN]; 6],
    pub xv: [f64; 6],
    pub t: f64,
    pub step: f64,
    pub mm: usize,
    pub ll: usize,
    pub mode: usize,
    pub alpha: f64,
    pub epm: f64,
    pub e1max: f64,
    pub e1min: f64,
    pub e2max: f64,
    pub e2min: f64,
    pub fact: f64,
    /// Set to true if any state variable becomes NaN or infinite.
    pub diverged: bool,
    /// Number of consecutive step halvings (capped at 10 to prevent runaway).
    pub halvings: u8,
}

impl IntegratorState {
    pub fn new(
        y0: &[f64; NN],
        t0: f64,
        step: f64,
        mode: usize,
        e1max: f64,
        e1min: f64,
        e2max: f64,
        e2min: f64,
        fact: f64,
    ) -> Self {
        let mut s = Self {
            y: *y0,
            dydt: [0.0; NN],
            yu: [[0.0; NN]; 6],
            fv: [[0.0; NN]; 6],
            xv: [0.0; 6],
            t: t0,
            step,
            mm: 1,
            ll: 1,
            mode,
            alpha: t0,
            epm: 0.0,
            e1max,
            e1min: if e1min <= 0.0 { e1max / 55.0 } else { e1min },
            e2max,
            e2min,
            fact: if fact <= 0.0 { 0.5 } else { fact },
            diverged: false,
            halvings: 0,
        };
        if mode == 1 {
            s.mm = 4;
        }
        s.xv[s.mm] = t0;
        s.yu[s.mm] = *y0;
        s
    }
}

pub(crate) fn rk4_step(s: &mut IntegratorState, freq_mhz: f64, ray_mode: f64, p: &ModelParams) {
    if s.diverged {
        return;
    }
    let bet = [0.5, 0.5, 1.0, 0.0];
    let mut dely = [[0.0f64; NN]; 4];
    let mm = s.mm;

    for k in 0..4 {
        for i in 0..NN {
            dely[k][i] = s.step * s.fv[mm][i];
            s.y[i] = s.yu[mm][i] + bet[k] * dely[k][i];
        }
        s.t = bet[k] * s.step + s.xv[mm];
        let (d, _, _, _, _) = hamltn(&s.y, freq_mhz, ray_mode, p, false);
        s.dydt = d;
        s.fv[mm] = d;
    }

    for i in 0..NN {
        let delta = (dely[0][i] + 2.0 * dely[1][i] + 2.0 * dely[2][i] + dely[3][i]) / 6.0;
        s.yu[mm + 1][i] = s.yu[mm][i] + delta;
    }
    s.mm += 1;
    s.xv[s.mm] = s.xv[s.mm - 1] + s.step;
    s.y = s.yu[s.mm];
    s.t = s.xv[s.mm];

    // NaN/Inf guard
    if !s.y.iter().all(|v| v.is_finite()) {
        s.diverged = true;
        return;
    }

    let (d, _, _, _, _) = hamltn(&s.y, freq_mhz, ray_mode, p, false);
    s.dydt = d;

    if s.mode == 1 {
        exit_routine(s);
        return;
    }

    s.fv[s.mm] = d;

    // Warmup phase: caller's loop handles mm < 4 by calling rk4_step again.
    // No recursive call here to avoid potential stack overflow.
    if s.mm <= 3 {
        return;
    }

    am_step(s, freq_mhz, ray_mode, p);
}

pub(crate) fn am_step(s: &mut IntegratorState, freq_mhz: f64, ray_mode: f64, p: &ModelParams) {
    if s.diverged {
        return;
    }
    let mut dely1 = [0.0f64; NN];

    // Predictor (Adams-Bashforth)
    for i in 0..NN {
        let delta = s.step
            * (55.0 * s.fv[4][i] - 59.0 * s.fv[3][i] + 37.0 * s.fv[2][i] - 9.0 * s.fv[1][i])
            / 24.0;
        s.y[i] = s.yu[4][i] + delta;
        dely1[i] = s.y[i];
    }

    s.t = s.xv[4] + s.step;
    let (d, _, _, _, _) = hamltn(&s.y, freq_mhz, ray_mode, p, false);
    s.dydt = d;
    s.xv[5] = s.t;

    // Corrector (Adams-Moulton)
    for i in 0..NN {
        let delta =
            s.step * (9.0 * d[i] + 19.0 * s.fv[4][i] - 5.0 * s.fv[3][i] + s.fv[2][i]) / 24.0;
        s.yu[5][i] = s.yu[4][i] + delta;
        s.y[i] = s.yu[5][i];
    }

    let (d2, _, _, _, _) = hamltn(&s.y, freq_mhz, ray_mode, p, false);
    s.dydt = d2;

    if s.mode <= 2 {
        exit_routine(s);
        return;
    }

    // Error analysis (mode 3)
    let mut sse = 0.0f64;
    for i in 0..NN {
        let mut epsil = 8.0 * (s.y[i] - dely1[i]).abs();
        if s.y[i].abs() > 1.0e-8 {
            epsil /= s.y[i].abs();
        }
        if sse < epsil {
            sse = epsil;
        }
    }

    if s.e1max <= sse {
        if s.step.abs() <= s.e2min || s.halvings >= 10 {
            s.halvings = 0;
            exit_routine(s);
            return;
        }
        s.halvings += 1;
        s.ll = 1;
        s.mm = 1;
        s.step *= s.fact;
        // Reinit from current y
        s.yu[1] = s.y;
        s.fv[1] = s.dydt;
        s.xv[1] = s.t;
        rk4_step(s, freq_mhz, ray_mode, p);
        return;
    }

    if s.ll <= 1 || sse >= s.e1min || s.e2max <= s.step.abs() {
        exit_routine(s);
        return;
    }

    // Double step
    s.ll = 2;
    s.mm = 3;
    s.xv[2] = s.xv[3];
    s.xv[3] = s.xv[5];
    s.fv[2] = s.fv[3];
    s.fv[3] = s.dydt;
    s.yu[2] = s.yu[3];
    s.yu[3] = s.yu[5];
    s.step *= 2.0;
    rk4_step(s, freq_mhz, ray_mode, p);
}

fn exit_routine(s: &mut IntegratorState) {
    s.ll = 2;
    s.mm = 4;

    for k in 1..4 {
        s.xv[k] = s.xv[k + 1];
        s.fv[k] = s.fv[k + 1];
        s.yu[k] = s.yu[k + 1];
    }
    s.xv[4] = s.xv[5];
    s.fv[4] = s.dydt;
    s.yu[4] = s.yu[5];

    if s.mode <= 2 {
        return;
    }
    let e = (s.xv[4] - s.alpha).abs();
    s.epm = s.epm.max(e);
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::params::*;
    // Tests for the RK4/Adams-Moulton integrator

    fn init_state() -> (IntegratorState, ModelParams) {
        let p = ModelParams::default();
        let elev = 20.0_f64.to_radians();
        let az = 45.0_f64.to_radians();
        let theta0 = PID2 - 40.0_f64.to_radians();
        let kr0 = elev.sin();
        let kth0 = elev.cos() * (std::f64::consts::PI - az).cos();
        let kph0 = elev.cos() * (std::f64::consts::PI - az).sin();
        let mut y = [EARTH_RADIUS, theta0, 0.0, kr0, kth0, kph0, 0.0, 0.0];
        let (_, _, nkr, nkth, nkph) = hamltn(&y, 10.0, -1.0, &p, true);
        y[3] = nkr;
        y[4] = nkth;
        y[5] = nkph;
        let mut state = IntegratorState::new(&y, 0.0, 10.0, 2, 1e-4, 2e-6, 100.0, 1e-8, 0.5);
        let (d, _, _, _, _) = hamltn(&state.y, 10.0, -1.0, &p, false);
        state.dydt = d;
        state.fv[state.mm] = d;
        (state, p)
    }

    #[test]
    fn test_rk4_step_advances() {
        let (mut s, p) = init_state();
        let t0 = s.t;
        let r0 = s.y[0];
        rk4_step(&mut s, 10.0, -1.0, &p);
        assert!(s.t > t0);
        assert!(s.y[0] > r0);
        for (i, yi) in s.y.iter().enumerate() {
            assert!(yi.is_finite(), "y[{}] not finite: {}", i, yi);
        }
    }

    #[test]
    fn test_multiple_steps_finite() {
        let (mut s, p) = init_state();
        for step in 0..10 {
            rk4_step(&mut s, 10.0, -1.0, &p);
            for (i, yi) in s.y.iter().enumerate() {
                assert!(yi.is_finite(), "y[{}] not finite at step {}", i, step);
            }
        }
        assert!(s.y[0] - EARTH_RADIUS > 0.0);
    }

    #[test]
    fn test_am_step_after_warmup() {
        let (mut s, p) = init_state();
        // Warmup: rk4_step no longer recurses, caller must loop
        while s.mm < 4 {
            rk4_step(&mut s, 10.0, -1.0, &p);
        }
        assert_eq!(s.mm, 4, "mm should be 4 after warmup");
        assert!(s.t > 0.0);
    }
}
