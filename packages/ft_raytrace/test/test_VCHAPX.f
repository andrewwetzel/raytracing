      PROGRAM TEST_VCHAPX
      COMMON /XX/ MODX(2),X,PXPR,PXPTH,PXPPH,PXPT,HMAX
      COMMON R(6)
      COMMON /WW/ ID(10),WQ,W(400)
      EQUIVALENCE (EARTHR,W(2)),(F,W(6)),(FC,W(101)),(HM,W(102)),
     1 (CHI,W(103)),(PERT,W(150))
      CHARACTER*6 MODX

      EARTHR = 6370.0
      F = 5.0
      FC = 10.0
      HM = 300.0
      CHI = 2.0
      PERT = 0.0

C     Test at H=HM: TAU=(HM/HM)^CHI=1.0, X=(FC/F)^2*1.0*exp(0)=4.0
      R(1) = EARTHR + 300.0
      R(2) = 0.0

      CALL ELECTX

      PRINT *, 'Test for VCHAPX'
      PRINT *, 'MODX = ', MODX(1)
      PRINT *, 'X    = ', X
      PRINT *, 'PXPR = ', PXPR

C     At H=HM: TAU=1, X=4.0, PXPR=0.5*4.0*(1-1)*CHI/H=0.0
      IF (MODX(1) .EQ. 'VCHAPX' .AND.
     +    ABS(X - 4.0) .LT. 1.0E-5 .AND.
     +    ABS(PXPR) .LT. 1.0E-5) THEN
        PRINT *, 'Test PASSED'
      ELSE
        PRINT *, 'Test FAILED'
      END IF

      END PROGRAM TEST_VCHAPX
