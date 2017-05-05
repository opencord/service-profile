# frontend/Makefile

CONFIG_DIR         := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
COMMON_DIR         := $(abspath ../common )

.DEFAULT_GOAL      := frontend

DOCKER_PROJECT     ?= frontend
BOOTSTRAP_PROJECT  ?= frontendbs

XOS_BOOTSTRAP_PORT ?= 81
XOS_UI_PORT        ?= 8888 

# Include common functions
include $(COMMON_DIR)/Makefile

frontend: prereqs config_dirs xos_download cord_services cord_libraries bootstrap onboarding frontendconfig

onboarding:
	@echo "[ONBOARDING]"
	# on-board any services here
	$(RUN_TOSCA_BOOTSTRAP) $(COMMON_DIR)/tosca/disable-onboarding.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(LIBRARY_DIR)/ng-xos-lib/ng-xos-lib-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(COMMON_DIR)/tosca/enable-onboarding.yaml
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/ng-xos-lib
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) xos
	bash $(COMMON_DIR)/wait_for_xos_port.sh $(XOS_UI_PORT)

onboard-cord-pod:
	sudo bash -c "echo somekey > key_import/vsg_rsa"
	sudo bash -c "echo somekey > key_import/vsg_rsa.pub"
	sudo bash -c "echo somekey > key_import/volt_rsa"
	sudo bash -c "echo somekey > key_import/volt_rsa.pub"
	sudo bash -c "echo somekey > key_import/onos_rsa"
	sudo bash -c "echo somekey > key_import/onos_rsa.pub"
	$(RUN_TOSCA_BOOTSTRAP) $(COMMON_DIR)/tosca/disable-onboarding.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(LIBRARY_DIR)/ng-xos-lib/ng-xos-lib-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/vrouter/xos/vrouter-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/olt/xos/volt-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/vsg/xos/vsg-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/onos-service/xos/onos-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/fabric/xos/fabric-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/vtr/xos/vtr-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) xos-cord-branding.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(COMMON_DIR)/tosca/enable-onboarding.yaml
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/ng-xos-lib
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/vrouter
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/volt
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/vsg
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/onos
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/fabric
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/vtr
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) xos
	bash $(COMMON_DIR)/wait_for_xos_port.sh $(XOS_UI_PORT)

frontendconfig: sample.yaml
	@echo "[FRONTENDCONFIG]"
	$(RUN_TOSCA) sample.yaml

mock-cord-pod: onboard-cord-pod
	$(RUN_TOSCA) $(COMMON_DIR)/tosca/mgmt-net.yaml
	$(RUN_TOSCA) mocks/onos.yaml
	$(RUN_TOSCA) ../cord-pod/cord-services.yaml
	$(RUN_TOSCA) $(COMMON_DIR)/tosca/public-net.yaml
	$(RUN_TOSCA) ../cord-pod/cord-test-subscriber.yaml
	$(RUN_TOSCA) $(COMMON_DIR)/tosca/cord-volt-devices.yaml

mock-mcord:
	# check this
	$(RUN_TOSCA) $(COMMON_DIR)/tosca/mgmt-net.yaml
	$(RUN_TOSCA) mocks/mcord.yaml
	sudo docker exec $(DOCKER_PROJECT)_xos_ui_1 cp /opt/xos/configurations/mcord/xos_mcord_config /opt/xos/xos_configuration/
	sudo docker exec $(DOCKER_PROJECT)_xos_ui_1 touch /opt/xos/xos/settings.py

exampleservice: $(SERVICE_DIR)/exampleservice
	mkdir -p key_import
	# fake keys are fine
	sudo bash -c "echo somekey > key_import/exampleservice_rsa"
	sudo bash -c "echo somekey > key_import/exampleservice_rsa.pub"
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/exampleservice/xos/exampleservice-onboard.yaml
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/exampleservice
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) xos
	bash $(COMMON_DIR)/wait_for_xos_port.sh $(XOS_UI_PORT)

hypercache: $(SERVICE_DIR)/hypercache
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/hypercache/xos/hpc-onboard.yaml
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/hpc
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) xos
	bash $(COMMON_DIR)/wait_for_xos_port.sh $(XOS_UI_PORT)
	$(RUN_TOSCA) mocks/cdn.yaml
	$(RUN_TOSCA) ../opencloud/cdn-content.yaml

dashboard: dashboard.yaml
	$(RUN_TOSCA) $(CONFIG_DIR)/dashboard.yaml

# before executing this clone the service from: https://github.com/teone/mcord-slicing-ui.git
onboard-mcord-slicing: slicing-ui
	# fix ports (now they are set to use the FE config ones
	@echo "[ONBOARDING UI SERVICES]"
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_UI_PORT) xos
	$(RUN_TOSCA_BOOTSTRAP) $(COMMON_DIR)/disable-onboarding.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/mcord-ui-slicing/xos/mcord-slicing-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(COMMON_DIR)/enable-onboarding.yaml
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_UI_PORT) xos
	bash $(COMMON_DIR)/wait_for_xos_port.sh $(XOS_UI_PORT)

slicing-ui:
	$(RUN_TOSCA) ./mocks/mcord-slicing-ui.yaml

slices:
	$(RUN_TOSCA) ./mocks/slices.yaml

clean-config-folder:
	sudo docker exec $(DOCKER_PROJECT)_xos_ui_1 rm -f /opt/xos/xos_configuration/xos_mcord_config
	sudo docker exec $(DOCKER_PROJECT)_xos_ui_1 rm -f /opt/xos/xos_configuration/xos_cord_config

experimental-ui: xos_rest_gw_c
	$(RUN_TOSCA_BOOTSTRAP) $(COMMON_DIR)/tosca/disable-onboarding.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(CONFIG_DIR)/ui_containers.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(CONFIG_DIR)/gui.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(COMMON_DIR)/tosca/enable-onboarding.yaml
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) xos
	bash $(COMMON_DIR)/wait_for_xos_port.sh $(XOS_UI_PORT)

