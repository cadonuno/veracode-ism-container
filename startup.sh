#!/bin/bash

ENDPOINT_LOG="/usr/src/myapp/ism/veracode_ism/logs/smartendpoint.log"
APP_PROPERTIES="/usr/src/myapp/ism/veracode_ism/config/application.properties"

PROXYGATEWAYONLY=true
PROXYRESOLVEHOSTGATEWAY=true
RESOLVEHOSTURLS=true

while [ $# -gt 0 ] ; do
	case $1 in
		-t | --token) TOKEN="$2" ;;
		-k | --key)	APIKEY="$2" ;;
		--build_test) TEST="True" ;;

	esac
	shift
done

SPLIT_TOKEN=${TOKEN:0:36}
GATEWAY=${TOKEN:36:200}
sed -i "s/\$TOKEN\\$/$SPLIT_TOKEN/" $APP_PROPERTIES
sed -i "s/\$GATEWAY\\$/$GATEWAY/" $APP_PROPERTIES
sed -i "s/\$PROXYGATEWAYONLY\\$/$PROXYGATEWAYONLY/" $APP_PROPERTIES
sed -i "s/\$PROXYRESOLVEHOSTGATEWAY\\$/$PROXYRESOLVEHOSTGATEWAY/" $APP_PROPERTIES
sed -i "s/\$PROXYRESOLVEHOSTURLS\\$/$RESOLVEHOSTURLS/" $APP_PROPERTIES

if [ ! -z $TOKEN ] && [ -z $APIKEY ]
then
    MASKED_TOKEN=$(echo -n $TOKEN | head -c 8)"*********************"
    echo "[+] Registering ISM with token: $MASKED_TOKEN"
    cd /usr/src/myapp/ism/veracode_ism && java -jar endpoint.jar &
	while [ ! -f /usr/src/myapp/ism/veracode_ism/.mvsa_api_key ]
	do
		if [ -f $ENDPOINT_LOG ]
		then
			tail -n20 $ENDPOINT_LOG | grep -qe "ERROR"
			if [ $? == 0 ]
			then
				echo "[!] Error detected whilst waiting for ISM to register."
				exit 1
			fi
		fi
		sleep 0.1
	done
    API_KEY=$(cat /usr/src/myapp/ism/veracode_ism/.mvsa_api_key)
	if [ ! -z $API_KEY ]
	then
		echo "[+] Registration successful"
		echo "[!] Add the following API key to Pipeline / Dockerfile"
		echo "[+] API KEY : $API_KEY"
		echo "[!] Exiting.."
		exit 0
	else
		exit 1
	fi
#Build test for nightly pipeline deployment
elif [ ! -z $APIKEY ] && [ ! -z $TOKEN ] && [ ! -z $TEST ]
then
	echo "[!] RUNNING CONNECTIVITY TEST [!]"
	echo "[+] ISM API key and Token provided, attempting to connect to Veracode platform"
	echo -n $APIKEY > /usr/src/myapp/ism/veracode_ism/.mvsa_api_key
	cd /usr/src/myapp/ism/veracode_ism && java -jar endpoint.jar &
#Time limit on test conditions
	EXPIRE=$((SECONDS+300))
	while [ $SECONDS -lt $EXPIRE ]
	do
	   if [ -f $ENDPOINT_LOG ] 
	   then
		   tail -n20 $ENDPOINT_LOG | grep -qe "Smart Endpoint is running"
		   if [ $? == 0 ]
		   then
			   echo "[+] ISM is registered and running - Test Successful"
			   exit 0
			fi
			tail -n20 $ENDPOINT_LOG | grep -qe "ERROR"
			if [ $? == 0 ]
			then 
				echo "[!] Error detected whilst registering endpoint"
				exit 1
			fi
		fi
		sleep 0.1
	done
elif [ ! -z $APIKEY ] && [ ! -z $TOKEN ]
then
	echo "[+] ISM API key and Token provided, attempting to connect to Veracode platform"
	echo -n $APIKEY > /usr/src/myapp/ism/veracode_ism/.mvsa_api_key
	cd /usr/src/myapp/ism/veracode_ism && java -jar endpoint.jar
else
	echo "[-] ERROR: No TOKEN or API Key Provided"
fi
