//! Tests for the RK4/Adams-Moulton integrator

use raytrace_core::params::*;
use raytrace_core::hamiltonian::hamltn;
use raytrace_core::integrator::*;

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
    y[3] = nkr; y[4] = nkth; y[5] = nkph;
    let mut state = IntegratorState::new(&y, 0.0, 10.0, 2, 1e-4, 2e-6, 100.0, 1e-8, 0.5);
    let (d, _, _, _, _) = hamltn(&state.y, 10.0, -1.0, &p, false);
    state.dydt = d;
    for i in 0..NN { state.fv[state.mm][i] = d[i]; }
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
    rk4_step(&mut s, 10.0, -1.0, &p);
    assert_eq!(s.mm, 4, "mm should be 4 after warmup");
    assert!(s.t > 0.0);
}
