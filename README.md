# nagios_install

1 The installation in order to not affect the machine installation environment, environmental centos6.6 + Apache2.4 + php5.5, please know.

本次安装以不影响本机环境的情况安装，环境centos6.6 + Apache2.4 + php5.5,请知晓。

2 Send E-mail use sendmail, ensure the environment have sendmail installation and start-up.

发送邮件使用sendmail，确保环境已经安装sendmail并启动。

3 In the file/etc/mail. Rc file finally add configuration

在文件/etc/mail.rc文件最后添加配置
set from=xxx@xxx.com  smtp=smtp.exmail.xxx.com  smtp-auth-user=user  smtp-auth-password=password smtp-auth=login


