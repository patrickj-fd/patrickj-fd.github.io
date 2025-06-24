[首 页](https://patrickj-fd.github.io/index) | [ai](https://patrickj-fd.github.io/mdfiles/ai/index) | [docker](https://patrickj-fd.github.io/mdfiles/docker/index) | [git](https://patrickj-fd.github.io/mdfiles/git/index) | [net](https://patrickj-fd.github.io/mdfiles/net/index) | [os](https://patrickj-fd.github.io/mdfiles/os/index) | [python](https://patrickj-fd.github.io/mdfiles/python/index)

---

# 联网安装
## 1. 卸载旧版本docker
```
sudo apt-get remove docker docker-engine docker.io
sudo apt-get purge docker docker-ce
sudo rm -rf /var/lib/docker/
# /var/lib/docker/ 这个目录下是Docker的所有安装成果，包括镜像、容器、卷、网络等等。
```
## 2. 更新软件索引
```
sudo apt-get update
```
## 3. 安装一些附属包，允许apt使用HTTPS安装软件
```
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
```
## 4. 添加官方的GPG密钥
```
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
```
## 5. 选择stable版本的apt仓库
```
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
```
## 6. 更新apt仓库的索引并安装
```
sudo apt-get update
sudo apt-get install docker-ce
#sudo apt-get install docker-ce docker-ce-cli containerd.io

docker -v
# hello-world 测试
sudo docker run hello-world
```

# 安装nvidia-docker
```shell
# 以下未验证
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

sudo apt-get update 
sudo apt-get install -y nvidia-container-toolkit
sudo systemctl restart docker

# 测试是否成功
sudo docker container run --rm --gpus all nvidia/cuda:10.0-cudnn7-runtime-ubuntu18.04 nvidia-smi
```

---

[首 页](https://patrickj-fd.github.io/index)

