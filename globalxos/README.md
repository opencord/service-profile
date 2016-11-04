# Global XOS

This configuration launches an XOS that can control multiple CORD PODs.
Each POD is configured as a separate Site in Global XOS.

## Getting Started

- Navigate to `service-profile/globalxos` folder
- Edit `opencloud.yaml` to declare sites and admin login credentials for each site
- Run `make` command

### Using Vagrant

A Vagrant environment is provided with an ubuntu_14.04 box (ubuntu/trusty64).
There are two boxes: `global` and `arizona`.  The `global` box runs Global XOS
while the `arizona` box runs a sample L-XOS site.

The `global` XOS is available on `localhost:9999`.
The `arizona` XOS is available on `localhost:9990`.

It will also share the `service-profile` and `xos` folders with the Vagrant box.
These two directories are intended to be side by side.

How to set it up:
- Checkout the `service-profile` and `xos` repositories from Vagrant
- `cd service-profile/globalxos/`
- Start the Vagrant boxes: `vagrant up`
- Enter `arizona` Vagrant box: `vagrant ssh arizona`
- Start a frontend XOS: `cd service-profile/frontend; make local_containers; make; make mock-cord-pod`
- Exit `arizona` Vagrant box
- Enter `global` Vagrant box: `vagrant ssh global`
- Start Global XOS: `cd service-profile/globalxos; make local_containers; make`

If all goes well, the Global XOS should now be able to configure the frontend
XOS running in the `arizona` box.

### Docker Helpers

Stop the containers: `make stop`

Restart the containers: `make stop; make`

Delete the containers and relaunch them: `make rm; make`

Build the containers from scratch using the local XOS source tree: `make local_containers`

View logs: `make showlogs`

See what containers are running: `make ps`

## Docs

You can find Swagger documentation at: `http://0.0.0.0:9999/docs/`
