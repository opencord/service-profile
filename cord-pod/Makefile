# cord-pod/Makefile

CONFIG_DIR         := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
COMMON_DIR         := $(abspath ../common )

.DEFAULT_GOAL      := xos

DOCKER_PROJECT     ?= cordpod
BOOTSTRAP_PROJECT  ?= cordpodbs

XOS_UI_PORT        := 9000

# Include common functions
include $(COMMON_DIR)/Makefile

xos: prereqs config_dirs xos_download cord_services cord_libraries bootstrap onboarding rest-gw ui

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
	$(RUN_TOSCA_BOOTSTRAP) $(LIBRARY_DIR)/ng-xos-lib/ng-xos-lib-onboard.yaml
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
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/ng-xos-lib
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/vrouter
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/volt
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/vsg
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/vtn
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/onos
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/fabric
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/vtr
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) xos
	bash $(COMMON_DIR)/wait_for_xos_port.sh $(XOS_UI_PORT)
	sleep 120

nodes: nodes.yaml
	@echo "[NODES]"
	$(RUN_TOSCA) openstack.yaml
	$(RUN_TOSCA) nodes.yaml
	sleep 10

vtn: nodes vtn.yaml
	@echo "[VTN]"
	$(RUN_TOSCA) vtn.yaml

delete_fabric_config:
	http -a karaf:karaf DELETE http://onos-fabric:8181/onos/v1/network/configuration/

reactivate_fabric_apps:
	http -a karaf:karaf POST http://onos-fabric:8181/onos/v1/applications/org.onosproject.vrouter/active
	http -a karaf:karaf POST http://onos-fabric:8181/onos/v1/applications/org.onosproject.segmentrouting/active

fabric:
	@echo "[FABRIC]"
	cp $(SERVICE_DIR)/fabric/config/network-cfg-quickstart.json .
	$(RUN_TOSCA) fabric.yaml
	sleep 20

cord:
	@echo "[CORD]"
	$(RUN_TOSCA) management-net.yaml
	$(RUN_TOSCA) cord-services.yaml
	$(RUN_TOSCA) public-net.yaml
	$(RUN_TOSCA) $(COMMON_DIR)/tosca/cord-volt-devices.yaml

vrouter:
	$(RUN_TOSCA) ./vrouter.yaml

cord-subscriber:
	@echo "[CORD-SUBSCRIBER]"
	$(RUN_TOSCA) cord-test-subscriber.yaml
	sleep 60

exampleservice: $(SERVICE_DIR)/exampleservice
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
	$(RUN_TOSCA) exampleservice.yaml
	sleep 60

cord-monitoringservice: $(SERVICE_DIR)/monitoring
	@echo "[CORD-MONITORINGSERVICE]"
	sudo cp id_rsa key_import/monitoringservice_rsa
	sudo cp id_rsa.pub key_import/monitoringservice_rsa.pub
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/monitoring/xos/monitoring-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) monitoring_synchronizer.yaml
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/monitoring
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) xos
	bash $(COMMON_DIR)/wait_for_xos_port.sh $(XOS_UI_PORT)
	$(RUN_TOSCA) monitoringservice.yaml
	$(RUN_TOSCA) monitoringtenant.yaml
	@echo "waiting for monitoring service to be fully ready...."
	ansible-playbook -i local $(SERVICE_DIR)/monitoring/xos/test/monitoring_test_initial.yaml

rebuild-monitoringservice:
	bash $(COMMON_DIR)/rebuild.sh $(XOS_BOOTSTRAP_PORT) monitoring
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) xos

rebuild-exampleservice:
	bash $(COMMON_DIR)/rebuild.sh $(XOS_BOOTSTRAP_PORT) exampleservice
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) xos

install-inframonitoring-agents:
	bash $(SERVICE_DIR)/monitoring/xos/synchronizer/ceilometer/monitoring_agent/install_monitoring_ceilometer.sh

enable-inframonitoring: inframonitoring_yaml
	$(RUN_TOSCA) inframonitoring.yaml
	@echo "Validate if infra metrics are available...."
	ansible-playbook -i local $(SERVICE_DIR)/monitoring/xos/test/monitoring_test_inframetrics.yaml

enable-vsgmonitoring:
	$(RUN_TOSCA) vsgmonitoring.yaml
	@echo "Validate if vSG metrics are available...."
	ansible-playbook -i local $(SERVICE_DIR)/monitoring/xos/test/monitoring_test_vsgmetrics.yaml

enable-exampleservicemonitoring:
	$(RUN_TOSCA) exampleservicemonitoring.yaml
	@echo "Validate if exampleservice metrics are available...."
	ansible-playbook -i local $(SERVICE_DIR)/monitoring/xos/test/monitoring_test_exampleservicemetrics.yaml

inframonitoring_yaml:
	export SETUPDIR=$(CONFIG_DIR); bash ./make-inframonitoring-yaml.sh

virtualbng_json:
	export SETUPDIR=$(CONFIG_DIR); bash ./make-virtualbng-json.sh
