tosca_definitions_version: tosca_simple_yaml_1_0

description: Onboard the exampleservice

imports:
   - custom_types/xos.yaml

topology_template:
  node_templates:
    xos:
      type: tosca.nodes.XOS
      properties:
        ui_port:  9000
        bootstrap_ui_port:  9001
        docker_project_name: devel
        db_container_name: develbs_xos_db_1
        extra_hosts: ctl:CTLIP

    /opt/xos/xos_configuration/xos_common_config:
      type: tosca.nodes.XOSVolume
      properties:
          host_path: { path_join: [ SELF, CONFIG_DIR, ../common/xos_common_config, ENV_VAR ] }
          read_only: false
      requirements:
          - xos:
             node: xos
             relationship: tosca.relationships.UsedByXOS

    /root/setup:
      type: tosca.nodes.XOSVolume
      properties:
          host_path: { path_join: [ SELF, CONFIG_DIR, ../setup, ENV_VAR ] }
          read_only: false
      requirements:
          - xos:
             node: xos
             relationship: tosca.relationships.UsedByXOS

    /opt/xos/images:
      type: tosca.nodes.XOSVolume
      properties:
          host_path: { path_join: [ SELF, CONFIG_DIR, images, ENV_VAR ] }
          read_only: true
      requirements:
          - xos:
             node: xos
             relationship: tosca.relationships.UsedByXOS