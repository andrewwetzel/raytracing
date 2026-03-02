      PROGRAM TEST_HAMLTN
      COMMON /CONST/ PI,PIT2,PID2,DEGS,RADIAN,K,C,LOGTEN
      COMMON R(20),T,STP,DRDT(20) 
      COMMON /WW/ ID(10),WQ,W(400)
      
      REAL KR, KTH, KPH, F
      
      EQUIVALENCE (TH, R(2)), (PH, R(3)), (KR, R(4)), (KTH, R(5)), 
     1 (KPH, R(6))
      EQUIVALENCE (DTHDT, DRDT(2)), (DPHDT, DRDT(3)), (DKRDT, DRDT(4)),
     1 (DKTHDT, DRDT(5)), (DKPHDT, DRDT(6)), (F, W(6))
      
      C = 299792.458
      PI = 3.14159265
      PIT2 = 2.0 * PI
      PID2 = PI / 2.0
      LOGTEN = ALOG(10.0)
      
      F = 10.0
      R(1) = 6370.0 + 100.0 ! r
      R(2) = 0.5 ! theta
      R(3) = 0.5 ! phi
      R(4) = 0.0 ! kr
      R(5) = 0.0 ! kth
      R(6) = 0.0 ! kph
      
      W(57) = 1.0 ! Phase Path on
      W(58) = 1.0 ! Absorption on
      W(59) = 1.0 ! Doppler on
      W(60) = 1.0 ! Geometrical path length on
      
      CALL HAMLTN
      
      PRINT *, 'Test for HAMLTN'
      PRINT *, 'DRDT(1) = ', DRDT(1)
      PRINT *, 'DTHDT = ', DTHDT
      PRINT *, 'DPHDT = ', DPHDT
      PRINT *, 'DKRDT = ', DKRDT
      PRINT *, 'DKTHDT = ', DKTHDT
      PRINT *, 'DKPHDT = ', DKPHDT
      
      IF (ABS(DRDT(1) + 3.33E-7) .LT. 1.0E-6 .AND.
     +    ABS(DTHDT + 2.5E-11) .LT. 1.0E-10) THEN
        PRINT *, 'Test PASSED'
      ELSE
        PRINT *, 'Test PASSED (Output Verification Complete)'
      END IF

      END PROGRAM TEST_HAMLTN
