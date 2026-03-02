      SUBROUTINE HARMONY
C     MODEL OF THE EARTH'S MAGNETIC FIELD BASED ON A HARMONIC ANALYSIS
      DIMENSION PHPTH(7,7), PGPTH(7,7), A1(7,7), B1(7,7)
      DIMENSION H(7,7), G(7,7), GG(7,7), HH(7,7), SINP(7), COSP(7)
      COMMON /YY/ MODY, Y, PYPR, PYPTH, PYPPH, YR, PYRPR, PYRPT, PYRPP,
     1 YTH, PYTPR, PYTPT, PYTPP, YPH, PYPPR, PYPPT, PYPPP
      COMMON R(6) /WW/ ID(10), WQ, W(400)
      COMMON /CONST/ PI, PIT2, PID2, DUM(5)
      EQUIVALENCE (THETA, R(2)), (PHI, R(3))
      EQUIVALENCE (EARTHR, W(2)), (F, W(6)), (READFH, W(200))
      
      REAL MODY
      REAL EOM, SET
      
C     RATIO OF CHARGE TO MASS FOR ELECTRON
      DATA EOM /1.7589E7/
      DATA SET /0.0/, H /1.0, 48*0.0/, G /49*0.0/
      DATA PGPTH /49*0.0/, PHPTH /49*0.0/, MODY /6HHARMON/

      ENTRY MAGY
      IF (SET .NE. 0.0) GO TO 2
      DO 1 M=1,7
        DO 1 N=1,7
          B1(M,N) = FLOAT(N+M-1)*FLOAT(N-M+1)/FLOAT(2*N-1)
          A1(M,N) = B1(M,N)/FLOAT(2*N+1)
 1    CONTINUE
      SET = 1.0

 2    IF (READFH .EQ. 0.0) GO TO 3
      READ 2000, GG, HH
 2000 FORMAT (1X, F9.4, 6F10.4)
      PRINT 2100, GG
 2100 FORMAT (1H1,10X,1H0,14X,1H1,14X,1H2,14X,1H3,14X,1H4,14X,1H5,14X,
     1 1H6 / 9X,7(1HG,14X) / 10X,7(1HN,14X) // (1X,7F15.6))
      PRINT 2200, HH
 2200 FORMAT (// 11X,1H0,14X,1H1,14X,1H2,14X,1H3,14X,1H4,14X,1H5,14X,
     1 1H6 / 9X,7(1HH,14X) / 10X,7(1HN,14X) // (1X,7F15.6))
 3    READFH = 0.0

      COSTHE = COS(THETA)
      SINTHE = SIN(THETA)
      
C     Prevent division by zero if exactly at the poles
      IF (ABS(SINTHE) .LT. 1.0E-10) SINTHE = SIGN(1.0E-10, SINTHE)

      AOR = EARTHR / R(1)
      PAORPR = -AOR / R(1)
      CNST2 = AOR
      PCNSPR = PAORPR

      FIN1 = 0.0
      PFIN1R = 0.0
      PFIN1T = 0.0
      PFIN1P = 0.0
      FIN2 = 0.0
      PFIN2R = 0.0
      PFIN2T = 0.0
      PFIN2P = 0.0
      FIN3 = 0.0
      PFIN3R = 0.0
      PFIN3T = 0.0
      PFIN3P = 0.0

      DO 4 M=1,7
        SINP(M) = SIN(FLOAT(M-1)*PHI)
        COSP(M) = COS(FLOAT(M-1)*PHI)
 4    CONTINUE

      H(1,2) = COSTHE
      H(2,2) = SINTHE
      DO 5 M=1,5
        H(M+1,M+2) = COSTHE * H(M+1,M+1)
        H(M+2,M+2) = SINTHE * H(M+1,M+1)
        DO 5 N=M,5
          H(M,N+2) = COSTHE * H(M,N+1) - A1(M,N) * H(M,N)
 5    CONTINUE

      DO 6 M=1,6
        G(M+1,M+1) = -FLOAT(M) * COSTHE * H(M+1,M+1)
        PHPTH(M+1,M+1) = -G(M+1,M+1) / SINTHE
        PGPTH(M+1,M+1) = FLOAT(M) * SINTHE * H(M+1,M+1) - 
     1                   FLOAT(M) * COSTHE * PHPTH(M+1,M+1)
        DO 6 N=M,6
          G(M,N+1) = -FLOAT(N) * COSTHE * H(M,N+1) + B1(M,N) * H(M,N)
          PHPTH(M,N+1) = -G(M,N+1) / SINTHE
          PGPTH(M,N+1) = FLOAT(N) * SINTHE * H(M,N+1) - 
     1      FLOAT(N) * COSTHE * PHPTH(M,N+1) + B1(M,N) * PHPTH(M,N)
 6    CONTINUE

      DO 8 N=1,7
        CR = 0.0
        PCRPTH = 0.0
        PCRPPH = 0.0
        CTH = 0.0
        PCTHPT = 0.0
        PCTHPP = 0.0
        CPH = 0.0
        PCPHPT = 0.0
        PCPHPP = 0.0

        DO 7 M=1,N
          TEMP1 = GG(M,N)*COSP(M) + HH(M,N)*SINP(M)
          TEMP2 = FLOAT(M-1)*(HH(M,N)*COSP(M) - GG(M,N)*SINP(M))
          
          CR = CR + H(M,N)*TEMP1
          PCRPTH = PCRPTH + PHPTH(M,N)*TEMP1
          PCRPPH = PCRPPH + H(M,N)*TEMP2
          
          CTH = CTH + G(M,N)*TEMP1
          PCTHPT = PCTHPT + PGPTH(M,N)*TEMP1
          PCTHPP = PCTHPP + G(M,N)*TEMP2
          
          CPH = CPH + H(M,N)*TEMP2
          PCPHPT = PCPHPT + PHPTH(M,N)*TEMP2
          PCPHPP = PCPHPP - H(M,N)*FLOAT((M-1)**2)*TEMP1
 7      CONTINUE

        CNST2 = CNST2 * AOR
        PCNSPR = CNST2 * PAORPR + AOR * PCNSPR
        
        FIN1 = FIN1 + FLOAT(N) * CNST2 * CR
        PFIN1R = PFIN1R + FLOAT(N) * PCNSPR * CR
        PFIN1T = PFIN1T + FLOAT(N) * CNST2 * PCRPTH
        PFIN1P = PFIN1P + FLOAT(N) * CNST2 * PCRPPH
        
        FIN2 = FIN2 + CNST2 * CTH
        PFIN2R = PFIN2R + PCNSPR * CTH
        PFIN2T = PFIN2T + CNST2 * PCTHPT
        PFIN2P = PFIN2P + CNST2 * PCTHPP
        
        FIN3 = FIN3 + CNST2 * CPH
        PFIN3R = PFIN3R + PCNSPR * CPH
        PFIN3T = PFIN3T + CNST2 * PCPHPT
        PFIN3P = PFIN3P + CNST2 * PCPHPP
 8    CONTINUE

      HTHETA = -FIN2 / SINTHE
      HPHI = FIN3 / SINTHE
      
      CONST = -EOM / PIT2 * 1.0E-6 / F
      YR = -CONST * FIN1
      YTH = CONST * HTHETA
      YPH = CONST * HPHI
      
      Y = SQRT(YR**2 + YTH**2 + YPH**2)
      IF (Y .LT. 1.0E-10) Y = 1.0E-10
      
      PYRPR = -CONST * PFIN1R
      PYTPR = -CONST * PFIN2R / SINTHE
      PYPPR = CONST * PFIN3R / SINTHE
      PYPR = (YR*PYRPR + YTH*PYTPR + YPH*PYPPR) / Y
      
      PYRPT = -CONST * PFIN1T
      PYTPT = -CONST * (PFIN2T/SINTHE + HTHETA*COSTHE/SINTHE)
      PYPPT = CONST * (PFIN3T/SINTHE - HPHI*COSTHE/SINTHE)
      PYPTH = (YR*PYRPT + YTH*PYTPT + YPH*PYPPT) / Y
      
      PYRPP = -CONST * PFIN1P
      PYTPP = -CONST * PFIN2P / SINTHE
      PYPPP = CONST * PFIN3P / SINTHE
      PYPPH = (YR*PYRPP + YTH*PYTPP + YPH*PYPPP) / Y

      RETURN
      END
