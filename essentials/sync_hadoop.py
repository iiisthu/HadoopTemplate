from fabric import tasks,state
from fabric.api import *
import sys
# syncup networking essentials
known_hosts= "/home/ubuntu/.ssh/known_hosts"
resolv_hosts = "/etc/resolv.conf"
# syncup hadoop config files
hadoop_home="/home/ubuntu/hadoop"
hadoop_conf="%s/conf/conf.ini"%hadoop_home
hadoop_conf_parser="%s/conf/config_parser.py"%hadoop_home
# sync up hadoop template files
hadoop_template_yarn="%s/etc/hadoop/%s-site.xml.template"%(hadoop_home, 'yarn')
hadoop_template_core="%s/etc/hadoop/%s-site.xml.template"%(hadoop_home, 'core')
hadoop_template_mapred="%s/etc/hadoop/%s-site.xml.template"%(hadoop_home, 'mapred')
# syncup hadoop wrapper scripts
essential_scripts="/home/ubuntu/essentials"
# syncup hadoop environment scripts (in ~/.bashrc)
bashrc="/home/ubuntu/.bashrc"
# make sure that JAVA_HOME is set in hadoop-env.sh
hadoop_env="%s/etc/hadoop/hadoop-env.sh"%hadoop_home
slaves="%s/etc/hadoop/slaves"%hadoop_home
env.hosts=[line for line in open(slaves)]
def file_send(localpath,remotepath):
    put(localpath,remotepath,use_sudo=True)

files=[]
files.append(hadoop_conf)
files.append(hadoop_conf_parser)
files.append(hadoop_template_yarn)
files.append(hadoop_template_core)
files.append(hadoop_template_mapred)
files.append(bashrc)
files.append(known_hosts)
files.append(hadoop_env)
files.append(resolv_hosts)
dirs=[]
dirs.append(essential_scripts)
commands=[]
#execute config file to genenrate *.xml in slave nodes
commands.append("python %s"%hadoop_conf_parser)
commands.append("source %s"%bashrc)
@parallel
def worker():
	#sync up hadoop config file
	for _file in files:
		file_send(_file, _file)
	for _dir in dirs:
		l = _dir.split("/")
		del l[-1]
		if len(l) == 0:
			file_send(_dir, ".")
		else:
			file_send(_dir, "/".join(l)+"/")
	for command in commands:
		result=	run(command)
def main():
    tasks.execute(worker)

if __name__ == '__main__':
    main()
