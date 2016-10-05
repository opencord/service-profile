# cord-pod/Makefile

CONFIG_DIR         ?= $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
COMMON_DIR         ?= $(abspath ../common )

DOCKER_PROJECT     ?= cordpod
BOOTSTRAP_PROJECT  ?= cordpodbs

# Include common functions
include $(COMMON_DIR)/Makefile

xos: prereqs config_dirs xos_core cord_services bootstrap onboarding podconfig

onboarding: synchronizers.yaml id_rsa id_rsa.pub
	@echo "[ONBOARDING]"
	# on-board any services here
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh 81 xos
	$(RUN_TOSCA_BOOTSTRAP) $(COMMON_DIR)/tosca/disable-onboarding.yaml
	sudo cp id_rsa key_import/vsg_rsa
	sudo cp id_rsa.pub key_import/vsg_rsa.pub
	sudo cp id_rsa key_import/volt_rsa
	sudo cp id_rsa.pub key_import/volt_rsa.pub
	sudo cp id_rsa key_import/onos_rsa
	sudo cp id_rsa key_import/onos_rsa.pub
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/openstack/xos/openstack-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/vrouter/xos/vrouter-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/olt/xos/volt-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/vsg/xos/vsg-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/vtn/xos/vtn-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/onos-service/xos/onos-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/fabric/xos/fabric-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/vtr/xos/vtr-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) synchronizers.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(COMMON_DIR)/tosca/enable-onboarding.yaml
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh 81 services/vrouter
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh 81 services/volt
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh 81 services/vsg
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh 81 services/vtn
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh 81 services/onos
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh 81 services/fabric
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh 81 services/vtr
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh 81 xos
	bash $(COMMON_DIR)/wait_for_xos_port.sh 80

podconfig: nodes.yaml images.yaml
	@echo "[PODCONFIG]"
	$(RUN_TOSCA) $(COMMON_DIR)/tosca/setup.yaml
	$(RUN_TOSCA) nodes.yaml
	$(RUN_TOSCA) images.yaml

vtn: vtn-external.yaml
	$(RUN_TOSCA) vtn-external.yaml

delete_fabric_config:
	http -a karaf:karaf DELETE http://onos-fabric:8181/onos/v1/network/configuration/

reactivate_fabric_apps:
	http -a karaf:karaf POST http://onos-fabric:8181/onos/v1/applications/org.onosproject.vrouter/active
	http -a karaf:karaf POST http://onos-fabric:8181/onos/v1/applications/org.onosproject.segmentrouting/active

fabric: fabric.yaml
	cp ../../xos_services/fabric/config/network-cfg-quickstart.json .
	$(RUN_TOSCA) fabric.yaml

cord: vsg_custom_images
	$(RUN_TOSCA) $(COMMON_DIR)/tosca/mgmt-net.yaml
	$(RUN_TOSCA) cord-services.yaml
	$(RUN_TOSCA) $(COMMON_DIR)/tosca/cord-volt-devices.yaml

cord-subscriber:
	$(RUN_TOSCA) cord-test-subscriber.yaml

update_nodes: nodes.yaml
	$(RUN_TOSCA) nodes.yaml

new-nodes: clean_nodes update_nodes vtn

rebuild:
	bash $(COMMON_DIR)/rebuild.sh $(XOS_BOOTSTRAP_PORT)
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh 81 xos

exampleservice: onboard-exampleservice
	$(RUN_TOSCA) pod-exampleservice.yaml

onboard-exampleservice:
	sudo cp id_rsa key_import/exampleservice_rsa
	sudo cp id_rsa.pub key_import/exampleservice_rsa.pub
	$(RUN_TOSCA_BOOTSTRAP) $(COMMON_DIR)/tosca/disable-onboarding.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/exampleservice/xos/exampleservice-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) exampleservice-synchronizer.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(COMMON_DIR)/tosca/enable-onboarding.yaml
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh 81 services/exampleservice
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh 81 xos
	bash $(COMMON_DIR)/wait_for_xos_port.sh 80

cord-monitoringservice: ceilometer_custom_images onboard-monitoringservice
	$(RUN_TOSCA) monitoringservice.yaml
	$(RUN_TOSCA) monitoringtenant.yaml

onboard-monitoringservice: monitoring_services
	sudo cp id_rsa key_import/monitoringservice_rsa
	sudo cp id_rsa.pub key_import/monitoringservice_rsa.pub
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/monitoring/xos/monitoring-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) monitoring_synchronizer.yaml
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh 81 services/monitoring
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh 81 xos
	bash $(COMMON_DIR)/wait_for_xos_port.sh 80

monitoring_services: $(SERVICE_DIR)/monitoring

vtn-external.yaml:
	export SETUPDIR=$(CONFIG_DIR); bash ./make-vtn-external-yaml.sh

fabric.yaml:
	export SETUPDIR=$(CONFIG_DIR); bash ./make-fabric-yaml.sh

virtualbng_json:
	export SETUPDIR=$(CONFIG_DIR); bash ./make-virtualbng-json.sh

vtn_network_cfg_json:
	export SETUPDIR=$(CONFIG_DIR); bash ./make-vtn-networkconfig-json.sh

