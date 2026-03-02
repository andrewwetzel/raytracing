      SUBROUTINE AHWFNC
C     CALCULATES THE REFRACTIVE INDEX AND ITS GRADIENT USING THE
C     APPLETON-HARTREE FORMULA WITH FIELD, NO COLLISIONS
      COMMON /CONST/ PI,PIT2,PID2,DEGS,RADIAN,K,C,LOGTEN
      COMMON /RIN/ MODRIN(3),COLL,FIELD,SPACE,KAY2,KAY2I,
     1 H,HI,PHPT,PHPTI,PHPR,PHPRI,PHPTH,PHPTHI,PHPPH,PHPPHI,
     2 PHPOM,PHPOMI,PHPKR,PHPKRI,PHPKTH,PHPKTI,PHPKPH,PHPKPI,
     3 KPHPK,KPHPKI,POLAR,POLARI,LPOLAR,LPOLRI,SGN
      COMMON /XX/ MODX(2),X,PXPR,PXPTH,PXPPH,PXPT,HMAX
      COMMON /YY/ MODY,Y,PYPR,PYPTH,PYPPH,YR,PYRPR,PYRPT,PYRPP,
     1 YTH,PYTPR,PYTPT,PYTPP,YPH,PYPPR,PYPPT,PYPPP
      COMMON /ZZ/ MODZ,Z,PZPR,PZPTH,PZPPH
      COMMON /RK/ N,STEP,MODE,E1MAX,E1MIN,E2MAX,E2MIN,FACT,RSTART
      COMMON R(6) /WW/ ID(10),WQ,W(400)
      
      EQUIVALENCE (RAY,W(1)), (F,W(6))
      LOGICAL SPACE
      CHARACTER*6 MODX, MODY, MODZ
      CHARACTER*8 MODRIN
      REAL KR,KTH,KPH,K2,KPHPK,KPHPKI,KAY2,KAY2I,N2,NNP,LPOLAR,LPOLRI
      REAL I
      
      DATA MODRIN /'APPLETON', '-HARTREE', ' FORMULA'/
      DATA COLL /0.0/, FIELD /1.0/, U /1.0/

      ENTRY RINDEX
      
      KAY2I = 0.0
      HI = 0.0
      PHPTI = 0.0
      PHPRI = 0.0
      PHPTHI = 0.0
      PHPPHI = 0.0
      PHPOMI = 0.0
      PHPKRI = 0.0
      PHPKTI = 0.0
      PHPKPI = 0.0
      KPHPKI = 0.0
      POLARI = 0.0
      LPOLRI = 0.0

      KR = R(4)
      KTH = R(5)
      KPH = R(6)

      OM = PIT2 * F * 1.0E6
      C2 = C * C
      K2 = KR*KR + KTH*KTH + KPH*KPH
      OM2 = OM * OM
      VR = C/OM * KR
      VTH = C/OM * KTH
      VPH = C/OM * KPH

      CALL ELECTX
      CALL MAGY
      
      V2 = VR**2 + VTH**2 + VPH**2
      VDOTY = VR*YR + VTH*YTH + VPH*YPH
      
      YLV = 0.0
      YL2 = 0.0
      IF (V2 .NE. 0.0) THEN
         YLV = VDOTY / V2
         YL2 = VDOTY**2 / V2
      END IF
      
      YT2 = Y**2 - YL2
      YT4 = YT2 * YT2

      UX = U - X
      UX2 = UX * UX
      RAD = RAY * SQRT(YT4 + 4.0*YL2*UX2)
      D = 2.0*UX - YT2 + RAD
      D2 = D * D
      N2 = 1.0 - 2.0*X*UX / D

      IF (RAD .NE. 0.0) THEN
         PNPPS = 2.0*X*UX*(-1.0 + (YT2 - 2.0*UX2)/RAD) / D2
         PNPX = -(2.0*UX2 - YT2*(U-2.0*X) + 
     1          (YT4*(U-2.0*X) + 4.0*YL2*UX*UX2)/RAD) / D2
         PNPY = 0.0
         IF (Y .NE. 0.0) THEN
            PNPY = 2.0*X*UX*(-YT2 + (YT4 + 2.0*YL2*UX2)/RAD) / (D2*Y)
         END IF
      ELSE
         PNPPS = -2.0*X*UX / D2
         PNPX = -2.0*UX2 / D2
         PNPY = 0.0
      END IF

      NNP = N2 - (2.0*X*PNPX + Y*PNPY)

      PNPR = PNPX*PXPR + PNPY*PYPR + PNPPS*PPSPR
      PNPTH = PNPX*PXPTH + PNPY*PYPTH + PNPPS*PPSPTH
      PNPPH = PNPX*PXPPH + PNPY*PYPPH + PNPPS*PPSPPH

      PNPVR = 0.0
      PNPVTH= 0.0
      PNPVPH= 0.0
      IF (V2 .NE. 0.0) THEN
        PNPVR = PNPPS*(VR*YL2 - VDOTY*YR)/V2
        PNPVTH= PNPPS*(VTH*YL2 - VDOTY*YTH)/V2
        PNPVPH= PNPPS*(VPH*YL2 - VDOTY*YPH)/V2
      END IF

      PNPT = PNPX * PXPT

      SPACE = N2 .EQ. 1.0
      
      POLAR = 0.0
      LPOLAR= 0.0
      GAM = 0.0
      IF (VDOTY .NE. 0.0 .AND. UX .NE. 0.0) THEN
         POLARI = SQRT(V2)*(YT2 - RAD) / (2.0*VDOTY*UX)
         GAM = (-YT2 + RAD) / (2.0*UX)
         IF ((U+GAM) .NE. 0.0) THEN
           LPOLRI = X*SQRT(YT2) / (UX*(U+GAM))
         END IF
      END IF

      KAY2 = OM2 / C2 * N2
      IF (RSTART .EQ. 0.0) GO TO 1
      SCALE = SQRT(KAY2 / K2)
      KR = SCALE * KR
      KTH = SCALE * KTH
      KPH = SCALE * KPH
 1    CONTINUE

C     CALCULATES A HAMILTONIAN H
      H = 0.5 * (C2*K2/OM2 - N2)

C     AND ITS PARTIAL DERIVATIVES WITH RESPECT TO
C     TIME, R, THETA, PHI, OMEGA, KR, KTHETA, AND KPHI.
      PHPT = -PNPT
      PHPR = -PNPR
      PHPTH = -PNPTH
      PHPPH = -PNPPH
      PHPOM = -NNP / OM
      PHPKR = C2/OM2*KR - C/OM*PNPVR
      PHPKTH = C2/OM2*KTH - C/OM*PNPVTH
      PHPKPH = C2/OM2*KPH - C/OM*PNPVPH

      KPHPK = N2

      R(4) = KR
      R(5) = KTH
      R(6) = KPH

      RETURN
      END
