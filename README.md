## Service Profiles

This repository contains service profiles, one per directory, which configures
XOS with a graph of services to be instantiated.  These configurations automate
the creation of containers, loading things into the onboarding synchronizer,
and starting XOS.

### Using this repo

Most frequently, this `service-profile` repo is checked out by
[platform-install](https://github.com/opencord/platform-install/) during a
conventional build of a CORD pod.  The `cord-pod` style repos work in this way.

When using the testing configurations like `test-standalone` and `frontend`,
this repo can be checked out on it's own on a

The directory `common` is not a service profile, but contains various common
files and tools that are used by the other service profiles.  The
`common/Makefile` has many common targets and is included by the other
makefiles.  `common/Makedefs` specifies the git URL's and branches to use of
dependent software, which you may need to change if you're doing development on
a specific service.

In most cases, a profile is started by running `make local_containers; make` in
it's directory. See the per-directory README's for more information, or the
list of targets below.

### Notes on specific profiles

#### Used to build CORD pods:

 - `cord-pod`: [R-CORD](https://wiki.opencord.org/display/CORD/Residential+CORD)
  (Residential)
 - `opencloud`: [Opencloud](http://www.opencloud.us/) configuration
 - `mcord`: [M-CORD](https://wiki.opencord.org/display/CORD/Mobile+CORD)
  (Mobile)
 - `metronetwork`: Metro Network/Enterprise
  [E-CORD](https://wiki.opencord.org/display/CORD/Enterprise+CORD)
 - `acord`: [Analytics for
  CORD](https://wiki.opencord.org/display/CORD/Analytics+for+CORD)

#### Testing configurations:

 - `frontend`: Designed for [frontend
  development](https://wiki.opencord.org/display/CORD/User+experience+and+UI),
  this profile starts XOS without synchronizers (other than onboarding) for
  quick UI iteration.
 -  `test-standalone`: Runs a test suite that tests the REST API and Tosca API.

### Creating a new profile

The `devel` or `opencloud` configurations are good examples to start with.  All
configurations should start with defining `CONFIG_DIR`, `COMMON_DIR` (which
specify paths and should generally be the same as all other configurations),
the `.DEFAULT_GOAL` which specifies the target to start, and the
`DOCKER_PROJECT` and `BOOTSTRAP_PROJECT` variables that specify the names for
the docker containers created during the build process.

Next, include the `$(COMMON_DIR)/Makefile` which specifies common targets.
Before adding a new target, consier adding it to the common Makefile if is
useful across multiple profiles.

Define the default target, and the customize the other targets - most of the
time, the targets you'll need to customize are `onboarding` and `podconfig`,
which control which TOSCA files are loaded and which service synchronizer
containers are created by the onboarding synchronizer.

You'll also need to create a `xos.yaml` which specifies the configuration of
the onboarded XOS container, and `docker-compose-bootstrap.yml` which
configures the bootstrap containers.  Optionally, create a `cleanup.sh` to
clean up between run, if your service profile requires it.

## Utility/Convenience targets

There are several make targets created to help manage and the build process,
which are defined in `common/Makefile`. Run these within the service directories:

 - Build the containers from scratch using the local XOS source tree: `make
   local_containers`
 - Boostrap XOS and start containers: `make`
 - Stop the containers: `make stop`
 - Delete the containers (Database contents is deleted): `make rm`
 - Update XOS source tree: `make update_xos`
 - Update Services source trees: `make update_services`
 - View logs: `make showlogs_bootstrap` and `make showlogs`
 - See what containers are running: `make ps`
 - Open a shell on the XOS Bootstrap UI container: `make enter-bootstra-ui`
 - Open a shell on the XOS UI container: `make enter-ui`
 - Open a shell on the Database container: `make enter-db`



