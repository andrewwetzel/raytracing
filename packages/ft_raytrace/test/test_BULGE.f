      PROGRAM TEST_BULGE
      COMMON /CONST/ PI,PIT2,PID2,DUM(5)
      COMMON /XX/ MODX(2),X(6),HMAX,PXPR,PXPTH,PXPPH
      COMMON R(6)
      COMMON /WW/ ID(10),WQ,W(400)
      CHARACTER*8 MODX
      INTEGER ID
      REAL WQ, W, R

      EQUIVALENCE (EARTHR,W(2)),(F,W(6)),(PERT,W(150))

      PI = 3.1415926535
      PIT2 = 2.0 * PI
      PID2 = PI / 2.0

      EARTHR = 6370.0
      F = 5.0
      PERT = 0.1

      R(1) = EARTHR + 300.0
      R(2) = PID2 ! Colatitude for equator (latitude 0)

      CALL ELECTX

      PRINT *, 'Test for BULGE'
      PRINT *, 'MODX = ', MODX(1)
      PRINT *, 'X    = ', X(1)

      IF (X(1) > 0.0) THEN
        PRINT *, 'Test PASSED'
      ELSE
        PRINT *, 'Test FAILED'
      END IF

      END PROGRAM TEST_BULGE
