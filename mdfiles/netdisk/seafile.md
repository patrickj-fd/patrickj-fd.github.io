# 资料
- [官网](https://www.seafile.com/download/)


# 安装
[官网安装手册](https://cloud.seafile.com/published/seafile-manual-cn/docker/%E7%94%A8Docker%E9%83%A8%E7%BD%B2Seafile.md)

- 安装 docker-compose
```shell
sudo apt install docker-compose -y
```

- 配置 docker-compose.yml
```yaml
version: '2.0'
services:
  db:
    image: mariadb:10.5
    container_name: seafile-mysql
    environment:
      - MYSQL_ROOT_PASSWORD=hmfms188  # Requested, set the root's password of MySQL service.
      - MYSQL_LOG_CONSOLE=true
    volumes:
      - /data2/soft/netdisk/seafile/db:/var/lib/mysql  # Requested, specifies the path to MySQL data persistent store.
    networks:
      - seafile-net

  memcached:
    image: memcached:1.6
    container_name: seafile-memcached
    entrypoint: memcached -m 256
    networks:
      - seafile-net

  seafile:
    image: seafileltd/seafile-mc:latest
    container_name: seafile
    ports:
      - "38010:80"
#      - "443:443"  # If https is enabled, cancel the comment.
    volumes:
      - /data2/soft/netdisk/seafile/data:/shared   # Requested, specifies the path to Seafile data persistent store.
    environment:
      - DB_HOST=db
      - DB_ROOT_PASSWD=hmfms188  # Requested, the value shuold be root's password of MySQL service.
      - TIME_ZONE=Asia/Shanghai # Optional, default is UTC. Should be uncomment and set to your local time zone.
      - SEAFILE_ADMIN_EMAIL=Aoot # Specifies Seafile admin user, default is 'me@example.com'.
      - SEAFILE_ADMIN_PASSWORD=hmfms188     # Specifies Seafile admin password, default is 'asecret'.
      - SEAFILE_SERVER_LETSENCRYPT=false   # Whether use letsencrypt to generate cert.
      - SEAFILE_SERVER_HOSTNAME=10.81.1.28 # Specifies your host name or ip.
    depends_on:
      - db
      - memcached
    networks:
      - seafile-net

networks:
  seafile-net:
```

- 启动
```shell
# 在 docker-compose.yml 文件所在的目下执行
sudo docker-compose up -d
```

- **修改配置后生效方式**
```shell
sudo docker-compose down
sudo docker-compose up -d
```

# 客户端
## Linux
- [官网说明](https://help.seafile.com/syncing_client/install_linux_client/)

```shell
sudo wget https://linux-clients.seafile.com/seafile.asc -O /usr/share/keyrings/seafile-keyring.asc
sudo apt install -y seafile-gui
# 如果报错依赖包，则更新下再安装
sudo apt update

# 仅仅安装命令行客户端：
# sudo apt-get install seafile-cli

```