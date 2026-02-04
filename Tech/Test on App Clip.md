# Test on App Clip

以通知栏提示的往往是网络问题（Check AASA失败)导致退而求其次（也是Apple的官方策略）。所以有时候我Tap NFC会以通知栏提示，稳定情况都是Card。

### Test App Clip: Local Experience
- App Clip Must exist, otherwise, the `Open` in the Card is disabled.
Local exprience only for App Clip.

### Test App Clip's URL(Run from Xcode)
- Edit Scheme, `Run`, add Environment Variables:

```_XCAppClipURL https://mesh.firewalla.com/nfc?gid=915565a3-65c7-4a2b-8629-194d80ed824b&rule=249```

### Main App

- continueUserActivity (From Clip Card URL)
- openURL (From Notification URL)

### TestFlight

https://mesh.firewalla.net/.well-known/apple-app-site-association

- Check AASA, Association Domains.
- 当前所在国家或地区不存在此轻App

### App Store
- No App Clip, invoked by NFC Tag or QR code, popup a Card to `Open` full app.