#!/usr/bin/env python
""" This script compiles and executes the upgraded file that inspired the RESPY
package.
"""
import linecache
import shlex
import os

import numpy as np

np.random.seed(123)

# Compiler options. Note that the original codes are not robust enough to execute in debug mode.
DEBUG_OPTIONS = ' -O2  -Wall -Wline-truncation -Wcharacter-truncation -Wsurprising  -Waliasing ' \
                '-Wimplicit-interface  -Wunused-parameter -fwhole-file -fcheck=all  -fbacktrace ' \
                '-g -fmax-errors=1 -ffpe-trap=invalid,zero'

PRODUCTION_OPTIONS = ' -O3'

# I rely on production options for this script, as I also run the estimation below.
OPTIONS = PRODUCTION_OPTIONS

# Some strings that show up repeatedly in compiler command.
MODULES = 'kw_imsl_replacements.f90 kw_test_additions.f90 '
LAPACK = '-L/usr/lib/lapack -llapack'

# Compiling and calling executable for estimation.
cmd = ' gfortran ' + OPTIONS + ' -o dpml4a ' + MODULES + ' dpml4a.f90 ' + LAPACK
os.system(cmd)

# This is the first take at standardizing the disturbances.
num_periods, max_draws = 40, 1
draws_standard = np.random.multivariate_normal(np.zeros(4), np.identity(4), (num_periods, max_draws))

with open('draws.respy.test', 'w') as file_:
    for period in range(num_periods):
        for i in range(max_draws):
            fmt = ' {0:15.10f} {1:15.10f} {2:15.10f} {3:15.10f}\n'
            line = fmt.format(*draws_standard[period, i, :])
            file_.write(line)

# Let me just fix a small regression test just to be sure ...
os.system('./dpml4a')
stat = float(shlex.split(linecache.getline('output1.txt', 65))[2])
np.testing.assert_equal(stat, -28.948249816895)
