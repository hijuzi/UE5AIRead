# 引擎子系统目录与批次规划

本文件是**数据**，不是流程。① `ue-engine-inventory` 用它界定范围，主技能用它决定批次顺序。

所有数值为 **UE 5.8.3 (Build 58210709)** 实测值，由 `scan-engine.ps1` 于 2026-10-10 产出
（**引擎重装补齐源码之后**）。

## 一、分类规则

`scan-engine.ps1` 按模块目录相对引擎根的第一段路径分派：

| 类别 | 判定依据 | 模块数 | 纳入文档范围 |
|---|---|---|---|
| `Runtime` | `Engine/Source/Runtime/<模块>` | 291 | ✅ 核心 |
| `Editor` | `Engine/Source/Editor/<模块>` | 145 | ❌ 本版排除 |
| `Developer` | `Engine/Source/Developer/<模块>` | 164 | ❌ 本版排除 |
| `Platforms` | `Engine/Platforms/<模块>` | 12 | ❌ 本版排除 |
| `Programs` | `Engine/Source/Programs/<模块>` | 2 | ❌ 本版排除 |
| `Shaders` | `Engine/Shaders/Shaders.Build.cs` | 1 | ❌ 本版排除 |
| `Plugins/<分组或插件名>` | `Engine/Plugins/...` | 约 1,790 | ⚠️ 仅白名单 |
| `ThirdParty` | 路径含 `ThirdParty/` | 已排除 | ❌ 脚本层过滤 |

**模块总数 2,403。** `Runtime` 只有 291 个——**大头在 `Plugins`**，这一点与直觉相反，容易误判规模。

> `Plugins/*` 的分类名取自 `Engine/Plugins/` 下的第二段路径。当插件按分组组织时
> （如 `Engine/Plugins/Runtime/<插件>/...`），分类名是**分组名**而非插件名，
> 例如 `Plugins/Runtime` 下有 311 个模块。填写文档时以模块行的 `Path` 为准。

### 关于 `Programs` 与 `Shaders` 的两个反直觉点

1. **`Programs` 目录有 2,985 个文件，但只有 2 个 UE 模块**（合计 30 个文件）。
   其余全是 C# 构建工具链，没有 `*.Build.cs`。所以"排除 Programs"对模块计数几乎无影响，
   只对文件计数有影响——写规模总览时不要拿目录文件数当模块文件数。
2. **`Engine/Shaders/Shaders.Build.cs` 是真实模块**，内含 1,227 个着色器源文件。
   它不是误报，但属渲染管线专用内容，本版不产出文档；盘点时应单列并标注排除原因。

## 二、首批 10 个模块（白名单）

路径一律相对 UE 安装根。

| # | 模块 | 路径 | 文件数 | 头文件数 | 类别 | 层 |
|---|---|---|---|---|---|---|
| 1 | `Core` | `Engine/Source/Runtime/Core` | 2,171 | 1,368 | Runtime | 地基 |
| 2 | `CoreUObject` | `Engine/Source/Runtime/CoreUObject` | 969 | 553 | Runtime | 地基 |
| 3 | `Engine` | `Engine/Source/Runtime/Engine` | 4,037 | 2,404 | Runtime | 框架 |
| 4 | `GameplayTags` | `Engine/Source/Runtime/GameplayTags` | 27 | 13 | Runtime | 框架 |
| 5 | `EnhancedInput` | `Engine/Plugins/EnhancedInput/Source/EnhancedInput` | 42 | 21 | Plugins | 框架 |
| 6 | `SlateCore` | `Engine/Source/Runtime/SlateCore` | 327 | 189 | Runtime | UI |
| 7 | `Slate` | `Engine/Source/Runtime/Slate` | 465 | 267 | Runtime | UI |
| 8 | `UMG` | `Engine/Source/Runtime/UMG` | 315 | 168 | Runtime | UI |
| 9 | `RHI` | `Engine/Source/Runtime/RHI` | 108 | 62 | Runtime | 渲染 |
| 10 | `RenderCore` | `Engine/Source/Runtime/RenderCore` | 212 | 121 | Runtime | 渲染 |

合计 **8,673** 文件（其中 5,366 个头文件）。

> **校验白名单请用「头文件数」而不是「文件数」**：头文件数在"仅头文件安装"与"完整源码安装"下
> 完全一致（实测重装前后 10 个模块的头文件数一个都没变），而文件数会从 5,306 跳到 8,673。
> 断言用头文件数才能同时覆盖两种安装形态。

### 每个模块的入选理由

| 模块 | 为什么进首批 |
|---|---|
| `Core` | 容器 / 字符串 / 内存 / 日志，一切模块的根依赖 |
| `CoreUObject` | `UObject` / 反射 / `UClass` / GC / 序列化 |
| `Engine` | `AActor` / `UActorComponent` / `UWorld` / Tick |
| `GameplayTags` | 标签驱动架构的基础设施 |
| `EnhancedInput` | 输入系统的现行标准 |
| `SlateCore` | UI 底层声明式框架 |
| `Slate` | 控件与窗口实现 |
| `UMG` | 蓝图侧 UI 体系（游戏用最多） |
| `RHI` | 渲染硬件接口抽象，性能问题落点 |
| `RenderCore` | 渲染线程 / 着色器参数 / 资源管理 |

## 三、批次推进顺序

| 批次 | 模块 | 必须先完成上一批的原因 |
|---|---|---|
| 批 1 | `Core`、`CoreUObject` | 后 8 个模块的文档都要反向链接到这里 |
| 批 2 | `Engine`、`GameplayTags` | 依赖批 1 的类型文档 |
| 批 3 | `EnhancedInput`、`SlateCore`、`Slate`、`UMG` | UI 与输入依赖批 2 的 `AActor` / `UWorld` |
| 批 4 | `RHI`、`RenderCore` | 相对独立，可并行 |

**不要并发跑多个模块。** 顺序错了会导致后批次文档里的交叉链接指向不存在的文件。

## 四、第二批候选（本版不做）

按优先级排序：

| 模块 | 路径 | 文件数 |
|---|---|---|
| `Renderer` | `Engine/Source/Runtime/Renderer` | 401 |
| `MovieScene` | `Engine/Source/Runtime/MovieScene` | 296 |
| `Net` | `Engine/Source/Runtime/Net` | 253 |
| `AIModule` | `Engine/Source/Runtime/AIModule` | 208 |
| `NavigationSystem` | `Engine/Source/Runtime/NavigationSystem` | 61 |
| `PhysicsCore` | `Engine/Source/Runtime/PhysicsCore` | 43 |
| `GameplayTasks` | `Engine/Source/Runtime/GameplayTasks` | 12 |
| `DeveloperSettings` | `Engine/Source/Runtime/DeveloperSettings` | — |

扩面前先复盘首批流程。

## 五、三个已实测的坑

1. **高频模块不一定在 `Source/Runtime/`**
   `EnhancedInput` 实际位于 `Engine/Plugins/EnhancedInput/Source/EnhancedInput`。
   → 扫描根必须同时覆盖 `Engine/Source/**` 与 `Engine/Plugins/**/Source/**`。
   不要用"在不在 Runtime 下"当筛选条件。

2. **模块目录不一定在第一层**
   `Engine/Source/Runtime/Windows/WindowsD3D`、`Engine/Source/Runtime/AudioLink/AudioLinkCore`
   都是独立模块。
   → 必须递归查找 `*.Build.cs`，不能只扫 `Source/Runtime/*/`。

3. **`Build.cs` 文件名大小写不统一**
   引擎里同时存在 `Core.Build.cs` 与 `VirtualProduction.build.cs`、`TextureUtilitiesCommon.build.cs`。
   → 文件名匹配必须忽略大小写。

## 六、白名单校验断言

① 每次盘点后，用这张表核对白名单是否全部命中。**任一行缺失即为扫描规则出了问题**，
不得直接开始写文档：

| 模块 | 期望类别 | 期望头文件数 |
|---|---|---|
| `Core` | Runtime | ~1,368 |
| `CoreUObject` | Runtime | ~553 |
| `Engine` | Runtime | ~2,404 |
| `GameplayTags` | Runtime | ~13 |
| `EnhancedInput` | **Plugins/EnhancedInput** | ~21 |
| `SlateCore` | Runtime | ~189 |
| `Slate` | Runtime | ~267 |
| `UMG` | Runtime | ~168 |
| `RHI` | Runtime | ~62 |
| `RenderCore` | Runtime | ~121 |

**用头文件数当断言，不要用文件数。** 头文件数在"仅头文件安装"与"完整源码安装"下完全一致
（实测重装前后 10 个模块的头文件数一个都没变），而文件数会从 5,306 跳到 8,673。
用头文件数才能同时覆盖两种安装形态；用文件数会在换机器/换安装方式时误报。

头文件数允许小幅浮动（引擎小版本差异）；**类别必须完全一致**。
`EnhancedInput` 若落在 `Runtime` 类别下，说明路径判定逻辑被改坏了。
