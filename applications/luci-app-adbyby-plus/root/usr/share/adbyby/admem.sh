#!/bin/sh

if [ ! -f "/tmp/adbyby.updated" ];then
	touch /tmp/adbyby.mem
	wget_ok="0"
	while [ "$wget_ok" = "0" ];do 
		uclient-fetch --spider --quiet --tries=1 --timeout=3 www.baidu.com
		if [ "$?" == "0" ]; then
			wget_ok="1"
			touch /tmp/md5.json && uclient-fetch --no-check-certificate -t 1 -T 10 -O /tmp/md5.json https://cdn.jsdelivr.net/gh/kongfl888/ad-rules/md5.json && dos2unix /tmp/md5.json
			adm5=$(md5sum /tmp/md5.json | awk -F' ' '{print $1}')
			touch /tmp/adbyby/admd5.json && bmd5=$(md5sum /tmp/adbyby/admd5.json | awk -F' ' '{print $1}')
			if [ "$adm5" == "$bmd5" ];then
				echo "Rules MD5 are the same!"
				echo $(date "+%Y-%m-%d %H:%M:%S") > /tmp/adbyby.updated
				exit 0
			else
				touch /tmp/lazy.txt && uclient-fetch --no-check-certificate -t 1 -T 10 -O /tmp/lazy.txt https://cdn.jsdelivr.net/gh/kongfl888/ad-rules/lazy.txt && dos2unix /tmp/lazy.txt
				touch /tmp/video.txt && uclient-fetch --no-check-certificate -t 1 -T 10 -O /tmp/video.txt https://cdn.jsdelivr.net/gh/kongfl888/ad-rules/video.txt && dos2unix /tmp/video.txt
				touch /tmp/local-md5.json && md5sum /tmp/lazy.txt /tmp/video.txt > /tmp/local-md5.json
				lazy_local=$(grep 'lazy' /tmp/local-md5.json | awk -F' ' '{print $1}')
				video_local=$(grep 'video' /tmp/local-md5.json | awk -F' ' '{print $1}')
				lazy_online=$(sed 's/":"/\n/g' /tmp/md5.json | sed 's/","/\n/g' | sed -n '2p')
				video_online=$(sed 's/":"/\n/g' /tmp/md5.json | sed 's/","/\n/g' | sed -n '4p')
				if [ "$lazy_online"x == "$lazy_local"x -a "$video_online"x == "$video_local"x ]; then
					echo "adbyby rules MD5 OK!"
					mv /tmp/lazy.txt /tmp/adbyby/data/lazy.txt
					mv /tmp/video.txt /tmp/adbyby/data/video.txt
					mv /tmp/md5.json /tmp/adbyby/admd5.json
					echo $(date "+%Y-%m-%d %H:%M:%S") > /tmp/adbyby.updated
				fi
			fi
		else
			sleep 10
		fi
	done
	sleep 10 && /etc/init.d/adbyby restart
fi
