[首 页](https://patrickj-fd.github.io/index) | [ai](https://patrickj-fd.github.io/mdfiles/ai/index) | [docker](https://patrickj-fd.github.io/mdfiles/docker/index) | [git](https://patrickj-fd.github.io/mdfiles/git/index) | [net](https://patrickj-fd.github.io/mdfiles/net/index) | [os](https://patrickj-fd.github.io/mdfiles/os/index) | [python](https://patrickj-fd.github.io/mdfiles/python/index)

---

# 编译运行
```shell
#!/bin/bash

set -e

function usage() {
  echo "修改：PRJ_ROOT，LIBS，CLASSES_DIR，MainClass"
  echo "-b    编译"
  echo "-r    运行"
}

# 脚本所在目录
BINDIR="$(cd "$(dirname "$0")" && pwd)"

RUN_TYPE="$1"

export JAVA_HOME=/usr/java/jdk8
export PATH=$JAVA_HOME/bin:$PATH
java -version

PRJ_ROOT="$BINDIR"

LIBS="$(find $PRJ_ROOT/*/build/libs ! -type d -name "*.jar" | sed 's@^@@g' | paste -s -d ":")"
LIBS=$LIBS:"$(find /data3/java/libs ! -type d -name "*.jar" | sed 's@^@@g' | paste -s -d ":")"
echo LIBS=$LIBS

CLASSES_DIR=/tmp/classes/fdcore

# 编译
if [[ "$RUN_TYPE" =~ ^-.* && "$RUN_TYPE" =~ "b" ]]; then
  # 编译工程下所有文件
  # $(find $PRJ_ROOT ! -path "$SRC_ROOT/chat/server/*" -name "*.java" ! -name "*Test.java")
  # JUnit测试程序必须以Test结尾，以便这里能够过滤掉，否则编译时还得把JUnit的jar搞进来
#  javac -Xlint:unchecked -cp $LIBS -d $CLASSES_DIR \
#      $(find $PRJ_ROOT -name "*.java" ! -name "*Test.java")

  # 编译指定文件
  javac -cp $LIBS -d $CLASSES_DIR $PRJ_ROOT/database/src/test/java/fd/ng/db/jdbc/HugeDataBatchTest.java
  if [ $? -eq 0 ]; then
    echo; echo "Compile done."; echo;
  fi
fi

# 运行
MainClass=fd.ng.db.jdbc.HugeDataBatchTest
if [[ "$RUN_TYPE" =~ ^-.* && "$RUN_TYPE" =~ "r" || -z "$RUN_TYPE" ]]; then
  export CLASSPATH=$CLASSES_DIR:$LIBS
  java -Xms32m -Xmx256m $MainClass "$2" "$3" "$4" "$5" "$6" "$7"
fi
```

---

[首 页](https://patrickj-fd.github.io/index)
