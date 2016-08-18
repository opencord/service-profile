include ../common/Makedefs

MYIP:=$(shell hostname -i)
CONFIG_DIR:=$(shell pwd)
DOCKER_COMPOSE_YML=./onboarding-docker-compose/docker-compose.yml
BOOTSTRAP_YML=./docker-compose-bootstrap.yml
DOCKER_PROJECT=metronetwork
BOOTSTRAP_PROJECT=metronetworkdbs
XOS_BOOTSTRAP_PORT=9998
XOS_UI_PORT=9999
ADMIN_USERNAME=padmin@vicci.org
ADMIN_PASSWORD=letmein
RUN_TOSCA_BOOTSTRAP=python ../common/run_tosca.py $(XOS_BOOTSTRAP_PORT) $(ADMIN_USERNAME) $(ADMIN_PASSWORD)
RUN_TOSCA=python ../common/run_tosca.py $(XOS_UI_PORT) $(ADMIN_USERNAME) $(ADMIN_PASSWORD)

metronetwork: prereqs dirs download_xos download_services bootstrap onboarding

prereqs:
	sudo make -f ../common/Makefile.prereqs

dirs:
	# if this directory doesn't exist, then docker-compose will create it with root permission
	mkdir -p key_import
	mkdir -p onboarding-docker-compose

download_xos:
	make -f ../common/Makefile.services xos_core

download_services:
	make -f ../common/Makefile.services

update_services:
	make -f ../common/Makefile.services update

update_xos:
	make -f ../common/Makefile.services update_xos

bootstrap:
	@echo "[BOOTSTRAP]"
	sudo rm -f onboarding-docker-compose/docker-compose.yml
	sudo CONFIG_DIR=$(CONFIG_DIR) docker-compose -p $(BOOTSTRAP_PROJECT) -f $(BOOTSTRAP_YML) up -d
	bash ../common/wait_for_xos_port.sh $(XOS_BOOTSTRAP_PORT)
	sudo docker-compose -p $(BOOTSTRAP_PROJECT) -f $(BOOTSTRAP_YML) run xos_bootstrap_ui python /opt/xos/tosca/run.py none - < ../common/fixtures.yaml
	sudo docker-compose -p $(BOOTSTRAP_PROJECT) -f $(BOOTSTRAP_YML) run xos_bootstrap_ui python /opt/xos/tosca/run.py none - < ../common/mydeployment.yaml
	$(RUN_TOSCA_BOOTSTRAP) xos.yaml
	$(RUN_TOSCA_BOOTSTRAP) dashboard.yaml

onboarding:
	@echo "[ONBOARDING]"
	# on-board the metronetwork service
	bash ../common/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) xos
	$(RUN_TOSCA_BOOTSTRAP) ../common/disable-onboarding.yaml
	$(RUN_TOSCA_BOOTSTRAP) $(SERVICE_DIR)/metro-net/xos/metronetworkservice-onboard.yaml
	$(RUN_TOSCA_BOOTSTRAP) ../common/enable-onboarding.yaml
	bash ../common/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/metronetwork
	bash ../common/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) xos
	bash ../common/wait_for_xos_port.sh $(XOS_UI_PORT)

containers: prereqs download_xos
	make -f ../common/Makefile.containers xos_devel synchronizer onboarding_synchronizer

rebuild:
	bash ../common/rebuild.sh $(XOS_BOOTSTRAP_PORT)
	bash ../common/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) xos

stop:
	test ! -s $(DOCKER_COMPOSE_YML) || sudo docker-compose -p $(DOCKER_PROJECT) -f $(DOCKER_COMPOSE_YML) stop
	sudo docker-compose -p $(BOOTSTRAP_PROJECT) -f $(BOOTSTRAP_YML) stop

showlogs:
	sudo docker-compose -p $(DOCKER_PROJECT) -f $(DOCKER_COMPOSE_YML) logs

showlogs_bootstrap:
	sudo docker-compose -p $(BOOTSTRAP_PROJECT) -f $(BOOTSTRAP_YML) logs

rm: stop
	test ! -s $(DOCKER_COMPOSE_YML) || sudo docker-compose -p $(DOCKER_PROJECT) -f $(DOCKER_COMPOSE_YML) rm -f
	sudo docker-compose -p $(BOOTSTRAP_PROJECT) -f $(BOOTSTRAP_YML) rm -f

ps:
	sudo docker-compose ps

enter-ui:
	sudo docker exec -ti metronetwork_xos_ui_1 bash

enter-bootstrap-ui:
	sudo docker exec -ti metronetworkdbs_xos_bootstrap_ui_1 bash

enter-db:
	sudo docker exec -ti metronetworkdbs_xos_db_1 bash

django-restart:
	sudo docker exec metronetwork_xos_ui_1 touch /opt/xos/xos/settings.py

clean-config-folder:
	sudo docker exec metronetwork_xos_ui_1 rm -f /opt/xos/xos_configuration/xos_mcord_config
	sudo docker exec metronetwork_xos_ui_1 rm -f /opt/xos/xos_configuration/xos_cord_config


