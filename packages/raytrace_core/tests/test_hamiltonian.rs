//! Tests for Hamilton's equations

use raytrace_core::params::*;
use raytrace_core::hamiltonian::hamltn;

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
    let y2 = [EARTH_RADIUS + 50.0, theta0, 0.0, new_kr, new_kth, new_kph, 0.0, 0.0];
    let (derivs, _space, _, _, _) = hamltn(&y2, 10.0, -1.0, &p, false);

    // At 50 km, still in free space (ionosphere starts ~100 km)
    // dr/dt should be positive (moving up)
    assert!(derivs[0] > 0.0, "dr/dt should be positive (moving upward), got {}", derivs[0]);
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
        assert!(d.is_finite(), "derivative {} not finite in ionosphere: {}", i, d);
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
    assert!(derivs[6].is_finite(), "phase path derivative should be finite");
    // Absorption derivative (index 7) should be finite
    assert!(derivs[7].is_finite(), "absorption derivative should be finite");
}
