要将 Fork 项目与原始仓库（ upstream ）的新分支同步，需要通过 Git 命令手动操作，步骤如下：


### **前提：已配置 upstream 远程仓库**
首先确认本地仓库已关联原始仓库（若未配置，先执行以下命令）：
```bash
# 查看当前远程仓库（确认是否有 upstream）
git remote -v

# 若没有，添加原始仓库为 upstream（替换为原始仓库地址）
git remote add upstream https://github.com/original-owner/original-repo.git
```


### **同步原始仓库的新分支到本地**
假设原始仓库新增了一个分支 `new-feature`，需同步到你的 Fork 仓库：

#### 1. **拉取原始仓库的最新分支信息**
```bash
# 从 upstream 拉取所有分支和标签（更新本地对 upstream 的认知）
git fetch upstream
```
执行后，本地会获取原始仓库所有分支（包括新分支 `new-feature`）的信息。


#### 2. **在本地创建并切换到与 upstream 新分支对应的分支**
```bash
# 基于 upstream 的 new-feature 分支，在本地创建同名分支并切换
git checkout -b new-feature upstream/new-feature
```
- 此时本地 `new-feature` 分支与原始仓库的 `new-feature` 分支内容完全一致。


#### 3. **（可选）将本地新分支推送到你的 Fork 仓库**
若需要将同步后的分支保存到你的 Fork 仓库（方便后续基于此分支提交 PR）：
```bash
# 推送本地 new-feature 分支到你的 Fork 仓库（origin 是你的 Fork 远程仓库）
git push origin new-feature
```
- 执行后，你的 Fork 仓库会新增 `new-feature` 分支，且与原始仓库的该分支保持同步。


### **后续：保持分支与 upstream 同步**
若后续原始仓库的 `new-feature` 分支有更新，可再次同步：
```bash
# 切换到本地 new-feature 分支
git checkout new-feature

# 从 upstream 拉取最新更新并合并到本地分支
git pull upstream new-feature

# （可选）推送到你的 Fork 仓库
git push origin new-feature
```


### **总结步骤**
1. `git fetch upstream` → 获取原始仓库所有分支（包括新分支）
2. `git checkout -b 新分支名 upstream/新分支名` → 本地创建并关联原始仓库新分支
3. `git push origin 新分支名` → （可选）推送到你的 Fork 仓库

通过以上操作，即可将原始仓库的新分支同步到你的 Fork 仓库，并保持后续更新。