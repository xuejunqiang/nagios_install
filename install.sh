#!/bin/bash
# Host environment: centos 6.6
#author: xuejq
#nagios dir :/home/nagios_soft/nagios
#blog: xuejqone.com 

current_dir=`pwd`

# Check if user is root
if [ $(id -u) != "0" ];then
    echo "Error: please use root to install this script!"
    exit 1
fi
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
function soft_test(){
   if [ $? -ne 0 ];then
   exit 1;
   fi
}

nagios_dir=/home/nagios_soft/nagios
nagios_web_dir=/home/nagios_soft/web/nagios
apache_dir=/home/nagios_soft/apache
pnp4_dir=/home/nagios_soft/pnp4nagios
if [ ! -d $nagios_web_dir ];then
mkdir -p $nagios_web_dir
fi
cd $current_dir
chmod +x ./Apache_php.sh
./Apache_php.sh
soft_test
#create user
useradd nagios
groupadd nagcmd
usermod -a -G nagcmd nagios
mkdir $current_dir/nagios
cd $current_dir/nagios

if [ -s ./nagios-4.0.8.tar.gz ];then
echo "nagios-4.0.8.tar.gz [found]"
else
echo "Error:nagios-4.0.8.tar.gz not found!!!download now ......"
wget -c ftp://xuejqone.com/nagios/nagios-4.0.8.tar.gz 
soft_test
fi
if [ -s ./nagios-plugins-2.0.3.tar.gz];then
echo "nagios-plugins-2.0.3.tar.gz [found]"
else
echo "Error:nagios-plugins-2.0.3.tar.gz not found!!!download now ......"
wget -c ftp://xuejqone.com/nagios/nagios-plugins-2.0.3.tar.gz
soft_test
fi
if [ -s ./pnp4nagios-0.6.24.tar.gz];then
echo "pnp4nagios-0.6.24.tar.gz [found]"
else
echo "Error:pnp4nagios-0.6.24.tar.gz not found!!!download now ......"
wget -c ftp://xuejqone.com/nagios/pnp4nagios-0.6.24.tar.gz
soft_test
fi
#install nagios
tar zxvf nagios-4.0.8.tar.gz
cd nagios-4.0.8
./configure --prefix=$nagios_dir --with-command-group=nagcmd --with-nagios-group=nagcmd
soft_test
make all && make install  && make install-init  && make install-config  && make install-commandmode 
#make install-webconf 
#cp /etc/httpd/conf.d/nagios.conf  $apache_dir/conf/vhost/
cp -R contrib/eventhandlers/ $nagios_dir/libexec/
chown -R nagios:nagcmd $nagios_dir/libexec/eventhandlers
cd ..
#chick
$nagios_dir/bin/nagios -v $nagios_dir/etc/nagios.cfg
service nagios start

#password for nagios web
$apache_dir/bin/htpasswd -cmb $nagios_dir/etc/htpasswd.users nagiosadmin nagios

#install nagios-plugins
tar zxvf nagios-plugins-2.0.3.tar.gz
cd nagios-plugins-2.0.3
./configure --prefix=$nagios_dir --with-nagios-user=nagios --with-nagios-group=nagcmd --with-command-user=nagios --with-command-group=nagcmd
make
make install
cd ..
#pnp4nagios
tar zxvf pnp4nagios-0.6.24.tar.gz
cd pnp4nagios-0.6.24
./configure --prefix=$pnp4_dir --with-nagios-user=nagios --with-nagios-group=nagcmd
make all && make install && make install-config && make install-init
#&& make install-webconf 
#cp /etc/httpd/conf.d/pnp4nagios.conf  $apache_dir/conf/vhost/  
#cfg
cd $pnp4_dir/etc/
mv misccommands.cfg-sample misccommands.cfg
mv nagios.cfg-sample nagios.cfg
mv rra.cfg-sample rra.cfg
cd pages
mv web_traffic.cfg-sample web_traffic.cfg
cd ../check_commands
mv check_all_local_disks.cfg-sample check_all_local_disks.cfg
mv check_nrpe.cfg-sample check_nrpe.cfg
mv check_nwstat.cfg-sample check_nwstat.cfg
#
cd  $nagios_dir
sed -i 's@^process_performance_data=0@process_performance_data=1@' etc/nagios.cfg
cat >>etc/nagios.cfg<<EOF
host_perfdata_command=process-host-perfdata
service_perfdata_command=process-service-perfdata
host_perfdata_file=$pnp4_dir/var/host-perfdata
service_perfdata_file=$pnp4_dir/var/service-perfdata
host_perfdata_file_template=DATATYPE::HOSTPERFDATA\tTIMET::\$TIMET$\tHOSTNAME::\$HOSTNAME$\tHOSTPERFDATA::\$HOSTPERFDATA$\tHOSTCHECKCOMMAND::\$HOSTCHECKCOMMAND$\tHOSTSTATE::\$HOSTSTATE$\tHOSTSTATETYPE::\$HOSTSTATETYPE$
service_perfdata_file_template=DATATYPE::SERVICEPERFDATA\tTIMET::\$TIMET$\tHOSTNAME::\$HOSTNAME$\tSERVICEDESC::\$SERVICEDESC$\tSERVICEPERFDATA::\$SERVICEPERFDATA$\tSERVICECHECKCOMMAND::\$SERVICECHECKCOMMAND$\tHOSTSTATE::\$HOSTSTATE$\tHOSTSTATETYPE::\$HOSTSTATETYPE$\tSERVICESTATE::\$SERVICESTATE$\tSERVICESTATETYPE::\$SERVICESTATETYPE$
host_perfdata_file_mode=a
service_perfdata_file_mode=a
host_perfdata_file_processing_interval=15
service_perfdata_file_processing_interval=15
host_perfdata_file_processing_command=process-host-perfdata-file
service_perfdata_file_processing_command=process-service-perfdata-file
EOF
#

sed -i '173 aaction_url     /pnp4nagios/index.php/graph?host=$HOSTNAME$&srv=$SERVICEDESC$'  etc/objects/templates.cfg

cat >>etc/objects/commands.cfg<<EOF

define command{
       command_name    process-service-perfdata-file
       command_line    /bin/mv $pnp4_dir/var/service-perfdata $pnp4_dir/var/spool/service-perfdata.\$TIMET$
}
define command{
       command_name    process-host-perfdata-file
       command_line    /bin/mv $pnp4_dir/var/host-perfdata $pnp4_dir/var/spool/host-perfdata.\$TIMET$
}

EOF
#nagios web conf

cat >$apache_dir/conf/vhost/nagios.conf<<EOF

# SAMPLE CONFIG SNIPPETS FOR APACHE WEB SERVER
#
# This file contains examples of entries that need
# to be incorporated into your Apache web server
# configuration file.  Customize the paths, etc. as
# needed to fit your system.

ScriptAlias /nagios/cgi-bin "$nagios_dir/sbin"

<Directory "$nagios_dir/sbin">
#  SSLRequireSSL
   Options ExecCGI
   AllowOverride None
   Order allow,deny
   Allow from all
#  Order deny,allow
#  Deny from all
#  Allow from 127.0.0.1
   AuthName "Nagios Access"
   AuthType Basic
   AuthUserFile $nagios_dir/etc/htpasswd.users
   Require valid-user
</Directory>

Alias /nagios "$nagios_dir/share"

<Directory "$nagios_dir/share">
#  SSLRequireSSL
   Options None
   AllowOverride None
   Order allow,deny
   Allow from all
#  Order deny,allow
#  Deny from all
#  Allow from 127.0.0.1
   AuthName "Nagios Access"
   AuthType Basic
   AuthUserFile $nagios_dir/etc/htpasswd.users
   Require valid-user
 DirectoryIndex index.html index.php
</Directory>

# SAMPLE CONFIG SNIPPETS FOR APACHE WEB SERVER

Alias /pnp4nagios "$pnp4_dir//share"

<Directory "$pnp4_dir//share">
   	AllowOverride None
   	Order allow,deny
   	Allow from all
   	#
   	# Use the same value as defined in nagios.conf
   	#
   	AuthName "Nagios Access"
   	AuthType Basic
   	AuthUserFile $nagios_dir/etc/htpasswd.users
   	Require valid-user
	<IfModule mod_rewrite.c>
		# Turn on URL rewriting
		RewriteEngine On
		Options symLinksIfOwnerMatch
		# Installation directory
		RewriteBase /pnp4nagios/
		# Protect application and system files from being viewed
		RewriteRule "^(?:application|modules|system)/" - [F]
		# Allow any files or directories that exist to be displayed directly
		RewriteCond "%{REQUEST_FILENAME}" !-f
		RewriteCond "%{REQUEST_FILENAME}" !-d
		# Rewrite all other URLs to index.php/URL
		RewriteRule "^.*$" "index.php/$0" [PT]
	</IfModule>
</Directory>
EOF

      
                                          
mv $pnp4_dir/share/install.php $pnp4_dir/share/install.phpbak
chown nagios.nagcmd -R $pnp4_dir
chown nagios.nagcmd -R $nagios_dir

chkconfig apached on
service apached restart
chkconfig nagios on
service nagios restart
chkconfig npcd on
service npcd start
service apached start

echo "=============================================================================="
echo "start Apache :  service apached start"
echo "web directory : $home_dir"
echo "web log directory : $wwwlogs_dir "
echo "php directory : $php_dir"
echo "apache directory : $apache_dir"
echo "http://$ip:6666/"
echo "nagios dir : $nagios_dir"
echo "pnp4nagios dir : $pnp4_dir"
echo "Email Spam Alert :   We need to add your mail  to  $nagios_dir/etc/objects/contacts.cfg   "
echo "============================================================================================"

