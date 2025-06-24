[首 页](https://patrickj-fd.github.io/index) | [ai](https://patrickj-fd.github.io/mdfiles/ai/index) | [docker](https://patrickj-fd.github.io/mdfiles/docker/index) | [git](https://patrickj-fd.github.io/mdfiles/git/index) | [net](https://patrickj-fd.github.io/mdfiles/net/index) | [os](https://patrickj-fd.github.io/mdfiles/os/index) | [python](https://patrickj-fd.github.io/mdfiles/python/index)

---

# 确认字体文件该用什么名字使用
```
fc-list | grep mac
```
执行以上命令，会看到一个匹配清单：
```
/usr/share/fonts/truetype/mac/monaco.ttf: Monaco:style=Regular
```
其中，字体文件名(monaco.ttf)和style之间的名字，就是可使用的字体名。

# 安装文泉驿字体
```
sudo apt-get install -y fonts-wqy-zenhei fonts-wqy-microhei xfonts-wqy
```

# 安装MS和苹果字体
以苹果的最美字体"monaco"和Windows常用字体"宋体"为例
```
# 1. 创建字体存放目录
sudo mkdir -p /usr/share/fonts/truetype/custom/
sudo mkdir -p /usr/share/fonts/truetype/windows-fonts

# 2. 拷贝字体文件到该目录下
windows字体：C:\Windows\Fonts
- 宋体：simsunb.ttf, simsun.ttc 微软雅黑：msyhbd.ttc, msyh.ttc
- WPS Office 所需字体：wingding.ttf、webdings.ttf、symbol.ttf、WINGDNG3.TTF、WINGDNG2.TTF、MTExtra.ttf

苹果monaco ：sudo wget -c https://github.com/todylu/monaco.ttf/blob/master/monaco.ttf?raw=true

# 3. 更新字体缓存
# sudo mkfontscale
# sudo mkfontdir
# 只做下面这一步就可以了
sudo fc-cache -f -v

# 4. 查看字体是否生效
fc-list  | grep "sim.*"
```

# 最好的编程字体
- source code pro : Adobe免费开源的字体
> https://github.com/adobe-fonts/source-code-pro
```
# 官网下载发行包，解压
sudo mkdir -p /usr/share/fonts/truetype/source-code-pro
sudo cp -r source-code-pro/TTF/ /usr/share/fonts/truetype/source-code-pro
sudo fc-cache -f -v
fc-list | grep "source-code-pro"
```

- Hack 
> https://github.com/source-foundry/Hack
安装：
```
wget -c https://github.com/source-foundry/Hack/releases/download/v3.003/Hack-v3.003-ttf.tar.gz
tar xf Hack-v3.003-ttf.tar.gz
sudo mkdir -p /usr/share/fonts/truetype/Hack
sudo cp ttf/* /usr/share/fonts/truetype/Hack
sudo cp 45-Hack.conf /etc/fonts/conf.d/   # get it from github above
sudo fc-cache -f -v
fc-list | grep "Hack"
```

---

[首 页](https://patrickj-fd.github.io/index)
