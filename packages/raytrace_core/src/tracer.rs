use std::f64::consts::PI;
use serde::Serialize;

use crate::params::*;
use crate::hamiltonian::hamltn;
use crate::integrator::*;

/// A point along the ray path
#[derive(Serialize)]
pub struct TracePoint {
    pub step: usize,
    pub t: f64,
    pub height_km: f64,
    pub lat_deg: f64,
    pub lon_deg: f64,
    pub ground_range_km: f64,
    pub group_path: f64,
    pub phase_path: f64,
    pub absorption: f64,
}

/// Result of tracing one ray
#[derive(Serialize)]
pub struct TraceResult {
    pub points: Vec<TracePoint>,
    pub max_height: f64,
    pub ground_range_km: f64,
    pub returned_to_ground: bool,
    pub n_steps: usize,
}

pub fn trace_ray(
    freq_mhz: f64, ray_mode: f64,
    elevation_deg: f64, azimuth_deg: f64,
    tx_lat_deg: f64,
    int_mode: usize, step_size: f64, max_steps: usize,
    e1max: f64, e1min: f64, e2max: f64,
    p: &ModelParams,
    print_every: usize,
) -> TraceResult {
    let elev_rad = elevation_deg * PI / 180.0;
    let az_rad = azimuth_deg * PI / 180.0;

    // Initial state
    let r0 = p.earth_r;
    let theta0 = PID2 - tx_lat_deg * PI / 180.0;
    let phi0 = 0.0;
    let degs = 180.0 / PI;

    // Helper: ground range in km from initial position
    let ground_range = |theta: f64, phi: f64| -> f64 {
        let cos_ang = theta0.cos() * theta.cos() + theta0.sin() * theta.sin() * (phi - phi0).cos();
        p.earth_r * cos_ang.clamp(-1.0, 1.0).acos()
    };

    let kr0 = elev_rad.sin();
    let kth0 = elev_rad.cos() * (PI - az_rad).cos();
    let kph0 = elev_rad.cos() * (PI - az_rad).sin();

    // First call: compute derivatives and rescale k
    let mut y = [r0, theta0, phi0, kr0, kth0, kph0, 0.0, 0.0];
    let (_d0, _, new_kr, new_kth, new_kph) = hamltn(&y, freq_mhz, ray_mode, p, true);
    y[3] = new_kr;
    y[4] = new_kth;
    y[5] = new_kph;

    // Init integrator
    let mut state = IntegratorState::new(
        &y, 0.0, step_size, int_mode,
        e1max, e1min, e2max, 1.0e-8, 0.5,
    );

    // Store initial derivatives
    let (d_init, _, _, _, _) = hamltn(&state.y, freq_mhz, ray_mode, p, false);
    state.dydt = d_init;
    for i in 0..NN {
        state.fv[state.mm][i] = d_init[i];
    }

    let mut result = TraceResult {
        points: Vec::with_capacity(max_steps / print_every + 5),
        max_height: 0.0,
        ground_range_km: 0.0,
        returned_to_ground: false,
        n_steps: 0,
    };

    result.points.push(TracePoint {
        step: 0, t: 0.0, height_km: 0.0,
        lat_deg: tx_lat_deg, lon_deg: 0.0,
        ground_range_km: 0.0, group_path: 0.0,
        phase_path: 0.0, absorption: 0.0,
    });

    let mut went_up = false;

    for step_num in 1..=max_steps {
        // One integrator step
        if state.mm < 4 || state.mode == 1 {
            rk4_step(&mut state, freq_mhz, ray_mode, p);
        } else {
            am_step(&mut state, freq_mhz, ray_mode, p);
        }

        let h = state.y[0] - p.earth_r;
        if h > result.max_height { result.max_height = h; }
        if h > 10.0 { went_up = true; }
        if h.is_nan() || h.abs() > 50000.0 { break; }

        let ground = went_up && h < 0.0;
        if ground { result.returned_to_ground = true; }

        if step_num % print_every == 0 || ground {
            let theta = state.y[1];
            let phi = state.y[2];
            let lat = (PID2 - theta) * degs;
            let lon = phi * degs;
            let gr = ground_range(theta, phi);
            // Group path = integral of (c/vg) ds ≈ phase_path for simple cases
            let gp = state.y[6]; // close to group path for non-dispersive
            result.points.push(TracePoint {
                step: step_num,
                t: state.t,
                height_km: h,
                lat_deg: lat,
                lon_deg: lon,
                ground_range_km: gr,
                group_path: gp,
                phase_path: state.y[6],
                absorption: state.y[7],
            });
            if ground {
                result.ground_range_km = gr;
            }
        }

        result.n_steps = step_num;
        if ground { break; }
    }

    result
}
