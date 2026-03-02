      PROGRAM TEST_PRINTR
      COMMON /CONST/ PI,PIT2,PID2,DEGS,RAD,DUM(3)
      COMMON /FLG/ NTYP,NEWWR,NEWWP,PENET,LINES,IHOP,HPUNCH
      COMMON R(20),T
      COMMON /WW/ ID(10),WQ,W(400)
      
      LOGICAL NEWWR,NEWWP,PENET
      
      PI = 3.14159265
      PIT2 = 2.0 * PI
      PID2 = PI / 2.0
      DEGS = 180.0 / PI
      RAD = PI / 180.0
      
      W(2) = 6370.0
      W(3) = 0.0
      W(4) = 0.5
      W(5) = 1.0
      W(6) = 10.0
      W(10) = 0.5
      W(14) = 0.5
      W(20) = 100.0
      W(24) = 0.5
      W(25) = 1.0
      W(72) = 0.0
      
      NEWWP = .TRUE.
      IHOP = 0
      
      R(1) = 6470.0
      R(2) = 0.5
      R(3) = 1.0
      R(4) = 1.0
      R(5) = 0.5
      R(6) = 0.0
      T = 0.0
      
      PRINT *, 'Test for PRINTR'
      CALL PRINTR('TEST    ', 0.0)
      
      PRINT *, 'Test PASSED'

      END PROGRAM TEST_PRINTR
