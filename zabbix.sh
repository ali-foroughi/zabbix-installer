#!/bin/bash

read -p 'enter server name (example: vm1122):' NAME
read -p 'Please specify server location (ir/de):' LOCATION
OsType=&(cat /etc/os-release | grep NAME | cut -d '"' -f2 | head -n 1 | cut -d ' ' -f1)

IR_zabbix_install () {
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
    		
    		# Add the Zabbix server IP to the CSF configuration
    		echo "tcp|in|d=10050|s=164.138.19.209" >> /etc/csf/csf.allow
    		echo "tcp|out|d=10051|d=164.138.19.209" >> /etc/csf/csf.allow
}

DE_zabbix_install () {
    		touch /etc/zabbix/zabbix_agentd.conf
    		cat <<EOT >> /etc/zabbix/zabbix_agentd.conf
    		PidFile=/var/run/zabbix/zabbix_agentd.pid
    		LogFile=/var/log/zabbix/zabbix_agentd.log
	    	LogFileSize=1
	    	Include=/etc/zabbix/zabbix_agentd.d/*.conf
	    	TLSConnect=psk
	    	TLSAccept=psk
	    	TLSPSKFile=/etc/zabbix/zabbix_agentd.psk
	    	Server=zabbix.rackset.com
	    	ServerActive=zabbix.rackset.com
	    	Hostname=$NAME.euhosted.com
	    	TLSPSKIdentity=PSK $NAME
		EOT
    		# Add the Zabbix server IP to the CSF configuration
    		echo "tcp|in|d=10050|s=138.201.79.7" >> /etc/csf/csf.allow
    		echo "tcp|out|d=10051|d=138.201.79.7" >> /etc/csf/csf.allow
}

if [ $OsType == "CentOS" ] ; then
	
	rpm -Uvh https://repo.zabbix.com/zabbix/4.5/rhel/7/x86_64/zabbix-release-4.5-2.el7.noarch.rpm
	yum install zabbix-agent -y
	sh -c "openssl rand -hex 32 > /etc/zabbix/zabbix_agentd.psk"
	rm /etc/zabbix/zabbix_agentd.conf


	if [ $LOCATION == "ir" ]; then
		IR_server_install

	elif [ $LOCATION == "de" ]; then
		DE_server_install
	fi	
   		
elif [ $OsType == "Ubuntu" ] ; then

	wget https://repo.zabbix.com/zabbix/5.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_5.4-1+ubuntu20.04_all.deb
	dpkg -i zabbix-release_5.4-1+ubuntu20.04_all.deb
	apt update 
	apt install zabbix-agent
	rm zabbix-release*
	
	if [ $LOCATION == "ir" ]; then
		IR_server_install


	elif [ $LOCATION == "de" ]; then
		DE_server_install

	fi
else
	echo "OS type not supported"
fi


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
echo "Server PSK: $SERVER_PSK"
echo "###############################"
