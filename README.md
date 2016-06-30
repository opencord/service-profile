## Service Profiles

This repository contains service profiles. Each service profile specifies a graph of services that will be instantiated. 

Notable service profiles include:

* `cord-pod`: Standard R-CORD service stack, for both single-node-pod and multiple node pod installs. 
* `frontend`: Designed for frontend development, this profile starts XOS, but does not start any synchronizers other than the onboarding synchronizer. 
* `test-standalone`: Runs a test suite that tests the REST API and Tosca API.

The directory `common` is not a service profile, but contains various common files and tools that are used by the other service profiles.
