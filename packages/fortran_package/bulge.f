INPUT PARAMETER FORM FOR SUBROUTINE BULGE
An analytic ionospheric electron density model which represents the
general latitude variation of the equatorial ionosphere (afternoon,
equinox, sunspot maximum) - see the center panel of figure 3.18b,
page 133 of Davies (1965) .
The model is an alpha Chapman layer with parameters which vary
with geomagnetic latitude.
1

e

z(l-z-e

_z

)

h - h
max
where z = --::-:..::::=:.:
H

fN is the plasma frequency
f

is the critical frequency
c
h
is the height of the maximum electron density
max
H is the scale height
h is height
f , h
, H vary with geomagnetic latitude in the following way:
c
max
if h<lOO krn, h
= 350 km, f = 15 Mc/s
max
c

-------=
For h;;, 100 km,
h

= 350 if A;;' 24

0

max
(180 )
= 430 + 80 cos 24 A if A < 24
max
A is the geomagnetic latitude in degrees
0

h

In all cases H is determined by the constraint that
f

N

= 2 Mc/s at 100 km.

122

C
C

C
C

C

C

C

SUBROUTINE BULGE
ANALYTICAL MODEL OF THE VARIATION OF THE EQUATORIAL F2 LAYER
IN GEOMAGNETIC LATITUDE
(EQUATORIAL BULGE AND ANOMALY)
SEE FIGURE 3.18B, PAGE 133 IN DAVIES 11965J.
THIS MODEL HA S NO VARIA TION IN GEOMAGNETIC LONGITUDE.
COMM ON I CQNSTI PI,PI T 2,PID2t DU ~(5)
COM MON I XX! ~ODX{2 J , X , cXPR tPXPTH.PXPPH,PXPT'HMAX

BULGOOI
BULG002
BULG003
BULG004
BULG005
BULG006
BULG007
(OW·ION RIb) tWWI I D tl O ),W Q ,W(4QQI
BULG008
EQU I V AL ENCE (EARTH R .W ( 2 1) ,(F.W(6J),(PERT,W(15 0 1J
BULG009
DATA (~ODX(lJ=6H 8 ULGFJ
BULGOIO
EN TR Y ELECTX
BULGOII
H=RIl)-EARTHR
BULGOI2
PHMPTH=PFC2PTH=Q.
BULGOI3
HMA X=35 0 .
BULGOI4
FC2;225.
BULGOI5
IFIH.LT.IOO') GO TO 2
BULGOI6
EQUA TOR I AL BULGE
BULGOI7
BULLAT=7.5*IPID2 - R(2))
BULGOI8
IFIABSIBUL LAT).GE.PI)
GO n 1
BULGOI9
HMAX=43Q.+SO.*CQSISULlATI
BULG020
PHMPTH=600.*SIN(BUL lAT)
BULG02I
EQUATORIAL ANOMALY
BULG022
ANMLAT;22.5*IPID2 - R(2))/PI
BULG023
POW=2.-ABSIANM LAT)
BULG024
FC2=50.*ANM LAT**2*EXP {
POW
) + 40.
BULG025
PF C2PTH=- 1125./PI*P QW*ANMLAT*EXPIPOWl
BULG026
FORCING PLASMA FREQ AT 1 00 KM TO BE 2 MHl IN ORDER
CALCULATE SH BULG027
2 ALPHA =2.·ALO;(FC2/~.).1.
BULG028
l100; -ALOG (ALPHA)
BULG029
DO 3 1=1,5
BULG030
3 l100; -ALD GI ALPHA-ZlOO)
BULG03I
SH=II00.-HMAX)/ZIOO
BULG032
Z=IH-HMAXI/SH
BULG033
EXZ=l.-EXPI -Zl
BULG034
X~FC2*EXP (.5* (EXZ-Z ) I/F**Z
BULG035
PXPR=-O.5*X*EXZ/SH
BULG036
PXPTH=-PXPR*(l.-lIZlOO)*PHMPTH+(I. -Z*E XZ/(ZlOO*(I.-EXP( -lI OO}}l)
BULG037
I
*X/FCZ*PFCZPTH
BULG038
IF IPERT.NE.O.) CALL ELECT I
BULG039
RETURN
BULG040
END
BULG041-
Following line BULG038 in SUBROUTINE BULGE on page 123, insert the line :
BULG0385
PXPPH=O .
Following line EXPX014 in SUBROUTINE EXPX on page 124, insert the line :
PXPTH=PXPPH=O.
EXPX014S
The equation for the gyro frequency near the top of page 143 should r ead :

F ..
n

= FH. (R 0 I(R 0 + h»3(1 + 3 cos 2g)1/2
o

where 9 is the geomagnetic colatitude .
Line TABZ01S in SUBROUTINE TABLEZ on page 153 should r ead :
IF (READNU . EO.O . ) GO TO 10

TABZ01S

