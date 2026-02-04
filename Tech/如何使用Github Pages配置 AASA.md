# 如何使用Github Pages配置 AASA apple-app-site-association

使用 GitHub Pages 托管 AASA 文件是一个非常聪明的做法，因为它完全免费，且符合 Apple 对 HTTPS 和无重定向的所有硬性要求。

以下是创建名为 `your-username.github.io` 的仓库并发布 AASA 文件的详细步骤：

---

### 第一步：创建 GitHub Pages 专用仓库

1. **登录 GitHub**，点击页面右上角的 **“+”** 号，选择 **New repository**。
2. **设置仓库名称**：这是最关键的一步。
* 仓库名必须严格遵循格式：`你的用户名.github.io`。
* 例如，如果你的 GitHub 用户名是 `firewalladev`，那么仓库名必须是 `firewalladev.github.io`。


3. **可见性**：必须勾选 **Public**（公开）。
4. **初始化**：勾选 **Add a README file**（这样可以立即完成创建，方便后续直接在网页端操作）。
5. 点击底部的 **Create repository**。

---

### 第二步：准备 AASA 文件结构

由于 AASA 文件必须存放在 `.well-known` 文件夹下，且不能带后缀，我们需要在仓库中构建以下结构：

1. 在仓库主页，点击 **Add file** -> **Create new file**。
2. 在文件名输入框中输入：`.well-known/apple-app-site-association`。
* *注意：当你输入 `/` 时，GitHub 会自动将 `.well-known` 识别为文件夹。*


3. **粘贴内容**：将你的 AASA JSON 内容粘贴到下方的文本框中。
4. 点击右上角的 **Commit changes...** 提交保存。

---

### 第三步：解决 Jekyll 屏蔽问题（核心步骤）

GitHub Pages 默认使用 Jekyll 引擎构建，而 Jekyll 会**自动忽略**以点 `.` 开头的文件夹（如 `.well-known`）。

1. 回到仓库根目录，点击 **Add file** -> **Create new file**。
2. 文件名输入：`.nojekyll`。
3. 内容：留空即可。
4. 点击 **Commit changes...**。
> 这个文件的作用是告诉 GitHub：“不要使用 Jekyll 引擎，直接原封不动地发布我所有的文件。”



---

### 第四步：启用 GitHub Pages 服务

1. 在仓库页面点击上方的 **Settings**（设置）。
2. 在左侧边栏找到 **Pages** 选项。
3. 在 **Build and deployment** 下，确保 **Source** 选择的是 `Deploy from a branch`。
4. **Branch** 选择 `main` (或 `master`)，目录选择 `/ (root)`，点击 **Save**。
5. 等待 1-2 分钟，页面上方会显示：“Your site is live at `https://your-username.github.io/`”。

---

### 第五步：验证与 Apple 关联

#### 1. 验证链接

在浏览器中直接访问：
`https://your-username.github.io/.well-known/apple-app-site-association`
如果浏览器直接显示了 JSON 内容，说明托管成功。

#### 2. 配置 Xcode

freeway1979.github.io

在 Xcode 的 **Associated Domains** 中，添加：
`appclips:your-username.github.io`
`applinks:your-username.github.io`

#### 3. 修改 App Store Connect

在 **Advanced App Clip Experience** 的 URL 处，填入：
`https://your-username.github.io`

---

### 常见坑点排查

* **文件名后缀**：确保文件名为 `apple-app-site-association`，**千万不能有** `.json` 或 `.txt`。
* **HTTPS 强制跳转**：GitHub Pages 默认开启 HTTPS，这是对的。请确保不要在自己的域名设置里搞复杂的 301 跳转。
* **缓存时间**：当你修改了 GitHub 上的文件，Apple 的服务器可能需要几个小时甚至更久才会抓取新版本。如果你想快点看到效果，可以使用手机“设置 -> 开发人员 -> 诊断”输入该 URL。
