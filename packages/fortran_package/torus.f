INPUT PARAMETER FORM FOR SUBROUTINE TORUS
A perturbation to an ionospheric electron density model consisting of
an East-West irregularity with an elliptical cross section above the
equator

N = No (1 + ll)

ll= Co exp { - [

(Ro + Ho){ 8 - n /2) cos S + (R - Ro - Ho) sin B ] 2
A

_ [ (R - Ro - Ha) cos SB- (Ro +Ho}{8-n/2) sin S

Ro is the radius of the earth.
R, 8, cp give the position in spherical polar coordinates.
No (R, 8, cp) is any ionospheric electron density model.
Specify:
Co = _ _ _ _ • (W15I)
Semi-major axis of ellipse, A = ______km (W152)
Semi-minor axis of ellipse, B =

km (WI 53)

Tilt of ellipse, S = _ _ _ _ _ degrees
Height of torus from ground, Ho =

(W154)

- - - - km (W155)

(W150: = 1. to use perturbation, -= O. to ignore perturbation)

127

T}

SUBROUTINE TORUS
COMMON ICONST/ PI,PrT2,PJD2,DUM(51
(OMMON IXXI MODX(2),X,P XPR ,PXPTH,PXPPH,PXPT,HMAX

TOR 001
TOR 002
TOR 003
(OHMQN R(61 /WW/ IDflO),WO,W(4QQI
TOR 004
Eau ! VA LENC E (EAR THR ,W ( 2 I ) , ( C () ,w ( 151 I I , ( A' W( 152 I ) , ( B' W( 153 I I ,
TOR 005
1 (BETA,ItJ( ~C:;4J 1,(HQ.W(15S1 )
TOR 006
REA L LA~\RDA
TOR 007
DATA (P DPP =O.J,(~ODX(21=6H TORUS)
TOR 008
EN TRY ELECTI
TOR 009
IF (X.Eo.O •• AND.PXPR.EQ.O •• AND.PXPTH.EQ.O •• AND.PXPPH.EQ.O.) RETURNTOR 010
IF (C o . EO ,O.1 RETURN
TOR 011
RO =EARTHR+HO
TOR 012
Z;R(IJ-RO
TOR 013
LAMBDA=R O*tR( 2)-PJD2)
TOR 014
SINBET ; S IN(eETAJ
TOR 015
(OSBET;(OS(BETAJ
TOR 016
P=LAMBDA*CQSBET+Z*SINBET
TOR 017
Y=Z*COSBET-LAMBDA*SINBET
TOR 018
DEL TA=CO* EXP{ -fP/A1**2-(Y/SJ·*ZI
TOR 019
DELl;DELTA+I .
TOR 020
PDPR=-2.*OElTA*IP*SINBET/A**z+v*caSBET/S**21
TOR 021
POPT=-2.*OELTA*fP*RO*COSBET/A**2-Y*RO*SINBET/S**21
TOR 022
PXPR =PXPR*OELl+X*PDPR
TOR 023
PXPTH=PXPTH*OELl+X*PDPT
TOR 024
PXPPH =PXPPH*DEL1+X*PDPP
TOR 025
X=X*DELl
TOR 026
RETURN
TOR 027
END
TOR 028-
