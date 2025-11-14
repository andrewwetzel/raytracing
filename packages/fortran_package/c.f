FUNCTION C(XI
DOUB LEPRECISION
PIH, XD .. Y.. V. A, OZ, ON, 0, Z
DATA (Al=O.31830991,(A2= O. 10132),{Bl=O.0968),{B2=0.154)
PIH = 1.570796326794897
XA

= ASS!Xi

IF

(XA.GT.4.1

XD

=X

Y
V

PIH*XD*XD

A =

1. DO

c

GOTa 20

c
c
c

c

A
M
15.*CXA + 1.1
DO 10
I = 1, ~
KZ=2*( I-I)
KV=4*( I-I)

c

c
c
c
c
c

KV + 1

ON = IKl + 1)*{KZ + ZI*IKV + 51
Q

= OZION

A
10 Z

- A*O*V

c
c
c
c
c
c
c

Z + A

l*XD
Z

RETURN

c
20

c

W = PIH*X*X
XV~XA**4

c

RETURN
END

c

C=O.5+(AI - BI/XV)*SINCW1/XA-(A2-B2/XV1*COSIW 1/XA**3
IF (X.LT.O.)
C = -C

c

c

FUNC TI ON SeX)

S

PIH, XD, y, V, A. OZ. ON, O. Z
DATA CAl=0. 3 183 099 ),(A 2 =0.lOI321,(Bl=O. 0 968),(B2=0.1541
PIH = 1.5707963Z679~897

S

XA = AAS(XI
IF (XA.GT.4.1

S
S
S
S
S

XD
Y
V

GO TQ

20

= X

S
S

PIH*XO*XI)
Y*Y

S

S

A

Y/3.DO

S

Z

A

M

1~.*(XA

S
S
S

+ 1.)
J = 1. M

00 10

KZ=2*(I-l)
KV=4*(I-IJ
OZ
KV + 3
ON
CKZ + 2)4CKl + 3 1*CKV
Q

S
S

S

+

s

71

OZION

S
S
S
S
S
S

A :::r -A*Q*V
10 Z
l

=Z + A
= l*XD

S = Z
RETURN

20

c
c

DOUBLfPR~ctSION

c

c

c
c
c
c
c

2

Z
C

c

c

y*y

QZ

c

S

W = PIH*X*X
XV=XA**4
S=0.S -(AI-BI/XVJ*CO S(WI/XA -IA2-B2/XVI4 SIN (W 1 / XA**3
IF IX.LT.O.1
S = -S

S
S

RETURN
END

S
S

108

S
S

001
002
003
004
005
006
007
008
009
010
0 11
0 12
013
0 14
015
016
017
018
019
020
021
022
023
024
025
026
027
028
029
030
31-
