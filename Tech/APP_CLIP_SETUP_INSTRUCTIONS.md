# App Clip 设置说明

## ✅ 已完成的配置更新

### 1. App Clip 入口文件更新
- ✅ 更新了 `Rule_NFC_ClipApp.swift`，添加了 URL 处理功能
- ✅ 集成了 `AppRouter` 用于 URL 路由
- ✅ 添加了 `onOpenURL` 和 `onContinueUserActivity` 处理

### 2. App Clip UI 更新
- ✅ 更新了 `ContentView.swift`，添加了 URL 信息显示
- ✅ 集成了 `AppRouter` 环境对象
- ✅ 添加了 checksum 验证状态显示

### 3. 配置文件检查
- ✅ `Rule_NFC_Clip.entitlements` - Associated Domains 已配置
- ✅ `Info.plist` - App Clip 配置已存在

## ⚠️ 需要在 Xcode 中手动完成的步骤

### 步骤 1: 添加共享文件到 App Clip Target

在 Xcode 中，需要确保以下文件同时属于主 App 和 App Clip target:

1. **打开 Xcode 项目**
2. **选择以下文件，在右侧 File Inspector 中勾选 "Rule NFC Clip" target:**
   - `NFCTagWriter/AppRouter.swift`
   - `NFCTagWriter/URLDetailsView.swift`
   - `NFCTagWriter/NFCUtils/ClipHelper.swift`

**操作方法:**
1. 在 Project Navigator 中选择文件
2. 打开右侧 File Inspector (⌘⌥1)
3. 在 "Target Membership" 部分
4. 勾选 "Rule NFC Clip" ✅

### 步骤 2: 验证 Target Membership

检查以下文件是否在两个 target 中:
- ✅ `AppRouter.swift` → 主 App + App Clip
- ✅ `URLDetailsView.swift` → 主 App + App Clip  
- ✅ `ClipHelper.swift` → 主 App + App Clip

### 步骤 3: 构建测试

1. 选择 "Rule NFC Clip" scheme
2. 选择目标设备或模拟器
3. 构建并运行 (⌘R)
4. 检查是否有编译错误

如果出现 "Cannot find 'AppRouter' in scope" 等错误，说明文件未添加到 target。

## 📱 App Store Connect 配置

### 1. 创建 App Clip

1. 登录 [App Store Connect](https://appstoreconnect.apple.com)
2. 选择你的应用 `NFCTagWriter` (Bundle ID: `andy.liu.NFCTagWriter`)
3. 在左侧菜单选择 "App Clips"
4. 点击 "+" 创建新的 App Clip
5. 输入 Bundle ID: `andy.liu.NFCTagWriter.Clip`

### 2. 配置 Advanced Experience (可选)

如果需要支持 App Clip Code 和 NFC 标签:

1. 在 App Clip 页面，选择 "Advanced Experiences"
2. 点击 "Create Advanced Experience"
3. 配置:
   - **Invocation URL**: `https://mesh.firewalla.net/nfc`
   - **Image**: 上传 App Clip 图标 (1024x1024)
   - **Title**: "NFC Tag Writer"
   - **Subtitle**: (可选)

### 3. 上传构建版本

1. 在 Xcode 中，选择 "Any iOS Device" 或具体设备
2. Product → Archive
3. 上传到 App Store Connect
4. 在 App Store Connect 中，将构建版本分配给 App Clip

## 🌐 网站配置

### apple-app-site-association 文件

确保 `https://mesh.firewalla.net/.well-known/apple-app-site-association` 包含:

```json
{
  "appclips": {
    "apps": ["TEAM_ID.andy.liu.NFCTagWriter.Clip"]
  },
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "TEAM_ID.andy.liu.NFCTagWriter",
        "paths": ["/nfc*"]
      }
    ]
  }
}
```

**重要:**
- 将 `TEAM_ID` 替换为你的实际 Team ID (在 Apple Developer 账户中查看)
- 文件必须是纯文本，Content-Type: `application/json`
- 必须通过 HTTPS 访问
- 文件大小不超过 128KB

## 🧪 测试步骤

### 本地测试 (Xcode)

1. **设置测试 URL:**
   - 在 Xcode 中，选择 "Rule NFC Clip" scheme
   - Product → Scheme → Edit Scheme
   - 选择 "Run" → "Arguments"
   - 在 "Environment Variables" 中添加:
     - Name: `_XCAppClipURL`
     - Value: `https://mesh.firewalla.net/nfc?gid=test123&rule=456&chksum=abc1234567`

2. **运行测试:**
   - 构建并运行 App Clip (⌘R)
   - App Clip 应该自动打开并显示 URL 信息

### 设备测试 (NFC 标签)

1. **准备 NFC 标签:**
   - 使用 NFCTagWriter 应用写入 URL: `https://mesh.firewalla.net/nfc?gid=xxx&rule=xxx&chksum=xxx`
   - 确保 URL 格式正确

2. **测试触发:**
   - 将 iPhone 靠近 NFC 标签
   - App Clip 应该自动启动
   - 验证 URL 解析和 checksum 验证

### 诊断工具测试

1. **打开诊断工具:**
   - 设置 → 开发者 → App Clip Codes and Tags
   - 或使用 Xcode: Window → Devices and Simulators → 选择设备 → "App Clip Codes and Tags"

2. **输入 URL:**
   - URL: `https://mesh.firewalla.net/nfc`
   - 检查显示的 App Clip Bundle ID 是否为 `andy.liu.NFCTagWriter.Clip`

3. **验证状态:**
   - ✅ Register Advanced Experience: 应该显示新的 Bundle ID
   - ✅ App Clip Published on App Store: 上传构建版本后应该显示绿色
   - ✅ Associated Domains: 应该显示已配置
   - ✅ App Clip Code: 应该显示 URL 适合 App Clip Code

## 🔍 故障排除

### 问题 1: 编译错误 "Cannot find 'AppRouter' in scope"

**解决方案:**
- 检查 `AppRouter.swift` 是否在 "Rule NFC Clip" target 中
- 在 File Inspector 中勾选 target membership

### 问题 2: App Clip 无法触发

**检查清单:**
- [ ] Associated Domains 是否正确配置
- [ ] `apple-app-site-association` 文件是否正确
- [ ] URL 格式是否符合要求
- [ ] App Clip 是否已发布到 App Store
- [ ] 等待 24-48 小时让配置同步

### 问题 3: 诊断工具仍显示旧的 App Clip

**原因:**
- 诊断工具可能读取本地缓存
- 设备上可能安装了旧版本的 App Clip

**解决方案:**
- 等待 24-48 小时
- 删除设备上的旧 App Clip
- 重新测试

### 问题 4: Checksum 验证失败

**检查:**
- URL 参数 `chksum` 是否包含前 10 个字符
- UserDefaults 中是否保存了完整的 checksum
- `ClipHelper.readChecksum()` 是否能正确读取

## 📝 检查清单

在提交到 App Store 之前，确认:

- [ ] 所有共享文件已添加到 App Clip target
- [ ] App Clip 可以正常编译和运行
- [ ] URL 处理功能正常工作
- [ ] Checksum 验证功能正常
- [ ] App Store Connect 中已创建 App Clip
- [ ] 已上传 App Clip 构建版本
- [ ] `apple-app-site-association` 文件已配置
- [ ] 本地测试通过
- [ ] 设备测试通过 (如可能)

## 📚 相关文档

- [Apple App Clips Documentation](https://developer.apple.com/documentation/app_clips)
- [App Clip Advanced Experiences](https://developer.apple.com/documentation/app_clips/creating_an_advanced_app_clip_experience)
- [Associated Domains](https://developer.apple.com/documentation/xcode/supporting-universal-links-in-your-app)
