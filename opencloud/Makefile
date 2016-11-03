# opencloud/Makefile

CONFIG_DIR         := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
COMMON_DIR         := $(abspath ../common )

.DEFAULT_GOAL      := xos

DOCKER_PROJECT     ?= oc
BOOTSTRAP_PROJECT  ?= ocb

# Include common functions
include $(COMMON_DIR)/Makefile

xos: prereqs config_dirs xos_download opencloud_services oc_bootstrap onboarding

opencloud_services: $(SERVICE_DIR) \
	$(SERVICE_DIR)/onos-service \
	$(SERVICE_DIR)/openstack \
	$(SERVICE_DIR)/vrouter \
	$(SERVICE_DIR)/vtn

opencloud_bootstrap: deployment.yaml
	@echo "[OC BOOTSTRAP]"
	@echo "XOS Image Build Date: `sudo docker inspect -f '{{ .Created }}' xosproject/xos`"
	@echo "XOS Image Commit Hash: `sudo docker inspect -f '{{ .Config.Labels.XOS_GIT_COMMIT_HASH }}' xosproject/xos`"
	@echo "XOS Image Commit Date: `sudo docker inspect -f '{{ .Config.Labels.XOS_GIT_COMMIT_DATE }}' xosproject/xos`"
	sudo rm -f $(DOCKER_COMPOSE_YML)
	sudo CONFIG_DIR=$(CONFIG_DIR) docker-compose -p $(BOOTSTRAP_PROJECT) -f $(BOOTSTRAP_YML) up -d
	bash $(COMMON_DIR)/wait_for_xos_port.sh $(XOS_BOOTSTRAP_PORT)
	sudo docker-compose -p $(BOOTSTRAP_PROJECT) -f $(BOOTSTRAP_YML) run xos_bootstrap_ui python /opt/xos/tosca/run.py none - < $(COMMON_DIR)/tosca/fixtures.yaml
	sudo docker-compose -p $(BOOTSTRAP_PROJECT) -f $(BOOTSTRAP_YML) run xos_bootstrap_ui python /opt/xos/tosca/run.py none - < deployment.yaml
	bash $(COMMON_DIR)/wait_for_xos_port.sh $(XOS_BOOTSTRAP_PORT)
	$(RUN_TOSCA_BOOTSTRAP) $(CONFIG_DIR)/xos.yaml

onboarding: synchronizers.yaml id_rsa id_rsa.pub
	@echo "[ONBOARDING]"
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) xos
	$(RUN_TOSCA_BOOTSTRAP) $(COMMON_DIR)/tosca/disable-onboarding.yaml
	sudo cp id_rsa key_import/onos_rsa
	sudo cp id_rsa.pub key_import/onos_rsa.pub
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/openstack/xos/openstack-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/vrouter/xos/vrouter-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/vtn/xos/vtn-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/onos-service/xos/onos-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) synchronizers.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(COMMON_DIR)/tosca/enable-onboarding.yaml
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/vrouter
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/vtn
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/onos
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) xos
	bash $(COMMON_DIR)/wait_for_xos_port.sh $(XOS_UI_PORT)

opencloud: opencloud.yaml
	@echo "[OPENCLOUD]"
	$(RUN_TOSCA) opencloud.yaml

vtn: vtn.yaml
	@echo "[VTN]"
	$(RUN_TOSCA) vtn.yaml

exampleservice: $(SERVICE_DIR)/exampleservice opencloud-exampleservice.yaml
	@echo "[EXAMPLESERVICE]"
	sudo cp id_rsa key_import/exampleservice_rsa
	sudo cp id_rsa.pub key_import/exampleservice_rsa.pub
	$(RUN_TOSCA_BOOTSTRAP) $(COMMON_DIR)/tosca/disable-onboarding.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/exampleservice/xos/exampleservice-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) exampleservice-synchronizer.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(COMMON_DIR)/tosca/enable-onboarding.yaml
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/exampleservice
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) xos
	bash $(COMMON_DIR)/wait_for_xos_port.sh $(XOS_UI_PORT)
	$(RUN_TOSCA) opencloud-exampleservice.yaml

