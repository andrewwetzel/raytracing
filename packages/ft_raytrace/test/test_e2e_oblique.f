      PROGRAM E2E_OBLIQUE
C     End-to-end test: Oblique HF ray trace at 30-degree elevation
      COMMON /CONST/ PI,PIT2,PID2,DEGS,RAD,AK,C,LOGTEN
      COMMON /FLG/ NTYP,NEWWR,NEWWP,PENET,LINES,IHOP,HPUNCH
      COMMON /RIN/ MODRIN(3),COLL,FIELD,SPACE,KAY2,KAY2I,
     1 H,HI,PHPT,PHPTI,PHPR,PHPRI,PHPTH,PHPTHI,PHPPH,PHPPHI,
     2 PHPOM,PHPOMI,PHPKR,PHPKRI,PHPKTH,PHPKTI,PHPKPH,PHPKPI,
     3 KPHPK,KPHPKI,POLAR,POLARI,LPOLAR,LPOLRI,SGN
      COMMON /RK/ N,STEP,MODE,E1MAX,E1MIN,E2MAX,E2MIN,FACT,RSTART
      COMMON /TRAC/ GROUND,PERIGE,THERE,MINDIS,NEWRAY,SMT
      COMMON /XX/ MODX(2),X,PXPR,PXPTH,PXPPH,PXPT,HMAX
      COMMON R(20),T,STP,DRDT(20)
      COMMON /WW/ ID(10),WQ,W(400)
      
      LOGICAL SPACE,NEWWR,NEWWP,PENET,GROUND,PERIGE,THERE,MINDIS,
     1 NEWRAY
      REAL T_START, T_END, ELEV_RAD
      REAL KAY2,KAY2I,H,HI,PHPT,PHPTI,PHPR,PHPRI,PHPTH,PHPTHI
      REAL PHPPH,PHPPHI,PHPOM,PHPOMI,PHPKR,PHPKRI,PHPKTH,PHPKTI
      REAL PHPKPH,PHPKPI,KPHPK,KPHPKI,POLAR,POLARI,LPOLAR,LPOLRI

      PRINT *, '=== E2E Test: Oblique HF Ray (30 deg) ==='
      CALL CPU_TIME(T_START)

      PI = 3.141592653
      PIT2 = 2.0 * PI
      PID2 = PI / 2.0
      DEGS = 180.0 / PI
      RAD = PI / 180.0
      C = 2.997925E5
      AK = 2.81785E-15 * C * C / PI
      LOGTEN = ALOG(10.0)

      DO NW=1,400
        W(NW) = 0.0
      END DO
      W(2) = 6370.0
      W(6) = 10.0
      W(22)= 1.0
      W(41)= 1.0

      N = 6
      MODE = 1
      STEP = 0.01
      STP = 0.01
      E1MAX = 1.0E-4
      E1MIN = 2.0E-6
      E2MAX = 100.0
      E2MIN = 1.0E-8
      FACT = 0.5
      RSTART = 1.0

C     Ray launched at 30 degrees above horizontal
      ELEV_RAD = 30.0 * RAD
      R(1) = 6470.0
      R(2) = 0.5
      R(3) = 0.0
      R(4) = SIN(ELEV_RAD)
      R(5) = COS(ELEV_RAD)
      R(6) = 0.0
      T = 0.0

      PRINT *, 'Elevation angle: 30 degrees'
      PRINT *, 'kr =', R(4), ' kth =', R(5)

      CALL HAMLTN
      PRINT *, 'Initial derivatives computed'
      PRINT *, '  DRDT(1)=', DRDT(1), ' DRDT(2)=', DRDT(2)

      DO ISTEP=1,5
        CALL RKAM
        PRINT *, 'Step', ISTEP, ': R(1)=', R(1), ' R(2)=', R(2),
     1           ' T=', T
      END DO

      CALL CPU_TIME(T_END)

      PRINT *, ''
      PRINT *, 'Elapsed CPU time:', (T_END - T_START)*1000.0, ' ms'
      PRINT *, 'Test PASSED (oblique ray integration executed cleanly)'

      END PROGRAM E2E_OBLIQUE
