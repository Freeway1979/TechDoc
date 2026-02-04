在 Android 开发中，统计单元测试覆盖率（Unit Test Coverage）最主流、最标准的方法是使用 **JaCoCo (Java Code Coverage)** 插件。

针对不同的项目配置（Groovy 或 Kotlin DSL），实现步骤略 contractor 有差异，但核心逻辑一致。以下是完整的配置指南：

---

## 1. 在 `build.gradle` 中配置 JaCoCo

首先，你需要在 App 模块的 `build.gradle` (或 `build.gradle.kts`) 文件中启用覆盖率统计。

### 开启覆盖率支持

在 `android` 闭包下的 `buildTypes` 中，为 `debug` 版本开启 `enableUnitTestCoverage`。

```kotlin
// build.gradle.kts (Kotlin DSL)
android {
    buildTypes {
        getByName("debug") {
            // 开启单元测试覆盖率
            enableUnitTestCoverage = true
            // 如果需要统计 AndroidTest (设备测试)，则开启：
            // enableAndroidTestCoverage = true
        }
    }
}

```

---

## 2. 创建 JaCoCo 报表任务

虽然 Android 插件内置了基础支持，但为了生成漂亮的可视化 HTML 报告并排除掉生成的代码（如 R 类、Dagger 生成的代码等），通常需要自定义一个 Task。

在 `app/build.gradle.kts` 末尾添加以下配置：

```kotlin
tasks.withType<Test> {
    configure<JacocoTaskExtension> {
        isIncludeNoLocationClasses = true
        excludes = listOf("jdk.internal.*")
    }
}

val fileFilter = listOf(
    "**/R.class", "**/R$*.class", "**/BuildConfig.*", "**/Manifest*.*",
    "**/*Test*.*", "android/**/*.*", "**/*$ViewInjector*.*",
    "**/*$Lambda$*.*", "**/*Directions*.*", "**/*$Dagger*.*"
)

tasks.register<JacocoReport>("jacocoTestReport") {
    dependsOn("testDebugUnitTest") // 确保在生成报告前先运行单元测试

    group = "Reporting"
    description = "Generate Jacoco coverage reports."

    reports {
        xml.required.set(true)
        html.required.set(true)
    }

    val debugTree = fileTree("${project.layout.buildDirectory.get()}/tmp/kotlin-classes/debug") {
        exclude(fileFilter)
    }
    val mainSrc = "${project.projectDir}/src/main/java"

    sourceDirectories.setFrom(files(mainSrc))
    classDirectories.setFrom(files(debugTree))
    executionData.setFrom(fileTree(project.layout.buildDirectory.get()) {
        include("outputs/unit_test_code_coverage/debugUnitTest/testDebugUnitTest.exec")
    })
}

```

---

## 3. 运行并查看报告

配置完成后，你可以通过终端运行命令来生成报告：

1. **执行命令：**
```bash
./gradlew jacocoTestReport

```


2. **查看结果：**
命令完成后，报告会生成在以下路径：
`app/build/reports/jacoco/jacocoTestReport/html/index.html`
直接用浏览器打开该 `index.html` 即可看到详细的代码覆盖率图表。

---

## 4. 进阶技巧：使用 Android Studio 插件

如果你不想配置繁琐的 Gradle 脚本，只想快速看一眼结果，可以使用 Android Studio 自带的功能：

1. 在你的测试文件夹上点击 **右键**。
2. 选择 **"Run 'Tests in...' with Coverage"**。
3. IDE 右侧会弹出 **Coverage** 窗口，列出每个包和类的覆盖百分比。同时，在编辑器左侧的代码行号处，绿色表示已覆盖，红色表示未覆盖。

---

## 总结建议

* **本地快速查看：** 使用 Android Studio 自带的 "Run with Coverage"。
* **持续集成 (CI/CD)：** 必须使用 **JaCoCo** 脚本，因为它生成的 XML 报告可以被 Jenkins、SonarQube 或 GitHub Actions 识别并展示趋势图。

**你想了解如何将这些数据集成到特定的 CI 工具（如 GitHub Actions 或 GitLab CI）中吗？**


将单元测试覆盖率集成到 GitHub Actions 中，不仅能自动化测试流程，还能在每次 Pull Request (PR) 时自动评论覆盖率结果，防止代码质量下降。

通常分为三个步骤：**运行测试**、**上传报告**、以及**在 PR 中展示结果**。

---

## 1. 准备工作

确保你的 `app/build.gradle.kts` 中已经配置了上一步提到的 `jacocoTestReport` 任务，并且生成的 XML 报告路径正确。

## 2. 编写 GitHub Actions Workflow

在项目根目录创建 `.github/workflows/android_ci.yml`，参考以下配置：

```yaml
name: Android CI Coverage

on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Code
        uses: actions/checkout@v4

      - name: Set up JDK 17
        uses: actions/setup-java@v4
        with:
          java-version: '17'
          distribution: 'temurin'
          cache: 'gradle'

      - name: Grant execute permission for gradlew
        run: chmod +x gradlew

      # 1. 运行单元测试并生成 JaCoCo 报表
      - name: Run Unit Tests with Coverage
        run: ./gradlew jacocoTestReport

      # 2. 将 HTML 报告上传为 Artifact（可选，方便下载查看详情）
      - name: Upload Coverage Report
        uses: actions/upload-artifact@v4
        with:
          name: jacoco-report
          path: app/build/reports/jacoco/jacocoTestReport/html/

      # 3. 在 PR 中自动发布覆盖率评论
      - name: Add Coverage PR Comment
        uses: madrapps/jacoco-report@v1.6.1
        if: github.event_name == 'pull_request' # 仅在 PR 时运行
        with:
          paths: ${{ github.workspace }}/app/build/reports/jacoco/jacocoTestReport/jacocoTestReport.xml
          token: ${{ secrets.GITHUB_TOKEN }}
          min-coverage-overall: 40    # 整体覆盖率阈值
          min-coverage-changed-files: 60 # 变动文件覆盖率阈值

```

---

## 3. 关键 Action 说明

在上面的配置中，我推荐使用 **`madrapps/jacoco-report`**，它是目前 GitHub 社区比较流行且好用的工具。

### 它能实现的功能：

* **PR 自动评论：** 每次提交代码，机器人会自动在 PR 下方留言，列出本次修改涉及的类及其覆盖率变化。
* **状态检查 (Status Check)：** 如果覆盖率低于你设置的 `min-coverage`，Workflow 会报错，从而阻止该 PR 合并。
* **行内标注：** 它可以直接在 GitHub 的 "Files changed" 视图中指出哪些行没有被测试覆盖。

---

## 4. 进阶：使用 Codecov (更专业的选择)

如果你的项目是开源的，或者公司愿意付费使用第三方工具，**Codecov** 是更好的选择。它可以提供覆盖率趋势图和更精美的 UI。

1. **修改脚本：** 无需复杂的 PR 评论 Action，只需上传 XML。
```yaml
- name: Upload to Codecov
  uses: codecov/codecov-action@v4
  with:
    files: ./app/build/reports/jacoco/jacocoTestReport/jacocoTestReport.xml
    token: ${{ secrets.CODECOV_TOKEN }}

```


2. **优势：** Codecov 会在 GitHub 的 PR 页面提供一个非常直观的 "Coverage Patch" 报告，一眼看出新写的代码是否都被测试到了。

---

## 常见问题

* **路径不匹配：** 请确保 `paths` 指向的 XML 路径与 Gradle 生成的路径完全一致（注意 `debug` 或 `release` 变体）。
* **权限问题：** `GITHUB_TOKEN` 是 GitHub 自动提供的，无需手动配置，但请确保在仓库设置中 `Actions` -> `General` -> `Workflow permissions` 开启了 **"Read and write permissions"**。

**你需要我帮你针对多模块（Multi-module）项目的覆盖率合并提供配置建议吗？**