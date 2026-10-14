# Spec Kit 使用指南（UE5AIRead 实装版）

| 项 | 值 |
|---|---|
| 适用对象 | 在本仓库使用 Spec Kit 的人与 AI 代理 |
| Spec Kit 版本 | `specify-cli` **1.2.0**（`uv tool` 全局安装，工具目录 `%USERPROFILE%\.local\bin`） |
| 集成的编码代理 | **CodeBuddy**（`.codebuddy/commands/speckit.*.md`，**10** 个斜杠命令） |
| 脚本类型 | **PowerShell**（`.specify/scripts/powershell/*.ps1`，**6** 个脚本） |
| 功能编号模式 | `sequential`（`specs/001-…`，3 位零填充） |
| 初始化时间 | 2026-10-14 |
| 事实来源 | 本文结论均取自仓库内实际文件，标注为 `路径 第 N 行`；**示例产物为演示用**，非仓库现有文件 |
| 版本 | v1.0 / 2026-10-14 |

---

## 1. 这是什么

### 1.1 一句话

Spec Kit 是 GitHub 官方的 **SDD（Spec-Driven Development，规范驱动开发）** 工具包：
它把"让 AI 写代码"从**一次性对话**变成**有产物、有门禁、可复查的流水线**。

### 1.2 它解决什么问题

| 做法 | 过程 | 结果 |
|---|---|---|
| 直接让 AI 写代码 | "帮我加个 X 功能" → AI 直接改文件 | 意图只存在于对话里，下次上下文丢失；无从复查"是否实现了我要的东西" |
| **Spec Kit** | 先把 **WHAT/WHY** 固化成 `spec.md` → 澄清歧义 → 再谈 **HOW**（`plan.md`）→ 拆成可执行 `tasks.md` → 逐条实现 | 每一步都有**落盘产物**；需求、设计、任务、实现四者可交叉核对 |

**核心主张**：把"想清楚了没有"和"写对了没有"分成两个阶段，中间用**门禁**卡住。

### 1.3 三件套（理解这套东西的关键）

Spec Kit 由三层构成，缺一不可：

| 层 | 内容 | 在本仓库的位置 | 作用 |
|---|---|---|---|
| **斜杠命令** | 10 个 `.md` 提示词 | `.codebuddy/commands/speckit.*.md` | 定义**流程**；本身不含代码逻辑 |
| **PowerShell 脚本** | 6 个 `.ps1` | `.specify/scripts/powershell/` | 提供**状态解析**（当前是哪个功能、路径在哪、产物齐不齐） |
| **模板** | 5 个 `.md` | `.specify/templates/` | 定义**产物骨架**（spec/plan/tasks/checklist/constitution） |

> 命令不"执行"任何东西——它是一段给 AI 代理的指令，告诉代理"按这个顺序做这些事，中途调这个脚本拿路径"。
> 真正读写的，是 AI 代理本身。

### 1.4 非目标

| 不做 | 说明 |
|---|---|
| 替代 Git | 不做版本控制；分支/提交由你和扩展钩子负责 |
| 自动写对代码 | 它组织流程，不保证实现质量 |
| 跨功能状态管理 | 一个工作区同时只有一个"当前功能"（见 3.4） |
| 强制测试 | 测试任务**默认不生成**，除非 spec 明确要求或你要 TDD（`speckit.tasks.md` 第 143 行） |

---

## 2. 本仓库的安装实况

### 2.1 安装参数

来源：`.specify/init-options.json`

```json
{
  "ai": "codebuddy",
  "allow_symlinks": false,
  "feature_numbering": "sequential",
  "here": true,
  "integration": "codebuddy",
  "script": "ps",
  "speckit_version": "1.2.0"
}
```

要点：

- `integration: codebuddy` → 命令安装到 CodeBuddy 的斜杠命令目录
- `script: ps` → 使用 PowerShell 脚本（**不是** sh；本仓库 2026-10-14 从 `sh` 切换而来）
- `feature_numbering: sequential` → 目录用 `001-`/`002-` 顺序号，不用时间戳
- `here: true` → 直接初始化在仓库根，未新建子目录

### 2.2 目录地图

```
UE5AIRead/
├── .codebuddy/
│   └── commands/                     ← 斜杠命令定义（10 个）
│       ├── speckit.constitution.md
│       ├── speckit.specify.md
│       ├── speckit.clarify.md
│       ├── speckit.plan.md
│       ├── speckit.tasks.md
│       ├── speckit.analyze.md
│       ├── speckit.checklist.md
│       ├── speckit.implement.md
│       ├── speckit.converge.md
│       └── speckit.taskstoissues.md  （已废弃，见 5.10）
└── .specify/
    ├── init-options.json             ← 安装参数（2.1）
    ├── integration.json              ← 集成状态与 settings（script 等）
    ├── .gitignore                    ← 忽略 feature.json 等运行态文件
    ├── memory/
    │   └── constitution.md           ← 项目章程（宪法）
    ├── scripts/powershell/           ← 6 个脚本
    │   ├── common.ps1                ← 公共库（路径解析、模板解析、feature.json 读写）
    │   ├── check-prerequisites.ps1   ← 前置检查（命令最常用）
    │   ├── create-new-feature.ps1    ← 建功能目录 + 命名
    │   ├── setup-plan.ps1            ← plan 阶段准备
    │   ├── setup-tasks.ps1           ← tasks 阶段准备
    │   └── resolve-template.ps1      ← 模板解析（含 preset/extension 合成）
    ├── templates/                    ← 5 个模板
    │   ├── spec-template.md
    │   ├── plan-template.md
    │   ├── tasks-template.md
    │   ├── checklist-template.md
    │   └── constitution-template.md
    ├── integrations/                 ← 集成清单（记录受管文件与其哈希）
    │   ├── codebuddy.manifest.json
    │   └── speckit.manifest.json
    └── workflows/
        ├── workflow-registry.json
        └── speckit/workflow.yml      ← "Full SDD Cycle" 编排（见第 7 节）
```

### 2.3 当前状态（**动手前必读**）

| 项 | 现状 | 影响 |
|---|---|---|
| `specs/` 目录 | **不存在** | 还没跑过任何功能；第一条 `/speckit.specify` 会创建它 |
| `.specify/memory/constitution.md` | **仍是未填写的模板** | ⚠️ `/speckit.plan` 的 **Constitution Check 门禁无内容可卡** —— **正式使用前请先跑 `/speckit.constitution`** |
| `.specify/extensions.yml` / `extensions/` | **不存在** | 所有扩展钩子静默跳过 → `/speckit.specify` **不会自动创建 git 分支**（编号完全由目录扫描决定） |
| `.specify/presets/` | **不存在** | 模板走内置路径；无需 Python/PyYAML（仅当装了 preset 才需要，`common.ps1` 第 618-620 行） |
| 仓库 git 历史 | 2026-10-13 曾提交过一版定制章程（提交 `979f98c`、`a239007`） | 若想取回：`git show HEAD:.specify/memory/constitution.md`（当前工作区已被 1.2.0 模板覆盖） |

### 2.4 安装 / 升级 / 修复

```powershell
# 安装（已完成，此处备查）
uv tool install specify-cli --from git+https://github.com/github/spec-kit.git

# 自检：列出可用的编码代理集成，并确认 CLI 就绪
specify check

# 在已有项目里升级/重装集成（diff-aware，会比对哈希，避免覆盖你改过的文件）
specify integration upgrade codebuddy --script ps

# 查看项目集成状态（只读，不改文件）
specify integration status

# 切换脚本类型（sh / ps / py）
specify integration upgrade codebuddy --script sh
```

> **注意（本仓库踩过）**：`specify init --here --integration codebuddy` 会做**代理检测**，
> 找不到 `codebuddy` **CLI** 就报 `Agent Detection Error` 直接退出。
> 只装了 CodeBuddy IDE 时，加 `--ignore-agent-tools` 跳过检测；集成文件照样会装。

---

## 3. 核心概念与产物关系

### 3.1 五层产物

| 层 | 产物 | 回答的问题 | 生成命令 |
|---|---|---|---|
| 0 | `.specify/memory/constitution.md` | **不可动摇的原则是什么** | `/speckit.constitution` |
| 1 | `specs/<NNN>-<slug>/spec.md` | **要做什么、为什么**（WHAT/WHY，不谈技术） | `/speckit.specify` |
| 2 | `plan.md` + `research.md` + `data-model.md` + `contracts/` + `quickstart.md` | **怎么做**（技术选型、结构、契约） | `/speckit.plan` |
| 3 | `tasks.md` | **拆成哪些可执行步骤** | `/speckit.tasks` |
| 4 | 实际代码/文档 + `tasks.md` 勾选态 | **做完了没有** | `/speckit.implement` |

### 3.2 依赖与门禁

```
/speckit.constitution ──► constitution.md
                              │
                              ▼（plan 阶段的 GATE）
/speckit.specify ──► spec.md ──► /speckit.clarify（澄清，建议在 plan 前跑完）
                              │
                              ▼
                        /speckit.plan ──► plan.md + research.md + data-model.md + contracts/ + quickstart.md
                              │                （Constitution Check 门禁：Phase 0 前必须过，Phase 1 后复检）
                              ▼
                        /speckit.tasks ──► tasks.md
                              │
              ┌───────────────┼───────────────┐
              ▼               ▼               ▼
      /speckit.checklist  /speckit.analyze  /speckit.implement
       （需求质检清单）    （三方一致性报告）  （执行；checklist 有未勾选项则 STOP）
                                                  │
                                                  ▼
                                          /speckit.converge（追加缺口任务，APPEND-ONLY）
```

### 3.3 目录与命名规则

所有功能落在仓库根的 **`specs/`** 下，目录名 = **`<前缀>-<slug>`**。

| 项 | 规则 | 出处 |
|---|---|---|
| 前缀 | `sequential` 模式下为 **3 位零填充序号** `001`、`002`…（`'{0:000}'`） | `create-new-feature.ps1` 第 247 行 |
| 序号来源 | 扫描 `specs/` 下现有目录，取最大数字 **+1**；识别 `^(\d{3,})-`（≥3 位都认，超过 999 变 4 位） | 同上 第 233-238 行 |
| slug 来源 | 从描述里抽词：去停用词（`i/a/the/to/add/want…`）→ ASCII 词需 ≥3 字符（大写缩写例外）→ **Unicode 词（中文）不论长短都保留** → 取前 **3** 个（若恰好 4 个则取 4 个） | 同上 第 150-198 行 |
| 冲突处理 | 目录已存在 → 报错退出（除非 `-AllowExistingBranch`）；`-Number` 与已有前缀冲突会**自动顺延并告警** | 同上 第 291-298 行 |
| 长度上限 | 分支名 ≤ **244 字节**（GitHub 限制），超长按字节截断并告警 | 同上 第 17 行 |
| 是否建分支 | **脚本不建分支**。分支由 `before_specify` 钩子创建；本仓库无 `extensions.yml` → **不建分支** | `speckit.specify.md` 第 74-78 行 |

#### ⚠️ 中文描述的命名陷阱（本仓库实测）

`create-new-feature.ps1 -DryRun` 实跑结果（`-DryRun` 只计算不落盘）：

| 描述 | 生成的目录名 |
|---|---|
| `为文档库增加产物变更摘要生成器` | **`001-为文档库增加产物变更摘要生成器`** ← 整句中文被当成**一个词** |
| `docs changelog summary 扫描 docs 下产物更新记录并汇总` | **`001-docs-changelog-summary`** ✅ |
| `-ShortName 'docs-changelog'` + 中文描述 | **`001-docs-changelog`** ✅ |

**结论**：中文描述不会报错，但会生成**又长又难读**的目录名（还可能撞 244 字节上限）。
**建议**：描述开头放 2–4 个**英文关键词**，中文写在后面；或显式指定 `-ShortName`。

### 3.4 `.specify/feature.json`：跨命令握手的唯一状态

斜杠命令之间**不通过对话传上下文**，而是通过一个文件：

- 由 `/speckit.specify` 写入，内容指向"当前功能目录"
- 后续所有命令（clarify/plan/tasks/analyze/checklist/implement/converge）都从它（或环境变量）读当前功能
- 查找优先级：环境变量 `SPECIFY_FEATURE_DIRECTORY` > `.specify/feature.json` > 报错退出（`common.ps1` 第 161-220 行）
- 该文件被 `.specify/.gitignore` 忽略（运行态，不入库）

> **这意味着：一个工作区同时只能有"一个当前功能"。** 想并行做两个功能，得靠 `SPECIFY_FEATURE_DIRECTORY` 环境变量切换。

---

## 4. 命令总览

| 命令 | 用途 | 参数 | 前置要求 | 主要产出 |
|---|---|---|---|---|
| `/speckit.constitution` | 创建/修订项目章程 | 可选（原则内容） | 无 | `.specify/memory/constitution.md` |
| `/speckit.specify` | 由描述生成功能规范 | **必填**功能描述 | 无 | `spec.md` + `checklists/requirements.md` + `feature.json` |
| `/speckit.clarify` | 澄清 spec 歧义并回写 | 可选 | 已跑 `specify` | 就地改 `spec.md`（追加 `## Clarifications`） |
| `/speckit.plan` | 生成实现计划与设计产物 | 可选（技术栈提示） | spec 存在 | `plan.md`、`research.md`、`data-model.md`、`contracts/`、`quickstart.md` |
| `/speckit.tasks` | 按用户故事拆任务 | 可选 | `plan.md` + `spec.md`（脚本强校验） | `tasks.md` |
| `/speckit.analyze` | 三方一致性**只读**分析 | 可选 | 完整 `tasks.md` | **不写文件**，输出报告 |
| `/speckit.checklist` | 生成"需求的单元测试"式清单 | 可选（领域） | `spec.md` | `FEATURE_DIR/checklists/<domain>.md` |
| `/speckit.implement` | 按 `tasks.md` 执行实现 | 可选 | `tasks.md` 完整 | 代码/文档改动 + 勾选 `[X]` |
| `/speckit.converge` | 找"代码 vs 规范"缺口并追加任务 | 可选 | 已跑 `implement` | **仅追加** `## Phase N: Convergence` |
| `/speckit.taskstoissues` | ⚠️ **已废弃**：tasks → GitHub Issues | 可选 | `tasks.md` | GitHub Issues |

**本仓库无 `.specify/extensions.yml`** → 所有命令的 "Pre/Post-Execution Hooks" 段落为空操作，可忽略。

---

## 5. 主流程逐步详解（含例子）

> 下面所有 `specs/…` 产物均为**演示内容**（本仓库尚无 `specs/` 目录），
> 但命令名、参数、脚本调用方式、产物路径都已对照仓库内文件核实。

### 5.1 `/speckit.constitution` —— 立规矩

**做什么**：把项目的不可动摇原则写进 `.specify/memory/constitution.md`。全文覆盖写（`speckit.constitution.md` 第 123、142 行）。

**范围守卫（硬规则）**：只准写 `constitution.md`。**MUST NOT** 创建或修改任何源码、路由、测试、部署文件；若你塞给它功能需求，它必须抽成 "deferred intent" 放进 `Next Actions` 并建议你改用 `/speckit.specify`（第 19-34 行）。

**版本规则**：严格 SemVer —— MAJOR = 不兼容的删除/重定义，MINOR = 新增/扩写，PATCH = 澄清/措辞（第 96-100 行）。

**例**：

```
/speckit.constitution 定稿本项目章程：引擎源码只读；文档产物只写 docs/；数字断言必须可复算
```

产物（演示）：

```markdown
# UE5AIRead 项目章程

## Core Principles

### I. 引擎源码只读，产物单向流入 docs/（NON-NEGOTIABLE）
- 引擎安装根下的一切文件 MUST 视为只读……
- 文档产物 MUST 只写入仓库根的 docs/……

### II. 数字可复算
- 计数类断言 MUST 在产物末尾「取数说明」节给出取数方式……
```

> **本仓库特别提醒**：第一次正式使用前**务必先跑这条**。
> 当前 `constitution.md` 是空模板 → `/speckit.plan` 的 Constitution Check 门禁形同虚设。

---

### 5.2 `/speckit.specify` —— 说清要什么

**做什么**：把一句自然语言描述变成结构化规范。一次调用**只建一个功能**（第 109 行）。

**流程**（第 80-106、146 行）：

1. 从描述生成 2–4 词短名 → 建目录 + `spec.md` + `.specify/feature.json`
2. 按 `spec-template.md` 填 spec
3. 顺带生成 `checklists/requirements.md`（需求质量自检清单）
4. 最多 3 轮自校验修正

**硬规则**：

- 描述**必填**，为空直接 ERROR
- 只写 **WHAT / WHY**，不写 **HOW**（不得出现技术选型）
- **`[NEEDS CLARIFICATION]` 全 spec 最多 3 个**，超出只保留最关键的 3 个，其余自行合理推断；优先级 scope > security/privacy > UX > 技术细节（第 128、201、299-303 行）

**例**（描述开头放英文关键词，避免 3.3 的命名陷阱）：

```
/speckit.specify docs changelog summary 扫描 docs/ 下各产物的「更新记录」节，汇总为 docs/_meta/changelog.md
```

产物路径（`create-new-feature.ps1 -DryRun` 实测）：`specs/001-docs-changelog-summary/spec.md`

产物节选（演示）：

```markdown
# Feature Specification: 文档库变更摘要生成

**Feature Branch**: `001-docs-changelog-summary`
**Status**: Draft
**Input**: 扫描 docs/ 下各产物的「更新记录」节，汇总为 docs/_meta/changelog.md

## User Scenarios & Testing *(mandatory)*

### User Story 1 - 一键生成变更摘要 (Priority: P1)

作为文档维护者，我想在批量产出后一次性看到"这一轮都改了什么"，
而不必逐篇打开 69 篇产物翻「更新记录」。

**Why this priority**: 这是该功能的唯一核心价值，单独交付即可使用。

**Independent Test**: 对 docs/ 跑一次生成，检查 changelog.md 是否覆盖全部
带「更新记录」节的产物。

**Acceptance Scenarios**:
1. **Given** docs/ 下有 46 篇产物带「更新记录」，**When** 运行生成器，
   **Then** changelog.md 恰好收录这 46 篇的全部条目，条数可复算。
2. **Given** 某篇产物无「更新记录」节，**When** 运行生成器，
   **Then** 该篇不出现（而非报错）。

### Edge Cases
- 「更新记录」节存在但为空 → 如何处理？
- 同一天多条记录 → 是否合并？

## Requirements *(mandatory)*

### Functional Requirements
- **FR-001**: 系统 MUST 递归扫描 docs/ 下全部 `.md`
- **FR-002**: 系统 MUST 只收录含 `## 更新记录` 节的产物
- **FR-003**: 输出 MUST 按日期倒序，同日期按产物路径排序

## Success Criteria *(mandatory)*

### Measurable Outcomes
- **SC-001**: 对当前 docs/ 运行，输出条目数与"含更新记录节的产物数"一致（可复算）
- **SC-002**: 全程只读 docs/，除目标文件外零写入
```

---

### 5.3 `/speckit.clarify` —— 把模糊处问清楚

**做什么**：扫描 spec 里的歧义，**一次问一个问题**，每个答案**立即回写** spec。

**硬规则**：**整个会话最多 5 个问题**；不得提前泄露后续问题；用户说 `stop`/`done`/`proceed` 必须停（第 126、137、175、229、231 行）。必须在 `/speckit.plan` **之前**跑完（第 56 行）。

**回写格式**（第 181-183、206-223 行）——只允许新增这两个标题：

```markdown
## Clarifications

### Session 2026-10-14

- Q: 同一天多条更新记录如何呈现？ → A: 合并到同一日期小节，按产物路径排序
- Q: 「更新记录」节存在但为空时？ → A: 跳过该产物，不计入条数
```

**例**：

```
/speckit.clarify 聚焦输出格式与空节处理
```

---

### 5.4 `/speckit.plan` —— 定怎么做

**做什么**：读 spec + 章程 + plan 模板，产出实现计划与设计产物。

**流程**（第 58-67、131、155、160 行）：

1. 跑 `.specify/scripts/powershell/setup-plan.ps1 -Json` 拿路径
2. 填 `Technical Context`
3. **Constitution Check 门禁** —— Phase 0 前必须通过，Phase 1 后复检；门禁失败或仍有未解决澄清 → **ERROR**
4. **Phase 0**：产出 `research.md`
5. **Phase 1**：产出 `data-model.md`、`contracts/`、`quickstart.md`（到 Phase 1 即结束）

**产物骨架**（`plan-template.md`）：

```
# Implementation Plan: [FEATURE]
## Summary
## Technical Context      ← 每项都可写 "or NEEDS CLARIFICATION"
## Constitution Check     ← GATE: Must pass before Phase 0 / Re-check after Phase 1
## Project Structure      ← 给出 Documentation / Source Code 两棵树 + Structure Decision
## Complexity Tracking    ← 仅当 Constitution Check 有违规时才填
```

**例**：

```
/speckit.plan PowerShell 脚本实现，不引入新依赖；输出 Markdown，无网络
```

产物节选（演示）：

```markdown
## Technical Context
- **Language/Version**: PowerShell 5.1（Windows 内置）+ 7.x 兼容
- **Primary Dependencies**: 无（仅用 .NET BCL）
- **Storage**: 文件系统（读 docs/，写 docs/_meta/changelog.md）
- **Testing**: 手工验证 + 与 `verify-refs.ps1` 相同的"计数可复算"思路
- **Project Type**: single（脚本 + 文档）

## Constitution Check
- [x] 引擎源码只读 —— 本功能不触碰引擎目录
- [x] 产物只写 docs/ —— 输出落在 docs/_meta/changelog.md
- [x] 数字可复算 —— SC-001 要求条目数可复算

## Structure Decision
脚本置于 `.codebuddy/skills/ue-engine-docs-suite/ue-doc-verify/scripts/`（与既有校验脚本同址）
```

---

### 5.5 `/speckit.tasks` —— 拆成能勾选的步骤

**做什么**：按**用户故事**组织任务，产出 `tasks.md`。

**硬规则**：

- 任务行格式**强制**：`- [ ] [TaskID] [P?] [Story?] Description with file path`；
  Phase 1/2/Polish **不加** `[Story]`，用户故事 phase **必须加**（第 147-164 行）
- 前置：`plan.md` + `spec.md` 缺一不可（`setup-tasks.ps1` 第 35-47 行强校验）
- **测试任务默认不生成** —— 只有 spec 明确要求或你要求 TDD 才加（第 143 行）

**产物骨架**（`tasks-template.md`）：

```
# Tasks: [FEATURE NAME]
## Format: [ID] [P?] [Story] Description
## Path Conventions
## Phase 1: Setup
## Phase 2: Foundational   ← ⚠️ CRITICAL：本 phase 完成前，任何用户故事不得开工
## Phase 3..N: User Story …
## Phase N: Polish & Cross-Cutting
## Dependencies & Execution Order
## Implementation Strategy
```

**例**（演示）：

```markdown
## Phase 1: Setup
- [ ] T001 建立脚本骨架 `.codebuddy/.../scripts/gen-changelog.ps1`

## Phase 2: Foundational
- [ ] T002 [P] 实现「更新记录」节解析函数（含空节处理）到 `gen-changelog.ps1`

## Phase 3: User Story 1 - 一键生成变更摘要 (P1)
- [ ] T003 [US1] 实现 docs/ 递归扫描与筛选，输出到 `docs/_meta/changelog.md`
- [ ] T004 [US1] 按日期倒序 + 路径排序输出
```

---

### 5.6 `/speckit.checklist` —— 给"需求本身"做质检

**做什么**：生成 `FEATURE_DIR/checklists/<domain>.md`，条目检查的是**需求写得对不对**，不是"实现能不能跑"。

**硬规则**（第 31、144、221、234 行）：

- **MUST NOT** 把生成的条目勾成 `[x]`
- ≥80% 条目须带**追溯引用**（如 `[Spec §2.1]`、`[Gap]`、`[Ambiguity]`）
- 候选 > 40 条时按风险裁剪
- 已存在的 checklist 文件 → **追加**并续编 `CHK` 号（第 136-144 行）

**例**：

```
/speckit.checklist 输出格式与只读保证
```

产物节选（演示）：

```markdown
## 只读与边界
- [ ] CHK001 是否明确声明了生成器除目标文件外不得写入任何路径？ [Spec §FR-004]
- [ ] CHK002 "空「更新记录」节"的处理是否给出了**唯一**可判定的行为？ [Ambiguity]
- [ ] CHK003 输出条目数的复算方式是否写成了一个可执行断言？ [Gap]
```

> 注意语义：这里的 `[x]` 表示"**评审者确认该需求质量合格**"，**不等于**实现完成
> —— `/speckit.implement` 不会、也不得修改这些标记（第 53、75-80 行）。

---

### 5.7 `/speckit.analyze` —— 三方一致性体检

**做什么**：对 `spec.md` / `plan.md` / `tasks.md` 做**只读**交叉检查，输出报告。

**硬规则**（第 54、113、243-247 行）：**STRICTLY READ-ONLY**（绝不写文件）、**绝不臆造缺失章节**、
宪法冲突一律判 CRITICAL、findings 表最多 50 行。

**例**：

```
/speckit.analyze
```

产物（演示，**不落盘**）：

```markdown
## Findings

| ID | 级别 | 类别 | 描述 | 位置 |
|---|---|---|---|---|
| F1 | CRITICAL | 宪法冲突 | 章程要求"产物只写 docs/"，而 tasks T005 计划写 `specs/…/out.md` | T005 vs 章程 §I |
| F2 | HIGH | 覆盖缺失 | spec FR-003 的"同日期排序"在 tasks 中无对应任务 | spec §FR-003 |
| F3 | MEDIUM | 不一致 | plan 写输出到 `docs/_meta/`，tasks T003 写 `docs/` | plan §Structure vs T003 |

## Next Actions
1. 修订 T005 输出路径
2. 为 FR-003 补任务
```

---

### 5.8 `/speckit.implement` —— 执行

**做什么**：按 `tasks.md` 的 phase 顺序实现，并把完成任务改成 `[X]`。

**门禁（重要）**：**checklist 有未勾选项 → 必须 STOP 并询问你**；经你同意才可继续；
且**不得修改**任何 checklist 标记（第 53、75-80 行）。

**顺序规则**：TDD 时测试先写、先失败；`models → services → endpoints`；
**Phase 2（Foundational）完成前，任何用户故事不得开工**（第 148 行；`tasks-template.md` 第 62、182-186 行）。

**例**：

```
/speckit.implement
```

代理会：跑 `check-prerequisites.ps1 -Json -RequireTasks -IncludeTasks` → 检查 checklist 门禁 →
逐 phase 执行 → 把 `tasks.md` 里完成的项改成 `[X]`。

---

### 5.9 `/speckit.converge` —— 找差值，追加任务

**做什么**：对比"**代码/制品现状**"与 `spec`/`plan`/`tasks`，找出四类缺口并**追加**任务：

| 类别 | 含义 |
|---|---|
| `missing` | 规范要求了、实际没做 |
| `partial` | 做了一半 |
| `contradicts` | 实际做法与规范矛盾 |
| `unrequested` | 做了但规范没要求 |

**硬规则**（第 69-79、204-227 行）：**APPEND-ONLY，绝不改写**——不改 spec/plan、
不改/删/重排任何既有任务、不碰应用代码；**已收敛时 `tasks.md` 必须逐字节不变**（不留空标题）；
任务 ID 沿用 `T{M+1:03d}` 且**永不复用**。

> 它**不是 diff 工具**：不看 git、不看分支、不看提交历史（第 64-65 行）。

**例**：

```
/speckit.converge
```

产物节选（演示）：

```markdown
## Phase 5: Convergence

- [ ] T012 [US1] 补 FR-003 的"同日期按路径排序"实现到 `gen-changelog.ps1`
- [ ] T013 为 SC-001 增加可复算断言（与 verify-refs.ps1 同风格）
```

---

### 5.10 `/speckit.taskstoissues` —— ⚠️ 已废弃

**不要用**。应改为：

```powershell
specify extension add github
# 然后用
/speckit.github.taskstoissues
```

若你仍跑它，它有**双重 CAUTION**（第 68-77 行）：必须先 `git config --get remote.origin.url`
且 remote 必须是 GitHub URL，**任何情况下都不得**在 remote 不匹配的仓库建 issue。

---

## 6. 端到端完整走查

**场景**：给文档库加一个"变更摘要生成器"。

| # | 你输入 | 代理做什么 | 落盘产物 | 检查点 |
|---|---|---|---|---|
| 0 | `/speckit.constitution 定稿本项目章程…` | 起草并覆盖写章程 | `.specify/memory/constitution.md` | 章节与版本页脚齐全 |
| 1 | `/speckit.specify docs changelog summary 扫描 docs/ 下产物「更新记录」节汇总` | 建目录、填 spec、生成需求清单 | `specs/001-docs-changelog-summary/spec.md`、`checklists/requirements.md`、`.specify/feature.json` | `specs/` 下出现 `001-…`；spec 里 `[NEEDS CLARIFICATION]` ≤ 3 |
| 2 | `/speckit.clarify 聚焦输出格式与空节处理` | 逐个问（≤5 问），即时回写 | 修改 `spec.md`（新增 `## Clarifications`） | 你的每个答案都在文件里 |
| 3 | `/speckit.plan 用 PowerShell，零新依赖` | Technical Context → Constitution Check → Phase 0/1 | `plan.md`、`research.md`、`data-model.md`、`contracts/`、`quickstart.md` | Constitution Check 全部勾上；无 ERROR |
| 4 | `/speckit.tasks` | 按用户故事拆任务 | `tasks.md` | 任务行格式合规；Phase 2 标 CRITICAL |
| 5 | `/speckit.checklist 输出格式与只读保证` | 生成质检清单 | `checklists/输出格式与只读保证.md` | 条目**未勾选**；带 `[Spec §X]` 追溯 |
| 6 | `/speckit.analyze` | 三方一致性只读体检 | **无文件** | 报告无 CRITICAL |
| 7 | `/speckit.implement` | 检查 checklist 门禁 → 逐 phase 执行 | 脚本/文档改动 + `tasks.md` 勾选 `[X]` | 门禁未过会 STOP 问你 |
| 8 | `/speckit.converge` | 找缺口、追加任务 | `tasks.md` 追加 `## Phase N: Convergence` | 无缺口时文件**逐字节不变** |
| 9 | `/speckit.implement` | 执行追加的任务 | 勾选 | 回到 8，直到无缺口 |

**最小可用路径**（不想用全部命令时）：

```
/speckit.constitution → /speckit.specify → /speckit.plan → /speckit.tasks → /speckit.implement
```

其余四个（clarify / checklist / analyze / converge）是**可选增强**。

---

## 7. 工作流编排（`workflow.yml`）

`.specify/workflows/speckit/workflow.yml` 是一个**把命令串成带人工门禁的流水线**（"Full SDD Cycle" v1.0.1）。

| 项 | 值 |
|---|---|
| 输入 | `spec`（string，**必填**，"Describe what you want to build"）、`integration`（默认 `auto`） |
| 步骤 | `specify` → **gate `review-spec`**（approve/reject，reject 即 abort） → `plan` → **gate `review-plan`** → `tasks` → `implement` |
| 与命令的关系 | 每一步的 `command:` 就是斜杠命令名；工作流是它们的**上层调度器**，不改变命令行为 |
| 注册表 | `.specify/workflows/workflow-registry.json`（记录 `speckit` / source `bundled`） |

**运行**：

```powershell
# 列出已安装的工作流
specify workflow list

# 查看步骤图
specify workflow info speckit

# 运行（输入用 key=value）
specify workflow run speckit -i spec="docs changelog summary 生成器"

# 中途被门禁暂停/失败后恢复
specify workflow resume
specify workflow status
```

**什么时候用工作流**：你想要"**每一步停下等人点头**"的自动化。
**什么时候别用**：想灵活跳步、想单独用 clarify/analyze/checklist —— 这些**不在**工作流里，手工逐个跑更自在。

> 注意：`specify workflow` 由 **CLI** 驱动，不依赖 CodeBuddy 的斜杠命令
> （工作流内部通过 `integration: auto` 派发到已安装的集成）。

---

## 8. CLI 参考

| 命令组 | 常用子命令 | 用途 |
|---|---|---|
| `specify init` | `--here` / `--integration <k>` / `--script sh\|ps\|py` / `--force` / `--non-interactive` / `--ignore-agent-tools` | 初始化项目 |
| `specify check` | — | 环境自检（列出可用编码代理集成） |
| `specify integration` | `install` / `upgrade` / `status` / `list` / `switch` / `uninstall` | 管理编码代理集成（**diff-aware**，不会盲覆你改过的文件） |
| `specify preset` | `list` / `add` / `remove` / `resolve` / `search` | 管理模板预设（本仓库未用） |
| `specify extension` | `add` / `list` / `remove` | 管理扩展（如 `github`） |
| `specify workflow` | `run` / `resume` / `status` / `list` / `info` | 编排工作流（第 7 节） |
| `specify artifact` | `list` / `info` / `lookup` | 反查"这个命令/模板实际由哪一层解析出来的" |
| `specify self` | `check` / `update` | 管理 CLI 自身（升级到新版本） |
| `specify mcp` | — | 实验性 MCP server（stdio） |

**本仓库已实跑过的**：

```powershell
specify --version                 # → specify 1.2.0
specify check                     # → Specify CLI is ready to use!
specify integration upgrade codebuddy --script ps   # sh → ps
specify integration status        # → Integration status: OK（Modified/Missing 均为 0）
```

---

## 9. 硬规则与上限汇总

**执行环境**

| # | 事实 |
|---|---|
| 1 | 脚本是 **pwsh** 风格，但刻意兼容 Windows PowerShell 5.1 / .NET Framework（`common.ps1` 第 60-62 行） |
| 2 | 所有写文件都用 **UTF-8 无 BOM**（`create-new-feature.ps1` 第 310 行等） |
| 3 | `-Json` 模式下：进度/告警走 **stderr**，stdout 保持纯 JSON（`setup-plan.ps1` 第 53-58 行） |
| 4 | **单引号参数**要转义：`'I'\''m Groot'` 或改用双引号（多个命令都写了这条） |
| 5 | 路径解析顺序：环境变量 `SPECIFY_INIT_DIR` → 向上找含 `.specify/` 的目录 → 脚本位置回退（`common.ps1` 第 7-97 行） |

**内容与流程**

| # | 规则 | 出处 |
|---|---|---|
| 6 | `[NEEDS CLARIFICATION]` 全 spec **最多 3 个** | `speckit.specify.md` 第 128 行 |
| 7 | `/speckit.clarify` 整个会话**最多 5 个问题**，一次一个 | `speckit.clarify.md` 第 126 行 |
| 8 | 任务行格式强制 `- [ ] [TaskID] [P?] [Story?] Description with file path` | `speckit.tasks.md` 第 147-164 行 |
| 9 | 测试任务**默认不生成**（除非 spec 要求或要 TDD） | `speckit.tasks.md` 第 143 行 |
| 10 | `/speckit.implement`：checklist 有未勾选 → **STOP 询问**；不得改标记 | `speckit.implement.md` 第 53、75-80 行 |
| 11 | `/speckit.checklist` **MUST NOT** 把条目勾成 `[x]`；≥80% 条目带追溯引用 | `speckit.checklist.md` 第 31、221 行 |
| 12 | `/speckit.analyze` **NEVER modify files**；findings 表 ≤50 行 | `speckit.analyze.md` 第 54、243-247 行 |
| 13 | `/speckit.converge` **APPEND-ONLY, NEVER REWRITE**；已收敛时 tasks.md 逐字节不变 | `speckit.converge.md` 第 69-79 行 |
| 14 | `/speckit.constitution` 只准写 constitution.md，功能诉求转 deferred intent | `speckit.constitution.md` 第 19-34 行 |
| 15 | `/speckit.plan` 的 Constitution Check 是**门禁**，失败 → ERROR | `speckit.plan.md` 第 160 行 |
| 16 | 分支名 ≤ **244 字节**；spec 目录名与分支名互相独立 | `create-new-feature.ps1` 第 17 行 |

---

## 10. 与本仓库既有约定的关系

⚠️ **必读**：本仓库已有一套**严格的文档规范**（`_meta/convention.md`），Spec Kit 的工作方式与它有一处**真实冲突**，必须说清。

### 10.1 兼容的部分

| 本仓库约定 | 与 Spec Kit 的关系 |
|---|---|
| 引擎源码只读、写入仅限 `docs/` | Spec Kit 的 `specs/` 与 `.specify/` 都在**仓库内**，不碰引擎目录 → **不冲突** |
| 产物只写入 `docs/` | 用 Spec Kit 做**文档库自身**的演进（产出写到 `docs/`）时**不冲突** |
| 数字类断言必须可复算（`convention.md` §4.2） | 与 Spec Kit 的"验收标准要可度量"（SC-xxx）**理念一致**，可互相引用 |
| 引用格式（`文件：` + `行 A-B：`） | Spec Kit 产物里引用引擎代码时，**同样适用该规范** |

### 10.2 ⚠️ 冲突点：`/speckit.implement` 会写"应用代码"

- 本仓库章程（`convention.md`）写死：**引擎目录只读**，且产物**只写 `docs/`**
- 而 `/speckit.implement` 的职责就是**按 tasks 改文件**（含源码、测试、`.gitignore` 等）

**处置建议**：

| 用法 | 安全性 |
|---|---|
| 用 Spec Kit 驱动 **`docs/` 与 `.codebuddy/skills/` 的演进** | ✅ 安全，产物落在仓库内 |
| 用 Spec Kit 做"生成引擎源码补丁"之类的任务 | ❌ **禁止** —— 会在 tasks 阶段就埋下"改引擎"的任务 |
| 需要举例引擎路径时 | 一律写 `Engine/...` 相对形式，**不写盘符**（`convention.md` §2 红线） |

**一句话**：把 Spec Kit 当作"**本仓库自身的开发流程**"，而不是"改引擎的工具"。

### 10.3 建议的第一次使用顺序

```powershell
# 1) 先立章程（当前是空模板，门禁形同虚设）
/speckit.constitution 定稿本项目章程：引擎源码只读；产物只写 docs/；数字断言必须可复算

# 2) 让章程与既有规范对齐（convention.md 是事实来源，章程不该另立一套）
#    把 convention.md 的硬规则抄进章程的 Core Principles / Governance

# 3) 再开始第一个功能
/speckit.specify docs changelog summary 扫描 docs/ 下产物「更新记录」节并汇总
```

---

## 11. 故障排查

| 现象 | 原因 | 处理 |
|---|---|---|
| CodeBuddy 里打 `/speckit.` 没有补全 | IDE 未重读命令目录 | **重启 IDE / 新建终端** |
| `specify` 命令找不到 | 工具目录不在 PATH | `uv tool update-shell`，或当前会话 `$env:PATH = "$env:USERPROFILE\.local\bin;$env:PATH"` |
| `specify init` 报 `codebuddy not found` | 只装了 IDE，没装 CodeBuddy CLI | 加 `--ignore-agent-tools`；或按 <https://www.codebuddy.cn/docs/cli/installation> 装 CLI |
| 命令里脚本报"无法加载文件，因为在此系统上禁止运行脚本" | PowerShell 执行策略 | `powershell -ExecutionPolicy Bypass -File <脚本>` |
| 脚本报 `Not a Spec Kit project (no .specify/ directory)` | 不在项目根，或 `.specify/` 被删 | `cd` 到含 `.specify/` 的目录；必要时 `specify integration upgrade` 重装 |
| 参数含单引号报错 | PowerShell 引号规则 | 用 `'I'\''m Groot'` 或改双引号 |
| 生成的目录名又长又怪（全中文） | slug 抽取保留了整句 Unicode 词 | 描述开头放英文关键词，或 `-ShortName 'xxx'` |
| `/speckit.plan` 的 Constitution Check 空的 | `constitution.md` 还是模板 | 先跑 `/speckit.constitution` |
| 想确认"这条命令到底用了哪个模板/脚本" | — | `specify artifact info <name>`、`specify preset resolve <name>` |
| `integration upgrade` 说"文件已被修改，拒绝升级" | 你改过受管文件 | 先备份改动，再 `--force` |

---

## 12. 速查卡

```text
【一次性】
/speckit.constitution <原则>          # 立章程（首次必做）

【主流程】
/speckit.specify <描述>               # 要什么（描述开头放英文关键词）
/speckit.clarify                      # 澄清（≤5 问，plan 之前跑完）
/speckit.plan <技术栈提示>            # 怎么做（含 Constitution 门禁）
/speckit.tasks                        # 拆任务
/speckit.implement                    # 执行（checklist 未勾完会停下问你）

【可选增强】
/speckit.checklist <领域>             # 给需求做质检清单
/speckit.analyze                      # 三方一致性只读体检
/speckit.converge                     # 找缺口、追加任务（只追加）

【产物位置】
specs/<NNN>-<slug>/
├── spec.md            ← WHAT/WHY
├── plan.md            ← HOW
├── research.md  data-model.md  contracts/  quickstart.md
├── tasks.md           ← 可勾选任务
└── checklists/
    ├── requirements.md      （specify 自动生成）
    └── <domain>.md          （checklist 生成）

.specify/memory/constitution.md   ← 章程
.specify/feature.json             ← 当前功能指针（被 gitignore）

【诊断】
specify check
specify integration status
specify workflow info speckit
specify artifact info speckit.plan
```

---

## 取数说明

| 断言 | 取数方式 |
|---|---|
| 斜杠命令 **10** 个 | `(Get-ChildItem ".codebuddy/commands" -File -Filter "speckit.*.md").Count` |
| PowerShell 脚本 **6** 个 | `(Get-ChildItem ".specify/scripts/powershell" -File -Filter "*.ps1").Count` |
| 模板 **5** 个 | `(Get-ChildItem ".specify/templates" -File -Filter "*-template.md").Count` |
| 目录名 `001-docs-changelog-summary` | `create-new-feature.ps1 -DryRun -Json 'docs changelog summary …'` 实跑（`-DryRun` 只计算、不落盘） |
| 各命令的硬规则与行号 | 逐文件通读 `.codebuddy/commands/speckit.*.md`，引用处已随文标注 `路径 第 N 行` |

---

## 相关文档

- `_meta/convention.md` —— 文档库唯一规范（路径写法、引用格式、数字断言的"取数说明"制度）
- `设计说明-UE5引擎文档技能套件.md` —— 文档库的技能套件设计与落地记录
- `00-索引.md` —— 全库产物索引
