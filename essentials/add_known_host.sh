#!/bin/bash
function valid_ip()
{
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

for node in `cat $slave_path`;do
 result=$(ssh-keyscan -t rsa $node 2>&1 >> ~/.ssh/tmp_hosts)
 if [ "$result" == ""  ]
 then
 	if valid_ip $node; then 
    		echo $i >> $essentials_path/log/failed_request_ip
		exit
 	else
		echo $i >> $essentials_path/log/failed_request_host
		exit
	fi
 fi
 if valid_ip $node
 then
    	hostname=$(ssh -o StrictHostKeyChecking=no  $node "hostname")
 	result=$(ssh-keyscan -t rsa $hostname 2>&1 >> ~/.ssh/tmp_hosts)
 else
        ip=$(ssh -o StrictHostKeyChecking=no  $node "host $node | cut -d' ' -f4")
 	result=$(ssh-keyscan -t rsa $ip 2>&1 >> ~/.ssh/tmp_hosts)
 fi	
 if [ "$result" == ""  ]
 then
 	if valid_ip $node; then 
    		echo $i >> $essentials_path/log/failed_request_ip
		exit
 	else
		echo $i >> $essentials_path/log/failed_request_host
		exit
	fi
 fi

 done
 mv ~/.ssh/tmp_hosts ~/.ssh/known_hosts
