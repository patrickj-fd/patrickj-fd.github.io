[首 页](https://patrickj-fd.github.io/index)

---

# 构建镜像

```shell
#!/bin/bash
set -e
# 【设置 .dockerignore】
cat > .dockerignore << EOF
*
EOF

# 【构建镜像】

IMAGE_NAME="hrs-neo4j"
IMAGE_TAG="3.5"

DFILE_NAME=/tmp/DF-$IMAGE_NAME-$IMAGE_TAG.df
# ----------------- Dockerfile Start -----------------
cat >$DFILE_NAME <<EOF
FROM neo4j:3.5

ENV  TZ=Asia/Shanghai \
     NEO4J_AUTH=none

EOF
# ----------------- Dockerfile End  -----------------

sudo docker build -f $DFILE_NAME -t $IMAGE_NAME:$IMAGE_TAG .
echo 
echo "====================================================================="
echo 
echo "image build success : ( $IMAGE_NAME:$IMAGE_TAG )"
echo 
echo "====================================================================="
echo 
```

# 启动容器
```
CAR_NAME="hrs-pgsql"
DATA_DIR="/tmp/data"
sudo docker container run -d --name $CAR_NAME \
     -p 37474:7474 -p 37687:7687 \
     -v $DATA_DIR:/data \
     hrs-neo4j:3.5
```

---

[首 页](https://patrickj-fd.github.io)
