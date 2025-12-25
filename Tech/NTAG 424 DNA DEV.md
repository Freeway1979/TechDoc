https://medium.com/@androidcrypto/demystify-the-secure-dynamic-message-with-ntag-424-dna-nfc-tags-android-java-part-1-b947c482913c

https://medium.com/@androidcrypto/a-comprehensive-overview-of-all-keys-for-the-ntag424-nfc-chip-9ef961b71437


# NTAG 424 DNA DEV

## Xcode Settings:

- Build Phases -> Build Binary with Libraries -> Add CryptoSwift (NfcDnaKit Dependency)
- Add iso7816 in `Info.plist`, NOT .entitlements
```json
<key>com.apple.developer.nfc.readersession.iso7816.select-identifiers</key>
	<array>
		<string>D2760000850101</string>
	</array>
```

### Basic 

- Secure Dynamic Message Feature (SDM)

“Secure Unique Number” (“SUN”)

- 5 application keys: key numbers 00h to 04h

AppMasterKey

### Set New KEY

### Write Data with KEY
- Do not lock the file reading.
- Read Access: Set to Free (0xE) 
> This allows the iPhone to "see" the URL in the background.
- SDM Enabled: You configure the file to use SDM with your keys.
> This makes the chip inject a secure, unique code (CMAC) into the URL every time it is tapped.

### Read Data with Key

Here is the configuration formatted as a Markdown table.

This specific configuration is often the solution for the issue you described earlier. If the **Read Access** is not set to **Free / Plain (0xE)**, the iPhone's background scanner cannot read the NDEF data without user interaction, causing the silent failure you are experiencing.

### NFC Tag Access Configuration

| Access Type | Setting | Value (Hex) | Notes |
| :--- | :--- | :--- | :--- |
| **Read Access** | Free / Plain | `0xE` | **CRITICAL for iOS Background.** Allows the system to read the URL without a password. |
| **Write Access** | Key Protected | e.g., `0x0` | Protects the tag data from being overwritten by others. |
| **R/W Access** | Key Protected | e.g., `0x3` | Usually used for internal management or admin updates. |
| **Change Access** | Key Protected | `0x0` | Prevents unauthorized changes to these configuration settings. |

---

## NTAG424 TAG Write/Read Flow


