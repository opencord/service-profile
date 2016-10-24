# test-standalone/Makefile

CONFIG_DIR         := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))
COMMON_DIR         := $(abspath ../common )

.DEFAULT_GOAL      := prepare

DOCKER_PROJECT     ?= teststandalone
BOOTSTRAP_PROJECT  ?= teststandalonebs

XOS_BOOTSTRAP_PORT ?= 9998
XOS_UI_PORT        ?= 9999

DB_NAME            ?= $(BOOTSTRAP_PROJECT)_xos_db_1

# Include common functions
include $(COMMON_DIR)/Makefile

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
	sudo docker exec -i $(DOCKER_PROJECT)_xos_ui_1 bash -c "cd /opt/xos/tests/api; npm install --production"
	sudo docker exec $(DOCKER_PROJECT)_xos_ui_1 pip install dredd_hooks

xos: prereqs config_dirs xos_download cord_services cord_libraries test_bootstrap onboarding

test_bootstrap:
	@echo "[TEST_BOOTSTRAP]"
	sudo rm -f onboarding-docker-compose/docker-compose.yml
	sudo docker-compose -p $(BOOTSTRAP_PROJECT) -f $(BOOTSTRAP_YML) up -d
	bash $(COMMON_DIR)/wait_for_xos_port.sh $(XOS_BOOTSTRAP_PORT)
	sudo docker-compose -p $(BOOTSTRAP_PROJECT) -f $(BOOTSTRAP_YML) run -e CONFIG_DIR=$(CONFIG_DIR) xos_bootstrap_ui python /opt/xos/tosca/run.py none - < xos.yaml

onboarding:
	@echo "[ONBOARDING]"
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) xos
	bash -c "echo somekey > key_import/vsg_rsa"
	bash -c "echo somekey > key_import/vsg_rsa.pub"
	bash -c "echo somekey > key_import/volt_rsa"
	bash -c "echo somekey > key_import/volt_rsa.pub"
	bash -c "echo somekey > key_import/onos_rsa"
	bash -c "echo somekey > key_import/onos_rsa.pub"
	sudo docker-compose -p $(BOOTSTRAP_PROJECT) -f $(BOOTSTRAP_YML) run xos_bootstrap_ui python /opt/xos/tosca/run.py None - < $(COMMON_DIR)/tosca/disable-onboarding.yaml
	sudo docker-compose -p $(BOOTSTRAP_PROJECT) -f $(BOOTSTRAP_YML) run xos_bootstrap_ui python /opt/xos/tosca/run.py None - < $(LIBRARY_DIR)/ng-xos-lib/ng-xos-lib-onboard.yaml
	sudo docker-compose -p $(BOOTSTRAP_PROJECT) -f $(BOOTSTRAP_YML) run xos_bootstrap_ui python /opt/xos/tosca/run.py None - < $(SERVICE_DIR)/vrouter/xos/vrouter-onboard.yaml
	sudo docker-compose -p $(BOOTSTRAP_PROJECT) -f $(BOOTSTRAP_YML) run xos_bootstrap_ui python /opt/xos/tosca/run.py None - < $(SERVICE_DIR)/olt/xos/volt-onboard.yaml
	sudo docker-compose -p $(BOOTSTRAP_PROJECT) -f $(BOOTSTRAP_YML) run xos_bootstrap_ui python /opt/xos/tosca/run.py None - < $(SERVICE_DIR)/vsg/xos/vsg-onboard.yaml
	sudo docker-compose -p $(BOOTSTRAP_PROJECT) -f $(BOOTSTRAP_YML) run xos_bootstrap_ui python /opt/xos/tosca/run.py None - < $(SERVICE_DIR)/vtr/xos/vtr-onboard.yaml
	sudo docker-compose -p $(BOOTSTRAP_PROJECT) -f $(BOOTSTRAP_YML) run xos_bootstrap_ui python /opt/xos/tosca/run.py None - < $(SERVICE_DIR)/onos-service/xos/onos-onboard.yaml
	sudo docker-compose -p $(BOOTSTRAP_PROJECT) -f $(BOOTSTRAP_YML) run xos_bootstrap_ui python /opt/xos/tosca/run.py None - < $(COMMON_DIR)/tosca/enable-onboarding.yaml
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/ng-xos-lib
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/vrouter
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/volt
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/vsg
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/vtr
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) services/onos
	bash $(COMMON_DIR)/wait_for_onboarding_ready.sh $(XOS_BOOTSTRAP_PORT) xos
	bash $(COMMON_DIR)/wait_for_xos_port.sh $(XOS_UI_PORT)

restore-initial-db-status:
	sudo docker exec $(DB_NAME) psql -U postgres -d xos -c "$$TRUNCATE_FN" >/dev/null 2>&1
	sudo docker exec $(DB_NAME) psql -U postgres -d xos -c "SELECT truncate_tables('postgres');" >/dev/null 2>&1
	sudo docker exec $(DB_NAME) psql -U postgres -d xos -c "SELECT setval('core_tenant_id_seq', 1)" >/dev/null 2>&1
	sudo docker exec $(DB_NAME) psql -U postgres -d xos -c "SELECT setval('core_deployment_id_seq', 1)" >/dev/null 2>&1
	sudo docker exec $(DB_NAME) psql -U postgres -d xos -c "SELECT setval('core_flavor_id_seq', 1)" >/dev/null 2>&1
	sudo docker exec $(DB_NAME) psql -U postgres -d xos -c "SELECT setval('core_service_id_seq', 1)" >/dev/null 2>&1
	sudo docker-compose -p $(DOCKER_PROJECT) -f $(DOCKER_COMPOSE_YML) run xos_ui python /opt/xos/manage.py --noobserver loaddata /opt/xos/core/fixtures/core_initial_data.json
	sudo docker-compose -p $(DOCKER_PROJECT) -f $(DOCKER_COMPOSE_YML) run xos_ui python /opt/xos/tosca/run.py none - < $(COMMON_DIR)/tosca/fixtures.yaml
	sudo docker-compose -p $(DOCKER_PROJECT) -f $(DOCKER_COMPOSE_YML) run xos_ui python /opt/xos/tosca/run.py none - < $(COMMON_DIR)/tosca/mydeployment.yaml
	sudo docker-compose -p $(DOCKER_PROJECT) -f $(DOCKER_COMPOSE_YML) run xos_ui python /opt/xos/tosca/run.py $(ADMIN_USERNAME) - < ../frontend/sample.yaml
	# sudo docker-compose run xos python /opt/xos/tosca/run.py $(ADMIN_USERNAME) /opt/xos/configurations/cord-pod/setup.yaml
	# sudo docker-compose run xos python /opt/xos/tosca/run.py $(ADMIN_USERNAME) /opt/xos/configurations/cord-pod/nodes.yaml
	# sudo docker-compose run xos python /opt/xos/tosca/run.py $(ADMIN_USERNAME) /opt/xos/configurations/cord-pod/images.yaml
	sudo docker-compose -p $(DOCKER_PROJECT) -f $(DOCKER_COMPOSE_YML) run xos_ui python /opt/xos/tosca/run.py $(ADMIN_USERNAME) - < $(COMMON_DIR)/tosca/mgmt-net.yaml
	sudo docker-compose -p $(DOCKER_PROJECT) -f $(DOCKER_COMPOSE_YML) run xos_ui python /opt/xos/tosca/run.py $(ADMIN_USERNAME) - < services.yaml
	sudo docker-compose -p $(DOCKER_PROJECT) -f $(DOCKER_COMPOSE_YML) run xos_ui python /opt/xos/tosca/run.py $(ADMIN_USERNAME) - < $(COMMON_DIR)/tosca/cord-volt-devices.yaml

test: restore-initial-db-status
	# RUN TESTS
	sudo docker cp $(XOS_DIR)/apiary.apib $(DOCKER_PROJECT)_xos_ui_1:/opt/xos/tests/api/apiary.apib
	sudo docker exec -i $(DOCKER_PROJECT)_xos_ui_1 bash -c "cd /opt/xos/tests/api; npm test"

test-tosca: restore-initial-db-status
	sudo docker-compose -p $(DOCKER_PROJECT) -f $(DOCKER_COMPOSE_YML) run xos_ui bash -c "cd /opt/xos/tosca/tests; python ./alltests.py"

test-ui: restore-initial-db-status
	sudo docker exec -u root -i $(DOCKER_PROJECT)_xos_1 bash -c "cd /opt/xos/tests/ui-e2e; python xos-e2e-test.py"

