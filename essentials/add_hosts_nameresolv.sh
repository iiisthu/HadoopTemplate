#/bin/bash
if [ -n "$HADOOP_HOME" ]; then
	slave_path="$HADOOP_HOME/etc/hadoop/slaves"
else
	slave_path="/home/ubuntu/hadoop/etc/hadoop/slaves"	
fi
essentials_path=/home/ubuntu/essentials
host_file=$essentials_path/data/hosts
this_host=$(ifconfig eth0 | grep 'inet addr' | cut -d':' -f2 | cut -d' ' -f1)
## generate hostfile
echo "Generate hadoop hosts file (by slaves config)......"
cat /etc/host_template > $host_file
for node in `cat $slave_path`; do
	if [ "$node" == "127.0.0.1" ]
	 then
		continue
	fi
	hostname=$(ssh -o StrictHostKeyChecking=no  $node "hostname")
	echo  "$node $hostname" >> $host_file
done
## enable sudo on localhost, sometimes no worker allocated on master node, thus add loopback entry to avoid sudo error : unable to resolve hostname

## sudo can't pipe redirection to /etc/hosts
tmp=${host_file}_1
cp $host_file ${tmp}
#echo "$this_host $(hostname)" >> ${tmp}
## update hosts file to local /etc/hosts on RM node

sudo mv ${tmp} /etc/hosts
if [ $? -ne 0 ]; then
	echo "copy $tmp to /etc/hosts failed; exit;"
	exit
fi

##distribute hosts files to each nodes
echo "Sync hosts file with slaves......"
for node in `cat $slave_path`; do
	echo "To slave : $node ...."
	if [ "$node" == "127.0.0.1" ] || [ "$node" == "localhost" ]; then
		continue
	fi
	scp -o StrictHostKeyChecking=no $host_file $node:$host_file
	if [ $? -ne 0 ]; then

		echo "transmit $host_file to $node failed; exit;"
		echo "$node" >> $essentials_path/log/failed_transmit
	exit
	fi
	ssh -o StrictHostKeyChecking=no  $node "sudo cp $host_file /etc/hosts"
	if [ $? -ne 0 ]; then

		echo "$node: copy $host_file to /etc/hosts failed; exit;"
		echo "$node" >> $essentials_path/log/failed_copy
	exit
	fi
	## add hostname resolv to /etc/hosts in avoid of 'sudo' error
	#ssh -o StrictHostKeyChecking=no  $node 'sudo echo "127.0.1.1 $(hostname)" >> /etc/hosts'
	#if [ $? -ne 0 ]; then

	#	echo "$node: cat hostname resolv to /etc/hosts failed; exit;"
	#	echo "$node" >> $essentials_path/log/failed_hostname_resolv
	#fi

done
echo "Success: /etc/hosts updated on all nodes"
