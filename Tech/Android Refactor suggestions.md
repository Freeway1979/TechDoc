## Android Refactor Suggestions

### Structural Code and files
>  Add Common Layer to hold general classes such as 
`Networker` `CacheHelper` to make it more relaxable and independent.

Example:
`Common`
    Extensions
    Network
    Cache
    Utils
`Features`
    Constants
    FWAPI
    Views
    Models
    Activities
    ViewModels
    Utils

> Refactor `Constants` with more namespaces to isolate codes

### Effective UI design and MVVM. Less bugs, Better performance.
> Support Jetpack step by step to get more benefits.
    Stage 1. Support `LiveData` and `ViewModel` 
    Stage 2. Support Compose UI (Like `SwiftUI` `React`)
    
### Logging
> Use inline `logDebug` to simplify code
> Save Debug logs to local files for later analytics(from end-user to developer)

### TODOs
> Reduce hardcode and add more `TODO` when not stable

### I18n Support
> Some strings miss `I18n` support
>
### Performance

[BUG: SGoldProX takes around 10 seconds to loadup](https://github.com/firewalla/firecommit/issues/4889)

Key issue: `JSON parsing.`

> Replace built-in `JSONObject` lib with modern one（[kotlinx.serialization](https://github.com/Kotlin/kotlinx.serialization)） to optimize performance. In Home Page, it 's very slow to load UI because of JSON parsing.
Comparing to iOS, there are performance issue in JSON parsing and networking related(JSON parsing)

https://github.com/Kotlin/kotlinx.serialization/blob/master/docs/serialization-guide.md