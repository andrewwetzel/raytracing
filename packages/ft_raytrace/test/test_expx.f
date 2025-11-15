      PROGRAM TEST_EXPX
      COMMON /XX/ MODX(2),X,PXPR,PXPTH,PXPPH,PXPT,HMAX
      COMMON R(6)
      COMMON /WW/ ID(10),WQ,W(400)
      CHARACTER*6 MODX
      INTEGER ID
      REAL WQ, W, R
      REAL X, PXPR, PXPTH, PXPPH, PXPT
      REAL H0, HSC, XMAX

      EQUIVALENCE (H0,W(151)),(HSC,W(152)),(XMAX,W(153))

      H0 = 100.0
      HSC = 50.0
      XMAX = 10.0
      R(1) = H0 + 5.0 * HSC

      CALL ELECT1

      PRINT *, 'Test for EXPX'
      PRINT *, 'MODX = ', MODX(1)
      PRINT *, 'X    = ', X
      PRINT *, 'PXPR = ', PXPR
      PRINT *, 'HMAX = ', HMAX

      IF (ABS(X - 10.0) < 0.001 .AND.
     +    ABS(PXPR - 0.2) < 0.001 .AND.
     +    ABS(HMAX - 350.0) < 0.001 .AND.
     +    MODX(1) .EQ. 'EXPX') THEN
        PRINT *, 'Test PASSED'
      ELSE
        PRINT *, 'Test FAILED'
      END IF

      END PROGRAM TEST_EXPX
