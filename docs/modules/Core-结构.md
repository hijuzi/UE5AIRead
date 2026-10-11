> 引擎版本：UE 5.8.3 (Build 58210709)
> 源码根：Engine/Source
> 生成技能：ue-module-structure v1.0
> 生成时间：2026-10-10
> 校验状态：已校验（2026-10-11）

# Core 模块结构

## 一、模块定位

| 项 | 值 |
|---|---|
| 路径 | `Engine/Source/Runtime/Core` |
| 类别 | Runtime |
| 规模 | 2,171 文件 / 1,368 头文件（`_meta/engine-modules.json` 2026-10-10 盘点口径，含模块目录内嵌套文件之和）；其中 `Public/` 下 `.h` 1,265 个、`Public/` 子目录 49 个 |
| 分层 | 地基 |
| 一句话职责 | 引擎最底层基础设施——容器、字符串、内存、数学、HAL、日志、委托、异步任务；不依赖任何功能层模块（仅构建支持与第三方库），全引擎其余模块几乎都直接或间接依赖它 |

## 二、目录结构

```
Core/
├── Core.Build.cs                 # 模块构建脚本（376 行）
├── Core_APL.xml                  # Android 构建收据附加文件（仅 Android 分支引用，Build.cs 第 33-34 行）
├── Public/                       # 对外契约（1,265 个 .h / 49 个子目录）
│   ├── 根文件：Core.h、CoreFwd.h、CoreGlobals.h、CoreMinimal.h、CoreSharedPCH.h、CoreTypes.h、PixelFormat.h
│   └── 功能分区：Algo/ Async/ Containers/ Delegates/ GenericPlatform/ HAL/ IO/ Internationalization/
│       Logging/ Math/ Memory/ Misc/ Modules/ ProfilingDebugging/ Serialization/ Stats/ String/ Tasks/
│       Templates/ Traits/ UObject/ Virtualization/
│       平台特化：Android/ Apple/ IOS/ Linux/ Mac/ Microsoft/ MSVC/ Unix/ Windows/ …
├── Private/                      # 实现（子目录与 Public 基本对称，另有 Thirdparty/、Instrumentation/）
├── Internal/                     # 内部共享（不在 Public 契约内，见第六节）
├── Tests/                        # 测试代码根（按子系统再分目录）
├── Public/Tests + Private/Tests  # 测试支撑（Assertions.h、TestHarnessAdapter.h 等头与实现）
```

- `Public/` 与 `Private/` 分离；另有含义不同的 `Internal/`——**不要把它当作 `Public/`**。
- `Tests/` 属测试代码，本版标注不展开。

## 三、依赖关系

### 3.1 无条件依赖

| 模块 | 类型 | Build.cs 行 | 说明 |
|---|---|---|---|
| `BuildSettings` | 私有依赖 | 20 | 构建期设置 |
| `AtomicQueue` | 私有依赖 + 公开依赖 | 40、49 | 同一模块同时列入两张列表，**实测如此，非笔误，勿去重** |
| `AutoRTFM` | 私有依赖 ×2 + 公开包含路径 | 41、327、59 | 3 处出现：两处私有依赖（内容重复）+ 一处公开包含路径 |
| `BLAKE3` | 私有依赖 | 42 | 第三方哈希库（以模块形式引入） |
| `OodleDataCompression` | 私有依赖 | 43 | 第三方压缩库（模块形式） |
| `xxhash` | 私有依赖 | 44 | 第三方哈希库（模块形式） |
| `GuidelinesSupportLibrary` | 公开依赖 | 47 | GSL（Guidelines Support Library） |
| `TraceLog` | 公开依赖 | 48 | Trace 事件日志 |
| `DerivedDataCache` | 私有包含路径 | 52 | 仅加包含路径，不链接 |
| `TargetPlatform` | 私有包含路径 | 53 | 同上 |
| `Json` | 私有包含路径 | 54 | 同上 |
| `RSA` | 私有包含路径 | 55 | 同上 |

> 辅助成员检查：`Core.Build.cs` 里的 `SupportsBinaryConfig`（第 360-363 行）与 `bWithMallocStomp`（第 367-374 行）
> **只产出编译定义、不追加依赖**——"辅助函数会追加依赖"这一漏项检查在本模块不适用。

### 3.2 平台与配置条件依赖

> `Core.Build.cs` 全文含 **39 处 `if` 分支**（含 `else if`），下表按"平台 / 配置 / 功能开关"归并为 22 行。

| 依赖 | 类型 | 生效条件 | Build.cs 行 |
|---|---|---|---|
| `GoogleGameSDK`、`VKQuality` | 私有依赖 | `Target.Platform == UnrealTargetPlatform.Android` | 23-24 |
| `VulkanRHI` | 私有包含路径 | 同上（注释：供 `AndroidPlatformMisc`） | 26 |
| `libGPUCounters`、`heapprofd` | 私有依赖 | Android 且 `Configuration != Shipping` | 30-31 |
| `DirectoryWatcher` | 私有包含路径 + 动态加载 | `bBuildEditor == true` | 64-65 |
| `libpas` | 私有依赖 | `Platform == Win64`（并定义 `PLATFORM_BUILDS_LIBPAS=1`） | 71 |
| `mimalloc` | 私有依赖 | Windows 平台组且 `StaticAnalyzer == None` | 91 |
| `WinPixEventRuntime` | 私有依赖 | Windows 平台组且 `bPixProfilingEnabled && 非 Shipping` | 110 |
| `ApplicationCore` | 私有包含路径 | （Windows 平台组或 IOS 平台组）且 `bCompileAgainstApplicationCore` | 120、164 |
| `ConcurrencyVisualizer`、`SuperLuminal`、`VSPerfExternalProfiler` | 私有依赖 | Windows 平台组且非 Shipping | 277-283 |
| `Detours` | 私有依赖 | Windows 平台组且（非 Shipping 或启用插桩 `bEnableInstrumentation`） | 339 |
| `mimalloc` | 私有依赖 | Mac | 132 |
| Mac 系统框架（`Cocoa`、`Carbon`、`IOKit`、`Security`、`UniformTypeIdentifiers`、`Network`、`ScreenCaptureKit`、`SystemConfiguration`） | 系统框架 | Mac | 130 |
| `MultitouchSupport` | 附加静态库（路径式） | Mac 且 `bBuildEditor` | 137-138 |
| IOS 平台组系统框架（`UIKit`、`Foundation`、`AudioToolbox`、`AVFoundation`、`GameKit`、`CoreVideo`、`CoreMedia`、`CoreGraphics`、`GameController`、`SystemConfiguration`、`DeviceCheck`、`UserNotifications`、`Network`；IOS 追加 `CoreMotion`、`AdSupport`、`WebKit`；VisionOS 追加 `CoreMotion`） | 系统框架 | IOS 平台组（括号内为更细分支） | 146-160 |
| `MarketplaceKit` | 私有包含路径 | `Platform == IOS` | 155 |
| `mimalloc212` | 私有依赖 | IOS 平台组或 Android 平台组 | 249 |
| `mimalloc` | 私有依赖 | Unix 平台组且未启用 MemorySanitizer | 216 |
| `dl` | 系统库（`PublicSystemLibraries`） | Unix 平台组 | 210 |
| LinuxUEKernelTools 源码路径 | 私有包含路径（路径式） | Linux 平台组且 `ENABLE_LINUX_UE_KERNEL_TOOLS=1` | 241-244 |
| ScudoMemoryTrace 源码路径 | 私有包含路径（路径式） | Android 平台组且非 Shipping | 197-199 |
| `DerivedDataCache`、`Virtualization` | 动态加载 | `bCompileAgainstEngine && !bBuildRequiresCookedData` | 264-265 |
| `Contacts` | 系统框架 | Apple 平台组、非 TVOS，且启用联系人管理 | 353 |

### 3.3 第三方静态依赖

`AddEngineThirdPartyPrivateStaticDependencies` 全文调用 **8 处**：

| 三方库 | 生效条件 | Build.cs 行 |
|---|---|---|
| `IntelTBB`、`zlib` | Windows 平台组 | 76-79 |
| `IntelVTune` | Windows 平台组且非 Arm64 | 83-85 |
| `IntelTBB`、`zlib`、`PLCrashReporter` | Mac | 125-129 |
| `zlib` | IOS 平台组 | 143-145 |
| `PLCrashReporter` | IOS（非 VisionOS） | 151-153 |
| `cxademangle`、`zlib`、`libunwind` | Android 平台组 | 183-187 |
| `zlib`、`jemalloc` | Unix 平台组 | 204-207 |
| `ICU` | `bCompileICU == true` | 255 |

> `BLAKE3`、`OodleDataCompression`、`xxhash` 虽为第三方库，但经 `PrivateDependencyModuleNames`
> 以**模块**形式引入，因此列在 3.1，不属本表。

## 四、对外暴露面

> 只列 `Public/` 下的头文件。全模块公开头共 1,265 个，下表为承担主要契约的核心头。

| 头文件 | 提供的能力 |
|---|---|
| `CoreMinimal.h` | 最小聚合头：基础类型 + HAL 平台 + 断言 + 内存等（近零依赖，可广泛包含） |
| `Core.h` | 完整聚合头：在 `CoreMinimal.h` 之上继续引入容器、字符串、数学、时间等（开头带 MONOLITHIC_HEADER_BOILERPLATE） |
| `CoreTypes.h` | 基础类型入口：转发 `HAL/Platform.h` 与 `Misc/CoreMiscDefines.h`、`Misc/CoreDefines.h`（第 10-13 行）。`int32` 等基础类型定义链终点在 `GenericPlatform/GenericPlatform.h` 第 57 行，由 `HAL/Platform.h` 第 1190 行 re-export |
| `CoreFwd.h` | 引擎常用类型前置声明集合 |
| `CoreGlobals.h` | 全局变量声明：`GLog`、`GConfig`、`GWarn`、`GMalloc` 等 |
| `Containers/Array.h` | `TArray`（动态数组） |
| `Containers/Map.h` | `TMap` / `TSparseMap` / `TCompactMap`（宏注入式定义，见第六节） |
| `Containers/Set.h` | `TSet` / `TSparseSet`（宏注入式定义，见第六节） |
| `Containers/UnrealString.h` | `FString`（类声明在 `Containers/UnrealString.h.inl` 第 58 行，经 `UE_STRING_CLASS` 注入） |
| `Containers/StringConv.h` | 字符串转换：`StringCast`、`TCHAR_TO_UTF8` 等 |
| `Templates/SharedPointer.h` | 共享指针族：`TSharedPtr`、`TSharedRef`、`TWeakPtr` |
| `Templates/Function.h`、`Templates/UniquePtr.h`、`Templates/Tuple.h` | `TFunction`、`TUniquePtr`、`TTuple` |
| `Math/UnrealMathUtility.h` | `FMath` 数学工具 |
| `Delegates/Delegate.h` | 委托体系声明宏（`DECLARE_DELEGATE` 系列） |
| `Modules/ModuleManager.h` | 模块系统：`FModuleManager`、`IMPLEMENT_MODULE` |
| `HAL/Platform.h` | 平台抽象总入口（基础类型 re-export、平台宏） |
| `HAL/PlatformMisc.h` | `FPlatformMisc` 平台杂项接口 |
| `GenericPlatform/GenericPlatformMemory.h` | `FGenericPlatformMemory` 平台内存抽象（内存统计基类） |
| `Logging/LogMacros.h` | 日志宏：`UE_LOG`、`DEFINE_LOG_CATEGORY`（本版无 `Logging/Log.h`，日志头按用途拆分，见第六节） |
| `Misc/AssertionMacros.h` | 断言宏：`check` / `ensure` 系列 |
| `Misc/`（`CoreMisc.h`、`Guid.h`、`Crc.h`） | 核心杂项：`FSelfRegisteringExec`（执行注册）、`FGuid`、CRC 校验 |
| `Misc/OutputDevice.h` | `FOutputDevice` 输出设备基类（第 137 行）——日志/控制台聚合链的基础 |
| `UObject/NameTypes.h` | `FName`（**定义在 Core，不在 CoreUObject**） |
| `Internationalization/Text.h` | `FText` 与本地化文本体系 |
| `Serialization/Archive.h` | `FArchive` 序列化基类 |
| `Async/Async.h`、`Tasks/Task.h` | 异步任务：`Async()` 入口与 `FTask` 任务图 |
| `Stats/Stats.h` | 统计系统宏：`DECLARE_STATS_GROUP` 等 |

## 五、模块生命周期

```
文件：Engine/Source/Runtime/Core/Private/Misc/CoreGlobals.cpp
行 38-46：FCoreModule 类定义（仅覆写 SupportsDynamicReloading，返回 false）

文件：Engine/Source/Runtime/Core/Private/Misc/CoreGlobals.cpp
行 49：IMPLEMENT_MODULE( FCoreModule, Core );
```

- **入口宏**：`IMPLEMENT_MODULE( FCoreModule, Core );`（第 49 行）
- **模块类**：`FCoreModule : public FDefaultModuleImpl`（第 38-46 行）
- **`StartupModule()` / `ShutdownModule()`**：**未覆写**，沿用 `FDefaultModuleImpl` 默认实现——"未覆写"与"没有入口类"是两回事，如实记录
- **动态重载**：`SupportsDynamicReloading()` 返回 `false`（第 41-45 行，源码注释：`Core cannot be unloaded or reloaded`）
- 模块系统设施本身（`FModuleManager`）由本模块提供，见 `Public/Modules/ModuleManager.h`

## 六、关键约定与坑

1. **`TMap` / `TSet` / `FString` 是"宏注入式定义"——字面文本搜索会零命中。** 直接搜 `class TMap` 零命中**不代表类型不存在**：

```
文件：Engine/Source/Runtime/Core/Public/Containers/Map.h
行 140-149：三次宏前缀注入（UE_TMAP_PREFIX 依次为 T / TSparse / TCompact）后包含 Map.h.inl

文件：Engine/Source/Runtime/Core/Public/Containers/Map.h.inl
行 1179：TMap 类定义行（类名为宏拼接后的名字）

文件：Engine/Source/Runtime/Core/Public/Containers/Set.h
行 31-33：默认分支（UE_USE_COMPACT_SET_AS_DEFAULT == 0，定义于 Containers/ContainerAllocationPolicies.h 第 1912 行）将 UE_TSPARSE_SET 定为 TSet 后包含 SparseSet.h.inl

文件：Engine/Source/Runtime/Core/Public/Containers/SparseSet.h.inl
行 58：TSet 类声明行（宏拼接名 UE_TSPARSE_SET）

文件：Engine/Source/Runtime/Core/Public/Containers/UnrealString.h
行 13-18：UE_STRING_CLASS 定为 FString 后包含 UnrealString.h.inl

文件：Engine/Source/Runtime/Core/Public/Containers/UnrealString.h.inl
行 58：FString 类声明行（宏拼接名 UE_STRING_CLASS）
```

   查证此类时的顺序：先搜 `.inl`，再搜宏注入点。

2. **依赖表里的多处出现是实测事实，勿去重**：`AtomicQueue` 同时是私有与公开依赖；`AutoRTFM` 出现 3 次（第 41、327、59 行），见 3.1。
3. **`Internal/` 不是公开边界**：它位于模块根，不在 `Public/` 下。实测 `Engine/Source/Runtime` 内仅 Core 自身的 `Public/IO/IoDispatcherBackend.h`（第 12-13 行）引用 `Runtime/Core/Internal/`。对外暴露面只应使用 `Public/` 下的路径。
4. **数字口径**：`Core.Build.cs` 376 行（`ReadAllLines` 口径；read_file 显示 377 属 EOF 渲染）；`if` 分支 39 处；三方静态依赖调用 8 处。取数命令见「取数说明」。
5. **构建期要点**：`bRequiresPlatformSDK = true`（第 12 行）；Unity 大小覆写 491520（第 14 行）；私有 PCH `Private/CorePrivatePCH.h`、共享 PCH `Public/CoreSharedPCH.h`（第 16-18 行）；Android 分支额外挂接 `Core_APL.xml` 构建收据（第 33-34 行）。
6. **本版不存在 `Logging/Log.h`**（实测）——日志头按用途拆分（`LogMacros.h`、`LogVerbosity.h`、`LogCategory.h` 等），不要按旧版印象引用。

## 取数说明

以下命令的相对基准为 `Engine/Source`（`<引擎源码根>`，实际路径按 `_meta/convention.md` 的本机环境块解析）：

| 断言 | 取数方式 |
|---|---|
| 2,171 文件 / 1,368 头文件 | `[M]` 引擎磁盘递归计数：`(Get-ChildItem "Runtime/Core" -Recurse -File).Count` 得文件数；`(Get-ChildItem "Runtime/Core" -Recurse -File -Filter *.h).Count` 得头文件数（同 `_meta/engine-modules.json` 口径） |
| `Public/` 1,265 个 `.h`、49 个子目录 | `[M]` `(Get-ChildItem "Runtime\Core\Public" -Recurse -File -Filter *.h).Count`、`(Get-ChildItem "Runtime\Core\Public" -Directory).Count` |
| `Core.Build.cs` 376 行 | `[M]` `[System.IO.File]::ReadAllLines("Runtime/Core/Core.Build.cs").Count` |
| `if` 分支 39 处 | `[M]` `Select-String "Runtime\Core\Core.Build.cs" -Pattern '\bif\s*\(' -AllMatches` 的全匹配计数 |
| 三方静态依赖调用 8 处 | `[M]` `Select-String "Runtime/Core/Core.Build.cs" -Pattern 'AddEngineThirdPartyPrivateStaticDependencies' -AllMatches` |
| 全部行号引用 | 2026-10-10 对 UE 5.8.3 源码本机逐条核对 |

## 相关文档

- `modules/CoreUObject-结构.md` —— 同批产出的下游模块（`UObject` / 反射 / GC）
- `types/FName.md` —— `FName` 定义于本模块 `Public/UObject/NameTypes.h`
- `types/UObject.md` —— `UObject` 属 `CoreUObject` 模块
- `flows/UObject创建流程.md` —— 对象创建主路径（已校验）

## 更新记录

- 2026-10-11 按规范 4.2.1 为「取数说明」各行加方法标记（`[M]`/`[R]`/`[H]`）；`[M]` 行把原文省略成 `(...)` 的路径补全为白名单可执行命令，现由 `ue-doc-verify` 逐条实际执行比对
