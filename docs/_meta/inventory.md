> 引擎版本：UE 5.8.3 (Build 58210709)
> 源码根：Engine/Source
> 生成技能：ue-engine-inventory v1.0
> 生成时间：2026-10-10
> 校验状态：未校验

# UE5 引擎源码盘点

数据来源：`scan-engine.ps1` 于 2026-10-10 直跑（**引擎重装补齐源码之后**），
参数 `-EngineRoot "E:\EpicGames\UE_5.8\Engine" -AsJson`。尚未经 `ue-doc-verify` 校验。

> 本次为重跑。重装前（仅头文件安装）同口径数据为 52,157 个文件；补齐源码后为 **89,196**，
> 增幅来自恢复的 `.cpp` 与被剥离的 `Private/*.h`。**模块数 2,403 未变**（`Build.cs` 未变动）。

## 一、规模总览

| 类别 | 模块数 | 模块内文件数 | 是否纳入范围 |
|---|---|---|---|
| Runtime | 291 | 19,221 | ✅ 核心 |
| Plugins/* | ~1,788 | 56,780 | ⚠️ 仅白名单 |
| Editor | 145 | 8,343 | ❌ 本版排除 |
| Developer | 164 | 3,541 | ❌ 本版排除 |
| Platforms | 12 | 47 | ❌ 本版排除 |
| Programs | 2 | 37 | ❌ 本版排除 |
| Shaders | 1 | 1,227 | ❌ 本版排除 |
| ThirdParty | 已排除 | 31,021（目录总量） | ❌ 脚本层过滤 |
| **合计** | **2,403** | **89,196** | — |

两点必须留意：

1. **模块数的大头在 `Plugins`（约 1,788），不在 `Runtime`（291）。** 这与直觉相反。
2. **`模块内文件数` 是各模块目录内文件数之和**，含嵌套模块的重复计数，不等于磁盘上的独立文件数，也不等于目录总量。
   例：`Engine/Source/Programs` 目录有 2,985 个文件，但其中属于 UE 模块的只有 30 个——其余是 C# 构建工具链。

## 二、模块清单

完整机器可读清单见 `docs/_meta/engine-modules.json`（由同一脚本产出，含全部 2,403 行）。

下表为首批白名单模块，路径已按规范转为相对形式：

| 模块 | 类别 | 路径 | 文件数 | 头文件数 | 纳入范围 |
|---|---|---|---|---|---|
| `Core` | Runtime | `Engine/Source/Runtime/Core` | 2,171 | 1,368 | ✅ |
| `CoreUObject` | Runtime | `Engine/Source/Runtime/CoreUObject` | 969 | 553 | ✅ |
| `Engine` | Runtime | `Engine/Source/Runtime/Engine` | 4,037 | 2,404 | ✅ |
| `GameplayTags` | Runtime | `Engine/Source/Runtime/GameplayTags` | 27 | 13 | ✅ |
| `EnhancedInput` | Plugins/EnhancedInput | `Engine/Plugins/EnhancedInput/Source/EnhancedInput` | 42 | 21 | ✅ |
| `SlateCore` | Runtime | `Engine/Source/Runtime/SlateCore` | 327 | 189 | ✅ |
| `Slate` | Runtime | `Engine/Source/Runtime/Slate` | 465 | 267 | ✅ |
| `UMG` | Runtime | `Engine/Source/Runtime/UMG` | 315 | 168 | ✅ |
| `RHI` | Runtime | `Engine/Source/Runtime/RHI` | 108 | 62 | ✅ |
| `RenderCore` | Runtime | `Engine/Source/Runtime/RenderCore` | 212 | 121 | ✅ |

白名单合计 **8,673** 文件。纳入范围的模块数：**292**（Runtime 291 + 白名单插件 1）。

> 重装前后**头文件数完全未变**（1,368 / 553 / 2,404 / 13 / 21 / 189 / 267 / 168 / 62 / 121），
> 增长全部来自实现文件。这印证了"重装前是仅头文件安装"的判断：头文件本来就齐全，缺的是 `.cpp`。

## 三、首批批次

| 批次 | 模块 | 说明 |
|---|---|---|
| 批 1 | `Core`、`CoreUObject` | 后 8 个模块的文档都要反向链接到这里 |
| 批 2 | `Engine`、`GameplayTags` | 依赖批 1 的类型文档 |
| 批 3 | `EnhancedInput`、`SlateCore`、`Slate`、`UMG` | UI 与输入依赖批 2 的 `AActor` / `UWorld` |
| 批 4 | `RHI`、`RenderCore` | 相对独立，可并行 |

批次顺序的依据与详细理由见 `.codebuddy/skills/ue-engine-docs-suite/ue-engine-docs/references/subsystem-catalog.md`。

## 四、第二批候选

| 模块 | 路径 | 文件数 |
|---|---|---|
| `Renderer` | `Engine/Source/Runtime/Renderer` | 401 |
| `MovieScene` | `Engine/Source/Runtime/MovieScene` | 296 |
| `Net` | `Engine/Source/Runtime/Net` | 253 |
| `AIModule` | `Engine/Source/Runtime/AIModule` | 208 |
| `NavigationSystem` | `Engine/Source/Runtime/NavigationSystem` | 61 |
| `PhysicsCore` | `Engine/Source/Runtime/PhysicsCore` | 43 |
| `GameplayTasks` | `Engine/Source/Runtime/GameplayTasks` | 12 |
| `DeveloperSettings` | `Engine/Source/Runtime/DeveloperSettings` | 未单独统计 |

## 五、盘点异常与待核对项

### 5.1 已核清的异常

| 现象 | 结论 |
|---|---|
| `Engine/Shaders` 被识别为 1 个模块、1,227 个文件 | **不是误报。** `Engine/Shaders/Shaders.Build.cs` 确实存在，是承载着色器源文件的真实模块。属渲染管线专用内容，本版排除，但盘点时必须单列并标注原因 |
| `Programs` 目录 2,985 个文件，却只有 2 个模块 | 其余为 C# 构建工具链，无 `*.Build.cs`。**不能用目录文件数当模块文件数** |
| `Plugins/Experimental` 一个分类就有 476 个模块 | 它是插件**分组**而非单个插件。分类名取 `Engine/Plugins/` 下第二段路径，分组组织时得到的是分组名 |
| `EnhancedInput` 的模块文件数是 22，而插件分类汇总写 42 | 22 是模块目录自身的文件数；42 是该插件下 3 个模块的合计。**填文档用模块行的数字** |

### 5.2 待核对项

- [x] 本机环境块记录的版本与实际安装一致 —— 已于 2026-10-10 核对通过（重装后为 UE 5.8.3 Build 58210709）
- [x] 白名单 10 个模块全部命中，无缺失
- [ ] `Plugins` 分组名与插件名的对应关系尚未展开，扩面到某个插件时需先确认其真实 path
- [ ] `DeveloperSettings` 的文件数未单独统计（`-SkipFileCount` 未使用，但其行未在摘录中）

### 5.3 已知的计数口径限制

- 嵌套模块会被父模块重复计数（父模块目录包含子模块目录时）。
- `ThirdParty` 在脚本层过滤，因此不在模块总数内；其 31,021 文件数来自目录枚举，仅作规模参照。

### 5.4 源码形态（已解决）

**当前状态：`Complete`。** `Engine/Source` 下 `.h` 28,567 个、`.cpp` **13,182** 个、`.inl` 207 个（2026-10-10 复跑 `check-source.ps1` 更新，原记 13,180）。

无法判定的能力（调用链、时序、实现算法）现已全部可用。

> **历史（2026-10-10 上午）**：本机曾是**仅头文件安装**（`.cpp` 为 0），当时的盘点得出的是
> 52,157 个文件、"无法产出实现层结论"的结论。重装补齐源码后重跑，模块数 2,403 未变、
> 文件数升至 89,196。这段历史保留在此，因为它是「零命中不等于不存在」这条规则的来源——
> 详见 `docs/_meta/convention.md` 的「源码形态」。

### 5.5 版本锚点在重装后发生了变化

| 时点 | 版本锚点 |
|---|---|
| 重装前 | UE 5.8.2 (Build 56702186) |
| 重装后 | **UE 5.8.3 (Build 58210709)** |

小版本升级（5.8.2 → 5.8.3）。全部产物的文档头已同步更新为 5.8.3。

**同时发现 Launcher Manifest 不可靠**：重装后 `UE_5.8` 的引擎条目从 Manifest 中消失了
（只剩同为 `E:\EpicGames\UE_5.8` 路径的 Fab / QuixelBridge 等插件条目）。
因此版本号的**首选来源已改为引擎自带的 `Engine/Build/Build.version`**，Manifest 降为备用。
