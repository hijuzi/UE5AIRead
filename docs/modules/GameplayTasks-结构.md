> 引擎版本：UE 5.8.3 (Build 58210709)
> 源码根：Engine/Source
> 生成技能：ue-module-structure v1.0
> 生成时间：2026-10-10
> 校验状态：已校验（2026-10-11）

# GameplayTasks 模块结构

## 一、模块定位

| 项 | 值 |
|---|---|
| 路径 | `Engine/Source/Runtime/GameplayTasks` |
| 类别 | Runtime |
| 规模 | 21 文件 / 11 头文件（`_meta/engine-modules.json` 2026-10-10 口径）；公开侧 10 个 `.h`（`Classes/` 4 + `Classes/Tasks/` 4 + `Public/` 2） |
| 分层 | 框架 |
| 一句话职责 | 异步任务（Gameplay Task）框架：`UGameplayTask` 基类与资源调度（`UGameplayTaskResource`）、任务宿主组件（`UGameplayTasksComponent`）、内置任务（WaitDelay / ClaimResource / SpawnActor / TimeLimitedExecution）——AI（`UAITask`）与技能系统的任务基座 |

## 二、目录结构

```
GameplayTasks/
├── GameplayTasks.Build.cs        # 模块构建脚本（32 行、1 处 if 分支）
├── Classes/                      # 公开侧之一（UObject 反射类头，4 个 .h + Tasks/ 4 个 .h）
│   └── Tasks/                    # GameplayTask_WaitDelay.h / GameplayTask_ClaimResource.h
│                                 # GameplayTask_SpawnActor.h / GameplayTask_TimeLimitedExecution.h
├── Public/                       # 公开侧之二（2 个 .h：GameplayTasksModule.h、GameplayTaskTypes.h）
└── Private/                      # 实现（6 个文件 + Tasks/ 4 个 .cpp）
```

- 无 `Internal/`、无 `Tests/`（实测 0 命中）；无聚合头。

## 三、依赖关系

### 3.1 无条件依赖

| 模块 | 类型 | Build.cs 行 | 说明 |
|---|---|---|---|
| `Core` | 公开依赖 | 12 | |
| `CoreUObject` | 公开依赖 | 13 | |
| `Engine` | 公开依赖 | 14 | |
| `NetCore` | 公开依赖 | 15 | |

> Build.cs 以 `namespace UnrealBuildTool.Rules` 包裹（与 CoreUObject 同风格）。
> **辅助函数已展开**：第 29 行 `SetupIrisSupport(Target)`（位于 `if` 块**之外**、无条件生效；未传第二参、默认 `false`）
> → 追加**私有依赖 `IrisCore`**（UBT `ModuleRules.cs` 第 1760 行）+ 2 个宏定义。**无其他未展开依赖。**

### 3.2 平台与配置条件依赖

> 全文 **1 处 `if` 分支**（第 21 行）。

| 依赖 | 类型 | 生效条件 | Build.cs 行 |
|---|---|---|---|
| `EditorFramework`、`UnrealEd` | 私有依赖 | `Target.bBuildEditor == true` | 23-24 |
| `UnrealEd`（循环引用登记） | `CircularlyReferencedDependentModules` | 同上 | 25 |

### 3.3 第三方静态依赖

调用 **0 处**——无第三方静态依赖。

## 四、对外暴露面

> 公开侧共 10 个 `.h`。

| 头文件 | 提供的能力 |
|---|---|
| `Engine/Source/Runtime/GameplayTasks/Classes/GameplayTask.h` | `UGameplayTask`（第 145 行）→ `types/UGameplayTask.md` |
| `Engine/Source/Runtime/GameplayTasks/Classes/GameplayTasksComponent.h` | `UGameplayTasksComponent`（第 61 行，`: UActorComponent, IGameplayTaskOwnerInterface, IVisualLoggerDebugSnapshotInterface`） |
| `Engine/Source/Runtime/GameplayTasks/Classes/GameplayTaskOwnerInterface.h` | `IGameplayTaskOwnerInterface`（第 20 行；`UINTERFACE` 第 14-15 行） |
| `Engine/Source/Runtime/GameplayTasks/Classes/GameplayTaskResource.h` | `UGameplayTaskResource`（第 14 行） |
| `Engine/Source/Runtime/GameplayTasks/Classes/Tasks/GameplayTask_WaitDelay.h` | 延时任务 |
| `Engine/Source/Runtime/GameplayTasks/Classes/Tasks/GameplayTask_ClaimResource.h` | 资源占位任务 |
| `Engine/Source/Runtime/GameplayTasks/Classes/Tasks/GameplayTask_SpawnActor.h` | 生成 Actor 任务 |
| `Engine/Source/Runtime/GameplayTasks/Classes/Tasks/GameplayTask_TimeLimitedExecution.h` | 限时执行任务 |
| `Engine/Source/Runtime/GameplayTasks/Public/GameplayTasksModule.h` | 模块接口 `IGameplayTasksModule`（第 13 行） |
| `Engine/Source/Runtime/GameplayTasks/Public/GameplayTaskTypes.h` | `FGameplayTasks` 命名空间（第 15 行起） |

## 五、模块生命周期

```
文件：Engine/Source/Runtime/GameplayTasks/Private/GameplayTasksModule.cpp
行 11：class FGameplayTasksModule : public IGameplayTasksModule
行 26：IMPLEMENT_MODULE(FGameplayTasksModule, GameplayTasks);
```

- **`StartupModule()`**（第 14-17 行）：唯一行为 `check(GConfig);`（第 16 行）。
- **`ShutdownModule()`**（第 19-21 行）：空实现。
- **`SupportsDynamicReloading`**：未覆写（0 命中）。
- 附带：`DEFINE_LOG_CATEGORY(LogGameplayTasks);`（第 27 行）、`DEFINE_STAT(STAT_TickGameplayTasks);`（第 28 行）。
- 静态辅助：`IGameplayTasksModule::Get()`（`Public/GameplayTasksModule.h` 第 24 行）、`IsAvailable()`（第 34 行）。

## 六、关键约定与坑

1. **公开侧是 `Classes/` + `Public/` 双目录**：`GameplayTask.h` 只在 `Classes/` 下（`Public/GameplayTask.h` **不存在**）；模块接口头只在 `Public/`。
2. **`UGameplayTask_TimeLimitedAction` 不存在**（实测 0 命中）——实际类名是 `UGameplayTask_TimeLimitedExecution`（`Classes/Tasks/GameplayTask_TimeLimitedExecution.h` 第 18 行）。
3. **`SetupIrisSupport` 无条件追加 `IrisCore` 私有依赖**（第 29 行，位于 `if` 块外）。
4. **数字口径**：`GameplayTasks.Build.cs` 32 行（`ReadAllLines`）、1 处 `if`、0 处三方静态调用；公开侧 10 个 `.h`。取数命令见「取数说明」。

## 取数说明

以下命令的相对基准为 `Engine/Source`（实际路径按 `_meta/convention.md` 的本机环境块解析）：

| 断言 | 取数方式 |
|---|---|
| 追加私有依赖 `IrisCore` 时附 **2** 个宏定义 | `[H]` 逐行通读 UBT `ModuleRules.cs` 第 1760 行前后的 `PublicDefinitions` 段 → **2** 个 `WITH_*` 定义 |
| 21 文件 / 11 头文件 | `[M]` 引擎磁盘递归计数：`(Get-ChildItem "Runtime/GameplayTasks" -Recurse -File).Count` 得文件数；`(Get-ChildItem "Runtime/GameplayTasks" -Recurse -File -Filter *.h).Count` 得头文件数（同 `_meta/engine-modules.json` 口径） |
| 公开侧 10 个 `.h` | `[H]` `Classes/`（含 `Tasks/`）与 `Public/` 递归计数 |
| Build.cs 32 行、1 处 `if`、0 处三方静态调用 | `[M]` `[System.IO.File]::ReadAllLines("Runtime/GameplayTasks/GameplayTasks.Build.cs").Count`；`Select-String "Runtime/GameplayTasks/GameplayTasks.Build.cs" -Pattern '\bif\s*\(' -AllMatches`；`Select-String "Runtime/GameplayTasks/GameplayTasks.Build.cs" -Pattern 'AddEngineThirdPartyPrivateStaticDependencies' -AllMatches` |
| `SetupIrisSupport` 展开 | UBT `ModuleRules.cs` 第 1747-1762 行 |
| 全部行号引用 | 2026-10-10 对 UE 5.8.3 源码本机逐条核对 |

## 相关文档

- `types/UGameplayTask.md` —— 本模块核心类型（同批产出）
- `modules/MovieScene-结构.md` —— 同批模块
- `modules/AIModule-结构.md` —— `UAITask` 派生类的宿主模块（第二批，后续批次）
- `modules/Engine-结构.md` —— `UActorComponent` 基类所在模块

## 更新记录

- 2026-10-11 补齐 `UGameplayTasksComponent` 基类链（漏第三基类 `IVisualLoggerDebugSnapshotInterface`）

- 2026-10-11 「取数说明」补入 1 行计数断言取数方式（`convention.md` 4.2 覆盖要求）

- 2026-10-11 按规范 4.2.1 为「取数说明」各行加方法标记（`[M]`/`[R]`/`[H]`）；`[M]` 行把原文省略成 `(...)` 的路径补全为白名单可执行命令，现由 `ue-doc-verify` 逐条实际执行比对
