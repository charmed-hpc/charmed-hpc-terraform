#!/usr/bin/env python
import json
import subprocess

# Workaround for:
# https://github.com/juju/terraform-provider-juju/issues/573
#
# Deploying on AWS intermittently fails with i/o timeouts as the Juju
# Terraform provider returns inaccessible local IP addresses in the list of
# API controllers. Work around by determining if the current cloud is 'aws'
# and set environment variable 'JUJU_CONTROLLER_ADDRESSES' to the non-local
# endpoint(s) if so.
#
# For example, controller configuration:
#
#   cloud: aws
#   api_endpoints = ['44.192.113.5:17070', '172.31.11.216:17070',
#                    '252.11.216.1:17070']
#
# results in:
#
#   export JUJU_CONTROLLER_ADDRESSES=44.192.113.5:17070

# Check if deploying on AWS
result = subprocess.check_output("juju show-controller --format json".split(),
                                 stderr=subprocess.STDOUT, text=True)
juju_config = json.loads(result)
# Expect dictionary with single key corresponding to current controller name
controller_name = list(juju_config.keys())[0]
cloud = juju_config[controller_name]["details"]["cloud"]

if cloud == "aws":
    # Filter out local IP addresses from list of all API endpoints
    endpoints = juju_config[controller_name]["details"]["api-endpoints"]
    valid_endpoints = "" # Terraform requires external data as string type
    for endpoint in endpoints:
        # Local IPs defined as those in 172.x and 252.x ranges
        if not(endpoint.startswith(("172","252"))):
            valid_endpoints += endpoint + ","

    # Output in JSON format expected by Terraform
    valid_endpoints = valid_endpoints.rstrip(",")
    print(json.dumps({"controller_addresses": valid_endpoints}))
else:
    # For all other clouds, do not specify addresses. Return empty JSON.
    print(json.dumps({}))
