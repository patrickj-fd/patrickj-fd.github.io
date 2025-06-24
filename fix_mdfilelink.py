"""
指定目录和index文件
得到该目录下除index外的所有文件（包括子目录）
检查这些文件是否都在index文件中配置了访问链接
"""

import argparse
import glob
import os

from feedwork.utils import logger
import feedwork.utils.FileHelper as fileu


def file_list_indir(root_dir, index_mdfile):
    # root_dir目录下必须存在被检查的索引文件
    if not os.path.isfile(os.path.join(root_dir, index_mdfile)):
        logger.error(f"{index_mdfile} is not real file")
        return None

    file_list = []
    for cur_root_dir, sub_dirs, filenames in os.walk(root_dir):
#    for file in glob.glob(f"{root_dir}/*"):
        for filename in filenames:
            if filename == index_mdfile:
                continue
            cur_file = os.path.join(cur_root_dir, filename)  # 每个文件名，都是 root_dir 开头的

            file_list.append(os.path.join(cur_root_dir, filename))
            logger.info(f"file={filename}")
    return file_list


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--dir', type=str, help="从该目录开始检查其索引文件的完整性")
    parser.add_argument('--idxfile', type=str, help="被检查的索引文件名")
    args = parser.parse_args()
    root_dir = args.dir
    index_mdfile = args.idxfile
    logger.debug(f"root_dir={root_dir}, index_mdfile={index_mdfile}")

    logger.debug(file_list_indir(root_dir, index_mdfile))
