> 引擎版本：UE 5.8.3 (Build 58210709)
> 源码根：Engine/Source
> 生成技能：ue-module-structure v1.0
> 生成时间：2026-10-10
> 校验状态：已校验（2026-10-11）

# IrisCore 模块结构

## 一、模块定位

| 项 | 值 |
|---|---|
| 路径 | `Engine/Source/Runtime/Net/Iris`（**模块名 `IrisCore`**） |
| 类别 | Runtime |
| 规模 | 363 文件 / 197 头文件（`_meta/engine-modules.json` 2026-10-10 口径；公开侧 120 + `Private/` 77） |
| 分层 | 框架 |
| 一句话职责 | Iris 复制系统：复制系统（`UReplicationSystem`）、复制桥（`UReplicationBridge` / `UObjectReplicationBridge`）、序列化器（`FNetSerializer` / `FNetSerializationContext`）、复制状态描述（`FReplicationStateDescriptor`）与对象过滤（`UNetObjectFilter`） |

## 二、目录结构

```
Net/Iris/
├── IrisCore.Build.cs             # 模块构建脚本（32 行、1 处 if 分支）
├── IrisCore.natvis
├── Public/Iris/                  # 公开侧（120 个 .h；Public 根无文件）
│   ├── IrisConfig.h / IrisConstants.h（Public/Iris 顶层仅此 2 个）
│   └── 子目录（8）：Config/ Core/ DataStream/ Metrics/ PacketControl/ ReplicationState/ ReplicationSystem/ Serialization/
└── Private/Iris/                 # 实现（77 个 .h + 162 个 .cpp；子目录同名展开 + Stats/；含 Readme.txt 占位）
```

- **特殊**：`Public/Iris/ReplicationState/Private/IrisFastArraySerializerInternal.h`——公开树内嵌一个 `Private/` 子目录。
- 无 `Internal/`、无 `Tests/`；无聚合头（`Iris.h` 实测 0 命中）。

## 三、依赖关系

### 3.1 无条件依赖

| 模块 | 类型 | Build.cs 行 | 说明 |
|---|---|---|---|
| `Core` | 公开依赖 | 12 | |
| `CoreUObject` | 公开依赖 | 13 | |
| `NetCore` | 公开依赖 | 14 | Startup 时强制加载（见第五节） |
| `TraceLog` | 公开依赖 | 15 | |

> 另：`PublicDefinitions.Add("UE_WITH_IRIS=1");`（第 20 行，注释"scheduled for removal"）。
> 警告等级：`UnsafeTypeCastWarningLevel`（第 28 行）与 `ReturnTypeWarningLevel`（第 29 行）均为 `Error`。
> 辅助函数检查：**无**——无未展开依赖。

### 3.2 平台与配置条件依赖

> 全文 **1 处 `if` 分支**（第 23 行）。

| 项 | 类型 | 生效条件 | Build.cs 行 |
|---|---|---|---|
| `UE_SUPPORT_PARALLEL_IRIS=1` | 编译定义（**非模块依赖**） | `!Target.bExcludeParallelIrisSupport && !(Type == TargetType.Client \|\| Type == TargetType.Program)` | 23-26 |

### 3.3 第三方静态依赖

调用 **0 处**——无第三方静态依赖。

## 四、对外暴露面

> 公开侧共 120 个 `.h`；核心如下。

| 头文件 | 提供的能力 |
|---|---|
| `Engine/Source/Runtime/Net/Iris/Public/Iris/ReplicationSystem/ReplicationSystem.h` | `UReplicationSystem`（第 79 行）→ `types/UReplicationSystem.md` |
| `Engine/Source/Runtime/Net/Iris/Public/Iris/ReplicationSystem/ReplicationBridge.h` | `UReplicationBridge`（第 126 行） |
| `Engine/Source/Runtime/Net/Iris/Public/Iris/ReplicationSystem/ObjectReplicationBridge.h` | `UObjectReplicationBridge`（第 117 行，`: UReplicationBridge`） |
| `Engine/Source/Runtime/Net/Iris/Public/Iris/ReplicationSystem/Filtering/NetObjectFilter.h` | `UNetObjectFilter`（第 191 行） |
| `Engine/Source/Runtime/Net/Iris/Public/Iris/Serialization/NetSerializer.h` | `FNetSerializer`（第 376 行，`UE::Net`） |
| `Engine/Source/Runtime/Net/Iris/Public/Iris/Serialization/NetSerializationContext.h` | `FNetSerializationContext`（第 30 行，`UE::Net`） |
| `Engine/Source/Runtime/Net/Iris/Public/Iris/ReplicationState/ReplicationStateDescriptor.h` | `FReplicationStateDescriptor`（第 198 行，`UE::Net`） |
| `Engine/Source/Runtime/Net/Iris/Public/Iris/IrisConfig.h` | Iris 配置 |

## 五、模块生命周期

```
文件：Engine/Source/Runtime/Net/Iris/Private/Iris/IrisCoreModule.cpp
行 25：class FIrisCoreModule : public IModuleInterface
行 219：IMPLEMENT_MODULE(FIrisCoreModule, IrisCore);
```

- **`SupportsDynamicReloading` 显式覆写为 `false`**（第 98-100 行）——已产出模块中第 3 个显式覆写者（前两个：Renderer=`true`、NetCore=`false`）。
- **`StartupModule()`**（第 43-75 行）：
  1. 强制加载 NetCore：`FModuleManager::LoadModuleChecked<IModuleInterface>("NetCore");`（第 46 行，注释"Iris requires NetCore"）
  2. 注册 `FCoreDelegates::OnAllModuleLoadingPhasesComplete`（第 48 行）
  3. 命令行覆盖复制系统选择（第 51-56 行）
  4. `RegisterPropertyNetSerializerSelectorTypes();`（第 58 行；流程：Reset → PreFreeze 广播 → 注册默认序列化器 → Freeze → PostFreeze 广播）
  5. `UE_NET_IRIS_INIT_LEGACY_PUSH_MODEL();`（第 60 行）；`#if UE_NET_ENABLE_IRISCREATIONFLOWLOG` 下初始化 CreationFlowLog（第 62-64 行）
  6. 注册模块变更 / 复制系统 created-destroyed 委托并统计实例数（第 66-74 行）
- **`ShutdownModule()`**：第 77 行起。

## 六、关键约定与坑

1. **路径是 `Runtime/Net/Iris`**（模块名 `IrisCore`）；`Net/` 三兄弟：`Core`（NetCore）/ `Common`（NetCommon）/ `Iris`（IrisCore）。
2. **`Public/` 根无 `.h`**（全在 `Public/Iris/` 下）；`Public/Iris/` 顶层只有 `IrisConfig.h`、`IrisConstants.h`。
3. **命名空间要仔细看**：`UReplicationSystem` / `UReplicationBridge` / `UNetObjectFilter` 在**全局作用域**（文件内的 `UE::Net` 块服务于其它声明）；而 `FNetSerializer` / `FNetSerializationContext` / `FReplicationStateDescriptor` 在 **`UE::Net`** 内。
4. **数字口径**：`IrisCore.Build.cs` 32 行（`ReadAllLines`）、1 处 `if`（仅编译定义、不加依赖）、0 处三方静态调用；公开侧 120 个 `.h`（模块合计 197）。取数命令见「取数说明」。

## 取数说明

以下命令的相对基准为 `Engine/Source`（实际路径按 `_meta/convention.md` 的本机环境块解析）：

| 断言 | 取数方式 |
|---|---|
| 363 文件 / 197 头文件 | `[M]` 引擎磁盘递归计数：`(Get-ChildItem "Runtime/Net/Iris" -Recurse -File).Count` 得文件数；`(Get-ChildItem "Runtime/Net/Iris" -Recurse -File -Filter *.h).Count` 得头文件数（同 `_meta/engine-modules.json` 口径） |
| 公开侧 120 个 `.h`（Public 根 0） | `[M]` `(Get-ChildItem "Runtime/Net/Iris/Public" -Recurse -File -Filter *.h).Count` |
| Build.cs 32 行、1 处 `if`、0 处三方静态调用 | `[M]` `[System.IO.File]::ReadAllLines("Runtime/Net/Iris/IrisCore.Build.cs").Count`；`Select-String "Runtime/Net/Iris/IrisCore.Build.cs" -Pattern '\bif\s*\(' -AllMatches`；`Select-String "Runtime/Net/Iris/IrisCore.Build.cs" -Pattern 'AddEngineThirdPartyPrivateStaticDependencies' -AllMatches` |
| 全部行号引用 | 2026-10-10 对 UE 5.8.3 源码本机逐条核对 |

## 相关文档

- `types/UReplicationSystem.md` —— 本模块核心类型（同批产出）
- `modules/NetCore-结构.md` —— 依赖与加载前置（批 7）
- `modules/NetCommon-结构.md` —— 同批模块
- `modules/Engine-结构.md` —— `UNetDriver` 集成方

## 更新记录

- 2026-10-11 按规范 4.2.1 为「取数说明」各行加方法标记（`[M]`/`[R]`/`[H]`）；`[M]` 行把原文省略成 `(...)` 的路径补全为白名单可执行命令，现由 `ue-doc-verify` 逐条实际执行比对
