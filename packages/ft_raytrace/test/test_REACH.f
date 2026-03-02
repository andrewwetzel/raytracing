      PROGRAM TEST_REACH
      COMMON /RK/ N,STEP,MODE,E1MAX,E1MIN,E2MAX,E2MIN,FACT,RSTART
      COMMON /TRAC/ GROUND,PERIGE,THERE,MINDIS,NEWRAY,SMT
      COMMON /COORD/ S
      COMMON /XX/ MODX(2),X,PXPR,PXPTH,PXPPH,PXPT,HMAX
      COMMON R(20),T,STP,DRDT(20) 
      COMMON /WW/ ID(10),WQ,W(400)
      
      LOGICAL GROUND,PERIGE,THERE,MINDIS,NEWRAY
      
      ! Setup basics
      R(1) = 6470.0
      R(4) = 1.0
      R(5) = 1.0
      R(6) = 0.0
      
      W(2) = 6370.0 ! EARTHR
      W(20)= 100.0  ! RCVRH
      
      X = 1.0
      NEWRAY = .TRUE.
      
      PRINT *, 'Test for REACH'
      CALL REACH
      
      PRINT *, 'New R(1) = ', R(1)
      PRINT *, 'New R(4) = ', R(4)
      
      IF (R(1) .GT. 6400.0) THEN
        PRINT *, 'Test PASSED'
      ELSE
        PRINT *, 'Test FAILED'
      END IF

      END PROGRAM TEST_REACH
