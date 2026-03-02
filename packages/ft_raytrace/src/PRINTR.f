      SUBROUTINE PRINTR(NWHY, CARD)
C     PRINTS OUTPUT AND PUNCHES RAYSETS WHEN REQUESTED
      DIMENSION G(3,3),G1(3,3),RPRINT(20),NPR(20)
      CHARACTER*8 TYPE(3),HEAD1(20),HEAD2(20),UNITS(20)
      CHARACTER*8 HEAD01(20),HEAD02(20),UNIT(20)
      COMMON /CONST/ PI,PIT2,PID2,DEGS,RAD,DUM(3)
      COMMON /FLG/ NTYP,NEWWR,NEWWP,PENET,LINES,IHOP,HPUNCH
      COMMON /RIN/ MODRIN(3),COLL,FIELD,SPACE,N2,N2I,PNP(10),
     1 POLAR(2),LPOLAR(2)
      COMMON R(20),T
      COMMON /WW/ ID(10),WQ,W(400)
      
      EQUIVALENCE (THETA,R(2)), (PHI,R(3))
      EQUIVALENCE (EARTHR,W(2)), (XMTRH,W(3)), (TLAT,W(4)),
     1 (TLON,W(5)), (F,W(6)), (AZ1,W(10)), (BETA,W(14)),
     2 (RCVRH,W(20)), (HOP,W(22)), (PLAT,W(24)), (PLON,W(25)),
     3 (RAYSET,W(72))
      
      LOGICAL SPACE,NEWWR,NEWWP,PENET
      REAL N2,N2I,LPOLAR
      COMPLEX PHP
      CHARACTER*8 NWHY
      
      SAVE G, G1, XR, YR, ZR, CTHR, STHR, PHIR, ALPH, NR, NP, NP1
      SAVE HEAD01, HEAD02, UNIT, NPR
      
      DATA TYPE /'X       ','N       ','O       '/
      DATA HEAD01(7) /'  PHASE '/
      DATA HEAD02(7) /'E  PATH '/
      DATA UNIT(7)   /' KM     '/
      DATA HEAD01(8) /' ABSO   '/
      DATA HEAD02(8) /'RPTION  '/
      DATA UNIT(8)   /' DB     '/
      DATA HEAD01(9) /' DOP    '/
      DATA HEAD02(9) /'PLER    '/
      DATA UNIT(9)   /' C/S    '/
      DATA HEAD01(10)/' PATH   '/
      DATA HEAD02(10)/'LENGTH  '/
      DATA UNIT(10)  /' KM     '/
      
      CALL RINDEX
      IF (.NOT. NEWWP) GO TO 10

C     NEW W ARRAY -- REINITIALIZE
      NEWWP = .FALSE.
      SPL = SIN(PLON - TLON)
      CPL = COS(PLON - TLON)
      SP = SIN(PLAT)
      CP = COS(PLAT)
      SL = SIN(TLAT)
      CL = COS(TLAT)

C     MATRIX TO ROTATE COORDINATES
      G(1,1) = CPL*SP*CL - CP*SL
      G(1,2) = SPL*SP
      G(1,3) = -SL*SP*CPL - CL*CP
      G(2,1) = -SPL*CL
      G(2,2) = CPL
      G(2,3) = SL*SPL
      G(3,1) = CL*CP*CPL + SP*SL
      G(3,2) = CP*SPL
      G(3,3) = -SL*CP*CPL + SP*CL

      DENH = G(1,1)*G(2,2)*G(3,3) + G(1,2)*G(3,1)*G(2,3)
     1     + G(2,1)*G(3,2)*G(1,3) - G(2,2)*G(3,1)*G(1,3)
     2     - G(1,2)*G(2,1)*G(3,3) - G(1,1)*G(3,2)*G(2,3)

C     THE MATRIX G1 IS THE INVERSE OF THE MATRIX G
      G1(1,1) = (G(2,2)*G(3,3) - G(3,2)*G(2,3)) / DENH
      G1(1,2) = (G(3,2)*G(1,3) - G(1,2)*G(3,3)) / DENH
      G1(1,3) = (G(1,2)*G(2,3) - G(2,2)*G(1,3)) / DENH
      G1(2,1) = (G(3,1)*G(2,3) - G(2,1)*G(3,3)) / DENH
      G1(2,2) = (G(1,1)*G(3,3) - G(3,1)*G(1,3)) / DENH
      G1(2,3) = (G(2,1)*G(1,3) - G(1,1)*G(2,3)) / DENH
      G1(3,1) = (G(2,1)*G(3,2) - G(3,1)*G(2,2)) / DENH
      G1(3,2) = (G(3,1)*G(1,2) - G(1,1)*G(3,2)) / DENH
      G1(3,3) = (G(1,1)*G(2,2) - G(2,1)*G(1,2)) / DENH

      RO = EARTHR + XMTRH
C     CARTESIAN COORDINATES OF TRANSMITTER
      XR = RO*G(1,1)
      YR = RO*G(2,1)
      ZR = RO*G(3,1)
      CTHR = G(3,1)
      STHR = SIN(ACOS(CTHR))
      PHIR = ATAN2(YR, XR)
      ALPH = ATAN2(G(3,2), G(3,3))

      NR = 6
      NP = 0
      DO 7 NN=7,20
        IF (W(NN+50) .EQ. 0.0) GO TO 7
        NR = NR + 1
        IF (W(NN+50) .NE. 2.0) GO TO 7
        NP = NP + 1
        NPR(NP) = NR
        HEAD01(NP) = HEAD01(NN)
        HEAD02(NP) = HEAD02(NN)
        UNIT(NP) = UNITS(NN)
 7    CONTINUE
      NP1 = MIN0(NP, 3)

C     PRINT COLUMN HEADINGS AT THE BEGINNING OF EACH RAY
 10   IF (IHOP .NE. 0) GO TO 12

      IF (RAYSET .NE. 0.0) THEN
C       PUNCH A TRANSMITTER RAYSET
        TLOND = TLON*DEGS
        IF (TLOND .LT. 0.0) TLOND = TLOND + 360.0
        TLATD = TLAT*DEGS
        IF (TLATD .LT. 0.0) TLATD = TLATD + 360.0
        AZ = AZ1*DEGS
        EL = BETA*DEGS
        NHOP = HOP
      END IF

 12   V = 0.0
      IF (N2 .NE. 0.0) V = (R(4)**2+R(5)**2+R(6)**2)/N2 - 1.0
      H = R(1) - EARTHR
      STH = SIN(THETA)
      CTH = COS(THETA)

C     CARTESIAN COORDINATES OF RAY POINT, ORIGIN AT TRANSMITTER
      XP = R(1)*STH*COS(PHI) - XR
      YP = R(1)*STH*SIN(PHI) - YR
      ZP = R(1)*CTH - ZR

C     ROTATED COORDINATES
      EPS = XP*G1(1,1) + YP*G1(1,2) + ZP*G1(1,3)
      ETA = XP*G1(2,1) + YP*G1(2,2) + ZP*G1(2,3)
      ZETA= XP*G1(3,1) + YP*G1(3,2) + ZP*G1(3,3)
      RCE2 = ETA**2 + ZETA**2
      RCE = SQRT(RCE2)

C     GROUND RANGE
      RANGE = EARTHR * ATAN2(RCE, EARTHR+EPS)

C     ANGLE OF WAVE NORMAL WITH LOCAL HORIZONTAL
      ELL = ATAN2(R(4), SQRT(R(5)**2 + R(6)**2)) * DEGS

C     STRAIGHT LINE DISTANCE FROM TRANSMITTER TO RAY POINT
      SR = SQRT(RCE2 + EPS**2)

      IF (NP .GE. 1) THEN
        DO I=1,NP
          NN = NPR(I)
          RPRINT(I) = R(NN)
        END DO
      END IF

      IF (SR .LE. 1.0E-6) THEN
C       TOO CLOSE TO TRANSMITTER
        PRINT *, V, NWHY, H, RANGE, ELL, POLAR(1), T
        GO TO 40
      END IF

      IF (RCE .LT. 1.0E-6) THEN
C       NEARLY DIRECTLY ABOVE OR BELOW TRANSMITTER
        EL_ANG = ATAN2(EPS, RCE) * DEGS
        PRINT *, V, NWHY, H, RANGE, EL_ANG, ELL, POLAR(1), T
        GO TO 40
      END IF

C     AZIMUTH ANGLE OF RAY POINT FROM TRANSMITTER
      ANGA = ATAN2(ETA, ZETA)
      AZDEV = 180.0 - AMOD(540.0 - (AZ1-ANGA)*DEGS, 360.0)
      
      IF (R(5) .EQ. 0.0 .AND. R(6) .EQ. 0.0) THEN
C       WAVE NORMAL IS VERTICAL, AZIMUTH DIRECTION CANNOT BE CALCULATED
        PRINT *, V, NWHY, H, RANGE, AZDEV, ELL, POLAR(1), T
        GO TO 40
      END IF

      ANA = ANGA - ALPH
      SANA = SIN(ANA)
      SPHI = SANA*STHR/STH
      CPHI = -COS(ANA)*COS(PHI-PHIR) + SANA*SIN(PHI-PHIR)*CTHR
      AZA = 180.0 - AMOD(540.0 - (ATAN2(SPHI,CPHI) - 
     1       ATAN2(R(6),R(5))) * DEGS, 360.0)
      
      PRINT *, V, NWHY, H, RANGE, AZDEV, AZA, ELL, POLAR(1), T

 40   LINES = LINES + 1
      IF (CARD .EQ. 0.0) RETURN

C     PUNCH A RAYSET
      AZDEV_O = AZDEV
      AZA_O = AZA
      IF (AZDEV .LT. -90.0) AZDEV_O = AZDEV + 360.0
      IF (AZA .LT. -90.0) AZA_O = AZA + 360.0
      TDEV = T - SR
      
      RETURN
      END
