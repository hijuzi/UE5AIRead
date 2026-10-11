> 引擎版本：UE 5.8.3 (Build 58210709)
> 源码根：Engine/Source
> 生成技能：ue-module-structure v1.0
> 生成时间：2026-10-10
> 校验状态：已校验（2026-10-11）

# NetCore 模块结构

## 一、模块定位

| 项 | 值 |
|---|---|
| 路径 | `Engine/Source/Runtime/Net/Core`（**注意：不是 `Runtime/NetCore`**；`Runtime/Net/` 下并列三模块：`Core`（本模块）/ `Common`（NetCommon）/ `Iris`（IrisCore）） |
| 类别 | Runtime |
| 规模 | 82 文件 / 47 头文件（`_meta/engine-modules.json` 2026-10-10 口径：公开侧 38 + `Classes/` 3 + `Private/` 6） |
| 分层 | 框架 |
| 一句话职责 | 网络底层核心：`FNetHandle` 对象句柄、Fast Array 序列化（`FFastArraySerializer`）、Push Model 与属性条件（PropertyConditions）、脏对象追踪（DirtyNetObjectTracker）与网络分析（Analytics） |

## 二、目录结构

```
Net/Core/
├── NetCore.Build.cs              # 模块构建脚本（30 行、1 处 if 分支）
├── Classes/                      # 公开侧之一（UHT 旧式反射头，3 个 .h）
│   └── Net/Analytics/NetAnalyticsAggregatorConfig.h；Net/Serialization/FastArraySerializer.h、FastArraySerializerImplementation.h
├── Public/                       # 公开侧之二（38 个 .h，全部在 Public/Net/Core/ 下；Public 根无文件）
│   ├── Public/Net/Core/ 直属 3 个：NetBitArray.h / NetBitArrayPrinter.h / NetCoreModule.h
│   └── Public/Net/Core/ 子目录：Analytics/ Connection/ DirtyNetObjectTracker/ Misc/ NetHandle/
│       NetToken/ PropertyConditions/ PushModel/ Serialization/ Trace/
└── Private/                      # 实现（34 个 .cpp + 6 个 .h；同名子目录展开；另有 Private/Net/Serialization/）
```

- 无 `Internal/`、无 `Tests/`（测试文件 `Private/Net/Core/Misc/ResizableCircularQueueTests.cpp` 不在 Tests 目录）；无聚合头。

## 三、依赖关系

### 3.1 无条件依赖

| 模块 | 类型 | Build.cs 行 | 说明 |
|---|---|---|---|
| `Core` | 公开依赖 | 14 | |
| `CoreUObject` | 公开依赖 | 15 | |
| `TraceLog` | 公开依赖 | 16 | |
| `NetCommon` | 公开依赖 | 17 | 同级模块（`Runtime/Net/Common`；本版未产出其文档） |

> 无私有依赖列表；辅助函数检查：**无**（无 UBT 辅助调用）——无未展开依赖。
> 另：`CppCompileWarningSettings.UnsafeTypeCastWarningLevel = WarningLevel.Error;`（第 21 行）。

### 3.2 平台与配置条件依赖

> 全文 **1 处 `if` 分支**（第 25 行）。

| 项 | 类型 | 生效条件 | Build.cs 行 |
|---|---|---|---|
| `NET_ANALYTICS_MULTITHREADING=1` | 编译定义（**非模块依赖**） | `!Target.bExcludeParallelIrisSupport && !(Type == TargetType.Client \|\| Type == TargetType.Program)` | 25-28 |

> 该条件块**不追加任何模块依赖**——只加编译定义。

### 3.3 第三方静态依赖

调用 **0 处**——无第三方静态依赖。

## 四、对外暴露面

> 公开侧共 41 个 `.h`（38 Public + 3 Classes）；核心如下。

| 头文件 | 提供的能力 |
|---|---|
| `Engine/Source/Runtime/Net/Core/Classes/Net/Serialization/FastArraySerializer.h` | `FFastArraySerializer`（第 408 行）→ `types/FFastArraySerializer.md` |
| `Engine/Source/Runtime/Net/Core/Public/Net/Core/NetHandle/NetHandle.h` | `FNetHandle`（第 31 行，`namespace UE::Net`）——复制对象句柄 |
| `Engine/Source/Runtime/Net/Core/Public/Net/Core/NetBitArray.h` | `FNetBitArray` 位数组 |
| `Engine/Source/Runtime/Net/Core/Public/Net/Core/NetCoreModule.h` | 模块导出变量（第 7 行 `GUseDetailedScopeCounters`） |
| `Public/Net/Core/PropertyConditions/`（子目录） | 属性条件框架（Push-Model 前置） |
| `Public/Net/Core/PushModel/`（子目录） | Push Model（`MARK_PROPERTY_DIRTY` 体系） |
| `Public/Net/Core/DirtyNetObjectTracker/`（子目录） | 脏对象追踪 |
| `Public/Net/Core/NetToken/`（子目录） | 网络 Token |
| `Public/Net/Core/Analytics/`（子目录） | 网络分析 |
| `Public/Net/Core/Trace/`（子目录） | 网络 Trace |

## 五、模块生命周期

```
文件：Engine/Source/Runtime/Net/Core/Private/Net/Core/NetCoreModule.cpp
行 28：class FNetCoreModule : public IModuleInterface
行 50：IMPLEMENT_MODULE(FNetCoreModule, NetCore);
```

- **`SupportsDynamicReloading` 显式覆写为 `false`**（第 43-45 行）——本模块**禁止热重载**（已产出模块中第二个显式覆写者；Renderder 覆写为 `true` 是第一个）。
- **`StartupModule()`**（第 31-35 行）：`UE::Net::FNetHandleManager::Init();`（第 33 行）、`UE::Net::FGlobalDirtyNetObjectTracker::Init();`（第 34 行）。
- **`ShutdownModule()`**（第 37-41 行）：逆序 `Deinit`（第 39-40 行）。
- 文件级设施：`GUseDetailedScopeCounters`（第 14 行）、`net.EnableDetailedScopeCounters` CVar（第 15-19 行）、日志类别（第 21 / 23 行）、CSV 类别（第 25 行）。

## 六、关键约定与坑

1. **路径易错**：模块名 `NetCore` 但路径是 `Engine/Source/Runtime/Net/Core`；同级还有 `Net/Common`（NetCommon）与 `Net/Iris`（IrisCore）——计数与文档不要混入。
2. **`FNetBitReader` / `FNetBitWriter` / `UPackageMap` 都不在本模块**：定义在 **CoreUObject**（`Public/UObject/CoreNet.h` 第 414 / 383 / 190 行）；`FNetworkGUID` 在 **Core**（`Public/Misc/NetworkGuid.h` 第 11 行）；`FNetSerializationContext` 在 **IrisCore**。本模块自己的核心类型是 `FNetHandle`（`Public/Net/Core/NetHandle/NetHandle.h` 第 31 行）。
3. **`Public/` 根目录无 `.h`**（全部在 `Public/Net/Core/` 下）；公开侧还包括 `Classes/`（旧式布局）。
4. **数字口径**：`NetCore.Build.cs` 30 行（`ReadAllLines`）、1 处 `if`（仅编译定义、不加依赖）、0 处三方静态调用；公开侧 41 个 `.h`。取数命令见「取数说明」。

## 取数说明

以下命令的相对基准为 `Engine/Source`（实际路径按 `_meta/convention.md` 的本机环境块解析）：

| 断言 | 取数方式 |
|---|---|
| 公开侧 **41** 个 `.h`（`Public/` **38** + `Classes/` **3**） | `[M]` `(Get-ChildItem "Runtime/Net/Core/Public" -Recurse -File -Filter *.h).Count` → 38；`(Get-ChildItem "Runtime/Net/Core/Classes" -Recurse -File -Filter *.h).Count` → 3 |
| 82 文件 / 47 头文件 | `[M]` 引擎磁盘递归计数：`(Get-ChildItem "Runtime/Net/Core" -Recurse -File).Count` 得文件数；`(Get-ChildItem "Runtime/Net/Core" -Recurse -File -Filter *.h).Count` 得头文件数（同 `_meta/engine-modules.json` 口径） |
| 公开侧 38 个 `.h`（Public 根 0） | `[M]` `(Get-ChildItem "Runtime/Net/Core/Public" -Recurse -File -Filter *.h).Count` |
| Build.cs 30 行、1 处 `if`、0 处三方静态调用 | `[M]` `[System.IO.File]::ReadAllLines("Runtime/Net/Core/NetCore.Build.cs").Count`；`Select-String "Runtime/Net/Core/NetCore.Build.cs" -Pattern '\bif\s*\(' -AllMatches`；`Select-String "Runtime/Net/Core/NetCore.Build.cs" -Pattern 'AddEngineThirdPartyPrivateStaticDependencies' -AllMatches` |
| 全部行号引用 | 2026-10-10 对 UE 5.8.3 源码本机逐条核对 |

## 相关文档

- `types/FFastArraySerializer.md` —— 本模块核心类型（同批产出）
- `modules/GameplayTasks-结构.md` —— 公开依赖本模块的模块（同批产出）
- `modules/PhysicsCore-结构.md` —— 同批模块
- （注：`FNetBitReader` / `FNetBitWriter` 属 CoreUObject 模块，本版未成篇）

## 更新记录

- 2026-10-11 「取数说明」补入 1 行计数断言取数方式（`convention.md` 4.2 覆盖要求）

- 2026-10-11 按规范 4.2.1 为「取数说明」各行加方法标记（`[M]`/`[R]`/`[H]`）；`[M]` 行把原文省略成 `(...)` 的路径补全为白名单可执行命令，现由 `ue-doc-verify` 逐条实际执行比对
