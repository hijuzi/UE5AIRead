# UE5 引擎文档规范（单一真源）

本文件是**全体技能共同引用的唯一规范**。任何技能产出的文档都必须遵守本文件。
规范变更时，在文末「变更记录」追加条目，并同步检查已有产物是否需要回改。

> 本文件由主技能 `ue-engine-docs` 从 `assets/convention-template.md` 生成。
> 结构变更改模板，环境变更改本文件。

---

## 一、本机环境

> **本块是唯一允许出现绝对路径的地方。** 用途仅是让技能把文档中的相对路径解析成实际可读路径。
> 文档引用格式里**禁止**出现绝对路径。

| 项 | 值 |
|---|---|
| 引擎版本 | UE 5.8.3 (Build 58210709) |
| 引擎安装根 | `E:\EpicGames\UE_5.8` |
| 引擎根（扫描用） | `E:\EpicGames\UE_5.8\Engine` |
| 源码根 | `E:\EpicGames\UE_5.8\Engine\Source` |
| 插件根 | `E:\EpicGames\UE_5.8\Engine\Plugins` |

### 源码形态（影响全部技能）

**复核状态：✅ 已复核（2026-10-10，重装后）**

| 项 | 实测值 |
|---|---|
| `Engine/Source` 下 `.h` 数量 | 28,567 |
| `Engine/Source` 下 `.cpp` 数量 | **13,180** |
| `.inl` | 207 |
| **结论** | **`Complete`——源码完整，全部技能可执行（含 ④ 调用链追踪）** |

复核命令（**唯一真源**，不要用手写命令替代；脚本已排除 `Marketplace` / `Fab` / `Bridge` 等用户插件目录）：

```powershell
.codebuddy\skills\ue-engine-docs-suite\ue-engine-docs\scripts\check-source.ps1 -SourceRoot "E:\EpicGames\UE_5.8\Engine\Source"
```

| `Verdict` | 含义 |
|---|---|
| `Complete` | 有 `.cpp`，全部技能可执行 |
| `HeadersOnly` | 0 个 `.cpp`，④ 不可执行，② 的「模块生命周期」只能写"本机不可判定" |

> **历史（必须记住的教训）**：重装前本机是 `HeadersOnly`（0 个 `.cpp`）。当时对 `Core` 与 `CoreUObject`
> 搜不到 `IMPLEMENT_MODULE` 调用，被误判为"这两个模块没有入口类"，错误结论写进了产物。
> 补齐源码后确认入口分别是 `FCoreModule` 与 `FCoreUObjectModule`。
> 由此固化为全局规则：**任何"零命中"结论在下定论之前，先确认证据源本身是否完整。**

**这条约束决定哪些技能可执行，开工前必须先确认：**

| 能力 | 是否可行 | 原因 |
|---|---|---|
| 模块结构（`Build.cs`、目录布局、公开头文件） | ✅ 可行 | 这些文件都在 |
| 类型 API（声明、反射宏、继承链、函数签名、`UPROPERTY`/`UFUNCTION`） | ✅ 可行 | 头文件里有 |
| 函数内联体 / 模板实现 / `.inl` | ⚠️ 部分可见 | 头文件内联体 + `Engine/Source` 下 207 个 `.inl` |
| **调用链 / 时序 / 实现算法** | ✅ 可行 | 需要 `.cpp`；重装后 `Engine/Source` 有 13,180 个 `.cpp`（见上表） |

**任何技能都不得在只有头文件的情况下推断实现行为。** 无法确认时写"本机不可判定"，
不要用"UE 通常是这样"补全。

### 本机对照：其他引擎版本的源码完整度

| 引擎 | `.h` | `.cpp` | 形态 |
|---|---|---|---|
| `E:\EpicGames\UE_5.5` | 26,048 | 11,568 | ✅ 完整源码 |
| `E:\EpicGames\UE_5.7` | 27,408 | 12,399 | ✅ 完整源码 |
| **`E:\EpicGames\UE_5.8`（本版锁定）** | **28,567** | **13,180** | ✅ **重装后完整** |

### 版本锚点来源：首选 `Build.version`，不要依赖 Manifest

**首选**读引擎自带的 `Engine/Build/Build.version`：

```powershell
Get-Content "E:\EpicGames\UE_5.8\Engine\Build\Build.version" -Raw
```

2026-10-10 实测内容：

```json
{ "MajorVersion": 5, "MinorVersion": 8, "PatchVersion": 3, "Changelist": 58210709,
  "CompatibleChangelist": 55116800, "IsLicenseeVersion": 0, "IsPromotedBuild": 1,
  "BranchName": "++UE5+Release-5.8" }
```

解析规则：版本锚点 = `UE <MajorVersion>.<MinorVersion>.<PatchVersion> (Build <Changelist>)`
→ 本机为 **`UE 5.8.3 (Build 58210709)`**。

**为什么不用 Manifest**：它会漂移。2026-10-10 重装 UE 5.8 后，Manifest 里该引擎的条目**直接消失了**
（只剩同为 `E:\EpicGames\UE_5.8` 路径的 `FabPlugin_5.8` / `QuixelBridge_5.8` 等**插件**条目）。
用 Manifest 查会得到空结果，而"空结果"很容易被误当成"命令写错了"而不是"数据源不可靠"。

Manifest 仅作**备用**来源（必须带 `-Encoding UTF8`，否则报 `无效的 JSON 基元`）：

```powershell
Get-ChildItem "$env:ProgramData\Epic\EpicGamesLauncher\Data\Manifests\*.item" |
    ForEach-Object { Get-Content $_.FullName -Raw -Encoding UTF8 | ConvertFrom-Json } |
    Where-Object { $_.TechnicalType -eq 'engines/ue5,engines' } |
    Select-Object AppName, AppVersionString, InstallLocation
```

### 本机其他引擎（不在本版文档范围内）

| 引擎 | 版本 |
|---|---|
| UE 5.7 | 5.7.4-51494982 |
| UE 5.5 | 5.5.4-40574608 |

本版锁定 UE 5.8，不产出跨版本对照内容。

---

## 二、路径规范

**统一规则：文档中所有引擎路径一律相对 UE 安装根，一律以 `Engine/` 开头，使用正斜杠，不含盘符。**

| 写法 | 结论 | 示例 |
|---|---|---|
| 相对安装根（引擎） | ✅ 采用 | `Engine/Source/Runtime/Core/Core.Build.cs` |
| 相对安装根（插件） | ✅ 采用 | `Engine/Plugins/EnhancedInput/Source/EnhancedInput/EnhancedInput.Build.cs` |
| 相对 `Engine/` | ❌ 禁止 | `Source/Runtime/Core/Core.Build.cs` |
| 绝对路径 | ❌ 禁止 | `E:\EpicGames\UE_5.8\Engine\...` |

这样处理的收益：换机器、换引擎版本时路径依然成立，且不同产物的交叉链接不会因环境差异而断裂。

---

## 三、强制文档头

`docs/modules/`、`docs/types/`、`docs/flows/` 下的每份产物必须以下面这段开头：

```markdown
> 引擎版本：UE 5.8.3 (Build 58210709)
> 源码根：Engine/Source
> 生成技能：ue-module-structure v1.0
> 生成时间：2026-10-10
> 校验状态：未校验
```

| 字段 | 规则 |
|---|---|
| 引擎版本 | 从本文件「本机环境」块复制，不得自行填写 |
| 源码根 | 固定为 `Engine/Source`（相对安装根） |
| 生成技能 | 技能名 + 版本，取自该技能 SKILL.md 的 `metadata.version` |
| 生成时间 | `YYYY-MM-DD` |
| 校验状态 | `未校验`，或 `已校验（YYYY-MM-DD）`，由 `ue-doc-verify` 回填 |

> **没有版本锚点的引擎文档，升版后无法判断是否仍然有效。** 这一条不可省略。

---

## 四、引用格式

正文中引用引擎代码时，统一用下面的块：

```
文件：Engine/Source/Runtime/Core/Public/CoreTypes.h
行 14-44：FName 类定义
```

规则：

- `文件：` 后跟相对安装根的路径（见第二节）
- `行 A-B：` 后跟该区间内容的简短说明
- 行号必须是**实际核对过的行号**；`ue-doc-verify` 会逐条回查，对不上的必须修正
- 一个引用块只描述一处代码，多处引用写成多个块

> **命名空间与宏不要臆造。** 本版引擎的 `UCLASS` 类定义在头文件中通常带 `ENGINE_API` 或
> 模块导出宏，写文档前先读原文件确认，不要按"常见写法"推断。

---

## 五、语言约定

- 正文用中文。
- **类名 / 函数名 / 宏 / 变量名 / 文件名 / 模块名 / 配置项一律保留英文原名**，不翻译、不加空格、不改大小写。
- 英文术语首次出现时附中文说明，格式：`FName（名称索引，字符串驻留）`；同一产物内重复出现不再加注。
- 代码标识符统一用反引号包裹。

---

## 六、目录与命名

| 目录 | 内容 | 生产者 | 命名规则 |
|---|---|---|---|
| `docs/_meta/` | 元信息 | 主技能 / 盘点 / 校验 / 评估 | `convention.md`、`inventory.md`、`engine-modules.json`、`quality-report.md`、`skill-suite-assessment.md` |
| `docs/modules/` | 模块级结构 | `ue-module-structure` | `<模块名>-结构.md` |
| `docs/types/` | 类型级 API 面 | `ue-type-api` | `<类名>.md` |
| `docs/flows/` | 机制级调用链 | `ue-flow-trace` | `<机制名>.md` |
| `docs/ai/` | AI 检索索引 | `ue-ai-index` | `ai-index.md` |
| `docs/` 根 | 全库索引 | 主技能 | `00-索引.md` |

- 文件名用中文（模块名、类名等英文标识符保持原名），便于人工查阅。
- 子文档命名：`<主名>-<子名>.md`，如 `UI模块-框架核心.md`。
- 每份产物末尾必须有「相关文档」小节，列出可交叉引用的其他产物。

---

## 七、写入边界（红线）

| 规则 | 说明 |
|---|---|
| **引擎源码只读** | 禁止对引擎安装根下任何文件执行写操作 |
| **写入仅限 `docs/`** | 产物路径由第六节固定，不得写到技能目录或仓库其他位置 |
| **不修改已有产物的事实内容** | 补充与修正在原文上叠加；修正历史留痕，见第八节 |

---

## 八、校验状态与修正留痕

- 产物创建时 `校验状态：未校验`。
- `ue-doc-verify` 核对通过后，回填 `校验状态：已校验（YYYY-MM-DD）`。
- 内容发生实质修正（不只是错别字）时，在产物末尾追加：

```markdown
## 更新记录

- 2026-10-12 修正 Uxxx 的行号引用（原 88-102 -> 实际 91-105）
```

- 只做补充、未改事实的更新，可不记入更新记录，但要刷新「生成时间」。

---

## 九、变更记录

| 日期 | 版本 | 变更 |
|---|---|---|
| 2026-10-10 | v1.0 | 初版：确立路径规范、文档头、引用格式、语言约定、目录命名、红线 |
| 2026-10-10 | v1.1 | 修正「技能可执行性」表中调用链一栏：重装补齐源码后由「不可行」改为「可行」（HeadersOnly 时期遗留判定）；④ 首个流程产物已落定 |
| 2026-10-10 | v1.2 | `_meta/` 命名表登记 `skill-suite-assessment.md`（技能套装评估报告，新产物类型） |
