      PROGRAM TEST_EXPZ
      COMMON /CONST/ PI, PIT2, PID2, DUM(5)
      COMMON /ZZ/ MODZ, Z, PZPR, PZPTH, PZPPH
      COMMON R(6)
      COMMON /WW/ ID(10), WQ, W(400)
      REAL NU, NU0
      EQUIVALENCE (EARTHR, W(2)), (F, W(6)), (NU0, W(251)),
     1 (H0, W(252)), (A, W(253))
      CHARACTER*6 MODZ

      PI = 3.1415926535
      PIT2 = 2.0 * PI
      PID2 = PI / 2.0

      EARTHR = 6370.0
      F = 1.0
      NU0 = PIT2 * 1.0E6
      H0 = 100.0
      A = 0.1

C     Test at H0
      R(1) = EARTHR + 100.0
      CALL COLFRZ
      IF (ABS(Z - 1.0) .GT. 1.0E-5 .OR. 
     +    ABS(PZPR - (-0.1)) .GT. 1.0E-5) THEN
        PRINT *, 'Test 1 FAILED: Z, PZPR = ', Z, PZPR
        STOP 1
      END IF

C     Test at H = 110.0 => exp(0.1*10) = exp(1) = 2.71828
C     NU = NU0 / e => Z = 1/e = 0.367879
      R(1) = EARTHR + 110.0
      CALL COLFRZ
      IF (ABS(Z - 0.367879) .GT. 1.0E-5) THEN
        PRINT *, 'Test 2 FAILED: Z = ', Z
        STOP 1
      END IF

      PRINT *, 'Test for EXPZ PASSED'
      END PROGRAM TEST_EXPZ
