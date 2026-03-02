      SUBROUTINE RKAM
C     NUMERICAL INTEGRATION OF DIFFERENTIAL EQUATIONS
      COMMON /RK/ NN,SPACE,MODE,E1MAX,E1MIN,E2MAX,E2MIN,FACT,RSTART
      COMMON Y(20),T,STEP,DYDT(20)
      DIMENSION DELY(4,20),BET(4),XV(5),FV(5,20),YU(5,20)
      DOUBLE PRECISION YU
      SAVE DELY, BET, XV, FV, YU, LL, MM, ALPHA, EPM
      
      REAL SPACE, E1MAX, E1MIN, E2MAX, E2MIN, FACT, RSTART
      REAL T, STEP, DEL, EPSIL, E, EPM, SSE
      LOGICAL SPACE_FLAG

      IF (RSTART.EQ.0.0) GO TO 1000
      LL = 1
      MM = 1
      IF (MODE.EQ.1) MM = 4
      
      ALPHA = T
      EPM = 0.0
      
      BET(1) = 0.5
      BET(2) = 0.5
      BET(3) = 1.0
      BET(4) = 0.0
      
      STEP = SPACE
      Y(19) = 270.0
      XV(MM) = T
      
      IF (E1MIN.LE.0.0) E1MIN = E1MAX/55.0
      IF (FACT.LE.0.0) FACT = 0.5
      
      CALL HAMLTN
      
      DO 320 I=1,NN
        FV(MM,I) = DYDT(I)
        YU(MM,I) = Y(I)
 320  CONTINUE

      RSTART = 0.0
      GO TO 1001

 1000 IF (MODE.NE.1) GO TO 2000

C     RUNGE-KUTTA
 1001 DO 1034 K=1,4
        DO 1350 I=1,NN
          DELY(K,I) = STEP * FV(MM,I)
          Z = YU(MM,I)
          Y(I) = Z + BET(K)*DELY(K,I)
 1350   CONTINUE
        
        T = BET(K)*STEP + XV(MM)
        CALL HAMLTN
        
        DO I=1,NN
          FV(MM,I) = DYDT(I)
        END DO
 1034 CONTINUE

      DO 1039 I=1,NN
        DEL = (DELY(1,I) + 2.0*DELY(2,I) + 2.0*DELY(3,I) + DELY(4,I))
     1        / 6.0
        YU(MM+1,I) = YU(MM,I) + DEL
 1039 CONTINUE

      MM = MM+1
      XV(MM) = XV(MM-1) + STEP
      
      DO 1400 I=1,NN
        Y(I) = YU(MM,I)
 1400 CONTINUE
 
      T = XV(MM)
      CALL HAMLTN
      
      IF (MODE.EQ.1) GO TO 42
      DO 150 I=1,NN
        FV(MM,I) = DYDT(I)
 150  CONTINUE
 
      IF (MM.LE.3) GO TO 1001

C     ADAMS-MOULTON
 2000 DO 2046 I=1,NN
        DEL = STEP*(55.0*FV(4,I) - 59.0*FV(3,I) + 37.0*FV(2,I) 
     1        - 9.0*FV(1,I))/24.0
        Y(I) = YU(4,I) + DEL
        DELY(1,I) = Y(I)
 2046 CONTINUE

      T = XV(4) + STEP
      CALL HAMLTN
      XV(5) = T
      
      DO 2051 I=1,NN
        DEL = STEP*(9.0*DYDT(I) + 19.0*FV(4,I) - 5.0*FV(3,I) 
     1        + FV(2,I))/24.0
        YU(5,I) = YU(4,I) + DEL
        Y(I) = YU(5,I)
 2051 CONTINUE

      CALL HAMLTN
      
      IF (MODE.LE.2) GO TO 42

C     ERROR ANALYSIS
      SSE = 0.0
      DO 3033 I=1,NN
        EPSIL = 8.0 * ABS(Y(I) - DELY(1,I))
        IF (MODE.EQ.3 .AND. Y(I).NE.0.0) EPSIL = EPSIL / ABS(Y(I))
        IF (SSE.LT.EPSIL) SSE = EPSIL
 3033 CONTINUE

      IF (E1MAX.GT.SSE) GO TO 3035
      IF (ABS(STEP).LE.E2MIN) GO TO 42
      LL = 1
      MM = 1
      STEP = STEP * FACT
      GO TO 1001
      
 3035 IF (LL.LE.1 .OR. SSE.GE.E1MIN .OR. E2MAX.LE.ABS(STEP)) GO TO 42

      LL = 2
      MM = 3
      XV(2) = XV(3)
      XV(3) = XV(5)
      
      DO 5363 I=1,NN
        FV(2,I) = FV(3,I)
        FV(3,I) = DYDT(I)
        YU(2,I) = YU(3,I)
        YU(3,I) = YU(5,I)
 5363 CONTINUE

      STEP = 2.0 * STEP
      GO TO 1001

C     EXIT ROUTINE
 42   LL = 2
      MM = 4
      
      DO K=1,3
        XV(K) = XV(K+1)
        DO I=1,NN
          FV(K,I) = FV(K+1,I)
          YU(K,I) = YU(K+1,I)
        END DO
      END DO

      XV(4) = XV(5)
      DO 52 I=1,NN
        FV(4,I) = DYDT(I)
        YU(4,I) = YU(5,I)
 52   CONTINUE

      IF (MODE.LE.2) RETURN
      
      E = ABS(XV(4) - ALPHA)
      IF (E.LE.EPM) GO TO 2000
      EPM = E
      
      RETURN
      END
