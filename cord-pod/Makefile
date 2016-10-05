# cord-pod/Makefile

CONFIG_DIR         := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
COMMON_DIR         := $(abspath ../common )

.DEFAULT_GOAL      := xos

DOCKER_PROJECT     ?= cordpod
BOOTSTRAP_PROJECT  ?= cordpodbs

# Include common functions
include $(COMMON_DIR)/Makefile

xos: prereqs config_dirs xos_download cord_services bootstrap onboarding podconfig

onboarding: synchronizers.yaml id_rsa id_rsa.pub
	@echo "[ONBOARDING]"
	# on-board any services here
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) xos
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
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/vrouter
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/volt
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/vsg
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/vtn
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/onos
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/fabric
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/vtr
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) xos
	bash $(COMMON_DIR)/wait_for_xos_port.sh $(XOS_UI_PORT)

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

vsg_custom_images: images/vsg-1.1.img
	bash -c "source ./admin-openrc.sh; glance image-show vsg-1.1 || glance image-create --name vsg-1.1 --disk-format qcow2 --file ./images/vsg-1.1.img --container-format bare"

cord-subscriber:
	$(RUN_TOSCA) cord-test-subscriber.yaml

update_nodes: nodes.yaml
	$(RUN_TOSCA) nodes.yaml

new-nodes: clean_nodes update_nodes vtn

exampleservice: onboard-exampleservice
	$(RUN_TOSCA) pod-exampleservice.yaml

onboard-exampleservice: $(SERVICE_DIR)/exampleservice
	sudo cp id_rsa key_import/exampleservice_rsa
	sudo cp id_rsa.pub key_import/exampleservice_rsa.pub
	$(RUN_TOSCA_BOOTSTRAP) $(COMMON_DIR)/tosca/disable-onboarding.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/exampleservice/xos/exampleservice-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) exampleservice-synchronizer.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(COMMON_DIR)/tosca/enable-onboarding.yaml
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/exampleservice
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) xos
	bash $(COMMON_DIR)/wait_for_xos_port.sh $(XOS_UI_PORT)

cord-monitoringservice: ceilometer_custom_images onboard-monitoringservice
	$(RUN_TOSCA) monitoringservice.yaml
	$(RUN_TOSCA) monitoringtenant.yaml

onboard-monitoringservice: $(SERVICE_DIR)/monitoring
	sudo cp id_rsa key_import/monitoringservice_rsa
	sudo cp id_rsa.pub key_import/monitoringservice_rsa.pub
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/monitoring/xos/monitoring-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) monitoring_synchronizer.yaml
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/monitoring
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) xos
	bash $(COMMON_DIR)/wait_for_xos_port.sh $(XOS_UI_PORT)

vtn-external.yaml:
	export SETUPDIR=$(CONFIG_DIR); bash ./make-vtn-external-yaml.sh

fabric.yaml:
	export SETUPDIR=$(CONFIG_DIR); bash ./make-fabric-yaml.sh

virtualbng_json:
	export SETUPDIR=$(CONFIG_DIR); bash ./make-virtualbng-json.sh

