      PROGRAM TEST_BULGE
      COMMON /XX/ MODX(2),X,PXPR,PXPTH,PXPPH,PXPT,HMAX
      COMMON R(6)
      COMMON /WW/ ID(10),WQ,W(400)
      CHARACTER*6 MODX
      INTEGER ID
      REAL WQ, W, R
      REAL X, PXPR, PXPTH, PXPPH, PXPT
      REAL H0, HSC, XMAX, FRAC, XLAT, XLON, HSC2, HSC3, HSC4

      EQUIVALENCE (H0,W(151)),(HSC,W(152)),(XMAX,W(153)),
     1 (FRAC,W(154)),(XLAT,W(155)),(XLON,W(156)),(HSC2,W(157)),
     2 (HSC3,W(158)),(HSC4,W(159))

      H0 = 100.0
      HSC = 50.0
      XMAX = 10.0
      FRAC = 0.1
      XLAT = 0.0
      XLON = 0.0
      HSC2 = 10.0
      HSC3 = 10.0
      R(1) = H0 + 5.0 * HSC
      R(2) = XLAT

      CALL ELECT1

      PRINT *, 'Test for BULGE'
      PRINT *, 'MODX = ', MODX(1)
      PRINT *, 'X    = ', X
      PRINT *, 'PXPR = ', PXPR
      PRINT *, 'PXPTH= ', PXPTH
      PRINT *, 'HMAX = ', HMAX

      IF (ABS(X - 11.0) < 0.001 .AND.
     +    ABS(PXPR - 0.22) < 0.001 .AND.
     +    ABS(PXPTH - 0.0) < 0.001 .AND.
     +    ABS(HMAX - 350.0) < 0.001 .AND.
     +    MODX(1) .EQ. 'BULGE') THEN
        PRINT *, 'Test PASSED'
      ELSE
        PRINT *, 'Test FAILED'
      END IF

      END PROGRAM TEST_BULGE
