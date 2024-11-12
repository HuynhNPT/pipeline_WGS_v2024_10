#!/bin/bash
export my_date=$(date | awk '{print$1}')

until [ $my_date == "Sun" ]
do
    echo "Waiting to initiate SAREK. Date is $my_date"
    sleep 18000
    export my_date=$(date | awk '{print$1}')
done 

./02_run_sarek.sh