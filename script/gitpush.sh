set -e

PushFiles=${1}
if [ "x$PushFiles" == "x" ]; then
    git status
    echo
    echo "======================================="
    echo "需要指定要提交的文件。 '.'：提交全部"; 
    echo
    exit 1
fi

CommitMsg=${2:-"update"}

git add "${PushFiles}"
git commit -m "${CommitMsg}"
git push

echo
echo "======================================="
echo "提交完成，本地仓库现在的状况："
echo
git status
