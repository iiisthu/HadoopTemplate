#/bin/bash
# build hadoop config files on master node firstly
echo "Process Info: Prepare cluster enviroment...."
echo "Progress Info: Start building master hadoop config..."
python /home/ubuntu/hadoop/conf/config_parser.py
if [ $? != 0  ]
then
	echo "Failure: Build local hadoop config..."
	exit
fi
echo "Success: Finish building hadoop config on master..."
# add slaves to /etc/hosts and syncup among slaves
echo "Progress Info: Start syncup /etc/hosts..."
bash /home/ubuntu/essentials/add_hosts_nameresolv.sh
if [ $? != 0  ]
then
	echo "Failure: Syncup hosts config..."
	exit
fi
echo "Success: Finish syncup /etc/hosts..."
echo "Progress Info: Start syncup hadoop configs..."
python /home/ubuntu/essentials/sync_hadoop.py
if [ $? != 0  ]
then
	echo "Failure: Syncup hadoop config..."
	exit
fi
echo "Success: Finish syncup hadoop configs..."
