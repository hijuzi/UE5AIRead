> 引擎版本：UE 5.8.3 (Build 58210709)
> 源码根：Engine/Source
> 生成技能：ue-module-structure v1.0
> 生成时间：2026-10-10
> 校验状态：已校验（2026-10-11）

# TimeManagement 模块结构

## 一、模块定位

| 项 | 值 |
|---|---|
| 路径 | `Engine/Source/Runtime/TimeManagement` |
| 类别 | Runtime |
| 规模 | 55 文件 / 29 头文件（`_meta/engine-modules.json` 2026-10-10 口径；公开侧 26：顶层 16 + Estimation/ 3 + Misc/ 4 + Widgets/ 3） |
| 分层 | 框架（时间基础设施） |
| 一句话职责 | **时间上层设施**：自定义时间步（Fixed / Genlocked / Catchup / Timecode）、时间码提供者与同步源、帧率/时间码 UI 组件（`SFrameRatePicker` / `STimecode`）、时间码插值估算（Estimation/）与蓝图库 |

> **关键归属**：帧率/时间码**基础类型** `FFrameRate` / `FFrameTime` / `FFrameNumber` / `FQualifiedFrameTime` / `FTimecode` 定义在 **Core**（`Core/Public/Misc/`），本模块只做前置声明与上层使用。

## 二、目录结构

```
TimeManagement/
├── TimeManagement.Build.cs   # 模块构建脚本（19 行、0 处 if 分支）
├── Public/                   # 公开侧 26 个 .h（顶层 16 + Estimation/ 3 + Misc/ 4 + Widgets/ 3）
│   ├── 顶层：ITimeManagementModule.h / TimeManagementBlueprintLibrary.h / FixedFrameRateCustomTimeStep.h /
│   │        GenlockedCustomTimeStep.h / CatchupFixedRateCustomTimeStep.h / TimecodeCustomTimeStep.h /
│   │        GenlockedTimecodeProvider.h / ITimedDataInput.h / TimeSynchronizationSource.h /
│   │        TimedDataInputCollection.h / FrameNumberTimeEvaluator.h / CommonFrameRates.h …
│   ├── Estimation/（IClockedTimeStep.h / TimecodeEstimator.h / TimecodeRegressionProvider.h）
│   ├── Misc/（4 个，线性回归/环形缓冲工具）
│   └── Widgets/（SFrameRateEntryBox.h / SFrameRatePicker.h / STimecode.h）
└── Private/                  # 13 个 .cpp + 3 个 .h + Tests/（4 组测试与 Utils/；本版标注不展开）
```

## 三、依赖关系

### 3.1 无条件依赖

> 唯一一条 `PublicDependencyModuleNames.AddRange`（第 9-17 行）。

| 模块 | 类型 | Build.cs 行 | 说明 |
|---|---|---|---|
| `Core` | 公开依赖 | 11 | |
| `CoreUObject` | 公开依赖 | 12 | |
| `SlateCore` | 公开依赖 | 13 | 模块内含 Widgets |
| `Slate` | 公开依赖 | 14 | 同上 |
| `Engine` | 公开依赖 | 15 | |

> 辅助函数检查：**无**——无未展开依赖。

### 3.2 平台与配置条件依赖

**无**——`TimeManagement.Build.cs` 全文 **0 处 `if` 分支**（实测）。

### 3.3 第三方静态依赖

调用 **0 处**——无第三方静态依赖。

## 四、对外暴露面

> 公开侧共 26 个 `.h`；核心如下。

| 头文件 | 提供的能力 |
|---|---|
| `Engine/Source/Runtime/TimeManagement/Public/ITimeManagementModule.h` | 模块接口 `ITimeManagementModule`（第 16 行；`TIMEMANAGEMENT_MODULE_NAME` 第 10 行；`Get()` 第 24 行；`IsAvailable()` 第 33 行） |
| `Engine/Source/Runtime/TimeManagement/Public/TimeManagementBlueprintLibrary.h` | `UTimeManagementBlueprintLibrary`（第 28 行，`: UBlueprintFunctionLibrary`） |
| `Engine/Source/Runtime/TimeManagement/Public/FixedFrameRateCustomTimeStep.h`、`CatchupFixedRateCustomTimeStep.h`、`GenlockedFixedRateCustomTimeStep.h`、`TimecodeCustomTimeStep.h` | 自定义时间步族（固定帧率/追赶/同步锁/时间码驱动） |
| `Engine/Source/Runtime/TimeManagement/Public/GenlockedTimecodeProvider.h` | 时间码提供者实现族 |
| `Engine/Source/Runtime/TimeManagement/Public/ITimedDataInput.h`、`TimeSynchronizationSource.h`、`TimedDataInputCollection.h` | 时间数据同步源体系 |
| `Engine/Source/Runtime/TimeManagement/Public/Widgets/`（3 个） | 编辑器 UI 组件（`SFrameRatePicker` / `STimecode` 等） |
| `Engine/Source/Runtime/TimeManagement/Public/Estimation/`（3 个） | 时间码回归与估算 |

> **基础类型归属 Core**：`FFrameRate`（`Engine/Source/Runtime/Core/Public/Misc/FrameRate.h` 第 20 行）→ `types/FFrameRate.md`；`FFrameTime`（`Misc/FrameTime.h` 第 15 行）；`FFrameNumber`（`Misc/FrameNumber.h` 第 17 行）；`FQualifiedFrameTime`（`Misc/QualifiedFrameTime.h` 第 12 行）；`FTimecode`（`Misc/Timecode.h` 第 18 行）。
> `UTimecodeProvider` 在 **Engine**（`Engine/Source/Runtime/Engine/Classes/Engine/TimecodeProvider.h` 第 40 行）。
> `UTimedDataMonitor` 不在本模块（属 `VirtualProduction/TimedDataMonitor` 插件，本版范围外）。

## 五、模块生命周期

```
文件：Engine/Source/Runtime/TimeManagement/Private/TimeManagementModule.cpp
行 11：class FTimeManagementModule : public ITimeManagementModule
行 26：IMPLEMENT_MODULE(FTimeManagementModule, TimeManagement);
```

- **无 `StartupModule` / `ShutdownModule` / `SupportsDynamicReloading` 覆写（全模块 0 命中）**——模块类只实现接口的业务方法（`GetTimedDataInputCollection` 第 14 行等）。
- 接口派生：`ITimeManagementModule : public IModuleInterface`（`Public/ITimeManagementModule.h` 第 16 行）；按需加载宏见第 10 行。

## 六、关键约定与坑

1. **基础类型不在本模块**：`Public/FrameRate.h`、`Public/FrameTime.h`、`Public/QualifiedFrameTime.h`、`Public/Timecode.h`、`Public/TimecodeProvider.h` 实测**均不存在**——实现在 Core / Engine（见第四节）；本模块仅前置声明（如 `TimeManagementBlueprintLibrary.h` 第 22 行）。
2. **零生命周期覆写**：`FTimeManagementModule` 有类但**不覆写 Startup/Shutdown**（本套件第 2 个此类模块；`Navmesh` 是直接复用 `FDefaultModuleImpl`，本模块是有类零覆写）。
3. **依赖 Slate/SlateCore**（第 13-14 行）——模块内含编辑器 Widgets，为少数"运行时基础 + UI 组件"混装模块。
4. **数字口径**：`TimeManagement.Build.cs` 19 行（`ReadAllLines`）、0 处 `if`、0 处三方静态调用；公开侧 26 个 `.h`（顶层 16）、模块合计 29。取数命令见「取数说明」。

## 取数说明

以下命令的相对基准为 `Engine/Source`（实际路径按 `_meta/convention.md` 的本机环境块解析）：

| 断言 | 取数方式 |
|---|---|
| 本模块为第 **2** 个"零生命周期覆写"模块 | `[H]` 逐模块核对 `StartupModule` / `ShutdownModule`：`Navmesh`（复用 `FDefaultModuleImpl`）为第 **1** 个，本模块第 **2** 个 |
| 55 文件 / 29 头文件 | `[M]` 引擎磁盘递归计数：`(Get-ChildItem "Runtime/TimeManagement" -Recurse -File).Count` 得文件数；`(Get-ChildItem "Runtime/TimeManagement" -Recurse -File -Filter *.h).Count` 得头文件数（同 `_meta/engine-modules.json` 口径） |
| 公开侧 26 个 `.h`（顶层 16） | `[M]` `(Get-ChildItem "Runtime/TimeManagement/Public" -Recurse -File -Filter *.h).Count` 与顶层计数 |
| Build.cs 19 行、0 处 `if`、0 处三方静态调用 | `[M]` `[System.IO.File]::ReadAllLines("Runtime/TimeManagement/TimeManagement.Build.cs").Count`；`Select-String "Runtime/TimeManagement/TimeManagement.Build.cs" -Pattern '\bif\s*\(' -AllMatches`；`Select-String "Runtime/TimeManagement/TimeManagement.Build.cs" -Pattern 'AddEngineThirdPartyPrivateStaticDependencies' -AllMatches` |
| 全部行号引用 | 2026-10-10 对 UE 5.8.3 源码本机逐条核对 |

## 相关文档

- `types/FFrameRate.md` —— 帧率基础类型（归属 Core，随本批产出）
- `modules/UniversalObjectLocator-结构.md` —— 同批模块
- `modules/MovieScene-结构.md`、`modules/LevelSequence-结构.md` —— 主要消费方（批 6/批 9）
- `modules/Engine-结构.md` —— `UTimecodeProvider` 归属

## 更新记录

- 2026-10-11 「取数说明」补入 1 行计数断言取数方式（`convention.md` 4.2 覆盖要求）

- 2026-10-11 按规范 4.2.1 为「取数说明」各行加方法标记（`[M]`/`[R]`/`[H]`）；`[M]` 行把原文省略成 `(...)` 的路径补全为白名单可执行命令，现由 `ue-doc-verify` 逐条实际执行比对
