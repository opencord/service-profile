# metronetwork/Makefile

CONFIG_DIR         := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
COMMON_DIR         := $(abspath ../common )

.DEFAULT_GOAL      := metronetwork

DOCKER_PROJECT     ?= metronetwork
BOOTSTRAP_PROJECT  ?= metronetworkbs

XOS_BOOTSTRAP_PORT ?= 9998
XOS_UI_PORT        ?= 9999

# Include common functions
include $(COMMON_DIR)/Makefile

metronetwork: prereqs config_dirs xos_download cord_services cord_libraries bootstrap dashboard onboarding ecord_services

dashboard:
	$(RUN_TOSCA_BOOTSTRAP) dashboard.yaml

onboarding:
	@echo "[ONBOARDING]"
	# on-board the metronetwork service
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) xos
	$(RUN_TOSCA_BOOTSTRAP) $(COMMON_DIR)/tosca/disable-onboarding.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/metro-net/xos/metronetworkservice-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(COMMON_DIR)/tosca/enable-onboarding.yaml
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/metronetwork
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) xos
	bash $(COMMON_DIR)/wait_for_xos_port.sh $(XOS_UI_PORT)

ecord_services:
	$(RUN_TOSCA) ecord-services.yaml

clean-config-folder:
	sudo docker exec $(DOCKER_PROJECT)_xos_ui_1 rm -f /opt/xos/xos_configuration/xos_mcord_config
	sudo docker exec $(DOCKER_PROJECT)_xos_ui_1 rm -f /opt/xos/xos_configuration/xos_cord_config
