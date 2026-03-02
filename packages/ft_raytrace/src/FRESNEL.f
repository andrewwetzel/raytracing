      FUNCTION C(X)
      DOUBLE PRECISION PIH, XD, Y, V, A, QZ, QN, Q, Z
      REAL X, XA, W, XV, A1, A2, B1, B2
      DATA A1 /0.3183099/, A2 /0.10132/, B1 /0.0968/, B2 /0.154/
      PIH = 1.570796326794897D0
      XA = ABS(X)
      IF (XA.GT.4.1) GO TO 20
      
      XD = DBLE(XA)
      Y = PIH*XD*XD
      V = -Y * Y
      A = 1.D0
      Z = 1.D0
      M = INT(15.0*(XA + 1.0))
      DO 10 I = 1, M
         KZ=2*(I-1)
         KV=4*(I-1)
         QZ = DBLE(KV + 1)
         QN = DBLE((KZ + 1)*(KZ + 2)*(KV + 5))
         Q = QZ/QN
         A = A*Q*V
 10      Z = Z + A
      C = REAL(Z*XD)
      IF (X.LT.0.0) C = -C
      RETURN
      
 20   W = REAL(PIH)*X*X
      XV = XA**4
      C = 0.5 + (A1 - B1/XV)*SIN(W)/XA - (A2 - B2/XV)*COS(W)/(XA**3)
      IF (X.LT.0.0) C = -C
      RETURN
      END

      FUNCTION S(X)
      DOUBLE PRECISION PIH, XD, Y, V, A, QZ, QN, Q, Z
      REAL X, XA, W, XV, A1, A2, B1, B2
      DATA A1 /0.3183099/, A2 /0.10132/, B1 /0.0968/, B2 /0.154/
      PIH = 1.570796326794897D0
      XA = ABS(X)
      IF (XA.GT.4.1) GO TO 20
      
      XD = DBLE(XA)
      Y = PIH*XD*XD
      V = -Y * Y
      A = Y/3.D0
      Z = A
      M = INT(14.0*(XA + 1.0))
      DO 10 I = 1, M
         KZ=2*(I-1)
         KV=4*(I-1)
         QZ = DBLE(KV + 3)
         QN = DBLE((KZ + 2)*(KZ + 3)*(KV + 7))
         Q = QZ/QN
         A = A*Q*V
 10      Z = Z + A
      S = REAL(Z*XD)
      IF (X.LT.0.0) S = -S
      RETURN
      
 20   W = REAL(PIH)*X*X
      XV = XA**4
      S = 0.5 - (A1 - B1/XV)*COS(W)/XA - (A2 - B2/XV)*SIN(W)/(XA**3)
      IF (X.LT.0.0) S = -S
      RETURN
      END
