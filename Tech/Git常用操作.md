# Git常用操作

## 如何从一个Fork项目同步新的Branch

#### 查看远程URL
```bash
git remote -v
```
```bash
origin	git@github.com:Freeway1979/firewalla.android.git (fetch)
origin	git@github.com:Freeway1979/firewalla.android.git (push)
upstream	git@github.com:firewalla/firewalla.android.git (fetch)
upstream	git@github.com:firewalla/firewalla.android.git (push)
```

#### 如果没有，则配置上游仓库:
`bash
git remote add upstream git@github.com:firewalla/firewalla.android.git
`

#### 获取上游所有更新：
```bash
git fetch upstream
```
#### 切换并创建新分支
```
git checkout -b new-feature upstream/new-feature
```
### 推送到你的 GitHub Fork
```
git push origin new-feature
```