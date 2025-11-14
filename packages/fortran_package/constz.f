INPUT PARAMETER FORM FOR SUBROUTINE CONSTZ
An ionospheric collision frequency model consisting of a constant collision
frequency

" = 0

for I) < h
-

for h> h

.

m iD

min

Specify:

(

"0

= _ _ _ _ _ collisions pe r second (W251)

h

=

min

-----

krn (W 2 <;2)

SUBROU TINE (ONSTl
CONSTAN T COLLISION FREQUENCY
COMMON ICONST/ PI,PIT2,PI02,DUM(51
COMMON IlZI MOOl,Z,PZPR,PZPTH,PZPP H
(OMMON R(6)

/WWI

EQUrVAL::NCE

(EARTHR,W(2) J, (F,W{61I,{NU,WI251) I ,(HMIN,W(2521)

IDIIO),WQ,W(400J

REAL NU
DATA (MOD l=6HCQNSTlJ
ENTRY (OLFRl
H=R '11 -EARTHR
l=O.

IF ( H.GT.HMINI Z=NU/ ( PIT2*Fl*1.E-6
RETURN
END

155

(ONlOOl
(ONl002
(ONl003
(ON2004
(ON2005
(ON2006
(ON2007
(ON2008
(ON2009
(ON2010
(ON20 11
(ON2012
(ON2013
(ON2014-
