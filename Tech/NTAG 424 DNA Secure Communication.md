MTool on Android

UID Changeable NTAG N213 N215 N216

https://shop.mtoolstec.com/product/uid-changeable-ntag-n213-n215-n216

# NTAG 424 DNA Secure Communication

This architecture leverages the **NTAG 424 DNA's** advanced security features—specifically **Secure Dynamic Messaging (SDM)** and **AES-128 encryption**—to create a system where tags cannot be cloned, and data cannot be written without authorization.

### **1. High-Level System Architecture**

The system is composed of three distinct entities:

1.  **The Cloud (Trust Anchor):** Stores the "Master Keys" and validates the authenticity of every tap.
2.  **The iPhone (Interface):** Acts as both the **Provisioner** (configuring the tag using the Admin App) and the **Verifier** (reading the tag via background NFC).
3.  **The Tag (NTAG 424 DNA):** The secure element that generates a unique cryptographic code for every single tap.

-----

### **2. Component Breakdown & Responsibilities**

#### **A. The Cloud (Backend)**

  * **Key Management System (KMS):** You never store actual keys on the iPhone app. The cloud holds a **Master Key (MK)** and dynamically derives a unique key for each tag (e.g., `TagKey = AES_CMAC(MK, TagUID)`).
  * **Verification Service:** An API endpoint (e.g., `GET /verify`) that receives the scan data, recalculates the cryptographic signature (CMAC), and confirms if the tag is genuine.
  * **Database:** Stores the `LastReadCounter` for each tag to prevent "Replay Attacks" (copying a valid URL and reusing it).

#### **B. The iPhone (iOS Core NFC)**

  * **Role 1: The Provisioner (Admin App):** This proprietary app is used by your factory/staff. It connects to the Cloud to request temporary session keys or encrypted payloads to write to the tag. It uses **Core NFC** to send raw APDU commands (ISO 7816-4).
  * **Role 2: The Consumer (User Experience):** No app is required. The user taps the tag, and iOS reads the NDEF URL in the background, opening Safari to your verification page.

#### **C. The Tag (NTAG 424 DNA)**

  * **File 1 (CC):** Capability Container (Standard NFC setup).
  * **File 2 (NDEF):** Stores the dynamic URL.
  * **Keys 0-4:** 5 separate AES-128 keys. usually:
      * *Key 0:* Application Master Key (for formatting/key changing).
      * *Key 1:* Read Access (optional).
      * *Key 2:* SDM / Meta Read Key (encrypts the data).
      * *Key 3:* File Access / Write Key.

-----

### **3. Workflow 1: Secure Write (Provisioning Phase)**

This is the process of initializing a blank tag so it becomes a secure, un-cloneable asset. This must be done via an iOS App with **Core NFC** entitlements.

**The Protocol:**

1.  **Key Derivation:**
      * The iPhone reads the Tag's UID.
      * iPhone sends UID to Cloud.
      * Cloud calculates the specific AES Keys for this tag (to avoid using the same key for all tags) and sends them securely to the iPhone App (or the App calculates them if obfuscated).
2.  **Authentication (AES-128):**
      * iPhone sends `AuthenticateEV2First` command to the tag using the Default Key (usually `00...00`).
      * Tag responds with a challenge.
      * iPhone responds with an encrypted challenge.
      * **Result:** An encrypted session is established. All subsequent data written to the tag is encrypted over the air.
3.  **Configuration (Write):**
      * **Change Keys:** The iPhone updates the tag's keys from Default to your secure Derived Keys.
      * **Set File Settings:** The iPhone configures the NDEF file (File 02) to enable **SDM (Secure Dynamic Messaging)**. It sets the "SDM Read Access Rights" to require Key 2.
      * **Write NDEF URL:** The iPhone writes the template URL with placeholders:
        `https://auth.yoursite.com/v?uid=000000&ctr=000000&cmac=00000000`
      * **Configure Offsets:** You tell the tag *exactly* which byte in that URL corresponds to the `uid`, `ctr` (counter), and `cmac`.

-----

### **4. Workflow 2: Secure Read (Authentication Phase)**

This is the consumer experience. No special app is needed; just a standard iPhone XS or newer.

**The Flow:**

1.  **User Tap:** The user taps the tag.
2.  **Tag Generation (On-Chip):**
      * The NTAG 424 DNA wakes up.
      * It increments its internal **NFC Counter** by 1.
      * It generates a **CMAC (Signature)** using *Key 2* based on the UID and the new Counter value.
      * It dynamically replaces the placeholders in the URL with the real ASCII values.
3.  **Data Transmission:**
      * The iPhone sees a standard URL:
        `https://auth.yoursite.com/v?uid=04A1B2C3D4E5F6&ctr=000015&cmac=A1B2C3D4E5F6A7B8`
      * Safari opens this link.
4.  **Cloud Verification:**
      * Your server receives the request.
      * **Step A (Key Lookup):** It takes the `uid` from the URL, derives/retrieves the specific AES Key 2 for that tag.
      * **Step B (Re-calculation):** The server calculates the CMAC locally: `CMAC(Key 2, uid + ctr)`.
      * **Step C (Comparison):**
          * If `Server_CMAC == URL_CMAC`: **Pass**.
          * If `ctr <= Last_Known_Ctr`: **Fail** (Replay Attack / Cloned URL).
      * **Step D (Response):** Server returns a "Success/Verified" HTML page to the user.

-----

### **5. Technical Implementation Details**

#### **iOS Core NFC (Swift)**

To write to the tag, you cannot use `NFCNDEFReaderSession`. You must use `NFCTagReaderSession` with `iso7816` polling.

```swift
// Swift Pseudo-code for connecting
func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
    guard case let .iso7816(tag) = tags.first else { return }
    
    session.connect(to: tag) { (error) in
        // 1. Send "Select Application" APDU (0x5A)
        // 2. Send "AuthenticateEV2First" APDU (0x71) with AES Key
        // 3. Send "WriteData" APDU (0x8D) with Encrypted Payload
    }
}
```

#### **Cloud Backend (Node.js Example)**

You need an AES-CMAC library (like `node-aes-cmac`).

```javascript
// Node.js Logic
const verifyTag = (uid, counter, receivedCmac) => {
    const key = deriveKey(masterKey, uid); // 1. Get Key
    
    // 2. Build the message the tag would have signed
    // (Tag specific format: often 7 byte UID + 3 byte Counter)
    const dataToSign = Buffer.concat([uidBuffer, counterBuffer]);
    
    // 3. Calculate expected CMAC
    const expectedCmac = aesCmac(key, dataToSign);
    
    // 4. Verify
    if (receivedCmac === expectedCmac) {
       // Check for replay attacks
       if (counter > db.getLastCounter(uid)) {
           db.updateCounter(uid, counter);
           return "AUTHENTIC";
       } else {
           return "REPLAY_DETECTED";
       }
    }
    return "FAKE";
}
```

### **Summary of Security Features**

| Feature | Function | Protects Against |
| :--- | :--- | :--- |
| **AES-128 Auth** | Requires a key to write data. | Unauthorized rewriting/defacing. |
| **SUN (CMAC)** | Signs the data with a secret key. | URL Spoofing / cloning the tag content. |
| **NFC Counter** | Increments on every read. | Replay attacks (copying a valid URL). |
| **Key Diversification** | Unique key per UID. | System-wide compromise (if one tag is hacked). |