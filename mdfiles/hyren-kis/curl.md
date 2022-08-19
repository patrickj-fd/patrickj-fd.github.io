
[参考](https://www.cnblogs.com/fan-gx/p/12321351.html)

- 看响应头信息
curl -I url
如果使用`-d`参数，那么应该用`-i`代替`-I`，否则会报警告。

- 需要session认证的网站
curl -c session.txt url
curl -b session.txt url

- 需要Basic认证的网站
响应头类似如下内容的：
WWW-Authenticate: Basic realm="Realm"
X-Content-Type-Options: nosniff
....

curl -u <username>:<password> url

- Spring Security 登录认证后继续访问后续API
curl -c tmp/session.txt -X POST -d "username=admin&password=admin" http://localhost:8101/login
curl -b tmp/session.txt http://localhost:8101/order/add

注意：直接访问后端，会有跨域的问题（会出现 302 DENY 的响应）

curl -c tmp/se-admin.txt -X POST -d "username=admin&password=admin" http://localhost:8101/login
curl -c tmp/se-manager.txt -X POST -d "username=manager&password=1" http://localhost:8101/login

curl -b tmp/se-admin.txt http://localhost:8101/order/add
curl -b tmp/se-admin.txt http://localhost:8101/order/counts
curl -b tmp/se-manager.txt http://localhost:8101/order/add
curl -b tmp/se-manager.txt http://localhost:8101/order/counts
