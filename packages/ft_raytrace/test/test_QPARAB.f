      PROGRAM TEST_QPARAB
      COMMON /XX/ MODX(2),X,PXPR,PXPTH,PXPPH,PXPT,HMAX
      COMMON R(6)
      COMMON /WW/ ID(10),WQ,W(400)
      EQUIVALENCE (EARTHR,W(2)),(F,W(6)),(FC,W(101)),(HM,W(102)),
     1 (YM,W(103)),(QUASI,W(104)),(PERT,W(150))
      CHARACTER*6 MODX

      EARTHR = 6370.0
      F = 5.0
      FC = 10.0
      HM = 300.0
      YM = 100.0
      QUASI = 0.0
      PERT = 0.0

C     Test at peak height: H=HM, so Z=0, X=FCF2=4.0
      R(1) = EARTHR + 300.0
      R(2) = 0.0

      CALL ELECTX

      PRINT *, 'Test for QPARAB'
      PRINT *, 'MODX = ', MODX(1)
      PRINT *, 'X    = ', X
      PRINT *, 'PXPR = ', PXPR

C     Expected: FCF2 = (10/5)^2 = 4.0, Z=0, X=4.0, PXPR=0.0
      IF (MODX(1) .EQ. 'QPARAB' .AND.
     +    ABS(X - 4.0) .LT. 1.0E-5 .AND.
     +    ABS(PXPR) .LT. 1.0E-5) THEN
        PRINT *, 'Test PASSED'
      ELSE
        PRINT *, 'Test FAILED'
      END IF

      END PROGRAM TEST_QPARAB
