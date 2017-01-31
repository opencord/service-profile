#in mcord.yaml, replace 'compute1', 'compute2', etc. with the actual compute node names

NODES=$( bash -c "source $SETUPDIR/admin-openrc.sh ; nova host-list" | grep compute|awk '{print $2}' )

it=1
for name in "${NODES[@]}"
do
        sed "s/compute${it}/${name}/" mcord.yaml > mcord.new; mv mcord.new mcord.yaml
        it=$((it+1))
done


