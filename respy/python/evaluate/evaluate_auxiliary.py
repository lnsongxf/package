""" This module contains some auxiliary functions for the evaluation of the
criterion function.
"""
import numpy as np

from respy.python.shared.shared_auxiliary import check_dataset
from respy.python.shared.shared_constants import HUGE_FLOAT


def get_smoothed_probability(total_payoffs, idx, tau):
    """ Construct the smoothed choice probabilities.
    """
    maxim_payoff = max(total_payoffs)

    smoot_payoff = np.clip(np.exp((total_payoffs - maxim_payoff)/tau), 0.0,
        HUGE_FLOAT)

    prob_choice = smoot_payoff[idx] / sum(smoot_payoff)

    # Finishing
    return prob_choice


def check_output(crit_val):
    """ Check integrity of criterion function.
    """
    assert (np.isfinite(crit_val))
    assert (isinstance(crit_val, float))

    # Finishing
    return True


def check_input(respy_obj, data_frame):
    """ Check input arguments.
    """
    # Check that class instance is locked.
    assert respy_obj.get_attr('is_locked')

    if respy_obj.get_attr('is_solved'):
        respy_obj.reset()

    # Check that dataset aligns with model specification.
    check_dataset(data_frame, respy_obj, 'est')

    # Finishing
    return True
