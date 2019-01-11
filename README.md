# TcpCheck
## 功能：

已完成的：
不间断监测
SMTP邮件提醒
TG机器人提醒
掉线时间统计
准确率提升
平均延时显示
未完成：
比较漂亮的邮件模板

## 用法

*下载

```
wget -q https://teduis.com/Script/TcpCheck.sh && chmod +x TcpCheck.sh
```

*建议先安装screen以保持脚本不间断运行
Centos

```
yum install screen -y
```

Ubuntu/Debian

```
apt-get install screen -y
```

*安装

```
./TcpCheck.sh install
```

*配置
同目录下新建`config.conf`，加入以下内容：

```
SMTP_ENABLE="1"    #是否开启SMTP
TG_ENABLE="1"   #是否开启Telegram提醒
SMTPemailaddress="example@example.com"    #SMTP发件地址
SMTPHOST="smtp.example.com"    #SMTP服务器
SMTPemailuser="example"    #SMTP登录用户名
SMTPPassword="examplepasswd"    #SMTP登录密码
Myemail="mail@example.net"    #收件邮箱
SMTP_SSL="1"    #是否开启SMTP的SSL
TG_API_URL="api.telegram.org"  #Telegram API地址（可以反代）
Telegram_Bot_Api_Key="1234564444:sdnasbdjasdjasbdjbcs"  #Telegram bot api key
Telegram_User_ID="22222222"   #你的Telegram 用户ID
```

*如何获取Telegram用户ID?
点击[Telegram_get_id_bot](https://t.me/get_id_bot) 向它发送/start即可获取自己的用户ID。

**重要**
在配置好脚本后，请使用与填写的Telegram用户ID相同的TG私聊你自己的bot，并点击开始，否则机器人无法直接私聊你。

任意目录下新建一个文件，填写需要监测的IP/域名与端口，格式：

```
IP/域名 端口 备注(可以不写)
```

例：

```
8.8.8.8 53 googledns
114.114.114.114 53
google.com 80 googleweb
```

*使用

```
screen -S TcpCheck   #关掉SSH窗口后可继续运行，运行`screen -r TcpCheck`以查看
./TcpCheck.sh -f '文件位置'
```

*查看log

```
./TcpCheck.sh -l
```
