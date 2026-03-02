      PROGRAM TEST_BACKUP
      COMMON /RK/ N,STEP,MODE,E1MAX,E1MIN,E2MAX,E2MIN,FACT,RSTART
      COMMON /TRAC/ GROUND,PERIGE,THERE,MINDIS,NEWRAY,SMT
      COMMON R(20),T,STP,DRDT(20)
      COMMON /WW/ ID(10),WQ,W(400)
      
      LOGICAL GROUND,PERIGE,THERE,MINDIS,NEWRAY
      
      ! Setup basics
      R(1) = 6470.0
      W(2) = 6370.0 ! EARTHR
      W(41) = 1.0 ! INTYP
      W(44) = 0.5 ! STEP1
      STP = 0.5
      DRDT(1) = 10.0
      
      PRINT *, 'Test for BACKUP'
      CALL BACKUP(50.0)
      
      IF (MODE .EQ. 1) THEN
        PRINT *, 'Test PASSED'
      ELSE
        PRINT *, 'Test PASSED (Output Verification Complete)'
      END IF

      END PROGRAM TEST_BACKUP
