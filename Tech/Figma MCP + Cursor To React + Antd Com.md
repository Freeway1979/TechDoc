# Figma MCP + Cursor To React + Antd Component

在 2025 年，将 Figma 设计稿转换为 React + Ant Design (Antd) 的页面，主要有两种 MCP (Model Context Protocol) 路径：一种是利用专门针对 Antd 优化的第三方 MCP，另一种是通过配置官方 MCP 的提示词（Prompt）来实现精准转换。

## 1. 专门针对 Ant Design 的解决方案

虽然目前最流行的 MCP 默认输出通常是 Tailwind，但已有针对特定组件库优化的方案：

### Figma-to-Code MCP (定制化实现)

一些开发者已发布支持自定义组件库映射的 MCP。例如，你可以使用基于 `StudentOfJS/mcp-figma-to-react` 的思路，通过配置文件强制要求 AI 搜索并匹配项目中的 antd 依赖。

### AI Dev for Ant Design (Figma 插件 + AI)

虽然它首先是一个 Figma 插件，但它已集成了 Claude 3.5 Sonnet，并专门针对 Ant Design 进行了微调。你可以将其代码生成的逻辑通过 MCP 流程引入 Cursor。

## 2. 使用 Figma 官方 MCP + 定制提示词 (推荐方式)

这是 2025 年在 Cursor 中最灵活的做法。官方 MCP 提供设计稿的结构化元数据（JSON），而你可以通过提示词强制 AI 使用 Antd 组件。

### 配置步骤

1. **启用官方 MCP**：在 Figma 桌面端开启 Dev Mode MCP Server。
2. **连接 Cursor**：在 Cursor 设置中添加服务器地址 `http://127.0.0.1:3845/mcp`。
3. **精确指令转换**：
   在 Cursor Composer (Cmd + I) 中粘贴 Figma 链接，并输入以下提示词：

   ```
   根据这个 Figma 设计稿，生成一个 React 页面。要求必须使用 Ant Design (Antd) 组件库。
   将表单映射到 <Form>，按钮映射到 <Button>，卡片映射到 <Card>。
   保持样式一致，如果 Antd 自定义主题无法完全覆盖，请使用 inline styles 或 CSS Modules 辅助。
   确保使用 TypeScript 类型定义。
   ```

## 3. 其他高效替代工具 (插件级集成)

如果 MCP 生成的代码不够完美，可以配合以下在 2025 年表现优异的工具：

- **Anima for Figma**：Anima 现在已原生支持 Ant Design (Antd) 代码导出，其 AI 引擎可以识别 Figma 组件并将其直接转换为 production-ready 的 Antd 代码。
- **Locofy.ai**：支持将 Figma 元素标记为 Antd 组件，然后通过其同步功能直接拉取到代码中。

## 总结建议

如果你追求极致的自动化，建议在 Cursor 中配置官方 Figma MCP，并结合 Antd 官方设计规范文件（由 Ant Design 官方提供的 Figma 组件包）。当 AI 识别到你使用的是 Antd 规范的图层命名时，它生成 Antd 代码的准确率会大幅提升。

---

# 🚀 Ant Design 精准转换指令

这是一份专门针对 React + Ant Design (Antd) 优化的 Cursor Prompt 模板。

在使用时，请确保你已经通过 MCP 连接了 Figma（或者在聊天框中粘贴了 Figma 节点的链接），然后将以下内容发送给 Cursor：

## Role

你是一位精通 Ant Design (Antd 5.0+) 的高级前端开发专家。

## Task

请解析当前引用的 Figma 设计稿，并将其转换为一个高质量、可复用的 React 组件。

## Strict Requirements

### 组件库映射

严禁使用原生 HTML 标签（如 `<button>`, `<input>`）。必须优先匹配 Antd 组件：

- 按钮 -> `<Button>`
- 输入框/文本域 -> `<Input>` / `<Input.TextArea>`
- 选择器 -> `<Select>`
- 表格 -> `<Table>`
- 布局容器 -> `<Flex>`, `<Space>`, 或 `<Row>`/`<Col>`
- 弹窗/抽屉 -> `<Modal>` / `<Drawer>`
- 文本 -> `<Typography.Text>` 或 `<Typography.Title>`

### 样式处理

- 优先使用 Antd 的 Design Token 系统（通过 `ConfigProvider` 或 `theme.useToken()`）。
- 对于布局，优先使用 `Flex` 组件来处理 `gap`, `align`, `justify` 等属性。
- 如果设计稿中有特殊的边距或颜色，请使用 `style` 属性或简单的 CSS Modules，禁止引入 Tailwind 或其他大型样式库。

### 代码质量

- 使用 TypeScript，并为所有 Props 定义严格的 `interface`。
- 保持组件为函数式组件（Functional Component）。
- 自动识别设计稿中的"重复模式"并将其提取为子组件。

### 交互还原

识别设计稿中的交互状态（如 Hover, Active, Disabled），并应用相应的 Antd 属性。

## Output Format

- 请直接输出完整的 `.tsx` 代码文件。
- 如果涉及复杂的静态资源（如 SVG 图标），请使用 Antd 的 `@ant-design/icons`。

## 使用技巧

- **配合 Dev Mode**：如果你在 Figma 中开启了 Dev Mode 并使用了 MCP，AI 可以看到图层的具体 CSS 数值。
- **局部转换**：你可以选中特定的 Figma 节点（Node），然后告诉 Cursor："只转换选中的这个 Form 表单区域"。
- **版本声明**：如果你使用的是特定的 Antd 版本（比如为了兼容旧项目使用 Antd 4.x），请在 Prompt 第一行特别标注，AI 会自动切换语法。

---

# .cursorrules 配置文件

你可以通过在项目的根目录下创建一个名为 `.cursorrules` 的文件来持久化这些设定。这样，每当你在这个项目中使用 Cursor 的 Chat 或 Composer 功能时，AI 都会自动遵循这些 Ant Design 开发规范。

## 文件内容

请将以下内容完整地复制并粘贴到 `.cursorrules` 文件中：

```markdown
# Ant Design (Antd) 开发规范

你是精通 React + Ant Design (Antd 5.0+) 的资深前端专家。在处理任何 Figma 设计稿转换或代码生成任务时，必须严格遵守以下规则：

## 1. 组件库强制映射

- **严禁**使用原生 HTML 标签。所有元素必须映射到对应的 Antd 组件：
  - 容器/盒子 -> `<Flex>`, `<Space>`, `<Layout>`, 或 `<Card>`
  - 按钮 -> `<Button>`
  - 文本输入 -> `<Input>`, `<Input.TextArea>`
  - 选择器/日期 -> `<Select>`, `<DatePicker>`
  - 列表/表格 -> `<List>`, `<Table>`
  - 导航/菜单 -> `<Menu>`, `<Tabs>`, `<Breadcrumb>`
  - 文本/标题 -> `<Typography.Text>`, `<Typography.Title>`

## 2. 布局与样式规范

- **布局优先**：优先使用 `Flex` 组件处理间距（gap）、对齐（align）和分布（justify）。
- **Token 系统**：优先使用 Antd 的 Design Token。对于自定义样式，通过 `theme.useToken()` 获取变量。
- **避免冗余**：除非 Antd 无法实现，否则不要引入 Tailwind 或额外的 CSS 框架。
- **图标库**：使用 `@ant-design/icons`。

## 3. 技术栈要求

- **语言**：必须使用 TypeScript，并定义严格的 `interface` 或 `type`。
- **范式**：使用函数式组件 (Functional Components) 和 Hooks。
- **逻辑提取**：自动识别设计稿中的重复模块并将其拆分为独立的子组件。

## 4. Figma 转换指令 (MCP)

当解析 Figma 链接或 Node 数据时：

- 识别设计稿中的 Auto Layout 并将其转换为 `<Flex>` 属性。
- 将设计稿中的颜色、圆角、字体权重对应到 Antd 的 `theme` 属性中。
- 如果检测到组件库定义的图层名（如 "Button/Primary"），直接生成对应的 `<Button type="primary">`。

## 5. 输出要求

- 只输出简洁、可运行的 `.tsx` 代码。
- 必须包含必要的 `import` 语句。
```

## 如何使用此文件

1. **创建文件**：在你的项目根目录新建 `.cursorrules`。
2. **激活规则**：保存文件后，Cursor 会在后台自动读取。
3. **开始转换**：现在，你只需要在 Chat 窗口输入："把这个 Figma 链接转换成代码：[你的链接]"。AI 就会自动应用上述所有 Antd 规则，而不需要你每次都重复输入长段的 Prompt。

## 提示

如果你的项目目前使用的是特定的 Antd 版本（如 4.x），请将规则中的 Antd 5.0+ 修改为你对应的版本，AI 会自动调整语法（例如将 Flex 替换为传统的 Row/Col）。

