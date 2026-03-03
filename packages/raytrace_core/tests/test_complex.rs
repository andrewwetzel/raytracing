//! Tests for the complex number type

use raytrace_core::complex::*;

const EPS: f64 = 1e-12;

fn approx_eq(a: f64, b: f64) -> bool { (a - b).abs() < EPS }

#[test]
fn test_cx_new_and_from_real() {
    let c = Cx::new(3.0, 4.0);
    assert_eq!(c.re, 3.0);
    assert_eq!(c.im, 4.0);

    let r = Cx::from_real(5.0);
    assert_eq!(r.re, 5.0);
    assert_eq!(r.im, 0.0);
}

#[test]
fn test_cx_add() {
    let a = Cx::new(1.0, 2.0);
    let b = Cx::new(3.0, 4.0);
    let c = a + b;
    assert!(approx_eq(c.re, 4.0));
    assert!(approx_eq(c.im, 6.0));
}

#[test]
fn test_cx_sub() {
    let a = Cx::new(5.0, 7.0);
    let b = Cx::new(3.0, 4.0);
    let c = a - b;
    assert!(approx_eq(c.re, 2.0));
    assert!(approx_eq(c.im, 3.0));
}

#[test]
fn test_cx_mul() {
    // (1+2i)(3+4i) = 3+4i+6i+8i² = 3+10i-8 = -5+10i
    let a = Cx::new(1.0, 2.0);
    let b = Cx::new(3.0, 4.0);
    let c = a * b;
    assert!(approx_eq(c.re, -5.0));
    assert!(approx_eq(c.im, 10.0));
}

#[test]
fn test_cx_mul_scalar() {
    let a = Cx::new(2.0, 3.0);
    let c = a * 4.0;
    assert!(approx_eq(c.re, 8.0));
    assert!(approx_eq(c.im, 12.0));
}

#[test]
fn test_cx_div() {
    // (1+2i)/(3+4i) = (1+2i)(3-4i)/25 = (3-4i+6i-8i²)/25 = (11+2i)/25
    let a = Cx::new(1.0, 2.0);
    let b = Cx::new(3.0, 4.0);
    let c = a / b;
    assert!(approx_eq(c.re, 11.0 / 25.0));
    assert!(approx_eq(c.im, 2.0 / 25.0));
}

#[test]
fn test_cx_div_by_zero() {
    let a = Cx::new(1.0, 2.0);
    let b = Cx::new(0.0, 0.0);
    let c = a / b;
    assert_eq!(c.re, 0.0);
    assert_eq!(c.im, 0.0);
}

#[test]
fn test_cx_neg() {
    let a = Cx::new(2.0, -3.0);
    let c = -a;
    assert!(approx_eq(c.re, -2.0));
    assert!(approx_eq(c.im, 3.0));
}

#[test]
fn test_cx_sqrt_real_positive() {
    let c = cx_sqrt(Cx::from_real(4.0));
    assert!(approx_eq(c.re, 2.0));
    assert!(approx_eq(c.im, 0.0));
}

#[test]
fn test_cx_sqrt_real_negative() {
    // sqrt(-4) = 2i
    let c = cx_sqrt(Cx::from_real(-4.0));
    assert!(approx_eq(c.re, 0.0));
    assert!(approx_eq(c.im, 2.0));
}

#[test]
fn test_cx_sqrt_complex() {
    // sqrt(3+4i) should give result where result² ≈ 3+4i
    let z = Cx::new(3.0, 4.0);
    let s = cx_sqrt(z);
    let check = s * s;
    assert!(approx_eq(check.re, 3.0));
    assert!(approx_eq(check.im, 4.0));
}

#[test]
fn test_cx_abs() {
    // |3+4i| = 5
    assert!(approx_eq(cx_abs(Cx::new(3.0, 4.0)), 5.0));
    // |0+0i| = 0
    assert!(approx_eq(cx_abs(Cx::new(0.0, 0.0)), 0.0));
    // |1+0i| = 1
    assert!(approx_eq(cx_abs(Cx::from_real(1.0)), 1.0));
}

#[test]
fn test_cx_identity_operations() {
    let a = Cx::new(2.5, -1.3);
    // a + 0 = a
    let z = Cx::new(0.0, 0.0);
    let r = a + z;
    assert!(approx_eq(r.re, a.re));
    assert!(approx_eq(r.im, a.im));
    // a * 1 = a
    let one = Cx::from_real(1.0);
    let r = a * one;
    assert!(approx_eq(r.re, a.re));
    assert!(approx_eq(r.im, a.im));
    // a / a = 1
    let r = a / a;
    assert!(approx_eq(r.re, 1.0));
    assert!(approx_eq(r.im, 0.0));
}
