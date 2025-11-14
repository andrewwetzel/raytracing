      PROGRAM TEST_DCHAPT
      COMMON /CONST/ PI,PIT2,PID2,DUM(5)
      COMMON /XX/ MODX(2),X(6),HMAX
      COMMON R(6)
      COMMON /WW/ ID(10),WQ,W(400)
      CHARACTER*8 MODX
      INTEGER ID
      REAL WQ, W, R
      REAL FC1, HM1, SH1, FC2, HM2, SH2, C, E, PERT

      EQUIVALENCE (EARTHR,W(2)),(F,W(6)),(FC1,W(101)),(HM1,W(102)),
     1 (SH1,W(103)),(FC2,W(104)),(HM2,W(105)),(SH2,W(106)),(C,W(107)),
     2 (E,W(108)),(PERT,W(150))

      PI = 3.1415926535
      PIT2 = 2.0 * PI
      PID2 = PI / 2.0

      EARTHR = 6370.0
      F = 5.0
      FC1 = 10.0
      HM1 = 300.0
      SH1 = 100.0
      FC2 = 5.0
      HM2 = 400.0
      SH2 = 50.0
      C = 0.1
      E = 0.2
      PERT = 0.0

      R(1) = EARTHR + 300.0
      R(2) = PID2

      CALL ELECTX

      PRINT *, 'Test for DCHAPT'
      PRINT *, 'MODX = ', MODX(1)
      PRINT *, 'X    = ', X(1)

      IF (X(1) > 0.0) THEN
        PRINT *, 'Test PASSED'
      ELSE
        PRINT *, 'Test FAILED'
      END IF

      END PROGRAM TEST_DCHAPT
