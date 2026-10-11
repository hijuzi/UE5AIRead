---
name: ue-engine-docs
description: >
  编排 UE5 引擎源码技术文档的生成与维护：初始化文档库、写入统一规范、
  把任务路由到对应子技能、维护全库索引与校验状态。
  当用户提出"把 UE 引擎源码整理成文档""建一个 UE5 引擎知识库"
  "UE 引擎源码技术文档""给 AI 用的 UE 引擎文档""UE 源码文档怎么组织"，
  或意图笼统、未指明具体模块 / 类 / 流程时触发。
  触发词组合：UE 引擎/UE5 + 源码 + 文档/知识库/整理/梳理/组织。
  不适用：用户已明确指定模块名（走 ue-module-structure）、类名（走 ue-type-api）、
  机制或流程名（走 ue-flow-trace）；游戏工程源码分析（本套件只处理引擎源码，不处理游戏项目代码）；
  只想知道引擎装在哪或装了哪些版本（走 epic-engine-inventory）；
  修改引擎源码（本套件全程只读引擎源码）。
metadata:
  category: ue-engine-docs
  version: "1.0"
  platform: Windows
---

# UE5 引擎源码技术文档 · 总编排

把 UE5 引擎源码变成两件事：**给程序员读得懂的三级文档**，和**给 AI 检索得准的索引**。

本技能是总入口，负责立规范、建骨架、做路由。**它不亲自做分析。**

## 技能分工（先看这张表）

| 技能 | 唯一产物 | 何时用它 |
|---|---|---|
| **ue-engine-docs**（本技能） | `docs/` 初始化 + `00-索引.md` | 意图笼统，或要整套流程 |
| `ue-engine-inventory` | `docs/_meta/inventory.md` | 盘点模块、定首批批次 |
| `ue-module-structure` | `docs/modules/<模块>-结构.md` | 用户提到模块名 |
| `ue-type-api` | `docs/types/<类名>.md` | 用户提到类名 |
| `ue-flow-trace` | `docs/flows/<机制名>.md` | 用户提到机制 / 流程 |
| `ue-doc-verify` | `docs/_meta/quality-report.md` | 校验既有产物 |
| `ue-ai-index` | `docs/ai/ai-index.md` | 生成 AI 检索索引 |
| `ue-doc-sync` | — | **占位，本版未启用** |

## 适用判断

- **操作系统**：仅 Windows。
- **引擎源码可达**。若路径不存在则停止，不要猜路径：

```powershell
Test-Path "E:\EpicGames\UE_5.8\Engine\Source"
```

返回 `False` 时：改走 `epic-engine-inventory` 查本机引擎安装位置，拿到真实路径再继续。

- **不适用**：游戏项目源码分析、引擎安装位置查询、修改引擎源码。
- **只读红线的动作级要求**：用户要求改引擎源码时，除了拒绝，还**不得给出可直接应用的引擎源码补丁
  或写操作建议**；若其真实意图是理解某处实现，引导到只读路径（③ 类型 / ④ 流程）。

## 执行流程

### Step 1: 核对环境

读取 `docs/_meta/convention.md` 的「本机环境」块。文件不存在 → 跳到 Step 2（首次初始化）。

文件存在时做**两项**核对，缺一项都不算完成。

#### 1.1 版本与构建号

**首选**读引擎自带的 `Engine/Build/Build.version`：

```powershell
Get-Content "E:\EpicGames\UE_5.8\Engine\Build\Build.version" -Raw
```

版本锚点写作 `UE <MajorVersion>.<MinorVersion>.<PatchVersion> (Build <Changelist>)`。

**为什么首选它**：该文件随引擎本体存在，源码构建也有；而 Launcher Manifest 会漂移——
实测 2026-10-10 重装 UE 5.8 后，Manifest 里**该引擎的条目直接消失了**
（只剩同为 `E:\EpicGames\UE_5.8` 路径的 Fab / QuixelBridge 等插件条目），用 Manifest 查会得到空结果。

Manifest 作为**备用**来源（必须带 `-Encoding UTF8`，否则报 `无效的 JSON 基元`）：

```powershell
Get-ChildItem "$env:ProgramData\Epic\EpicGamesLauncher\Data\Manifests\*.item" |
    ForEach-Object { Get-Content $_.FullName -Raw -Encoding UTF8 | ConvertFrom-Json } |
    Where-Object { $_.TechnicalType -eq 'engines/ue5,engines' } |
    Select-Object AppName, AppVersionString, InstallLocation
```

**检查点**：解析出的版本构建号与 `convention.md` 记录一致。不一致时先分清是哪种变化：

| 变化 | 处理 |
|---|---|
| 小版本晋升（如 5.8.2 → 5.8.3） | 更新 `convention.md` 的版本锚点，并**同步全部产物的文档头**，然后继续 |
| 跨大版本 / 引擎安装路径变化 | **停下问用户**——文档基座变了，全部产物需重新评估 |

不要因为"版本号变了"就跳过，也不要静默改完不告知。文档头一旦与真实引擎不符，全库可信度归零。

#### 1.2 源码完整性（决定哪些技能可执行）

```powershell
.codebuddy\skills\ue-engine-docs-suite\ue-engine-docs\scripts\check-source.ps1 -SourceRoot "E:\EpicGames\UE_5.8\Engine\Source"
```

| `Verdict` | 含义 | 对后续的含义 |
|---|---|---|
| `Complete` | 存在 `.cpp`，源码完整 | 全部技能可执行，含 ④ 调用链追踪 |
| `HeadersOnly` | 0 个 `.cpp`，仅头文件安装 | ④ 不可执行；② 的「模块生命周期」写"本机不可判定"；⑤ 只能回查声明层 |

把结果写回 `convention.md` 的「源码形态」块（覆盖旧值并刷新复核日期）。

**检查点**：`convention.md`「源码形态」块里的 `.cpp` 数量与本次实测一致。不一致就更新那一块，
**不要改技能正文里的判定逻辑**。

> **这项检查不能省。** 本套件在 2026-10-10 曾因遗漏它，把"仅头文件安装导致的零命中"
> 误判成"模块没有入口类"，错误结论写进了产物之后才被发现。
> 任何"零命中"结论在下定论前，先确认证据源本身是否完整。

### Step 2: 初始化文档库（仅首次）

`docs/_meta/convention.md` 不存在时执行：

```powershell
New-Item -ItemType Directory -Force -Path `
    docs\_meta, docs\modules, docs\types, docs\flows, docs\ai | Out-Null
```

然后：

1. 把本技能的 `assets/convention-template.md` 复制为 `docs/_meta/convention.md`；
2. 用 Step 1 拿到的真实版本号与安装路径，替换模板里「本机环境」块的占位值；
3. 创建 `docs/00-索引.md`，写入标题与下面这张空表。

`00-索引.md` 索引表结构：

| 产物 | 类型 | 模块归属 | 生成技能 | 校验状态 |
|---|---|---|---|---|
| （待填充） | 模块/类型/流程 | | | 未校验 |

**检查点**：

```powershell
Test-Path docs\_meta\convention.md; Test-Path docs\00-索引.md
```

两条都返回 `True` 才继续。**不要跳过本步直接分析**——规范缺席会导致后续每篇产物格式各异，返工成本最高。

### Step 3: 路由

| 用户表达 | 路由到 | 若前置未满足 |
|---|---|---|
| 未指明粒度 / 要整套 | ① `ue-engine-inventory` | — |
| 提到模块名（`Core`、`Engine`…） | ② `ue-module-structure` | `_meta/inventory.md` 缺失 → 先跑 ① |
| 提到类名（`AActor`、`UWorld`…） | ③ `ue-type-api` | 同上 |
| 提到机制 / 流程（`GC`、Tick…） | ④ `ue-flow-trace` | 同上 |
| 要核对文档准不准 | ⑤ `ue-doc-verify` | 产物 < 10 篇时先告知用户意义有限 |
| 要 AI 检索索引 | ⑥ `ue-ai-index` | 产物 < 10 篇时先告知用户 |
| 要做某个模块但不在首批白名单 | 先跑 ① 确认该模块真实存在，再交 ② | — |

用户只说了"把 UE 引擎源码整理成文档"时：**不要立刻开始分析**。先跑 ① 拿到批次表，把批次表给用户看，确认后逐批推进。

### Step 4: 归档与索引

每完成一篇产物，更新 `docs/00-索引.md`：

- 追加行：产物文件名、类型、模块归属、生成技能、校验状态
- ⑤ 跑完后，把对应行校验状态改为 `已校验（YYYY-MM-DD）`
- ⑥ 跑完后追加 `ai/ai-index.md` 一行

**检查点**：产出行数与 `docs/` 下产物文件数一致：

```powershell
(Get-ChildItem docs\modules, docs\types, docs\flows -Recurse -File -Filter *.md).Count
```

### Step 5: 修正传播检查（改完任何"可检索事实"后必做）

对**可检索事实**（版本号、行数、模块数、路径写法、口令词）的修正，改完一处不等于改完——
必须全库反向检索旧值，确认技能目录与 `docs/` 产物中零残留：

```
search_content: pattern="<旧值>"
```

设计说明的历史记录小节允许保留旧值（那是留痕），其余位置残留即为漏改。

**为什么**：2026-10-10 的评估发现"修正传播不完整"模式出现过四轮——
每次修正都漏掉了同一事实在其他文件里的副本（详见设计说明第 18 节）。
**修正的最后一步永远是反向检索，不是保存文件。**

## 输入输出示例

**示例 1：笼统意图（最常见的正确路径）**

输入：`把 UE5 引擎源码整理成技术文档`

应做：Step 1 核对环境 → Step 2 初始化（若首次）→ Step 3 判定为"未指明粒度"→ 交 ① → 把 ① 产出的批次表呈现给用户 → 等确认。

不应做：直接开始读 `Engine/Source/Runtime/Core` 的头文件。

**示例 2：已指明粒度（不要抢子技能的活）**

输入：`分析一下 UE 的 Core 模块`

应做：确认 `_meta/inventory.md` 存在（不存在先跑 ①），然后交 ②。

不应做：本技能自己展开 Core 的目录结构——那会产出一份和 ② 格式不一致的重复文档。

**示例 3：路径不存在**

输入：`帮我梳理 E:\Engine\UE 的源码`

应做：`Test-Path` 得 `False` → 告知用户路径不存在，改走 `epic-engine-inventory` 查本机真实安装位置。

不应做：猜一个路径，或扫描整个 E 盘找引擎。

**示例 4：模块名不在白名单**

输入：`帮我分析 UE 的 Niagara 模块`

应做：先跑 ① 确认 `Niagara` 在扫描结果里（它属于 `Plugins/FX` 分组下的插件模块，不在首批白名单），告知用户它不在首批范围，问是否扩面。

不应做：直接开跑 ② 并在文档里凭空标注路径。

## 完成检查

- [ ] `docs/_meta/convention.md` 与 `docs/00-索引.md` 均已存在
- [ ] `convention.md` 记录的版本构建号与实际引擎一致
- [ ] 已按 Step 3 路由表分派，未越权做子技能的分析工作
- [ ] 笼统意图场景下，已先呈现批次表并等用户确认，未自行开跑
- [ ] `00-索引.md` 行数与 `docs/` 下产物数量一致
- [ ] 全程未对引擎目录执行任何写操作

## 常见问题

### Q: 为什么文档写在仓库根 `docs/`，而不是技能自己的 `references/`？

因为文档是交付资产，技能是可替换工具。放在 `docs/` 才能脱离技能被分享、被 git 追踪、被 review；而且规范文件需要一个所有技能都能稳定引用的固定路径，放在某个技能目录内会随安装位置失效。

### Q: 用户一次要求分析 5 个模块，怎么处理？

不要并发跑 ②。按 `references/subsystem-catalog.md` 的批次顺序串行推进，每批完成后让用户确认再进下一批。理由：后批次模块的文档要反向引用前批次（如 `Engine` 的文档引用 `Core` 的类型文档），顺序错了链接会断。

### Q: 用户明确要求文档写英文？

本套件规范锁定"中文为主 + 英文术语保留原名"。若用户强需求双语，先改 `docs/_meta/convention.md` 并记入变更记录，再继续——不要只在单篇产物里特例化。

### Q: `ue-doc-sync` 这个技能不存在，怎么办？

它是预留位。用户提出跨引擎版本维护需求时，告知本版未启用，可先按 `convention.md` 的版本锚点人工判断哪些产物受影响。

## 参考文件

- `assets/convention-template.md` —— 规范的结构模板，Step 2 复制为 `docs/_meta/convention.md` 后填环境值。
- `references/subsystem-catalog.md` —— 子系统分类规则、首批 10 个模块白名单、批次推进顺序、第二批候选。
