#!/usr/bin/env bash

Ver="1.46"
Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Green_background_prefix="\033[42;37m" && Red_background_prefix="\033[41;37m" && Font_color_suffix="\033[0m"
Tip="${Green_font_prefix}[Tip]${Font_color_suffix}"
WARNING="${Red_font_prefix}[WARNING]${Font_color_suffix}"
Error="${Red_font_prefix}[Error]${Font_color_suffix}"
Info="${Green_font_prefix}[Message]${Font_color_suffix}"
Separator="——————————————————————————————————————————"

Welcome(){
	clear
	echo -e "${Separator}"
	echo -e " ${Tip}  Time: $(date +"%Y-%m-%d %X")"
	echo -e " ${Tip} Tcping check script Ver ${Ver}."
	echo -e " ${Tip} By Jiu."
	echo -e "${Separator}"
	sleep 2s
	echo -e " Loading......"
}

Check_Update(){
	echo -e " ${Tip} Checking update......"
	Result=$( wget -qO- https://teduis.com/Script/TcpCheck.sh | grep -a "Ver" | head -n1 | sed 's/Ver=//' | sed 's/\"//g' )
	if [[ "${Result}" == "${Ver}" ]] ; then
		echo -e " ${Tip} The script is the latest version."
	else
		echo -e " ${Tip} Update..."
		wget -qO TcpCheck.sh https://teduis.com/Script/TcpCheck.sh && chmod +x TcpCheck.sh
		./TcpCheck.sh
	fi
}

Welcome
Check_Update

[[ ! -e "result.log" ]] && touch result.log
[[ ! -e "run.log" ]] && touch run.log

MailCheck(){
	if [[ "${SMTP_ENABLE}" -eq 1 ]] ; then
		echo -e " ${Tip} SMTP is enabled."
		CheckMailuser=$( cat /etc/mail.rc | grep "smtp-auth-user" )
		[[ -n "${CheckMailuser}" ]] && sed -i '/set from/d' /etc/mail.rc && sed -i "/set smtp/d" /etc/mail.rc && sed -i "/set smtp-auth-user/d" /etc/mail.rc && sed -i "/set smtp-auth-password/d" /etc/mail.rc && sed -i "/set smtp-auth=login/d" /etc/mail.rc && sed -i "/set nss-config-dir/d" /etc/mail.rc && sed -i "/set smtp-user-starttls/d" /etc/mail.rc && sed -i "/set ssl-verify/d" /etc/mail.rc
		MailCommand="mail -s"
		if [[ "${SMTP_SSL}" -eq 1 ]] ; then
			 SMTPHOST="smtps://${SMTPHOST}:465"
			 MailCommand="mail -v -s"
			 SMTPSSL_CONFIG="set nss-config-dir=/etc/mail.rc_ssl.crt\nset smtp-user-starttls\nset ssl-verify=ignore"
		fi
		CheckMail=$( cat /etc/mail.rc | grep "${SMTPemailaddress}" )
		[[ ! -n "${CheckMail}" ]] && echo -e "set from="${SMTPemailaddress}"\nset smtp=${SMTPHOST}\nset smtp-auth-user=${SMTPemailuser}\nset smtp-auth-password=${SMTPPassword}\nset smtp-auth=login\n${SMTPSSL_CONFIG}" >> /etc/mail.rc
	else 
		echo -e " ${Tip} SMTP is disabled."
	fi
}

TG_Message_Check(){
	if [[ "${TG_ENABLE}" -eq 1 ]] ; then
		echo -e " ${Tip} Telegram reminder is enabled."
		[[ ! -n "${TG_API_URL}" ]] && echo -e " ${Error} Please edit config.conf" && exit 1
		[[ ! -n "${Telegram_Bot_Api_Key}" ]] && echo -e " ${Error} Please edit config.conf" && exit 1
		[[ ! -n "${Telegram_User_ID}" ]] && echo -e " ${Error} Please edit config.conf" && exit 1
	else
		echo -e " ${Tip} Telegram reminder is disabled."
	fi
}

Success(){
  IPaddr="$1"
  Portnum="$2"
  Successed="$3"
  Failed="$4"
  Average="$5"
  Remarks="$6"
  Timecount
  if [[ -n "${Remarks}" ]] ; then
		Templates="Remarks:${Remarks} IP:${IPaddr} Port:${Portnum} 本次测试目前在线，成功次数：${Successed} 失败次数：${Failed} 平均延时：${Average}"
		MTemplates="Tip:${IP}( ${Remarks} ) 目前在线，本次测试成功次数：${Successed} 失败次数：${Failed} 平均延时：${Average}"
		TGTemplates="***Tip***:  ***${IP}***( ${Remarks} ) 目前在线，本次测试成功次数：***${Successed}*** 失败次数：***${Failed}*** 平均延时：***${Average}***"
	else
		Templates="IP:${IPaddr} Port:${Portnum} 目前在线，本次测试成功次数：${Successed} 失败次数：${Failed} 平均延时：${Average}"
		MTemplates="Tip:${IP} 目前在线，本次测试成功次数：${Successed} 失败次数：${Failed} 平均延时：${Average}"
		TGTemplates="***Tip***:  ***${IP}*** 目前在线，本次测试成功次数：***${Successed}*** 失败次数：***${Failed}*** 平均延时：***${Average}***"
	fi
	echo -e " ${Info} Date:[ $(date +"%Y-%m-%d %X") ] ${Templates}"
	Added_or_not=$( cat run.log | grep "${IPaddr}" )
	if [[ -n "${Added_or_not}" ]] ; then
		 Starttime=$( cat run.log | grep "${IPaddr}" | grep "Time" | sed 's/ '${IPaddr}' Time://' )
		 ((DownTime=(${Timenow}-${Starttime})/60))
		 	if [[ "${DownTime}" -gt 60 ]] ; then
		 		((DownTimehour=(${Timenow}-${Starttime})/60/60))
		 		((DownTimemin=(${DownTime}-${DownTimehour}*60)))
		 		DownTime="${DownTimehour} hours ${DownTimemin} minutes."
		 	else
		 		DownTime="${DownTime} minutes."
		 	fi
			if [[ -n "${Remarks}" ]] ; then
				MTemplates="Tip:${IP}( ${Remarks} ) 目前在线，本次测试成功次数：${Successed} 失败次数：${Failed} 平均延时：${Average} ，监测到服务器掉线时长：${DownTime}"
				TGTemplates="***Tip***:  ***${IP}***( ${Remarks} ) 现已在线，下线时长为 ***${DownTime}*** 本次测试成功次数：***${Successed}*** 失败次数：***${Failed}*** 平均延时：***${Average}***"
			else
				MTemplates="Tip:${IP} 目前在线，本次测试成功次数：${Successed} 失败次数：${Failed} 平均延时：${Average} ，监测到服务器掉线时长： ${DownTime}"
				TGTemplates="***Tip***:  ***${IP}*** 现已在线，下线时长为 ***${DownTime}*** 本次测试成功次数：***${Successed}*** 失败次数：***${Failed}*** 平均延时：***${Average}***"
			fi
		 sed -i '/'${IPaddr}'/d' run.log
		 echo -e " Date:[ $(date +"%Y-%m-%d %X") ] Tip: ${MTemplates}" >> result.log
		 Sendmail "${MTemplates}" "Date:[ $(date +"%Y-%m-%d %X") ] ${MTemplates} , 请注意."
		 Send_TG_Message "${TGTemplates}"
		 echo -e " ${Info} Date:[ $(date +"%Y-%m-%d %X") ] 现已在线，下线时长为 ${DownTime}"
	fi
}

Send_TG_Message(){
	Message="$1"
	if [[ "${TG_ENABLE}" -eq 1 ]] ; then
		SendMessage=$( curl -s -g "https://${TG_API_URL}/bot${Telegram_Bot_Api_Key}/sendMessage?chat_id=${Telegram_User_ID}&text=${Message}&parse_mode=markdown" )
		Check=$( echo "${SendMessage}" | grep "true" )
		if [[ -n "${Check}" ]] ; then
			echo -e " ${Tip} Telegram message sent successful."
		else
			echo -e " ${Error} Telegram message sent failed."
		fi
	else
		echo -e " ${Tip} Telegram reminder has been disabled,unsent message."
	fi
}

Sendmail(){
	Title="$1"
	Message="$2"
	if [[ "${SMTP_ENABLE}" -eq 1 ]] ; then
		echo -e "${Message}" | ${MailCommand} "${Title}" ${Myemail} > /dev/null 2>&1
		if [[ "$?" -eq 0 ]] ; then
			echo -e " ${Tip} Email sent successful."
		else
			echo -e " ${Error} Email sent failed."
		fi
	else
		echo -e " ${Tip} SMTP has been disabled,unsent email."
	fi
}

Timecount(){
	Timenow=$( date '+%s' )
}

Failed(){
  IPaddr="$1"
  Portnum="$2"
  Remarks="$3"
  Timecount
	if [[ -n "${Remarks}" ]] ; then
		Templatef="Remarks:${Remarks} IP:${IPaddr} Port:${Portnum} tcping failed. Maybe your server is offline,or it may be banned for TCP."
		MTemplatef="Warning:${IP}( ${Remarks} ) may offline , or it may be banned for TCP."
		TGTemplates="***Warning***:  ***${IP}***( ${Remarks} ) TCPING检测到服务器***掉线***或端口不通。 "
	else
		Templatef="IP:${IPaddr} Port:${Portnum} tcping failed. Maybe your server is offline,or it may be banned for TCP."
		MTemplatef="Warning:${IP} may offline , or it may be banned for TCP."
		TGTemplates="***Warning***:  ***${IP}*** TCPING检测到服务器***掉线***或端口不通。 "
	fi
	echo -e " ${WARNING} Date:[ $(date +"%Y-%m-%d %X") ] ${Templatef}"
	Added_or_not=$( cat run.log | grep "${IPaddr}" )
	if [[ ! -n "${Added_or_not}" ]] ; then
		 echo " Date:[ $(date +"%Y-%m-%d %X") ] WARNING: ${Templatef}" >> result.log 
		 echo " Date:[ $(date +"%Y-%m-%d %X") ] WARNING: ${Templatef}" >> run.log 
		 echo " ${IPaddr} Time:${Timenow} " >> run.log 
		 Sendmail "${MTemplatef}" "Date:[ $(date +"%Y-%m-%d %X") ] ${MTemplatef} , please notice."
		 Send_TG_Message "${TGTemplates}"
	fi
}

Checkifip(){
	Checkipaddr=$( echo "$1" | grep "^[0-9]\{1,3\}\.\([0-9]\{1,3\}\.\)\{2\}[0-9]\{1,3\}$" )
}

Main(){
		while true
		do
			for (( i=1;i<$[${count}+1];i++ ))
				do
					IP_Port=$( echo -e "${IP_PortRead}" | sed -n ''$i'p' )
					IPorDomain=$( echo ${IP_Port} | awk '{print $1}' )
					Checkifip ${IPorDomain}
					if [[ "$?" -eq 0 ]] ; then
						IP=${IPorDomain}
					else
						IP=$( dig -t a ${IPorDomain} +noqu | grep "${IPorDomain}" | sed -n '2p' | sed 's/\t/\n/g' | grep "^[0-9]\{1,3\}\.\([0-9]\{1,3\}\.\)\{2\}[0-9]\{1,3\}$" )
					fi
					Port=$( echo ${IP_Port} | awk '{print $2}' )
					Remark=$( echo ${IP_Port} | awk '{print $3}' )
					CheckWhetherClosed=$( tcpingc ${IP} ${Port} -u 4000000 | grep "closed" )
					if [[ ! -n "${CheckWhetherClosed}" ]] ; then
						Tcping_Result=$( tcping ${IP} -p ${Port} -c 5 --report )
						if [[ "$?" -eq 1 ]] ; then
							Failed ${IP} ${Port} ${Remark}
						else
							Result=$( echo -e "${Tcping_Result}" | tail -n2 | sed 's/-//g' | sed 's/+//g' | sed 's/|//g' | head -n1 )
							Successed=$( echo -e "${Result}" | awk '{print $3}' )
							Failed=$( echo -e "${Result}" | awk '{print $4}' )
							Average=$( echo -e "${Result}" | awk '{print $8}' )
							if [[ "${Successed}" -eq "0" ]] ; then
								Failed ${IP} ${Port} ${Remark}
							else
								Success ${IP} ${Port} ${Successed} ${Failed} ${Average} ${Remark}
							fi
						fi
					else
						Failed ${IP} ${Port} ${Remark}
					fi
			done
		sleep 30s
	done
}

checklog(){
	log=$( cat result.log | sed 's/WARNING/\\033\[31m\[WARNING\]\\033\[0m/g' | sed 's/Tip/\\033\[32m\[Tip\]\\033\[0m/g' )
	echo -e "${log}"
	exit 1
}

Check_Sys(){
	if [[ -f /etc/redhat-release ]]; then
		release="centos"
	elif cat /etc/issue | grep -q -E -i "debian"; then
		release="debian"
	elif cat /etc/issue | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /etc/issue | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
	elif cat /proc/version | grep -q -E -i "debian"; then
		release="debian"
	elif cat /proc/version | grep -q -E -i "ubuntu"; then
		release="ubuntu"
	elif cat /proc/version | grep -q -E -i "centos|red hat|redhat"; then
		release="centos"
    fi
	bit=`uname -m`
}

Install(){
	echo -e " ${Tip} Installing......"
	if [[ "${release}" == "centos" ]] ; then
		yum install bind-utils mail sendmail screen sed gawk grep gcc make python python-devel python-setuptools -y
	else
		apt-get update
		apt-get install sendmail heirloom-mailx screen grep sed gawk dnsutils gcc make python python-setuptools -y
	fi
	wget -q https://teduis.com/Software/tcping-1.3.5.tar.gz
	tar -zxf tcping-1.3.5.tar.gz
	pushd tcping-1.3.5
	make
	mv tcping /usr/bin/tcpingc
	pushd +1
	echo -e " ${Tip} Installing PIP."
	wget -q https://github.com/pypa/pip/archive/9.0.3.tar.gz
	tar -zxf 9.0.3.tar.gz
	pushd pip-9.0.3
	python setup.py install
	pushd +1
	pip install tcping
	echo -e " ${Tip} Install done."
	exit 0
}

Gomain(){
	[[ ! -d "/etc/mail.rc_ssl.crt" ]] && mkdir /etc/mail.rc_ssl.crt && wget -O /etc/mail.rc_ssl.crt/ssl.tar.gz -q 'https://raw.githubusercontent.com/Thnineer/Bash/master/Source/ssl.tar.gz' && pushd /etc/mail.rc_ssl.crt && tar -zxf ssl.tar.gz && pushd +1
	[[ ! -e "config.conf" ]] && echo -e " ${Error} The configuration file is not found.Please edit config.conf." && echo -e 'SMTP_ENABLE="1"   #是否启用SMTP功能，启用为1 \nSMTPemailaddress=""   #SMTP发件地址 \nSMTPHOST=""   #SMTP发件主机 \nSMTPemailuser=""   #SMTP用户名 \nSMTPPassword=""   #SMTP账户密码 \nMyemail=""   #收件邮箱 \nSMTP_SSL="1"  #是否启用SSL' && exit 0
	source config.conf
	MailCheck
	TG_Message_Check
	IP_PortRead=$( cat ${file} | sed '/^#/d' | sed '/^[[:space:]]*$/d' )
	count=$( echo -e "${IP_PortRead}" | wc -l )
	[[ ! -n "${file}" ]] && echo -e " ${Error} No file input." && exit 0
	echo -e " ${Tip} Start monitoring......"
	Main
}

while [[ $# -ge 1 ]]; do
  case $1 in
  	-f|--file)
      shift
    	file="$1"
    	Gomain
      shift
      ;;
    -l|--log)
      shift
      checklog
      shift
      ;;
    install)
      shift
      Check_Sys
      Install
      ;;
    *)
    	echo -e " ${Tip} Unknown action!"
      exit 1;
      ;;
    esac
  done
 