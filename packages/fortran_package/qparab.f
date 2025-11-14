INPUT PARAMETER FORM FOR SUBROUTINE QPARAB
An ionospheric electron density model consisting of a parabolic or a
quasi-parabolic layer ( concentric)

,

f N

~

f

c

h-h

"

[1.

y

max . C

,
1

,. f f

N

> O.

m

fN

C

c

O.

otherwise.

1.

for a parabolic layer

R

+h

o

whE>re R

max
R +h
o

o

Y

m

for a quasi-paraboli c layer

is the radius of the ea rth .

Specify :

Critical f r equency .. fc = ______ Mc/s (W I Dl)
Height of maximum electron density , h

S e mi -thickness, Y

m

max

_ _ _ _ _ km. (WI02)

_ _ _ _---'km. (W I03)

Type of profile:
Plain parabolic _ _ _ _ _ _ _ (W I 04 = O.

Quasi-parabolic

C
C
C

(WI04 = 1.

SUBROUTINE QPARAB
PLAIN PARABOLIC OR QUASI-PARABOLIC PROFILE
W(lO~)
= O. FOR A PLAIN PARABOLIC PROFILE
1. FOR A QUASI-PARABOLIC PROFILE
COMMON IXX/ MOOX(2),X,PXPR,PXPTH,PXPPH,PXPT,HMAX
CO~MON R(6) /WIN/ IDIIO),WQ,W(4001
EQUIVALENCE

IEARTH R ,W(2)),(F,W(61),(FC,W1I Ol)) ,(HM,W(102)),

1 (Y ." 1,W(103)),CQUASI,\!,'(!04)J,CPERT,WI150))
DATA IMOJXIll=6HOPARABI
ENTRY ELECTX
HMAX=HM
PXPR=O.
H=RIII-EARTHR
FCF2=(FC/FI**2
CONST=!.
IF (QUASI.EQ.I.) CONST=(EARTHR+HM-YM)/R(I)
Z=CH-HM1/YM*CONST
X=MAXIFfO.,FCF2*(1.-Z*ZII
IF (X.EO.O.) GO TO 50
IF (QUASr.EO.I.) CONST=(EARTHR+HMI*IEARTHR+HM-YM )/ R(1)**2
PXPR=-2.*Z*FCF2/YM*CONST
50 IF (PERT.NE.O.) CALL ELEcT 1
RETURN
END

121

PARA OO l
PARA002
PARA003
PARA004
PARA005
PARA006
PARA001
PARAOOB
PARA009
PARAOIO
PARAOII
PARAO!2
PARA013
PARAO!4
PARAOI5
PARAOI6
PARAOI7
PARAOIB
PARAOI9
PARA020
PARA02I
PARA022
PARA023
PARA024-
