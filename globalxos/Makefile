# globalxos/Makefile

CONFIG_DIR         := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
COMMON_DIR         := $(abspath ../common )

.DEFAULT_GOAL      := opencloud

DOCKER_PROJECT     ?= globalxos
BOOTSTRAP_PROJECT  ?= globalxosbs

XOS_BOOTSTRAP_PORT ?= 9001
XOS_UI_PORT        ?= 9000

# Include common functions
include $(COMMON_DIR)/Makefile

opencloud: prereqs config_dirs xos_download cord_libraries bootstrap onboarding opencloudconfig globalxos

onboarding:
	@echo "[ONBOARDING]"
	# on-board any services here
	bash ../common/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) xos
	bash ../common/wait_for_xos_port.sh $(XOS_UI_PORT)

opencloudconfig:
	@echo "[OPENCLOUDCONFIG]"
	$(RUN_TOSCA) opencloud.yaml
	$(RUN_TOSCA) dashboard.yaml

globalxos: $(SERVICE_DIR) $(SERVICE_DIR)/globalxos
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/globalxos/xos/globalxos-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(LIBRARY_DIR)/ng-xos-lib/ng-xos-lib-onboard.yaml
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/ng-xos-lib
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/globalxos
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) xos
	bash $(COMMON_DIR)/wait_for_xos_port.sh $(XOS_UI_PORT)
