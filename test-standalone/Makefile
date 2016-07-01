include ../common/Makedefs

MYIP:=$(shell hostname -i)
CONFIG_DIR:=$(shell pwd)
DOCKER_COMPOSE_YML=./onboarding-docker-compose/docker-compose.yml
BOOTSTRAP_YML=./docker-compose-bootstrap.yml
DOCKER_PROJECT=teststandalone
BOOTSTRAP_PROJECT=teststandalonebs
XOS_BOOTSTRAP_PORT=9998
XOS_UI_PORT=9999
DB_NAME=$(BOOTSTRAP_PROJECT)_xos_db_1

define TRUNCATE_FN
	CREATE OR REPLACE FUNCTION truncate_tables(username IN VARCHAR) RETURNS void AS $$$$
	DECLARE
			statements CURSOR FOR
					SELECT tablename FROM pg_tables
					WHERE tableowner = username AND schemaname = 'public';
	BEGIN
			FOR stmt IN statements LOOP
					EXECUTE 'TRUNCATE TABLE ' || quote_ident(stmt.tablename) || ' CASCADE;';
			END LOOP;
	END;
	$$$$ LANGUAGE plpgsql;
endef
export TRUNCATE_FN

prepare: xos
	sudo docker exec -i teststandalone_xos_ui_1 bash -c "cd /opt/xos/tests/api; npm install --production"
	sudo docker exec teststandalone_xos_ui_1 pip install dredd_hooks

xos: prereqs dirs download_xos download_services bootstrap onboarding

prereqs:
	sudo make -f ../common/Makefile.prereqs

dirs:
	# if this directory doesn't exist, then docker-compose will create it with root permission
	mkdir -p key_import
	mkdir -p onboarding-docker-compose

bootstrap:
	echo "[BOOTSTRAP]"
	sudo rm -f onboarding-docker-compose/docker-compose.yml
	sudo docker-compose -p $(BOOTSTRAP_PROJECT) -f $(BOOTSTRAP_YML) up -d
	bash ../common/wait_for_xos_port.sh 9998
	sudo docker-compose -p $(BOOTSTRAP_PROJECT) -f $(BOOTSTRAP_YML) run -e CONFIG_DIR=$(CONFIG_DIR) xos_bootstrap_ui python /opt/xos/tosca/run.py none - < xos.yaml

download_xos:
	make -f ../common/Makefile.services xos_core

download_services:
	make -f ../common/Makefile.services

update_services:
	make -f ../common/Makefile.services update

update_xos:
	make -f ../common/Makefile.services update_xos

onboarding:
	echo "[ONBOARDING]"
	bash ../common/wait_for_onboarding_ready.sh 9998 xos
	bash -c "echo somekey > key_import/vsg_rsa"
	bash -c "echo somekey > key_import/vsg_rsa.pub"
	bash -c "echo somekey > key_import/volt_rsa"
	bash -c "echo somekey > key_import/volt_rsa.pub"
	bash -c "echo somekey > key_import/onos_rsa"
	bash -c "echo somekey > key_import/onos_rsa.pub"
	sudo docker-compose -p $(BOOTSTRAP_PROJECT) -f $(BOOTSTRAP_YML) run xos_bootstrap_ui python /opt/xos/tosca/run.py None - < ../common/disable-onboarding.yaml
	sudo docker-compose -p $(BOOTSTRAP_PROJECT) -f $(BOOTSTRAP_YML) run xos_bootstrap_ui python /opt/xos/tosca/run.py None - < $(SERVICE_DIR)/vrouter/xos/vrouter-onboard.yaml
	sudo docker-compose -p $(BOOTSTRAP_PROJECT) -f $(BOOTSTRAP_YML) run xos_bootstrap_ui python /opt/xos/tosca/run.py None - < $(SERVICE_DIR)/olt/xos/volt-onboard.yaml
	sudo docker-compose -p $(BOOTSTRAP_PROJECT) -f $(BOOTSTRAP_YML) run xos_bootstrap_ui python /opt/xos/tosca/run.py None - < $(SERVICE_DIR)/vsg/xos/vsg-onboard.yaml
	sudo docker-compose -p $(BOOTSTRAP_PROJECT) -f $(BOOTSTRAP_YML) run xos_bootstrap_ui python /opt/xos/tosca/run.py None - < $(SERVICE_DIR)/vtr/xos/vtr-onboard.yaml
	sudo docker-compose -p $(BOOTSTRAP_PROJECT) -f $(BOOTSTRAP_YML) run xos_bootstrap_ui python /opt/xos/tosca/run.py None - < $(SERVICE_DIR)/onos-service/xos/onos-onboard.yaml
	sudo docker-compose -p $(BOOTSTRAP_PROJECT) -f $(BOOTSTRAP_YML) run xos_bootstrap_ui python /opt/xos/tosca/run.py None - < ../common/enable-onboarding.yaml
	bash ../common/wait_for_onboarding_ready.sh 9998 services/vrouter
	bash ../common/wait_for_onboarding_ready.sh 9998 services/volt
	bash ../common/wait_for_onboarding_ready.sh 9998 services/vsg
	bash ../common/wait_for_onboarding_ready.sh 9998 services/vtr
	bash ../common/wait_for_onboarding_ready.sh 9998 services/onos
	bash ../common/wait_for_onboarding_ready.sh 9998 xos
	bash ../common/wait_for_xos_port.sh 9999

restore-initial-db-status:
	sudo docker exec $(DB_NAME) psql -U postgres -d xos -c "$$TRUNCATE_FN" >/dev/null 2>&1
	sudo docker exec $(DB_NAME) psql -U postgres -d xos -c "SELECT truncate_tables('postgres');" >/dev/null 2>&1
	sudo docker exec $(DB_NAME) psql -U postgres -d xos -c "SELECT setval('core_tenant_id_seq', 1)" >/dev/null 2>&1
	sudo docker exec $(DB_NAME) psql -U postgres -d xos -c "SELECT setval('core_deployment_id_seq', 1)" >/dev/null 2>&1
	sudo docker exec $(DB_NAME) psql -U postgres -d xos -c "SELECT setval('core_flavor_id_seq', 1)" >/dev/null 2>&1
	sudo docker exec $(DB_NAME) psql -U postgres -d xos -c "SELECT setval('core_service_id_seq', 1)" >/dev/null 2>&1
	sudo docker-compose -p $(DOCKER_PROJECT) -f $(DOCKER_COMPOSE_YML) run xos_ui python /opt/xos/manage.py --noobserver --nomodelpolicy loaddata /opt/xos/core/fixtures/core_initial_data.json
	sudo docker-compose -p $(DOCKER_PROJECT) -f $(DOCKER_COMPOSE_YML) run xos_ui python /opt/xos/tosca/run.py none - < ../common/fixtures.yaml
	sudo docker-compose -p $(DOCKER_PROJECT) -f $(DOCKER_COMPOSE_YML) run xos_ui python /opt/xos/tosca/run.py none - < ../common/mydeployment.yaml
	sudo docker-compose -p $(DOCKER_PROJECT) -f $(DOCKER_COMPOSE_YML) run xos_ui python /opt/xos/tosca/run.py padmin@vicci.org - < ../frontend/sample.yaml

	# sudo docker-compose run xos python /opt/xos/tosca/run.py padmin@vicci.org /opt/xos/configurations/cord-pod/setup.yaml
	# sudo docker-compose run xos python /opt/xos/tosca/run.py padmin@vicci.org /opt/xos/configurations/cord-pod/nodes.yaml
	# sudo docker-compose run xos python /opt/xos/tosca/run.py padmin@vicci.org /opt/xos/configurations/cord-pod/images.yaml
	sudo docker-compose -p $(DOCKER_PROJECT) -f $(DOCKER_COMPOSE_YML) run xos_ui python /opt/xos/tosca/run.py padmin@vicci.org - < ../cord-pod/mgmt-net.yaml
	sudo docker-compose -p $(DOCKER_PROJECT) -f $(DOCKER_COMPOSE_YML) run xos_ui python /opt/xos/tosca/run.py padmin@vicci.org - < services.yaml
	sudo docker-compose -p $(DOCKER_PROJECT) -f $(DOCKER_COMPOSE_YML) run xos_ui python /opt/xos/tosca/run.py padmin@vicci.org - < ../cord-pod/cord-volt-devices.yaml


test: restore-initial-db-status
	# RUN TESTS
	sudo docker cp $(XOS_DIR)/apiary.apib teststandalone_xos_ui_1:/opt/xos/tests/api/apiary.apib
	sudo docker exec -i teststandalone_xos_ui_1 bash -c "cd /opt/xos/tests/api; npm test"

test-tosca: restore-initial-db-status
	sudo docker-compose -p $(DOCKER_PROJECT) -f $(DOCKER_COMPOSE_YML) run xos_ui bash -c "cd /opt/xos/tosca/tests; python ./alltests.py"

test-ui: restore-initial-db-status
	sudo docker exec -u root -i teststandalone_xos_1 bash -c "cd /opt/xos/tests/ui-e2e; python xos-e2e-test.py"

base-container: 
	make -f ../common/Makefile.containers xos_base

devel-container: base-container
	make -f ../common/Makefile.containers xos_devel synchronizer onboarding_synchronizer

containers: prereqs download_xos devel-container
	make -f ../common/Makefile.containers xos_test

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

docker-clean:
	sudo docker rm -f $(shell sudo docker ps -aq)

enter-xos:
	sudo docker exec -ti teststandalone_xos_ui_1 bash

enter-xos-db:
	sudo docker exec -ti $(DB_NAME) bash
