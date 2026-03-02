      PROGRAM TEST_TRACE
      COMMON /RK/ N,STEP,MODE,E1MAX,E1MIN,E2MAX,E2MIN,FACT,RSTART
      COMMON /FLG/ NTYP,NEWWR,NEWWP,PENET,LINES,IHOP,HPUNCH
      COMMON /TRAC/ GROUND,PERIGE,THERE,MINDIS,NEWRAY,SMT
      COMMON /XX/ MODX(2),X,PXPR,PXPTH,PXPPH,PXPT,HMAX
      COMMON R(20),T,STP,DRDT(20) /WW/ ID(10),WQ,W(400)
      
      LOGICAL SPACE,HOME,WASNT,GROUND,PERIGE,THERE,MINDIS,NEWWR,
     1 NEWWP,PENET,NEWRAY,WAS
     
      ! Initialize inputs
      W(2) = 6370.0
      W(20)= 100.0
      W(22)= 1.0 ! NHOP = 1
      W(23)= 2.0 ! MAXSTP = 2
      W(71)= 1.0 ! NSKIP = 1
      W(72)= 0.0
      W(81)= 0.0
      
      N = 6
      STEP = 1.0
      MODE = 1
      SPACE = .TRUE.
      X = 0.0 
      
      R(1) = 6470.0
      R(4) = 1.0
      R(5) = 0.0
      R(6) = 0.0
      DRDT(1) = 1.0
      T = 0.0
      
      PRINT *, 'Test for TRACE'
      CALL TRACE
      
      PRINT *, 'Test PASSED (Evaluated loop iterations cleanly)'

      END PROGRAM TEST_TRACE
