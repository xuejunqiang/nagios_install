#!/bin/bash
# Host environment: centos 6.6
#author: xuejq
#nagios dir :/home/nagios_soft/nagios
#blog: xuejqone.com 

current_dir=`pwd`

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: please use root to install this script!"
    exit 1
fi
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
nagios_dir=/home/nagios_soft/nagios
nagios_web_dir=/home/nagios_soft/web/nagios
apache_dir=/home/nagios_soft/apache
pnp4_dir=/home/nagios_soft/pnp4nagios
mkdir $nagios_web_dir

#create user
useradd nagios
groupadd nagcmd
usermod -a -G nagcmd nagios
function soft_test(){
   if [ $? -ne 0 ];then
   exit 1;
   fi
}
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
make all
make install 
make install-init  
make install-config 
make install-commandmode 
make install-webconf 

cp /etc/httpd/conf.d/nagios.conf  $apache_dir/conf/vhost/nagios.conf
cp -R contrib/eventhandlers/ $nagios_dir/libexec/
chown -R nagios:nagcmd $nagios_dir/libexec/eventhandlers
cd ..
#chick
$nagios_dir/bin/nagios -v $nagios_dir/etc/nagios.cfg
service nagios start

#password for nagios web
/home/xjq/apache2/bin/htpasswd -cmb /home/xjq/nagios/etc/htpasswd.users nagiosadmin nagios

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
make all
make install
make install-webconf
make install-config
make install-init
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
cd $current_dir/nagios_cfg

mv $nagios_dir/etc/objects/commands.cfg       $nagios_dir/etc/objects/commands.cfgbak
cp ./commands.cfg                          $nagios_dir/etc/objects/
mv $nagios_dir/etc/objects/templates.cfg      $nagios_dir/etc/objects/templates.cfgbak
cp ./templates.cfg                         $nagios_dir/etc/objects/
mv $nagios_dir/etc/nagios.cfg 		     $nagios_dir/etc/nagios.cfgbak
cp ./nagios.cfg 			           $nagios_dir/etc/

#
mv $pnp4_dir/share/install.php $pnp4_dir/share/install.phpbak
chown nagios.nagcmd -R $pnp4_dir
chown nagios.nagcmd -R $nagios_dir

chkconfig apached on
service apached restart
chkconfig nagios on
service nagios restart
chkconfig npcd on
service npcd restart
