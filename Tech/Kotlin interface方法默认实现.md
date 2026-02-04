在 Kotlin 中，**接口（interface）的方法可以有默认实现**，这是 Kotlin 相比 Java （Java 8 之前）的一个重要特性，极大增强了接口的灵活性。


### **核心特点**
1. **使用 `default` 关键字（可选）**  
   在 Kotlin 中，接口方法的默认实现无需像 Java 8 及以上那样强制使用 `default` 关键字，直接在接口中编写方法体即可。不过，为了明确区分抽象方法和默认实现方法，通常建议显式添加 `default` （非强制，但更规范）。

2. **不影响接口的抽象性**  
   接口依然可以包含抽象方法（无实现），同时混合默认实现方法。类实现接口时，**只需实现抽象方法**，默认实现方法可以直接继承使用，也可以重写。


### **示例代码**

#### 1. 接口中定义默认实现方法
```kotlin
interface Logger {
    // 抽象方法（无实现，必须被实现类重写）
    fun logError(message: String)

    // 默认实现方法（有方法体，实现类可直接使用或重写）
    default fun logInfo(message: String) {
        println("[INFO] $message")
    }

    // 另一个默认实现方法（省略 default 关键字也可，但不推荐）
    fun logDebug(message: String) {
        println("[DEBUG] $message")
    }
}
```


#### 2. 实现类的使用方式
```kotlin
// 实现 Logger 接口
class ConsoleLogger : Logger {
    // 必须实现抽象方法 logError
    override fun logError(message: String) {
        println("[ERROR] $message")
    }

    // 可选：重写默认实现方法（如不需要可省略）
    override fun logInfo(message: String) {
        // 自定义实现
        println("[CONSOLE_INFO] $message")
    }
}

fun main() {
    val logger = ConsoleLogger()
    logger.logError("文件读取失败")  // 输出：[ERROR] 文件读取失败
    logger.logInfo("程序启动成功")   // 输出：[CONSOLE_INFO] 程序启动成功（使用重写的实现）
    logger.logDebug("调试信息")      // 输出：[DEBUG] 调试信息（使用接口的默认实现）
}
```


#### 3. 接口继承与默认方法冲突
当一个类实现多个接口，且接口中存在**同名同参数的默认方法**时，实现类必须显式重写该方法以解决冲突：

```kotlin
interface A {
    default fun foo() {
        println("A 的 foo")
    }
}

interface B {
    default fun foo() {
        println("B 的 foo")
    }
}

// 实现 A 和 B，必须重写 foo() 解决冲突
class C : A, B {
    override fun foo() {
        // 可选：调用其中一个接口的默认实现
        A.super.foo()  // 输出：A 的 foo
        B.super.foo()  // 输出：B 的 foo
        // 或自定义实现
        println("C 的 foo")
    }
}
```


### **优势**
- **向后兼容**：当接口需要新增方法时，可提供默认实现，避免所有实现类被迫修改。
- **代码复用**：接口的默认方法可以被多个实现类共享，减少重复代码。
- **功能扩展**：实现类可根据需求重写默认方法，灵活定制行为。


### **注意事项**
- 接口的默认方法**不能访问接口的属性**（接口属性默认是抽象的，需实现类提供具体值）。
- 与抽象类不同，接口**不能有状态**（即不能有带初始值的属性，除非是常量 `val`），默认方法仅能基于参数或无状态逻辑实现。

综上，Kotlin 接口支持默认实现方法，这一特性让接口在设计上更加灵活，兼具抽象规范和代码复用的能力。