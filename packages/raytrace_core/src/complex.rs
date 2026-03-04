/// Complex number operations (inline for speed)
#[derive(Clone, Copy)]
pub struct Cx { pub re: f64, pub im: f64 }

impl Cx {
    pub fn new(re: f64, im: f64) -> Self { Self { re, im } }
    pub fn from_real(re: f64) -> Self { Self { re, im: 0.0 } }
}

impl std::ops::Add for Cx {
    type Output = Cx;
    fn add(self, o: Cx) -> Cx { Cx::new(self.re + o.re, self.im + o.im) }
}
impl std::ops::Sub for Cx {
    type Output = Cx;
    fn sub(self, o: Cx) -> Cx { Cx::new(self.re - o.re, self.im - o.im) }
}
impl std::ops::Mul for Cx {
    type Output = Cx;
    fn mul(self, o: Cx) -> Cx {
        Cx::new(self.re * o.re - self.im * o.im, self.re * o.im + self.im * o.re)
    }
}
impl std::ops::Mul<f64> for Cx {
    type Output = Cx;
    fn mul(self, s: f64) -> Cx { Cx::new(self.re * s, self.im * s) }
}
impl std::ops::Div for Cx {
    type Output = Cx;
    fn div(self, o: Cx) -> Cx {
        let d = o.re * o.re + o.im * o.im;
        if d == 0.0 { return Cx::new(0.0, 0.0); }
        Cx::new((self.re * o.re + self.im * o.im) / d,
                (self.im * o.re - self.re * o.im) / d)
    }
}
impl std::ops::Neg for Cx {
    type Output = Cx;
    fn neg(self) -> Cx { Cx::new(-self.re, -self.im) }
}

pub fn cx_sqrt(c: Cx) -> Cx {
    let mag = (c.re * c.re + c.im * c.im).sqrt();
    let r = ((mag + c.re) / 2.0).sqrt();
    let i = if c.im >= 0.0 { ((mag - c.re) / 2.0).sqrt() } else { -((mag - c.re) / 2.0).sqrt() };
    Cx::new(r, i)
}

pub fn cx_abs(c: Cx) -> f64 { (c.re * c.re + c.im * c.im).sqrt() }

#[cfg(test)]
mod tests {
    use super::*;
    use crate::params::*;
    // Tests for the complex number type
    
    
    
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
    
}
