# mcord/Makefile

CONFIG_DIR         := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
COMMON_DIR         := $(CONFIG_DIR)/../common

.DEFAULT_GOAL      := xos

DOCKER_PROJECT     ?= mcord
BOOTSTRAP_PROJECT  ?= mcordbs

XOS_UI_PORT        := 8888

include $(COMMON_DIR)/Makefile

xos: prereqs config_dirs xos_download cord_services cord_libraries bootstrap onboarding podconfig

onboarding:
	@echo "[ONBOARDING]"
	# on-board any services here
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) xos
	$(RUN_TOSCA_BOOTSTRAP) $(COMMON_DIR)/tosca/disable-onboarding.yaml
	sudo cp id_rsa key_import/vBBU_rsa
	sudo cp id_rsa.pub key_import/vBBU_rsa.pub
	sudo cp id_rsa key_import/vPGWC_rsa
	sudo cp id_rsa.pub key_import/vPGWC_rsa.pub
	sudo cp id_rsa key_import/onos_rsa
	sudo cp id_rsa key_import/onos_rsa.pub
	$(RUN_TOSCA_BOOTSTRAP) $(LIBRARY_DIR)/ng-xos-lib/ng-xos-lib-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/openstack/xos/openstack-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/vBBU/xos/vBBU-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/vPGWC/xos/vPGWC-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/vtn/xos/vtn-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/onos-service/xos/onos-onboard.yaml
	# $(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/fabric/xos/\fabric-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) synchronizers.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(COMMON_DIR)/tosca/enable-onboarding.yaml
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/ng-xos-lib
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/vbbu
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/vpgwc
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/vtn
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/onos
	# bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/fabric
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) xos
	bash $(COMMON_DIR)/wait_for_xos_port.sh $(XOS_UI_PORT)

podconfig: nodes.yaml images.yaml
	@echo "[PODCONFIG]"
	$(RUN_TOSCA) setup.yaml
	$(RUN_TOSCA) nodes.yaml
	$(RUN_TOSCA) images.yaml

vtn: vtn-external.yaml
	$(RUN_TOSCA) vtn-external.yaml

vtn-external.yaml:
	export SETUPDIR=$(CONFIG_DIR); bash ./make-vtn-external-yaml.sh

mcord:
	$(RUN_TOSCA) mgmt-net.yaml
	$(RUN_TOSCA) mcord.yaml

onboard-slicing: slicing-ui
	@echo "[ONBOARDING]"
	# on-board slicing services here
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) xos
	$(RUN_TOSCA_BOOTSTRAP) $(COMMON_DIR)/disable-onboarding.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/mcord_slicing_ui/xos/mcord-slicing-onboard.yaml
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/mcord_slicing_ui
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) xos
	bash $(COMMON_DIR)/wait_for_xos_port.sh $(XOS_UI_PORT)

slicing-ui:
	$(RUN_TOSCA) ./mcord-slicing-ui.yaml
