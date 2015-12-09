import configparser
import re
import pdb


class HadoopConfParser:
	def __init__(self, Object):
		self.config_file = Object
		self.template_path = {}
		self.settings = configparser.ConfigParser()
		self.settings._interpolation = configparser.ExtendedInterpolation()
		self.settings.read(self.config_file)
		self.template_pattern = '\.template$'
	def name_conversion(self, pointed):
		return pointed.replace('.','_').replace('-','_').upper()
	def hadoop_conf_parser_executor(self):
		self.retreive_global_conf()
		self.retreive_sites()
		self.retreive_slaves()
	def retreive_slaves(self):
		dict_helper = self.ConfigSectionMap('SLAVES')
		slaves = dict_helper['slaves'].split(',')
		with open(self.template_path['SLAVES'], 'w') as fout:
			for slave in slaves:
				fout.write(slave.strip()+'\n')
			
	def retreive_global_conf(self):
		dict_helper = self.ConfigSectionMap('GLOBAL')
		self.template_path['CORE_SITE'] = dict_helper['core.site.template.path']	
		self.template_path['YARN_SITE'] = dict_helper['yarn.site.template.path']	
		self.template_path['MAPRED_SITE'] = dict_helper['mapred.site.template.path']	
		self.template_path['SLAVES'] = dict_helper['slaves.path']
	def retreive_sites(self):
		self.retreive_site('CORE_SITE')
		self.retreive_site('YARN_SITE')
		self.retreive_site('MAPRED_SITE')

	def retreive_site(self, section_name):
		dict_helper = self.ConfigSectionMap(section_name)
		replacements = {}
		for name, value in dict_helper.iteritems():
			replacements[self.name_conversion(name)] = value
		with open(re.sub(self.template_pattern, '', self.template_path[section_name]), 'w') as fout, open(self.template_path[section_name], 'r') as fin:
			for line in fin:
 				for src, target in replacements.iteritems():
            				line = line.replace(src, target)
        			fout.write(line)
	

	def ConfigSectionMap(self,section):
    		dict1 = {}
    		options = self.settings.options(section)
    		for option in options:
        		try:
           			dict1[option] = self.settings.get(section, option)
            			if dict1[option] == -1:
                			DebugPrint("skip: %s" % option)
        		except:
            			print("exception on %s!" % option)
            			dict1[option] = None
    		return dict1	
if __name__ == '__main__':
	config_file='/home/ubuntu/hadoop/conf/conf.ini'
	parser = HadoopConfParser(config_file)	
	parser.hadoop_conf_parser_executor()
