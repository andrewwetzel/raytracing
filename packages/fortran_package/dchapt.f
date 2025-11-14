INPUT PARAMETER FORM FOR SUBROUTINE DCHAPT

(1-

An ionospheric electron density m.odel consisting of a double, tilted
Chapm.an layer

lN = fZcl exp -Z1 (l-z 1 - e -Zl ) + f ZcZ exp 21 ( l - z Z -e -Z2 )
h-h

h-hm.l

zl

=

fZ
cl

= fZclO C(8 -n/Z)

Zz

HI

=

m.Z

HZ

Z
l cZ = f czo
C(S-n/Z)
n

n

fT

n

h

h
+ R 0 E ( 180 ) (8 - -Z)
m.l = m.lO

h

+ R E ( 180 ) ( e - -)
Z
m.Z = hm.ZO
0

Specify:

=

MHz (f

at equator)

(W 101)

=

Km. (hm.l at equator)

(W 10Z)

HI

=

Km.

(W 103)

f

=

MHz (f cZ at equator)

(W 104)

=

Km. (hm.Z at equator)

(W 105)

HZ

=

Km.

(W 106)

C

=

rad

E

=

deg

f

dO

h

h

m.lO

cZO
m.ZO

-1

cl

(fractional change in fCl' fcZ.
position for increases southward)
(positive for upward tilt to the south)

118

(WI07)
(WI08)

SUBROUTINE DCHAPT
TWO CHAPMAN LAYERS WITH TILTS
COMMON ICONS T/ PI,PIT2,PID2,OUM(5)
COMMON /XX/ MODX(2),X,PXPR,PXPTH,PXPPH,PXPT,HMAX
COM ~·10N

R(6)

/WWI

IOIIOI,WQ,WI4001

EQUiVALENCE (EARTHR,W(2J1,(F,W(6)),{FCl,WllOll),(HMl.Wl102)).
1
2

(SHbW( 103) I ,(FC2,W(104) ) , (Hf-12,W( 1(1511 ,(SH2,WCI 0611, ((,WIID7)),
(E,WII08),(PERT,w(150))

DATA

(~ODX(lJ=6HDCHAPTl

ENTRY ELECTX
EARTHE =EARTHR*E
THElAZ=R(Zl -PID2
HMAX=HMl+EARTHE*THETA2
X=PXPR=PXPTH=a.
H=RCIJ-EARTHR
IF (H .ll.O.) GO TO 50
ll=(H-HMAX1/SHl

EXPZl=l.-FXP(-Zll
TEMP=1.+C*THETA2
X=(FCI/F1**2*TEMP*EXP(.S*(EXPZI-Zl'l
PXPR=-O.5*X*EXPll/SHl

PXPTH=X*C/TEMP-PXPR*EARTHE
IF (Fe2.EO.o.) GO TO 50
l2=(H-HM?-EARTHE*THETA21/$H2
EXPZ2=1.-EXP(-Z2)

X2=(FC2 / FI**2*TEMP*EXPI.S*IEXPZ2-Z2)'
X=X+X2
PXPR2=-O.S*X2*EXPZ2/SH2
PXPR=PXPR+PXPR2
PXPTH=PXPTH+X2*C/TEMP-PXPR2*EARTHE
50 IF (PERT.NE.D.l CALL ELECTl
RETURN
END

119

OCHAOOl
DCHAODZ
DCHA003
DCHAOD4
DCHAD05
DCHAD06
DCHA007
DCHAOD8
DCHAOD9
DCHAOIO
DCHADll
DCHA012
DCHADl3
DCHA014
DCHA015
DCHADl6
DCHAOl7
DCHA018
DCHA019
DCHADZO
DCHAOZI
DCHADZZ
DCHAOZ3
DCHAOZ4
DCHADZ5
DCHAOZ6
DCHAOZ7
DCHADZ8
DCHAD29
DCHA030
DCHA031
DCHA032
DCHA033-
Line DCHA014 in SUBROUTINE DCHAPT on page 119 should read :
X=PXPR=PXPTH=?XPPH=O.

DCHA014

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

