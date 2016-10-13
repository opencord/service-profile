#! /bin/bash
set -x 
COMPUTENODES=$( bash -c "source ./admin-openrc.sh ; nova host-list" |grep compute|awk '{print $2}')
USER="ubuntu"
DIR_PATH="/home/ubuntu"
MONITORING_DIR="/home/ubuntu/xos_services/monitoring/xos/synchronizer/ceilometer"

for NODE in $COMPUTENODES; do
    echo $COMPUTENODES
    copycmd="cp $DIR_PATH/monitoring_agent/monitoring_agent_compute.conf.j2 /home/ubuntu/monitoring_agent/monitoring_agent.conf"
    excutecmd="sudo $DIR_PATH/monitoring_agent/start_monitoring_agent.sh"
    scp -r $MONITORING_DIR/monitoring_agent $USER@$NODE:$DIR_PATH
    ssh $USER@$NODE $copycmd
    echo $excutecmd
    ssh -t $USER@$NODE $excutecmd
done

CEILOMETERNODE="ceilometer-1"
echo $CEILOMETERNODE
copycmd="cp $DIR_PATH/monitoring_agent/monitoring_agent_ceilometer.conf.j2 /home/ubuntu/monitoring_agent/monitoring_agent.conf"
excutecmd="sudo $DIR_PATH/monitoring_agent/start_monitoring_agent.sh"
scp -r $MONITORING_DIR/monitoring_agent $USER@$CEILOMETERNODE:$DIR_PATH
ssh $USER@$CEILOMETERNODE $copycmd
echo $excutecmd
ssh -t $USER@$CEILOMETERNODE $excutecmd
