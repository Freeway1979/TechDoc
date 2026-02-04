在 Kotlin 中，`reified` 关键字用于泛型函数，允许在函数内部访问泛型类型的具体信息（如类型名称、类对象等），突破了 Java 泛型的"类型擦除"限制。它只能与 `inline` 函数配合使用，因为需要在编译期将函数代码内联到调用处，从而保留泛型类型信息。


### **核心用法与场景**

#### 1. **获取泛型类型的 Class 对象**
无需手动传递 `Class` 参数，直接在函数中通过 `T::class` 获取泛型类型的类对象。

```kotlin
// 普通泛型函数（无法直接获取 T 的类型信息）
fun <T> genericFun() {
    // 编译错误：Cannot use 'T' as reified type parameter
    // println(T::class.simpleName)
}

// 使用 reified + inline 的泛型函数
inline fun <reified T> reifiedFun() {
    println("泛型类型名称：${T::class.simpleName}")
    println("泛型类型对象：${T::class.java}")
}

// 调用
fun main() {
    reifiedFun<String>()  // 输出：泛型类型名称：String；泛型类型对象：class java.lang.String
    reifiedFun<Int>()     // 输出：泛型类型名称：Int；泛型类型对象：int
}
```


#### 2. **类型判断与转换**
直接使用 `is T` 或 `as T` 进行类型检查和转换（无需像 Java 那样用 `Class.isInstance`）。

```kotlin
inline fun <reified T> checkType(value: Any): Boolean {
    return value is T  // 直接判断是否为 T 类型
}

inline fun <reified T> safeCast(value: Any): T? {
    return value as? T  // 安全转换为 T 类型
}

// 调用
fun main() {
    println(checkType<String>("hello"))  // true
    println(checkType<Int>("hello"))     // false
    
    val str: String? = safeCast("test")
    val num: Int? = safeCast(123)
}
```


#### 3. **简化反射操作**
结合 Kotlin 反射 API，简化泛型类型的反射调用（如创建实例、调用方法等）。

```kotlin
inline fun <reified T> createInstance(): T? {
    return try {
        // 调用无参构造函数创建实例
        T::class.java.getDeclaredConstructor().newInstance()
    } catch (e: Exception) {
        null
    }
}

// 测试类
class User(val name: String = "默认名称")

// 调用
fun main() {
    val user = createInstance<User>()
    println(user?.name)  // 输出：默认名称
}
```


#### 4. **在集合中过滤特定类型元素**
快速从集合中筛选出指定类型的元素（比 `filterIsInstance` 更简洁）。

```kotlin
inline fun <reified T> List<*>.filterType(): List<T> {
    return this.filterIsInstance<T>()
}

// 调用
fun main() {
    val mixedList = listOf("a", 1, 2L, "b", 3.14)
    val strings = mixedList.filterType<String>()  // 结果：["a", "b"]
    val numbers = mixedList.filterType<Number>()  // 结果：[1, 2L, 3.14]
}
```


### **注意事项**

1. **必须与 `inline` 配合**  
   `reified` 只能用于 `inline` 函数，因为非内联函数会在运行时擦除泛型类型信息，无法保留 `T` 的具体类型。

   ```kotlin
   // 错误：reified 只能用于 inline 函数
   // fun <reified T> invalidFun() {}
   ```


2. **不能用于类或接口的泛型参数**  
   `reified` 仅适用于函数的泛型参数，不能修饰类、接口或属性的泛型。

   ```kotlin
   // 错误：类的泛型参数不能用 reified
   // class ReifiedClass<reified T>
   ```


3. **Java 调用限制**  
   带有 `reified` 泛型的内联函数无法被 Java 代码调用，因为 Java 不支持 Kotlin 的内联泛型语法。


4. **性能影响**  
   虽然 `inline` 会增加字节码体积，但 `reified` 避免了手动传递 `Class` 参数的麻烦，同时减少了反射调用的开销（编译期已确定类型）。


### **典型应用场景**

- **简化工具类**：如日志工具、JSON 解析器（如 `Gson.fromJson<T>()`）。
- **依赖注入**：通过类型自动获取对应实例。
- **数据转换**：在不同类型之间安全转换，减少类型转换代码。

例如，一个简化的 JSON 解析工具：

```kotlin
inline fun <reified T> parseJson(json: String): T? {
    return try {
        // 假设使用 Gson 解析
        com.google.gson.Gson().fromJson(json, T::class.java)
    } catch (e: Exception) {
        null
    }
}

// 调用
data class User(val name: String, val age: Int)
fun main() {
    val json = """{"name":"Alice", "age":20}"""
    val user = parseJson<User>(json)
    println(user?.name)  // Alice
}
```


通过 `reified`，Kotlin 泛型的灵活性大幅提升，尤其在需要类型信息的场景中，能显著简化代码并提高可读性。