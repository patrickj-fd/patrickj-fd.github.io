[首 页](https://patrickj-fd.github.io/index)

---

- 安装文泉驿字体
```
sudo apt-get install -y fonts-wqy-zenhei fonts-wqy-microhei xfonts-wqy
```

- 安装指定的字体文件
```
# 以苹果的最美字体"monaco"和Windows常用字体"宋体"为例

# 1. 创建字体存放目录
sudo mkdir -p /usr/share/fonts/truetype/custom/
sudo mkdir -p /usr/share/fonts/truetype/windows-fonts

# 2. 拷贝字体文件到该目录下
windows字体：C:\Windows\Fonts
- 宋体：simsunb.ttf, simsun.ttc 微软雅黑：msyhbd.ttc, msyh.ttc
- WPS Office 所需字体：wingding.ttf、webdings.ttf、symbol.ttf、WINGDNG3.TTF、WINGDNG2.TTF、MTExtra.ttf

苹果monaco ：sudo wget -c https://github.com/todylu/monaco.ttf/blob/master/monaco.ttf?raw=true

# 3. 更新字体缓存
sudo mkfontscale
sudo mkfontdir
sudo fc-cache -f -v

# 4. 或许应该再重启下系统
```


打开gnome-tweak-tool，选择字体选项卡，然后就可以替换字体了

---

[首 页](https://patrickj-fd.github.io/index)
