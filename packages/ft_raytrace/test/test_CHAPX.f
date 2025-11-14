      PROGRAM TEST_CHAPX
      COMMON /CONST/ PI,PIT2,PID2,DUM(5)
      COMMON /XX/ MODX(2),X(6),HMAX
      COMMON R(6)
      COMMON /WW/ ID(10),WQ,W(400)
      CHARACTER*8 MODX
      INTEGER ID
      REAL WQ, W, R
      REAL FC, HM, SH, ALPHA, A, B, C, E, PERT

      EQUIVALENCE (EARTHR,W(2)),(F,W(6)),(FC,W(101)),(HM,W(102)),
     1 (SH,W(103)),(ALPHA,W(104)),(A,W(105)),(B,W(106)),(C,W(107)),
     2 (E,W(108)),(PERT,W(150))

      PI = 3.1415926535
      PIT2 = 2.0 * PI
      PID2 = PI / 2.0

      EARTHR = 6370.0
      F = 5.0
      FC = 10.0
      HM = 300.0
      SH = 100.0
      ALPHA = 0.5
      A = 0.1
      B = 0.2
      C = 0.3
      E = 0.4
      PERT = 0.0

      R(1) = EARTHR + 300.0
      R(2) = PID2

      CALL ELECTX

      PRINT *, 'Test for CHAPX'
      PRINT *, 'MODX = ', MODX(1)
      PRINT *, 'X    = ', X(1)

      IF (X(1) > 0.0) THEN
        PRINT *, 'Test PASSED'
      ELSE
        PRINT *, 'Test FAILED'
      END IF

      END PROGRAM TEST_CHAPX
