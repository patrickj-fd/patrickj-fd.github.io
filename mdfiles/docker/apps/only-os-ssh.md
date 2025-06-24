[首 页](https://patrickj-fd.github.io/index) | [ai](https://patrickj-fd.github.io/mdfiles/ai/index) | [docker](https://patrickj-fd.github.io/mdfiles/docker/index) | [git](https://patrickj-fd.github.io/mdfiles/git/index) | [net](https://patrickj-fd.github.io/mdfiles/net/index) | [os](https://patrickj-fd.github.io/mdfiles/os/index) | [python](https://patrickj-fd.github.io/mdfiles/python/index)

---

# 构建镜像

```shell
#!/bin/bash

# 【设置 .dockerignore】
cat > .dockerignore << EOF
*
EOF

# 【构建镜像】
IMAGE_NAME="only-os-ssh"
IMAGE_TAG="ubuntu-18.04"

DFILE_NAME=/tmp/DF-$IMAGE_NAME-$IMAGE_TAG.df
SOURCES_LIST=$(cat /data1/docker/apps/apt-sources.list)
# -------------------------------- Dockerfile Start --------------------------------------
cat >$DFILE_NAME <<EOF
FROM ubuntu:18.04

ENV  TZ=Asia/Shanghai DEBIAN_FRONTEND=noninteractive HR_OSLABEL=$IMAGE_NAME:$IMAGE_TAG

RUN  set -ex && \\
$SOURCES_LIST
     apt-get update && \\
     apt-get install -y --no-install-recommends tzdata && \\
     ln -sf /usr/share/zoneinfo/\$TZ /etc/localtime && echo \$TZ > /etc/timezone && \\
     dpkg-reconfigure -f noninteractive tzdata \\
     && apt-get install -yq --no-install-recommends locales \\
     && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \\
# ssh
     && apt-get install -yq --no-install-recommends openssh-server nano \\
#     && apt-get clean 
#     && rm -rf /var/lib/apt/lists/* 
     && mkdir /run/sshd \\
     && echo "root:hrs@6688" | chpasswd \\
     && echo "PermitRootLogin yes" >> /etc/ssh/sshd_config \\
# over
     && echo "Done!"

WORKDIR /data

ENV LANG=en_US.utf8 LC_ALL=en_US.UTF-8 LANGUAGE=en_US.UTF-8

CMD  ["/usr/sbin/sshd", "-D"]

EOF
# -------------------------------- Dockerfile End  -------------------------------------

sudo docker build -f $DFILE_NAME -t $IMAGE_NAME:$IMAGE_TAG .
echo 
echo "====================================================================="
echo 
echo "image build success : ( $IMAGE_NAME:$IMAGE_TAG )"
echo "root password : hrs@6688"
echo 
echo "Checking it :"
echo "docker container run -d --name cartest-$IMAGE_NAME $IMAGE_NAME:$IMAGE_TAG"
echo 
echo "====================================================================="
echo 
```

---

[首 页](https://patrickj-fd.github.io)
