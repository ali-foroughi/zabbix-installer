# zabbix-installer

A script to automatically install Zabbix on servers and add the needed configurations.

Supported OS:

- CentOS
- Ubuntu
- CloudLinux

How it works:

- The /etc/zabbix/zabbix_agentd.conf file is edited as needed
- The CSF firewall is configured (has to be installed first)
- PSK is configured for for authentication
- Zabbix starts and PSK and server IP and server hostname is displayed

<h2>Usage</h2>

<code> wget https://raw.githubusercontent.com/ali-foroughi/zabbix-installer/main/zabbix.sh && chmod u+x zabbix.sh && ./zabbix.sh </code>
