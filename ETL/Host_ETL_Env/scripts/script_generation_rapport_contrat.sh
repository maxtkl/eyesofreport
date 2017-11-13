#!/bin/bash

#if [ -z "$1" ]; then
# echo "Usage script_generation_rapport.sh year month"
# exit 1
#fi

#if [ -z "$2" ]; then
# echo "Usage script_generation_rapport.sh year month"
# exit 1
#fi


MYSQL_PWD=root66
#param_year=$1
#param_month=$2
previous_year=$(date --date="$(date +%Y-%m-15)" +'%Y')
previous_month=$(date --date="$(date +%Y-%m-15)" +'%m')
date_month_folder=${previous_year}${previous_month}
#date_month_folder=$(date -d "${param_year}-${param_month}-01" '+%Y%m')
date_month=${previous_year}-${previous_month}-01
#date_month=$(date -d "${param_year}-${param_month}-01" '+%Y-%m-%d')
month_folder=/mnt/reports/Contract_Monthly/${date_month_folder}



mkdir -p $month_folder

current_datetime=$(date +"%Y-%m-%d %r")
echo $current_datetime "Creation du dossier /mnt/reports/Contract_Monthly/"$date_month " OK" >> $month_folder/creation_rapports.log

#application_list=$(MYSQL_PWD=$MYSQL_PWD mysql -uroot -e "SELECT distinct dap_name from d_application" eor_dwh)

application_list=$(MYSQL_PWD=$MYSQL_PWD mysql -uroot -e "SELECT distinct dcc_name from d_contract_context" eor_dwh)

#MYSQL_PWD=$MYSQL_PWD mysql -uroot -e "SELECT distinct dap_name from d_application where dap_priority=1" eor_dwh | tail -n +2 > $month_folder/liste_application.txt

MYSQL_PWD=$MYSQL_PWD mysql -uroot -e "SELECT distinct dcc_name from d_contract_context" eor_dwh | tail -n +2 > $month_folder/liste_contrats.txt

#Get contract id for contract "Full"
#contract_context_id=$(MYSQL_PWD=$MYSQL_PWD mysql -uroot -e "SELECT dcc_id from d_contract_context where dcc_name = 'Platinium_Application'" eor_dwh | tail -n +2)

while read contrat
do 
	contrat_id=$(MYSQL_PWD=$MYSQL_PWD mysql -uroot -e "SELECT dcc_id from d_contract_context where dcc_name='$contrat'" eor_dwh | tail -n +2)
	#application_level=$(MYSQL_PWD=$MYSQL_PWD mysql -uroot -e "SELECT dap_priority from d_application where dap_name='$application'" eor_dwh | tail -n +2)
	
	continue=1
	#contract_context_id_custom="0"
	#contract_context_name_custom="0"
	month_application_folder=$month_folder/$contrat
	mkdir -p $month_application_folder
	cd $month_application_folder
	
	if [ $continue -eq 1 ]; then
	
			report_name=${date_month_folder}_${contrat}.pptx
      rm -f ${date_month_folder}_${contrat}.pptx
      
			echo $(date +"%Y-%m-%d %r") "Generation rapport $contrat pour le $previous_year-$previous_month" >> $month_folder/creation_rapports.log
      
      
			wget -q -O $report_name "http://localhost:8080/birt/run?__report=EOR_Contract_Application_EN.rptdesign&__format=PPTX&Year=$previous_year&__isdisplay__Year=$previous_year&Month=$previous_month&__isdisplay__Month=$previous_month&contract_context=$contrat" >> /dev/null
      
	fi
done < $month_folder/liste_contrats.txt

cd $month_folder