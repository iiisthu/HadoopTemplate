#/bin/bash
## validate IP Address

function valid_ip(){
    local  ip=$1
    local  stat=1

    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
            && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}


if [ -n "$HADOOP_HOME" ]; then
	slave_path="$HADOOP_HOME/etc/hadoop/slaves"
else
	slave_path="/home/ubuntu/hadoop/etc/hadoop/slaves"	
fi
essentials_path=/home/ubuntu/essentials
host_file=$essentials_path/data/hosts
this_host=$(ifconfig eth0 | grep 'inet addr' | cut -d':' -f2 | cut -d' ' -f1)
this_host_is_slave=0
## generate hostfile
echo "Generate hadoop hosts file (by slaves config)......"
cat /etc/host_template > $host_file
for node in `cat $slave_path`; do
	if [ "$node" == "127.0.0.1" ]
	 then
		continue
	fi
	if [ "$node" == $this_host ]
	then 
		this_host_is_slave=1
	fi
	echo $node
	if valid_ip $node
	then
		hostname=$(ssh -o StrictHostKeyChecking=no  $node "hostname")
		echo  "$node $hostname" >> $host_file
	else
		ip=$(ssh -o StrictHostKeyChecking=no  $node "host $node | cut -d' ' -f4")
		echo  "$ip $node" >> $host_file
	fi
done
## enable sudo on localhost, sometimes no worker allocated on master node, thus add loopback entry to avoid sudo error : unable to resolve hostname

## sudo can't pipe redirection to /etc/hosts
if [ $this_host_is_slave == 0 ]
then
   echo "$this_host $(hostname)" >> $host_file 
fi
## update hosts file to local /etc/hosts on RM node

sudo cp $host_file /etc/hosts
if [ $? -ne 0 ]; then
	echo "copy $host_file to /etc/hosts failed; exit;"
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

