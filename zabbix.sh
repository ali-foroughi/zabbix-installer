#!/bin/bash

# Installs Zabbix-agent on Centos,Ubuntu or Cloudlinux servers. Creates the approriate configuration file and;
# adds required configuration to CSF firewall.
# It does NOT check whether or CSF is installed.

#change these to zabbix server IP
IR_IP=""
DE_IP=""

read -p 'enter server name (example: vm1122):' NAME
read -p 'Please specify server location (ir/de):' LOCATION

# Check OS version
OSTYPE=$(cat /etc/os-release | grep NAME | cut -d '"' -f2 | head -n 1 | cut -d ' ' -f1)




IR_zabbix_install () {
touch /etc/zabbix/zabbix_agentd.conf
cat <<EOT >> /etc/zabbix/zabbix_agentd.conf
LogFile=/var/log/zabbix/zabbix_agentd.log
LogFileSize=20
Include=/etc/zabbix/zabbix_agentd.d/*.conf
TLSConnect=psk
TLSAccept=psk
TLSPSKFile=/etc/zabbix/zabbix_agentd.psk
Server=irzbx.rackset.com
ServerActive=irzbx.rackset.com
Hostname=$NAME.euhosted.com
TLSPSKIdentity=PSK $NAME
EOT

if [ $OSTYPE == "Ubuntu" ] ; then
cat <<EOT >> /etc/zabbix/zabbix_agentd.conf
PidFile=/run/zabbix/zabbix_agentd.pid
EOT

elif [[ $OSTYPE == "CentOS" || $OSTYPE == "CloudLinux" ]] ; then
cat <<EOT >> /etc/zabbix/zabbix_agentd.conf
PidFile=/var/run/zabbix/zabbix_agentd.pid
EOT

else
echo "OS type not supported. Please use Ubuntu, CentOS or CloudLinux"
exit 1
fi

# Add the Zabbix server IP to the CSF configuration
echo "tcp|in|d=10050|s=$IR_IP" >> /etc/csf/csf.allow
echo "tcp|out|d=10051|d=$IR_IP" >> /etc/csf/csf.allow
}


DE_zabbix_install () {
touch /etc/zabbix/zabbix_agentd.conf
cat <<EOT >> /etc/zabbix/zabbix_agentd.conf
LogFile=/var/log/zabbix/zabbix_agentd.log
LogFileSize=20
Include=/etc/zabbix/zabbix_agentd.d/*.conf
TLSConnect=psk
TLSAccept=psk
TLSPSKFile=/etc/zabbix/zabbix_agentd.psk
Server=zabbix.rackset.com
ServerActive=zabbix.rackset.com
Hostname=$NAME.euhosted.com
TLSPSKIdentity=PSK $NAME
EOT

if [ $OSTYPE == "Ubuntu" ] ; then
cat <<EOT >> /etc/zabbix/zabbix_agentd.conf
PidFile=/run/zabbix/zabbix_agentd.pid
EOT

elif [[ $OSTYPE == "CentOS" || $OSTYPE == "CloudLinux" ]] ; then
cat <<EOT >> /etc/zabbix/zabbix_agentd.conf
PidFile=/var/run/zabbix/zabbix_agentd.pid
EOT

else
echo "OS tyoe not supported. Please use Ubuntu or CentOS"
exit 1
fi

# Add the Zabbix server IP to the CSF configuration
echo "tcp|in|d=10050|s=$DE_IP" >> /etc/csf/csf.allow
echo "tcp|out|d=10051|d=$DE_IP" >> /etc/csf/csf.allow
}

if [[ $OSTYPE == "CentOS" || $OSTYPE == "CloudLinux" ]] ; then
	
rpm -Uvh https://repo.zabbix.com/zabbix/4.5/rhel/7/x86_64/zabbix-release-4.5-2.el7.noarch.rpm
yum install zabbix-agent -y
sh -c "openssl rand -hex 32 > /etc/zabbix/zabbix_agentd.psk"
rm /etc/zabbix/zabbix_agentd.conf

	if [ $LOCATION == "ir" ]; then
		IR_zabbix_install

	elif [ $LOCATION == "de" ]; then
		DE_zabbix_install
	else
		echo "Location is incorrect. Please choose ir/de"
		exit 1
	fi	
   		
elif [ $OSTYPE == "Ubuntu" ] ; then

wget https://repo.zabbix.com/zabbix/5.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_5.4-1+ubuntu20.04_all.deb
dpkg -i zabbix-release_5.4-1+ubuntu20.04_all.deb
apt update 
apt install zabbix-agent
rm zabbix-release*
sh -c "openssl rand -hex 32 > /etc/zabbix/zabbix_agentd.psk"
rm /etc/zabbix/zabbix_agentd.conf
	
	if [ $LOCATION == "ir" ]; then
		IR_zabbix_install


	elif [ $LOCATION == "de" ]; then
		DE_zabbix_install
	else
		echo "Location is incorrect. Please choose ir/de"
	fi
else
	echo "OS type not supported"
fi

echo "" >> /etc/csf/csf.pignore
echo "exe:/usr/sbin/zabbix_agentd" >> /etc/csf/csf.pignore

# Restart CSF
csf -r &>/dev/null

# Start Zabbix
systemctl enable zabbix-agent
systemctl start zabbix-agent

# Display server stuff
echo " "
echo " "
echo "######## Server info ##########"
SERVER_PSK=$(cat /etc/zabbix/zabbix_agentd.psk)
SERVER_HOSTNAME=$(hostname)
SERVER_IP=$(hostname -i)
echo "Hostname: $SERVER_HOSTNAME"
echo "Server IP: $SERVER_IP"
echo "PSK ID: PSK $NAME"
echo "Server PSK: $SERVER_PSK"
echo "###############################"
