      PROGRAM TEST_RKAM
      COMMON /RK/ NN,SPACE,MODE,E1MAX,E1MIN,E2MAX,E2MIN,FACT,RSTART
      COMMON Y(20),T,STEP,DYDT(20)
      
      REAL Y, T, STEP, DYDT
      REAL SPACE, E1MAX, E1MIN, E2MAX, E2MIN, FACT, RSTART
      
      ! Setup
      NN = 6
      SPACE = 1.0
      MODE = 1
      E1MAX = 1.0E-4
      E1MIN = 1.0E-6
      E2MAX = 1.0E-2
      E2MIN = 1.0E-8
      FACT  = 0.5
      RSTART = 1.0
      
      T = 0.0
      Y(1) = 6470.0
      Y(2) = 0.5
      Y(3) = 0.5
      Y(4) = 0.0
      Y(5) = 0.0
      Y(6) = 0.0
      
      ! Run numerical integration step
      CALL RKAM
      
      PRINT *, 'Test for RKAM (Numerical Integrator)'
      PRINT *, 'New T = ', T
      PRINT *, 'New R = ', Y(1)
      PRINT *, 'New TH= ', Y(2)
      PRINT *, 'New PH= ', Y(3)
      PRINT *, 'New KR= ', Y(4)
      PRINT *, 'New KTH=', Y(5)
      PRINT *, 'New KPH=', Y(6)
      
C     We evaluate that a step successfully incremented variables without throwing an error
      IF (T .GT. 0.0) THEN
        PRINT *, 'Test PASSED'
      ELSE
        PRINT *, 'Test FAILED'
      END IF

      END PROGRAM TEST_RKAM
