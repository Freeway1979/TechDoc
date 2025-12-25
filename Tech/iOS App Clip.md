# iOS App Clip

#### AASA
https://app-site-association.cdn-apple.com/a/v1/mesh.firewalla.net


## Only Https Link to invoke
## How long can it live?

- 10 days (standard)
- 30 days (Apple Log in)

## Can it request network?
Yes. As long as it is in foreground.

## Share data with full App

1. The Core Solution: App Groups
2. Method A: Shared UserDefaults (Best for Simple Data)
3. Method B: Shared Container (Best for Files/Databases)
```swift
let sharedURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.yourcompany.yourapp")
```
4. Method C: Keychain Sharing (Best for Security)