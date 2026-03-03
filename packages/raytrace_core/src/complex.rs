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
