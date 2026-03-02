      SUBROUTINE TABLEZ
C     CALCULATES COLLISION FREQUENCY AND ITS GRADIENT FROM PROFILES
      DIMENSION HPC(250), FN2C(250)
      COMMON /CONST/ PI, PIT2, PID2, DUM(5)
      COMMON /ZZ/ MODZ, Z, PZPR, PZPTH, PZPPH
      COMMON R(6) /WW/ ID(10), WQ, W(400)
      EQUIVALENCE (EARTHR, W(2)), (F, W(6)), (READNU, W(250))
      
      REAL FN2_INTERP
      CHARACTER*6 MODZ
      DATA MODZ /'TABLEZ'/
      
      ENTRY COLFRZ
      IF (READNU .EQ. 0.0) GO TO 10
      READNU = 0.0
      READ 1000, NOC, (HPC(I), FN2C(I), I=1,NOC)
 1000 FORMAT (I4/(F8.2,E12.4))
      PRINT 1200, (HPC(I), FN2C(I), I=1,NOC)
 1200 FORMAT(1H1,14X,6HHEIGHT,4X,20HCOLLISION FREQUENCY/
     1 (1X,F20.10,E20.10))
     
      A = 0.0
      IF (FN2C(1) .NE. 0.0) A = ALOG(FN2C(2)/FN2C(1))/(HPC(2)-HPC(1))
      
      DO 7 I=1,NOC
        FN2C(I) = FN2C(I) / (PIT2 * 1.0E6)
    7 CONTINUE

 10   H = R(1) - EARTHR
      Z = 0.0
      PZPR = 0.0
      PZPTH = 0.0
      PZPPH = 0.0
      
      NH = 2
      IF (H .GE. HPC(1)) GO TO 12
 11   NH = 2
      IF (FN2C(1) .EQ. 0.0) GO TO 50
      Z = FN2C(1) * EXP(A*(H-HPC(1))) / F
      PZPR = A * Z
      GO TO 50

 12   IF (H .GE. HPC(NOC)) GO TO 18
      NSTEP = 1
      IF (H .LT. HPC(NH-1)) NSTEP = -1
 15   IF (HPC(NH-1) .LE. H .AND. H .LT. HPC(NH)) THEN
        FN2_INTERP = FN2C(NH-1) + (H - HPC(NH-1)) *
     +   (FN2C(NH) - FN2C(NH-1)) / (HPC(NH) - HPC(NH-1))
        Z = FN2_INTERP / F
        PZPR = (FN2C(NH) - FN2C(NH-1)) / (HPC(NH) - HPC(NH-1)) / F
        GO TO 50
      END IF
      NH = NH + NSTEP
      GO TO 15

 18   Z = FN2C(NOC) / F
      PZPR = 0.0

 50   CONTINUE
      RETURN
      END
