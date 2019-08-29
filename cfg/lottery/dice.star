# A simple example of how to override a value. All deployments to the "special" cluster use
# an 8 sided die.
DEFAULT_NUM_SIDES = 6
NUM_SIDES_OVERRIDES = {
  "special": 8
}

def dice(deployment):
  return {
    "sides": NUM_SIDES_OVERRIDES.get(deployment["cluster"], DEFAULT_NUM_SIDES),
    "rolls": 2
  }
