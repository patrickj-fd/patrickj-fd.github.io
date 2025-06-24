[首 页](https://patrickj-fd.github.io/index) | [ai](https://patrickj-fd.github.io/mdfiles/ai/index) | [docker](https://patrickj-fd.github.io/mdfiles/docker/index) | [git](https://patrickj-fd.github.io/mdfiles/git/index) | [net](https://patrickj-fd.github.io/mdfiles/net/index) | [os](https://patrickj-fd.github.io/mdfiles/os/index) | [python](https://patrickj-fd.github.io/mdfiles/python/index)

---

Windows平台下，“宋体”、“微软雅黑”、“Courier New(编程字体)”用的比较多，看的也习惯了。那如何在 Ubuntu下也安装这些字体呢？

操作步骤如下：

第一步：从 Windows 7 系统下字体文件（C:\Windows\Fonts）
- 宋体：simsunb.ttf 和 simsun.ttc
- 微软雅黑：msyhbd.ttf
- Courier New：courbd.ttf、courbi.ttf、couri.ttf 和 cour.ttf
- WPS Office 所需字体：wingding.ttf、webdings.ttf、symbol.ttf、WINGDNG3.TTF、WINGDNG2.TTF、MTExtra.ttf

第二步：新建字体存放目录 windows-font
```
sudo mkdir /usr/share/fonts/truetype/windows-font
```
第三步：拷贝字体到wiondow-font目录下
```
sudo cp /home/php-note/123/* /usr/share/fonts/truetype/windows-font
```
第四步：修改权限，并更新字体缓存
```
sudo chmod -R 777 /usr/share/fonts/truetype/windows-font

cd /usr/share/fonts/truetype/windows-font

sudo mkfontscale

sudo mkfontdir

sudo fc-cache -fv
```
第五步：重启系统

---

[首 页](https://patrickj-fd.github.io/index)
