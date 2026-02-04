# 如何用Node.js 实现一个MCP，能够将常用的一些方法转换出具体的command或guide？

比如 调整 AWS 输出 log level的方法是什么？能得到具体的操作方法。以此类推，不断增加工作中常用的行为。


要实现这个需求，最优雅的方法是利用 MCP 的 **Resources（资源）** 和 **Tools（工具）** 两个核心特性。

你可以将 Node.js MCP 服务器看作一个**“企业知识库 + 脚本执行器”**。

### 1. 核心架构设计

* **Resources (知识库)**：存储静态或动态的 `guides`（如：AWS Log Level 调整指南）。当 AI 需要查看“怎么做”时，它会读取资源。
* **Tools (执行器)**：提供具体的 `commands`（如：直接执行 AWS CLI 修改命令）。当用户说“帮我把日志改为 DEBUG”时，AI 调用工具。

---

### 2. 代码实现 (Node.js + TypeScript)

我们将使用 `@modelcontextprotocol/sdk` 构建一个名为 `WorkAssistant` 的服务器。

#### 第一步：准备数据结构

为了方便“不断增加常用行为”，我们定义一个配置对象。

```typescript
// src/knowledge.ts
export const WORK_GUIDES = {
  "aws-log-level": {
    title: "AWS Lambda/CloudWatch 日志级别调整",
    guide: "1. 进入 Lambda 控制台\n2. 找到配置选项卡\n3. 修改环境变量 LOG_LEVEL 为 DEBUG/INFO/WARN",
    command: "aws lambda update-function-configuration --function-name MyFunction --environment 'Variables={LOG_LEVEL=DEBUG}'"
  },
  "docker-clean": {
    title: "清理 Docker 空间",
    guide: "使用 docker system prune 命令清理未使用的镜像和容器",
    command: "docker system prune -af"
  }
};

```

#### 第二步：编写 MCP Server

```typescript
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";
import { WORK_GUIDES } from "./knowledge.js";

const server = new McpServer({
  name: "WorkFlowAssistant",
  version: "1.0.0",
});

// --- 1. 定义资源：让 AI 可以检索所有指南 ---
server.resource(
  "work-guides",
  "knowledge://company/guides",
  async (uri) => ({
    contents: [{
      uri: uri.href,
      text: JSON.stringify(WORK_GUIDES, null, 2),
      mimeType: "application/json"
    }]
  })
);

// --- 2. 定义工具：获取特定行为的操作方法 ---
server.tool(
  "get-action-guide",
  "根据行为关键字获取具体的操作指南和命令示例",
  {
    actionKey: z.string().describe("行为关键字，例如 'aws-log-level' 或 'docker-clean'"),
  },
  async ({ actionKey }) => {
    const action = WORK_GUIDES[actionKey as keyof typeof WORK_GUIDES];
    if (!action) {
      return {
        content: [{ type: "text", text: `未找到关于 ${actionKey} 的操作方法。` }],
        isError: true
      };
    }
    return {
      content: [{ 
        type: "text", 
        text: `【${action.title}】\n操作步骤：${action.guide}\n具体命令：${action.command}` 
      }],
    };
  }
);

// --- 3. 定义工具：模糊搜索 (可选) ---
server.tool(
  "search-actions",
  "搜索相关的常用行为",
  { query: z.string() },
  async ({ query }) => {
    const results = Object.keys(WORK_GUIDES).filter(k => k.includes(query));
    return {
      content: [{ type: "text", text: `匹配的行为项: ${results.join(", ")}` }]
    };
  }
);

async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
}

main().catch(console.error);

```

---

### 3. 如何实现“不断增加”？

为了让非开发人员也能增加内容，你可以改变数据存储方式：

1. **从本地 JSON/YAML 加载**：让 `knowledge.ts` 读取一个本地目录下的所有 `.md` 或 `.json` 文件。这样你只需要往文件夹里丢新文件，AI 就能识别。
2. **连接数据库**：在 `get-action-guide` 工具内部连接你的数据库。
3. **集成 Notion/Confluence**：在 MCP 工具内调用这些文档平台的 API。

### 4. 实际使用场景示例

* **用户问**：“我想调整 AWS 的日志等级，该怎么做？”
* **AI 思考**：
1. AI 发现有一个 `search-actions` 工具，输入 "AWS log"。
2. 找到 `aws-log-level`。
3. AI 调用 `get-action-guide(actionKey: "aws-log-level")`。


* **AI 回答**：“调整 AWS 日志等级，你可以通过控制台修改环境变量。如果你想用命令行，可以执行：`aws lambda update-function-configuration...`”

### 5. 为什么这样做比直接写 Prompt 好？

* **实时性**：你可以随时更新数据库，AI 无需重新训练或修改 System Prompt 就能获得最新命令。
* **准确性**：命令直接从你的“标准库”里提取，不会出现 AI 胡编乱造（幻觉）命令参数的情况。
* **权限控制**：如果你愿意，你甚至可以再写一个 `execute-command` 的 Tool，让 AI 经过你确认后直接运行这些命令。

**你需要我帮你写一个能自动扫描特定目录下所有 Markdown 文件并生成 MCP 工具的代码模板吗？** 这样你只需增加 `.md` 文件即可扩展功能。

这是一个非常实用的方案。通过**动态扫描目录**的方式，你可以将 MCP 服务器变成一个“热更新”的知识库：只需在特定文件夹下扔进一个新的 Markdown 文件，AI 就能立即学会新的操作规程。

### 1. 项目结构设计

我们将 Markdown 文件的 **文件名** 作为 Key，**文件内容** 作为 Guide。

```text
my-mcp-server/
├── src/
│   └── index.ts
├── guides/            <-- 存放你的操作手册
│   ├── aws-log-level.md
│   └── docker-clean.md
├── package.json
└── tsconfig.json

```

---

### 2. 代码实现

我们将使用 Node.js 原生的 `fs` 模块来实时读取文件。

```typescript
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";
import fs from "fs/promises";
import path from "path";
import { fileURLToPath } from "url";

// 处理 ESM 下的路径问题
const __dirname = path.dirname(fileURLToPath(import.meta.url));
const GUIDES_DIR = path.join(__dirname, "../guides");

const server = new McpServer({
  name: "DynamicKnowledgeBase",
  version: "1.0.0",
});

/**
 * 辅助函数：扫描目录并读取所有 Markdown 文件
 */
async function getAllGuides() {
  try {
    const files = await fs.readdir(GUIDES_DIR);
    const mdFiles = files.filter(f => f.endsWith(".md"));
    
    const guides: Record<string, string> = {};
    for (const file of mdFiles) {
      const content = await fs.readFile(path.join(GUIDES_DIR, file), "utf-8");
      const key = path.parse(file).name; // 例如 aws-log-level
      guides[key] = content;
    }
    return guides;
  } catch (error) {
    console.error("读取目录失败:", error);
    return {};
  }
}

// --- 1. 定义资源：列出所有可用的指南条目 ---
server.resource(
  "guide-list",
  "knowledge://guides/all",
  async (uri) => {
    const guides = await getAllGuides();
    return {
      contents: [{
        uri: uri.href,
        text: `可用指南索引：\n${Object.keys(guides).join("\n")}`,
        mimeType: "text/plain"
      }]
    };
  }
);

// --- 2. 定义工具：搜索并获取具体的指南内容 ---
server.tool(
  "get-guide",
  "输入关键字获取具体的操作手册（Command/Guide）",
  {
    topic: z.string().describe("手册关键字，如 'aws-log-level'"),
  },
  async ({ topic }) => {
    const guides = await getAllGuides();
    const content = guides[topic];

    if (!content) {
      const suggestions = Object.keys(guides).filter(k => k.includes(topic));
      return {
        content: [{ 
          type: "text", 
          text: `未找到 '${topic}'。你是不是想找：${suggestions.join(", ") || "无匹配项"}` 
        }],
        isError: true
      };
    }

    return {
      content: [{ type: "text", text: content }],
    };
  }
);

// --- 启动服务器 ---
async function main() {
  // 确保目录存在
  try { await fs.mkdir(GUIDES_DIR, { recursive: true }); } catch {}

  const transport = new StdioServerTransport();
  await server.connect(transport);
}

main().catch(console.error);

```

---

### 3. Markdown 文件编写规范建议

为了让 AI 更好地理解你的 Markdown，建议在每个文件内部使用标准结构。例如：

**guides/aws-log-level.md**

```markdown
# 调整 AWS Lambda 日志等级
## 适用场景
当需要调试生产环境代码时，将日志级别从 INFO 切换至 DEBUG。

## 操作步骤
1. 打开 AWS 控制台。
2. 搜索并进入 Lambda 服务。
3. 选择目标函数 -> Configuration -> Environment variables。

## CLI 命令
aws lambda update-function-configuration --function-name YOUR_FUNC --environment 'Variables={LOG_LEVEL=DEBUG}'

```

---

### 4. 进阶：如何让它更智能？

1. **自动索引 (Vector Store)**：如果你有几百个 Markdown 文件，手动 Key 匹配太慢。你可以集成一个轻量级的向量数据库（如 `LanceDB` 或 `FAISS`），通过 **语义搜索** 找到相关的 `.md` 文件。
2. **文件监听 (Chokidar)**：使用 `chokidar` 库监听 `guides/` 目录。当文件变动时，服务器可以向客户端发送通知。
3. **多级目录**：修改 `getAllGuides` 支持递归扫描子文件夹，这样你可以按 `guides/aws/`、`guides/docker/` 分类管理。

---

### 5. 调试建议

1. **使用 `console.error**`：再次提醒，所有的调试日志必须输出到 `stderr`，不要用 `console.log`。
2. **绝对路径**：在客户端配置时，`args` 里的路径建议写绝对路径，防止 `node` 找不到 `guides` 文件夹。

**下一步：**
你会发现在实际工作中，有些命令需要填入变量（如 `function-name`）。
**你想让我演示如何在 MCP 工具中加入参数化模板（Template），让 AI 自动把用户的输入填充到命令中吗？**


这是一个非常棒的进化方向。通过引入**参数化模板**，你可以让 AI 不仅仅是一个“复读机”，而是一个能帮你生成**立即可执行命令**的智能助手。

我们可以使用 **Handlebars** 风格的语法（或者简单的正则替换）在 Markdown 指南中预留变量占位符，例如 `{{function_name}}`。

### 1. 设计思路

1. **模板定义**：在 Markdown 文件中使用 `{{key}}` 定义变量。
2. **动态 Schema**：MCP 工具需要先读取文件，识别出里面有哪些变量。
3. **参数填充**：AI 提取用户提到的信息（如“函数名是 my-app”），填充进模板。

### 2. 代码实现 (Node.js + TypeScript)

我们需要引入一个简单的正则解析逻辑，动态告诉 AI 这个指南需要哪些参数。

```typescript
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { z } from "zod";
import fs from "fs/promises";
import path from "path";
import { fileURLToPath } from "url";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const GUIDES_DIR = path.join(__dirname, "../guides");

const server = new McpServer({
  name: "SmartTemplateAssistant",
  version: "1.1.0",
});

/**
 * 核心逻辑：从 Markdown 中提取 {{variable}} 变量名
 */
function extractVariables(content: string): string[] {
  const regex = /{{(.*?)}}/g;
  const matches = [...content.matchAll(regex)];
  return [...new Set(matches.map(m => m[1].trim()))];
}

/**
 * 核心逻辑：填充变量
 */
function fillTemplate(content: string, vars: Record<string, string>): string {
  let result = content;
  for (const [key, value] of Object.entries(vars)) {
    const regex = new RegExp(`{{${key}}}`, 'g');
    result = result.replace(regex, value);
  }
  return result;
}

// --- 工具 1：列出所有指南及其需要的参数 ---
server.tool(
  "list-available-guides",
  "查看所有操作指南以及它们需要的参数列表",
  {},
  async () => {
    const files = await fs.readdir(GUIDES_DIR);
    const mdFiles = files.filter(f => f.endsWith(".md"));
    let info = "可用指南：\n";

    for (const file of mdFiles) {
      const content = await fs.readFile(path.join(GUIDES_DIR, file), "utf-8");
      const vars = extractVariables(content);
      const key = path.parse(file).name;
      info += `- ${key} ${vars.length > 0 ? `(需要参数: ${vars.join(", ")})` : "(无需参数)"}\n`;
    }
    return { content: [{ type: "text", text: info }] };
  }
);

// --- 工具 2：生成填充后的指南 ---
server.tool(
  "generate-command",
  "根据用户提供的参数填充指南模板并生成具体命令",
  {
    topic: z.string().describe("指南关键字，如 'aws-log-level'"),
    parameters: z.record(z.string()).describe("键值对形式的参数，例如 { \"function_name\": \"my-api\" }"),
  },
  async ({ topic, parameters }) => {
    const filePath = path.join(GUIDES_DIR, `${topic}.md`);
    try {
      const rawContent = await fs.readFile(filePath, "utf-8");
      const requiredVars = extractVariables(rawContent);
      
      // 检查参数是否缺失
      const missing = requiredVars.filter(v => !parameters[v]);
      if (missing.length > 0) {
        return {
          content: [{ type: "text", text: `缺失必要参数: ${missing.join(", ")}。请补充后再试。` }],
          isError: true
        };
      }

      const finalContent = fillTemplate(rawContent, parameters);
      return { content: [{ type: "text", text: finalContent }] };
    } catch (e) {
      return { content: [{ type: "text", text: `指南 '${topic}' 不存在。` }], isError: true };
    }
  }
);

async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
}

main().catch(console.error);

```

---

### 3. Markdown 模板编写示例

现在你可以创建一个带变量的模板文件：

**guides/aws-log-level.md**

```markdown
# 调整 {{function_name}} 的日志级别

## 操作命令
执行以下命令将环境变量修改为 {{level}}:

```bash
aws lambda update-function-configuration \
  --function-name {{function_name}} \
  --environment 'Variables={LOG_LEVEL={{level}}}'

```

```

---

### 4. 实际交互流程

1.  **用户**：“我想把名为 `order-service` 的 Lambda 日志改成 `DEBUG`。”
2.  **AI 思考**：
    * 调用 `list-available-guides` 发现有 `aws-log-level`。
    * 发现该模板需要 `function_name` 和 `level`。
    * 从用户话语中提取出：`function_name: "order-service"`, `level: "DEBUG"`。
    * 调用 `generate-command(topic: "aws-log-level", parameters: { "function_name": "order-service", "level": "DEBUG" })`。
3.  **AI 回答**：
    “好的，你可以执行以下命令：
    `aws lambda update-function-configuration --function-name order-service --environment 'Variables={LOG_LEVEL=DEBUG}'`”

---

### 5. 进一步增强建议：

* **默认值支持**：在提取变量时，可以支持 `{{level|INFO}}` 这种格式，如果用户没提供就用 `INFO`。
* **交互式询问**：如果用户没提供参数，AI 会看到工具返回的“缺失必要参数”，它会自动追问用户：“请问您的函数名称是什么？”
* **权限确认**：如果这是个高危命令（如删除数据库），你可以在 Markdown 里加一个 `danger: true` 的元数据，提醒 AI 在输出前必须加上加粗的警告标识。

这种架构下，你只需要**维护 Markdown 文件**，无需改动代码，就能不断扩展你的“智能运维助手”的能力。你觉得这个模板解析深度够用吗？

```