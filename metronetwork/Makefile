# metronetwork/Makefile

CONFIG_DIR         := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
COMMON_DIR         := $(abspath ../common )

.DEFAULT_GOAL      := metronetwork

DOCKER_PROJECT     ?= metronetwork
BOOTSTRAP_PROJECT  ?= metronetworkbs

XOS_BOOTSTRAP_PORT ?= 9001
XOS_UI_PORT        ?= 9000

BOOTSTRAP_DEVEL_YML        ?= $(CONFIG_DIR)/docker-compose-bootstrap-devel.yml

# Include common functions
include $(COMMON_DIR)/Makefile

metronetwork: prereqs config_dirs xos_download cord_services cord_libraries bootstrap dashboard onboarding onboard_veg wait_for_xos ecord_services enable-vegmonitoring rest-gw ui

# Targets to accomodate users with HTTP proxies
metronetworkconfig: prereqs config_dirs xos_download cord_services cord_libraries
metronetworklaunch: bootstrap dashboard onboarding ecord_services

dashboard:
	$(RUN_TOSCA_BOOTSTRAP) dashboard.yaml

onboarding:
	@echo "[ONBOARDING THE LOCAL NODE]"
	# on-board the metronetwork service
	# on-board the vnodlocal service
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) xos
	$(RUN_TOSCA_BOOTSTRAP) $(COMMON_DIR)/tosca/disable-onboarding.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(LIBRARY_DIR)/ng-xos-lib/ng-xos-lib-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/metronet-local/xos/vnodlocalservice-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(COMMON_DIR)/tosca/enable-onboarding.yaml
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/ng-xos-lib
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/vnodlocal


onboard_veg:
	sudo cp ../cord-pod/id_rsa key_import/veg_rsa
	sudo cp ../cord-pod/id_rsa.pub key_import/veg_rsa.pub
	$(RUN_TOSCA_BOOTSTRAP) $(COMMON_DIR)/tosca/disable-onboarding.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/vrouter/xos/vrouter-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/vEG/xos/veg-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(COMMON_DIR)/tosca/enable-onboarding.yaml
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/vrouter
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/veg

wait_for_xos:
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) xos
	bash $(COMMON_DIR)/wait_for_xos_port.sh $(XOS_UI_PORT)

ecord_services:
	$(RUN_TOSCA) ecord-services.yaml

enable-vegmonitoring:
	$(RUN_TOSCA) vegmonitoring.yaml
	@echo "Validate if vEG metrics are available...."
	ansible-playbook -i local $(SERVICE_DIR)/monitoring/xos/test/monitoring_test_vsgmetrics.yaml

clean-config-folder:
	sudo docker exec $(DOCKER_PROJECT)_xos_ui_1 rm -f /opt/xos/xos_configuration/xos_mcord_config
	sudo docker exec $(DOCKER_PROJECT)_xos_ui_1 rm -f /opt/xos/xos_configuration/xos_cord_config

# Global node

onboardglobal:
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) xos
	$(RUN_TOSCA_BOOTSTRAP) $(COMMON_DIR)/tosca/disable-onboarding.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(LIBRARY_DIR)/ng-xos-lib/ng-xos-lib-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/metro-net/xos/metronetworkservice-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(COMMON_DIR)/tosca/enable-onboarding.yaml
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/ng-xos-lib
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/metronetwork
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) xos
	bash $(COMMON_DIR)/wait_for_xos_port.sh $(XOS_UI_PORT)

devel:
	# Simply start the DB - other steps will be done manually
	sudo CONFIG_DIR=$(CONFIG_DIR) docker-compose -p $(BOOTSTRAP_PROJECT) -f $(BOOTSTRAP_DEVEL_YML) up -d
