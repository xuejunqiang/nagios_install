#!/bin/bash
# Host environment: centos 6.6
#author: xuejq
#
#apache :/home/nagios_soft/apache
#php	:/home/nagios_soft/php
#源码编译文件bak:/home/nagios_soft/source_bak
#blog: xuejqone.com 

# Check if user is root
if [ $(id -u) != "0" ]; then
    echo "Error: please use root to install this script!"
    exit 1
fi
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

#
chmod +x ./Apache_php.sh
apache_port=6666

#dir
apache_dir=/home/nagios_soft/apache
current_dir=`pwd`
php_dir=/home/nagios_soft/php
wwwlogs_dir=/home/nagios_soft/wwwlogs_dir
home_dir=/home/nagios_soft/web
bak_dir=/home/nagios_soft/source_bak
mkdir -p $home_dir
mkdir -p $wwwlogs_dir
mkdir -p $bak_dir
mkdir $current_dir/apache

#Yum environment depend on the installation
read -p "Update the system? yes |no " update
if [ "$update" = "yes" ];then
yum -y update
yum makecache -y
fi
for packages in gcc gcc-c++  glibc glibc-commons libtool libtool-libs   autoconf kernel-devel make cmake lsof wget unzip  flex bison file  t1lib-devel libjpeg libjpeg-devel libpng libpng-devel  gd gd-devel libicu-devel  freetype freetype-devel libcurl-devel libxml2 libxml2-devel zlib zlib-devel glib2 glib2-devel bzip2 bzip2-devel libevent libevent-devel curl curl-devel e2fsprogs e2fsprogs-devel  krb5-devel libidn libidn-devel openssl openssl-devel  pcre pcre-devel gettext gettext-devel  gmp-devel libcap diffutils net-snmp perl-Time-HiRes rrdtool  rrdtool-perl mailx sendmail
do
 
yum -y install $packages
sleep 2
done
 #if 
function soft_test(){
   if [ $? -ne 0 ];then
   exit 1;
   fi
}
#apache depend 
cd $current_dir/apache
if [ -s ./apr-1.5.1.tar.gz ];then
echo "apr-1.5.1.tar.gz [found]"
else
echo "Error:apr-1.5.1.tar.gz not found!!!download now ......"
wget -c ftp://xuejqone.com/nagios/apr-1.5.1.tar.gz
soft_test
fi
if [ -s ./apr-util-1.5.4.tar.gz ];then
echo "apr-util-1.5.4.tar.gz [found]"
else
echo "Error:apr-util-1.5.4.tar.gz not found!!!download now ......"
wget -c ftp://xuejqone.com/nagios/apr-util-1.5.4.tar.gz
soft_test
fi
if [ -s ./httpd-2.4.12.tar.gz ];then
  echo "httpd-2.4.12.tar.gz [found]"
  else
  echo "Error: httpd-2.4.12.tar.gz not found!!!download now......"
  wget -c ftp://xuejqone.com/nagios/httpd-2.4.12.tar.gz
  soft_test
fi
unzip mod_rpaf-stable.zip
#php depend
if [ ! -d  $current_dir/php ];then
mkdir $current_dir/php
fi
cd $current_dir/php
if [ -s ./libiconv-1.14.tar.gz ];then
	echo "libiconv-1.14.tar.gz [found]"
else	
	 echo "Error: libiconv-1.14 not found !!! downloading ..."
	 wget -c ftp://xuejqone.com/nagios/libiconv-1.14.tar.gz
	soft_test
fi
if [ -s ./mhash-0.9.9.9.tar.gz ];then
	echo "mhash-0.9.9.9.tar.gz [found]"
else	
	 echo "Error: mhash-0.9.9.9.tar.gz not found !!! downloading ..."
	 wget -c ftp://xuejqone.com/nagios/mhash-0.9.9.9.tar.gz
	soft_test
fi
if [ -s ./libmcrypt-2.5.8.tar.gz ];then
	echo "libmcrypt-2.5.8.tar.gz [found]"
else	
	 echo "Error: libmcrypt-2.5.8.tar.gz not found !!! downloading ..."
	 wget -c ftp://xuejqone.com/nagios/libmcrypt-2.5.8.tar.gz
	soft_test
fi
if [ -s ./php-5.5.23.tar.gz ];then
	echo "php-5.5.23.tar.gz [found]"
else
	echo "Error: php-5.5.23.tar.gz not found !!! downloading ..."
	 wget -c ftp://xuejqone.com/nagios/php-5.5.23.tar.gz
	soft_test
fi
tar xvf libiconv-1.14.tar.gz
cd libiconv-1.14 && ./configure && make && make install && cd ..
tar xvf mhash-0.9.9.9.tar.gz 
cd mhash-0.9.9.9 && ./configure  && make && make install && cd ..
tar xf libmcrypt-2.5.8.tar.gz
cd libmcrypt-2.5.8 && ./configure  && make && make install && cd ..

##########install Apache httpd-2.4.12.tar.gz 
cd $current_dir/apache
tar zxvf httpd-2.4.12.tar.gz 
cd httpd-2.4.12
tar xvf $current_dir/apache/apr-1.5.1.tar.gz && mv ./apr-1.5.1/ ./srclib/apr
tar xvf $current_dir/apache/apr-util-1.5.4.tar.gz && mv ./apr-util-1.5.4 ./srclib/apr-util

./configure --prefix=$apache_dir  --enable-module=so  --enable-so  --with-included-apr --with-mpm=prefork  --enable-rewrite --enable-rewrite=shared --enable-headers --with-libxml2  --enable-mime-magic  --enable-ssl --with-ssl --enable-suexec --enable-proxy  --enable-mods-shared=all --enable-deflate --enable-speling --enable-cache --enable-file-cache --enable-disk-cache --enable-mem-cache  --enable-expires=shared  --enable-vhost-alias --enable-static-support  --with-z  --with-pcre --disable-userdir 
soft_test
make && make install
soft_test
cd ..
mv httpd-2.4.12 $bak_dir
############install php
yum -y remove php*
cd $current_dir/php
rm -rf php-5.5.23
tar zxvf php-5.5.23.tar.gz
cd php-5.5.23
 ./configure --prefix=$php_dir  --with-apxs2=$apache_dir/bin/apxs  --with-png-dir --with-jpeg-dir --with-freetype-dir --with-zlib --with-gd --enable-gd-native-ttf  --with-mcrypt --with-mysql=mysqlnd  --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd --with-iconv-dir --with-libxml-dir=/usr --enable-xml --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl --enable-mbregex --enable-mbstring=all --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-xmlrpc --enable-zip --enable-soap --with-gettext  --enable-sysvmsg --enable-sysvsem --enable-sysvmsg
soft_test
 ln -s /usr/local/lib/libiconv.so.2 /usr/lib64/
make ZEND_EXTRA_LIBS='-liconv' && make install
soft_test
cp php.ini-development  $php_dir/etc/php.ini
# Modify php.ini
Mem=`free -m | awk '/Mem:/{print $2}'`
if [ $Mem -gt 1024 -a $Mem -le 1500 ];then
	Memory_limit=192
elif [ $Mem -gt 1500 -a $Mem -le 3500 ];then
	Memory_limit=256
elif [ $Mem -gt 3500 -a $Mem -le 4500 ];then
	Memory_limit=320
elif [ $Mem -gt 4500 ];then
	Memory_limit=448
else
	Memory_limit=128
fi
sed -i "s@^memory_limit.*@memory_limit = ${Memory_limit}M@" $php_dir/etc/php.ini
sed -i 's@^output_buffering =@output_buffering = On\noutput_buffering =@'  $php_dir/etc/php.ini
sed -i 's@^;cgi.fix_pathinfo.*@cgi.fix_pathinfo=0@' $php_dir/etc/php.ini
sed -i 's@^short_open_tag = Off@short_open_tag = On@' $php_dir/etc/php.ini
sed -i 's@^expose_php = On@expose_php = Off@' $php_dir/etc/php.ini
sed -i 's@^request_order.*@request_order = "CGP"@' $php_dir/etc/php.ini
sed -i 's@^;date.timezone.*@date.timezone = Asia/Shanghai@' $php_dir/etc/php.ini
sed -i 's@^post_max_size.*@post_max_size = 50M@' $php_dir/etc/php.ini
sed -i 's@^upload_max_filesize.*@upload_max_filesize = 50M@' $php_dir/etc/php.ini
sed -i 's@^;upload_tmp_dir.*@upload_tmp_dir = /tmp@' $php_dir/etc/php.ini
sed -i 's@^max_execution_time.*@max_execution_time = 5@' $php_dir/etc/php.ini
sed -i 's@^disable_functions.*@disable_functions = passthru,exec,system,chroot,chgrp,chown,shell_exec,proc_open,proc_get_status,ini_alter,ini_restore,dl,openlog,syslog,readlink,symlink,popepassthru,stream_socket_server,fsocket,popen@' $php_dir/etc/php.ini
sed -i 's@^session.cookie_httponly.*@session.cookie_httponly = 1@' $php_dir/etc/php.ini
sed -i 's@^mysqlnd.collect_memory_statistics.*@mysqlnd.collect_memory_statistics = On@' $php_dir/etc/php.ini
[ -e /usr/sbin/sendmail ] && sed -i 's@^;sendmail_path.*@sendmail_path = /usr/sbin/sendmail -t -i@' $php_dir/etc/php.ini

cd ..
mv php-5.5.23 /home/nagios/source_bak
#start httpd php-/
sed -i 's@^User daemon@User nagios@' $apache_dir/conf/httpd.conf
sed -i 's@^Group daemon@Group nagcmd@' $apache_dir/conf/httpd.conf
sed -i "s@AddType\(.*\)Z@AddType\1Z\n    AddType application/x-httpd-php .php .phtml\n    AddType application/x-httpd-php-source .phps@" $apache_dir/conf/httpd.conf
sed -i 's@^#LoadModule rewrite_module@LoadModule rewrite_module@' $apache_dir/conf/httpd.conf
sed -i 's@^#LoadModule\(.*\)mod_deflate.so@LoadModule\1mod_deflate.so@' $apache_dir/conf/httpd.conf
sed -i 's@^#LoadModule\(.*\)mod_cgi.so@LoadModule\mod_cgi.so@' $apache_dir/conf/httpd.conf
sed -i 's@^#LoadModule\(.*\)mod_slotmem_shm.so@LoadModule\mod_slotmem_shm.so@' $apache_dir/conf/httpd.conf
sed -i 's@DirectoryIndex index.html@DirectoryIndex index.html index.php@' $apache_dir/conf/httpd.conf
sed -i "s@^#Include conf/extra/httpd-mpm.conf@Include conf/extra/httpd-mpm.conf@" $apache_dir/conf/httpd.conf

#port
sed -i "s@^Listen 80 @Listen $apache_port@" $apache_dir/conf/httpd.conf

totalip=`ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v inet6 |awk '{print $2}'|tr -d "addr:" |wc -l`
if [ $ -ne 1 ];then
ip=`ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v inet6 |awk '{print $2}'|tr -d "addr:"`
else
while true
do
read -p "Please input the closed network IP：" ip
if [ "$ip" = "" ];then
echo "Please enter the IP again:" 
else
break;
fi
done 

cat >> $apache_dir/conf/httpd.conf <<EOF
ServerTokens ProductOnly
ServerSignature Off
AddOutputFilterByType DEFLATE text/html text/plain text/css text/xml text/javascript
DeflateCompressionLevel 6
SetOutputFilter DEFLATE
Include conf/vhost/*.conf
EOF

sed -i "s@Include conf/extra/httpd-mpm.conf@Include conf/extra/httpd-mpm.conf\nInclude conf/extra/httpd-remoteip.conf@" $apache_dir/conf/httpd.conf
sed -i "s@LogFormat \"%h %l@LogFormat \"%h %a %l@g" $apache_dir/conf/httpd.conf

mkdir $apache_dir/conf/vhost

#test

cat >$apache_dir/conf/vhost/test.conf<EOF
<VirtualHost $ip:$apache_port>
    ServerAdmin  admin@xuejqone.com
    DocumentRoot "$home_dir"
    ServerName  localhost:$apache_port
#    ServerAlias 
    ErrorLog "$wwwlogs_dir/nagios-error.log"
    CustomLog "$wwwlogs_dir/nagios-access.log" common
<Directory "$home_dir">
    SetOutputFilter DEFLATE
    Options FollowSymLinks
	Require all granted
    AllowOverride All
    Order allow,deny
    Allow from all
    DirectoryIndex index.html index.php
</Directory>
</VirtualHost>
EOF
cat >$home_dir/index.php<<EOF
<?php
phpinfo();
EOF
#init apache
grep -v "#" $apache_dir/bin/apachectl > /etc/init.d/apached
 sed 1'i\#!/bin/bash' /etc/init.d/apached
 sed 2'i\# chkconfig: 2345 85 15' /etc/init.d/apached
 sed 3'i\# description: Apache is a World Wide Web server.' /etc/init.d/apached
 sed 4'i\#blog :xuejqone.com' /etc/init.d/apached
chmod +x /etc/init.d/apached
chkconfig apached on
#start
service apached start

chkconfig --list | grep apached

echo "=============================================================================="
echo "start Apache :  service apached start"
echo "web directory : $home_dir"
echo "web log directory : $wwwlogs_dir "
echo "php directory : $php_dir"
echo "apache directory : $apache_dir"
echo "http://$ip:6666/"
echo "=============================================================================="