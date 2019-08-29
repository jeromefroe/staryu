# tree is a hierarchical representation of the different deployments of the lottery service.
# When considering a service holistically, I find it simpler to envision the deployments as
# a tree-like structure since this matches the natural symmetries that exist. For instance,
# to improve the reliability of the service we may want to run it in two different failure
# domains. We can an example of this in tree, we have "production" instances of our "default"
# cluster running in both the "east" and "west" zones. The zones are unlikely to be completely
# identical though: tree has an additional "dev" environment in our "default" cluster in the
# "east" zone.
tree = {
  "east": {
    "default": [
      "production",
      "staging",
      "dev"
    ],

    "special": [
      "production",
      "staging"
    ],
  },

  "west": {
    "default": [
      "production",
      "staging"
    ],
  },
}

# flatten converts a dictionary which represents the deployments of the lottery service in a
# tree-like structure into a list of deployments. flatten is useful since, although I find it
# more intuitive to visualize the deployments as a tree, when actually working with those
# deployments to create a config file for each, it is easier to work with a list of objects
# which captures the properties of the deployment (zone, cluster, environment, etc.).
def flatten(tree):
  deployments = []
  for zone in tree:
    for cluster in tree[zone]:
      for env in tree[zone][cluster]:
        deployments.append(new_deployment(zone, cluster, env))
  return deployments

# new_deployment creates a new deployment object. Each deployment must have a zone, cluster,
# and env.
def new_deployment(zone, cluster, env):
  return {
    "zone": zone,
    "cluster": cluster,
    "env": env
  }

deployments = flatten(tree)
