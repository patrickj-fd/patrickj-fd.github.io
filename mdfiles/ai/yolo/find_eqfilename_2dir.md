
```python
import os
import glob


imageDir1 = os.path.abspath('/tmp/eqf/d1')
imageDir2 = os.path.abspath('/tmp/eqf/d2')

# 两次遍历，比较文件名
for file1 in glob.glob(os.path.join(imageDir1, '*')):
    if not os.path.isfile(file1):
        continue
    file_fname1 = os.path.basename(file1)  # 文件全名，包括后缀
    file_sname1, file_ext1 = os.path.splitext(file_fname1)  # 得到文件名和后缀名
    for file2 in glob.glob(os.path.join(imageDir2, '*')):
        if not os.path.isfile(file2):
            continue
        # print(f"==== {file_fname1}, {file_fname2}")
        file_fname2 = os.path.basename(file2)
        file_sname2, file_ext2 = os.path.splitext(file_fname2)
        if file_sname1 == file_sname2:  # 文件名相同(不包括后缀)
            if file_ext1 == file_ext2:  # 后缀也相同
                print(f"find equal filename : {file_fname1}")
            else:
                print(f"find equal filename : {file_fname1}, but not equal extname : dir1({file_ext1}) | dir2({file_ext2})")
```