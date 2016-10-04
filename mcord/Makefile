include ../common/Makedefs

CONFIG_DIR:=$(shell pwd)
DOCKER_COMPOSE_YML=./onboarding-docker-compose/docker-compose.yml
BOOTSTRAP_YML=./docker-compose-bootstrap.yml
DOCKER_PROJECT=mcord
BOOTSTRAP_PROJECT=mcordbs
XOS_BOOTSTRAP_PORT=81
XOS_UI_PORT=80
ADMIN_USERNAME=padmin@vicci.org
ADMIN_PASSWORD=letmein
RUN_TOSCA_BOOTSTRAP=python ../common/run_tosca.py $(XOS_BOOTSTRAP_PORT) $(ADMIN_USERNAME) $(ADMIN_PASSWORD)
RUN_TOSCA=python ../common/run_tosca.py $(XOS_UI_PORT) $(ADMIN_USERNAME) $(ADMIN_PASSWORD)

.PHONY: xos
xos: prereqs dirs download_xos download_services bootstrap onboarding podconfig slicing-ui

prereqs:
	sudo make -f ../common/Makefile.prereqs

dirs:
	# if this directory doesn't exist, then docker-compose will create it with root permission
	mkdir -p key_import
	mkdir -p onboarding-docker-compose

bootstrap:
	@echo "[BOOTSTRAP]"
	@echo "XOS Image Build Date: `docker inspect -f '{{ .Created }}' xosproject/xos`"
	@echo "XOS Image Commit Hash: `docker inspect -f '{{ .Config.Labels.XOS_GIT_COMMIT_HASH }}' xosproject/xos`"
	@echo "XOS Image Commit Date: `docker inspect -f '{{ .Config.Labels.XOS_GIT_COMMIT_DATE }}' xosproject/xos`"
	sudo rm -f onboarding-docker-compose/docker-compose.yml
	sudo CONFIG_DIR=$(CONFIG_DIR) docker-compose -p $(BOOTSTRAP_PROJECT) -f $(BOOTSTRAP_YML) up -d
	bash ../common/wait_for_xos_port.sh $(XOS_BOOTSTRAP_PORT)
	sudo docker-compose -p $(BOOTSTRAP_PROJECT) -f $(BOOTSTRAP_YML) run xos_bootstrap_ui python /opt/xos/tosca/run.py none - < ../common/fixtures.yaml
	sudo docker-compose -p $(BOOTSTRAP_PROJECT) -f $(BOOTSTRAP_YML) run xos_bootstrap_ui python /opt/xos/tosca/run.py none - < ../common/mydeployment.yaml
	$(RUN_TOSCA_BOOTSTRAP) xos.yaml

download_xos:
	make -f ../common/Makefile.services xos_core

download_services:
	make -f ../common/Makefile.services

update_services:
	make -f ../common/Makefile.services update

update_xos:
	make -f ../common/Makefile.services update_xos

onboarding:
	@echo "[ONBOARDING]"
	# on-board any services here
	bash ../common/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) xos
	$(RUN_TOSCA_BOOTSTRAP) ../common/disable-onboarding.yaml
        
	sudo cp id_rsa key_import/vBBU_rsa
	sudo cp id_rsa.pub key_import/vBBU_rsa.pub
	sudo cp id_rsa key_import/vPGWC_rsa
	sudo cp id_rsa.pub key_import/vPGWC_rsa.pub
	sudo cp id_rsa key_import/onos_rsa
	sudo cp id_rsa key_import/onos_rsa.pub
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/openstack/xos/openstack-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/vBBU/xos/vBBU-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/vPGWC/xos/vPGWC-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/vtn/xos/vtn-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/onos-service/xos/onos-onboard.yaml
	# $(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/fabric/xos/\fabric-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) synchronizers.yaml
	$(RUN_TOSCA_BOOTSTRAP) ../common/enable-onboarding.yaml
	bash ../common/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/vbbu
	bash ../common/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/vpgwc
	bash ../common/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/vtn
	bash ../common/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/onos
	# bash ../common/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/fabric
	bash ../common/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) xos
	bash ../common/wait_for_xos_port.sh $(XOS_UI_PORT)

podconfig: nodes.yaml images.yaml
	@echo "[PODCONFIG]"
	$(RUN_TOSCA) setup.yaml
	$(RUN_TOSCA) nodes.yaml
	$(RUN_TOSCA) images.yaml

vtn: vtn-external.yaml
	$(RUN_TOSCA) vtn-external.yaml

delete_fabric_config:
	http -a karaf:karaf DELETE http://onos-fabric:8181/onos/v1/network/configuration/

fabric: fabric.yaml
	cp ../../xos_services/fabric/config/network-cfg-quickstart.json .
	$(RUN_TOSCA) fabric.yaml

#cord: vsg_custom_images
mcord:
	$(RUN_TOSCA) mgmt-net.yaml
	$(RUN_TOSCA) mcord.yaml
#	$(RUN_TOSCA) cord-volt-devices.yaml

#cord-subscriber:
#	$(RUN_TOSCA) cord-test-subscriber.yaml

clean-nodes:
	rm -f nodes.yaml

update-nodes: nodes.yaml
	$(RUN_TOSCA) nodes.yaml

new-nodes: clean-nodes update-nodes vtn

rebuild:
	bash ../common/rebuild.sh $(XOS_BOOTSTRAP_PORT)
	bash ../common/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) xos

exampleservice: onboard-exampleservice
	$(RUN_TOSCA) pod-exampleservice.yaml

onboard-exampleservice:
	sudo cp id_rsa key_import/exampleservice_rsa
	sudo cp id_rsa.pub key_import/exampleservice_rsa.pub
	$(RUN_TOSCA_BOOTSTRAP) ../common/disable-onboarding.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/exampleservice/xos/exampleservice-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) exampleservice-synchronizer.yaml
	$(RUN_TOSCA_BOOTSTRAP) ../common/enable-onboarding.yaml
	bash ../common/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/exampleservice
	bash ../common/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) xos
	bash ../common/wait_for_xos_port.sh $(XOS_UI_PORT)

cord-monitoringservice: ceilometer_custom_images onboard-monitoringservice
	$(RUN_TOSCA) monitoringservice.yaml
	$(RUN_TOSCA) monitoringtenant.yaml

onboard-monitoringservice: download-monitoringservice
	sudo cp id_rsa key_import/monitoringservice_rsa
	sudo cp id_rsa.pub key_import/monitoringservice_rsa.pub
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/monitoring/xos/monitoring-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) monitoring_synchronizer.yaml
	bash ../common/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/monitoring
	bash ../common/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) xos
	bash ../common/wait_for_xos_port.sh $(XOS_UI_PORT)

download-monitoringservice:
	make -f ../common/Makefile.services monitoring_services

nodes.yaml:
	export SETUPDIR=.; bash ../common/make-nodes-yaml.sh

images.yaml:
	export SETUPDIR=.; bash ../common/make-images-yaml.sh

vtn-external.yaml:
	export SETUPDIR=.; bash ./make-vtn-external-yaml.sh

fabric.yaml:
	export SETUPDIR=.; bash ./make-fabric-yaml.sh

virtualbng_json:
	export SETUPDIR=.; bash ./make-virtualbng-json.sh

vtn_network_cfg_json:
	export SETUPDIR=.; bash ./make-vtn-networkconfig-json.sh

stop:
	test ! -s $(DOCKER_COMPOSE_YML) || sudo docker-compose -p $(DOCKER_PROJECT) -f $(DOCKER_COMPOSE_YML) stop
	sudo docker-compose -p $(BOOTSTRAP_PROJECT) -f $(BOOTSTRAP_YML) stop

rm: stop
	test ! -s $(DOCKER_COMPOSE_YML) || sudo docker-compose -p $(DOCKER_PROJECT) -f $(DOCKER_COMPOSE_YML) rm -f
	sudo docker-compose -p $(BOOTSTRAP_PROJECT) -f $(BOOTSTRAP_YML) rm -f

showlogs:
	sudo docker-compose -p $(DOCKER_PROJECT) -f $(DOCKER_COMPOSE_YML) logs

showlogs_bootstrap:
	sudo docker-compose -p $(BOOTSTRAP_PROJECT) -f $(BOOTSTRAP_YML) logs

cleanup: stop rm
	./cleanup.sh
	bash -c "source ./admin-openrc.sh; nova list --all-tenants; neutron net-list"

ceilometer_custom_images: images/ceilometer-service-trusty-server-multi-nic.img images/ceilometer-trusty-server-multi-nic.img
	#TODO: Add logic for service VM custom image (ceilometer-service-trusty-server-multi-nic)
	bash -c "source ./admin-openrc.sh; glance image-show ceilometer-trusty-server-multi-nic || glance image-create --name ceilometer-trusty-server-multi-nic --disk-format qcow2 --file ./images/ceilometer-trusty-server-multi-nic.compressed.qcow2 --container-format bare"

#vsg_custom_images: images/vsg-1.1.img
#	bash -c "source ./admin-openrc.sh; glance image-show vsg-1.1 || glance image-create --name vsg-1.1 --disk-format qcow2 --file ./images/vsg-1.1.img --container-format bare"

images/ceilometer-trusty-server-multi-nic.img: images
	bash -c "source ./admin-openrc.sh; glance image-show ceilometer-trusty-server-multi-nic || wget http://www.vicci.org/cord/ceilometer-trusty-server-multi-nic.compressed.qcow2 -P ./images"

images/ceilometer-service-trusty-server-multi-nic.img: images
	#TODO: Add logic for service VM custom image (ceilometer-service-trusty-server-multi-nic) once image is uploaded into vicci portal
	#bash -c "source ../setup/admin-openrc.sh; glance image-show ceilometer-service-trusty-server-multi-nic || wget http://www.vicci.org/cord/ceilometer-service-trusty-server-multi-nic.compressed.qcow2 -P ./images"

#images/vsg-1.1.img: images
#	[ -s images/vsg-1.1.img ] || wget http://www.vicci.org/cord/vsg-1.1.img -P ./images

images:
	mkdir -p ./images

.PHONY: local_containers
local_containers: prereqs download_xos
	make -f ../common/Makefile.containers update_certs xos_base xos_devel synchronizer onboarding_synchronizer

onboard-slicing: slicing-ui
	@echo "[ONBOARDING]"
	# on-board slicing services here
	bash ../common/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) xos
	$(RUN_TOSCA_BOOTSTRAP) ../common/disable-onboarding.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/mcord_slicing_ui/xos/mcord-slicing-onboard.yaml
	bash ../common/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/mcord_slicing_ui
	bash ../common/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) xos
	bash ../common/wait_for_xos_port.sh $(XOS_UI_PORT)

slicing-ui:
	$(RUN_TOSCA) ./mcord-slicing-ui.yaml