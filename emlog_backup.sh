#!/bin/bash

#-----config------------
backup_path="/home/strider/blog/backup"
emlog_domain="http://www.xxxx.info"
emlog_user="admin"
emlog_password=admin
remote_content="ftp://username:passwd@1.1.1.1/domains/wwww.info/public_html/content"
#----------------------


#-----
mkdir -p "$backup_path"

if [ -d "$backup_path/content" ];then
mv "$backup_path/content" "$backup_path/content_old"
fi



backup_database()
{
	#----get the cookie----
	curl -d "user=$emlog_user&pw=$emlog_password"  "$emlog_domain"/admin/index.php?action=login -c "$backup_path/cookie"


	#----back up database----
	table_backup=(
	"emlog_attachment"
	"emlog_blog"
	"emlog_comment"
	"emlog_options"
	"emlog_navi"
	"emlog_reply"
	"emlog_sort"
	"emlog_link"
	"emlog_tag"
	"emlog_trackback"
	"emlog_twitter"
	"emlog_user"
	)
	table_box=$(
	let i=0;
	for((i=0;i<${#table_backup[@]}-1;i=i+1))
	do
	echo -n "table_box[$i]=${table_backup[$i]}&"
	done
	echo -n "table_box[$i]=${table_backup[$i]}"
	)
	echo $table_box

	sql_file="$(date "+%Y_%m_%d_%H_%M_%S").sql"

	curl  -b "$backup_path/cookie" -L    -d "$table_box"  "$emlog_domain"/admin/data.php?action=bakstart>"$backup_path/$sql_file"

	#----delete the cookie----
	rm -rf "$backup_path/cookie"
}

backup_content()
{
	wget  -r  -nH --cut-dirs=3  -nv "$remote_content" -P "$backup_path"

	#----delete old content
	if  [ -d "$backup__path/content" ];then
		rm -rf "$backup_path/content"
	fi
}


if [ $# -eq 0 ];then
	backup_database
	backup_content
	exit 0

elif [ $# -eq 1 ];then
	if [ "$1" == "all" ];then
		backup_database
		backup_content
		exit 0

	elif [ "$1" == "sql" ];then
		backup_database
		exit 0

	elif [ "$1" == "content" ];then
		backup_content
		exit 0
	else
		echo "operation not supported!"
		exit 1
	fi

else
	echo "operation not supported!"
	exit 1
fi	
