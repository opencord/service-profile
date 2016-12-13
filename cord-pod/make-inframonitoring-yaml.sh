FN=$SETUPDIR/inframonitoring.yaml

rm -f $FN

cat >> $FN <<EOF
tosca_definitions_version: tosca_simple_yaml_1_0

description: Auto generated file to enable monitoring of infrastructure services (OpenStack, ONOS...etc).

imports:
   - custom_types/xos.yaml
   - custom_types/monitoring_tosca_types.yaml

topology_template:
  node_templates:
    service_ceilometer:
      type: tosca.nodes.CeilometerService
      properties:
          no-create: true
          no-update: true
          no-delete: true

    onos_monitoring_agent_head_node:
      description: Monitoring agent info
      type: tosca.nodes.InfraMonitoringAgentInfo
      properties:
          start_url: http://ceilometer-1.cord.lab:5004/monitoring/agent/onos/start
          start_url_json_data: { get_artifact: [ SELF, onos_monitoring_service_endpoints, LOCAL_FILE] }
          stop_url: http://ceilometer-1.cord.lab:5004/monitoring/agent/onos/stop
      artifacts:
          onos_monitoring_service_endpoints: /root/setup/onos_monitoring_service_endpoints.json

    os_monitoring_agent_head_node:
      description: Openstack Monitoring agent info
      type: tosca.nodes.InfraMonitoringAgentInfo
      properties:
          start_url: http://ceilometer-1.cord.lab:5004/monitoring/agent/openstack/start
          stop_url: http://ceilometer-1.cord.lab:5004/monitoring/agent/openstack/stop

EOF

NODES=$( bash -c "source $SETUPDIR/admin-openrc.sh ; nova host-list" |grep compute|awk '{print $2}' )
I=0
for NODE in $NODES; do
    echo $I - $NODE
    I=$(( I+1 ))
    cat >> $FN <<EOF
    os_monitoring_agent_cp_${I}:
      description: Openstack Monitoring agent info for ${NODE}
      type: tosca.nodes.InfraMonitoringAgentInfo
      properties:
          start_url: http://$NODE.cord.lab:5004/monitoring/agent/openstack/start
          stop_url: http://$NODE.cord.lab:5004/monitoring/agent/openstack/stop

EOF
done

cat >> $FN <<EOF
    os_monitoring_collector_plugin:
      description: Infra Monitoring collector plugin info
      type: tosca.nodes.MonitoringCollectorPluginInfo
      properties:
          plugin_folder_path: /opt/xos/synchronizers/monitoring/ceilometer/ceilometer-plugins/network/ext_services/openstack_infra/
          plugin_rabbit_exchange: openstack_infra
 
    openstack_monitoring_publisher_tenant:
      description: OpenStack Monitoring Publisher Tenant
      type: tosca.nodes.OpenStackMonitoringPublisher
      requirements:
          - provider_service:
              node: service_ceilometer
              relationship: tosca.relationships.TenantOfService
          - monitoring_collector_plugin:
              node: os_monitoring_collector_plugin
              relationship: tosca.relationships.ProvidesMonitoringCollectorPluginInfo
          - monitoring_agent_1:
              node: os_monitoring_agent_head_node
              relationship: tosca.relationships.ProvidesInfraMonitoringAgentInfo
          - monitoring_agent_2:
              node: onos_monitoring_agent_head_node
              relationship: tosca.relationships.ProvidesInfraMonitoringAgentInfo
EOF
I=0
for NODE in $NODES; do
          I=$(( I+1 ))
          J=$(( I+2 ))
          cat >> $FN <<EOF
          - monitoring_agent_${J}:
              node: os_monitoring_agent_cp_${I}
              relationship: tosca.relationships.ProvidesInfraMonitoringAgentInfo
EOF
done

