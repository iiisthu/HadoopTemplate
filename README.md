 Hadoop 模板使用
===================================
 关于Hadoop镜像
-----------------------------------  
> Hadoop镜像默认两个用户：root与ubuntu；EasyStack可在分配实例时输入root密码与ssh密钥; 
> 初次登陆时:
> - 使用root用户以用户名密码/密钥登陆
> - 使用ubuntu用户只能用密钥ssh登陆(用户下载私钥保存)
通过UI分配节点
-----------------------------------  
> 通过UI分配的虚拟机，IP为OpenStack DHCP随机分配，（假设用户无OpenStack命令行使用权限）需用户手动统计节点的各个IP，写入/home/ubuntu/hadoop/conf/conf.ini 的[SLAVES]区域（多个IP以逗号分隔）。

> 基本需求只用修改yarn.resourcemanager.address 为你分配集群的ResourceManager地址。

###模板参数
> 以下指定参数为模板必选参数，请勿删除
> `考虑到集群易用性将可能用到的参数皆设为必选参数，其他Hadoop参数暂无自动添加功能，若用户有特定需求可自行生成Hadoop配置文件或联系[作者](thushenhan@gmail.com)，然自行配置无法使用本模板的脚本提供的自动集群同步功能，高级用户也可自行修改源代码实现特定需求`
> - [CORE_SITE]	
	`使用本机房公共HDFS的请勿改动CORE-SITE设置,并将虚拟机绑定在share_net下。`
	namenode : HDFS NameNode 主机名/IP地址(默认端口9000)；
	io.file.buffer.size: The size of buffer for use in sequence files。
	[官方配置文档](https://hadoop.apache.org/docs/r2.7.1/hadoop-project-dist/hadoop-common/core-default.xml)
	
> - [YARN_SITE]
	yarn.resourcemanager.address： Yarn集群Resource Manager 主机名/IP地址； 	
	yarn.resourcemanager.webapp.address: Yarn 集群Resource Manager Webapp 主机名/IP地址(默认端口8088)
	
	yarn.nodemanager.resource.memory-mb： Yarn 每Node Manager节点总内存资源(默认1024MB)；
	
	yarn.nodemanager.resource.cpu-vcores: Yarn 每Node Manager节点总虚拟CPU资源（默认1核）；

	yarn.scheduler.maximum(minimum)-allocation-mb: Resource Manager Scheduler为每Container分配的最大/最小内存(默认最大yarn.nodemanager.resource.memory-mb*0.8MB)；
	yarn.log-aggregation-enable: 是否聚集程序运行的所有log（默认删除各NodeManger节点上的log，集中存储在HDFS上）
	其余参数请参考[Hadoop yarn_default.xml](https://hadoop.apache.org/docs/r2.4.1/hadoop-yarn/hadoop-yarn-common/yarn-default.xml)官方文档

> - [MAPRED_SITE]
	mapreduce.framework.name: 指定mapreduce框架名;
	mapreduce.jobhistory.address: 指定mapreduce history server IP地址[主机名]
	mapreduce.jobhistory.webapp.address: 指定mapreduce history server webapp IP地址[主机名]	(默认端口19888)	
	yarn.app.mapreduce.am.resource.mb : MapReduce任务中Application Master分配的内存大小(默认1024MB)
	mapreduce.map(reduce).memory.mb(cpu.vcores)： map/reduce任务的内存大小/CPU核数(应不大于[YARN-SITE]中container的分配上限)
	mapreduce.task.io.sort.mb: MapReduce shuffle阶段的缓存大小（对于map输出非常大的应用非常重要）
	mapreduce.map(reduce).java.opts: map/reduce任务的JVM堆大小（不应大于map/reduce任务内存）
> [[SLAVES]]
	指定slave节点（NodeManger节点）
	格式：slaves= [IP lists]
	
> 修改完后保存即可。

### 编译/预处理Hadoop cluster：
``` bash
cd /home/ubuntu/essentails
bash cluster_builder.sh
```
### 运行Hadoop cluster:
``` bash
cd /home/ubuntu/essentails
bash start_cluster.sh
```
### 停止Hadoop Cluster：
``` bash
cd /home/ubuntu/essentails
bash stop_cluster.sh
```

### Hadoop 使用
成功运行Hadoop之后，可以为你的ResourceManager绑定floating ip, web访问
Resource Manager : http://[floating ip]:8088
History Server: http://[floating ip]:19888 

