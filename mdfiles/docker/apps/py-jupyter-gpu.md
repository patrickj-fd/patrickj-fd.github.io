[首 页](https://patrickj-fd.github.io/index) | [ai](https://patrickj-fd.github.io/mdfiles/ai/index) | [docker](https://patrickj-fd.github.io/mdfiles/docker/index) | [git](https://patrickj-fd.github.io/mdfiles/git/index) | [net](https://patrickj-fd.github.io/mdfiles/net/index) | [os](https://patrickj-fd.github.io/mdfiles/os/index) | [python](https://patrickj-fd.github.io/mdfiles/python/index)

---

# 构建 Jupyter GPU 镜像

因为Jupyter环境仅用于开发，所以安装软件时，没有清理缓存。  
注意对 '\\$' 的用法。因为是在shell脚本中书写的Dockerfile。  

```shell
#!/bin/bash

# 【设置 .dockerignore】
cat > .dockerignore << EOF
*
!soft/node-v12.16.1-linux-x64.tar.xz
EOF

# 【构建镜像】
VERSION=2.0.2
IMAGE_NAME="jupyter"
IMAGE_TAG="${VERSION}-python-GPU"

DFILE_NAME=/tmp/DF-$IMAGE_NAME-$IMAGE_TAG.df
# -------------------------------- Dockerfile Start --------------------------------------
WORKDIR_VAL="/jpbook"
cat >$DFILE_NAME <<EOF
FROM python-basic:3.6-GPU-cuda10.0-cudnn7

ENV  HR_OSLABEL=$IMAGE_NAME:$IMAGE_TAG

# ========== install soft ==========
# gcc python3-dev : for ujson using by jupyter-lsp
RUN  set -ex \\
     && apt-get update \\
     && apt-get install -yq --no-install-recommends openssh-server net-tools xz-utils vim wget bzip2 unzip curl git \\
     && apt-get install -yq --no-install-recommends gcc python3-dev \\
     && mkdir /run/sshd \\
     && echo "root:hrs@6688" | chpasswd \\
     && echo "PermitRootLogin yes" >> /etc/ssh/sshd_config \\
     && cat /etc/ssh/sshd_config

# install node for jupyter
ADD  soft/node-v12.16.1-linux-x64.tar.xz /opt/
ENV  PATH=\$PATH:/opt/node-v12.16.1-linux-x64/bin

# ========== install jupyter ==========
RUN  set -ex \\
     && pip3 install matplotlib Scikit-Image opencv-python \\
     && pip3 install jupyterlab==${VERSION} jupyter-lsp \\
     && jupyter labextension install @jupyter-widgets/jupyterlab-manager @jupyterlab/toc \\
                @krassowski/jupyterlab-lsp @krassowski/jupyterlab_go_to_definition \\
     && pip3 install python-language-server[all] \\
# start-jupyterlab
     && echo "nohup jupyter lab --notebook-dir=$WORKDIR_VAL --ip 0.0.0.0 --no-browser --allow-root > /var/log/jupyterlab.log 2>&1 &" > /bin/start-jupyterlab.sh \\
     && echo "echo " >> /bin/start-jupyterlab.sh \\
     && echo "echo 'Waitting log : /var/log/jupyterlab.log ... ...'" >> /bin/start-jupyterlab.sh \\
     && echo "tail -f /var/log/jupyterlab.log" >> /bin/start-jupyterlab.sh \\
     && chmod a+x /bin/start-jupyterlab.sh

RUN  set -ex \\
     && mkdir -p /root/.config \\
     && echo "[pycodestyle]" > /root/.config/pycodestyle \\
     && echo "ignore = E402, E703, E251, E121, E122" >> /root/.config/pycodestyle \\
     && echo "max-line-length = 120" >> /root/.config/pycodestyle \\
# ipython_config
     && mkdir -p /root/.ipython/profile_default \\
     && echo "c = get_config()" > /root/.ipython/profile_default/ipython_config.py \\
     && echo "c.InteractiveShell.ast_node_interactivity = 'all'" >> /root/.ipython/profile_default/ipython_config.py \\
# over
     && echo "Done!"

WORKDIR $WORKDIR_VAL

EXPOSE 8888

CMD  ["/usr/sbin/sshd", "-D"]
#CMD  ["python3", "-m", "http.server"]
#CMD ["bash", "-c", "jupyter lab --notebook-dir=/jpbook --ip 0.0.0.0 --no-browser --allow-root"]

EOF
# -------------------------------- Dockerfile End  -------------------------------------

sudo docker build -f $DFILE_NAME -t $IMAGE_NAME:$IMAGE_TAG .
echo 
echo "====================================================================="
echo 
echo "jupyter image build success : ( $IMAGE_NAME:$IMAGE_TAG )"
echo 
echo "Checking it :"
echo "docker container run -d --name cartest-$IMAGE_NAME $IMAGE_NAME:$IMAGE_TAG"
echo 
echo "====================================================================="
echo 
```

---

[首 页](https://patrickj-fd.github.io/index)
