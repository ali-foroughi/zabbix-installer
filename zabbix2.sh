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
echo "tcp|in|d=10050|s=164.138.19.209" >> /etc/csf/csf.allow
echo "tcp|out|d=10051|d=164.138.19.209" >> /etc/csf/csf.allow
echo "exe:/usr/sbin/zabbix_agentd" >> /etc/csf/csf.pignore
csf -r &>/dev/null
systemctl enable zabbix-agent
systemctl start zabbix-agent
echo " "
echo " "
echo "######## Server info ##########"
SERVER_PSK=$(cat /etc/zabbix/zabbix_agentd.psk)
SERVER_HOSTNAME=$(hostname)
SERVER_IP=$(hostname -i)
echo "Hostname: $SERVER_HOSTNAME"
echo "Server IP: $SERVER_IP"
echo "Server PSK: $SERVER_PSK"
