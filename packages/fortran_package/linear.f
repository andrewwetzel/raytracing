INPUT PARAMETER FORM FOR SUBROUTINE LINEAR
An ionospheric electron density :model consisting of a linear layer
for h < h

N=O

-

N = A(h - h

for h> h

. )
rnm

.

mln

.
rnm

The ray will penetrate if h> h

max

.

Spec ify:
A = _ _ _ _ _ electrons/crn3 /

krn (WIOI)

hrnax= _ _ _ _ _ krn (WI02)
h

min

= _____ krn (WI03)

SUBROUTINE LINEAR
LINE AR ELECTRON DEN S ITY MODEL

C

CO MMON ICONST! PI .pr T2,P ID2,OEGS,RAD,K,DUM{21

CO MMON /XX/ MODX(ZI,X,PXPR,PXPTH,PXPPH,PXPT,HMAX
COMMON R(6)
EQU 1 VA LENCE

/WW/ I D(lO).,W(),WI4001
(EAR THR, W{ 2 I I , ( F, W(6 I J , (F ACT, w( 101 ) I , (HM, W( 102 I I ,

1 (Hr-t IN,WII 03)},(PERT,W(lSOI)
REAL K

DATA (MODX(11=6HLINEAR)
EN T~Y ELECT X
H=R(1) - EAR THR
HMAX=H~

X",PXPR =O.
IF

(H.LE.HMINI

GO TO 50

PXPR=K*FACT/F**2
50

X=PXPR*(H-HMIN)
IF (PERT.NE.D.I
RETURN
END

CALL ELECTI

120

L1NE ODI
LI NEOOZ
LI NE003
LI NED04
L1NE005
LINEOD6
LINE007
UNE ODa
LINE 009
LI NED 10
LINEDl!
LINEOIZ
L1NEOI3
L1NEOI4
LINE015
L1NEDI6
LINE017
L1NEOla
Ll NEOI9-
Line LINE013 in SUBROUTINE LINEAR on page 120 should read :
X=PXPR=PXPTH=PXPPH=O .

LINEO 13

Line PARA012 in ~UBROUTINE QPARAB on page 121 should re?d :
X=P XP R=P XPTH = PXPPH =0 .

PARA012

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

