#!/bin/bash

function cleanup_network {
  NETWORK=$1
  SUBNETS=`neutron net-show $NETWORK | grep -i subnets | awk '{print $4}'`
  if [[ $SUBNETS != "" ]]; then
      PORTS=`neutron port-list | grep -i $SUBNETS | awk '{print $2}'`
      for PORT in $PORTS; do
          echo "Deleting port $PORT"
          neutron port-delete $PORT
      done
  fi
  neutron net-delete $NETWORK
}

source ./admin-openrc.sh

echo "Deleting VMs"
# Delete all VMs
VMS=$( nova list --all-tenants|grep mysite|awk '{print $2}' )
for VM in $VMS
do
    nova delete $VM
done

echo "Waiting 5 seconds..."
sleep 5

cleanup_network lan_network
cleanup_network wan_network
cleanup_network mysite_vcpe-private
cleanup_network mysite_vsg-access
cleanup_network management
cleanup_network management_host
cleanup_network shared_network
cleanup_network vsg_network
#cleanup_network lan_rru_network
#cleanup_network lan_3gpp_s5s8_pgw_network
#cleanup_network lan_3gpp_s1u_network
#cleanup_network lan_3gpp_s1mme_network
cleanup_network lan_taas_test_network1
cleanup_network lan_taas_public_network

echo "Deleting networks"
# Delete all networks beginning with mysite_
NETS=$( neutron net-list --all-tenants|grep mysite|awk '{print $2}' )
for NET in $NETS
do
    neutron net-delete $NET
done

neutron net-delete lan_network || true
neutron net-delete subscriber_network || true
neutron net-delete public_network || true
neutron net-delete hpc_client_network || true
neutron net-delete ceilometer_network || true
neutron net-delete management || true
neutron net-delete management_host || true
neutron net-delete shared_network || true
neutron net-delete vsg_network || true
neutron net-delete mysite_vsg-access || true
neutron net-delete exampleservice-public || true
neutron net-delete lan_taas_test_network1 || true
neutron net-delete lan_taas_public_network || true
