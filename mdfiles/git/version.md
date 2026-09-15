
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

# 解决方案
- 绝对不要新建仓库
- 正确的组合：「Tag 打基线 + 分支做维护 + 仓库先别动」

## 为什么光打 Tag 不够

tag 是你「完整获取这个版本」的唯一可靠锚点。分支会移动，tag 不会。给实施团队的交付依据永远是 tag，不是分支。

但只有 tag 会卡住一个现实问题：版本投产后，现场一定会发现 bug。你不能在没有分支的 tag 上改代码——那就是在移动历史。所以你需要一条分支来承载这些 hotfix。

## 为什么光开分支不够

分支是可变指针。今天 release/1.0 指向 A，明天有人合了个 hotfix 就指向 B了。你跟实施方说「拉 release/1.0」，一个月后拉到的就不是你验证过的那份代码了。

所以：tag 负责"可复现地获取"，branch 负责"可持续地维护"。两个都要。

## 在主分支上重构
main/master：重构主战场。
直接在主线上重构，而不是开一条长生命周期的 refactor 分支——长期分支最怕的就是和主线漂移，最后合并变成一场灾难。重构本来就是接下来唯一的主线工作，没必要再分叉。

## 版本号的走向
- v1.0.0 — 当前投产基线
- v1.0.x — 投产后的补丁
- v2.0.0 — 架构重构完成后的版本（major 号跳一级，明确告诉所有人：内部契约变了，升级需要评估）

# 操作命令
```bash
# 1. 确认当前就在 master，且工作区干净（没有未提交的改动）
git status

# 2. 打基线 tag
git tag -a v1.0.0 -m "投产基线：核心功能完成并测试通过"

# 3. 从 tag 拉出维护分支
git branch release/1.0 v1.0.0

# 4. 推上去
# 因为 git push 不会自动带上 tag，而且分支和 tag 在 Git 里是两套不同的命名空间。所以要push两次
git push origin v1.0.0                   # 推的是 tag
git push -u origin release/1.0       # 推的是分支


# 5. 结果核验
git tag -n                 # 列出所有 tag 及说明
git show v1.0.0 --stat     # 确认这个 tag 指向的提交确实是你验证过的那份
git log --oneline -1 release/1.0   # 确认维护分支起点正确

git ls-remote --tags origin        # 远端确实有 tag
git ls-remote --heads origin       # 远端确实有 分支
```

确认无误后，剩下的就是去代码平台上给 v1.0.0 加 tag 保护、给 release/1.0 加分支保护（禁止 force push）。
这一步在网页端做，Git 命令行管不了。

## GitHub（Settings → Rulesets，比老的 Branch protection 更推荐）
- Tag 保护：Settings → Tags​ → New tag ruleset，target 填 v1.0.0（或 v1.* 覆盖后续补丁），勾选 Restrict deletions、Block force pushes
- 分支保护：Settings → Branches​ → Add branch ruleset，target 填 release/1.0，同样勾 Restrict deletions、Block force pushes，再按需加 Require a pull request

## Gitee / 腾讯工蜂 / 阿里云 Codeup / Gitea
一般在「仓库设置 → 分支保护 / 标签保护」里，找 禁止强制推送、禁止删除​ 这两个开关。

