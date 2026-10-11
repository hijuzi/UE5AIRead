# UE 引擎文档套件 · 触发评估执行清单（分批版）

> 生成时间：2026-10-11　｜　来源：7 个技能的 `evaluation/trigger-cases.md`
> 用例 114 条 → 去重 **83 条独立输入** → 按"期望路由"分为 **10 批**，可一次跑一批。

## 一、怎么跑

1. **每条输入在全新会话中发送**——不要把两条输入发进同一个会话。
2. 原样粘贴"输入"列文字，**不附加任何提示**。
3. 把实际触发的技能记入"实际"列，"判定"列填 通过 / 失败。
4. 一批跑完，回填各技能 `trigger-cases.md` 的"实际/判定"列与"执行记录"表。
5. 建议顺序：**先跑批次 1**（最快，且立刻暴露泛化误触发），再 2 → 10。

> 判定口径：`实际` 与 `期望路由` 一致 = 通过；触发别的技能或**未触发** = 失败（未触发也要记）。
> 指标：Precision = 正确触发数 / 全部实际触发数；Recall = 正确触发数 / 应触发总数。

## 二、批次总览

| 批次 | 目的 | 条数 |
|---|---|---|
| 1 | 不该触发（泛化误触发 + 信息查询基线） | 6 |
| 2 | 主技能 ue-engine-docs | 11 |
| 3 | ① ue-engine-inventory | 7 |
| 4 | ② ue-module-structure | 15 |
| 5 | ③ ue-type-api | 12 |
| 6 | ④ ue-flow-trace | 7 |
| 7 | ⑤ ue-doc-verify | 10 |
| 8 | ⑥ ue-ai-index | 6 |
| 9 | 改道外部技能 epic-engine-inventory | 2 |
| 10 | 多解边界（允许两个技能，看是否追问/澄清） | 7 |

## 三、批次明细

### 批次 1 · 不该触发（泛化误触发 + 信息查询基线）（6 条）

| # | 类别 | 输入（原样发送） | 期望路由 | 覆盖用例 | 实际 | 判定 |
|---|---|---|---|---|---|---|
| 1 | 域外 | 把这段话翻译成英文 | 不触发本套件任何技能 | ue-ai-index/D4 , ue-doc-verify/D4 , ue-engine-docs/D4 , ue-engine-inventory/D4 , ue-flow-trace/D4 , ue-module-structure/D4 , ue-type-api/D4 |  |  |
| 2 | 域外 | 帮我写个 Python 脚本批量重命名文件 | 不触发本套件任何技能 | ue-ai-index/D1 , ue-doc-verify/D1 , ue-engine-docs/D1 , ue-engine-inventory/D1 , ue-flow-trace/D1 , ue-module-structure/D1 , ue-type-api/D1 |  |  |
| 3 | 域外 | 帮我优化这段 SQL 查询 | 不触发本套件任何技能 | ue-ai-index/D3 , ue-doc-verify/D3 , ue-engine-docs/D3 , ue-engine-inventory/D3 , ue-flow-trace/D3 , ue-module-structure/D3 , ue-type-api/D3 |  |  |
| 4 | 域外 | 解释一下 TCP 三次握手 | 不触发本套件任何技能 | ue-ai-index/D2 , ue-doc-verify/D2 , ue-engine-docs/D2 , ue-engine-inventory/D2 , ue-flow-trace/D2 , ue-module-structure/D2 , ue-type-api/D2 |  |  |
| 5 | 边界 | ai 目录下现在有什么 | 信息查询。**判定**：仅读现状回答且未重新生成索引 = 通过；重新生成 `ai-index.md` = 失败；未触发任何技能 = 通过（信息查询本身不要求加载） | ue-ai-index/B3 |  |  |
| 6 | 边界 | docs 目录下现在有几篇产物 | 信息查询，无需加载任何技能。**判定**：仅读现状回答且未启动全量校验 = 通过；启动全量校验或产出报告 = 失败 | ue-doc-verify/B3 |  |  |

### 批次 2 · 主技能 ue-engine-docs（11 条）

| # | 类别 | 输入（原样发送） | 期望路由 | 覆盖用例 | 实际 | 判定 |
|---|---|---|---|---|---|---|
| 1 | 正例 | UE 源码文档怎么组织比较好 | 主技能 | ue-engine-docs/P3 |  |  |
| 2 | 正例 | 把 UE5 引擎源码整理成技术文档 | 主技能（先核对环境 → 呈现批次表 → 等确认） | ue-engine-docs/P1 |  |  |
| 3 | 正例 | 帮我梳理一套 UE 引擎源码的文档体系 | 主技能 | ue-engine-docs/P4 |  |  |
| 4 | 正例 | 建一个 UE5 引擎知识库 | 主技能 | ue-engine-docs/P2 |  |  |
| 5 | 反例 | 把 UE 源码整理成文档 | 主技能 `ue-engine-docs` | ue-doc-verify/N4 |  |  |
| 6 | 反例 | 把 UE 源码整理成一套文档 | 主技能 `ue-engine-docs` | ue-flow-trace/N4 |  |  |
| 7 | 反例 | 把引擎源码整理成文档 | 主技能 `ue-engine-docs` | ue-type-api/N4 |  |  |
| 8 | 反例 | 更新一下全库目录索引 | 主技能 `ue-engine-docs`（`00-索引.md` 由主技能维护） | ue-ai-index/N1 |  |  |
| 9 | 边界 | 帮我看看 UE 源码 | 主技能（笼统兜底；不得直接开读源码） | ue-engine-docs/B1 |  |  |
| 10 | 边界 | 更新一下文档库的索引 | 主技能（维护动作不属任何子技能） | ue-engine-docs/B3 |  |  |
| 11 | 边界 | 这些模块的文档都做完了吗 | ① + 主技能（覆盖度属盘点/索引职责）；回答须引用 `inventory.md` 或 `00-索引.md`，不得凭印象 | ue-engine-inventory/B4 |  |  |

### 批次 3 · ① ue-engine-inventory（7 条）

| # | 类别 | 输入（原样发送） | 期望路由 | 覆盖用例 | 实际 | 判定 |
|---|---|---|---|---|---|---|
| 1 | 正例 | UE 5.8 源码里一共有多少个模块 | ① | ue-engine-inventory/P4 |  |  |
| 2 | 正例 | UE 引擎源码有哪些模块 | ①（盘点 + 批次） | ue-engine-inventory/P1 |  |  |
| 3 | 正例 | 哪些模块值得优先出文档 | ① | ue-engine-inventory/P3 |  |  |
| 4 | 正例 | 盘点一下 UE 源码的规模和文件数 | ① | ue-engine-inventory/P2 |  |  |
| 5 | 反例 | 引擎源码一共有哪些模块 | ① `ue-engine-inventory` | ue-module-structure/N3 |  |  |
| 6 | 边界 | 先做哪几个模块 | ①（批次界定属盘点职责） | ue-engine-inventory/B1 |  |  |
| 7 | 边界 | 重新盘点一下引擎 | ①（刷新 `inventory.md`） | ue-engine-inventory/B2 |  |  |

### 批次 4 · ② ue-module-structure（15 条）

| # | 类别 | 输入（原样发送） | 期望路由 | 覆盖用例 | 实际 | 判定 |
|---|---|---|---|---|---|---|
| 1 | 正例 | Core 模块的目录结构是什么 | ② | ue-module-structure/P5 |  |  |
| 2 | 正例 | Core.Build.cs 里有哪些依赖 | ② | ue-module-structure/P4 |  |  |
| 3 | 正例 | Engine 模块是怎么组织的 | ② | ue-module-structure/P2 |  |  |
| 4 | 正例 | RenderCore 依赖哪些模块 | ② | ue-module-structure/P3 |  |  |
| 5 | 反例 | Core 模块的目录结构 | ② `ue-module-structure` | ue-type-api/N2 |  |  |
| 6 | 反例 | Core 模块依赖哪些模块 | ② `ue-module-structure` | ue-engine-inventory/N2 |  |  |
| 7 | 反例 | Engine 模块依赖哪些模块 | ② `ue-module-structure` | ue-flow-trace/N2 |  |  |
| 8 | 反例 | 把 Core 模块的结构文档写一下 | ② `ue-module-structure` | ue-ai-index/N3 |  |  |
| 9 | 反例 | 分析一下 UE 的 Core 模块 | ② `ue-module-structure` | ue-engine-docs/N1 , ue-module-structure/P1 |  |  |
| 10 | 反例 | 写一篇 Engine 模块的结构文档 | ② `ue-module-structure` | ue-doc-verify/N1 |  |  |
| 11 | 边界 | Core 和 CoreUObject 是什么关系 | ②（模块间关系）；回答必须基于 `Build.cs` 依赖数据，不得凭印象 | ue-module-structure/B1 |  |  |
| 12 | 边界 | CoreUObject 模块里的 UObject 类 | ③（类型粒度优先）；若先走 ②，必须停在模块层面不展开类 API | ue-module-structure/B2 |  |  |
| 13 | 边界 | 分析 EnhancedInput 模块 | ②；路径必须是 `Engine/Plugins/EnhancedInput/Source/EnhancedInput`，不得写成 `Source/Runtime/EnhancedInput` | ue-module-structure/B3 |  |  |
| 14 | 边界 | 模块文档里的依赖关系画个图 | ②（结构与依赖属本技能）；若要求跨模块调用时序则改道 ④ | ue-module-structure/B4 |  |  |
| 15 | 边界 | 整理一下 Core 模块的文档 | ②（含模块名时子技能优先，即使出现"整理/文档"词） | ue-engine-docs/B2 |  |  |

### 批次 5 · ③ ue-type-api（12 条）

| # | 类别 | 输入（原样发送） | 期望路由 | 覆盖用例 | 实际 | 判定 |
|---|---|---|---|---|---|---|
| 1 | 正例 | UObject 能覆写哪些虚函数 | ③（扩展点列表，不展开调用链） | ue-type-api/P4 |  |  |
| 2 | 正例 | UWorld 有哪些 API | ③ | ue-type-api/P2 |  |  |
| 3 | 正例 | 分析一下 UE 的 AActor 类 | ③ | ue-type-api/P1 |  |  |
| 4 | 反例 | AActor 的继承链是什么 | ③ `ue-type-api` | ue-module-structure/N1 |  |  |
| 5 | 反例 | AActor 是怎么定义的 | ③ `ue-type-api` | ue-engine-docs/N2 |  |  |
| 6 | 反例 | AActor 有哪些可覆写的虚函数 | ③ `ue-type-api` | ue-flow-trace/N1 |  |  |
| 7 | 反例 | FName 是怎么定义的 | ③ `ue-type-api` | ue-engine-inventory/N3 , ue-type-api/P3 |  |  |
| 8 | 反例 | 分析 UObject 的公开 API | ③ `ue-type-api` | ue-ai-index/N4 |  |  |
| 9 | 反例 | 分析一下 UObject 的 API | ③ `ue-type-api` | ue-doc-verify/N2 |  |  |
| 10 | 边界 | TArray 的完整 API 列一下 | ③；按 FAQ 只列常用 API 并注明"完整 API 见头文件"，不得逐条罗列全部重载 | ue-type-api/B3 |  |  |
| 11 | 边界 | UClass 和 UStruct 有什么区别 | ③（类型对比）；各自继承链与用途写清即可 | ue-type-api/B1 |  |  |
| 12 | 边界 | 这个类的实现里都做了什么 | ③ 只给声明层结论；实现行为改道 ④，不得据头文件推断实现 | ue-type-api/B4 |  |  |

### 批次 6 · ④ ue-flow-trace（7 条）

| # | 类别 | 输入（原样发送） | 期望路由 | 覆盖用例 | 实际 | 判定 |
|---|---|---|---|---|---|---|
| 1 | 正例 | Actor 生命周期的调用链 | ④ | ue-flow-trace/P2 |  |  |
| 2 | 正例 | BeginPlay 是被谁调用的 | ④ | ue-flow-trace/P4 |  |  |
| 3 | 正例 | UObject 创建流程 | ④（已有产物可增量更新） | ue-flow-trace/P3 |  |  |
| 4 | 反例 | UE 的 GC 流程是怎么走的 | ④ `ue-flow-trace` | ue-engine-docs/N3 , ue-flow-trace/P1 , ue-type-api/N1 |  |  |
| 5 | 反例 | UObject 的创建流程 | ④ `ue-flow-trace` | ue-engine-inventory/N4 , ue-module-structure/N2 |  |  |
| 6 | 边界 | UE 的渲染流程 | ④ 但**不得硬追**：按技能示例 2 拆成可追踪子流程（如"RHI 命令提交""渲染线程帧调度"）让用户选 | ue-flow-trace/B1 |  |  |
| 7 | 边界 | 这个函数是怎么实现的 | ④（实现层）；但若源码形态为 `HeadersOnly` 必须记"本机不可判定"，不得推断 | ue-flow-trace/B4 |  |  |

### 批次 7 · ⑤ ue-doc-verify（10 条）

| # | 类别 | 输入（原样发送） | 期望路由 | 覆盖用例 | 实际 | 判定 |
|---|---|---|---|---|---|---|
| 1 | 正例 | 出一份文档质量报告 | ⑤（产出 `_meta/quality-report.md`） | ue-doc-verify/P4 |  |  |
| 2 | 正例 | 核对文档里的行号引用 | ⑤ | ue-doc-verify/P2 |  |  |
| 3 | 正例 | 文档和源码对不上吗 | ⑤ | ue-doc-verify/P3 |  |  |
| 4 | 反例 | 现有类型文档准不准 | ⑤ `ue-doc-verify` | ue-type-api/N3 |  |  |
| 5 | 反例 | 现有流程文档的行号对不对 | ⑤ `ue-doc-verify` | ue-flow-trace/N3 |  |  |
| 6 | 反例 | 校验 Core 模块文档的准确性 | ⑤ `ue-doc-verify` | ue-module-structure/N4 |  |  |
| 7 | 反例 | 校验一下现有文档 | ⑤ `ue-doc-verify` | ue-ai-index/N2 , ue-doc-verify/P1 |  |  |
| 8 | 反例 | 校验一下现有文档的行号 | ⑤ `ue-doc-verify` | ue-engine-docs/N4 |  |  |
| 9 | 边界 | 把质量报告里提到的问题文档重写一遍 | ⑤ 只修正事实错误并留痕，**不得**新增 / 重写内容；"重写"需求交回生产技能 | ue-doc-verify/B4 |  |  |
| 10 | 边界 | 检查一下 docs 有没有错误 | ⑤（"检查+文档"落入校验语义） | ue-doc-verify/B1 |  |  |

### 批次 8 · ⑥ ue-ai-index（6 条）

| # | 类别 | 输入（原样发送） | 期望路由 | 覆盖用例 | 实际 | 判定 |
|---|---|---|---|---|---|---|
| 1 | 正例 | 给文档库做一个检索入口 | ⑥ | ue-ai-index/P4 |  |  |
| 2 | 正例 | 让 AI 更好检索这些文档 | ⑥ | ue-ai-index/P3 |  |  |
| 3 | 正例 | 生成 AI 检索索引 | ⑥（先清点产物） | ue-ai-index/P1 , ue-doc-verify/N3 |  |  |
| 4 | 正例 | 做个 AI 用的索引 | ⑥ | ue-ai-index/P2 |  |  |
| 5 | 边界 | AI 怎么快速找到这些文档 | ⑥（正是本技能的目标问题） | ue-ai-index/B2 |  |  |
| 6 | 边界 | ai-index 覆盖了哪些模块 | ⑥（覆盖边界属本技能职责）；回答须引用产物第六节，不得外推 | ue-ai-index/B4 |  |  |

### 批次 9 · 改道外部技能 epic-engine-inventory（2 条）

| # | 类别 | 输入（原样发送） | 期望路由 | 覆盖用例 | 实际 | 判定 |
|---|---|---|---|---|---|---|
| 1 | 反例 | UE 装了哪些版本、装在哪个目录 | `epic-engine-inventory`（不在本套件，主技能应声明改道） | ue-engine-docs/N5 |  |  |
| 2 | 反例 | UE 装在哪、装了哪几个版本 | `epic-engine-inventory` | ue-engine-inventory/N1 |  |  |

### 批次 10 · 多解边界（允许两个技能，看是否追问/澄清）（7 条）

| # | 类别 | 输入（原样发送） | 期望路由 | 覆盖用例 | 实际 | 判定 |
|---|---|---|---|---|---|---|
| 1 | 边界 | BeginPlay 什么时候被调用 | 允许 ③（何时/时机）或 ④（谁调用）；跨类回答时必须落 ④ 并声明边界 | ue-flow-trace/B2 |  |  |
| 2 | 边界 | Core 模块的文档要不要更新 | 允许 ⑤（先校验出结论）或主技能；**不得**直接变成 ② 重写文档 | ue-doc-verify/B2 |  |  |
| 3 | 边界 | Core 模块有多大 | 允许 ①（规模）或 ②（结构）；两者都需引用 `engine-modules.json` 的真实数字，不得目测 | ue-engine-inventory/B3 |  |  |
| 4 | 边界 | UObject 的创建过程 | 允许 ③ 或 ④；若走 ③ 只写构造相关声明与时机，**不得**展开跨类调用链 | ue-type-api/B2 |  |  |
| 5 | 边界 | UObject 的生命周期 | 允许 ③（时机表）或 ④（调用链）；若走 ④ 必须有追踪边界四项 | ue-flow-trace/B3 |  |  |
| 6 | 边界 | 把 UObject 相关的都梳理一下 | 允许 ③ 或主技能追问粒度；**必须**在开跑前确认"UObject 相关"指类、流程还是模块 | ue-engine-docs/B4 |  |  |
| 7 | 边界 | 给文档做个索引 | 允许 ⑥ 或主技能追问；**必须**澄清是 `00-索引.md`（人看的目录）还是 `ai/ai-index.md`（AI 检索），不得默认选一个就开跑 | ue-ai-index/B1 |  |  |

