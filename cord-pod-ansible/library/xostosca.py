#!/usr/bin/python

import json
import os
import requests
import sys
import traceback

from ansible.module_utils.basic import AnsibleModule

def main():
    module = AnsibleModule(
        argument_spec = dict(
            recipe    = dict(required=True, type='str'),
            username  = dict(required=True, type='str'),
            password  = dict(required=True, type='str'),
            hostname  = dict(default="127.0.0.1", type="str"),
            port      = dict(default=80, type="int")
        )
    )

    xos_auth=(module.params['username'], module.params['password'])

    url = "http://%s:%d/api/utility/tosca/run/" % (module.params['hostname'], module.params['port'])
    
    r = requests.post(url, data={"recipe": module.params['recipe']}, auth=xos_auth)
    if (r.status_code != 200):
        try:
            error_text=r.json()["error_text"]
        except:
            error_text="error while formatting the error: " + traceback.format_exc()
        module.fail_json(msg=error_text, rc=r.status_code)

    result = r.json()
    if "log_msgs" in result:
        module.exit_json(changed=True, msg="\n".join(result["log_msgs"])+"\n")
    else:
        module.exit_json(changed=True, msg="success")

if __name__ == '__main__':
    main()
