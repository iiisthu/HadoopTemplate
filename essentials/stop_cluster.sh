#/bin/bash

echo "Progress Info: Stop Hadoop Cluster..."
bash $HADOOP_HOME/sbin/stop-yarn.sh
bash $HADOOP_HOME/sbin/mr-jobhistory-daemon.sh --config $HADOOP_CONF_DIR stop historyserver
