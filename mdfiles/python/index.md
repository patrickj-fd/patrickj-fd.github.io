[首 页](https://patrickj-fd.github.io/index) | [ai](https://patrickj-fd.github.io/mdfiles/ai/index) | [docker](https://patrickj-fd.github.io/mdfiles/docker/index) | [git](https://patrickj-fd.github.io/mdfiles/git/index) | [net](https://patrickj-fd.github.io/mdfiles/net/index) | [os](https://patrickj-fd.github.io/mdfiles/os/index) | [python](https://patrickj-fd.github.io/mdfiles/python/index)

---
> 镜像源： https://mirrors.aliyun.com/pypi/simple/

# 安装
- [嵌入版安装](embed.md)
- [源码编译安装](install-bysrc)
- [创建虚拟环境](venv)

# 通用
- [安装自己的程序到系统中](deploy-myapp)
- [Jupyter](jupyter)

# 开发
- [pandas](pandas)


# 视频剪辑
```python
from moviepy.editor import VideoFileClip, concatenate_videoclips, TextClip, CompositeVideoClip
 
# 加载视频文件
video = VideoFileClip("tmp/ttt.mov")
 
# # 提取指定时间区间内的部分
# final_clip = video.subclip(1, 100)

# 删除一段
del_start = 120+34 # 2分34妙
del_end   = 180+34 # 3分34妙
clip1 = video.subclip(t_start=1, t_end=del_start)
clip2 = video.subclip(t_start=del_end)
final_clip = concatenate_videoclips([clip1, clip2])

# # 添加文字
# # 创建新的视频对象并设置参数（如位置、大小等）
# text_clip = TextClip(txt="Hello World", fontsize=70, color='white')
# text_clip = text_clip.set_position('center').set_duration(10) # 持续时间为10秒
 
# # 将文本与原始视频合并
# final_clip = CompositeVideoClip([video, text_clip])
 

# 输出
output_file = "tmp/ttt-sub.mp4"
final_clip.write_videofile(output_file)

```

---

[首 页](https://patrickj-fd.github.io)
