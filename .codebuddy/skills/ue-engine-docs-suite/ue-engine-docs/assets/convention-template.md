# UE5 引擎文档规范（单一真源）

本文件是**全体技能共同引用的唯一规范**。任何技能产出的文档都必须遵守本文件。
规范变更时，在文末「变更记录」追加条目，并同步检查已有产物是否需要回改。

---

## 一、本机环境

> **本块是唯一允许出现绝对路径的地方。** 用途仅是让技能把文档中的相对路径解析成实际可读路径。
> 文档引用格式里**禁止**出现绝对路径。

| 项 | 值 |
|---|---|
| 引擎版本 | `<UE 5.x.y (Build nnnnnnnn)>` |
| 引擎安装根 | `<E:\...\UE_5.x>` |
| 引擎根（扫描用） | `<E:\...\UE_5.x>\Engine` |
| 源码根 | `<E:\...\UE_5.x>\Engine\Source` |
| 插件根 | `<E:\...\UE_5.x>\Engine\Plugins` |

> **版本号来源优先级**：优先读引擎自带的 `Engine/Build/Build.version`，读不到再退回 Launcher Manifest。
>
> ```powershell
> Get-Content "<引擎安装根>\Engine\Build\Build.version" -Raw
> ```
>
> 该文件形如 `{ "MajorVersion": 5, "MinorVersion": 8, "PatchVersion": 3, "Changelist": 58210709, ... }`，
> 版本锚点写作 `UE <Major>.<Minor>.<Patch> (Build <Changelist>)`。
>
> **为什么优先 `Build.version`**：它随引擎本体存在，源码构建也一定有；而 Launcher Manifest 会漂移——
> 实测 2026-10-10 重装 UE 5.8 后，Manifest 里**该引擎的条目直接消失了**（只剩同路径的插件条目），
> 此时用 Manifest 查版本会得到空结果。
>
> Manifest 查法（备用，需带 `-Encoding UTF8`，否则报"无效的 JSON 基元"）：
>
> ```powershell
> Get-ChildItem "$env:ProgramData\Epic\EpicGamesLauncher\Data\Manifests\*.item" |
>     ForEach-Object { Get-Content $_.FullName -Raw -Encoding UTF8 | ConvertFrom-Json } |
>     Where-Object { $_.TechnicalType -eq 'engines/ue5,engines' } |
>     Select-Object AppName, AppVersionString, InstallLocation
> ```
>
> `AppVersionString` 形如 `5.8.3-58210709+++UE5+Release-5.8-Windows`，截断到第一个 `+`。

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
> 引擎版本：<UE 5.x.y (Build nnnnnnnn)>
> 源码根：Engine/Source
> 生成技能：<技能名> v<版本>
> 生成时间：<YYYY-MM-DD>
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
| `docs/_meta/` | 元信息 | 主技能 / 盘点 / 校验 | `convention.md`、`inventory.md`、`engine-modules.json`、`quality-report.md` |
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

- 2026-10-12 修正 UXXX 的行号引用（原 88-102 -> 实际 91-105）
```

- 只做补充、未改事实的更新，可不记入更新记录，但要刷新「生成时间」。

---

## 九、变更记录

| 日期 | 版本 | 变更 |
|---|---|---|
| <YYYY-MM-DD> | v1.0 | 初版 |
