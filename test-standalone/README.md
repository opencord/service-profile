# XOS API Test Configuration

This configuration is intended to be used to test the API, to use it, clone
`service-profile` onto a supported machine (Ubuntu 14.04 currently), then run
the following commands:

 - `make test_containers`
 - `make`
 - `make test`
 - `make test-tosca`

Note that this test will be automatically executed by [OpenCord
Jenkins](https://jenkins.opencord.org/) on checkin to the `xos` repo, so it's a
good idea to make sure these tests pass after doing work on that repo.

