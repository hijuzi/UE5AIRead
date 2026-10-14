---
name: ue-module-structure
description: >
  分析 UE5 引擎**某个模块**的目录结构、构建依赖与对外暴露面，
  产出 docs/modules/<模块名>-结构.md。
  当用户提出"分析 UE 的 Core 模块""Engine 模块是怎么组织的"
  "RenderCore 依赖哪些模块""某个模块的 Build.cs 依赖关系"
  "这个模块的目录结构是什么""模块的公开头文件有哪些"时触发。
  触发词组合：UE5/UE 引擎 + 模块名（Core/Engine/RenderCore/UMG/Slate/RHI...）
  + 结构/依赖/Build.cs/目录/公开接口/暴露面。
  不适用：分析单个类或结构体（走 ue-type-api）；分析某个机制的调用链或时序（走 ue-flow-trace）；
  只想知道引擎有哪些模块（走 ue-engine-inventory）；游戏工程源码分析（本套件只处理引擎源码）；
  修改引擎源码（全程只读）。
metadata:
  category: ue-engine-docs
  version: "1.0"
  platform: Windows
---

# UE5 模块结构与依赖分析

给定**一个模块名**，产出该模块的结构与依赖文档。

## 职责边界（最容易越界的地方）

| 本技能负责 | 本技能**不做** |
|---|---|
| 模块的目录布局与分层 | 逐个类展开字段与函数（→ `ue-type-api`） |
| `Build.cs` 的依赖，含生效条件 | 跨类调用链与时序（→ `ue-flow-trace`） |
| `Public/` 对外暴露边界 | 模块清单盘点（→ `ue-engine-inventory`） |
| 模块的加载与卸载时机 | 编译配置、平台工具链细节 |
| 只处理**引擎**模块 | 游戏工程模块（如项目里的 `MyGame`）——**不读项目目录**，声明范围外，并引导用户改给引擎模块名 |

**判断标准**：如果一段内容换个模块也成立，它就不属于本篇——它属于规范或子系统目录。

## 前置条件

`docs/_meta/inventory.md` 与 `docs/_meta/convention.md` 必须存在。缺失时先跑
`ue-engine-inventory`，再跑主技能初始化，**不要跳过**。

## 核心约束

1. **一次只分析一个模块。** 用户一次给了多个模块名时，按 `subsystem-catalog.md` 的批次顺序串行做，做完一个让用户确认再进下一个。
2. **模块路径必须查表得来，不许拼。** 真实路径从 `docs/_meta/engine-modules.json` 里按 `Module` 字段取。引擎里存在名字像但在别的分组下的模块，拼路径会直接引到不存在的文件。
3. **只读。** 不修改引擎任何文件。写入仅限 `docs/modules/`。
4. **路径写相对形式。** `Engine/Source/Runtime/Core`，不带盘符。
5. **引用要能被 token 解析。** 三类写法会被 `ue-doc-verify` 判为"引用缺失"，必须规避：
   模块内相对形式（如 `Engine/Classes/...`）、用 `.../` 缩写中间段、路径后紧跟全角括号不设分隔。
   写完后自查这三条；规则原文见 `_meta/convention.md` 第 4.1 节。

## 执行步骤

### Step 1: 解析模块真实路径

从 `docs/_meta/engine-modules.json` 取该模块的行：

```powershell
$m = Get-Content "docs\_meta\engine-modules.json" -Raw -Encoding UTF8 | ConvertFrom-Json
$m | Where-Object { $_.Module -eq 'Core' } | Select-Object Module, Category, Path, Files, Headers
```

**检查点**：必须且只能命中一行。
- 命中 0 行 → 模块名拼错，或该模块不在本引擎版本里。**停下问用户，不要猜路径。**
- 命中多行 → 存在同名模块（不同分组下同名是可能的）。把候选的 `Path` 列给用户，让用户选。

拿到的是脚本口径的 `Source\Runtime\Core`（反斜杠、相对引擎根）。**在做下一句之前先转成规范口径**：
`Engine/Source/Runtime/Core`（正斜杠、以 `Engine/` 开头）。

### Step 2: 读 `Build.cs`，解析依赖

```powershell
Get-Content "E:\EpicGames\UE_5.8\Engine\Source\Runtime\Core\Core.Build.cs" -Raw
```

依赖列表名可能包含（以实际文件为准，不是每个模块都有全部）：

| 列表 | 含义 |
|---|---|
| `PublicDependencyModuleNames` | 消费者会继承的依赖 |
| `PrivateDependencyModuleNames` | 仅本模块内部使用 |
| `DynamicallyLoadedModuleNames` | 运行时动态加载，非编译期依赖 |
| `PublicIncludePathModuleNames` | 只加包含路径，不链接 |
| `PrivateIncludePathModuleNames` | 同上，私有侧 |

**必须把依赖分成三类，这是本技能最容易出错的地方：**

| 类型 | 判定 | 处理 |
|---|---|---|
| 无条件依赖 | 在 `if` 之外直接 `Add` | 计入默认依赖图 |
| **平台 / 配置条件依赖** | 在 `if` / `else if` 分支内 `Add` | 单独成表，逐行标注生效条件 |
| **第三方静态依赖** | 由 `AddEngineThirdPartyPrivateStaticDependencies` 引入 | **单列第三张表**——它们是第三方静态库，不是 UE 模块，混进模块依赖表会让人误判模块耦合度 |

**条件依赖必须按"条件"归并成组，不要逐条罗列。** 大型模块的条件分支可能有 30 处以上：
`Engine/Source/Runtime/Core/Core.Build.cs` 实测 376 行、约 30 处分支。逐条罗列会得到一张
无法阅读的表。归并维度按这三类：

| 维度 | 归并后的条件写法 |
|---|---|
| 平台 | `Android` / `Win64` / `Windows 平台组` / `Mac` / `Unix 平台组` / `IOS 平台组` |
| 配置 | `非 Shipping` / `bBuildEditor` / `StaticAnalyzer == None` / `bPixProfilingEnabled` |
| 功能开关 | `bCompileAgainstApplicationCore` / `bCompileAgainstEngine && !bBuildRequiresCookedData` |

同一条件组下的多个模块合成一行，用"类型"列区分是私有依赖、公开依赖、私有包含路径还是动态加载。

**两个会漏项的地方，必须显式检查：**

1. **辅助函数会追加依赖。** `Build.cs` 里除 `Add*` 调用外，还可能有 `SetupXxx()` 之类的辅助函数
   （实测例子：`Engine/Source/Runtime/CoreUObject/CoreUObject.Build.cs` 里的 `SetupVerse()`），
   函数体会追加额外依赖。**静态只读 `Add` 调用会漏掉它们。**
   无法展开时，在产物中单列"未展开的依赖（待核对）"，不要假装依赖表已完整。
2. **同一个模块可能出现在多张列表里。** 实测例子：`AtomicQueue` 同时是 `Core` 的私有依赖与公开依赖；
   `AutoRTFM` 在 `Core.Build.cs` 里出现 3 次（私有依赖 2 处内容重复、公开包含路径 1 处）。
   **这不是错误，不要"去重"**——按可见性如实记录。

**检查点**：产物中「无条件依赖」「条件依赖」「第三方静态依赖」必须是三张独立的表，缺一不可。
条件依赖表按条件分组，行数应远小于 `Build.cs` 里的分支数。

### Step 3: 扫目录与暴露边界

```powershell
Get-ChildItem "E:\EpicGames\UE_5.8\Engine\Source\Runtime\Core" -Directory | Select-Object Name
```

记录：

- 是否 `Public/` + `Private/` 分离；老模块可能还有 `Internal/`，含义不同，**不要默认它等同于 `Public`**
- `Public/` 下是整个引擎的对外契约；`Private/` 是实现细节
- `Tests/` 目录属测试代码，标注但不展开

**检查点**：产物中的「对外暴露面」章节只能引用 `Public/` 下的路径。把 `Private/` 头文件列进暴露面是错误。

### Step 4: 找模块入口

搜索模块的加载入口：

```
search_content: pattern="IMPLEMENT_MODULE\(|IMPLEMENT_PRIMARY_GAME_MODULE\(|IModuleInterface" path="<模块路径>"
```

记录：
- 入口宏与实现的类
- `StartupModule()` / `ShutdownModule()` 里注册了什么（子系统、委托、控制台命令等）
- 是否有 `FModuleManager` 相关的动态加载

**0 命中时先查源码完整性，不要急着下"没有入口类"的结论。**

先跑：

```powershell
(Get-ChildItem -Recurse -File -Filter *.cpp "<引擎源码根>" -ErrorAction SilentlyContinue).Count
```

| 结果 | 含义 | 产物该怎么写 |
|---|---|---|
| **0** | 本机是**仅头文件安装**，实现文件被剥离。`IMPLEMENT_MODULE` 的调用在被剥离的 `.cpp` 里，本机不可读 | "**本机不可判定**——源码为仅头文件安装"，并引用 `docs/_meta/convention.md` 的「源码形态」一节。**不要写"本模块没有入口类"** |
| 正常值 | 源码完整 | 先区分"定义"与"调用"；再记入口宏、模块类、`StartupModule()` 行为 |

**已核实的样例**（可直接照此格式写产物）：

| 模块 | 入口宏 | 模块类 | 位置 |
|---|---|---|---|
| `Core` | `IMPLEMENT_MODULE( FCoreModule, Core );` | `FCoreModule : FDefaultModuleImpl` | `Engine/Source/Runtime/Core/Private/Misc/CoreGlobals.cpp` 行 38-49 |
| `CoreUObject` | `IMPLEMENT_MODULE( FCoreUObjectModule, CoreUObject );` | `FCoreUObjectModule : FDefaultModuleImpl` | `Engine/Source/Runtime/CoreUObject/Private/UObject/CoreNative.cpp` 行 33-122 |

注意 `Core` **未覆写 `StartupModule()`**，只覆写了 `SupportsDynamicReloading()` 返回 `false`
（源码注释：`Core cannot be unloaded or reloaded`）。
**"未覆写 StartupModule"与"没有入口类"是两回事**——如实写"未覆写，沿用 `FDefaultModuleImpl` 默认实现"。

**"看不见"与"不存在"是两回事，不能混写。** 把仅头文件安装误判成"本模块没有模块入口类"，
是一个会被下游文档继承的错误结论——本套件在首个闭环里就踩过这个坑。

**不要编造入口类。** 写清"确实没有"或"本机不可判定"都是有价值的结论。

### Step 5: 写产物

路径：`docs/modules/<模块名>-结构.md`，模块名保持英文原名。结构如下：

````markdown
> 引擎版本：<从 docs/_meta/convention.md 复制>
> 源码根：Engine/Source
> 生成技能：ue-module-structure v1.0
> 生成时间：YYYY-MM-DD
> 校验状态：未校验

# <模块名> 模块结构

## 一、模块定位

| 项 | 值 |
|---|---|
| 路径 | `Engine/Source/Runtime/<模块名>` |
| 类别 | Runtime / Plugins |
| 规模 | N 文件 / N 头文件 |
| 分层 | 地基 / 框架 / UI / 渲染 |
| 一句话职责 | |

## 二、目录结构

```
<模块名>/
├── Public/
├── Private/
└── Tests/
```

## 三、依赖关系

### 3.1 无条件依赖

| 模块 | 类型 | 说明 |
|---|---|---|
| | 公开 / 私有 / 动态加载 / 仅包含路径 | |

### 3.2 平台与配置条件依赖

| 模块 | 生效条件 | 来源列表 |
|---|---|---|
| | `Target.Platform == Android` | PrivateDependencyModuleNames |

## 四、对外暴露面

`Public/` 下的核心头文件及其提供的能力。**只列 `Public/`。**

| 头文件 | 提供的能力 |
|---|---|

## 五、模块生命周期

入口宏、实现类、`StartupModule()` / `ShutdownModule()` 行为。
无模块入口类时明确写"无"。

## 六、关键约定与坑

本模块特有的注意事项。

## 相关文档

- （链接到相关模块 / 类型 / 流程产物，暂无则写"暂无"）
````

**检查点**：

```powershell
Test-Path "docs\modules\Core-结构.md"
Select-String -Path "docs\modules\Core-结构.md" -Pattern '平台与配置条件依赖' -Quiet
```

两条都要通过。

### Step 6: 交回主技能

告知用户：产物路径、无条件依赖数、条件依赖数、对外暴露的头文件数。
**由主技能更新 `docs/00-索引.md`，本技能不直接改索引。**

## 输出示例

**示例 1：正常路径**

输入：`分析一下 UE 的 Core 模块`

应做：查表得 `Source\Runtime\Core` → 转成 `Engine/Source/Runtime/Core` → 读 `Core.Build.cs`
→ 依赖分两类 → 扫目录 → 找 `IMPLEMENT_MODULE` → 写 `docs/modules/Core-结构.md` → 交回主技能。

**示例 2：模块在 Plugins 下（边界）**

输入：`分析一下 EnhancedInput 模块`

应做：查表得 `Plugins\EnhancedInput\Source\EnhancedInput`，`Category` 为 `Plugins/EnhancedInput`。
产物路径与依赖解析照常，但「模块定位」表里的「类别」要写 `Plugins`，
且「路径」写 `Engine/Plugins/EnhancedInput/Source/EnhancedInput`。

不应做：写成 `Engine/Source/Runtime/EnhancedInput`——那个路径不存在。

**示例 3：模块名不存在（异常）**

输入：`分析一下 UE 的 Ninja 模块`

应做：查表命中 0 行 → 告知用户本引擎里没有该模块，并提示可跑的近似名字（如 `Ninja` 可能想说的是 `NinjaCharacter` 之类的插件模块）。

不应做：按 `Engine/Source/Runtime/Ninja` 去猜路径，然后写一篇引用了不存在文件的文档。

**示例 4：同名模块（异常）**

输入：`分析一下 Runtime 模块`

应做：查表可能命中多行（`Plugins/Runtime` 分组下有 311 个模块，且分组名本身可能同名）。
把候选项的 `Module` + `Path` 列给用户，让用户指明是哪一个。

不应做：取第一行就开跑。

## 完成检查

- [ ] 模块真实路径来自 `engine-modules.json` 查表，不是拼接出来的
- [ ] 产物路径为 `docs/modules/<模块名>-结构.md`，模块名保留英文原名
- [ ] 文档头 5 行齐全，版本号与 `convention.md` 一致
- [ ] 所有路径为 `Engine/...` 相对形式，无盘符
- [ ] **依赖分成「无条件」「条件依赖」「第三方静态依赖」三张表**（与 Step 2 检查点一致）
- [ ] 对外暴露面只引用了 `Public/` 下的路径
- [ ] 模块无入口类时写"无"，未编造
- [ ] 数字类断言（行数、依赖条数等）**逐条**在「取数说明」节有对应行，且写清"对象 / 模式 / 大小写 / 递归"四要素（`convention.md` 4.2）；**每行以 `[M]` / `[R]` / `[H]` 开头**声明方法类别，`[M]` 行命令可复制执行且结果与文中数字一致（4.2.1）
- [ ] 行号引用只使用 `convention.md` 4.3 承认的三种形式（块式 / 名在前 / 数字在前且文件名**紧邻**）；`（第 N 行）` 这类文件名在别处的写法机器无法校验，新产物不应再出现
- [ ] 未对引擎目录执行写操作
- [ ] 已交回主技能更新索引

## 常见问题

### Q: 为什么不直接按 `Engine/Source/Runtime/<模块名>` 拼路径？

因为有两类反例：模块可能在 `Engine/Plugins/...` 下（`EnhancedInput`），
也可能在多层目录里（`Engine/Source/Runtime/Windows/WindowsD3D`）。
拼路径在 90% 的情况下对，剩下 10% 会产出引用不存在文件的文档——那种错误最难发现。

### Q: `DynamicallyLoadedModuleNames` 算不算依赖？

算，但是**运行时依赖**，性质与编译期依赖不同，必须单独标注。
把它混进 `PrivateDependencyModuleNames` 会让人误判模块耦合度。

### Q: 模块里没有 `Public/` 目录怎么办？

有些老模块或纯内部模块没有公开边界。此时「对外暴露面」写"无 `Public/` 目录，
模块不对外暴露头文件"，并说明其实际可见性靠什么保证。**不要拿 `Private/` 冒充 `Public/`。**

### Q: 依赖里出现了不在纳入范围的模块（如某个 Editor 模块）怎么办？

照常记录。依赖图反映的是事实，不要因为"本版不产出该模块文档"就把它从依赖表里删掉。
在说明列注明"该模块不在本版文档范围内"即可。

## 参考文件

- `docs/_meta/convention.md` —— 文档头、路径规范、引用格式（**必读**）。
- `docs/_meta/inventory.md` —— 模块清单与规模。
- `.codebuddy/skills/ue-engine-docs-suite/ue-engine-docs/references/subsystem-catalog.md` —— 分层与批次定义。
