#!/bin/sh
#Establish IP/Port
DEVICE_IP="$(hostname -I | awk '{print $1}')"
#Import Start Flag Values:
	#Load boot status - what condition was node last run
	. /home/pinodexmr/bootstatus.sh
	#Import Restricted Port Number (external use)
	. /home/pinodexmr/monero-port.sh
	#Import RPC username
	. /home/pinodexmr/RPCu.sh
	#Import RPC password
	. /home/pinodexmr/RPCp.sh
	
	if [ $BOOT_STATUS -eq 2 ]
then	
		#System Idle
		echo "--System Idle--" > /var/www/html/TXPool_Status.txt
fi	
	
	if [ $BOOT_STATUS -eq 3 ] || [ $BOOT_STATUS -eq 5 ]
then	
		#Node Status
		PRINT_POOL_STATS="$(./monero/build/release/bin/monerod --rpc-bind-ip=${DEVICE_IP} --rpc-bind-port=${MONERO_PORT} --rpc-login=${RPCu}:${RPCp} --rpc-ssl disabled print_pool_stats | sed '1d')" && echo "$PRINT_POOL_STATS" > /var/www/html/TXPool_Status.txt
fi	

	if [ $BOOT_STATUS -eq 4 ]
then	
		#Adapted command for tor rpc calls (payments) - RPC port and IP fixed due to tor hidden service settings linked in /etc/tor/torrc
		PRINT_POOL_STATS="$(./monero/build/release/bin/monerod --rpc-bind-ip=127.0.0.1 --rpc-bind-port=18081 --rpc-login=${RPCu}:${RPCp} --rpc-ssl disabled print_pool_stats | sed '1d')" && echo "$PRINT_POOL_STATS" > /var/www/html/TXPool_Status.txt
fi	
	
	if [ $BOOT_STATUS -eq 6 ]
then
		#Adapted command for restricted public rpc calls (payments)
		PRINT_POOL_STATS="$(./monero/build/release/bin/monerod --rpc-bind-ip=$DEVICE_IP --rpc-bind-port=$MONERO_PORT --rpc-ssl disabled print_pool_stats | sed '1d')" && echo "$PRINT_POOL_STATS" > /var/www/html/TXPool_Status.txt
fi

	if [ $BOOT_STATUS -eq 7 ]
then
		#Adapted command for public free (restricted) rpc calls. No auth needed for local.
		PRINT_POOL_STATS="$(./monero/build/release/bin/monerod --rpc-bind-ip=$DEVICE_IP --rpc-bind-port=$MONERO_PORT --rpc-ssl disabled print_pool_stats | sed '1d')" && echo "$PRINT_POOL_STATS" > /var/www/html/TXPool_Status.txt
fi

	if [ $BOOT_STATUS -eq 8 ]
then	
		#I2p Node Status
		PRINT_POOL_STATS="$(./monero/build/release/bin/monerod --rpc-bind-ip=$DEVICE_IP --rpc-bind-port=$MONERO_PORT --rpc-login=${RPCu}:${RPCp} --rpc-ssl disabled print_pool_stats | sed '1d')" && echo "$PRINT_POOL_STATS" > /var/www/html/TXPool_Status.txt
fi