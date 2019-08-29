load("./deployments.star", "deployments")
load("./dice.star", "dice")
load("./ratelimit.star", "rate_limit")

def filename(deployment):
  return "%s-%s-%s" % (deployment["zone"], deployment["cluster"], deployment["env"])

def config(deployment):
  return {
    "name": filename(deployment),
    "dice": dice(deployment),
    "rate_limit": rate_limit(deployment)
  }

outputs = [config(d) for d in deployments]
