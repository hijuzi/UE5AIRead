> 引擎版本：UE 5.8.3 (Build 58210709)
> 源码根：Engine/Source
> 生成技能：ue-module-structure v1.0
> 生成时间：2026-10-10
> 校验状态：已校验（2026-10-11）

# CoreUObject 模块结构

## 一、模块定位

| 项 | 值 |
|---|---|
| 路径 | `Engine/Source/Runtime/CoreUObject` |
| 类别 | Runtime |
| 规模 | 969 文件 / 553 头文件（`_meta/engine-modules.json` 2026-10-10 口径）；`Public/` 下 `.h` 471 个，其中核心区 `Public/UObject/` 的 `.h` 为 156 个 |
| 分层 | 地基 |
| 一句话职责 | `UObject` 对象模型与反射系统：`UObject`/`UClass`/`FProperty`、GC、序列化、CDO 与蓝图支撑、资源注册数据类型（AssetRegistry）、VerseVM 集成 |

## 二、目录结构

```
CoreUObject/
├── CoreUObject.Build.cs          # 模块构建脚本（75 行）
├── Public/                       # 对外契约（471 个 .h / 11 个子目录）
│   ├── 根文件：CoreUObject.h、CoreUObjectSharedPCH.h、InstancedReferenceSubobjectHelper.h
│   └── AssetRegistry/ Blueprint/ Concepts/ Cooker/ Internationalization/ Misc/
│       Serialization/ StructUtils/ Templates/ UObject/ VerseVM/
│       ※ Public/UObject/ 为平铺目录：156 个 .h（Object.h、Class.h、UObjectGlobals.h、ObjectMacros.h、…）
├── Private/                      # 实现（与 Public 基本对称，无 Concepts/）
├── Internal/                     # 内部共享（Serialization/、UObject/ 两个子目录）
└── Tests/                        # 测试代码根
```

- `Public/` 与 `Private/` 分离；另有含义不同的 `Internal/`——**不要把它当作 `Public/`**。
- `Tests/` 属测试代码，本版标注不展开。

## 三、依赖关系

### 3.1 无条件依赖

| 模块 | 类型 | Build.cs 行 | 说明 |
|---|---|---|---|
| `Core` | 公开依赖 | 26-34 | 上游地基模块 |
| `TraceLog` | 公开依赖 | 26-34 | Trace 事件日志 |
| `CorePreciseFP` | 公开依赖 | 26-34 | 确定性浮点支持（`SetupVerse()` 在 `Target.bUseVerseVM` 时会再次加入，见 3.2） |
| `Json` | 公开依赖 | 26-34 | JSON 解析 |
| `AutoRTFM` | 私有依赖 | 38-44 | 事务内存支持 |
| `Projects` | 私有依赖 | 38-44 | 项目/插件描述信息 |
| `TargetPlatform` | 私有包含路径 | 19-24 | 仅加包含路径，不链接 |

> **辅助函数已展开**：`SetupVerse()`（Build.cs 第 36 行调用）函数体定义于 UBT 的
> `Engine/Source/Programs/UnrealBuildTool/Configuration/Rules/ModuleRules.cs` 第 1629-1641 行——
> 设置 `bAllowUETypesInNamespaces = true`；当 `Target.bUseVerseVM` 为真时追加公开依赖（见 3.2）。
> **本模块无"未展开的依赖"遗留项。**

### 3.2 平台与配置条件依赖

> `CoreUObject.Build.cs` 全文含 **4 处 `if` 分支**。

| 依赖 | 类型 | 生效条件 | 来源（Build.cs 行 / 定义处） |
|---|---|---|---|
| `libpas` | 私有依赖 | `GlobalDefinitions` 中含 `UE_WITH_REMOTE_OBJECT_HANDLE=1` | 46-50 |
| `libpas`、`CorePreciseFP` | 公开依赖（经 `SetupVerse()` 追加） | `Target.bUseVerseVM` | 36 → `ModuleRules.cs` 第 1629-1641 行 |
| `DerivedDataCache` | 私有依赖 | `bBuildWithEditorOnlyData && Desktop 平台组` | 63-66 |
| `ApplicationCore` | 私有包含路径 | `bCompileAgainstApplicationCore` | 68-71 |

### 3.3 第三方静态依赖

`AddEngineThirdPartyPrivateStaticDependencies` 全文调用 **0 处**——本模块**无第三方静态依赖**
（实测为零，不是"未展开"）。

## 四、对外暴露面

> 只列 `Public/` 下的头文件。全模块公开头共 471 个，下表为核心契约。

| 头文件 | 提供的能力 |
|---|---|
| `CoreUObject.h` | 根聚合头 |
| `UObject/Object.h` | `UObject` 基类（第 98 行 `class UObject : public UObjectBaseUtility`） |
| `UObject/Class.h` | 类体系：`UField`（第 171 行）、`UStruct`（第 495 行）、`UScriptStruct`（第 1774 行）、`UFunction`（第 2562 行）、`UClass`（第 3893 行） |
| `UObject/ObjectMacros.h` | 反射标记宏：`UCLASS`（第 808 行）等 |
| `UObject/UObjectGlobals.h` | 对象创建与 GC 入口：`NewObject`、`StaticConstructObject_Internal`、`CollectGarbage`（第 952 行） |
| `UObject/ObjectPtr.h` | `TObjectPtr`（第 519 行）、`FObjectPtr`（第 54 行） |
| `UObject/WeakObjectPtr.h` | `TWeakObjectPtr` 弱引用 |
| `UObject/SoftObjectPtr.h` | `TSoftObjectPtr` 软引用 |
| `UObject/UnrealType.h` | `FProperty` 属性系统 |
| `UObject/Package.h` | `UPackage`（第 216 行，`class UPackage : public UObject`） |
| `UObject/GarbageCollection.h` | 实时 GC 辅助：`IsGarbageCollecting()`（第 204 行）等（**`CollectGarbage` 不在此文件**，见第六节） |
| `Templates/SubclassOf.h` | `TSubclassOf` |
| `StructUtils/InstancedStruct.h` | `FInstancedStruct` 结构化实例 |
| `AssetRegistry/AssetData.h` | `FAssetData`（第 163 行）资产注册数据类型 |
| `Blueprint/BlueprintSupport.h` | 蓝图核心支撑 |

## 五、模块生命周期

```
文件：Engine/Source/Runtime/CoreUObject/Private/UObject/CoreNative.cpp
行 33-121：FCoreUObjectModule 类定义（含 StartupModule 覆写）

文件：Engine/Source/Runtime/CoreUObject/Private/UObject/CoreNative.cpp
行 122：IMPLEMENT_MODULE( FCoreUObjectModule, CoreUObject );
```

- **入口宏**：`IMPLEMENT_MODULE( FCoreUObjectModule, CoreUObject );`（第 122 行）
- **模块类**：`FCoreUObjectModule : public FDefaultModuleImpl`（第 33 行起）
- **`StartupModule()` 覆写**（第 52-89 行），做了 6 件事：
  1. `UClassRegisterAllCompiledInClasses()`（第 55 行）——注册已加载的 compiled-in 类（CVar 生效所需）
  2. `FCoreDelegates::OnInit.AddStatic(InitUObject)`（第 57-58 行）——向 Core 注册 UObject 系统初始化函数
  3. 用 CoreUObject 实现**替换** Core 的异步加载函数指针（第 61-67 行）：`IsInAsyncLoadingThread`、`IsAsyncLoading`、`SuspendAsyncLoading`、`ResumeAsyncLoading`、`IsAsyncLoadingSuspended`、`IsAsyncLoadingMultithreaded`、`GetLoaderType`
  4. 编辑器下挂 `OnPostEngineInit` 本地化数据收集（第 70 行，`WITH_EDITORONLY_DATA`）
  5. 运行时错误回调（第 73-81 行）：`OnEnsureFailed` 处理与 `FRuntimeErrors::OnRuntimeIssueLogged` 绑定
  6. `FPackageName::OnCoreUObjectInitialized()`（第 84 行）、`FFrame::InitPrintScriptCallstack()`（第 86-88 行，`DO_BLUEPRINT_GUARD`）
- **`ShutdownModule()`**：未覆写，沿用 `FDefaultModuleImpl` 默认实现。
- **`SupportsDynamicReloading()`**：未覆写，沿用接口默认（返回 `true`，`Engine/Source/Runtime/Core/Public/Modules/ModuleInterface.h` 第 88-91 行）。
- 同一文件第 126-139 行另有 `!USE_COMPILED_IN_NATIVES` 时的 `Z_Construct_UClass_UObject` 回退与 `IMPLEMENT_CLASS(UObject, 0)`。

## 六、关键约定与坑

1. **`UObject` 类声明在 `UObject/Object.h`——不存在 `UObject/UObject.h`**（实测）。且类声明行不带类级导出宏（第 98 行 `class UObject : public UObjectBaseUtility`）——字面搜索 `class COREUOBJECT_API UObject` 会零命中，**零命中不代表不存在**。
2. **`UClass` 等类声明在 `UObject/Class.h`**（第 3893 行），同样不带类级导出宏，勿按"常见写法"拼检索式。
3. **`CollectGarbage()` 在 `UObject/UObjectGlobals.h`（第 952 行），不在 `UObject/GarbageCollection.h`**；后者是实时 GC 辅助（`IsGarbageCollecting()` 等）。
4. **辅助函数依赖已展开**（`SetupVerse()`，见 3.1/3.2）：只静态读 Build.cs 的 `Add*` 调用会漏掉它——函数体在 UBT 的 `ModuleRules.cs`。**这是本模块最隐蔽的一处依赖来源。**
5. **条件判定用的是全局宏**：`libpas` 私有依赖由 `GlobalDefinitions.Contains("UE_WITH_REMOTE_OBJECT_HANDLE=1")` 触发（第 46-50 行），不是 `Target.bXxx` 属性风格，检索时容易漏看。
6. **构建期要点**：`bMinimizeGeneratedIncludes = true`（第 13 行，减少 `.generated.h` 包含量以缓解模块内循环依赖）；`GenerateHeaderFuncs` 注册 VerseVM 字节码头生成（第 11 行）；`WITH_VERSE_COMPILER` 编译定义随 `bBuildWithEditorOnlyData || Server` 取 1/0（第 52-59 行）；PCH：`Private/CoreUObjectPrivatePCH.h`、`Public/CoreUObjectSharedPCH.h`（第 15-17 行）。

## 取数说明

以下命令的相对基准为 `Engine/Source`（实际路径按 `_meta/convention.md` 的本机环境块解析）：

| 断言 | 取数方式 |
|---|---|
| 969 文件 / 553 头文件 | `[M]` 引擎磁盘递归计数：`(Get-ChildItem "Runtime/CoreUObject" -Recurse -File).Count` 得文件数；`(Get-ChildItem "Runtime/CoreUObject" -Recurse -File -Filter *.h).Count` 得头文件数（同 `_meta/engine-modules.json` 口径） |
| `Public/` 471 个 `.h`、11 个子目录 | `[M]` `(Get-ChildItem "Runtime\CoreUObject\Public" -Recurse -File -Filter *.h).Count`、`(Get-ChildItem "Runtime\CoreUObject\Public" -Directory).Count` |
| `Public/UObject/` 156 个 `.h`、无子目录 | `[M]` `(Get-ChildItem "Runtime\CoreUObject\Public\UObject" -File -Filter *.h).Count`、`(Get-ChildItem "Runtime\CoreUObject\Public\UObject" -Directory).Count` |
| `CoreUObject.Build.cs` 75 行 | `[M]` `[System.IO.File]::ReadAllLines("Runtime/CoreUObject/CoreUObject.Build.cs").Count` |
| `if` 分支 4 处、三方静态调用 0 处 | `[M]` `Select-String "Runtime\CoreUObject\CoreUObject.Build.cs" -Pattern '\bif\s*\(' -AllMatches` 与 `AddEngineThirdPartyPrivateStaticDependencies` 的全匹配计数 |
| `SetupVerse()` 展开 | `Engine/Source/Programs/UnrealBuildTool/Configuration/Rules/ModuleRules.cs` 第 1629-1641 行 |
| 全部行号引用 | 2026-10-10 对 UE 5.8.3 源码本机逐条核对 |

## 相关文档

- `modules/Core-结构.md` —— 上游模块（本模块 `PublicDependencyModuleNames` 含 `Core`）
- `types/UObject.md` —— 本模块核心类型（同批产出）
- `types/FName.md` —— `FName` 定义在 Core，本模块的对象命名依赖它
- `flows/UObject创建流程.md` —— 对象创建主路径（已校验）

## 更新记录

- 2026-10-11 按规范 4.2.1 为「取数说明」各行加方法标记（`[M]`/`[R]`/`[H]`）；`[M]` 行把原文省略成 `(...)` 的路径补全为白名单可执行命令，现由 `ue-doc-verify` 逐条实际执行比对
