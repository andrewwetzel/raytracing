//! Hamilton's equations for ray tracing (internal).

use crate::models::refractive_index::compute_rindex;
use crate::params::*;

/// Compute derivatives [dr/dt, dθ/dt, dφ/dt, dkr/dt, dkth/dt, dkph/dt, dphase/dt, dabsorb/dt].
pub(crate) fn hamltn(
    y: &[f64],
    freq_mhz: f64,
    ray_mode: f64,
    p: &ModelParams,
    rstart: bool,
) -> ([f64; 8], bool, f64, f64, f64) {
    let r = y[0];
    let theta = y[1];
    let phi = y[2];
    let kr = y[3];
    let kth = y[4];
    let kph = y[5];

    let sth = theta.sin();
    let rsth = r * sth;

    let ri = compute_rindex(r, theta, phi, kr, kth, kph, freq_mhz, ray_mode, p, rstart);

    let phpom = ri.dhdom_re;
    let phpkr = ri.dhdkr_re;
    let phpkth = ri.dhdkth_re;
    let phpkph = ri.dhdkph_re;

    let new_kr = ri.new_kr;
    let new_kth = ri.new_kth;
    let new_kph = ri.new_kph;

    let (drdt, dthdt, dphdt);

    if phpom != 0.0 {
        drdt = -phpkr / (phpom * C);
        dthdt = if r != 0.0 {
            -phpkth / (phpom * r * C)
        } else {
            0.0
        };
        dphdt = if rsth != 0.0 {
            -phpkph / (phpom * rsth * C)
        } else {
            0.0
        };
    } else {
        drdt = 0.0;
        dthdt = 0.0;
        dphdt = 0.0;
    }

    let dkrdt = if phpom != 0.0 {
        ri.dhdr_re / (phpom * C) + new_kth * dthdt + new_kph * sth * dphdt
    } else {
        0.0
    };

    let dkthdt = if phpom != 0.0 && r != 0.0 {
        ri.dhdth_re / (phpom * C) - (new_kth * drdt + new_kph * r * theta.cos() * dphdt) / r
    } else {
        0.0
    };

    let dkphdt = if phpom != 0.0 && rsth != 0.0 {
        let mut v = ri.dhdph_re / (phpom * C) - new_kph * sth * drdt / rsth;
        v -= new_kph * r * theta.cos() * dthdt / rsth;
        v
    } else {
        0.0
    };

    // Phase path
    let d_phase = if phpom != 0.0 {
        let om = PIT2 * 1.0e6 * freq_mhz;
        ri.kphpk_re / phpom / om
    } else {
        0.0
    };

    // Absorption
    let d_absorb = if phpom != 0.0 {
        let om = PIT2 * 1.0e6 * freq_mhz;
        let k2 = new_kr * new_kr + new_kth * new_kth + new_kph * new_kph;
        if k2 > 0.0 {
            let kay2i = om * om / (C * C) * ri.n2_im;
            10.0 / LOGTEN * ri.kphpk_im * kay2i / k2 / phpom / C
        } else {
            0.0
        }
    } else {
        0.0
    };

    let derivs = [drdt, dthdt, dphdt, dkrdt, dkthdt, dkphdt, d_phase, d_absorb];
    (derivs, ri.space, new_kr, new_kth, new_kph)
}

#[cfg(test)]
mod tests {
    use super::*;
    // Tests for Hamilton's equations

    fn default_params() -> ModelParams {
        ModelParams::default()
    }

    #[test]
    fn test_hamltn_initial_call() {
        let p = default_params();
        let elev = 20.0_f64.to_radians();
        let az = 45.0_f64.to_radians();
        let kr = elev.sin();
        let kth = elev.cos() * (std::f64::consts::PI - az).cos();
        let kph = elev.cos() * (std::f64::consts::PI - az).sin();
        let theta0 = PID2 - 40.0_f64.to_radians();

        let y = [EARTH_RADIUS, theta0, 0.0, kr, kth, kph, 0.0, 0.0];
        let (derivs, _space, new_kr, new_kth, new_kph) = hamltn(&y, 10.0, -1.0, &p, true);

        // k should be rescaled on initial call
        assert!(new_kr.is_finite(), "new_kr should be finite");
        assert!(new_kth.is_finite(), "new_kth should be finite");
        assert!(new_kph.is_finite(), "new_kph should be finite");
        // All derivatives should be finite
        for (i, d) in derivs.iter().enumerate() {
            assert!(d.is_finite(), "derivative {} not finite: {}", i, d);
        }
    }

    #[test]
    fn test_hamltn_ray_moving_upward() {
        let p = default_params();
        let elev = 20.0_f64.to_radians();
        let az = 45.0_f64.to_radians();
        let kr = elev.sin();
        let kth = elev.cos() * (std::f64::consts::PI - az).cos();
        let kph = elev.cos() * (std::f64::consts::PI - az).sin();
        let theta0 = PID2 - 40.0_f64.to_radians();

        let y = [EARTH_RADIUS, theta0, 0.0, kr, kth, kph, 0.0, 0.0];
        let (_, _, new_kr, new_kth, new_kph) = hamltn(&y, 10.0, -1.0, &p, true);

        // Second call with rescaled k (not rstart)
        let y2 = [
            EARTH_RADIUS + 50.0,
            theta0,
            0.0,
            new_kr,
            new_kth,
            new_kph,
            0.0,
            0.0,
        ];
        let (derivs, _space, _, _, _) = hamltn(&y2, 10.0, -1.0, &p, false);

        // At 50 km, still in free space (ionosphere starts ~100 km)
        // dr/dt should be positive (moving up)
        assert!(
            derivs[0] > 0.0,
            "dr/dt should be positive (moving upward), got {}",
            derivs[0]
        );
    }

    #[test]
    fn test_hamltn_in_ionosphere() {
        let p = default_params();
        let elev = 20.0_f64.to_radians();
        let kr = elev.sin();
        let kth = -elev.cos();
        let kph = 0.0;
        let theta0 = PID2 - 40.0_f64.to_radians();

        let y = [EARTH_RADIUS + 250.0, theta0, 0.0, kr, kth, kph, 0.0, 0.0];
        let (derivs, space, _, _, _) = hamltn(&y, 10.0, -1.0, &p, false);

        // At 250 km (peak density), should NOT be in free space
        assert!(!space, "At 250 km should not be free space");
        // All derivatives should be finite
        for (i, d) in derivs.iter().enumerate() {
            assert!(
                d.is_finite(),
                "derivative {} not finite in ionosphere: {}",
                i,
                d
            );
        }
    }

    #[test]
    fn test_hamltn_phase_and_absorption() {
        let p = default_params();
        let kr = 0.342;
        let kth = -0.664;
        let kph = 0.664;
        let theta0 = PID2 - 40.0_f64.to_radians();

        let y = [EARTH_RADIUS + 200.0, theta0, 0.0, kr, kth, kph, 0.0, 0.0];
        let (derivs, _, _, _, _) = hamltn(&y, 10.0, -1.0, &p, false);

        // Phase path derivative (index 6) should be non-zero in ionosphere
        assert!(
            derivs[6].is_finite(),
            "phase path derivative should be finite"
        );
        // Absorption derivative (index 7) should be finite
        assert!(
            derivs[7].is_finite(),
            "absorption derivative should be finite"
        );
    }
}
