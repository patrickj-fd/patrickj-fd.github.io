
# 要处理的状况
```
我有一个产品，主要功能开发完成，并测试通过，初步达标可投产使用了。

这个版本里面的代码处理非常复杂，是经过了上百轮的测试+打补丁达到了成熟态。

现在，基于积累下来的经验，有了一个比较成熟的重构方案，需要进行架构级的重构。

我希望当前的版本应该可以非常方便的被完整获取，随时可以基于这个版本去各地进行落地实施。
同时，我要开始投入整个重构工作。

我的问题是，我该如何进行版本管理？

是新建一个仓库，还是打一个分支，还是打一个tag？
```

# 一、解决方案
- 绝对不要新建仓库
- 正确的组合：「Tag 打基线 + 分支做维护 + 仓库先别动」

## 1.1 为什么要tag和branch一起做
### - 光打 Tag 不够

tag 是你「完整获取这个版本」的唯一可靠锚点。分支会移动，tag 不会。给实施团队的交付依据永远是 tag，不是分支。

但只有 tag 会卡住一个现实问题：版本投产后，现场一定会发现 bug。你不能在没有分支的 tag 上改代码——那就是在移动历史。所以你需要一条分支来承载这些 hotfix。

### - 为什么光开分支不够

分支是可变指针。今天 release/1.0 指向 A，明天有人合了个 hotfix 就指向 B了。你跟实施方说「拉 release/1.0」，一个月后拉到的就不是你验证过的那份代码了。

所以：tag 负责"可复现地获取"，branch 负责"可持续地维护"。两个都要。

## 1.2 在主分支上重构
main/master：重构主战场。
直接在主线上重构，而不是开一条长生命周期的 refactor 分支——长期分支最怕的就是和主线漂移，最后合并变成一场灾难。重构本来就是接下来唯一的主线工作，没必要再分叉。

## 1.3 版本号的走向
- v1.0.0 — 当前投产基线
- v1.0.x — 投产后的补丁
- v2.0.0 — 架构重构完成后的版本（major 号跳一级，明确告诉所有人：内部契约变了，升级需要评估）

# 二、操作命令
```bash
# 1. 找到要发版(打tag)的位置：commit id(hash)
# 如果是对当前最新的提交发版，就不需要执行本步骤了
#    但是，保险起见，应该执行`git status`，确认当前工作区是干净的（没有未提交的改动）
git log --oneline -5

# - tag名
export TAG_NAME="v1.0.0"; echo $TAG_NAME
# - 分支名：因为以后这个分支可能会修bug导致出现多个小版本，所以分支名字应该是一个概括性名字，比如： "release/1.0" , "v0911"。
export BRANCH_NAME="release/1.0"; echo $BRANCH_NAME

# 2. 打基线 tag。如果是对当前最新的一次提交打tag，后面的commitid就不需要了
git tag -a ${TAG_NAME:?NullTagName} -m "投产基线：核心功能完成并测试通过" [commit id]

# 3. 从 tag 拉出维护分支
git branch ${BRANCH_NAME:?NullBranchName} ${TAG_NAME:?NullTagName}
git branch

# 4. 推到远程仓库
# 因为 git push 不会自动带上 tag，而且分支和 tag 在 Git 里是两套不同的命名空间。所以要push两次
git push origin ${TAG_NAME:?NullTagName}              # 推: tag
git push -u origin ${BRANCH_NAME:?NullBranchName}     # 推: 分支


# 5. 结果核验
git tag -n                 # 列出所有 tag 及说明
git show ${TAG_NAME:?NullTagName} --stat     # 确认这个 tag 指向的提交确实是你验证过的那份
git log --oneline -1 ${BRANCH_NAME:?NullBranchName}   # 确认维护分支起点正确

git ls-remote --tags origin        # 远端确实有 tag
git ls-remote --heads origin       # 远端确实有 分支
```

确认无误后，剩下的就是去代码平台上给 v1.0.0 加 tag 保护、给 release/1.0 加分支保护（禁止 force push）。
这一步在网页端做，Git 命令行管不了。

### 2.2 GitHub（Settings → Rulesets，比老的 Branch protection 更推荐）
- Tag 保护：Settings → Tags​ → New tag ruleset，target 填 v1.0.0（或 v1.* 覆盖后续补丁），勾选 Restrict deletions、Block force pushes
- 分支保护：Settings → Branches​ → Add branch ruleset，target 填 release/1.0，同样勾 Restrict deletions、Block force pushes，再按需加 Require a pull request

### 2.3 Gitee / 腾讯工蜂 / 阿里云 Codeup / Gitea
一般在「仓库设置 → 分支保护 / 标签保护」里，找 禁止强制推送、禁止删除​ 这两个开关。


# 三、如何维护分支的版本
## 3.1 切换到维护分支
```bash
git switch 分支名
```
⚠️ 注意：不要在 master 上修 bug。所有针对 `分支` 基线的修复都只在这个分支上提交。

## 3.2 修复 bug 并提交
```bash
git add .
git commit -m ...
```

## 3.3 修复完成、测试通过后，打补丁版本 tag（版本号递增）
```bash
export TAG_NAME="v1.0.1"
git tag -a ${TAG_NAME} -m "补丁版本：修复XX问题，投产基线 v1.0.1"
git push origin ${TAG_NAME}       # 推送新 tag
git push origin 分支名             # 推送分支（带上的新提交）
```

> 📌 规律：每修一批 bug、每次投产，就打一个新 tag。
> 分支上会累积多个 tag：v1.0.0 → v1.0.1 → v1.0.2…