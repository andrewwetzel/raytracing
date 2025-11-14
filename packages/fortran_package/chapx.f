INPUT PARAMETER FORM FOR SUBROUTINE CHAPX
An ionospheric electron density model consisting of a Chapman layer w i th
tilts, ripples, and gradients

r

2

= fC exp\.. Ci (l - z - e
h - h

z

h

).J

max

H
2

f

-z '\

= <0

c

h

max

(1+ A SID ( 2 T1 (e - D/B) + C (8 - D)

maxo

+ E( 8 - ~

'I Ro

2 "

iN is the plasma frequency

h is the height above the ground
Ro is the radius of the earth in km
and

e is the colatitude in radians.

Specify:
Critical frequency at the equator,

f

= __~
""-...,,
• S'
=--___...:MHz (W I OI)

Co

Height of the rnaximwn electron density at the equator,

Scale height.
Ci

H =

h

=300 km (WI02)

maxo

_-',"'2.
, =-.___ km (W I 03 )

= _ -"O
='S'
>L__ (W I 04,

0.5 for an

Ci

Chapman layer,

1. 0 for a

8 Chapman layer)
2

Amplitude of. periodic variation of f

Period of variation of l

c

w i th latitude,

with latitude,

A = _ _",Q,,, _ _ (W I 0 5)

rad
B = __-'0::0....____ deg (WIO 6)

km

c

Coefficient of linear variation of f
Tilt of the layer,

2·

c

with latitude,

E = _ _---'0::...:.. ___ rad (WI08)
deg

165

C =

0.

r ad - 1 (W I O?)

INPUT PARAMETER FORM FOR SUBROUTINE WAVE
A pertur"!:>ation to an ionospheric electron density model consisting of
a "gravity-wave" ir 'r egularity traveling from north pole to south pole

6.

= 6 exp - [(R - Ro - zo)/H]2
cos 2rr [t' + (rr/2 - 8) ~xo

+ (R - Ro)1 A, ]

aN __~rr Vx N 6 exp _ [(R - Ro _ zo)/H]2
o
at
x
sin 2rr [t' + (n/2 - 6) ~: + (R - Ro)/Az ]

Ro is the radius of the earth.

R,

e, cp are the spherical (earth-centered) polar coordinates
(6. is independent of co ).

No (R, 6, co) is any electron density model.
Specify:
the height of maximum wa ve amplitude, Zo = 250. km (Wl5l)
wave-amplitude "scale height," H = /00.
wave perturbation amplitude, 6 =

0.1.

km (W152)

[0. to 1.J (W153)

horizontal trace velocity, Vx =
km/sec (W154)
(needed only if Doppler shift is calculated)
horizontal wa velength, Ax = 100. km (W155)
vertical wa velength,

}~%

=

100. km

. .In \vave perlO
. d 5, t' =
tlme

166

0.

(W156)

[0. to 1. J (W157)

INPUf PARAMETER FORM FOR SUBROUfINE DIPOLY
An ionospheric lTIodel of the earth I S magnetic field consisting of an earth
centered dipole
The gyrofrequency is given by:
1

fH = fHo ( R;:h) (1 + 3 cos

2

>-)'

The magnetic dip angle, I, is given by

tan I = 2 cot

>-

h is the height above the ground
Ro is the radius of the earth

A is the geomagnetic colatitude

Specify:
the gyrofrequency at the equator on the ground, fHo = ---,0"",-,-,8,,-__ MHz (W20i)
the geographic coordinates of the north magnetic pole
radians
latitude
= _ ...7",8","",5'",-_ (!egr e!]> north (W24)

long itude

L'. .,,--_

= _2b...
Q

radians
([egre§> east (W25)

167

INPUT PARAMETER FOR M FOR SUBROUTINE EXPZ 2

An io'"1ospheric collision frequcncy model con,sisting of a double
c'<po!1cntial profile

where h

is thc height above the ground.

Specify for the first exponential:

3. "5 x/O ¢

Collision frequency at he i ght h1' \1 1 =

p,~r

Reference height,

h1

collis ions

second (W251)

=_ . .I'-'O"'-"O<-___km (W252)

Expoc,ential dec r ease of

\I

with height,

a1 =

(J.IJf8

km - 1 (W253)

Specify for th-~ second exponential:

Collision freq'~ency at height h2 , \1 2 = __....,_3'-O'""----:---:-:-=-::-c:--_collisions
p'~r second (W254)

Reference h 'oight,

h 2 = _LI_If'-"'O"-___km (W255)

Exponential decrease of

\I

with he i ght, a2

1 68

= D.o/83

km -1 (W256)

Appendix Sb .
XOI
1
1
3
4

5
7
9

11
13
15,
16
17
20
22

TEST CASE
O.
- 1.

O.
40.
- 105.
6.0

o.

45.0

1

O.
90.0
15.0
200.

1
1
1

o.

3.

57

2.

58
71

2.
5.0

72

1.
1.
40.0
-105.
52.12
-81.8

81
83

84
85
86

87
101
102
103
104
150

1

1

1
1
I

1

100.0
6.5
300.0
62.
0.5

1

1.
250.
152 100.

Listing of I nput Cards for t h e Sample Case

OF DUPLICATE W CARDS, THE LAST ONE DOMINATES
EXTRAORDINARY RAY
TRANSMITTER HEIGHT. KM
TRANSMITTER LATITUDE. DEG NORTH
TRANSMITTER LONGITUDE. DEG EAST
INITIAL FREQUENCY, MC/S
DONT STEP FREQUENCY
INITIAL AZIMUTH ANGLE, DEGS CLOCKWISE FROM NORTH POLE
DONT STEP AZIMUTH ANGLE
INITIAL ELEVATION ANGLE, DEG
FINAL ELEVATION ANGLE, DEG
STEP IN ELEVATION ANGLE. DEG
RECEIVER HEIGHT ABOVE THE EARTH, KM
NUMBER OF HOPS
INTEGRATE AND PRINT PHASE PATH
INTEGRATE AND PRINT ABSORPTION
NUMBER OF STEPS FOR EACH PRINTING
PUNCH RAYSETS
PLOT PROJECTION OF RAY PATH ON A VERTICAL PLANE
LEFT LATITUDE OF PLOT, OEG
LEFT LONGITUDE OF PLOT. DEG
RIGHT LATITuDE OF PLOT. DEG
RIGHT LONGITUDE OF PLOT, DEG
DISTANCE BETWEEN TIC MARKS. KM
CRITICAL FREQUENCY, MC/S
HMAX, KM
SCALE HEIGHT, KM
ALPHA CHAPMAN LAyER
CALL PERTURBATION SUBROUTINE

151

zo,

153
155
156
201

SH, SCALE HEIGHT, KM
DELTA
LAMBDAX, HORIZONTAL WAVELENGTH, KM
LAMBDAZ, VERTICAL WAVELENGTH, KM
GYROFREQUENCY ON THE GROUND AT THE EQUATOR. MHZ
ACCEPTED STANDARD LAT. OF NORTH MAGNETIC PO LE. DEG NORTH

0 .1
100.
100.

24

0.8
78.5

25
251
252
253

291.
3.65
100.0
.148

254

30.

255
256

140.
.0183

XOI
71

TEST CASE

72
81
82

o.
o.

2.
10.0

1
1

E4

KM

ACCEPTED STANDARD LONG. OF NORTH MAGNETIC POLE, OEG EAST

COLLISION FREQUENCY AT HI. ISEC
HI, REFERENCE HEIGHT, KM
AI, EXPONENTIAL DECREASE OF NU WITH HEIGHT, /KM
COLLIsION FREQUENCY AT H2. ISEC
HZ, REFERENCE HEIGHT, KM
A2, EXPONENTIAL DECREASE OF NU WITH HEIGHT. IKM
(A BLANK IN COL. 1- 3 ENDS THE CURRENT W ARRAY)
NO PERIODIC PRINTOUT
DO NOT PUNCH RAYSETS
PLOT PROJECTION OF RAY PATH ON THE GROUND
LATERAL DEVIATION EXPANSION FACTOR
(A BLANK IN COL . 1- 3 ENDS THE CURRENT W ARRAY)

Col. 1 - 3
Identification number
Col. 4-17
Data in E14. 6 format
Col. 18
A 1 indicates an angle in degrees
Col. 19
A 1 indicates a central earth angle in kilometers
Col. 20
A 1 indicates a distance in nautical miles
Col. 21
A 1 indicates a distance in feet
Col. 22-24
Left for other cO!lve-rsions
Col. 25-80
Description 0: the data

169

)(01

I[SI

CHAn:

CA~f.

INITIAL VALU ES

,
1

,HP.JL'f

WAH
ro~

TH E

r )(Pl Z

w ~~~~'f --

APPLETON - HAkTREE
kLL

~NGL ~S

IN

~AUIA~S .

ONL'f

~ONZERO

VALUES

FO~HULA

11/ 05/71.
rlCTRAOROlNAR'f WITll COLLISIONS

P~ I NTEO

-1 .00000UOO~OJ*UOO
b.J7~O~O~~~GG~ti0 3

•5 Eo .

~<HJ 1 700o0 J-OOl

-1. 6jZ5357 14 &u9~OO

7

b.OOuOOO~OOOO ' OOO

11

7.8,3~o l oJ3~0 - ~0 1

10

1. :j 7 OHI) 32679*0 00

17

2.6 17 q~3077ql - u& 1

"zz 2.0JOOOOOOOOOt002
1.00 00&000000 +003
10083kQZ80+000
""" 5I .J. 0189061ZJ31
9 uOO
9
3.00 00~COOOOO+COO

.
.,
...,"
"

>-'

""o

.7

3.DDJOJ&uOOOO &OO
1 • .JOOOOOJOOOO - OOk
5.00000000000900 1
1.000000 00000 *000

(l)

P
P.

. ..
:><:

00
()

1.0U OOuOOO~00 t D02

I.J OOOJOOOOOO - uOo
5.0DODJOOOaOJ-O OI
2.o0Dooaooooo ~ ooo

""71 2.00000000000 90 00
".. b . 9613 1 70080.. 60J-t 001
OOO
1 2/o - 001
"86 -1:;t.0'l007000
... Z7b7'1JZb lJtOOO
" o3.00000000000+002
. 5JOOOCJOOOO t OOO
101
7Z

~
'0
'0

(J)

\11

S

5.0000~OOOOOO + OOO

'0

1 .00000100000 t O~0

(l)

>-'

t. O~OCo~uOO~Ot~OO

8l
~

-1 .~32 59S 71

1.55'16 5~ 71 Z 73-u02

10'
103
10.

D.l~999999~9S + 00 1

:; . 00000 0 00000-001

150

1 .i)Ji)CJJJGOJ~.COij

1 51
1"
1"

Z. 5000JOOOOJO +002

IS'
1"

'01

1 .00000JOO300.0~Z

1.00000 000000 - 00 1
1.i)0 00000OOOO t C02
1 .0000JOOOOOJ +ODZ
! . o~~a~OJCi)i)O - JOl

'51

l.D 5UOJOODQ02 +ilC~

'"
'"

J . OaOO.JOilOOOa t OO l

'52 1. 0300JOOOJOJ+JJ2
"3 1 . .. d OOOOilOOOl - llOl
256

1. lJ~ o;~Hq H~ . OO2

1. 6J.uJJOJ~J~ - JCZ

'1:l

"....
g.
o

g.

•

:;:;:;:;:; ~:! ~ ~ ~ .: ~ ~ ~

o

6:e :: ; !: ~ ~ ~ ~ ~ ~ ~ ~:;::;: :;:

o o o o o Q g O O O Oo _ _ _ _ _ _ NNNNNNNNNMMM

~

~=c c cococoOoooo ooOoOcOcoccooOooc

<1<0
~

' • •• •• •• • ••• • • • • • • • •• ••• •• • • • •
oooOcOoOOCOOgoocoOCOOOOOOOCO -Q

~ ~~~~~* ~~~~ !: : ~~~:~ ~~ ~~~~ ~ ~~ ~~~:
~

O~~~~~~~M

_ ~~

~~

~~~ ~~~~~jjjj_jOO

.... '" .. .. . ..... . .... , ... . . . . . _._.... .
EO NNNNNNN

~

_ ~~ O~~ ~~O~~~N~~~~~~

OMNNNCCCC~~~~N~~

4

N

r

CC~~O_NNMjj
______ _

~

r

~_~jN

oC~

M'

___

j

N

~

~MMMMMMMMMMM NNNNNNNN~ ~~~~~~~~_
O~~~~~~~~~~~NNNNNNNNNOOOOOOOOM

~

O~~~~~~~~~~~OOOOOOOO~~~~~~~~~j
~NNNNNNNNNNN~~~~~

•

••••

••

~

••

CCN~~

~

~

~

•

•

______ O
••••• "
•
___ C

~~
~N NN~ ~~~~~~~#
~~~~O
_ ~~~~~~~~~~~ON~~
~ ~OO _ N~~

COO

~g~~

•

j~~

~
~

~

•

~

• • •
N __

~

••••
__

~~

o

~"'oMNNNCCCC

w

j ~C

~C~~

~

0..:1:
0

MM~MCN~

OCjONjC~jjjOj

~~~~~
CON~~~~OO_NMM
______
NNNMMM j j j j j j

•

•

~~~~Oj_MM

~~~~~gg~~~

_~~

~

__________

0
0
0
0

,
"

~

0

~
::O$~

:l:O U ....

... _

O?

i:-'

~

>
~

C
0

,

0

"

,
•

>.

..
--.
w
Z. >

_Z_

",,,,
"

r<

."'..,,~
o w

>

L

0

- -

>

no

.

~

171

Z .... :::

e ;;~
o.

.. .
..
>
_ w
~

'"

.>

0

Z

z

z

o

goaO~~~~~~~~~~~~~O~~~4~~4~~~ ~
oooooo_~~~~~ ~~~ _~~~~~~~~_N~4 ~
c
o o o o o o c O O = = = = = _ _ _ _ _ _ _ _ _ NNNNN

~

~mo==o=oo=ooooooooooooooooooooo

a: c

o

•• • • • • • • • • • • • • • • • • • • • • • • •••••

0000 000 000000000 0000000 0

000 0

0

~

~
,~

.z

z

·;

,0

OOOOO=~4~M

~

u

0

_ ~~O~~~~3_4~_

----------

___________ 00000000 4

_______ ~

J:

•

•••••••••

•••••

••••••••••••••

o

~

~ NN"'MM ~ ~~~~~~~~~~~ ~ N ~~~ ~~~~~

~

0

~~~~~-~--~

O~~M~~NO N~O ~~_NM~N~~Q~~N_~~_N

0

Z~O~~~"_""~~~M~~~~ ~ ~~MQ~a~NN~~~

0

... l:

•

'"

",'

0

~

z

z

w

0

••
z,

~

~

z
~

e •."
~

;• "0

40

M.~~Q"M

•

~~"M

0

z

N

~~Q~~_~~~~~~~~MM~~~~~~"'Q~MM~ ~ ~~
~"'~~"'~M ~ ~~M~ ~~ ~M ~ ~O~~~~~M~ ~ ~

u
w

0

~

~4N

o44444444J34~~~~~~~~~ooooooo_
=
___________ OOOCOOOO _ MMMMMMM4

··• ,
"w

N

_N NN MM4~~~~~~~~OO~ON44~~~Oo~

Q..

0

~

~

O O O O O O O O O O O O N N N N N NNNMO OOOOOOO

•~
w

444~~~_M

M~O~~~

~N40N~M_~~NMMMM

>

~

NNO~40NN~

~~O

O_N_~~4~N~OOO_NNNO~_Me

X

~

0

~

~

~

z

O~

044444M04~M_~~~~00004~~~~

~O

-~
-~
0

•z

O~~~4_~

__
_ _ ~~
___
__
ILl:.: • • • • • • • • • • • • • • • • • • • • • • • • • • • • •
~
U~
_ _ ~~~~~4 _ ~NN~~ M MM~~ ~_ 0000 4 N
~

o ~

,

O ____

~

~-

•

•

N

u
w

•

O

•

_

•

...
•

~~

.

• _
• _
• _•

~

•

___
• _
• _
• _
• _
• _• _•
"O

O~

~"

_M

•

•

N

O

•

•

NNNM

~

~

• •

•

•

•

.. , ,

~M_

~~M ~~ ~~~~=~= o ~ o~=~ ~~ N~~===o ~ ~

4~=_N ~~~

o

•

~O~~N

''';'

~

.... OQ==OOOOQOCC~cc==COOOO

~~O_MNMM~COC OCO OOOC=OCOMMOOOOOO

f~~~~ ;~~~~~~
~~~ ~~ ~~~~~~, ~~
, ,
, , ~~~~~~
,

,

.,o
o
e
o
o

•

_- "' .... '" , , , , , , , , , , ,

~~~

,,,

u

w

•

OMM~~"'~"'~N~~OOO"' ~N .~ ~~O ~ ~NMNO
~
O~C~~~ ~ NO _ ~~OON"'O~~M"'~O~MM~~O~
Z4~OD~O ~~" ~~~DMO~~~~~"N~M~~_. " I~O
~

--

.

0<..1 . . . . . . . . . . . . . . . . .

.

.

.

.... .

....... N

, --- --- ,,--, , --, , --

... OO~~~~~~~~~M~_OOO"' ~ ~~~.~~~~"'_"'O

~ ~
>

.... ----~--

OOOOOOO_~~~~~ . N"'MNM"''''NMO~~~~
oooooO~.~_~~ ~
OO OO

OO~G~C

_

~

~~~

~~~~I_~~ ~~ ~

~~~~GO~~.

__ ___ _________
••

w
~
u

~~"'~~~ .~

z

OC

_ _

••••••••••••••••••••••

NG~~~~~

•

••

•

•

· 0

"""",,~
M NNN~~Mo _
~~~MNNNNNO

:;
0

z

•

z

OOOO_NN~"'II

OOOOOO O_O~ "'~

~

~~.NO

oooonooooo ____

ze u

•

:Z:OU ...

~MO

OG~

~ ~~ MMMNNN N

o

_ _ M"'_
..

_" NNO~ ~

ooo~cooococoNo

•••••••••••••••

•

•••••••

•

••• J

...... 0 0

OOOOOOOOOOOOoooooooooonooooo~

O .~

,

Z.

•

'

"

,

,

,

,

<:> o
., o
." o
<:>o
'='oL.oc:>O
0
...... _ '. ..., ~ " ' ... M
o
O
o ____

,

,

,

,

,

,

"

~ J' "- ... oJ' J ' N

'" N

'"

U

J

(t' ..,

....

NMMM~~~~~~~~~'"

~~~~~~~~~~~~~~~~~~ ~~ ~~~~~~~~:

~?~~~?~~~~~oer n ~c~~o~e~nOQ~~~

OI~~NC~~ M~_M' . tNO~.C~ ~

<:>

w

~
~

r

;~N

Z

~'~~N~n~~

' N~oQ" ~"' '''M'''''' <:1' _ q>M'''~O , D _I..zN ''''Q

OCN~ON<:1'~. · DC~OON~OO~~N .t~ ~~O~N
oO~~ _~~N N~~O _~~<:1' ~~.~<:1'CC _ ~O~N~

•••••••••••••••••••••••••••••

d~O~ _ ON~~,~..z ~ ~~ Z~ ~O~O~N~~"'~~N~·O
~
~ _ ~~~ ..z~ ~N ' D~QOO~~WMM_oe~ ~ N~~N

... "''''''' '''..., :y, ." ..' '" -..> , L .., ... . .... ~ :: ::: ~~ ~::::::::~:

X

ONQ"'NO~N~ _ N~NN~~ ~~ ~MO~4NN""~

~ ~

~,~

"'

_

~_~~~

o~~N~e

_

~

<:1'~

_

o

~_

~

~M

"'~NO"'~Moe_o"'

__
____

, ~~

~

_t~

~~""~~

~_

___

·D
~

...w ............................ .
~

r

o

~~

~~

~_~I

~

O~~·~<:1'_I.

X

~

__

o~o

~~

~NNNN"'O~

m~<:1'_O~

_~~~..z

. ~~~~~ON~~D~ ~~ ~·~~o~ ..z

------~-----

z
~

--~
an

'W
=oooo~

~

~~~.n~

oo~c

_

OoQ

OOoOOo o

o

.......

,

oooooo~

,

,

•

,

,

,

__
__

oooo

~oooo~oo

,

,

,

,

z
z

W<.!)I .oJ

o~'~~ln~o

"

0

· o~

~~~
r:z:,.

r z

~

----- -

_z.
, .z

'"

.~

~:Y~~o

':>:...00

VI '" ILl

.-

N~~

~"'_ ~ ~ · D~~

'".
- <>: -

-. >

_

,

,

,

,

__

~~

~o_~~

. nl~.o

O~oon

~

noo~ooooo

,

•

,

,

I

,

,

,

...

OOOO~ ~ N _"' ~_~"'MN"'M~MMOMM<:1'_~_~O
•
,.
"
"
,.,"
"
I
,
,
,
,
,

172

,

~~~~~~~~~~~~~~~~~~~~~~~~~~~~
_ _ _ NNNNN

8
~

QOCCOCCOCQOOOOO~_~_~

~~oooooooooococccoccocoococooc

a: 0
o

~

••••••••••••••••••••••••••••

occoocooocooccccccooooaooooc

~

•

~

=~~~~~_~~o~~~~~~c~~~~~~~ ~~~o

4

O~~~~~~~N~~~

~

___

~O~~~~~~~N~C~

C~~~~~~N~==C~~~N=~~~~~~~

_ _ ~O

~O~~~~~~~_=~O~~~~~~~~~OO~_4~_

,,,\0< . . . . . . • • • • . . . . . . • . . • • • . . • . . •
~

•

••••••••

c~~~~~~~~~~~
o~~~~~~~
OOOOOOOOOOOONNNN~NNN~~~~~~~M
a~~~~~~~~~~~~~~~~~~~ONNNNNN~

•

>

~

~

-----C

O

~

=

~

C_N~~O.~N~~OOC~.NONNM_~~~N.
_ _ _ _ _ NNNMMM • • • •
__ N N
~

•Z

~

O ~ ~~MM~~~~OOCOM~8~ ~ONM.M ~_Na
~

~

O~~~~~~~~~~~~~~~~~~~DM~~MMMO

•z

Q. Z;

•

•

•

•

•

•

•

•

•

•

•

•

•

•

•

•

•

•

•

•

•

•

~~O.~~MM~~~~~~~~~ • • • • ONM

•

•

•

•

•

O_N~~C.ON~ONNN_~~~~~O~.O.O_

~

~~_~~ NNN~~4444~~~~~~~O_NNN~

~

~~----

__________ ____
___ __
.
, ,,,,

o
o

•

• • OOO N

o

C~N4~NN~~~

__

OO~~~CN~o~~_~~e_

Z~O~~~O~~~~~~_~~~_~~~_ON~~N~O~

04cN~~~~~~~~~~~~
~~
~
. ~_O
~
UOOON~~~~_~
~
~~_N~_

~

..... z:

~
~

"W

•••••••

•••••

,

•

••••••

•

,, ,

••

•

••••

,,

ON~o~~oco~ccoeceC~~~~~Neo~ce

"~e~~

o

•

__

ccooooooooeOO~~O~OOOOOo

~"O~N_ooooooeooooUOCCOONOOOOOO

0'-' • • • • • • • • • • •

••

•••••••••••••••

~~OOooo~OOOOOOOOOoo~oooon~o~~o

' "

,

,

•

"

,

,

,

,

,

I

,

,

,

,

~
O~~O~~O~~~~NOO~~_~o~~~_~~~~o
~

OCNo~~o~~~~~oO~_~

_

~

O~~~~~~_~cN

Z,,~o=~o_~~~o~~~oO~~~~~~_n ' ~o~~~o,

00..1 ....
_

........................
____

OOooo

~~

~

•

• • '"

=

'NNNNNNNN~NN

,

....

•

~~~~oo_~~~~~~~~o",o~o.

M~M~~M~~~N_

~

,

1

,

' "

oooooo~~~~~~e~~~ ~~~~~ ~~~~~ _

~~

OO~COO~~~CO~~ ~ ~~~~O~O~'~~~~

.... ~ ~
z: W

oocooO~~~~~MM_~~ON'N_~~M~~~~

•••

~o

•

••••••••••••••••••••

•

•• 0

ouooOO~~~~~~~~~N~N_~O_~~~~~O

,

~M~M~~NN NNNNNN ~_

,

~

a

oooooO _ ~~~~~~~~_~~~~=4~~NN' _

"

~oOOOOOO~N'

,.~

N

<

,

o

..,-"

__

~~N~O~'O~~N~O

~

_

~~~~~~~~~~~~~ ~~ ~ ~~;;;~~~~~~~

z:o u w

~_oo

oooo~OOOOOOOOOOOOOOOOUOOOOO~

1

,

C

O V <' U CU~_~~ M MO~U~~~~~

,

"

.,

,

OOOOOCOU _ _

I

,

NNNN~~~

,

~

,

,

,

,

,

U O

"

<.)

_ ~

~O~~~OO

"

.• U
__

~

~~~~~~~~~~~~~~~~~~;~~~~~ ~ \ ~ =
"'"
, 0,

0"'"
I • c,

0,

C'

,

c>
I ""
, 0,

....,..,"'"
, , , 0,

c> 0

e

C

Q

0

Q

. ,

Q

0

"" "" c

O O~~ _ _
~'~~Me~ee
~ O~ ~ O_ON"'TO~~N!
__
O

W

_

N~~

oo",

~

~

Ouo_

uu

",e~~'~~~~~~M

~~~eNo~O"O~

_

N~"'oM~N

__

O

~

~N

U~ · O_'M~~_~MN~~_"'~~ ~ ~"'M_N~O~~

z't
"~

•

••••••

O~ N

•

••••••••••••••••••••

_ _ ~ ~ _~~O N ,~

e"' M_O'MO Q~ _ ~

~~

~O_M~~_'~_T ~ ~ ~N ~ "' M~MMn~ N~C O

Q

_____

O~

N

N~

M~N .

~_~~~~ON~~

M~44

__

~~

.~~

r·

~

~~

~

:

~~O_~~O_~~O~

N

~

- . . .... . . ... .. .. . . .......... .
O~~'~~ ~ \ ~~_~"'~T ~ ~ ~ · O _ ~",,~~o~ ·ft ~_
o~~_O~~~~~M~~",o~~~c~o~~~ ~ ~~N

X

~z:C~ft~~~MMN~OM ~~ ' N

....
z:

'""

~

O

O~~~O~O~~OO~

____
~ . ~~~~:~~~!:==~~~~~~

N

C~

~~~~~~'

N~ln

,

~_
- W
>

,,

0

-- ~

==;;

;!!
~~

W

r.r:>:

~~~NNN~

~

~~

~ ~ ~!~~!

",
-.o w ·.::t

~

_

,

0

O ~

_z ...

x"(""!"

~

W~W

_ ~ _ OO~~~~I~~~DOO"'~~~ I ~_O~ ~ ~ ~

~O

_~_O_oOOOOOOD~_OOOOO_o~OOOOO

.. , " " " . , " , , .

OOOoOooooOOOO~OOOOOOoo~OoOOO

, . , . ," _ _" " ,

~OMCNN

,

'"

~NN

I

_

,

173

OO~'NNNN~O~N

,

_

N~O

","

'"

TEST CASE

CHIl.~)(

w~"E

OIPOlY

b.COQJ~G

FI<EaU[ ,' j(.Y

ELEVATr~~

0"000

XHTR

0.000 OUR 101\'
]-011
0+ I) oa

-

-J

"'"

-j-JOq
-lo-\I J8
-1- 0Jl
5-0J~

-2-005
&-Jil5
-3-iI11
2 - 00"
2-il06
3 - 00:'
_3- ~,)7
J-011
1-005
4-00&
&- ilO"
6-0iH.
6-~0"

RCVR
AP OGEE
IojAVE REV

HE r;:;H1

°A .~GE

'"

!<M

O.OOH:
52 . '315'1
oZ . 24·}Q
69 , J"2(:
i6.1331
"9.47 .. 3
113.d433
142.55of:
I1J.I0H
133 . 2703
200 .i1000
209.011 .. 3
20'1.68J ..
20~.4300

2u5 d&lS
RCVR

EXIT 10,",
O+JOO GR.NO REf
0 + 000 E~ T K ION
-&-007
-6-007
- .. -006
7-005
-3- Hl RCV~

2G~.OliOO

172 . 6329
117.8':> 20
119 . 5472
3d . "02!)
30.3021:
0 . 0000

52.'3177
l1(1. 1 (i6~
13 d .4~ 'JI

165.6750
I dOl . 5Qj':i
2~O.OOJ':

APfLETml-HART~EE

fXPlZ
MHZ .

tZIMUTH ANGLE OF

ANGL~

OF TRANSHISSION =

AlPW T>i
!lEVIA TI ON
XHT P.
LOCAL
OEf,
OEG

FO :~HlJlA

T~ANSHI SS ION

EXTR:AORDINA iH

11/0517'0
WITH COLLISIONS

4s.000nOD DEG

1t5.DOOOOO DEG

ELEYATION
LOCAL

XH T ~

POLARIZATION

GROUP PATH

OEG

REAL

tMAG

45 . 000
1+5 ... 71
45.552
.. 5.bI4
.. 5 .7 51
45.d73
45. H6
.. 5.d57
.. 3.266
J4.o7J
26 ... 80
4.180
3.110
-0.26&
-12.692
-23."56
-41.316
- .. 50154
- 44"'127
-4 .. ... 72
- .. 4 ... 72
4 4.11 ..
44.599
1,5 .1 03
.. 5 . 0':15

-0,000
-0.113

1.000
1.1 00

,*5.000
- 0.0 aD
-O.O5~
0.000
.. 5.000
-0.021
-0. 000
-0.002
"5.000
- O. JCC
-,). J aoj
-0.000
'l7 . 2010
.. 5.000
110. II8£; ~
-I). 'l 0 C
- 0.000
45.000
- 0 .000
- 0.002
-') . 000
0.003
.. lo.'J80
1311.045"
1&,,0762&
-~. il g
- 0.10&
.. 4.789
-0.001
.. lo.1i1 ..
-J.OOJ
130.6257
- J .'~71
0 . 369
-Jo1]2
II. &07
.. 3.622
- iJ . OO~
700.2014
-0 . J 6 Q
233 .25<;9
-1. 590
40.lo 3&
0.000
.. 0.109
- 0 . J .. c -1.7 .. &
O. OOJ
23~ . 8629
i). 0 Oil
24 1. 0~b9
(I . ~21
-1. 9i12
J9'''3 1
36.11 19
,.; . 24"
-2. 00 1
0 . 000
259.5H9
-1 .4 1 5
34.427
J . oo~
774.371:18
J. HS
21.233
0.00 ]
111.8136
'J . S 47
-0.183
3&'; .;' 6liO
J. '> &~ -0.033
1&.021
~.OOJ
J. 00]
J. <; 7 ~
-0. OH
10.932
394 . 264'3
2 . 976
444.9524
il.004
'J . " 74 - 0 . 027
_ .. 4 . 952<0
-0.027
2 . '178
0 . :; 7 ~
il . OO ..
-o.o~]
<'81, .7 ilbO
J.57&
- 0.025
- 2.t ~ 0
- 0.J22
-'J. 105
3311 .6621
O . ~ltl
3.168
-0.020
-~.oo~
<;,15 .3 574
O, "!H
7.7as
-0.000
~ .5111
9.566
t:Z2 . ':IrJ<;
- 0.01&
-J.OOO
tSn .166'l
0.5 7~ - 0.0001
11.1 '39 "2.~69
(,7& . 0632
0.057
12.376 35 . 811
-0.001
0 . '.>72
12.71',9
- O.OOil
';H .5163
'J . '-''of
0 . 796
2&.'153
Trl IS ~Af CALCULATION TOOK
10.310 SEC

1 .207
1.219

87.6128
':IT.blza

1.217
1.213
1. 209
1.20'l
1.2&0
1 .€:H
2.2'l3
-1. <;76
-1.631
-1. 623
-1.266
-1 .142
-1.041
-1.031
-1.G32
-1. 000
-1. GOO
1. 000
1. C'34
1.1"6
1.19 ..
1.230
1. 434
20159

11':I.b128
139.&126
159.&128
1 'l'J.&126
239.0128
279.b126
295.1649
3 10 601&109
35201649
360.1649
366.1649
4 1 0.6543
4&7.d543
547.8543
587 . 6543
659.8543
&59 . 65 .. 3
715 . 5&2&
791.33CJ2
672.3392
'31203]':12
952.3392
99203392
1015.6617

DE;';

Q.OO OO

52 . 32"0
&1 . 3530

-0. ; 0 ~
- J.~on

&~ . 2802

O. ~ 0 0

d3.it&S'1

- O . 1(j~

- 0.000

45 . 000

'"0.0000
74.&126

PHASE

PA TH

'"

0.0000
74.6128

87.b 126
':17.6 126
119. &126
UCJ.6125
1 59.60 cl1
1 'l'J .10 233
231 . 3102
2&8.91018
278.4396
JO Io. 3962
30603131
3 1 0 .1 892
32 ... 3tH
336 . 837Z
317. &491
454 . 52 1 2
.. 94 . 513 1
566.5130
566.5130
&22.2214
&97.9960
77e.9960
616 . 81 7 ..
857.2445
690.3307
905.3752

ABSORPT ION

DB
0.0000

0.0000
0.0000

o.aooo
0.0001
0.00010
0.0009
0.0021
0 .0 030
0.00106
0.0056
0.0095
0.00CJ8
0.0103
0.0122
O. 0 137
o.01&CJ
0.0 193
~. 0204
0.0206
0.020&
0.0206
0.Ol06
0.02 14
O. liZ26
0.02 36
0 . 02 5 2
0.02&6

z
~

~~~~:~:~~~~!!~:~~:~~~~~~;~~

~

QoOOOOOOOOO~""_"NNNNNNNNNNN

~moCoOOCCOoCOOCOOCOOOOOOCOOOo
~

<:I

o

•••••••••••••••••••••••••••
OOOOOOOooQOOOOOOOOOO OOOOOOO

~

~

.

.~

z

z
,0

~
~

.~
g~

O~~~C40~~M~_"~~~"04~~~~~~MC
OOOOOON~N~~~~N~~Q'~NNN~~4~MO

~

o~~

~~~C~MM~~~~O

"M

_ _ _ NN NNN OC

rOOOOoOO~~~~NNOCM"~~~NCCC4NO

,~

~~

W >l

"~

~
~
~

0

u

••••

••••••••••

•••

•

•

••••••••

O"~cccC~~~cMM~~MO~hMNcNMMC"
~~h~"Mh_N4~~~~h "~~ ~OM404h~
_"_N NNNNNNNMMM44~~~~~~

z

•

z

~

C

OOOOOOOOO~~~~~~NNNNNMhhhhh_

>

~

O~~~~~~~~~~~~~~NNNNNMMMMMMO
OOOOOOOOONNNNNN
__
__

0..

z: • • • • • • • • • • • • • • • • • • • • • • • • • • •

>

·

z

z

0

~

0

•
~
>

OOOOOOOOONNNNNN~~~~~O~~~~~M

~

~

'MMMMM~

~>lO _ ~OOOOOO~~4 40 0~NNN~~~~~~~~
C
~~~~~~~~~~NN~~~~~~~~~~~~~~

=
o

u

w

0
0
0
0

~~~NNN~~~ ~~33~~~~~~ ~ ~~

~ ... _ _ _ _ _
___
__
__
_ _ ~NN _ _ _ _ _ _ _ _ _ _ _ _ _ ~
C~N~~~c~ec~NN~c~~~~cc~ec

__

~

Z~O~~CCOD D~ ~~CC~~N_ ~~ CON~~~~~

u

U4~Ou~

·- ••

~

N~Oc_ooOOOC~~COOC~

... :a:: • • • • • • • • • • • • • • • • • • • • • • • • • • •
~

I

I

••

I

••

,

,

0

z

~

~

0

"

~~O~~_oooOOOOccOOOCCCCONNOCOO
~4 00QODOOOOCOOOODOOOCOCOOOCOO

C 1,01

U

z
0

~

~

~

·
••·

••••

•

••••••

••

••

••

••••••••

••

~=OO~OOOOOOOOOOOOOOOOOOOOOOO~

•••

!z •~
o
z ;• •
~
w

~~I~N _~c cc~Ooco~o~~~oo.~ ~oo o

~

>

I

I

I

I

I

I

I

I

I

I

I

t

I

I

I

~
cN~e~NN~O~G~~~~~~_~_O~_~~C~

~

~

O~C~~N~~~~~~~NN~ _ Oe_N~ _~~ O~~

~~~ON~~~~~_~~~~~~N~r~~~~~~~~~~O

0<..)1,01

•

•••••

•••••••••••••••

' , '

•

•

•• 0

"'CQOOOOCOOO~O~~~~ON~~~~~~~~~~M.
.O~~~QD~~~~N I
'M ~Q.~~~~.~~.'O.G

~~
;!

, , , ,

I

I

,

COOOO~~~~_NNe~~OO~_~~~~~~N

"0

~COOO~~~N~~~N~~~

_ _ ~~~ _~_ Me

oCCOC~~ · OM~GGO.~~N~ ~CNo~~ ~~V

• • • • • • • • • • • • • • • • •• • •• • • • • • a

w
~

OOOOc~~~~~~~~~ee~~~

_ o_o~~oo

0

·oo.

I

~
z

, O'O~~~'~'~I~'~~r~MN

_

__

NNNM~

z

OOOOOO~G

~

~4~

0

=

~o uw

~~ oo

N
<

0 >"

_~NN~

~~~~~~M_~~

__

o

~'"

OOOOOOO~~~OON~~~O~~ON~ ~ OM~~
OOOOOOOOG~~~.O~~G~~OC.O.N~4

....... .... ............ . ..

OOCOOOOOQ~~~~

I

,

,

,

,

.,'

~

•
__
__
c~e~
_•
_•
_ ~~MMN
______
<..)

z<

.
~

QOO~WQ~~~~I~NO~M\~~ ·, _~h~~~a~U
~

ooooCO~~~~~N_G~o

_l

o~~MI

__

~~~ ~' :~~ ~ ~ ~~~'~~~~~~~~~~~!~~=
__
,

oooonooOO"~OO

•

,

,

•

,

•

,

,

,

,

,

,

M~~C~~~~_~O~

,

,

,

I

•

I

,

•

,

,

••

._

_~

__

g

~

·

0

N

~

C

t

..
.,

O~~~O~~.~N.oorO~~.NO~N~~

-

~M~~~O~M~O~~M_OM

"

W
0
0

__

!,oj

O~N~~_~~

w

~

CNN~~_~UN~~.~~O_~~O~~O~~NO~

.'

~yc,~~~~~~,O~.~

7'1:
~

•••••

~~~~~~~~~~_~N~~~_

•••••••••••••••••

~~NOt~~NU~NNN~~~~~~_g~~

O~N~MM~~40Q~~_~O~NN~CG~

M~

__

~O

-

•••••••••

~
~

y

••

••

••

•

•

••••

••

•

•••

~N~~~~~I~O~~~_.O~~~OCN~~_~C
~~~~c_~~~NNNNOC~ _~ N
~~ _ ~~~

_ _ _ _ NNNNNNN _ _

"

_ __ N

Z" Z

<

~ Z

~.

~

>

~~

•

~U

__

_ ~~~ _ O.G~~NO~~N'O~~~N~C

~

>

••

O~~~.~~N~'~o~.~~no~~~~~~~~~oo

X

w
Ow

•<
.Z

•

~rn~~~

0

~ X

••

• • ~~~~~N~gQ_ ~ ~~M
._ _ _ •
_•
__
_ _ _ _ NNNNNNNn~
~~.~~ _ M~~.~~C_

Mn~~~~~c_~

.>

•

z

_I O~_~~~~N_

>

>
U

- •·
>

..

Z
u

CU~
~

U"

>

u

O~OQ~~

~

..

.z

~ ~

~

> 0.
z >

~

"ow

.,>

0>

~

U

~~%

~~~~314~o~~~,~c

Oooooo~ooaoooaOOO~"OO

~

_ _ ,n.n~g
__
CC~o

o~~Oaa~aOoOOcOOOoO~~OooOoOO

..............
aoaO~

,

•

I

....

_1140~

I.

,

,

175

,

I

•

,

,

"

___

,
M

....
O

I

_4

"

,

....

,

,

,

,

,

...

NNO~~M.t~

,

I

'"

,

<0,

WAvE

il iF OLY
n~O U ('lt y

E: ){PZZ
6 . COO~OO

F LEV~TIJN

tiE I GH r
Oi 000 )(HT R
uiODa [NTR l Ot- J - 0 11
-3-011
-2-0011
-1-~07

....
....,

a-

1110517r.
APP LET ON-HAr..TREE FORHULA rxTRAOROINARY wITH COLLISIONS

TES T C ~ SE

CHAP)(

-9-007
'+-007
3-00:'
O+OilO RCIIR
6 -00 5

I- DO ..
1-004 APOGEE
9 - 0H lIol II:; RE II
5-:10$
0+000 RCIIR
2":"10 5
- 2-0015
- l- a O£>
-1-00 &
-1- 006 ExIT r ON
OtOOO GR N" REf
0 +000 EN T~ I ON
-8-00'
-6- 00&
2-005
4- 0J5
-3·011 ~CIIR

'"

O. Of.iJO
52 .9blt b
oO.71b~

65 .5~"' ''
87 . 785~

IJ7.1 217
1 2€l . 455tJ
1 .. 5.£>921
17d.77 37
2)O . J O)(
2210 . ~1o .. C
230. 7 "if>
230 d l S 3
2loJ .25 9;;
222.0226
200 . 000(0
161.ob 'll
129.0135
')S.7312
n2 ... 97/o
23. J;, 2 C1
0 . 0000
52 . 96.1b
'17 . 0257
lZIl . J0 97

1 53 .37 H
la].o}'1l ~
200 .0 0~L

f\ llrl(,E

'"
O.
Il
1 ... 0 7 5 9

~ ....

z, AZIMUTH ANGLE OF TRANSMI SS ION
IoS.CDooaD OEG
OF TRAN S MISSION = H.ODOODD OEG

~NGL f

t Z 1 t' u TH
il [VUTJON
nlHI
l OC Al

l(MTR

OEG

DEO

;:lEG

ELEVATION
LOCAL

':,)0

75.0,)0
- il . O DC
75.000
10 .11 tO
17.3H8
- 0 . CO 0 iJ
75.000
-O.DOL
75 .0 00
23 .1901
-,J . u DC
75.0')0
Z e . 2 1 Zit
71t.9'}9
- 0 . 00 1
J3 .20 25
- 0.007
3e .l'+ 96
74. 9~"
- 0 . !1 £>2
7 ... nO
.. (; .6 08 1
0
.
Ho2
52 . &IP5
'''.7d3
-1 • ., 77
74.379
00 . 6£>'15
1;)(;, 1025
-1. 7 11
73 ... 32
-1. 511
73 .111
o ?55G ..
- ')'~22
72.J07
'0. 76"1
1. ; 1,3
68 .50e
~ .. . 262:1
01.084
100.62<;7
S . 5 ll
3 • .,,.2
,,9 . 25&
1 3/0 .6131
10 . J 9 2
J8.6&1
1 'j5 .6~6"
11. ~I! ~
In. Ide s
27 .405
tb.'t63
19G . 950d
12.?2~
1 2 .192
- 6 . ~56
1'>.551
~20 . 990S
? .. C.75b9
13. <;':>7
- o.ZcU
-1.0 83
2 7 b . JIo 1; J
1" . ]7 ~
- 5 , "1 ~
9 .5 65
I/o. 7 6~
- 5.'165
1/o.7 d5
?qb . e Io 6 ~
-,. .72 1
16 . 9 .. 6
1'.; . 12 1'
l2e . Sllt ..
-4./0 25
22 .35 3
1'> ." 2.
310 " . 0&2 4
2 ,..q15
3E-Z . 9 J72
15 . " 7';
-". 2 14
J7 .... . 35{:7
1 5 .7')"
l5 .9H
-l. 6 ""
THI S ~A' C Al CU L4TI ON TOO K
- 0 . 00 0

-0.000
-0.000
-0.000
-0. 000
-0.000
O. 000
- 0 .012
- 0.32 1
1.3310
1.370
-7.3':10
-8. 853
-11.181
-110. 20&
-13. 5 43
-11.276
-9.7510
- 8 . 5&2
-7. &20

OEG

PO LA RIZ ATION
REA L
IHt>G

75.000
75. 1l7

-0. DOl

75 .110 5

- 0.0110
- 0.00 II
-01 . oo~
- 0.000

75.156
75.209
75.253
75.279
75.166
73 . 849
71.357
52 .074
15.5&9
8 . 2l1
-10.10 74
-29.337
- :'&.1075
-55.293
-56 ... 07
- 5& .2 82
-56.0810
- 55'8f5
55.706
56 . ~27

-a.allt

-O. OO~

- o. aDol
- 0 . 000
- 0 . 000
-0.00 0
:1.000
J. 000
iI. 001
!j, 0 0(1
0.000
0.000
J. a a 0
0.0001
~ .001
~. 00 J
- 'J. 00 a
-3. 069
-11. 00 1
-!l.000

56.231
56 . .. 0 b
55. ~O ..
- J.ooa
- 0 . 0 00
51 . H4
-0.000
45.37&
').&24 SE::

1.GOO
i.IlZ]

1.0410
1 '(l107

1. Glt6
loIl47
I.C4£>
l.tllo7
1.057
1.067
1.5&8
-9. 825
-J. e 7&
-1 . 95i1
-1.143
-1.0210
-1.007
-1. (j0&
-1 . co£>
-1.00&
-1.000
1. 000
1.0b4
1.134
1.1-JO
1 .13'>
1.19,
1. l710

GRO UP PATH

K"
0.0000

SIo.0371o
62./lJ71o

67 .11 3710

90.83710
110.il371o
13006374
150.637"
166.a37"
213dl81
2&& . 9181
306.9161
314dl81
330 . 9161
376.9181
10310. 96 73
491.9£>13
53 1 .9013
571 . 9673
1'>11.9673
&51 . 9673
£>67.41059
7~1,"563

792.10563
IIJ£' '' ~ bJ

872 ... 563
HZ./oS63
937.9,1'

PHASE

K"

PHH

48S(lRP T ION

0 . 0000

08
D.OOO O

510 .837"
62./13710
67.63710
90.6374
110.6365
130.8161
150.£>143
183 . 5011
202 .12e"
2 17.2922
220.0213
220.4&73
221.5762
228.5 798
2 109.21"7
291.7604
330.5977
370.5601
410.5600
1050.5600
1066.0386
550 .04e9
591.01069
bJt.OJ.,b
&70.52(,0
705 .8795
7 2 2.6911

0.0000
0.0000
0.0000
0.0001
0.0005
0.0013
0.00 19
0.0030
0.00"6
0.0091
0.0127
O.Olllo
0.01" 7
0 .01 81
0.0232
0.02&3
0.0275
0.0289
0.0292
0.0292
0 . 0292
0.0292
0.0293
O.O JOJ
0.031",
0 . 0327
0 .0 3 103

z

8

~~~~~~~~~~~~~::~~=~=::~~:~:=:~:::=~~~=~=~~::::::~~

or c

• • • • • • • • • • • • • • • • ••••• • • • • • • • • • •• • • • • • • • • • • • • • • •• ••
ccocccccccoocccccccoccccocccccocccooccooooccOcoocn

~
COOOOOogcoCaoOO=o=OOOO=O=O==== O= O~~
~m==O=O=OO==ODOO=CCOC=CCCOC c =cc= ==Occ

.
~

_~_ NNNNNNNNNNN"
=cccccoccOccccc

o

.-,."
,

.z

r

~~

4

o~ee~e~eee~~~ee~NNo~ec~~~ _ ~Me~~NN~N~eOM~~~~ ~_ o~cNu
COOCOOCCO~OCOOOOO~~~_N~~~j~~~~~ ~ OMN ~ ~N~~~~~ ~ _ _ MOO~

~

c ~~~~~~

~~~~~~~4~~MM~MN~~~O N~

~~C~N~~M~o ~~M nn~ ~~~

_

o~

~:~~~~~~~~~~~~~~~~~~~~ ~ ~~~~ ~ ~~~~~~~~~~~::~~~~~~~~~~~

-- ""
•

W

ON6~N.~~~_.~~.~.~o~~o~eC~~M~C.hNM~~~~nCNNNo~onnNM~

___
______________

r

~

0

~~~~~~~~~~~~~~~O

NN

~~~~~~~~C

__ " __ _

N~~N~
_~~
N~C~~
NNNNNNNNNN~~~~~~~~~~

"

~

o~~~~~~~~e~~~e~~~~~.e~e~e~e~~e~~~eee~ecocac~~~~~~c

_ ____
_ _ _ ___
_ _ _ _ _ _ _ _ _ OOCCONNNNNNN
• • • • • • • • • • • • • • • • • • • • •
o~¥ON~~N~~~~_~~~~~~~o~~o~~ce~~e~h~~N~ce3~_~e.~N~~~~~~
__
_________ ____
OOOOOooooocoooccccaCCCOaOaOcO~~~~~~~~~~~~

~

o~~~~~~

4

3~~~~3~~~~~333~~3~

___

~~~~~~

~~~

~

~~~~~~~~~~~

~

~~~~~~~NN~N~NNNNNNN~~~~~~~~h~

!z

Q. :II:

"~ ~

• • • • •

•

• •

•

• •

• •

• •

• •

~~~~~~~~~~~~.~~O

~

• • • •

• • •

• •

• • •

NN~~~~~h~a~~~~
~~ _ ~C ~ ~N~o~eNM
NNNNN~~~~~~~~~~~~~~.~

~

;
w

~ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ __ __ _ _ _ _ _ _ 3 ~ _ _ _ _ _ _ _ _ _ _ _ _ _ _
.... ,. ...................... " . ........... . .. .... ...... .
Z~oo
_ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ NNNN~
~ ~~_~C~~C33~ocooaoca
O~N~~~~~~~~~~~~ecee.~.~~~c
~ C~~N~~~~mON N~Oc~~~~~~

0

~

,

;
•
"
'"w

~

",
~
r

"

"

;; ~
w

_o oooc~~oaaoo

;!

,

I

,

,

I

,

,

,

~~~~~~NNN _ _ _ O~~oo~~ooaoeoe~ooo~6oe~ooaOOON_~~OO~OO

;

~;~~~~~~~~~~~~~~~~~g~~ggggg~ggg~~ggg6ggg~gggg~6ggg~g

0

<;

OqCo~coc~ao~aaccaOac~c~coooocoocu~ca~~~

~~~~~~;~~~~~~~~;~~~~~~~~~~~~~~~ ~~~~~~ ~~~~~~~;~~~~~~~
,

0

,

,

,

,

•

,

,

,

1

,

,

I

,

I

,

I

I

,

,

,

,

•

,

,

,

,

,

I

I

,

I

I

,

1

,

,

,

I

I

,

,

~

0

~

~

oooccooocccoooooaaaaCO~~a 3
~

MO~~~~~OO_MMM _ C~~~ _ h_~~M

coooeoococoaCCCOOOOCOO~~~~~hOh~

_

O~~~M~

OU,,-,

••••••

•

•••

••

••••

••

••

•

•••••

••••

•••••••••••

3~

__

I

••

••••

•

•

•

I

,

,

,

I

,

,

QOOO~o~o~oaoancoa

0

.

.. ...

.

~

oaO~~~h~~N

............ -

.

....

_~

~~~~~~~~·ON~~~N~~

....... ....... .

_ _ .~

.......

.

' 0

0===oooo=ooc==oca=coc~~~~~~~~~~~~~C~h~0~.~=~ah_~40

?-~-~~~~-----~-~--·--~~~~~~~~O~_~~~~~~~~ON

'~ ~~O"·"_

r

"

o

z

z

~~a_~~~_occ~aooo=oo~oaac~cooocaoc~~_

~~N~oc=a=coooQo=c=ooooeocccccaaooco_
~o~~o=acoooooo=ocoo=cooc~COCoa==o~ o~

.. . . . .... . ........... . ...... ...... .
777h
' 77:777
'
~

"

Z<tl!l
I:OUW

~~

"c

~

OO

c~~~aOOOOOOo==ooocc=aooao=aaaaaaoao~

i.':;;~

I

~
~

,,

..

,"
•
;;
w

.;

"
~

0

~

0

z

.:.

<w'

3~~h~~~~~ ~~~.~· ~~~~~~~ ~,~·o~~~~~·~~.~"r

r. ~ L'

~~ ~ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~:

~ :;;

~~~~~~w~~~~~w~~~~ 'n ~~~~~~~~~~~~~~~

,

,

~~oo=~~oaoaooc~oC

,

•

__

,

,

,

,

,

,

,

,

I

I

I

,

,

,

,

,

,

,

•

,

,

•

,

,

•

,

,

,

,

~~~~_~=~~~~N~~~~~~

O?oooo=caoooaco=0=oa~OU_~~ _ N~O~~~D _

'« '"

~ W e ' : ' 0,,", g Q O 0 0 < : " ' 0 0 > 0 0

QOO c o o 00"'", 0 0 '"

<> OoN~

_

~M~~~~~o~~~u

~~~~~~a~a~O'~3_

~

~

or ~~ ~ N<1'.,.., ~O'" j

"'N
_N~"'~~~~"' ~~~

O~~_C~~~~~~~~~~~~~~~~~~~N~N~~O~~~4~~_OU~4~~~~~~ON~
~-_~O~Q~on~~OC"O~_~~·~~~h"''''~O_O~~~~~'''~DO~hM'~~~'''j~C
~

=~~~~~~ ~~~4~4334~"' M~M~~~NN~~~O~~O~~=~~O~~~~Q~~~"~~

~~~~:~!~!~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~:~~~~~
w _"'IO",~~q~_~~~~~~~a~.a~~O~h~~No~ ~=~~ ~~_o_NN~~"'~''''h~
~

~~~~~ · OOO~"'~h~~~~ "

• • NN~~~~
<t'O
_ "'M"'M"'~ NO~ _~'"
_ _ _ - • • ~~
___
"'N"''''N'''NNNN__

_-_~

y
0_

.,

T;:",

< w r

_ ___ __ •

>

w

">

>
>

aO~~~.<t'

~~.,~

......

~

owo

.0

~

>

~~ND~~
_ __

.. "
-.-z_

>

•"

•w

;
___ __ _

...

>

. . ; ;e.

w

•

w

.~

o

>

>

">

_0'

~
~

>0

0

•

h~O~~~I~~~.

_

~

.. .y7.

0

•

• .,<,!I •.,
'n~·n~

_ _ ...

~~~~

~~~~~~~~~~~~~~~~~:~~~~~~g~:~~~~~~~~~~~~~~~:~~:~~~~
..

,

•

,

,

,

I

,

I

,

,

,

I

•

,

,

I

I

I

,

I

,

,

,

I

I

I

,

...

,

I

,

,

I

,

,

,

,

,

I

•

,

,

I

O.., ..,M ~<t'~~~~M~O~NM _ N~~ ~~3~MMNN_O~..,3~~N~N ~N _ NN..,~

,

,

I

I

,

I

,

,

,

I

,

,

,

""

177

,

,

y

~~Og~voo=uao=c~OQU~UOOMN_~~Q~N~U_N=MU~hNU~M_4_NM_~

.~

~

.....

~:II:~~~~~~~~~~~~~~~~~~~~~~~~~~ ~~ ~ ~~~~~ ~~ ~ ~~~:~~~~~~~~~

"

00

~~

!!!!!!!!!!!!!!!!!~!!!!!!!!!!!!!!!!!

>

~>
."w
"r

I

NN~~~U~~~~_~~~~~~O~~.~~~~~~~~~~~~~~U

N>

i

•

=oooaooo~ooaccaoocooo~~~~~~~~~~~~C~~~~~h_~NNC~~NM¥

;0

0

~

,

~oaoooooococcc=coaoooe~~~~~N ~~ ~~~~~~~O~C~~N~M~~C~

~ "w 0z
"" "
~

~

~N~VMh

~O Ocoocccooooaoc=cocococa~~~~~~~~ ~~~~_M_~~~~ ~~~~~~~h~
~ ~
~~-~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~_M~~~~h~h~~hhhhh~

;!

""

_ _ _

zq~ooaaoooo~~OCOOOO~OO~OO~~~~~~~~~~N~_Nh~NO_O~~C~~~~N~

,

I

I

,

,

,

I

"

I

I

"

I

I

,

,

..

_ N~~O

"

,

_

,

~

~z

'0
~.

,.
o~

- 0"
u

=

•>

·
·~

z

0

«
~

~

~ •
u

~

Z

0

"

~
~

«

~

,~ "">
z, 0
•
z ~
0

··
~

•~

z
z

0

>

z"

,
0

~

·
0

«
z

~

~

"

"
""

·
· ·•
·•
N

"

"0
"
0

W W

~~

~

~

z

OM

_

~C_O_N~MQ~03

_

QN~

_

O OOcOO UOOOOO~OoOoOo O

. . , .... ,. , ........... , .....

OO~O

__

O

_

~NON

OOOOOOOOO~OO

•U
M
W

;

~O MO OO~ _ OOOO

"

__
O~

oNN

C

=

_

NN

_~N

OOOOCOO

_ _ NN
~~OO

........ , .. , .. , ..... , .. .. .. , .. , .... , .. ,

~OOO~O~OO~~~OoOOOO~OO~~OOOOO~OO O

~~OO"OO ~

OO~o~oo

_O OOOOU~OOO~OMO~MMOO~~OOooooONo

~OO~O~~~oooe~ooooo~OOOOOO O

~N

_ ~

_

grN

O O~OOOOOO~OOOOO~O

O~O~~M~~OOONMOOOOO~OOOOOOO~ _ ~NOO~~OOOOOOOOOOQ~O
OOU _ ~~N~OOo · ONOoooooooooooo _ ~N _ oo~oooooOooooou~o
UOO~OOMOUOOI _ OOOOO~OOOOOOO~ · ~~~OO~ · ~OO~OO,OO~O · ~ ~ ~
~O~~O
~O

_ ~ ~OOOM~OOOOOUOOOO "

O~

_ ~OO_~~OO~OOOOOOOOO~OOO

' A~~D~O~·~OOOOO . ,OOOO~~ O

_ .~~~~~.~OOOOOoo~oooro

- ·· .... ...... .. ..................... . .. . ..... . ....
-.
. Z
U .

>

W

~
_z

oU

"

OOM~o~~~caao~aaaoocaccC~CM~~~~oC~coccaa~aaQOO~O
~O_NaMa~aaoo~oaoo~ooOOOO~ _ ND~~ oo ~~aooooo~~ooo~~
~~~Mo ' ~~

_ ~ao_~ooooo~oooOOOeM~~~

?O ~~O~OOO~O~O~O

OM~~O~~~OO?~~Oooooooaoo~o~~o.~~o
7'n

. o

7

~~

_N~~~

-

NNM

--

~M

-

~

---

~NN

-

N

-

~

7

~

7_

_o~ ~ooooo~o~o

~M~~

_

N

___ _

~

M

_M
~~

__ M __

__
__
__
_ _ _ NNNNN ~~~~~ • • ~~~ee~eee~aooo~
' ~~~~~o~~~~~~
______
____ NNNNNN N

_

~~CN

M.~_NM.~~~_e

178

NM.~~

NM~O_NM~~

NM~~~

z

Z

o

OO'O..D ...... c:>O ......... ."

o

CO ..... .... 4'4'."fOO

OC>CC>C>NNN~-4 ...
...
c::>O ........... N"'NNt\j",
o..<l:)ooc>C>oOO<;>OCC>

....

0 0 . , . , . , .......... '"
0 0 0 0 0 .......... ""

co: 0
o

COOOOOOo;:lO

0<'0'

o

.~
~z

CL-a)oooooo<:>oo

••••••••••

..,<;;><:>000:;><:>c:>000

~

~

~

~

z

z

~;:

....

o~

0

00"...,.000"0''''(\1",.0

'" .......... .

...
~

O " ' ........ CI"' .... ., ........ O

.... :z::e>"' .......... oD"''''''''''CI

-- ""

.~

0
U

oO ....... O"""' _ N
04''o£)<D ' " 0 4'''''''
:1:0"' 4'4' "'C>_ .... ."

Wlo( • • • • • • • • •

O~~~~~~::;:;~

""<l.r

...

O . . , " ' N N N " ' ....... ,.._

...

<C

oO'NNNNN ... OO'"

...

0..

O"'CQClC"""'C7'C7' ....

.......... ..,"''''-

0 . / ' ' ' ' ......... '''0' ........

.....

. . o N " ' " , ............

_"I'''''''
'" "'.0<:::1 C>..,
__

J:
0..

O ... N"'ONC>,z ....

~

... .0.00"0 .... " ' ' ' ' . ' ' ' ,..

""

Q.

•••••••••

~

.. 'o£)<D"'<:>
_ ...
.... 4(7'
_ ...

L
~

z

•
>
••

ONO'C7'O""' ............... O
0..:1: • • • • • • • • • • •
::>"'c;> ... C>C>Naolt\O ...... . ,
(\I ...... " ' ... "'C>\I'I"'CI

" "'
~

o

0

<.!I

~

0

~

z

... ..,OO..,..,4' .......
<:>"' .... NN"'..,..,C;O

C

'''''' 0 ...

a.
0 4 ' ' ' ' ' ' ' .....
0_00..,.., ......... .,.
a. J: • • • . " . • • • •
::o:ro:O~ ......... ..,NO ...
o
a-.,../'.,.0<1'f1'4'

.... "'oD<D_N4'f1'

(J£

. , ..... " ' ' ' ' , . . . ' ' ' ... 0 0 , . . ,

<!I

...... _NN"' ............

...... _ ...

0

<

~

~
<

0
0
0

"
"~ •

~

0

"
,""'

:;;

~

~

,

L

Z
0

~

r

0 . . , ...... .... 1 ' - 0 " ' ....

""

""

.0;

"""

'"

0

co:

"" a-O"O"'''',,"'''

I

I

~

,

. . . . . . . . . . , " ' .... .... 00<::1

"

,,

c:> .... O O .... e)CI ....

"''''c

U

...J

o , D o o ....

4...00_0<:>01'-000

, ....,

a.~o..,ooooo

:.l

Z " ' . . , O . . , , , .......................... ON

~

0<.)\01

"

"~ "
0

",
;;

o-...J

N

C

Z

u

~...o

I'

I

, -

>

%

o

0 ..... "',z.., ..... ~0'
0 ........ "'""",<D",

"~
W ~ ~

oa- ... .,O'4' .... a-:roo:

<w

•••••••

_0

"' .... N .... -, .....
.............
, ./', ...., ...O

_0

~,;,~~,:,::~~~:::e
,

'--'_'0

_ ...

<

w

"" ......... '" 0 '" 4 4 .... '>t
• • • • • • • • • ·0

XO

.... 0 0 ..... " ' 0 0 0 " ' 4 ' ' ' ' 0 .

""

...
C> ' /'I " ' ........... .0'" ... '"

"~

o

.... _ ,

",.0 """' .0"'''''''

0

,. . ....ZW..,

z

,

Z

Z

o

u

.... o-:.

oo oooo oooo~
~

Z< 0

rou .....

~

· ~./'J

. . . . . . . . . . -,

"

0 ........ .......... 0 0 0 ......
0000000000""

" ~"
z<
N>

C'>t\.t\. ..., .., ' " "" ..

41"'~

OClOOOOOOcCl

"
"~ "

Z<~

Z<

,.., .-..u

zw
xc.

"

<

<,,~

~",~,,,,,,o,€O'a-<'

c ...... _ 4' 4'
'"
"'oOOc,""coc,"
~

'::C:O:;':; ':':~":!;

0 " 0

,O

C.,
... "' ....
co ........

'I: 0 u ....
....... 0 0

, , ,

o

....... o ..... ...
N...,O ...
OOC04
" • " • " • • "...0
00000<:>00::::J
,
, , , ' U

0~C"~""0"'''''''.n_

"
=
"
<

"

W

z
N

o u . . . . . . . . . . . . . ...

. . . . . . . . . . . ....

<
>

"

-'

.... OClo ... gOa ... o .... c o o .

~

c:>

o .... oo"'""''''oDQ
O ... OON ......... "'OoD
Z4.<.!)o oDOO"'''''''''' 0""

...,,..,<:> ....... <:> ...

~

W

,

..... 4 . 0 ... 0 0 0 ' " " 0 . . , 0
OW , • • • • • • • •

...... " " 0 " ' .... 0<:1"'0(0'0<:>0

o

...... ,., ...... .............

~

OW· • • • • • • • • • •
O:YogOOoC'>,=,Oco,""

o
o
o

-

Z <!IO"''''''",,,,,,,,,,,,,,
OqOM4.l..tOOI(>Q"\
....:1: • • • • • • • • •

.. ...JoC7'OOOc:;lc:>..,OOC>

W

o

Z
0

~
<

..... o c", ... C. ..o","' ....

Z"-'ONNNC7'C7'O ... ...., ......

.... :l; _
•
•..
•_
•_
••
••••
•
......
_
..............
_13'

O ... .., .... , ..... oI.IQQ>iJ .... ClM

0

••••

, ,,, ,

,

"

••

'4

•..• "'<:oo~n"='OfY

C'>~,:>o",o""O'Olo'"

0

<

~
N
N

•

~

~

". 1:

0<:> _ _ (7' .... "" .... ..,"" "' ...
<:> .... .n ;:) .......... .., ..... (7' oJ' ~
4'O~ ... :ICI

c""
'I' ..............
'01",_
""",,"'''''' __
•

•

•

•

~

•

•

•

•

•

0

••

-'

~~~c>~,I"~

~

__
_ 17 · "' ... ..;<:>4"""".;0

~'>t<:>",

Q'

C4'4'./''''a- ... ..,

...
">

•, ~ • .3_ ': ·r ... r...,

....

<!I

c O _ _ I'-'I),J'ooD

?':I:

•

<>.lo(~

It'

"

•••••••

"'~~""",,,,,,,,,,,,,,

..,CQo .... _ c
... . ,

.... --""""...,..,..,~

~

~

"

· ""
0

0

" '"
">

•

ur

,"

.

,

<
_z

~U

W

~

'~"" <1'oJ'""",o "''''NoD

"" .... ·0"' .... ..,0.., ..........

J:
c .... 44'_Nc~<;lClo;:l
<.!):r",(J''''' _ _ NO(J'''''''''7'

... :roo:

W
:

• • • • • • • • • ••
o .... 'C""-eC"""N ...... 1'..... .,;":::~4'
-l':=;:~
"" _ _ >.tlo.;;!:
> ...
::0 ..... ..., ... 0 ... 0 _ ........

_ ...

_Q::_,._~O!:

:::..,
<1::11:

...0

WI-:::Ieo.

...

Q

"" .... ,.." " ' .... ..>

. ,, ,, ,, ,, , ...., , .

z:-

w' 0

o"''"'-t/'....,O~... <D
r
~.., ... ..,oD .... O~'"
<!Iro "' _ _ 0'"'0 '7''''
.... lo(

••••••

•

_

•

. . . c"""" .... N'CO"'"N _
1:

"' ~~~~

\.... ~

OI: _ _ >;;!: .... "" ...

0 '1'1 ........ 00.;0<11
..._
... 3:_"' .... _

':)
W

...... zz> _z ... ><>z
rz .... ""><'Y~""""_
>< '... II: x: ~ .... <!O .... II::S-:I:

....

.. ~~ C'> ........

>
0

z

~I-

o ./'.., .~ .... .D ..... ~Q
' = ' O C O " ' ........... ....

fICO!:

00

,
W I-":lOC

z
""><tr:>:_
>< ... r.::r:J< .... <!I .... :I:;

...... 2:Z>_OI: ...
1:Z _ _

-.0000000=>00

~C ....... o"'Q ... O
00_"'''''''0'0''''0
"00000"'<:>0

0"""'"" <D ""c <:> . . . . 0

0 0 ...... "1 ... 0 " ' 0

:;:::::::;g~:;~~g

179

+ •

, ••

"

, •

,

, •

,

11105/71+

TEST C",S<:

'"'CHAi'X

W.l.~[

JIPJL'f

APPL[TOtl-HA RTREE FO~I1ULA ExTRAORDINARY HITH COLLISIONS

f XPZ 2

0.006JOO MHZ. AZIMUTH ANGLE Of

FI'IECuEllCr

fLEV~r I JN

~Nr,l~

OF TRANSMI5SION

"5.000000 DEC,

T~ANS~I SS I ON

=

30.000011~

DEa

il.21~uTH

DEvIATION
ttEIGHT

3- 011
0+000
0+0,)0

"

~ 'nR

ENTR ION
NIN 'JI'; I

O+JOO MIN (JIST

.....
00

0-010 \oI",VE REV
Z-'liI5 E~ IT
-3-011 GRrlO REF
1i*IlOO UH~ 101\
1i*000 l'1IN JIST

'"

:l . } 0 C~
52.'373<;'
l'H.Sb .. l
191.5b41

Fll.40':';o,
"d. 7 3:;~

O.OOUO
:'2.Q711
UY.:\217

0

~A ~ GE

" 0 orie
~.

~HTP.

,,"

1\9.<JOtu

- C. COO

354. '14 (HI
3S4 . 94(d

- 0 . 023
- 0 . ~ Z 3'

3~8.1Gb5

- O. OZO

[l[V ATIO tl

LOCAL

xrHit

OEO

DEG

-0.000
0.21'3
O.2B

30.000
lo .HS
26.3'18

o*aOG
0+000
-3-011
2-00:'
3·JJ.,
3- 0 11
a-DO"
0*\100
0*)00
- j-HI

~MH

E'I TR ION

'"
:;;2. "I75Q
0.0000

~';VR

2iJ~ . OOOO

APOGEE
.u .... E. REV
RCVR
EUT 10'"
GR."'O REf
ErHR ION
RCVP.

2J~ . c8j4

2~q .43 "O

2ilO.JO\l1i
36.3020
J.JO)O

52.9717
20U .,) 0\10

30.6(1'3
0.000

PGLAiHZATICN
IHAG
RElIl

- ,:; .0 aD
- O. HZ
0 . 000
0 .000

0.000
-1. J95
~. u0)
26 .154
0.03,
1.406 -26.'H5
~ .357
t;41o.46e1
-3. 29'3
28.17 3
-J.OOil
i3l.Quao
"). '. O~
2Q.0103
-Q.271
~ . ,.Iot:
-;).308
-0.1 0 10
~3Q .l H2
0.000
J . r; 1~
0.454
10.581
O. liD 0
1107.5272
THI::; R41 C4lCUL4TION TOOK
iI.113 SEC
0 .137
-0.3'37
-0 • .14'3

ELEVATl)!\. AN;;Lf OF TR:4NSMISSION

HI:. IGHT

LOCAL
OEG
30.ol00

4,IMUTH
lJEVU TI ON
~MrR:
LOC Al

=

1.000
1.25<)
-1.0;30

-1.530
-1. 4 75

-1.013
1.coa
1.223
-1.771

JEt.

DEO

~ ,'1TR:

DEO

KH

D.ooon

PHASE

PATM

KH
0.0000
104.6686

ABSORPTION

DB
0.0000
0.0000

10 ... 6686
1025.79210
425.7924
r.2'3.7nr.
770.7n4
872.6850
963.3256
1312.1:1736

ItO O. 'H>14

c..ooel

40D,qUlo
1003.6'31'3
720.51057
822.10383
933.0789
1240.1070

0.0062

GROUP PA TH

PH4SE PATH

ABSORPT ION

'"

08
0.0000
0.0000

0.oti65
0.0177
0.0177
O. 0177
0.OZ59

45.0GQOOO OEG

ELEVATION
POLA~IZA TION
LOCAL
DEl;
~EAL
IM.IIG
K<
- (I.OO·J
1.000
105,.000
c.oaoo
1.100
45.471
- ~ .113
- U.C~O
-0.000
45.0JO
52 .324 6
-0.000
2.293
-0.132
.. 3.622
28.480
200.2014
O. '" 07
\1.00 ,)
-1. e3 l
.. 0.lQ9
3 .110
-'J. :iltC
-1. 740
,,35. bol~
O.OO'} -1.t23
J. -)21
-1. 'H2
39.1031
241. J"Ie~
-0.2"6
-1.1102
34.427 -23.45£>
\I.OOil
J ..~8<j
-1.415
?74.3781:1
0.004 -1.000
2.\178 -'+4 ... 72
.• 4~.9524
0 . :; 74
-0.027
-J. OO )
-2.1 :10
44.114
1.000
JoSH
- 0 . \125
4e4.7J6il
1.091,
-0.105
-0. 022
3. b8
104.5099
I:. J~.c621
O. '.i 71>
- 0 . 000
2.159
12.709
26.953
t<> 1.51cj
0 . 5 .. •
O. '90
TH[S R~1 CALCULATiUN roo~
".013 SoEC
R: 0\, 'I GE

GROUP P A' H

'"

0.0000
74.6126
295016109
352.1649
360.1"49
410.8543
659.dS103
715.51'>26
7Ql.3392
t015.j617

0.0000
74.6128
276.~398

~.OC58

306. J131
310.18'92
H€;. 8372
566.5130
622.2214
697.9980
905.3752

0.0098
0.0103
0.0137
0.020"
0.0206
0.0206
(). 0266

<01

TEjT

C~APX

C~~f

W 4~E

11/05/7'.

0 I PCl Y
FRi:..OlJE,ilY

6.0QQ,JOO Hill.
ELl ~ A TIJ ~

liE I GH T
0+ 0 00

o+oao

-00

O+ (j 00
-1-004

XMTR
HHR 1 0N
RCVR

AP OGt:E
WAVE i?EV
OtOOO RCvR
-2-~0 7 EXIT lON
OtOOO GRNU REF
-3-011 EN I R I ON
Ot-OOO ~CVR
-1- ~(l 1t

K"

a .D OOG
52 . 9He
200 . 0(;oe
£25 .83 32
225 . 83.i2
2uO.OOJIi
26 . 77 :; 1
a.OODO
52 d8 Ie
200 . 0 00 0

APPLETON - HARTREE FORMULA EXTRA ORDINARY WITH COLLISIONS

, 'IF l2

~4 ~ GE

K"
C. GOQO

~NGL ~

OEG

OEG

HEIGHT

q /l~ C.E

<"

K.'

O .~ OOO

";2 .9 Slob
200 . 0000
230 091<:13
2J~.l513

200 .<l OOU
2903420
() . 00 JD
52.9636
2~0.1l00G

:

DO .O COOa~

OEC.

ELE'IATION

XHTR
OEG

;, o. 00 0

LOC~L

;>OLA~IZATIGN

DEb

REAL

6C.OOC

- a.OOJ

60.272
-0.053
3'3 .325
50.576
-D.DIlO
- il .354
5 ... 02
55 .672 -5.296
0 . 00 ()
1 <t~ . ~»30
- li .35"
5 .4 02
55 . 872
- 5 .2 98
0 . 300
168 .1Ii3»
-1. Ja J
1':'.370
.. 1'1 .7104 -62.1099
O. a 0 (I
6
.
;'
107
5
.561
~9
.'+11
;).000
230 .91 96
13. ;; 6"
2"0 .711rl
-7. I) 0"
13.003
-1.01:13
1>9.320
- ~.~oo
- 7 . '1 92
20G . G662
12. 02 1
1 0 . 2'019 69.1t')'J
-0.026
3 13.'3111
-10. t 1 ~
8.555
30 .632
- 0.000
6 3.,6"
THI S RAY CALCULATION r OOK
7.518 ~EC
30 . l Si]&,
111, . 41.<,2
14f>.6930

-0.15 7

-0. 000
-0 .&51

ELEVATIJtl ANGLE. OF

utQJO X'1T R
OtJOD ErHR I ON
OtOOO RCVR
1- 00 4 APOGEE
9 - B5 WAV" REV
OtDOO RCvR
-1- DOb EXIT 10'
Ot-OUO G~NO Rt: F
<l * Jij G EtH R lOt.
-3-011 RCVi(

rRAN~HISSION

AztHuTH
rJl:VIATlO,1
XHTF
LOC4 l
-1). 0 0 e

1,5.00 0000 DEC.

AZIMUTH ANGLE OF T RAN $ MI SS IO II

OF

il . 0 ~ OU
lit. a 7S9
52 . 6 d 75
:' 7. 5SG,+
70.7691
l J6 . bZ')7

T~ANSHI SSION

AZIHUTH
l)EVIATION
LO C AL
OEG
OEG
~MT R

- v. OOoJ

- O.OOV
- 0 . 3 02
1.331t
-i. '> 11
-a.853
-~. 12Z -11.101
5 . '> 11 -13. 543
-6.85&
220. 'B08
12. J9Z
240 .75119
13. 5 S7
- 6 .291
1 ... 3n
-5 . .. 7')
'N6 . 3 4 G3
37<;.3507
1 5.794
- 3 . 61t4
THI S ~AY CA L CULA TI ON

1.01t9

1.250
-2.C02
- 2 .C02
-1. 025
-1.000
1.DOO
1.(;25
1.e9,)

GR.OUP PATH

K"

PHASE

PATH

<.
0.0000

ABSORPTION
0'

0 .0 000
61.0908
239.25'52
324.2552
3210.2552
J95.1225
588.1225
616.7330
673.3376
837.7013

61.0906
225.&3 '+3
253.2661
253.2661
273 ..H58
1053.61210
"82.2229
538.8275
691.0808

0.0000
0.0000
0.0050
0.0114
0.0114
C. 0 1 73
0.0223
0.0223
0.0223
0.0271

GROUP PATH

PHASE PA TH

ABSORPTION

75.000000 DEG

ELE VA lION
LOCAL

XHT~

OEG

IM.IIG
1.000

O£O

75. UOO
75.000
750127
74.783
71.357
73 .111
8.237
72.3Q7
-4.47"
6 1.084 -46.,+7S
6 . 55 1 - 55.685
-ldld3
55.706
'1.565
56. <127
25. 91H
45 .376
TOOK
9.0 .. 9 SEC

POLAR IZATI ON
RE AL
IMA G
-0.000
1.000
- 0.02,+
1.023
- 0.0 OJ
1.087
J. 0 a J
- 3.8 76
a. aO'J -1.'3S0
0.000 -1 .021t
-1.000
1.1. a 0 J
-0.00)
1.000
-(1. 0 69
1.061t
- O.OD~
1 . 374

K"

0.0000
54.H7 ..
213.9181
314.9181
330.9181
434.Y673
651.9673
687.'+459
751.IoS63
937 . 9577

K"

0.0000
54.8371t
202.1281t
220.4673
221.5782
2109.27"7
1050.5600
1t86.o386
550.0 f!89
722.8911

0'
0.0000
0.0000
0.001t6
0.0134
0.011t7
0 . 0232
0.02'32
0.02')2
0.0292
0.0343

z

o

d dOOC ~ ~~~~~NNNC

C>""c:> O .... N~<CN..., "' '''''''''C>

o o c c c o O "' _ _ "''''''''''''''

~

~mooo o c>oococ:>ooc>oc>

0< C

o

•

•

•

••

•

•

••

•

••

•••

000000000000000

~

~
.~
~ z

, 0

~

~::;:;

~

I

O<C<C<C ....

,~

~"
~ "
0

w

0

•

~C~~N~~~"'~~"""'~~'"
CNj~~""~M"''''<CC~O'''

~

"''''~_~~

r

_ ........

~

~

o

0

Z

"

"
~

~

. . --- ----j"' --- --

~

O~~ NO ~~O~~~

~-

""'

•

0

~
~

"•
"0

'"",
;;
;

~

•••••

•••
I

~
~

~

I

I

I

,

I

u

•

~

•

""

~

,

·
•

.... ~-~

••••

I

I

I

I

..,"''''_1'')

"
~

I

I

I

I

2

OC>OO ....... .... (1''"'O~N~..,
~0"'0,ro ....
..........(>"' ... N>O
ooOo~(1''''O(1' .... tf\NN''''lI!
• • ••• • ••• •• ••• 0

~
~

'" '"'''',....., ... "'..,...,.,., N

oOOO(1'(1'(1'(1'~~""",(1'",O

"'.0 ~

,

z

r

o

~

z

~

""""'<.!l

.... 0 0 0 0 0 0 0 " " ' 0 0 ...
0 0 0 0 0 0 0 0 , , " 0 0 ...
0:>0000000"'00"'"

....... 0 0

00<:>0000000"':;:>

. ... .... ...

"

1 : 0 U ....

:::> .... ~

..,,,,,

" '"

~

<.1

I

,,

""

'"
'" w .... .:J .f' ," _" C '" ., V
o!J .f' ..c oJ;> .!) ~ >0 ..c ..c ..c .0

"

"
c'
Z

";"; "~":";". ~ ~ ~": '::;

-.

...
_........ .....................
_...;- - ----""

'"
" ..." '" '" '" '" 'Y
~ or'
.... '"
~ '" '" ...
I

,

I

,

,

,

I

•

•

,

,

O""oo.., .... ~m(1'..,M ... (1' ...

....

r

~~

<:'O.., .... "'_ ... '"

O.:>·~c:>;:>tf\N ...
0 " " " ' 0 0 .... 0"'_(1'(1'(1'0(1' _
Oq~o<:> _ ..,(1'DcMD ... ~ ....

<.!l
;>-:>:

••

••

•••••

•

••

•

•

•

~KCL'OOOOOOM3~"'MMN

Q

~

....... ..., ~" N

_

...

~

<.:> ., .,-. ,~ ,J

.,

C

. C'"

J.J

;>

= ~;~;~~~~~~~~~~~
~

~C~~ N

.... lI!

=
~

•••

.... _ ON~OO~O:>"'O
••• •••••••••

~N~~(1'~~~n..,~~ON~

.... O~~M~N
__

"'~ . O_

'n

NNNN~

Z

,>,

0

....... ' .. ' "

'"~

Z .... Z
WuJ

0 ,.. 0

"l: 'r'"

~""Il.''''Q:

,

UI
'0

•

o o o c o ( 1 ' .... OC(1'~~ _ _ "' ...
.... N~NN~(1'O~O
OU W • • • • • • • • • • • • • ~ .....
~OOOOOOO(1''''(1' .... '''~~~(1' .... •
~~
~(1'~(1'~~~~ .... ~ ........ ~ ........ ..,

.~
~

I

;;:

"

" '"c0

I

0 0 0 0 0 1 " ) ( 1 ' .... " ' ...

Z

~

0

••••

,

~

"
~

•

,

Z~~ooooo~

z

,"

•

I

•••••••

0

;:

••

o..~OO~OO~OOOO~OO~~

.
•
r

•

~""'~OOOOOOOOOOOOOO

'" UJ

z

_0

•

""'~oO~oooCOOoooooo

~

~

.... NC<C .... oDNoD...,

O<1'N<1'..,
_ _ _ ....
N CNU"IoDOOc->..,'"
M"'Oc..,OOOO

~

~
,

~

~

O~OOOOOOOOU,"'O~UOO

..... ::1:

0

~

__

~ONNN

Z~OO

0

~

I

~oDoDoD"''''

"''''oD ........
OoD_ .... _ ~N .... M
.... .... NN""MjlnoDoD<C

~

~

0

•,

j

~~ONj~a'oD

'"

0

~

"

O~~jj

C,...a'N ........ .... _ _ ....

o..:r • • • • • • • • • • • • • • •

0

"0
r
"0

''''M_~~''''

OCCCOC"''''''''''~~~_~

~

•z

_ _

NNNN4jj~

<c<c>""..,..,<C., OO"'C O>&loDO

o
~

·•
·•,

••• • • • • • ••• • • • •

~

~

>

.... C

~"'NN~...,"' _
CCCC"" ~ ~ON ~ ~~~_~
C~~~""N~N"'M~""~~~

4

_10:_

'" ... :=oa::o::
0::0:: "
......... " ' " " , ' O , ... Z ... ,
::c 7""'4'" " " U " " ' C ( n . U " ' t r Z u
l.UW "'~l.U l.U<.!l'r

"'lL.I'1:S"~~O::~'X""'trl.U<.!IWO::

0 .0,..,.., .....

... 0' ....
n ........ <:>
.......... 0 0 0 0 0 0 .... 0 ........ 0

<:> .... _

0

~"'OOoO"'o~o<:>o<:>""

,

,

,

,

I

..

00

0,..,""'" "'NO"'''''N.tIN''''''0

, , , ,

18 2

•

,

,

I

,

, .,

,

I

"

,

.....

~I

..

Appendix 8d.

Listing of Punched Card Output (ray sets)
for Sample Case

TEST CASE
XOI
CHAPX
6 . 500+000 3.000+002 6.200+001
WAVE
2.500+ 002 1.000+002 1.000-001
DIPQLY
8.000 - 001 0 .0 00+0')0 0 . 000+000
3 .6 5() +OO4 1.000+002 1.480-(11)1
EXPZ2

x'Jlx

o 4000'1255000

5.000-001 0.000+000
0.000+000 1.000+002
n . OOO+OOO 0 .0 00+000
3.00 0 +0 1)1 1.40')+002

0. 11 00+000

0 . 000+000 0.000+000
1.830-002 0 . 000+000

2000 001"1
6f'l(l ('I '1
45 0QOOO
0
- 29
0 1514 389 4513 -161 0
11
2
14912561
2
- 29
0 1514389 4513 -161 0
11
10
29000482
-0
738 2875068 80425 68182
22
£..3050842
- 0 '12785611 09 482 91246
-7
76
33
4500000
o 40000255000 2000 000
600(10
1500000
0 635731
6041034
15
184
8122 - 3264
8
6<141('13 4
184
8
15
0 635731
8122 - 3264
12129251
46
-23 14656 1211ng4 81100 58053
17
59
18286204
-65
- 0 1854769 92641 58123
26
4500000
o 40 000255000 2000000
3000000
60000
3549 4 08
0 407964 17828 - 7003
8
- 23
219
35494(18
8
-23
219
0 407964 17828 - 7003
7336080
405 -349 28173 731203139482 89236
18
11075272
514
454
26
0 11384 30174444 101677
45 00000
o 4()OOO255000
20000 00
4500000
60000
607 28480
2002014 -132
285194 9971 -6754
6
274,788
389 -1415-23456 342980 67874 -6143
14
4847060
576
- 25 44114 484589230974137632
21
(..1915163
548
796 26953
72988 0 285982175495
27
o 40000255000 2000000
4500000
6000000
60000
7950 - 5671
1144182 -1 57 -851 5 05 78 231305
5
1681639 -1383 16876 - 62499 2629931321'0 10323
17
2407118 -7009 13003 69320
240697376036241525
22
3139111-1 01 15 8555 63564 376316461386314765
27
7500000
0 40000255000 2000000
45 0 0000
60000
526875
1334 71357 207034 6884 -4 906
5
-302
1066297 5511-1>543 -46475 227435207533 21840
23
24 07589 13557 -6291 55706 240745446701245294
29
34
3753507 15794 - 3644 45376 4,0 4 30507528292462
o 40000255000 2000000
6n'1no
4500000
9000000
3028214734180000 88779 200000 7166 -5034
5
153973214734
0 - 75213 200610210447 37559
20
537019214734
0 78918
25
53702568516382995
927180214734
0 77233 221057612222414510
30

1581469 1'.. 911561
1581469
1~81469

1579016

XOl:<
1721392
1721392
1721416
1719566

XOIX
1 9 15641
1 915641

1916346

1898217
XOlx
0
2096543
2096843
0
XOIX
0
22 58382
2258>82
0
XOlx
0
2309183
230,183
0
X01X
0
2382305
2382305
0

The first card is the title ca rd.
The second card contains the name of the electron density
model plus parameters W101 - WI0?
The third card contains the name of the perturbation
model plus parameters WlSl - WlS7 .
The fourth card contains the name of the magnetic field
model plus parameters WZOI - WZ07.
The fifth card contains the name of the collision
frequency model plus parameters WZ5 1- WZ57.

For description of remaining cards, see figures 1 and 2 .

183

o . uoo +ooo

1 .O CO +002 0 . 000+000

o - 1003T

0
0
0
0
0
0
0
0
0
0
0
0

0
0
0
0
0
0
0
0
0
0
0
0
0
0
0
0

0 -17Z1 M

o - 1722M
o -1 00%

-0 9323""
0 - lOOn
0 -1481M
0 - 1482M
-0
1003G
0 -1953M
-0
1003T
0 - 1531M
0 -1532M
-0 1 003G
0 -1773f.A
-0
1003T
- 0 2291R
0 -1142R
-0
100%
- 0 2163R
-0
1003T
-0
1251R
0 -1 032R
- 0 1003G
-0 11 0 3R
-0
1003T
-0 1091R
0 -1022R
- 0 1003G
-0
1373R
-0 1003T
- 0 1031R
0 - 1082R
-0 1003G
-0 1013R

Appendix 8e.

Ray Path Plots for Sample Case

Projection of raypath on vertical plane

XOI

TEST CA.SE

r: = S.OOO, AZ = A5.00, EXTRAORD.

184

11/05174
100.00 KM BETWEEN TICK HARKS

Projection of raypath on ground for sample case

X

F' =

TEST C~SE
Z = 45.00 , EXTRMRD,

6.000 ,

185

II/O~I7'

100.00 KH BETWEEN TICI( MARKS

FORM
13·73 1

OT·29

U.S . DEPAR T MENT OF COMMERCE
O F FICE OF TELECOMMUNICATIONS

BIBLIOGRAPHIC DATA SHEET
I. PUBLICATION OR REPORT NO

3. Recip ient's Acce ss ion No.

2. Gov't Accession No.

OTR 75 - 76
4. TITLE AND SUB TITLE

S. Publ icat ion Date

A versatile three- dimensional ray tracing computer
program for radio waves i n the ionosphere

October 1975
6. Perf orm in g Organization Code

OT/ITS, Div. 1
7. AUTHOR(S)

9. Pr oj e ct / Task / Work Unit No.

R. Michael Jones and J ud i th J. Stephenson
8. PERFORMING ORGANIZATION NAME AND ADDRESS

U. S. Department of Conunerce
Office of Telecommunications
Insti tute for Telecommunicati on Sciences
Boulder, Colorado 80302

10. Contract / Grant No.

12. T y~ of Rep o rt and Period Covered

11. Sponsoring Organ izat ion Name and Address

U. S. Department of Conunerce
Office of Telecommunications
Institute for Telecommunication Sc i ences
Boulder, Co l orado 80302

Technica l Report
13.

14. SU PPLEMENTARY NOTES

IS. ABSTRACT ( A 20()-'woro or les s factual summary of most sifP1ificant information. It do cument include s a siQniticant
bjbljo~raphy

ot literature survey, ment;oo it here . )

Thi s report describes an accurate, versat i le FORTRAN computer program f or
tracing rays through an anisotropic medium whose index of r efracti on varies continuously in three dimensions. Although developed to calculate the propagation
of radio waves in the i onosphere , the program can be easi l y modi fi ed to do other
types of ray tra cing because of its organizat i on into subroutine.
The program can represent the refracti ve index by e i ther the Appleton- Hartree
or the Sen- \,yller formu l a, and has several ionospheric models for electron density
perturbations to the e l ectron density (irregularities), the earth's magnetic fie l d
and e l ectron co l l i s i on f requency.
For each path, the program can calculate group path length, phase path length,
absorption, Doppler shift due to a t i me - varying ionosphere , and geometrical path
l ength . In addition to pr i nting these' parameters and the direct i on of the wave
normal a t various point s along the ray path, the program c an p l ot the project i on
of the ray path on any vert i cal plane or on the ground and punch the main characteristics of each ray path on cards .
The documentation incl udes equations, flow charts , program listings with
corrunents, definitions of program variables, deck set- ups, description of input
and output, and a sample case.
KEY WORDS:
Appleton- Hartree formu l a; computer progr am; ionosphere; radio waves; ray tracing;
Sen-Wyller formula; three- dimensional.

17. AV AILA BILITY STATEMENT

18 . ~cwi ty Class (This report)

UNCLASSIFIED

CZlXUNLlM1TED.

19. ~curity Cl ass (This pa~)

0

20. Number of pages

197
21. Price:

FOR OFFICIAL DISTRIBUTION.

UNCLASSIFIED
~ u. S. GOVERNMENT PRINTING OFFICE 1117~· 662·16t1111C1 R.... e

l'SCOMM - 'J C 2Sl716-P73
16(X)1Ot • fJJ.

ERRATA (21 April 1979)
OT REPORT

75-76

A VERSATILE THREE-DIMENSIONAL RAY TRACING COMPUTER PROGRAM .... _ _ '.
rOR RADIO WAVES IN THE IONOSPHERE

by R. Michael Jones and Judith J . Stephenson
The 8th line from the bottom of page 9 should read :
(1) the dispersion relat i on cannot be exactly satisfied, or
The first line in the 3rd complete paragraph on page 12 should read :
Similarly, the AHWrNC (Appleton - Hartree , ',; ith field , no colli -

in SUBROUTINE PRI1'1TR on pa~e 80 should read :
RANG"C:=EJl.R THR '" .~.7 AN2 (RCE, EARTHR+EPS+Xt1'i'RH)

PRIN12S

Line 8C1'1C020 in SUBROUTINE BQI-1F"NC on page 100 should read :
REJl.L N2, NNP, L?OLAR , LPOLRI, KR, KtH! [(PH, K2 , KDOTY, K4, KDOTY2,

BONC020

Line 7.o.8X064 in SUBROUTINE TABLEX on page 112 s"r.ould read :
PXPR=PXPTH=PXPPH=O .

TABX064

Line

P~IN'25

Follo'.{ing line CHAP024 in SUBROUTINE CH.Il. PX on page 116, insert the line :
CHAP0245
PXPPH=O .
Line VeHA010 in SUBROUTINE VCHAPX on pag e 111 should read :
X=PXPR=PXPTH=PxPFH=O .

VCHA010

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

