INPUT PARAMETER FORM FOR SUBROUTINE SHOCK
A perturbation to an ionospheric electron density model consisting of
an increase in electron density produced by a shock wave
N(R, 8, cp ) = No(R, 8, cp )[l + P exp(- 9(Pc; P:)]

Pc = s (h - h o ) - w
P = R[cos- 1 [cos(cp - CPo ) cos (A - 1,.0)] [

No (R, 8, cp ) is the ambient electron density specified by any electron
dens·ity model.
R, 8, cp give the position in spherical polar coordinates.
h = R - a is the height above the surface of the earth.
a is the radius of the earth.
TT

A = 2" - e is the latitude.
Specify:
Relative increase in electron density, P = _____ (WI 51).
Width of the disturbance, w =

- - - - km (WI 52) •

Latitude of the center of the disturbance, 1,.0 =
radians or degrees
(WI53).
--Longitude of the center of the disturbance, CPo =
radians or
degrees (W154).
---Slope measured from vertical - rate of increase of Pc with height,
s =
(W155).
Height to the bottom of the disturbance, ho = ____ km (WI 56).
(W150: = 1. to use perturbation, = O. to ignore perturbation)

132

C

SUBROUTINE SHOCK
SHOCOOl
A PERTURBATION TO AN ELECTRON DENSITY MODEL SIMULATING A SHOCK WAVE SHOC002
COMMON ICONST/ PI,PIT2,PI02,QUM(5 1
5HO(003
COMMON IXX/ MODX(2I,X,PXPR,PXPTH,PXPPH,PXPT,liMAX
SHOC004
(OHMQN R(61 /'NW/ IO(lOI,WQ,W(40QI
EOUIVALENCE {EAR TH R ,W (21 J , (P,W( 1511) ,(WW,W( 152»
1 (ALON,W(1541),(S,\;I(155 1 )dHQ,\-J1l561 J
RE:AL LAT ,LON

,(ALAT,W(153 1),

SHOC005
SHOC006
5HOC007
SHOC008

DATA (~ODX(2) =~H SHOCK)
SHOCQ09
ENTRY ELECTl
SHOCOlO
IF (X.EQ.O •• AND.PXPR.EQ.O •• AND.PXPTH.EQ.O •• ANO.PXPPH.EQ.O.) RETURNSHOCOll
IF (P.EQ. Q•• OR.WW.E O.O.1
RETURN
SHOC012
H=RIll -EA RTHR
SHOCOl3
QHQC=5*(H-H01-WW
5HOC014
LON=RI3 - ALON
SHOCOl5
'
LAT=PID2-RI21-ALAT
SHOCOl6
COSLON=COSILONI
SHOCOl7
COSLAT=COSILATI
SHOC018
U=CaSLON*CQSLAT
5HOC019
RHO=RIll*ACOSIUI
SHOC020
DIF=RHOC - RHO
SHOC021
CON =-9 ./WIA'** 2

SHOC022

CONS=P*EXP(CON*DIF**21

SHOC023

CONST=l.+CONS

SHOC024

CON=Z.*CON*CONS*OIF
PXPR=PXPR*CONST+X*CON*IS-RHO/R(l»)
CONS=R(1)*ll./SQRTll.-U**2)
PXPTH=PXPTH*CONST+X*CON*CONS*COSLON*SINILAT)
PXPPH=PXPPH*CONST-X*CON*CONS*COSLAT*SrNILON)
X=X*CONS T
RETURN
EN D

SHOc025
SHOC026
SHOC027
SHOC028
SHOC029
SHOC030
SHOC031
SHOC032-
