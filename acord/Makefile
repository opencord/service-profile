include ../common/Makedefs

MYIP:=$(shell hostname -i)
CONFIG_DIR:=$(shell pwd)
DOCKER_COMPOSE_YML=./onboarding-docker-compose/docker-compose.yml
BOOTSTRAP_YML=./docker-compose-bootstrap.yml
DOCKER_PROJECT=acord
BOOTSTRAP_PROJECT=acordbs
XOS_BOOTSTRAP_PORT=9998
XOS_UI_PORT=9999
ADMIN_USERNAME=padmin@vicci.org
ADMIN_PASSWORD=letmein
RUN_TOSCA_BOOTSTRAP=python ../common/run_tosca.py $(XOS_BOOTSTRAP_PORT) $(ADMIN_USERNAME) $(ADMIN_PASSWORD)
RUN_TOSCA=python ../common/run_tosca.py $(XOS_UI_PORT) $(ADMIN_USERNAME) $(ADMIN_PASSWORD)

cloudlab: download_xos common_cloudlab local_containers xos

devstack: download_xos upgrade_pkgs common_devstack local_containers xos devstack_net_fix

xos: dirs download_services bootstrap onboarding develconfig

dirs:
	# if this directory doesn't exist, then docker-compose will create it with root permission
	mkdir -p key_import
	mkdir -p onboarding-docker-compose

download_xos:
	make -f ../common/Makefile.services xos_core

download_services:
	make -f ../common/Makefile.services

bootstrap:
	echo "[BOOTSTRAP]"
	sudo rm -f onboarding-docker-compose/docker-compose.yml
	sudo CONFIG_DIR=$(CONFIG_DIR) MYIP=$(MYIP) docker-compose -p $(BOOTSTRAP_PROJECT) -f $(BOOTSTRAP_YML) up -d
	bash ../common/wait_for_xos_port.sh $(XOS_BOOTSTRAP_PORT)
	sudo docker-compose -p $(BOOTSTRAP_PROJECT) -f $(BOOTSTRAP_YML) run xos_bootstrap_ui python /opt/xos/tosca/run.py none - < ../common/fixtures.yaml
	sudo docker-compose -p $(BOOTSTRAP_PROJECT) -f $(BOOTSTRAP_YML) run xos_bootstrap_ui python /opt/xos/tosca/run.py none - < ../common/mydeployment.yaml
	$(RUN_TOSCA_BOOTSTRAP) xos.yaml

onboarding:
	echo "[ONBOARDING]"
	# on-board any services here
	bash ../common/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) xos
	bash ../common/wait_for_xos_port.sh $(XOS_UI_PORT)

develconfig:
	$(RUN_TOSCA) ../common/cloudlab-openstack.yaml
	$(RUN_TOSCA) ../setup/nodes.yaml

cord-monitoringservice: devstack_ceilometer_custom_images onboard-monitoringservice ceilometer_devstack_cord_plugins
	$(RUN_TOSCA) ceilometer.yaml

onboard-monitoringservice: download-monitoringservice
	sudo cp ~/.ssh/id_rsa key_import/monitoringservice_rsa
	sudo cp ~/.ssh/id_rsa.pub key_import/monitoringservice_rsa.pub
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/monitoring/xos/monitoring-onboard.yaml
	bash ../common/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/monitoring
	bash ../common/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) xos
	bash ../common/wait_for_xos_port.sh $(XOS_UI_PORT)

download-monitoringservice:
	make -f ../common/Makefile.services monitoring_services

exampleservice:
	#Ensure exampleservice is enabled in xos/tools/xos-manage and xos/settings.py file before uncommenting below lines
	#sudo docker-compose run xos python /opt/xos/tosca/run.py padmin@vicci.org /opt/xos/configurations/acord/acord-exampleservice.yaml

containers:
	cd ../../../containers/xos; make devel
	cd ../../../containers/synchronizer; make

common_cloudlab:
	make -C ../common -f Makefile.cloudlab

common_devstack:
	make -C ../common -f Makefile.devstack

local_containers:
	make -f ../common/Makefile.containers update_certs xos_base xos_devel synchronizer onboarding_synchronizer

ceilometer_cloudlab_cord_plugins:
	if [ -d ./ceilometer-plugins ]; then rm -fr ./ceilometer-plugins; fi
	git clone https://github.com/srikanthvavila/ceilometer-plugins.git
	sudo cp -r ceilometer-plugins/network/ext_services /usr/lib/python2.7/dist-packages/ceilometer/network/
	sudo cp -r ceilometer-plugins/network/statistics/onos /usr/lib/python2.7/dist-packages/ceilometer/network/statistics/
	sudo cp ceilometer-plugins/network/statistics/__init__.py /usr/lib/python2.7/dist-packages/ceilometer/network/statistics/ 
	sudo cp ceilometer-plugins/entry_points.txt /usr/lib/python2.7/dist-packages/ceilometer-*egg-info/
	sudo cp ceilometer-plugins/pipeline.yaml /etc/ceilometer/
	echo "Restarting ceilometer-agent-notification"
	sudo service ceilometer-agent-notification restart
	echo "Restarting ceilometer-agent-central"
	sudo service ceilometer-agent-central restart

ceilometer_devstack_cord_plugins:
	#if [ -d ./ceilometer-plugins ]; then rm -fr ./ceilometer-plugins; fi
	#git clone https://github.com/srikanthvavila/ceilometer-plugins.git
	#sudo cp -r ceilometer-plugins/network/ext_services /opt/stack/ceilometer/ceilometer/network/
	#sudo cp ceilometer-plugins/entry_points.txt /opt/stack/ceilometer/ceilometer*egg-info/
	#sudo cp ceilometer-plugins/pipeline.yaml /etc/ceilometer/
	#echo "Remember to restart ceilometer-anotification ceilometer-acentral screens"

ceilometer_pub_sub:
	if [ -d ./pub-sub ]; then rm -fr ./pub-sub; fi
	git clone https://github.com/srikanthvavila/pub-sub.git
	echo "Starting Ceilometer PUB/SUB service...Ensure zookeeper and kafka services are launched (if required)"
	cd pub-sub/ceilometer_pub_sub/ ; python sub_main.py & 
	cd ../..

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
	bash -c "source ../setup/admin-openrc.sh; nova list --all-tenants; neutron net-list"

ps:
	sudo MYIP=$(MYIP) docker-compose ps

devstack_net_fix:
	sudo ../common/devstack/net-fix.sh
	sudo bash -c "source ../setup/admin-openrc.sh; neutron subnet-update private-subnet --dns-nameservers list=true 8.8.8.8 8.8.4.4"

upgrade_pkgs:
	sudo pip install httpie --upgrade

rebuild_xos:
	make -C ../../../containers/xos devel

rebuild_synchronizer:
	make -C ../../../containers/synchronizer

devstack_ceilometer_custom_images:
	#Assuming Openstack Mitaka backend. The glance commands require --os-image-api-version 1 to be passed to use v1 version of glance APIs
	bash -c "source ../setup/admin-openrc.sh; glance --os-image-api-version 1 image-show ceilometer-trusty-server-multi-nic || ! mkdir -p /opt/stack/images || ! wget http://www.vicci.org/cord/ceilometer-trusty-server-multi-nic.compressed.qcow2 -P /opt/stack/images || glance image-create --name ceilometer-trusty-server-multi-nic --disk-format qcow2 --file /opt/stack/images/ceilometer-trusty-server-multi-nic.compressed.qcow2 --container-format bare"

cloudlab_ceilometer_custom_images:
	bash -c "source ../setup/admin-openrc.sh; glance image-show --os-image-api-version 1 ceilometer-trusty-server-multi-nic || if test -f /proj/xos-PG0/images/ceilometer-trusty-server-multi-nic.compressed.qcow2 ; then glance image-create --name ceilometer-trusty-server-multi-nic --disk-format qcow2 --file /proj/xos-PG0/images/ceilometer-trusty-server-multi-nic.compressed.qcow2 --container-format bare ; else mkdir -p /tmp/images && wget http://www.vicci.org/cord/ceilometer-trusty-server-multi-nic.compressed.qcow2 -P /tmp/images && glance image-create --name ceilometer-trusty-server-multi-nic --disk-format qcow2 --file /tmp/images/ceilometer-trusty-server-multi-nic.compressed.qcow2 --container-format bare ; fi "

