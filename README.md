# Content Workflow - AI短视频内容生产工作流

用于：记录选题、检索素材、生成文稿、优化开头、生成标题、数据复盘。

## 安装方式

### 方式一：直接复制到 OpenClaw workspace skills 目录
```bash
cp -r content-workflow ~/.openclaw/workspace/skills/
```

### 方式二：链接方式（保留数据在原位置）
```bash
ln -sf /你的路径/content-workflow ~/.openclaw/workspace/skills/content-workflow
```

### 方式三：打包移动到其他工具
- 将整个 `content-workflow` 文件夹复制到目标 AI 工具的 skills 目录下
- 具体路径请参考目标工具的文档

## 目录结构

```
content-workflow/
├── SKILL.md                          # 技能主文件
├── references/                       # 参考规范
│   ├── 生成文稿.md                    # 含文风DNA
│   ├── 生成标题.md
│   ├── 优化开头.md
│   ├── 检索素材.md
│   ├── 选题记录.md
│   └── 数据复盘.md
└── 内容生产系统/                      # 内容生产数据（工作目录）
    ├── 00-想法收集箱/
    ├── 01-素材库/
    ├── 02-选题管理/
    ├── 03-文稿库/
    ├── 04-发布与数据/
    └── 05-方法论沉淀/
```

## 工作流命令

| 命令 | 触发词 |
|------|--------|
| 记录选题 | 「记录选题：XXX」「记个选题」 |
| 检索素材 | 「检索素材：XXX」「搜一下素材」 |
| 生成文稿 | 「生成文稿：XXX」「写个脚本」 |
| 优化开头 | 「优化开头」「前5秒」「开屏」 |
| 生成标题 | 「生成标题」「起个标题」 |
| 数据复盘 | 「记录数据」「数据复盘」「发布后」 |

---

## 飞书 CLI 安装与配置（可选）

> 如需与飞书多维表格联动（如选题管理自动同步到飞书），需要安装飞书 CLI。

### 环境要求
- Node.js 16.0 及以上版本
- npm 或 yarn

### 安装步骤

**第一步：安装 lark-cli**

```bash
npm install -g @larksuite/cli
```

**第二步：安装相关 Skills**

```bash
npx skills add https://github.com/larksuite/cli -y -g
```

**第三步：初始化应用配置**

```bash
lark-cli config init --new
```

配置过程中，会创建一个新应用（或选择已有应用）。**配置完成后需要重启 AI Agent 工具。**

**第四步：完成用户授权（可选）**

```bash
lark-cli auth login
```

执行后打开链接在飞书中确认即可。授权后 AI 可以你的身份访问日历、消息、文档等。

**第五步：验证安装**

```bash
lark-cli help       # 查看命令总览
lark-cli auth status # 查看当前登录状态
```

### 飞书多维表格配置（选题管理用）

Content Workflow 已内置飞书多维表格联动：

- **App Token**: `MAr1bOFujaC53FssmwNcgnGqnMe`
- **表格1「选题池」** table_id: `tblEXW02QlfdHT4S`
- **表格2「选题进度追踪」** table_id: `tblKFbeSisOa40rl`

安装 CLI 后，选题操作会自动同步到飞书多维表格。

### 飞书 CLI 核心能力

| 业务域 | 核心能力 |
|--------|----------|
| 消息与群组 | 搜索消息和群聊、发送消息、回复话题 |
| 云文档 | 创建文档、读取内容、更新正文、评论协作 |
| 多维表格 | 管理数据表、字段、记录、视图、仪表盘 |
| 日历 | 查询日程、创建会议、查询忙闲、推荐时间 |
| 邮箱 | 搜索、读取、起草、发送、回复、归档邮件 |
| 任务 | 创建任务、更新状态、管理清单和子任务 |
| 知识库 | 查询空间、管理节点和文档层级 |

---

## 文风DNA

生成文稿时已内置高密度话语模式（PT01-PT15）、禁忌成交算法（AL06）、特殊规则层（RULE01-RULE10）等，详见 `references/生成文稿.md`。

---

版本：1.0.0
更新日期：2026-04-10
