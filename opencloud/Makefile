include ../common/Makedefs

CONFIG_DIR           ?= $(shell pwd)
DOCKER_COMPOSE_YML   ?= ./onboarding-docker-compose/docker-compose.yml
BOOTSTRAP_YML        ?= ./docker-compose-bootstrap.yml
DOCKER_PROJECT       ?= oc
BOOTSTRAP_PROJECT    ?= ocb
XOS_BOOTSTRAP_PORT   ?= 81
XOS_UI_PORT          ?= 80
ADMIN_USERNAME       ?= padmin@vicci.org
ADMIN_PASSWORD       ?= letmein
RUN_TOSCA_BOOTSTRAP  ?= python ../common/run_tosca.py $(XOS_BOOTSTRAP_PORT) $(ADMIN_USERNAME) $(ADMIN_PASSWORD)
RUN_TOSCA            ?= python ../common/run_tosca.py $(XOS_UI_PORT) $(ADMIN_USERNAME) $(ADMIN_PASSWORD)

.PHONY: local_containers
local_containers: prereqs download_xos
	make -f ../common/Makefile.containers update_certs xos_base xos_devel synchronizer onboarding_synchronizer

prereqs:
	make -f ../common/Makefile.prereqs

download_xos:
	make -f ../common/Makefile.services xos_core

.PHONY: xos
xos: prereqs dirs download_xos opencloud_services bootstrap onboarding podconfig

dirs:
	mkdir -p ./key_import
	mkdir -p ./onboarding-docker-compose
	mkdir -p ./images

opencloud_services:
	make -f ../common/Makefile.services opencloud_services

bootstrap: $(BOOTSTRAP_YML) xos.yaml
	@echo "[BOOTSTRAP]"
	@echo "XOS Image Build Date: `docker inspect -f '{{ .Created }}' xosproject/xos`"
	@echo "XOS Image Commit Hash: `docker inspect -f '{{ .Config.Labels.XOS_GIT_COMMIT_HASH }}' xosproject/xos`"
	@echo "XOS Image Commit Date: `docker inspect -f '{{ .Config.Labels.XOS_GIT_COMMIT_DATE }}' xosproject/xos`"
	sudo rm -f $(DOCKER_COMPOSE_YML)
	sudo CONFIG_DIR=$(CONFIG_DIR) docker-compose -p $(BOOTSTRAP_PROJECT) -f $(BOOTSTRAP_YML) up -d
	bash ../common/wait_for_xos_port.sh $(XOS_BOOTSTRAP_PORT)
	sudo docker-compose -p $(BOOTSTRAP_PROJECT) -f $(BOOTSTRAP_YML) run xos_bootstrap_ui python /opt/xos/tosca/run.py none - < ../common/tosca/fixtures.yaml
	sudo docker-compose -p $(BOOTSTRAP_PROJECT) -f $(BOOTSTRAP_YML) run xos_bootstrap_ui python /opt/xos/tosca/run.py none - < ../common/tosca/mydeployment.yaml
	$(RUN_TOSCA_BOOTSTRAP) xos.yaml

onboarding: synchronizers.yaml
	@echo "[ONBOARDING]"
	# on-board any services here
	bash ../common/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) xos
	$(RUN_TOSCA_BOOTSTRAP) ../common/tosca/disable-onboarding.yaml
	sudo cp id_rsa key_import/onos_rsa
	sudo cp id_rsa key_import/onos_rsa.pub
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/openstack/xos/openstack-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/vrouter/xos/vrouter-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/vtn/xos/vtn-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/onos-service/xos/onos-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) synchronizers.yaml
	$(RUN_TOSCA_BOOTSTRAP) ../common/tosca/enable-onboarding.yaml
	bash ../common/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/vrouter
	bash ../common/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/vtn
	bash ../common/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/onos
	bash ../common/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) xos
	bash ../common/wait_for_xos_port.sh $(XOS_UI_PORT)

podconfig: nodes.yaml images.yaml
	@echo "[PODCONFIG]"
	$(RUN_TOSCA) ../common/tosca/setup.yaml
	$(RUN_TOSCA) nodes.yaml
	$(RUN_TOSCA) images.yaml

nodes.yaml:
	export SETUPDIR=.; bash ../common/make-nodes-yaml.sh

images.yaml:
	export SETUPDIR=.; bash ../common/make-images-yaml.sh

# manual operation targets

cleanup: stop rm
	./cleanup.sh
	bash -c "source ./admin-openrc.sh; nova list --all-tenants; neutron net-list"

stop:
	test ! -s $(DOCKER_COMPOSE_YML) || sudo docker-compose -p $(DOCKER_PROJECT) -f $(DOCKER_COMPOSE_YML) stop
	sudo docker-compose -p $(BOOTSTRAP_PROJECT) -f $(BOOTSTRAP_YML) stop

rm: stop
	test ! -s $(DOCKER_COMPOSE_YML) || sudo docker-compose -p $(DOCKER_PROJECT) -f $(DOCKER_COMPOSE_YML) rm -f
	sudo docker-compose -p $(BOOTSTRAP_PROJECT) -f $(BOOTSTRAP_YML) rm -f
	[ -n "$(shell docker images -f \"dangling=true\" -q)" ] && docker rmi $(shell docker images -f "dangling=true" -q) || true

update_xos:
	make -f ../common/Makefile.services update_xos

showlogs_bootstrap:
	sudo docker-compose -p $(BOOTSTRAP_PROJECT) -f $(BOOTSTRAP_YML) logs

showlogs:
	sudo docker-compose -p $(DOCKER_PROJECT) -f $(DOCKER_COMPOSE_YML) logs

