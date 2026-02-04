Docker 是一个开源的**容器化平台**，它允许开发者将应用程序及其依赖项打包到一个标准化的单元（称为“容器”）中，确保应用在任何支持 Docker 的环境中都能以相同的方式运行。这种“一次构建，到处运行”的特性解决了开发、测试和生产环境不一致的问题。


### **核心概念**
1. **镜像（Image）**  
   - 一个只读模板，包含运行应用所需的代码、库、环境变量和配置文件。  
   - 例如：`nginx` 镜像包含 Nginx 服务器的所有文件和配置。  

2. **容器（Container）**  
   - 镜像的**运行实例**，是一个独立的可执行单元。  
   - 容器之间相互隔离，拥有自己的文件系统、网络和进程空间。  

3. **仓库（Repository）**  
   - 用于存储和分发镜像的地方，类似代码仓库（如 GitHub）。  
   - 公共仓库：[Docker Hub](https://hub.docker.com/)（默认仓库，包含大量官方镜像）；私有仓库：企业内部自建或云服务商提供（如 AWS ECR、阿里云 ACr）。  


### **基本使用流程**

#### 1. 安装 Docker
- **macOS**：下载 [Docker Desktop](https://www.docker.com/products/docker-desktop) 并安装（包含 Docker Engine、CLI 和 GUI 工具）。  
- **Linux**：通过包管理器安装（如 `sudo apt install docker-ce`  for Ubuntu）。  
- **Windows**：使用 Docker Desktop（需开启 WSL2 支持）。  

安装完成后，终端执行 `docker --version` 验证：
```bash
docker --version  # 输出 Docker 版本信息，如 Docker version 24.0.6, build ed223bc
```


#### 2. 拉取镜像（从仓库下载）
从 Docker Hub 拉取官方镜像（如 Nginx）：
```bash
docker pull nginx  # 拉取最新版本（默认 :latest 标签）
docker pull nginx:1.25  # 拉取指定版本（标签为 1.25）
```


#### 3. 运行容器（基于镜像创建实例）
以 Nginx 为例，启动一个容器并映射端口：
```bash
docker run --name my-nginx -p 8080:80 -d nginx
```
- `--name my-nginx`：指定容器名称为 `my-nginx`（可选）。  
- `-p 8080:80`：端口映射（宿主机器的 8080 端口 → 容器内的 80 端口）。  
- `-d`：后台运行容器（守护进程模式）。  
- `nginx`：基于 `nginx` 镜像启动。  

此时访问 `http://localhost:8080` 即可看到 Nginx 默认页面。


#### 4. 查看容器状态
```bash
docker ps  # 查看正在运行的容器
docker ps -a  # 查看所有容器（包括已停止的）
```


#### 5. 进入容器内部
```bash
docker exec -it my-nginx /bin/bash
```
- `-it`：交互式终端模式（可在容器内执行命令）。  
- 退出容器：`exit`。


#### 6. 停止/启动/删除容器
```bash
docker stop my-nginx  # 停止容器
docker start my-nginx  # 启动已停止的容器
docker rm my-nginx  # 删除容器（需先停止，或加 -f 强制删除）
```


#### 7. 查看/删除镜像
```bash
docker images  # 列出本地所有镜像
docker rmi nginx:1.25  # 删除指定镜像（需先删除依赖该镜像的容器）
```


### **进阶操作：构建自定义镜像**
通过 `Dockerfile` 定义自定义镜像，例如创建一个简单的 Node.js 应用镜像：

1. 创建项目文件：
   ```bash
   mkdir docker-demo && cd docker-demo
   touch app.js Dockerfile
   ```

2. 编写 `app.js`：
   ```javascript
   const http = require('http');
   http.createServer((req, res) => {
     res.end('Hello from Docker!');
   }).listen(3000);
   ```

3. 编写 `Dockerfile`（镜像构建规则）：
   
    
   

4. 构建镜像：
   ```bash
   docker build -t my-node-app:1.0 .  # -t 标记镜像名称和版本，. 表示当前目录的 Dockerfile
   ```

5. 运行自定义镜像：
   ```bash
   docker run --name my-node -p 3000:3000 -d my-node-app:1.0
   ```
   访问 `http://localhost:3000` 即可看到 `Hello from Docker!`。


### **Docker 优势**
- **环境一致性**：容器包含应用所有依赖，避免“在我电脑上能运行”问题。  
- **轻量级**：容器共享宿主操作系统内核，比虚拟机更省资源、启动更快（秒级）。  
- **隔离性**：容器间相互隔离，一个容器的故障不会影响其他容器。  
- **可扩展性**：结合编排工具（如 Kubernetes）可轻松实现容器集群的自动扩缩容。  


### **常用命令速查表**
| 命令 | 功能 |
|------|------|
| `docker pull <镜像名>` | 拉取镜像 |
| `docker run [选项] <镜像名>` | 运行容器 |
| `docker ps [-a]` | 查看容器 |
| `docker exec -it <容器名> <命令>` | 进入容器执行命令 |
| `docker stop/start <容器名>` | 停止/启动容器 |
| `docker rm <容器名>` | 删除容器 |
| `docker images` | 查看本地镜像 |
| `docker rmi <镜像名>` | 删除镜像 |
| `docker build -t <标签> .` | 构建镜像 |

Docker 已成为现代软件开发和部署的标准工具，尤其在微服务架构和持续集成/持续部署（CI/CD）流程中应用广泛。


```shell
# 基础镜像（Node.js 官方镜像，版本 18）
FROM node:18-alpine

# 设置工作目录（容器内的目录）
WORKDIR /app

# 复制当前目录文件到容器的 /app 目录
COPY . .

# 暴露容器内的 3000 端口（仅声明，需配合 -p 映射）
EXPOSE 3000

# 容器启动时执行的命令（启动 Node 应用）
CMD ["node", "app.js"]
    
```