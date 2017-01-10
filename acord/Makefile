# acord/Makefile

CONFIG_DIR         := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
COMMON_DIR         := $(abspath ../common )

.DEFAULT_GOAL      := xos

DOCKER_PROJECT     ?= acord
BOOTSTRAP_PROJECT  ?= acordbs

DB_NAME            ?= $(BOOTSTRAP_PROJECT)_xos_db_1

XOS_BOOTSTRAP_PORT ?= 9001
XOS_UI_PORT        ?= 9000

# Include common functions
include $(COMMON_DIR)/Makefile

cloudlab: download_xos common_cloudlab local_containers xos

devstack: download_xos upgrade_pkgs common_devstack local_containers xos devstack_net_fix

xos: prereqs config_dirs xos_download cord_services cord_libraries bootstrap onboarding develconfig

onboarding:
	echo "[ONBOARDING]"
	# on-board any services here
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) xos
	bash $(COMMON_DIR)/wait_for_xos_port.sh $(XOS_UI_PORT)

develconfig:
	$(RUN_TOSCA) $(COMMON_DIR)/tosca/cloudlab-openstack.yaml
	$(RUN_TOSCA) ../setup/nodes.yaml

cord-monitoringservice: devstack_ceilometer_custom_images onboard-monitoringservice ceilometer_devstack_cord_plugins
	$(RUN_TOSCA) ceilometer.yaml

onboard-monitoringservice: $(SERVICE_DIR)/monitoring
	sudo cp ~/.ssh/id_rsa key_import/monitoringservice_rsa
	sudo cp ~/.ssh/id_rsa.pub key_import/monitoringservice_rsa.pub
	$(RUN_TOSCA_BOOTSTRAP) $(LIBRARY_DIR)/ng-xos-lib/ng-xos-lib-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/monitoring/xos/monitoring-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(LIBRARY_DIR)/ng-xos-lib/ng-xos-lib-onboard.yaml
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/monitoring
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) xos
	bash $(COMMON_DIR)/wait_for_xos_port.sh $(XOS_UI_PORT)

exampleservice:
	#Ensure exampleservice is enabled in xos/tools/xos-manage and xos/settings.py file before uncommenting below lines
	#sudo docker-compose run xos python /opt/xos/tosca/run.py padmin@vicci.org /opt/xos/configurations/acord/acord-exampleservice.yaml

common_cloudlab:
	make -C $(COMMON_DIR) -f Makefile.cloudlab

common_devstack:
	make -C $(COMMON_DIR) -f Makefile.devstack

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

devstack_net_fix:
	sudo $(COMMON_DIR)/devstack/net-fix.sh
	sudo bash -c "source ../setup/admin-openrc.sh; neutron subnet-update private-subnet --dns-nameservers list=true 8.8.8.8 8.8.4.4"

devstack_ceilometer_custom_images:
	#Assuming Openstack Mitaka backend. The glance commands require --os-image-api-version 1 to be passed to use v1 version of glance APIs
	bash -c "source ../setup/admin-openrc.sh; glance --os-image-api-version 1 image-show ceilometer-trusty-server-multi-nic || ! mkdir -p /opt/stack/images || ! wget http://www.vicci.org/cord/ceilometer-trusty-server-multi-nic.compressed.qcow2 -P /opt/stack/images || glance image-create --name ceilometer-trusty-server-multi-nic --disk-format qcow2 --file /opt/stack/images/ceilometer-trusty-server-multi-nic.compressed.qcow2 --container-format bare"

cloudlab_ceilometer_custom_images:
	bash -c "source ../setup/admin-openrc.sh; glance image-show --os-image-api-version 1 ceilometer-trusty-server-multi-nic || if test -f /proj/xos-PG0/images/ceilometer-trusty-server-multi-nic.compressed.qcow2 ; then glance image-create --name ceilometer-trusty-server-multi-nic --disk-format qcow2 --file /proj/xos-PG0/images/ceilometer-trusty-server-multi-nic.compressed.qcow2 --container-format bare ; else mkdir -p /tmp/images && wget http://www.vicci.org/cord/ceilometer-trusty-server-multi-nic.compressed.qcow2 -P /tmp/images && glance image-create --name ceilometer-trusty-server-multi-nic --disk-format qcow2 --file /tmp/images/ceilometer-trusty-server-multi-nic.compressed.qcow2 --container-format bare ; fi "

