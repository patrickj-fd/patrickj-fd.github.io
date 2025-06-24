

原始的树莓派官方镜像第一次启动后会自动扩展整个 SD 卡空间，恢复备份镜像后首次开机需要 sudo raspi-config 扩展 SD 卡使用空间。

```shell
su -

HRE_CODE=400

# 1. change hostname
hostnamectl set-hostname hre${HRE_CODE}-pi
cp /etc/hosts ./hosts.bak # backup

sed -i "s/127\.0\.1\.1\t\traspberrypi/127\.0\.1\.1\t\thre${HRE_CODE}-pi/g" /etc/hosts
cat /etc/hosts

# 2. modify frpc ssh
EdgeName="pi"
sed -i "s/HRE_ORG_NO/${HRE_ORG_NO}/g" /opt/HRETNC/ssh.ini
sed -i "s/EdgeName/${EdgeName}/g" /opt/HRETNC/ssh.ini

systemctl start HRETNC-ssh
systemctl status HRETNC-ssh  # check : Active: active (running)
systemctl enable HRETNC-ssh
# 重启主机并验证
reboot
# 自己笔记本上验证可以ssh上去（hyren 登陆）
ssh hyren@139.9.126.19 -oPort=上面设置的端口
exit

# 再次登陆到新安装的设备上(pi/nano)
su -
# 查看服务是否启动了，所属用户应该是：nobody
ps -ef|grep HRE
# 查看开发服务的启动日志是否有错误。应该没有任何输出
journalctl | grep HRE

```