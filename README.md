# nagios_install

1 The installation in order to not affect the machine installation environment, environmental centos6.6 + Apache2.4 + php5.5, please know.

���ΰ�װ�Բ�Ӱ�챾�������������װ������centos6.6 + Apache2.4 + php5.5,��֪����

2 Send E-mail use sendmail, ensure the environment have sendmail installation and start-up.

�����ʼ�ʹ��sendmail��ȷ�������Ѿ���װsendmail��������

3 In the file/etc/mail. Rc file finally add configuration

���ļ�/etc/mail.rc�ļ�����������
set from=xxx@xxx.com  smtp=smtp.exmail.xxx.com  smtp-auth-user=user  smtp-auth-password=password smtp-auth=login


