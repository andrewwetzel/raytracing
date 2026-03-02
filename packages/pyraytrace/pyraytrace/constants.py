"""Physical constants used throughout the ray tracer.

Matches the values from BLOCK_DATA.f and NITIAL.f in the Fortran code.
"""

import math

PI = math.pi
PIT2 = 2.0 * PI
PID2 = PI / 2.0
DEGS = 180.0 / PI
RADIAN = PI / 180.0

# Speed of light in km/s
C = 2.997925e5

# Classical electron radius constant: (e^2)/(m_e * c^2) * c^2 / pi
# Units: km (since C is in km/s)
K = 2.81785e-15 * C * C / PI

LOGTEN = math.log(10.0)

# Earth radius in km
EARTH_RADIUS = 6370.0
