# DIAPER CDC Publication 60064900 January 1964
# "IP" FLIP FLOP AND ASSOCIATED GATES - Test 8

# Line M04
# Expected checksum: .x693002
# Page 44

00: u.01.01.0.19.04   # Copy M19 to M04
01:  .03.04.4.21.31   # Jump to 04.04

# Verify Line 4 checksum with retry
04:  .05.06.3.04.28
06: u.07.07.1.04.29
07:  .08.09.0.28.27

10:  .11.11.0.17.31
11:  .13.13.0.16.31
13:  .15.15.0.06.31
15:  .17.15.0.28.31
16:  .18.18.0.15.31
18:  .20.18.0.28.31
19:  .21.00.6.21.31

# Load and verify Line 0 with retry
09:  .u7.12.0.04.28
12:  .02.14.4.04.03
14:  .16.u5.0.08.31
u5:  .u7.u5.0.28.31
u6:  .01.08.0.23.31
08:  .10.20.0.15.31
20:  .22.20.0.28.31
21:  .22.23.3.04.28
23: u.24.24.1.19.29
24:  .25.26.0.28.27

27:  .28.28.0.17.31
28:  .30.30.0.16.31
30:  .32.32.0.06.31
32:  .34.32.0.28.31
33:  .36.08.0.23.31

# Load and verify Line 1 with retry
26: u.27.29.0.19.00
29:  .31.34.0.15.31
34:  .36.34.0.28.31
35:  .36.37.3.04.28
37: u.38.38.1.19.29
38:  .39.40.0.28.27

41:  .42.42.0.17.31
42:  .44.44.0.16.31
44:  .46.46.0.06.31
46:  .48.46.0.28.31
47:  .50.29.0.23.31

# Load and verify Line 2 with retry
40: u.41.43.0.19.01
43:  .45.48.0.15.31
48:  .50.48.0.28.31
49:  .50.51.3.04.28
51: u.52.52.1.19.29
52:  .53.54.0.28.27

# Page 45
55:  .56.56.0.17.31
56:  .58.58.0.16.31
58:  .60.60.0.06.31
60:  .62.60.0.28.31
61:  .64.43.0.23.31

# Load and verify Line 3 with retry
54: u.55.57.0.19.02
57:  .59.62.0.15.31
62:  .64.62.0.28.31
63:  .64.65.3.04.28
65: u.66.66.1.19.29
66:  .67.68.0.28.27

69:  .70.70.0.17.31
70:  .72.72.0.16.31
72:  .74.74.0.06.31
74:  .76.74.0.28.31
75:  .78.57.0.23.31

68: u.69.73.0.19.03
73: u.74.76.1.26.19
76:  .78.u3.0.21.31   # Exit to 0.u3

# Page 53
17:  .20.25.0.23.31
25:  .28.31.1.26.22
31:  .58.59.0.00.22
59:  .60.67.5.04.26
67:  .68.71.4.26.26
71:  .72.87.1.26.28
87:  .89.99.0.22.31

u0:  .u4.86.0.22.28
86:  .29.53.0.01.29
53:  .56.99.0.28.22
99:  .u2.u3.0.22.28
u3:  .29.45.3.01.29
45:  .46.78.0.28.27

79:  .82.88.0.28.22
88:  .91.59.0.23.31

78:  .80.97.0.22.27

98:  .u0.u1.0.22.28
u1:  .u2.92.0.04.29
92:  .92.92.0.28.31
93:  .u7.39.0.28.19
39:  .41.97.0.09.31
97:  .99.16.3.21.31

# Page 54
05:  .x693002   # Line 4 checksum
80: -.x693002
22:  .3303w2v   # Line 0 checksum
81: -.3303w2v
36: -.7xw7v2x   # Line 1 checksum
84:  .7xw7v2x
50:  .uzy5657   # Line 2 checksum
83: -.uzy5657
64: -.954349v   # Line 3 checksum
82:  .954349v
u2:  .0001600

# Constants missing from listing, reconstructed from comments pg.44 words 09, 12
u7:  .444400w
02:  .4000004
03:  .8000000

# Bal.: 96, 85, 77
# Unused: 89, 90, 91, 94, 95, u4

96: -.60wv492   # Checksum correction factor (calculated)