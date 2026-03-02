      PROGRAM NITIAL
C     SETS THE INITIAL CONDITIONS FOR EACH RAY AND CALLS TRACE
C     Transcribed from OT Report 75-76
      DIMENSION MFLD(2)
      COMMON /CONST/ PI,PIT2,PID2,DEGS,RAD,AK,C,LOGTEN
      COMMON /FLG/ NTYP,NEWWR,NEWWP,PENET,LINES,IHOP,HPUNCH
      COMMON /RIN/ MODRIN(3),COLL,FIELD,SPACE,N2,N2I,PNP(10),
     1 POLAR,LPOLAR,SGN
      COMMON /RK/ N,STEP,MODE,E1MAX,E1MIN,E2MAX,E2MIN,FACT,RSTART
      COMMON /XX/ MODX(2),X,PXPR,PXPTH,PXPPH,PXPT,HMAX
      COMMON /YY/ MODY,Y(16) 
      COMMON /ZZ/ MODZ,Z(5)
      COMMON R(20),T,STP,DRDT(20)
      COMMON /WW/ ID(10),WQ,W(400)
      
      EQUIVALENCE (RAY,W(1)),(EARTHR,W(2)),(XMTRH,W(3)),
     1 (TLAT,W(4)),(TLON,W(5)),(F,W(6)),
     2 (FBEG,W(7)),(FEND,W(8)),(FSTEP,W(9)),
     3 (AZ1,W(10)),(AZBEG,W(11)),(AZEND,W(12)),(AZSTEP,W(13)),
     4 (BETA,W(14)),(ELBEG,W(15)),(ELEND,W(16)),(ELSTEP,W(17)),
     5 (ONLY,W(21)),(HOP,W(22)),(MAXSTP,W(23)),
     6 (PLAT,W(24)),(PLON,W(25)),
     7 (INTYP,W(41)),(MAXERR,W(42)),(ERATIO,W(43)),
     8 (STEP1,W(44)),(STPMAX,W(45)),(STPMIN,W(46)),
     9 (FACTR,W(47)),(SKIP,W(71)),(RAYSET,W(72)),(PLT,W(81)),
     A (PERT,W(150))
      
      LOGICAL SPACE,NEWWR,NEWWP,PENET
      REAL N2,N2I,LOGTEN,AK,MAXSTP,INTYP,MAXERR,MU
      COMPLEX PNP,POLAR,LPOLAR

C     CONSTANTS
      PI = 3.141592653
      PIT2 = 2.0 * PI
      PID2 = PI / 2.0
      DEGS = 180.0 / PI
      RAD = PI / 180.0
      C = 2.997925E5
      AK = 2.81785E-15 * C * C / PI
      LOGTEN = ALOG(10.0)

C     INITIALIZE W ARRAY
      DO NW=1,400
        W(NW) = 0.0
      END DO
      PLON = 0.0
      PLAT = PID2
      EARTHR = 6370.0
      INTYP = 3.0
      MAXERR = 1.0E-4
      ERATIO = 50.0
      STEP1 = 1.0
      MAXSTP = 100.0
      STPMIN = 1.0E-8
      FACTR = 0.5
      W(23) = 1000.0
      HOP = 1.0

C     READ W ARRAY
 10   CALL READW

      F = 0.0
      BETA = 0.0
      AZ1 = 0.0
      IF (SKIP .EQ. 0.0) SKIP = W(23)

      NEWWP = .TRUE.
      NEWWR = .TRUE.

C     INITIALIZE PARAMETERS FOR INTEGRATION SUBROUTINE RKAM
      N = 6
      DO NR=7,20
        IF (W(50+NR) .NE. 0.0) N = N + 1
      END DO
      MODE = INTYP
      STEP = STEP1
      E1MAX = MAXERR
      E1MIN = MAXERR / ERATIO
      E2MAX = STPMAX
      E2MIN = STPMIN
      FACT = FACTR

C     DETERMINE TRANSMITTER LOCATION
      RO = EARTHR + XMTRH
      SP = SIN(PLAT)
      CP = COS(PLAT)
      SDPH = SIN(TLON - PLON)
      CDPH = COS(TLON - PLON)
      SL = SIN(TLAT)
      CL = COS(TLAT)
      ALPHA = ATAN2(-SDPH*CP, -CDPH*CP*SL + SP*CL)
      THO = ACOS(CDPH*CP*CL + SP*SL)
      PHO = ATAN2(SDPH*CL, CDPH*SP*CL - CP*SL)

C     LOOP ON FREQUENCY, AZIMUTH ANGLE, AND ELEVATION ANGLE
      NFREQ = 1
      IF (FSTEP .NE. 0.0) NFREQ = (FEND-FBEG)/FSTEP + 1.5
      NAZ = 1
      IF (AZSTEP .NE. 0.0) NAZ = (AZEND-AZBEG)/AZSTEP + 1.5
      NBETA = 1
      IF (ELSTEP .NE. 0.0) NBETA = (ELEND-ELBEG)/ELSTEP + 1.5

      DO 50 NF=1,NFREQ
        F = FBEG + (NF-1)*FSTEP
        DO 45 J=1,NAZ
          AZ1 = AZBEG + (J-1)*AZSTEP
          GAMMA = PI - AZ1 + ALPHA
          SGAMMA = SIN(GAMMA)
          CGAMMA = COS(GAMMA)
          DO 40 I=1,NBETA
            BETA = ELBEG + (I-1)*ELSTEP
            CBETA = COS(BETA)
            R(1) = RO
            R(2) = THO
            R(3) = PHO
            R(4) = SIN(BETA)
            R(5) = CBETA*CGAMMA
            R(6) = CBETA*SGAMMA
            T = 0.0
            RSTART = 1.0
            SGN = 1.0
            CALL RINDEX

            IF (REAL(N2) .LE. 0.0) THEN
              PRINT *, 'EVANESCENT REGION'
              GO TO 40
            END IF

            MU = SQRT(REAL(N2)/(R(4)**2+R(5)**2+R(6)**2))
            DO NN=4,6
              R(NN) = R(NN)*MU
            END DO
            DO NN=7,N
              R(NN) = 0.0
            END DO

            CALL TRACE
 40       CONTINUE
          IF (PLT .NE. 0.0) CALL ENDPLT
 45     CONTINUE
 50   CONTINUE

      GO TO 10
      END
