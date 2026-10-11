> 引擎版本：UE 5.8.3 (Build 58210709)
> 源码根：Engine/Source
> 生成技能：ue-module-structure v1.0
> 生成时间：2026-10-10
> 校验状态：已校验（2026-10-11）

# GameplayTags 模块结构

## 一、模块定位

| 项 | 值 |
|---|---|
| 路径 | `Engine/Source/Runtime/GameplayTags` |
| 类别 | Runtime |
| 规模 | 27 文件 / 13 头文件（`_meta/engine-modules.json` 2026-10-10 口径）；公开侧 `Classes/` 5 个 `.h` + `Public/` 7 个 `.h` |
| 分层 | 框架 |
| 一句话职责 | 层级化标签基础设施：`FGameplayTag` 值类型、`FGameplayTagContainer` 容器、`UGameplayTagsManager` 全局标签表与查询——标签驱动架构的根依赖 |

## 二、目录结构

```
GameplayTags/
├── GameplayTags.Build.cs          # 模块构建脚本（43 行、1 处 if 分支）
├── Classes/                       # 公开侧之一（5 个 .h，无子目录）
│   ├── BlueprintGameplayTagLibrary.h
│   ├── GameplayTagAssetInterface.h
│   ├── GameplayTagContainer.h     # FGameplayTag / FGameplayTagContainer / FGameplayTagQuery
│   ├── GameplayTagsManager.h      # UGameplayTagsManager
│   └── GameplayTagsSettings.h
├── Public/                        # 公开侧之二（7 个 .h：GameplayTags.h 聚合头、NativeGameplayTags.h、…）
├── Private/                       # 实现（12 项，含 Tests/）
└── Private/Tests/                 # 测试（GameplayTagTests.cpp、GameplayTagQueryTests.cpp）
```

- 公开侧为 `Classes/` + `Public/` 双目录（与 `Engine` 模块同风格）；无 `Internal/` 目录。
- `Tests/` 属测试代码，本版标注不展开。

## 三、依赖关系

### 3.1 无条件依赖

| 模块 | 类型 | Build.cs 行 | 说明 |
|---|---|---|---|
| `Core` | 公开依赖 | 12 | |
| `CoreUObject` | 公开依赖 | 13 | |
| `Engine` | 公开依赖 | 14 | 与 `Engine` 互为公开依赖（见第六节第 1 条） |
| `DeveloperSettings` | 公开依赖 | 15 | |
| `Projects` | 私有依赖 | 22 | |
| `NetCore` | 私有依赖 | 23 | |
| `Json` | 私有依赖 | 24 | |
| `JsonUtilities` | 私有依赖 | 25 | |
| `IrisCore` | 私有依赖（经 `SetupIrisSupport` 追加） | 40 → UBT 第 1760 行 | 辅助函数追加，见下 |

> **辅助函数已展开**：第 40 行调用 `SetupIrisSupport(Target)`（未传第二参数，默认 `bAddAsPublicDependency = false`），
> 函数体定义于 UBT 的 `Engine/Source/Programs/UnrealBuildTool/Configuration/Rules/ModuleRules.cs` 第 1747-1762 行：
> **追加私有依赖 `IrisCore`**（第 1760 行），并添加 `UE_NET_HAS_IRIS_FASTARRAY_BINDING=1`（第 1749 行）、
> `UE_WITH_IRIS=1`（第 1752 行）两个宏定义。**本模块无其他未展开依赖。**

### 3.2 平台与配置条件依赖

> `GameplayTags.Build.cs` 全文 **1 处 `if` 分支**（第 29 行）。

| 依赖 | 类型 | 生效条件 | Build.cs 行 |
|---|---|---|---|
| `SlateCore`、`Slate` | 私有依赖 | `Target.bCompileAgainstEditor` | 29-38 |

### 3.3 第三方静态依赖

`AddEngineThirdPartyPrivateStaticDependencies` 调用 **0 处**——本模块**无第三方静态依赖**（实测为零，非"未展开"）。

## 四、对外暴露面

> 只列公开侧（`Classes/` + `Public/`，共 12 个 `.h`）。

| 头文件 | 提供的能力 |
|---|---|
| `Classes/GameplayTagContainer.h` | `FGameplayTag`（第 41 行）、`FGameplayTagContainer`（第 247 行）、`FGameplayTagQuery`（第 737 行）等核心值类型 |
| `Classes/GameplayTagsManager.h` | `UGameplayTagsManager`（第 336 行，`UCLASS(config=Engine, MinimalAPI)`）、`FGameplayTagNode`（第 184 行） |
| `Classes/GameplayTagAssetInterface.h` | `IGameplayTagAssetInterface`（第 19 行）/ `UGameplayTagAssetInterface`（第 14 行） |
| `Classes/GameplayTagsSettings.h` | 标签表配置（`UCLASS(config = GameplayTagsList, MinimalAPI)`，第 33 行） |
| `Classes/BlueprintGameplayTagLibrary.h` | 蓝图函数库（`UCLASS(..., MinimalAPI)`，第 14 行） |
| `Public/GameplayTags.h` | 聚合头（转发包含 Manager / Container / AssetInterface；11 行） |
| `Public/GameplayTagsModule.h` | 模块接口 `IGameplayTagsModule`（第 18 行） |
| `Public/NativeGameplayTags.h` | `FNativeGameplayTag`（第 58 行）原生标签注册 |
| `Public/GameplayTagRedirectors.h` | `FGameplayTagRedirect`（第 19 行）标签重定向 |
| `Public/GameplayTagTokenStore.h` | `FGameplayTagTokenStore`（第 14 行） |
| `Public/GameplayTagNetSerializer.h` | 标签网络序列化（配置类型第 9 行） |
| `Public/GameplayTagContainerNetSerializer.h` | 容器网络序列化（配置类型第 9 行） |

## 五、模块生命周期

```
文件：Engine/Source/Runtime/GameplayTags/Private/GameplayTagsModule.cpp
行 11：class FGameplayTagsModule : public IGameplayTagsModule

文件：Engine/Source/Runtime/GameplayTags/Private/GameplayTagsModule.cpp
行 19：IMPLEMENT_MODULE( FGameplayTagsModule, GameplayTags )
```

- **模块类**：`FGameplayTagsModule : IGameplayTagsModule : IModuleInterface`（第 11 行；接口声明在 `Public/GameplayTagsModule.h` 第 18 行）
- **`StartupModule()`**（第 22-26 行）：唯一实质行为 `UGameplayTagsManager::Get();`（第 25 行）——强制实例化标签管理器单例（注释：`This will force initialization`）
- **`ShutdownModule()`**（第 34-44 行）：`PrintReplicationFrequencyReport()`（第 39 行）、`UGameplayTagsManager::SingletonManager = nullptr;`（第 43 行）
- **`SupportsDynamicReloading`**：未覆写（模块内 0 命中）

## 六、关键约定与坑

1. **`Engine` 与 `GameplayTags` 互为公开依赖（循环）**：本模块 Build.cs 第 14 行公开依赖 `Engine`；`Engine.Build.cs` 第 102 行公开依赖本模块，并在第 250 行将本模块列入 `CircularlyReferencedDependentModules`——两侧都要记录，勿当单向依赖。
2. **`SetupIrisSupport()` 会追加 `IrisCore` 私有依赖**（见 3.1）——只静态读 `Add*` 调用会漏（函数体在 UBT 的 `ModuleRules.cs`）。
3. **公开侧是 `Classes/` + `Public/` 双目录**；聚合头是 `Public/GameplayTags.h`（11 行的转发聚合，勿当类型头引用）。
4. **`FGameplayTag` 的反射宏是 `GENERATED_USTRUCT_BODY()`**（`Classes/GameplayTagContainer.h` 第 43 行），不是 `GENERATED_BODY()`。
5. **数字口径**：`GameplayTags.Build.cs` 43 行（`ReadAllLines` 口径；read_file 显示 44 属 EOF 渲染）；`if` 分支 1 处；三方静态依赖 0 处。取数命令见「取数说明」。

## 取数说明

以下命令的相对基准为 `Engine/Source`（实际路径按 `_meta/convention.md` 的本机环境块解析）：

| 断言 | 取数方式 |
|---|---|
| 27 文件 / 13 头文件 | `[M]` 引擎磁盘递归计数：`(Get-ChildItem "Runtime/GameplayTags" -Recurse -File).Count` 得文件数；`(Get-ChildItem "Runtime/GameplayTags" -Recurse -File -Filter *.h).Count` 得头文件数（同 `_meta/engine-modules.json` 口径） |
| 公开侧 5 + 7 个 `.h` | `[H]` 目录枚举（`Classes/`、`Public/` 各一层；合计 12 个 `.h`） |
| `GameplayTags.Build.cs` 43 行、1 处 `if`、0 处三方静态调用 | `[M]` `[System.IO.File]::ReadAllLines("Runtime/GameplayTags/GameplayTags.Build.cs").Count`；`Select-String "Runtime/GameplayTags/GameplayTags.Build.cs" -Pattern '\bif\s*\(' -AllMatches`；`Select-String "Runtime/GameplayTags/GameplayTags.Build.cs" -Pattern 'AddEngineThirdPartyPrivateStaticDependencies' -AllMatches` |
| `SetupIrisSupport` 展开 | UBT `ModuleRules.cs` 第 1747-1762 行 |
| 全部行号引用 | 2026-10-10 对 UE 5.8.3 源码本机逐条核对 |

## 相关文档

- `types/FGameplayTag.md` —— 本模块核心值类型（同批产出）
- `modules/Engine-结构.md` —— 互为公开依赖的模块（同批产出）
- `modules/Core-结构.md` —— 上游地基模块
- `modules/CoreUObject-结构.md` —— 上游地基模块
- `types/AActor.md` —— 标签查询的常见载体（同批产出）
- `flows/UObject创建流程.md` —— 对象创建主路径（已校验）

## 更新记录

- 2026-10-11 按规范 4.2.1 为「取数说明」各行加方法标记（`[M]`/`[R]`/`[H]`）；`[M]` 行把原文省略成 `(...)` 的路径补全为白名单可执行命令，现由 `ue-doc-verify` 逐条实际执行比对
