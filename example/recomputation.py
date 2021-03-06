#!/usr/bin/env python
""" This module recomputes some of the key results of Keane & Wolpin (1994).
"""

import shutil
import glob
import os

import respy

# We can simply iterate over the different model specifications outlined in
# Table 1 of the paper.
for spec in ['kw_data_one.ini', 'kw_data_two.ini', 'kw_data_three.ini']:

    # Process relevant model initialization file
    respy_obj = respy.RespyCls(spec)

    # Let us simulate the datasets discussed on the page 658.
    respy.simulate(respy_obj)

    # To start estimations for the Monte Carlo exercises. For now, we just
    # evaluate the model at the starting values, i.e. maxfun set to zero in
    # the initialization file.
    respy_obj.unlock()
    respy_obj.set_attr('maxfun', 0)
    respy_obj.lock()

    respy.estimate(respy_obj)

    # Store results in directory for later inspection.
    dirname = spec.replace('.ini', '')
    os.mkdir(dirname)
    for fname in glob.glob('*.respy.*'):
        shutil.move(fname, dirname)
