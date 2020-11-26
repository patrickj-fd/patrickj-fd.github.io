
# 在 Nano 上安装 AI 应用

---

**使用 hyren 用户工作**

```shell
mkdir /hyren/app
cd /hyren/app

git clone http://139.9.126.19:38111/zhihuinongan/python.git
mv python zhihuinongan

cd /hyren/app/python/resources/module/nongan
# get model file :
sftp root@172.168.0.63
> get last1.h5
> bye

source ~/pyvenv-tf15  # cp from : /hyren/python/venv/tf-1.15/bin/activate

python3 -m pip install -U git+http://139.9.126.19:38111/FdcoreHyren/feedwork-py.git
python3 -m pip install flask==1.1.2 requests==2.25.0 pillow==8.0.1
# python3 -m pip install matplotlib==3.3.2 h5py==2.10.0

cat > start.sh << EOF
HRS_RESOURCES_ROOT=/hyren/app/zhihuinongan/resources
python3 ....../xxx.py
EOF
chown u+x start.sh

```

---

