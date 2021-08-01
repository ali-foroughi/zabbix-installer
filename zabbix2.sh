NAME=$(hostname | awk -F '\\.' '{print $1""}')
rpm -Uvh https://repo.zabbix.com/zabbix/4.5/rhel/7/x86_64/zabbix-release-4.5-2.el7.noarch.rpm
yum install zabbix-agent -y
sh -c "openssl rand -hex 32 > /etc/zabbix/zabbix_agentd.psk"
rm /etc/zabbix/zabbix_agentd.conf
touch /etc/zabbix/zabbix_agentd.conf
cat <<EOT >> /etc/zabbix/zabbix_agentd.conf
PidFile=/var/run/zabbix/zabbix_agentd.pid
LogFile=/var/log/zabbix/zabbix_agentd.log
LogFileSize=1
Include=/etc/zabbix/zabbix_agentd.d/*.conf
TLSConnect=psk
TLSAccept=psk
TLSPSKFile=/etc/zabbix/zabbix_agentd.psk
Server=irzbx.rackset.com
ServerActive=irzbx.rackset.com
Hostname=$NAME.euhosted.com
TLSPSKIdentity=PSK $NAME
EOT
