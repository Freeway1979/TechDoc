# App Clip 配置检查清单

## 当前配置状态

### ✅ 已配置项

1. **Bundle Identifier**
   - App Clip: `andy.liu.NFCTagWriter.Clip`
   - Parent App: `andy.liu.NFCTagWriter`
   - ✅ 配置正确

2. **Associated Domains**
   - `applinks:mesh.firewalla.net` ✅
   - `appclips:mesh.firewalla.net` ✅
   - 已在 `Rule_NFC_Clip.entitlements` 中配置

3. **Parent Application Identifier**
   - `$(AppIdentifierPrefix)andy.liu.NFCTagWriter` ✅
   - 已在 `Rule_NFC_Clip.entitlements` 中配置

4. **NFC Capabilities**
   - `com.apple.developer.nfc.readersession.formats: TAG` ✅
   - 已在 `Rule_NFC_Clip.entitlements` 中配置

5. **URL Handling**
   - ✅ `onOpenURL` 已添加到 `Rule_NFC_ClipApp.swift`
   - ✅ `onContinueUserActivity` 已添加
   - ✅ `AppRouter` 已集成

6. **App Clip Info.plist**
   - ✅ `NSAppClip` 配置存在
   - ✅ 已禁用临时通知和位置确认

### ⚠️ 需要检查的项

1. **共享文件到 App Clip Target**
   确保以下文件已添加到 App Clip target:
   - `AppRouter.swift` ✅ (需要确认)
   - `URLDetailsView.swift` ✅ (需要确认)
   - `ClipHelper.swift` ✅ (需要确认)
   - `URLDetails` struct (在 AppRouter.swift 中) ✅

2. **App Store Connect 配置**
   - [ ] 在 App Store Connect 中创建新的 App Clip
   - [ ] Bundle ID: `andy.liu.NFCTagWriter.Clip`
   - [ ] 配置 Advanced App Clip Experience (如需要)
   - [ ] 关联域名: `mesh.firewalla.net`
   - [ ] 上传 App Clip 构建版本

3. **网站配置 (apple-app-site-association)**
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
   ⚠️ 需要将 `TEAM_ID` 替换为实际的 Team ID

## 与旧 App Clip 的区别

### 旧 App Clip (已删除)
- Bundle ID: `com.firewalla.firewallb.Clip`
- 状态: 已在 App Store Connect 删除 Advanced Experience
- 问题: 诊断工具仍显示已注册（可能是缓存）

### 新 App Clip (当前)
- Bundle ID: `andy.liu.NFCTagWriter.Clip`
- 状态: 需要重新在 App Store Connect 配置
- 域名: `mesh.firewalla.net`

## 测试步骤

### 1. 本地测试
```bash
# 在 Xcode Scheme 中设置环境变量
_XCAppClipURL=https://mesh.firewalla.net/nfc?gid=test&rule=123&chksum=abc123
```

### 2. 设备测试
1. 构建并运行 App Clip target
2. 使用 NFC 标签或 QR 码测试 URL: `https://mesh.firewalla.net/nfc?gid=xxx&rule=xxx&chksum=xxx`
3. 验证 URL 解析和 checksum 验证功能

### 3. 诊断工具测试
1. 在设备上打开 "设置" > "开发者" > "App Clip Codes and Tags"
2. 输入 URL: `https://mesh.firewalla.net/nfc`
3. 检查是否显示新的 App Clip bundle ID

## 下一步操作

1. **确认文件共享**
   - 在 Xcode 中检查 `AppRouter.swift`、`URLDetailsView.swift`、`ClipHelper.swift` 是否在 App Clip target 中
   - 如果不在，需要添加到 target membership

2. **App Store Connect**
   - 登录 App Store Connect
   - 为 `andy.liu.NFCTagWriter` 应用创建 App Clip
   - 配置 Advanced Experience (如需要)
   - 上传构建版本

3. **等待同步**
   - App Store Connect 配置更改可能需要 24-48 小时同步
   - 诊断工具可能需要更长时间更新

4. **网站配置**
   - 确认 `apple-app-site-association` 文件正确配置
   - 测试 Universal Links 和 App Clip 触发

## 常见问题

### Q: 为什么诊断工具还显示旧的 App Clip?
A: 诊断工具可能读取本地缓存或设备上已安装的 App Clip。等待 24-48 小时后重试，或删除设备上的旧 App Clip。

### Q: App Clip 无法触发怎么办?
A: 检查:
1. Associated Domains 是否正确配置
2. `apple-app-site-association` 文件是否正确
3. URL 格式是否符合要求
4. App Clip 是否已发布到 App Store

### Q: 如何验证 checksum?
A: App Clip 会:
1. 从 URL 参数中读取 `chksum` (前10个字符)
2. 从 UserDefaults 中读取完整 checksum
3. 使用 `ClipHelper.verifyCheckSum()` 验证

## 相关文件

- `Rule NFC Clip/Rule_NFC_Clip.entitlements` - App Clip 权限配置
- `Rule NFC Clip/Rule_NFC_ClipApp.swift` - App Clip 入口
- `Rule NFC Clip/ContentView.swift` - App Clip UI
- `NFCTagWriter/AppRouter.swift` - URL 路由处理
- `NFCTagWriter/URLDetailsView.swift` - URL 详情显示
- `NFCTagWriter/NFCUtils/ClipHelper.swift` - Checksum 验证
