# zabbix-installer

A script to automatically install Zabbix on CentOS servers and add the needed configurations.

How it works:

- The /etc/zabbix/zabbix_agentd.conf file is edited as needed
- The CSF firewall is configured (has to be installed first)
- PSK is configured for for authentication
- Zabbix starts and PSK and server IP and server hostname is displayed
