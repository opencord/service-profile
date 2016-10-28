# common/Makefile

include $(COMMON_DIR)/Makedefs

# prerequisite software
.PHONY: prereqs
prereqs: /usr/bin/http /usr/bin/docker /usr/bin/curl /usr/local/bin/docker-compose

apt-prereqs:
	sudo apt-get update
	sudo apt-get -y install apt-transport-https ca-certificates python-pip
	touch $@

/usr/bin/http: | apt-prereqs
	sudo apt-get -y install httpie

/usr/bin/curl: | apt-prereqs
	sudo apt-get -y install curl

/usr/bin/docker: | apt-prereqs
	sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
	echo "deb https://apt.dockerproject.org/repo ubuntu-`lsb_release -c | awk '{print $$2}'` main" | sudo tee /etc/apt/sources.list.d/docker.list
	sudo apt-get update
	sudo apt-get -y install docker-engine
	sudo usermod -aG docker $(shell whoami)

/usr/local/bin/docker-compose: | apt-prereqs
	sudo pip install docker-compose


# configuration
config_dirs:
	mkdir -p $(CONFIG_DIR)/key_import
	mkdir -p $(CONFIG_DIR)/onboarding-docker-compose
	mkdir -p $(CONFIG_DIR)/images

nodes.yaml:
	export SETUPDIR=$(CONFIG_DIR); bash $(COMMON_DIR)/make-nodes-yaml.sh

clean_nodes:
	rm -f $(CONFIG_DIR)/nodes.yaml

images.yaml:
	export SETUPDIR=$(CONFIG_DIR); bash $(COMMON_DIR)/make-images-yaml.sh


# download/clone xos and service repos
GITOPTS ?= -c advice.detachedHead=false

xos_download: $(XOS_DIR)

$(XOS_DIR):
	git -C $(HOME_DIR) $(GITOPTS) clone -b $(XOS_BRANCH) $(XOS_GIT_URL)

update_xos:
	git -C $(XOS_DIR) pull

cord_services: $(SERVICE_DIR) \
	$(SERVICE_DIR)/exampleservice \
	$(SERVICE_DIR)/fabric \
	$(SERVICE_DIR)/hypercache \
	$(SERVICE_DIR)/olt \
	$(SERVICE_DIR)/onos-service \
	$(SERVICE_DIR)/openstack \
	$(SERVICE_DIR)/vrouter \
	$(SERVICE_DIR)/vsg \
	$(SERVICE_DIR)/vtn \
	$(SERVICE_DIR)/vtr \
	$(SERVICE_DIR)/metro-net

$(SERVICE_DIR):
	mkdir -p $(SERVICE_DIR)

$(SERVICE_DIR)/exampleservice:
	git -C $(SERVICE_DIR) $(GITOPTS) clone -b $(EXAMPLESERVICE_BRANCH) $(EXAMPLESERVICE_GIT_URL)

$(SERVICE_DIR)/olt:
	git -C $(SERVICE_DIR) $(GITOPTS) clone -b $(OLT_BRANCH) $(OLT_GIT_URL)

$(SERVICE_DIR)/vsg:
	git -C $(SERVICE_DIR) $(GITOPTS) clone -b $(VSG_BRANCH) $(VSG_GIT_URL)

$(SERVICE_DIR)/vtn:
	git -C $(SERVICE_DIR) $(GITOPTS) clone -b $(VTN_BRANCH) $(VTN_GIT_URL)

$(SERVICE_DIR)/vrouter:
	git -C $(SERVICE_DIR) $(GITOPTS) clone -b $(VROUTER_BRANCH) $(VROUTER_GIT_URL)

$(SERVICE_DIR)/vtr:
	git -C $(SERVICE_DIR) $(GITOPTS) clone -b $(VTR_BRANCH) $(VTR_GIT_URL)

$(SERVICE_DIR)/onos-service:
	git -C $(SERVICE_DIR) $(GITOPTS) clone -b $(ONOS_BRANCH) $(ONOS_GIT_URL)

$(SERVICE_DIR)/fabric:
	git -C $(SERVICE_DIR) $(GITOPTS) clone -b $(FABRIC_BRANCH) $(FABRIC_GIT_URL)

$(SERVICE_DIR)/monitoring:
	git -C $(SERVICE_DIR) $(GITOPTS) clone -b $(MONITORING_BRANCH) $(MONITORING_GIT_URL)

$(SERVICE_DIR)/hypercache:
	git -C $(SERVICE_DIR) $(GITOPTS) clone -b $(HYPERCACHE_BRANCH) $(HYPERCACHE_GIT_URL)

$(SERVICE_DIR)/metro-net:
	git -C $(SERVICE_DIR) $(GITOPTS) clone -b $(METRONETWORK_BRANCH) $(METRONETWORK_GIT_URL)

$(SERVICE_DIR)/openstack:
	git -C $(SERVICE_DIR) $(GITOPTS) clone -b $(OPENSTACK_BRANCH) $(OPENSTACK_GIT_URL)

update_services:
	git -C $(SERVICE_DIR)/exampleservice pull
	git -C $(SERVICE_DIR)/olt pull
	git -C $(SERVICE_DIR)/vsg pull
	git -C $(SERVICE_DIR)/vtn pull
	git -C $(SERVICE_DIR)/vrouter pull
	git -C $(SERVICE_DIR)/vtr pull
	git -C $(SERVICE_DIR)/onos-service pull
	git -C $(SERVICE_DIR)/fabric pull
	git -C $(SERVICE_DIR)/hypercache pull
	git -C $(SERVICE_DIR)/metro-net pull
	git -C $(SERVICE_DIR)/openstack pull

cord_libraries: $(LIBRARY_DIR) \
        $(LIBRARY_DIR)/ng-xos-lib

$(LIBRARY_DIR):
	mkdir -p $(LIBRARY_DIR)

$(LIBRARY_DIR)/ng-xos-lib:
	git -C $(LIBRARY_DIR) $(GITOPTS) clone -b $(NG_XOS_LIB_BRANCH) $(NG_XOS_LIB_URL)

# bootstrap the containers

RUN_TOSCA_BOOTSTRAP ?= python $(COMMON_DIR)/run_tosca.py $(XOS_BOOTSTRAP_PORT) $(ADMIN_USERNAME) $(ADMIN_PASSWORD)
RUN_TOSCA ?= python $(COMMON_DIR)/run_tosca.py $(XOS_UI_PORT) $(ADMIN_USERNAME) $(ADMIN_PASSWORD)

bootstrap: $(BOOTSTRAP_YML) $(CONFIG_DIR)/xos.yaml
	@echo "[BOOTSTRAP]"
	@echo "XOS Image Build Date: `sudo docker inspect -f '{{ .Created }}' xosproject/xos`"
	@echo "XOS Image Commit Hash: `sudo docker inspect -f '{{ .Config.Labels.XOS_GIT_COMMIT_HASH }}' xosproject/xos`"
	@echo "XOS Image Commit Date: `sudo docker inspect -f '{{ .Config.Labels.XOS_GIT_COMMIT_DATE }}' xosproject/xos`"
	sudo rm -f $(DOCKER_COMPOSE_YML)
	sudo CONFIG_DIR=$(CONFIG_DIR) docker-compose -p $(BOOTSTRAP_PROJECT) -f $(BOOTSTRAP_YML) up -d
	bash $(COMMON_DIR)/wait_for_xos_port.sh $(XOS_BOOTSTRAP_PORT)
	sudo docker-compose -p $(BOOTSTRAP_PROJECT) -f $(BOOTSTRAP_YML) run xos_bootstrap_ui python /opt/xos/tosca/run.py none - < $(COMMON_DIR)/tosca/fixtures.yaml
	sudo docker-compose -p $(BOOTSTRAP_PROJECT) -f $(BOOTSTRAP_YML) run xos_bootstrap_ui python /opt/xos/tosca/run.py none - < $(COMMON_DIR)/tosca/mydeployment.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(CONFIG_DIR)/xos.yaml


# container creation targets

local_containers: prereqs xos_download update_certs xos_base_c xos_devel_c

test_containers: local_containers xos_test_c

update_certs:
	echo "" > $(XOS_DIR)/containers/xos/local_certs.crt
	for CRT in $$(ls /usr/local/share/ca-certificates/*) ; do \
	        echo Adding Certificate: $$CRT ;\
	        cat $$CRT >> $(XOS_DIR)/containers/xos/local_certs.crt ;\
	        echo "" >> $(XOS_DIR)/containers/xos/local_certs.crt ;\
	done

xos_base_c:
	cd $(XOS_DIR)/containers/xos; make base

xos_devel_c:
	cd $(XOS_DIR)/containers/xos; make devel

xos_test_c:
	cd $(XOS_DIR)/containers/xos; make test


# image downloads

$(CONFIG_DIR)images/trusty-server-multi-nic.img: config_dirs
	curl -fLsS http://www.vicci.org/opencloud/trusty-server-cloudimg-amd64-disk1.img -o $@
	echo "c2d0ffc937aeb96016164881052a496658efeb98959dc68e73d9895c5d9920f7  $@" | sha256sum -c -

$(CONFIG_DIR)images/vsg-1.1.img: config_dirs
	curl -fLsS http://www.vicci.org/cord/vsg-1.1.img -o $@
	echo "16b0beb6778aed0f5feecb05f8d5750e6c262f98e6011e99ddadf7d46a177b6f  $@" | sha256sum -c -

$(CONFIG_DIR)images/ceilometer-trusty-server-multi-nic.img: config_dirs
	curl -fLsS http://www.vicci.org/cord/ceilometer-trusty-server-multi-nic.compressed.qcow2 -o $@
	echo "afde3f0448483902693be4d52ae76bb683fd74b1c7728019094bf81b37d86105  $@" | sha256sum -c -


# utilties/convenience targets
cleanup: stop rm $(CONFIG_DIR)/cleanup.sh
	$(CONFIG_DIR)/cleanup.sh
	bash -c "source $(CONFIG_DIR)/admin-openrc.sh; nova list --all-tenants; neutron net-list"

cleanup_services: $(SERVICE_DIR)
	rm -rf $(SERVICE_DIR)/*

rebuild:
	bash $(COMMON_DIR)/rebuild.sh $(XOS_BOOTSTRAP_PORT)
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) xos

stop:
	test ! -s $(DOCKER_COMPOSE_YML) || sudo docker-compose -p $(DOCKER_PROJECT) -f $(DOCKER_COMPOSE_YML) stop
	sudo docker-compose -p $(BOOTSTRAP_PROJECT) -f $(BOOTSTRAP_YML) stop

rm: stop
	test ! -s $(DOCKER_COMPOSE_YML) || sudo docker-compose -p $(DOCKER_PROJECT) -f $(DOCKER_COMPOSE_YML) rm -f
	sudo docker-compose -p $(BOOTSTRAP_PROJECT) -f $(BOOTSTRAP_YML) rm -f
	[ -n "$(shell docker images -f \"dangling=true\" -q)" ] && docker rmi $(shell docker images -f "dangling=true" -q) || true

ps:
	sudo docker ps

showlogs_bootstrap:
	sudo docker-compose -p $(BOOTSTRAP_PROJECT) -f $(BOOTSTRAP_YML) logs -f

showlogs:
	sudo docker-compose -p $(DOCKER_PROJECT) -f $(DOCKER_COMPOSE_YML) logs -f

enter-ui:
	sudo docker exec -ti $(DOCKER_PROJECT)_xos_ui_1 bash

enter-bootstrap-ui:
	sudo docker exec -ti $(BOOTSTRAP_PROJECT)_xos_bootstrap_ui_1 bash

enter-db:
	sudo docker exec -ti $(BOOTSTRAP_PROJECT)_xos_db_1 bash

django-restart:
	sudo docker exec $(DOCKER_PROJECT)_xos_ui_1 touch /opt/xos/xos/settings.py

