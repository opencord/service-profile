# opencloud/Makefile

CONFIG_DIR         := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
COMMON_DIR         := $(abspath ../common )

.DEFAULT_GOAL      := xos

DOCKER_PROJECT     ?= devel
BOOTSTRAP_PROJECT  ?= develbs

XOS_BOOTSTRAP_PORT ?= 9998
XOS_UI_PORT        ?= 9999

# Include common functions
include $(COMMON_DIR)/Makefile

cloudlab: xos_download common_cloudlab local_containers xos

devstack: xos_download upgrade_pkgs common_devstack local_containers xos

xos: config_dirs cord_services bootstrap onboarding develconfig

xos.yaml: xos.m4
	m4 -D CTLIP=$(MYIP) < xos.m4 > xos.yaml

onboarding:
	echo "[ONBOARDING]"
	# on-board any services here
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) xos
	$(RUN_TOSCA_BOOTSTRAP) $(COMMON_DIR)/tosca/disable-onboarding.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/openstack/xos/openstack-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(COMMON_DIR)/tosca/enable-onboarding.yaml
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/openstack
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) xos
	bash $(COMMON_DIR)/wait_for_xos_port.sh $(XOS_UI_PORT)

develconfig:
	$(RUN_TOSCA) $(COMMON_DIR)/tosca/cloudlab-openstack.yaml
	$(RUN_TOSCA) ../setup/nodes.yaml

common_cloudlab:
	make -C $(COMMON_DIR) -f Makefile.cloudlab

common_devstack:
	make -C $(COMMON_DIR) -f Makefile.devstack
