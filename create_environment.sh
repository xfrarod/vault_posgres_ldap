
#!/bin/bash -x

# Prompt user to insert inputs (one at a time) 

echo "Select the Vault Telemetry example you want to start:\n
1) statsd_exporter, prometheus, grafana
2) splunk, fluentd, telegraf\n"

read -p 'Enter an option: ' option 

if [ -z "${option}" ] 
then 
    echo 'Option cannot be blank please try again!' 
    exit 0
else
    export TF_VAR_option=$option
fi 


#echo $TF_VAR_option