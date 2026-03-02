      SUBROUTINE FSW(Z,F,DF)
C     FSW(Z) = Z*C_3/2(Z) + 2.5*I*C_5/2(Z)
C     WHERE THE INPUT Z IS REAL AND THE OUTPUT F AND DF ARE COMPLEX.
C     NEEDS THE SUBPROGRAMS FOR THE FRESNEL INTEGRAL FUNCTIONS S AND C
      REAL Z, X, X2, X3, X4, X5, Y, C4, C, S
      COMPLEX F,DF,C1,C2,C3,C6,W,TEMP,I
      
      DATA I /(0.0,1.0)/, PI /3.1415926536/, A3 /1.333333333/
      DATA C2 /(1.0, 1.0)/, C3 /(1.0, -1.0)/
      DATA C6 /1.333333333/
      
      C4=SQRT(2.0/PI)
      
      C1=(2.0/3.0)*I
      X = Z
      X2 = X*X
      X3 = X2*X
      X4 = X2*X2
      X5 = X4*X
      
      IF (ABS(X) .GT. 40.0) GO TO 500
      IF (ABS(X) .GT. 6.0) GO TO 400
      IF (ABS(X) .LT. .05) GO TO 200

C     FRESNEL
      IF (X .GT. 0.0) GO TO 300
      
      Y = C4*SQRT(-X)
      W = (COS(X) + I*SIN(X))*(1.0 - C3*(C(Y) + I*S(Y)))
      F = C1 + C6*(X + I*X*X/Y * W)
      DF = A3*CMPLX(1.0, X) + CMPLX(1.5, X)*A3*C3*X/Y * W
      RETURN

 300  Y = C4*SQRT(X)
      W = (COS(X) + I*SIN(X))*(1.0 - C2*(C(Y) - I*S(Y)))
      F = C1 + C6*(X - I*X*X/Y * W)
      DF = A3*CMPLX(1.0, X) - CMPLX(1.5, X)*A3*C2*X/Y * W
      RETURN

C     POWER SERIES
 200  TEMP = -C6 * SQRT(ABS(X)) * CEXP(I*X)
      F = CMPLX(4.0/3.0*X - 16.0/9.0*X3 + 64.0/315.0*X5,
     1          2.0/3.0 + 8.0/3.0*X2 - 32.0/45.0*X4)
     2    + TEMP*(1.0)
      DF = CMPLX(4.0/3.0 - 16.0/3.0*X2 + 64.0/63.0*X4,
     1           16.0/3.0*X - 128.0/45.0*X3 + 256.0/945.0*X5)
     2     + TEMP*CMPLX(0.5/X, 1.0)
      
      IF (X .GE. 0.0) RETURN
      F = -CONJG(F)
      DF = CONJG(DF)
      RETURN

C     ASYMPTOTIC SERIES
 400  CONTINUE
      F = CMPLX(0.0, 0.0)
      DF = CMPLX(0.0, 0.0)
      RETURN

 500  CONTINUE
      F = CMPLX(0.0, 0.0)
      DF = CMPLX(0.0, 0.0)
      RETURN
      END
