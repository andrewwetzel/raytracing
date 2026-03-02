      PROGRAM TEST_CONSTZ
      COMMON /CONST/ PI, PIT2, PID2, DUM(5)
      COMMON /ZZ/ MODZ, Z, PZPR, PZPTH, PZPPH
      COMMON R(6)
      COMMON /WW/ ID(10), WQ, W(400)
      EQUIVALENCE (EARTHR, W(2)), (F, W(6)), (NU, W(251)), (HMIN,W(252))
      REAL NU
      CHARACTER*6 MODZ

      PI = 3.1415926535
      PIT2 = 2.0 * PI
      PID2 = PI / 2.0

      EARTHR = 6370.0
      F = 1.0
      NU = PIT2 * 1.0E6 ! = 2*PI*1M
      HMIN = 100.0

C     Test 1: H < HMIN
      R(1) = EARTHR + 50.0
      CALL COLFRZ
      IF (Z .NE. 0.0) THEN
        PRINT *, 'Test 1 FAILED: Z = ', Z
        STOP 1
      END IF

C     Test 2: H > HMIN
      R(1) = EARTHR + 150.0
      CALL COLFRZ
      IF (ABS(Z - 1.0) .GT. 1.0E-5) THEN
        PRINT *, 'Test 2 FAILED: Z = ', Z
        STOP 1
      END IF

      PRINT *, 'Test for CONSTZ PASSED'
      END PROGRAM TEST_CONSTZ
