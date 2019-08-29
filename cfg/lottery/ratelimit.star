DEFAULT_LIMIT = 100
WEST_LIMIT = 150
EAST_SPECIAL_LIMIT =  50

# A more complex example of how to override a value.
def get_limit(deployment):
  # TODO
  if deployment['zone'] == 'west':
    return WEST_LIMIT

  if deployment['zone'] == 'east' and deployment['cluster'] == 'special':
    return EAST_SPECIAL_LIMIT

  return DEFAULT_LIMIT


def rate_limit(deployment):
  return {
    "limit": get_limit(deployment)
  }
