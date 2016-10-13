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

echo "Deleting Monitoring Service VMs"
# Delete all VMs
VMS=$( nova list --all-tenants|grep mysite|grep ceilometer|awk '{print $2}' )
for VM in $VMS
do
    nova delete $VM
done

echo "Waiting 5 seconds..."
sleep 5

cleanup_network mysite_ceilometer-private

echo "Deleting Monitoring Service networks"
# Delete all networks beginning with mysite_
NETS=$( neutron net-list --all-tenants|grep mysite|grep ceilometer|awk '{print $2}' )
for NET in $NETS
do
    neutron net-delete $NET
done

neutron net-delete mysite_ceilometer-private || true
