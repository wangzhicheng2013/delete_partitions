#delete table partitions in terms with table name and date
#!/bin/bash
#define config file and get password
CONFIG_FILE=/home/webdefender/conf/wdd.cfg
DBPWD=`grep "dbpwd" $CONFIG_FILE|awk -F "= " '{printf $2}'|awk -F'#'  '{print $1}'`
#define tables which contain partitions there are 35 tables
table_list=(wdd_flow_osi wdd_flow_appid wdd_audit_ics wdd_access wdd_flow_broadcast wdd_flow_ip wdd_flow_proto wdd_flow_packetsize wdd_flow_diagnosis wdd_ssnptr_end sendout_ftp_files wdd_sr_resource wdd_ip_command_count wdd_ip_command_day wdd_accessgrade_stat wdd_appid_session wdd_session_login attachment_info attachment_counter attachment_url_info attack_roadmap_node_attachment sandbox_suspicious_url wdd_access_combined_map wdd_access_counter wdd_access_ip_host wdd_access_maininfo wdd_access_sync_waf wdd_cloud_file wdd_file_thread_degree wdd_sr_alarm_ipinfo wdd_access_audit_map wdd_access_file wdd_audit wdd_ssnptr_start wdd_flow_coll)
#delete partitions between the min year and max year
function delete_table_partitions_between_years()
{
    data_base=$1
    table_name=$2
    min_year=$3
    max_year=$4
    select_partitions_sql=`echo "SELECT PARTITION_NAME from information_schema.PARTITIONS WHERE TABLE_SCHEMA='$data_base' and TABLE_NAME='$table_name'"|mysql -u wdd -p$DBPWD $data_base`
    echo "table $table_name partitions as following:"
    echo $select_partitions_sql
    partition_array=(${select_partitions_sql// / })
    #get every partition
    for partition in ${partition_array[@]}
    do
        if [ $partition = PARTITION_NAME ];then #ignore PARTITION_NAME
            continue
        fi
        echo $partition
        year=`echo $partition | awk '{print substr($1,2,4)}'` #get the year from partition
        echo $year
        if [[ $year -le $max_year && $year -ge $min_year ]];then    #between the years
            delete_partitions_sql=`echo "ALTER TABLE $table_name DROP PARTITION $partition"|mysql -u wdd -p$DBPWD $data_base`
            echo $delete_partitions_sql
            echo $?
        fi
    done
}
for table_name in ${table_list[@]}
do
    delete_table_partitions_between_years wdd $table_name 2017 2019
done