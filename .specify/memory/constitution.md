<!--
Sync Impact Report
==================
- Version change: （未填充的模板骨架 → 1.0.0）首次批准；原文件为 `.specify/templates/constitution-template.md`
  的原样副本，无任何项目条款，因此本次为初始制定而非修订。
- 模板解析：`.specify/scripts/bash/resolve-template.sh constitution-template --json` 成功（exit 0）；
  生效层为 `.specify/templates/constitution-template.md`（不存在 `templates/overrides/`、`.specify/presets/`、
  `.specify/extensions/` 三层，故无合成层）。
- Modified principles: 无（5 条原则全部新建，模板中无既有标题）
- Added sections: 「文档库与产物约束」、「技能套件与工作流」、「Governance」
- Removed sections: 无
- Follow-up TODOs: 无（无占位符留存；RATIFICATION_DATE 由本次首次批准动作确定，非推定值）
-->

# UE5AIRead 项目章程

本工程把 **UE5 5.8 引擎源码**转化为**可核验的中文技术文档**，服务两类消费者：
程序员阅读理解，以及 AI 辅助编程时的 API 检索。章程约束的对象是**文档产物**、
**技能套件**与**工作方式**——不是引擎源码自身。

## Core Principles（核心原则）

### I. 引擎源码只读，产物单向流入 `docs/`（NON-NEGOTIABLE）

- 引擎安装根（本机 `E:\EpicGames\UE_5.8`）及 `E:\EpicGames\` 下的一切文件 MUST 视为只读；
  任何技能、脚本、自动化或人工操作都 MUST NOT 对其执行写操作。
- 文档产物 MUST 只写入仓库根的 `docs/`，路径由 `docs/_meta/convention.md` 第六节固定；
  MUST NOT 写入技能目录或仓库其他位置。技能目录只承载技能本体
  （`SKILL.md`、`scripts/`、`assets/`、`references/`、`evaluation/`）。
- 已发布产物的事实内容 MUST NOT 被静默改写。补充与修正 MUST 在原文上叠加，
  并在产物末尾「更新记录」节留痕（格式见 `convention.md` 第八节）。

**理由**：引擎是外部依赖，重装或换机即整体漂移；`docs/` 才是可被 git 追踪、可被 review、
可脱离技能独立分享的资产。一旦允许就地改写事实或反向写入引擎树，
文档的可信度与可复现性会同时失效。

### II. 证据先行，不推断实现（NON-NEGOTIABLE）

- 每处代码引用 MUST 是实际打开原文件核对过的「文件 + 行号」。
  MUST NOT 凭记忆或"常见写法"补全 API 名、路径、命名空间与导出宏。
- 任何「零命中 / 搜不到 / 不存在」的结论，在下定论之前 MUST 先运行
  `check-source.ps1` 确认证据源本身完整。证据源不完整时，结论 MUST 记为
  「本机不可判定」，MUST NOT 写成"不存在"。
- 无法确认的事实 MUST 显式标注为「本机不可判定」，MUST NOT 用
  "UE 通常是这样"补全。

**理由**：本套件曾把"仅头文件安装导致的看不见"误判成"这两个模块没有入口类"，
错误结论写进产物之后才发现（补齐源码后确认为 `FCoreModule` / `FCoreUObjectModule`）。
这类错误会直接误导把 `docs/` 当作唯一事实来源的 AI 消费者。

### III. 版本锚点与文档头强制

- `docs/modules/`、`docs/types/`、`docs/flows/` 下的每份产物 MUST 以五字段文档头开头：
  引擎版本、源码根、生成技能、生成时间、校验状态。字段值 MUST 从
  `convention.md`「本机环境」块复制，MUST NOT 自行填写。
- 引擎版本号 MUST 取自 `Engine/Build/Build.version`。MUST NOT 依赖 Launcher Manifest
  （实测重装后其条目会丢失），MUST NOT 以文件时间戳（mtime）判定引擎身份或
  "是否被改动"。
- 校验状态初始为 `未校验`，只由 `ue-doc-verify` 核对通过后回填
  `已校验（YYYY-MM-DD）`。日期一律 `YYYY-MM-DD`。

**理由**：没有版本锚点的引擎文档，在引擎升版后无法判断是否仍然有效——
这一条不可省略。

### IV. 规范单一真源，格式机器可解析

- 全体技能 MUST 共享并遵守 `docs/_meta/convention.md`（单一真源）。
  格式争议一律以该文件为准，技能 MUST NOT 各自定义格式。
- 文档中的引擎路径 MUST 相对 UE 安装根、以 `Engine/` 开头、使用正斜杠、不含盘符。
  绝对路径只允许出现在 `convention.md` 的「本机环境」块。
- 引用 MUST 采用规范第四节的块格式，并遵守 4.1 的三条机器解析规避：
  模块内相对路径（`Public/...`）、`.../` 缩写中间段、路径后紧跟全角括号——
  三者都会被 `verify-refs.ps1` 误判为"引用缺失"。
- 正文用中文；类名、函数名、宏、变量名、文件名、模块名、配置项 MUST 保留英文原名，
  统一用反引号包裹，不翻译、不改大小写。

**理由**：套件协同的唯一前提是"规范只定义一次"，且放在随文档库走的固定路径
（而非某个技能目录内）。引用格式一旦不可机检，`ue-doc-verify` 对全库上千处行号
的回查就无法成立。

### V. 数字断言必须可复算

- 产物中每个「N 处 / N 个 / N 行 / N 命中 / N 文件」断言，MUST 在文末
  「取数说明」节有对应行；查不到对应行的数字视为不合规。
- 每行取数方式 MUST 以方法标记开头：`[M]` 机器可复算（MUST 给出白名单形式命令，
  且命令实跑结果须与断言一致）、`[R]` 引用型（MUST 写明来源路径）、
  `[H]` 人工通读型（MUST 写明通读对象与判据）。未声明标记即不合规。
- 计数口径 MUST 写进命令本身（数的对象、匹配模式、是否区分大小写、递归范围），
  因为口径漂移只能靠命令暴露，不能靠复读发现。

**理由**：2026-10-11 语义核对轮实测——约 1,800 处行号引用只错 **9** 处，
而计数类断言错 **13** 处。差别不在"看错"，而在数字没把口径写进命令里。

## 文档库与产物约束

**一、目录与命名**（与 `convention.md` 第六节一致）

| 目录 | 内容 | 生产者 | 命名规则 |
|---|---|---|---|
| `docs/_meta/` | 元信息与规范 | 主技能 / 盘点 / 校验 / 评估 | `convention.md`、`inventory.md`、`engine-modules.json`、`quality-report.md`、`skill-suite-assessment.md` |
| `docs/modules/` | 模块级结构 | `ue-module-structure` | `<模块名>-结构.md` |
| `docs/types/` | 类型级 API 面 | `ue-type-api` | `<类名>.md` |
| `docs/flows/` | 机制级调用链 | `ue-flow-trace` | `<机制名>.md` |
| `docs/ai/` | AI 检索索引 | `ue-ai-index` | `ai-index.md` |
| `docs/` 根 | 全库索引 | 主技能 | `00-索引.md` |

**二、每份产物必备的结构**：文档头（原则 III）、正文、`## 取数说明`（原则 V）、
`## 相关文档`（可交叉引用的其他产物）；发生实质修正时追加 `## 更新记录`。

**三、索引一致性**：每完成一篇产物 MUST 在 `docs/00-索引.md` 追加一行；
校验通过后回填校验状态。索引与磁盘 MUST 保持一致，全量机器检查须覆盖此项。

**四、AI 检索索引**：`docs/ai/ai-index.md` 只从既有产物重组提炼，
MUST NOT 引入新事实；产物数量增长后 MUST 重跑。

**五、范围边界（非目标，防止范围蔓延）**

| 不做 | 原因 |
|---|---|
| 逐行翻译 / 注释引擎源码 | 无边际收益，且无法校验 |
| `ThirdParty`（31,021 文件）文档 | 第三方库噪声，非 Epic 实现 |
| `Editor` / `Developer` / `Programs` / `Platforms` 层 | 本版服务 Gameplay 开发，不服务工具链与编辑器扩展 |
| 跨引擎版本并行维护 | 本版锁定 UE 5.8 单版本 |
| 可编译的示例工程 | 只产出文档，不产出工程代码 |

## 技能套件与工作流

**一、独立成技能的三问判据**（三问全"是"才独立成技能，
否则降级为步骤文档或数据文件）：

1. 能否一句话说清「输入 X → 单一产物 Y → 给消费者 Z」？
2. 能否被独立触发（用户可能只想做这一步）？
3. 改动频率是否与其他部分显著不同？

**二、拆分轴**：子技能按**产物粒度**拆（模块 / 类型 / 流程），主技能按**流程阶段**编排。
MUST NOT 按引擎子系统或引擎模块垂直拆技能——模块清单是**数据**不是**能力**。
原则：把"多"留给数据文件，把"专"留给技能。

**三、单一职责**：每个技能只产出自己那一种产物，并在 SKILL.md 中写明「明确不做」
与 description 触发锚点，避免子技能之间抢触发。

**四、脚本归属**：脚本 MUST 跟着唯一消费者走，放进该技能的 `scripts/`；
出现第二个消费者时才上提到共享位置。

**五、新增或修改技能** MUST 走 `.codebuddy/skills/`，动手前先读设计文档中的
拆分判据（`docs/设计说明-UE5引擎文档技能套件.md` 第 3 节）。

**六、标准闭环**（每个批次 MUST 依次经过）：
盘点 → 定批 → 生产 → 机器初筛 → 校验 → 回填校验状态 → 重建索引。

**七、质量门禁**：`verify-refs.ps1` 判 PASS 才可把产物标为 `已校验`；
`ue-doc-verify` 与 `ue-ai-index` MUST NOT 新增事实内容——前者只核对，后者只重组。

**八、变更传播**：规范或技能变更 MUST 做反向检索，评估已有产物的影响面并同步。
产物内容未变时，本轮记为"零修正"，不重复做语义重校。

**九、检查点**：技能的关键步骤 MUST 给出可直接复制的检查点命令，
供使用者与后续会话复现判断。

## Governance

**效力与优先级**：本章程是最高约束。`convention.md` 是其下的实施细则。
冲突时以本章程为准，且调整顺序 MUST 是先改技能、再改产物。
优先级：**章程 > `convention.md` > 技能 `SKILL.md` > 产物**。

**修订程序**：任何修订 MUST ① 说明理由与影响面；② 同步检查 `convention.md`
与受影响的技能；③ 按版本策略递增版本号；④ 涉及规范时在 `convention.md`
「变更记录」追加条目；⑤ 更新本章程底部的版本行。

**版本策略（语义化）**：

- **MAJOR**：移除或重定义原则、不兼容的治理变更。
- **MINOR**：新增原则或章节、实质性扩展既有指引。
- **PATCH**：措辞澄清、错别字、非语义性修正。

**合规复核**：每个批次收口 MUST 跑一次全量机器检查
（`verify-refs.ps1` + 文档头与版本锚点 + 索引 ↔ 磁盘一致性）；
每次规范升版 MUST 做影响面回归。复核结果记入 `docs/_meta/quality-report.md`。

**运行时指引**：日常操作以 `docs/_meta/convention.md` 与主技能 `ue-engine-docs`
的 SKILL.md 为准；本套件为**只读引擎、只写 `docs/`** 的文档生产工具链。

**Version**: 1.0.0 | **Ratified**: 2026-10-13 | **Last Amended**: 2026-10-13
