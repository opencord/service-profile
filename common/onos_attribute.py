#! /usr/bin/env python

import json
import os
import requests
import sys
import traceback

def check_status(r):
    if (r.status_code != 200):
        print >> sys.stderr, "ERR: recieved status %d" % r.status_code
        print >> sys.stderr, r.text
        sys.exit(-1)

def main():
    global opencloud_auth

    if len(sys.argv)!=7:
        print >> sys.stderr, "syntax: run_tosca.py <port> <username> <password> [get | set] app attribute"
        print >> sys.stderr, "   'get' will print attribute to stdout"
        print >> sys.stderr, "   'set' will read attribute from stdin"
        print >> sys.stderr, "example: onos_attribute.py 80 padmin@vicci.org letmein get VTN_ONOS_app rest_onos/v1/network/configuration/"
        sys.exit(-1)

    port = int(sys.argv[1])
    username = sys.argv[2]
    password = sys.argv[3]
    operation = sys.argv[4]
    app_name = sys.argv[5]
    attr_name = sys.argv[6]

    xos_auth=(username, password)
    hostname = "127.0.0.1"

    url = "http://%s:%d/api/tenant/onos/app/?name=%s" % (hostname, port, app_name)
    r = requests.get(url, auth=xos_auth)
    check_status(r)

    app_id = r.json()[0]["id"]

    url = "http://%s:%d/api/tenant/onos/app/%s/attributes/?attribute_name=%s" % (hostname, port, app_id, attr_name)
    r = requests.get(url, auth=xos_auth)
    check_status(r)

    if operation == "get":
        if r.json() != []:
            print r.json()[0]["value"]

    elif operation == "set":
        if r.json() == []:
            url = "http://%s:%d/api/tenant/onos/app/%s/attributes/" % (hostname, port, app_id)
            r = requests.post(url, data={"name": attr_name, "value": sys.stdin.read()}, auth=xos_auth)
            check_status(r)
        else:
            attr_id = r.json()[0]["id"]
            url = "http://%s:%d/api/tenant/onos/app/%s/attributes/%s/" % (hostname, port, app_id, attr_id)
            r = requests.put(url, data={"value": sys.stdin.read()}, auth=xos_auth)
            check_status(r)

if __name__ == "__main__":
    main()

