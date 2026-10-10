---
name: ue-engine-inventory
description: >
  盘点 UE5 引擎源码的模块清单与规模，界定文档范围并输出首批文档批次，
  产出 docs/_meta/inventory.md。
  当用户问"UE 引擎源码有哪些模块""引擎源码有多大 / 多少文件"
  "盘点一下 UE 源码""哪些模块值得优先出文档""先做哪几个模块""模块清单列一下"时触发。
  触发词组合：UE 引擎/UE5 + 源码 + 模块/盘点/清单/规模/批次。
  不适用：查引擎装在哪、装了哪些版本（走 epic-engine-inventory）；
  分析某个模块的内部结构与依赖（走 ue-module-structure）；
  分析某个类或机制（走 ue-type-api / ue-flow-trace）。
metadata:
  category: ue-engine-docs
  version: "1.0"
  platform: Windows
---

# UE5 引擎源码盘点

给定一个引擎根目录，产出**模块清单 + 规模 + 首批文档批次**。

只盘点，不阅读。本技能不打开任何模块内的源码文件。

## 关键约束（先看这四条）

1. **只统计，不阅读。** 不读取模块内的任何源码文件。盘点阶段读实现会直接烧掉上下文，且对"定范围"这个目标没有帮助。
2. **必须排除 `ThirdParty` / `Programs` / `Intermediate` / `Binaries`。** `ThirdParty` 单目录就有 31,021 个文件（占引擎全量六成），混进来会让规模数字完全失真。
3. **扫描根必须同时覆盖 `Engine/Source/**` 与 `Engine/Plugins/**/Source/**`。** 高频模块 `EnhancedInput` 就在 `Engine/Plugins/` 下，按"只在 Runtime 下找"会直接漏掉。
4. **模块 = 递归查找到的 `*.Build.cs`**，且**忽略大小写**——引擎里同时存在 `Core.Build.cs` 与 `VirtualProduction.build.cs`。

## 适用判断

- **操作系统**：仅 Windows。
- **源码根可达**：

```powershell
Test-Path "E:\EpicGames\UE_5.8\Engine\Source"
```

返回 `False` 时**停止**：本技能只在已知源码路径上工作。若用户不知道路径，先走 `epic-engine-inventory` 拿真实路径。

- **不适用**：找引擎安装位置（走 `epic-engine-inventory`）；分析模块内部结构（走 `ue-module-structure`）。

## 执行步骤

### Step 1: 确认引擎根

从 `docs/_meta/convention.md` 的「本机环境」块取引擎根；用户显式给了路径则以用户为准。

本技能的工作参数是**引擎根**（含 `Source/` 与 `Plugins/`），不是 `Source/`：

```
正确：E:\EpicGames\UE_5.8\Engine
错误：E:\EpicGames\UE_5.8\Engine\Source   <- 会漏掉 Plugins 下的模块
```

### Step 2: 运行盘点脚本

```powershell
.codebuddy\skills\ue-engine-docs-suite\ue-engine-inventory\scripts\scan-engine.ps1 -EngineRoot "E:\EpicGames\UE_5.8\Engine"
```

| 场景 | 命令 |
|---|---|
| 默认：模块表 + 分类汇总 | `.codebuddy\skills\ue-engine-docs-suite\ue-engine-inventory\scripts\scan-engine.ps1 -EngineRoot "<引擎根>"` |
| 供后续步骤消费 | `.codebuddy\skills\ue-engine-docs-suite\ue-engine-inventory\scripts\scan-engine.ps1 -EngineRoot "<引擎根>" -AsJson` |
| 只求快，不要文件数 | `.codebuddy\skills\ue-engine-docs-suite\ue-engine-inventory\scripts\scan-engine.ps1 -EngineRoot "<引擎根>" -SkipFileCount` |

环境不允许执行脚本文件时（如 ExecutionPolicy 受限），改用：

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File ".codebuddy\skills\ue-engine-docs-suite\ue-engine-inventory\scripts\scan-engine.ps1" -EngineRoot "E:\EpicGames\UE_5.8\Engine"
```

> 默认输出用 `Format-Table` 会按控制台宽度截断 `Path` 列。**需要完整路径时必须加 `-AsJson`**，不要靠格式化表格里的路径去填文档。

**检查点**：分两处看，缺一即说明扫描根给错了：

| 检查 | 期望值 | 不达标说明 |
|---|---|---|
| `Runtime` 分类的模块数 | 约 **290** | 缺失或 < 100 → 扫描根给了 `Source\Runtime`，不是引擎根 |
| 模块总数（含 `Plugins/*`） | 约 **2,400** | 只有几百 → 扫描根给了 `Source`，漏掉了 `Plugins` |

> 注意 `Runtime` 只有 290 个模块，而 `Plugins` 下有约 1,790 个——**总数的大头在 Plugins**。
> 因此"总数 300 量级"是错误预期，表格里的 `Plugins/*` 分类行必须有内容。

### Step 3: 分类与批次划分

按 `docs/_meta/convention.md` 与主技能的 `references/subsystem-catalog.md` 处理：

1. **范围判定**：保留 `Runtime` 与白名单内的 `Plugins`；标出 `Editor` / `Developer` / `Programs` 为「本版排除」。
2. **规模汇总**：按类别汇总模块数与文件数。
3. **批次划分**：按 `subsystem-catalog.md` 的依赖顺序排出批 1–批 4，并列出第二批候选。
4. **核对白名单**：首批 10 个模块是否都能在扫描结果里找到。**找不到就是发现问题的信号**——不是白名单错了，就是路径规则漏了（例如 `EnhancedInput` 缺失，说明 `Plugins` 没扫到）。

### Step 4: 写 `docs/_meta/inventory.md`

用下面的结构。**只写事实，不写分析。**

````markdown
> 引擎版本：<从 docs/_meta/convention.md 复制>
> 源码根：Engine/Source
> 生成技能：ue-engine-inventory v1.0
> 生成时间：YYYY-MM-DD
> 校验状态：未校验

## 一、规模总览

| 类别 | 模块数 | 文件数 | 是否纳入范围 |
|---|---|---|---|
| Runtime | | | ✅ |
| Plugins | | | ⚠️ 白名单 |
| Editor | | | ❌ |
| Developer | | | ❌ |
| Programs | | | ❌ |
| ThirdParty | 已排除 | 31,021 | ❌ |

## 二、模块清单

| 模块 | 类别 | 路径 | 文件数 | 头文件数 | 纳入范围 |
|---|---|---|---|---|---|

## 三、首批批次

| 批次 | 模块 | 说明 |
|---|---|---|

## 四、第二批候选

（列表）

## 五、盘点异常与待核对项

- 本机环境块记录的版本与实际是否一致
- 白名单模块是否有缺失（缺失即为扫描规则问题）
- 疑似模块目录（含大量源码但无 `*.Build.cs`，如 `Runtime/Experimental`）
````

`Path` 列写入时统一转成 `Engine/Source/Runtime/Core` 形式（正斜杠、以 `Engine/` 开头），
不得保留脚本输出的反斜杠与盘符，理由见 `convention.md` 第二节。

**检查点**：

```powershell
Test-Path docs\_meta\inventory.md
Select-String -Path docs\_meta\inventory.md -Pattern '首批批次' -Quiet
```

### Step 5: 交回主技能

告知用户：模块总数、纳入范围的模块数、首批 10 个模块及批次顺序。
**等用户确认批次后再进入 ② `ue-module-structure`，不要自行开跑。**

## 输出示例

**示例 1：默认输出的分类汇总（UE 5.8 实测，摘录）**

```
Category                  Modules      Files
------------------------ -------- ----------
Developer                      164       2025
Editor                         145       4664
Platforms                       12         47
Programs                         2         30
Plugins/EnhancedInput            3         42
Plugins/Experimental           476       5707
Plugins/Runtime                311       6816
Runtime                        291      11589
Shaders                          1       1227

Engine root : E:\EpicGames\UE_5.8\Engine
Modules     : 2403
```

> `Plugins/*` 分组实际有约 70 行，上表只摘录 3 行。**`Plugins` 才是模块数的大头（约 1,790）。**
> 字段含义：`Modules` = 该分类下的模块数，`Files` = 该分类下各模块目录内文件数之和
> （含嵌套模块的重复计数，因此不等于磁盘上的独立文件数）。

**示例 2：单模块行（UE 5.8 实测）**

```
Category          Module        Path                                          Files Headers
--------          ------        ----                                          ----- -------
Runtime           Core          Source\Runtime\Core                            1433    1368
Runtime           CoreUObject   Source\Runtime\CoreUObject                       566     553
Runtime           Engine        Source\Runtime\Engine                          2434    2404
Plugins/EnhancedInput EnhancedInput Plugins\EnhancedInput\Source\EnhancedInput    22      21
```

> 第四行是**最容易漏掉的一行**：`EnhancedInput` 不在 `Source\Runtime\` 下。
> 另外注意它的 `Files` 是 22（模块目录自身），不是 `Plugins/EnhancedInput` 分类汇总的 42
> ——后者是该插件下 3 个模块的合计。**填文档时用模块行的数字，不要用分类汇总的数字。**

**示例 3：异常——扫描根给成了 Source**

```
scan-engine.ps1 : 'Source' folder not found under:
E:\EpicGames\UE_5.8\Engine\Source  (pass the engine root, not a subfolder)
```

把 `-EngineRoot` 上提到 `E:\EpicGames\UE_5.8\Engine` 重跑。

**示例 4：边界——一个 `Build.cs` 都没找到**

```
WARNING: No *.Build.cs marker found under: <root>
```

说明路径指错了（可能指到了 `Content/` 或某个子模块目录），不要凭空编造模块清单。

## 完成检查

- [ ] 扫描根是**引擎根**（含 `Source` 与 `Plugins`），不是 `Source`
- [ ] 输出中无 `ThirdParty` / `Programs` / `Intermediate` / `Binaries` 条目
- [ ] 模块总数两处均达标：`Runtime` 约 290、总数约 2,400（与 Step 2 检查点一致）
- [ ] 数字类断言（规模、文件数）注明取数命令或实测时点，未凭目视估算
- [ ] 首批 10 个模块全部在扫描结果中找到（尤其 `EnhancedInput`）
- [ ] 所有路径均为相对路径：`Engine/...` 形式，**无盘符、无 `E:\`**
- [ ] `inventory.md` 只含事实，未出现对实现的描述
- [ ] 已交回主技能并等用户确认批次

## 常见问题

### Q: 和 `epic-engine-inventory` 有什么差别？

`epic-engine-inventory` 回答"**引擎装在哪**、装了哪几个版本"，读的是 Epic Launcher 的 Manifest。本技能回答"**已确定的那份源码里有哪些模块**"，读的是源码目录里的 `*.Build.cs`。前者是后者的前置：不知道路径就走前者。

### Q: 为什么 `Programs` 要排除？

它装的是 UnrealBuildTool、UnrealHeaderTool 这类构建工具链（2,985 个文件），不是运行时 API。写 Gameplay 代码的人用不到，AI 辅助编程也不需要。

### Q: `Runtime/Experimental` 这类目录算模块吗？

不算独立模块——它本身没有 `*.Build.cs`，里面装着若干各自带标记的子模块。脚本靠 `*.Build.cs` 识别模块，因此那些子模块会各自作为独立模块出现，这是正确行为。

### Q: 为什么脚本输出反斜杠，写文档要转成正斜杠？

脚本产出 Windows 原生路径（`Source\Runtime\Core`），便于本地核对；文档要跨机器、跨版本可读，统一用 `Engine/Source/Runtime/Core` 形式。转换由本技能在 Step 4 完成。

### Q: 某一类别的汇总数字和逐个模块加起来不一致？

因为存在嵌套模块：父模块目录内若含子模块目录，父模块的文件数会把子模块一起算进去。属预期行为，不要"修正"这个数字。

## 注意事项

- **改脚本时保持纯 ASCII。** Windows PowerShell 5.1 对没有 BOM 的脚本文件按 ANSI 解码，非 ASCII 字面量会乱码，乱码后的字节还可能吞掉紧随其后的引号——表现出来不是语法错误，而是"脚本能跑但结果全空"，极难排查。中文说明写在本文件里，不要写进 `.ps1`。
- 引擎源码只读。本技能不产生任何对引擎目录的写操作。
