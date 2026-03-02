      SUBROUTINE BQWFWC
C     CALCULATES A HAMILTONIAN H = BOOKER QUARTIC FOR VERTICAL INCIDENCE
C     AND ITS PARTIAL DERIVATIVES WITH RESPECT TO TIME, R,
C     THETA, PHI, OMEGA, KR, KTHETA, AND KPHI.
C     WITH FIELD, WITH COLLISIONS
      COMMON /CONST/ PI,PIT2,PID2,DEGS,RADIAN,K,C,LOGTEN
      COMMON /RIN/ MODRIN(3),COLL,FIELD,SPACE,KAY2,H,PHPT,PHPR,PHPTH,
     1 PHPPH,PHPOM,PHPKR,PHPKTH,PHPKPH,KPHPK,POLAR,LPOLAR,
     2 SGN
      COMMON /XX/ MODX(2),X,PXPR,PXPTH,PXPPH,PXPT,HMAX
      COMMON /YY/ MODY,Y,PYPR,PYPTH,PYPPH,YR,PYRPR,PYRPT,PYRPP,YTH,
     1 PYTPR,PYTPT,PYTPP,YPH,PYPPR,PYPPT,PYPPP
      COMMON /ZZ/ MODZ,Z,PZPR,PZPTH,PZPPH
      COMMON R(6) /WW/ ID(10),WQ,W(400)
      COMMON /RK/ N,STEP,MODE,E1MAX,E1MIN,E2MAX,E2MIN,FACT,RSTART
      COMMON /FLG/ NTYP,NEWWR,NEWWP,PENET,LINES,IHOP,HPUNCH
      EQUIVALENCE (RAY,W(1)), (F,W(6))
      
      LOGICAL SPACE
      CHARACTER*6 MODX, MODY, MODZ
      CHARACTER*8 MODRIN
      REAL KR,KTH,KPH,K2,KDOTY,C4,KDOTY2
      COMPLEX KAY2,H,PHPT,PHPR,PHPTH,PHPPH,PHPOM,PHPKR,PHPKTH,PHPKPH,
     1 POLAR,LPOLAR,I,U,RAD,D,PNPPS,PNPX,PNPY,PNPZ,UX,UX2,D2,
     2 KPHPK,U2,A,B,ALPHA,BETA,GAMMA,PHPX,PHPY2,PHPKY2,PHPU,PHPZ,
     3 N2,PNPR,PNPTH,PNPPH,PNPVR,PNPVTH,PNPVPH,NNP,PNPT,PHPK2
      
      DATA MODRIN /'BOOKER Q', 'UARTIC  ', '        '/
      DATA COLL /1.0/, FIELD /1.0/, SGN /1.0/, I /(0.0, 1.0)/
      DATA ABSLIM /1.0E-5/

      ENTRY RINDEX
      OM = PIT2 * F * 1.0E6
      C2 = C * C
      KR = R(4)
      KTH = R(5)
      KPH = R(6)
      K2 = KR*KR + KTH*KTH + KPH*KPH
      OM2 = OM * OM

      CALL ELECTX
      
      IF (X .LT. 1.0E-4) GO TO 2

      K4 = K2 * K2
      OM4 = OM2 * OM2
      C4 = C2 * C2

      CALL MAGY
      Y2 = Y * Y
      KDOTY = KR*YR + KTH*YTH + KPH*YPH
      KDOTY2 = KDOTY * KDOTY
      
      CALL COLFRZ
      
      U = CMPLX(1.0, -Z)
      U2 = U * U
      UX = U - X
      UX2 = UX * UX
      
      A = UX*U2 - U*Y2
      B = -2.0*U*UX2 + Y2*(2.0*U - X)
      
      ALPHA = A*C4*K4 + X*KDOTY2*C4*K2
      BETA = B*C2*OM2*K2 - X*KDOTY2*C2*OM2
      GAMMA = (UX2 - Y2)*UX*OM4

      H = ALPHA + BETA + GAMMA
      
      PHPX = -U2*C4*K4 + KDOTY2*C4*K2 + (4.0*U*UX - Y2)*C2*OM2*K2 
     1       - KDOTY2*C2*OM2 + (-3.0*UX2 + Y2)*OM4
     
      PHPY2 = -U*C4*K4 + (2.0*U - X)*C2*OM2*K2 - UX*OM4
      
      PHPKY2 = X*C2*(C2*K2 - OM2)
      
      PHPU = (2.0*U*UX + U2 - Y2)*C4*K4 + 2.0*(Y2 - UX2 - 2.0*U*UX)*
     1       C2*K2*OM2 + (3.0*UX2 - Y2)*OM4
     
      PHPZ = -I * PHPU
      
      PHPK2 = 2.0*A*C4*K2 + X*KDOTY2*C4 + B*C2*OM2

      PHPT = PHPX * PXPT
      
      PHPR = PHPX*PXPR + PHPY2*2.0*Y*PYPR + PHPKY2*2.0*KDOTY*
     1       (KR*PYRPR + KTH*PYTPR + KPH*PYPPR) + PHPZ*PZPR
     
      PHPTH = PHPX*PXPTH + PHPY2*2.0*Y*PYPTH + PHPKY2*2.0*KDOTY*
     1       (KR*PYRPT + KTH*PYTPT + KPH*PYPPT) + PHPZ*PZPTH
     
      PHPPH = PHPX*PXPPH + PHPY2*2.0*Y*PYPPH + PHPKY2*2.0*KDOTY*
     1       (KR*PYRPP + KTH*PYTPP + KPH*PYPPP) + PHPZ*PZPPH

      PHPOM = (2.0*BETA + 4.0*GAMMA)/OM - 2.0*PHPX*X/OM - 
     1        2.0*PHPY2*Y2/OM - 2.0*PHPKY2*KDOTY2/OM - PHPZ*Z/OM
     
      PHPKR = 2.0*PHPK2*KR + 2.0*KDOTY*PHPKY2*YR
      PHPKTH = 2.0*PHPK2*KTH + 2.0*KDOTY*PHPKY2*YTH
      PHPKPH = 2.0*PHPK2*KPH + 2.0*KDOTY*PHPKY2*YPH

      IF (ALPHA .NE. CMPLX(0.0, 0.0)) THEN
         KAY2 = K2 * (-BETA + SGN*RAY*CSQRT(BETA**2 - 4.0*ALPHA*GAMMA))
     1          / (2.0*ALPHA)
      ELSE
         KAY2 = K2
      END IF

      IF (RSTART .EQ. 0.0) GO TO 1
      
      IF (REAL(ALPHA) .NE. 0.0) THEN
         SCALE = SQRT(REAL((-REAL(BETA) + SGN*RAY*SQRT(REAL(BETA)**2 - 
     1           4.0*REAL(ALPHA)*REAL(GAMMA))) / (2.0*REAL(ALPHA))))
         KR = SCALE * KR
         KTH = SCALE * KTH
         KPH = SCALE * KPH
      END IF

 1    CONTINUE
      
      IF (CABS((BETA - SGN*RAY*CSQRT(BETA**2 - 4.0*ALPHA*GAMMA)) 
     1     / ALPHA - 2.0)
     2   .LT. CABS((BETA + SGN*RAY*CSQRT(BETA**2 - 4.0*ALPHA*GAMMA)) 
     3     / ALPHA - 2.0)
     4   .AND. RSTART .EQ. 0.0) SGN = -SGN

      KPHPK = 4.0*ALPHA + 2.0*BETA
      
      SPACE = CABS(C2*KAY2/OM2 - CMPLX(1.0,0.0)) .LT. ABSLIM
      
      POLAR = CMPLX(0.0, 0.0)
      LPOLAR = CMPLX(0.0, 0.0)
      IF (KDOTY .NE. 0.0 .AND. UX .NE. CMPLX(0.0,0.0)) THEN
         POLAR = CMPLX(SQRT(K2),0.0)*(U + X*OM2/(C2*KAY2 - OM2))/KDOTY
         LPOLAR= SQRT(K2 - KDOTY2/K2) / (UX*(1.0 - C2*KAY2/OM2))
      END IF
      
      R(4) = KR
      R(5) = KTH
      R(6) = KPH

      RETURN

 2    CONTINUE
C     FALLBACK TO APPLETON-HARTREE FORMULA FOR VERY LOW DENSITIES
      VR = C/OM*KR
      VTH= C/OM*KTH
      VPH= C/OM*KPH
      
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
      
      CALL COLFRZ
      
      U = CMPLX(1.0, -Z)
      UX = U - X
      UX2 = UX * UX
      RAD = SGN * RAY * CSQRT(YT4 + 4.0*YL2*UX2)
      D = 2.0*U*UX - YT2 + RAD
      D2 = D * D
      N2 = 1.0 - 2.0*X*UX / D

      IF (RAD .NE. CMPLX(0.0, 0.0)) THEN
         PNPPS = 2.0*X*UX*(-1.0 + (YT2 - 2.0*UX2)/RAD)/D2
         PPSPR = 0.0
         PPSPTH = 0.0
         PPSPPH = 0.0
         IF (Y .NE. 0.0) THEN
            PPSPR = YL2/Y*PYPR - (VR*PYRPR+VTH*PYTPR+VPH*PYPPR)*YLV
            PPSPTH = YL2/Y*PYPTH - (VR*PYRPT+VTH*PYTPT+VPH*PYPPT)*YLV
            PPSPPH = YL2/Y*PYPPH - (VR*PYRPP+VTH*PYTPP+VPH*PYPPP)*YLV
         END IF
         PNPX = -(2.0*U*UX2 - YT2*(U-2.0*X) + 
     1          (YT4*(U-2.0*X) + 4.0*YL2*UX*UX2)/RAD)/D2
         PNPY = 0.0
         IF (Y .NE. 0.0) THEN
            PNPY = 2.0*X*UX*(-YT2 + (YT4 + 2.0*YL2*UX2)/RAD)/(D2*Y)
         END IF
         PNPZ = I*X*(-2.0*UX2 - YT2 + YT4/RAD)/D2
      ELSE
         PNPPS = -2.0*X*UX / D2
         PPSPR = 0.0
         PPSPTH= 0.0
         PPSPPH= 0.0
         PNPX = -2.0*U*UX2 / D2
         PNPY = 0.0
         PNPZ = I*X*(-2.0*UX2) / D2
      END IF
      
      PNPR = PNPX*PXPR + PNPY*PYPR + PNPZ*PZPR + PNPPS*PPSPR
      PNPTH = PNPX*PXPTH + PNPY*PYPTH + PNPZ*PZPTH + PNPPS*PPSPTH
      PNPPH = PNPX*PXPPH + PNPY*PYPPH + PNPZ*PZPPH + PNPPS*PPSPPH
      
      PNPVR = 0.0
      PNPVTH= 0.0
      PNPVPH= 0.0
      IF (V2 .NE. 0.0) THEN
         PNPVR = PNPPS*(VR*YL2 - VDOTY*YR)/V2
         PNPVTH= PNPPS*(VTH*YL2 - VDOTY*YTH)/V2
         PNPVPH= PNPPS*(VPH*YL2 - VDOTY*YPH)/V2
      END IF

      NNP = N2 - (2.0*X*PNPX + Y*PNPY + Z*PNPZ)
      PNPT = PNPX * PXPT
      
      SPACE = REAL(N2) .EQ. 1.0 .AND. ABS(AIMAG(N2)) .LT. ABSLIM
      
      POLAR = CMPLX(0.0, 0.0)
      LPOLAR = CMPLX(0.0, 0.0)
      
      H = 0.5 * (C2*K2/OM2 - N2)
      PHPT = -PNPT
      PHPR = -PNPR
      PHPTH= -PNPTH
      PHPPH= -PNPPH
      PHPOM= -NNP / OM
      PHPKR= C2/OM2*KR - C/OM*PNPVR
      PHPKTH=C2/OM2*KTH - C/OM*PNPVTH
      PHPKPH=C2/OM2*KPH - C/OM*PNPVPH
      KPHPK = N2
      
      RETURN
      END
