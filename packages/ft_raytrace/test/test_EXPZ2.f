      PROGRAM TEST_EXPZ2
      COMMON /CONST/ PI, PIT2, PID2, DUM(5)
      COMMON /ZZ/ MODZ, Z, PZPR, PZPTH, PZPPH
      COMMON R(6)
      COMMON /WW/ ID(10), WQ, W(400)
      
      REAL NU1, NU2
      EQUIVALENCE (EARTHR, W(2)), (F, W(6)), (NU1, W(251)),
     1 (H1, W(252)), (A1, W(253)), (NU2, W(254)), (H2, W(255)),
     2 (A2, W(256))
     
      CHARACTER*6 MODZ

      PI = 3.1415926535
      PIT2 = 2.0 * PI
      PID2 = PI / 2.0

      EARTHR = 6370.0
      F = 1.0
      
      NU1 = PIT2 * 1.0E6
      H1 = 100.0
      A1 = 0.1
      
      NU2 = PIT2 * 1.0E6
      H2 = 120.0
      A2 = 0.2

C     Test at H1 = 100.0
C     EXP1 = PIT2*1M * exp(0) = PIT2*1M
C     EXP2 = PIT2*1M * exp(-0.2*(100-120)) = PIT2*1M * exp(4) = PIT2*1M * 54.59815
C     Z = (1 + 54.59815) = 55.59815
C     PZPR = (-0.1*1 - 0.2*54.59815) = (-0.1 - 10.91963) = -11.01963
      R(1) = EARTHR + 100.0
      CALL COLFRZ
      
      IF (ABS(Z - 55.59815) .GT. 1.0E-4 .OR. 
     +    ABS(PZPR - (-11.01963)) .GT. 1.0E-4) THEN
        PRINT *, 'Test FAILED: Z, PZPR = ', Z, PZPR
        STOP 1
      END IF

      PRINT *, 'Test for EXPZ2 PASSED'
      END PROGRAM TEST_EXPZ2
