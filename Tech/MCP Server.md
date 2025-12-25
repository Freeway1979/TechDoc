# MCP Server 
## 官方MCP: https://mcp.figma.com/mcp
#### Figma to React

#### Figma to React Native with Cursor
```prompt
根据这个 Figma 节点的结构和样式，生成一个使用 React Native 和 TypeScript 的完整页面，确保符合 Flexbox 布局规范。
```
## 第三方
目前有专门为这一需求开发的开源 MCP 服务器，可以直接集成到 Cursor 中：

    Figma to React Native MCP (by kailashAppDev)
        核心功能：专门用于从 Figma 提取组件并生成对应的 React Native 组件代码。
        特点：支持组件层级维护、Props 处理以及样式的自动转换。
        安装指令 (Cursor):

        ```bash
        npx -y @smithery/cli@latest install @kailashg101/mcp-figma-to-code --client claude
        ```


Locofy MCP

    核心功能：Locofy 的 MCP 服务器允许你在 IDE 中直接调用其 AI 引擎，将复杂的 Figma 页面转换为模块化的 React Native 代码。
    优势：生成的代码质量较高，且支持响应式布局（自动处理 Flexbox）。