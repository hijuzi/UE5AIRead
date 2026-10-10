# ue-module-structure · 触发评估用例

> 用途：逐条在**独立会话**中把"输入"原样发给 AI，记录实际触发的技能。
> 判定：与"预期"列一致 = 通过；失败时记录实际行为。
> 指标：Precision = 正确触发数 / 全部实际触发数；Recall = 正确触发数 / 应触发总数。

## 正例（应触发本技能）

| # | 输入（用户原话） | 预期 |
|---|---|---|
| P1 | 分析一下 UE 的 Core 模块 | ②（路径查 `engine-modules.json`） |
| P2 | Engine 模块是怎么组织的 | ② |
| P3 | RenderCore 依赖哪些模块 | ② |
| P4 | Core.Build.cs 里有哪些依赖 | ② |
| P5 | Core 模块的目录结构是什么 | ② |

## 反例（不应触发本技能）

| # | 输入 | 预期 |
|---|---|---|
| N1 | AActor 的继承链是什么 | ③ `ue-type-api` |
| N2 | UObject 的创建流程 | ④ `ue-flow-trace` |
| N3 | 引擎源码一共有哪些模块 | ① `ue-engine-inventory` |
| N4 | 校验 Core 模块文档的准确性 | ⑤ `ue-doc-verify` |

## 边界（易混场景）

| # | 输入 | 预期 |
|---|---|---|
| B1 | Core 和 CoreUObject 是什么关系 | ②（模块间关系）；回答必须基于 `Build.cs` 依赖数据，不得凭印象 |
| B2 | CoreUObject 模块里的 UObject 类 | ③（类型粒度优先）；若先走 ②，必须停在模块层面不展开类 API |
| B3 | 分析 EnhancedInput 模块 | ②；路径必须是 `Engine/Plugins/EnhancedInput/Source/EnhancedInput`，不得写成 `Source/Runtime/EnhancedInput` |

## 执行记录

| 日期 | 执行人 | 正例 | 反例 | 边界 | 备注 |
|---|---|---|---|---|---|
| （待执行） | | | | | |
