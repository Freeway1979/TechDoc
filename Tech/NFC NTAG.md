# Firewalla NFC NTAG 
## NTAG 424

- Password can not be clone/cracked

使用的是 AES-128 互斥认证 (Mutual Authentication)。
机制： 你的手机（App）和芯片之间会进行加密对话。密码（密钥）本身从来不会在空中传输。
优势： 即使黑客用 Proxmark3 在旁边全程录制你们的通信，他也拿不到密钥，无法解密。
- 

## NTAG 215
至少使用NTAG 215，有密码尝试次数限制计数器

被破解密码:
- Proxmark3 Sniffing
- Default password (MTools)


## 破解工具

- Android: NFC Tools / NFC Tools Pro:
- PC 端 + USB 读卡器（进阶，适合批量操作）ACR122U
    硬件：ACR122U
    这是最经典的 NFC/RFID 读写器，兼容性极好。
软件：
    NFC Tools for Desktop: 界面友好，适合普通数据。
    Mifare/NTAG 命令行工具 (libnfc): 适合开发者，可以对内存页（Pages）进行逐个转储（Dump）
- 专业/极客硬件（黑客级，适合研究和破解）密码加密的NTAG 215
  Proxmark3 (PM3): Sniffing
  Flipper Zero: 暴力破解
 > Magic NTAG 215 (UID Changeable): 这种特殊的卡允许修改 UID。如果你需要做一张和原卡一模一样的克隆卡（Clone），你需要购买这种特制卡片，并配合 Proxmark3 或 ACR122U 写入。