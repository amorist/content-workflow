# Content Workflow - AI短视频内容生产工作流

用于：记录选题、检索素材、生成文稿、优化开头、生成标题、数据复盘。

## 快速安装

复制以下内容给 AI Agent 自动安装：

```
请安装 content-workflow 技能：https://github.com/amorist/content-workflow

安装步骤：
1. 下载项目：
   - 有 git：git clone https://github.com/amorist/content-workflow.git
   - 无 git：curl -L https://github.com/amorist/content-workflow/archive/refs/heads/main.zip -o cw.zip && unzip cw.zip && mv content-workflow-main content-workflow

2. 初始化：cd content-workflow && bash .content-workflow/preamble.sh

3. 读取 SKILL.md，告诉我版本和可用命令以及使用方式
```

## 目录结构

```
content-workflow/
├── SKILL.md                          # 技能主文件
├── references/                       # 工作流定义
│   ├── 内容策划.md                    # 深度选题策划
│   ├── 生成文稿.md                    # 完整文稿生成
│   ├── 内容审核.md                    # 多维度审核
│   ├── 数据复盘.md                    # 数据分析复盘
│   ├── 周报复盘.md                    # 周期性复盘
│   ├── 违规库维护.md                  # 违规库管理
│   ├── 产品资料维护.md                # 产品资料管理
│   ├── 生成标题.md
│   ├── 优化开头.md
│   ├── 检索素材.md
│   ├── 选题记录.md
│   └── 数据复盘.md
├── .content-workflow/                # 系统配置
│   ├── config                        # 用户配置
│   ├── preamble.sh                   # 前置检查
│   ├── timeline.sh                   # 时间线追踪
│   └── learnings.sh                  # 学习系统
└── 内容生产系统/                      # 内容生产数据（工作目录）
    ├── 00-想法收集箱/
    ├── 01-素材库/
    │   ├── 核心概念库/
    │   ├── 金句库/
    │   ├── 案例库/
    │   ├── 产品资料库/               # 产品资料管理
    │   │   ├── 产品索引.md
    │   │   ├── 产品标签体系.md
    │   │   └── products/
    │   ├── 结构库/
    │   └── 爆款拆解/
    ├── 02-选题管理/
    ├── 03-文稿库/
    ├── 04-发布与数据/
    └── 05-方法论沉淀/
```

## 工作流命令

| 功能         | 触发词                             | 说明                   |
| ---------- | ------------------------------- | -------------------- |
| **产品资料维护** | 「新产品」「添加产品」「录入产品」「上新」           | 添加新产品到产品库            |
| **产品资料维护** | 「查产品」「找产品」「产品资料」「有哪些产品」         | 查询产品资料               |
| **产品资料维护** | 「更新产品」「修改产品」「补充产品信息」            | 更新现有产品信息             |
| **违规库维护**  | 「查违规」「违规规则」「这个能发吗」「会不会违规」「违规查询」 | 查询违规规则和规避方法          |
| **违规库维护**  | 「添加违规」「记录违规」「新违规类型」「补充违规规则」     | 添加新的违规案例到库中          |
| **违规库维护**  | 「审核内容」「检查合规」「文案合规检查」「合规检查」      | 审核内容是否合规             |
| **违规库维护**  | 「更新违规库」「修改规避方法」「优化违规规则」         | 更新违规库规则和方法           |
| 内容策划       | 「帮我看看这个选题」「这个选题怎么样」「选题分析」       | 深度探讨选题可行性            |
| 生成文稿       | 「生成文稿」「写个脚本」「创作内容」「写文案」         | 完整的文稿生成流程（必须使用文风DNA） |
| 内容审核       | 「审核内容」「检查一下」「看看有没有问题」           | 多维度审核检查              |
| 数据复盘       | 「数据复盘」「分析效果」「为什么没爆」             | 单条内容数据分析             |
| 周报复盘       | 「周报」「这周怎么样」「weekly retro」       | 周期性总结复盘              |
| 记录选题       | 「记录选题」「记个选题」                    | 快速记录选题               |
| 检索素材       | 「检索素材」「搜一下素材」                   | 素材库检索                |
| 优化开头       | 「优化开头」「前5秒」「开屏」                 | 开头优化                 |
| 生成标题       | 「生成标题」「起个标题」                    | 标题生成                 |
| 版本更新       | 「检查更新」「更新技能」「upgrade」           | 检查并执行系统更新            |

## 系统工具

### 前置检查

```bash
bash .content-workflow/preamble.sh
```

### 学习系统

```bash
# 添加学习记录
bash .content-workflow/learnings.sh add "主题" "学习内容" "表现" "标签"

# 搜索学习记录
bash .content-workflow/learnings.sh search "关键词"

# 查看学习摘要
bash .content-workflow/learnings.sh summary
```

### 时间线追踪

```bash
# 记录事件
bash .content-workflow/timeline.sh draft "标题" "时长"
bash .content-workflow/timeline.sh publish "平台" "标题"
bash .content-workflow/timeline.sh review-data "标题" "播放量"

# 查看今日统计
bash .content-workflow/timeline.sh today
```

### 版本管理

```bash
# 查看当前版本
bash .content-workflow/upgrade.sh version

# 检查更新
bash .content-workflow/update-check.sh

# 升级到最新版本
bash .content-workflow/upgrade.sh

# 创建备份
bash .content-workflow/upgrade.sh backup

# 查看所有备份
bash .content-workflow/upgrade.sh list

# 恢复到指定备份
bash .content-workflow/upgrade.sh restore 1

# 清理旧备份
bash .content-workflow/upgrade.sh cleanup 5

# 查看升级历史
bash .content-workflow/upgrade.sh history
```

**版本：** 2.2.0 | [CHANGELOG](CHANGELOG.md)

## 文风DNA

生成文稿时已内置高密度话语模式（PT01-PT15）、禁忌成交算法（AL06）、特殊规则层（RULE01-RULE10）等，详见 `references/生成文稿.md`。

***

版本：2.2.0
更新日期：2026-04-11
