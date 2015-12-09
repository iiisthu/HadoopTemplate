#/bin/bash
echo "Progress Info: Start Hadoop Cluster..."
bash $HADOOP_HOME/sbin/start-yarn.sh
bash $HADOOP_HOME/sbin/mr-jobhistory-daemon.sh --config $HADOOP_CONF_DIR start historyserver
