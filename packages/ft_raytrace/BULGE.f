        SUBROUTINE BULGE
C
C     ANALYTICAL MODEL OF THE VARIATION OF THE EQUATORIAL F2 LAYER
C     IN GEOMAGNETIC LATITUDE (EQUATORIAL BULGE AND ANOMALY)
C     SEE FIGURE 3.18B, PAGE 133 IN DAVIES (1965).
C     THIS MODEL HAS NO VARIATION IN GEOMAGNETIC LONGITUDE.
C
C     Common blocks for sharing data
      COMMON /CONST/ PI,PIT2,PID2,DUM
      COMMON /XX/ MODX,X,PXPR,PXPTH,PXPPH,PXPT,HMAX
      COMMON /WW/ ID(10),WQ,W(400)
C
C     Blank common. We assume R(1)=radius, R(2)=co-latitude
      COMMON R
C
C     Declare types for /XX/ block
      CHARACTER*6 MODX(2)
      REAL X, PXPR, PXPTH, PXPPH, PXPT, HMAX
C
C     Declare types for /CONST/ block
      REAL PI,PIT2,PID2,DUM(5)
C
C     Declare types for Blank Common
      REAL R(3)
C
C     Equivalence variables to their locations in the W array
      EQUIVALENCE (EARTHR,W(2)),(F,W(61)),(PERT,W(151))
C
C     Declare local variable types
      REAL H, EARTHR, F, PERT
      REAL PHMPTH, PFC2PTH, HMAX_CALC, FC2
      REAL BULLAT, ANMLAT, POW
      REAL ALPHA, Z100, SH, Z, EXZ
      INTEGER I
C
C     Set model name. This is an executable statement.
      MODX(1) = ' BULGE'
C
C     ENTRY point for electron density calculation
      ENTRY ELECTX
C
C     Calculate height from radius in R(1)
      H = R(1) - EARTHR
C
C     Initialize local variables and default model parameters
      PHMPTH = 0.
      PXPTH = 0.
      PFC2PTH = 0.
      HMAX_CALC = 350.
      FC2 = 225.
C
C     If height is below 100km, skip bulge/anomaly calcs
      IF(H.LT.100.) GOTO 2
C
C     EQUATORIAL BULGE (HMAX calculation)
      BULLAT = 7.5*(PID2 - R(2))
C
C     Skip HMAX calc if latitude is too high
      IF(ABS(BULLAT).GE.PI) GOTO 1
C
      HMAX_CALC = 430. + 80.*COS(BULLAT)
      PHMPTH = 600.*SIN(BULLAT)
C
C     EQUATORIAL ANOMALY (FC2 calculation)
    1 CONTINUE
      ANMLAT = 22.5*(PID2 - R(2))/PI
      POW = 2. - ABS(ANMLAT)
      FC2 = 50.*ANMLAT**2*EXP(POW) + 40.
      PFC2PTH = -1125./PI*POW*ANMLAT*EXP(POW)
C
C     FORCING PLASMA FREQ AT 100 KM TO BE 2 MHZ IN ORDER TO CALCULATE SH
    2 CONTINUE
      ALPHA = 2.*ALOG(FC2/4.)
      Z100 = -ALOG(ALPHA)
C     Iterative solution for Z100
      DO 3 I=1,5
         Z100 = -ALOG(ALPHA - Z100)
    3 CONTINUE
C
      SH = (100. - HMAX_CALC)/Z100
      Z = (H - HMAX_CALC)/SH
      EXZ = 1. - EXP(-Z)
C
C     Set output values in /XX/ common block
      HMAX = HMAX_CALC
      X = FC2*EXP(0.5*(EXZ - Z))/F**2
      PXPR = -0.5*X*EXZ/SH
C
C     PXPTH calculation, split onto two lines
      PXPTH = -PXPR*(1.-1./Z100)*PHMPTH
     &      + (1. - Z*EXZ/(Z100*(1.-EXP(-Z100)))) * X/FC2*PFC2PTH
C
C     If perturbation flag is non-zero, call the perturbation subroutine
      IF (PERT.NE.0.) CALL ELECT1
C
      RETURN
      END