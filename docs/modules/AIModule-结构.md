> 引擎版本：UE 5.8.3 (Build 58210709)
> 源码根：Engine/Source
> 生成技能：ue-module-structure v1.0
> 生成时间：2026-10-10
> 校验状态：已校验（2026-10-11）

# AIModule 模块结构

## 一、模块定位

| 项 | 值 |
|---|---|
| 路径 | `Engine/Source/Runtime/AIModule` |
| 类别 | Runtime |
| 规模 | 389 文件 / 205 头文件（`_meta/engine-modules.json` 2026-10-10 口径）；公开侧主体在 `Classes/`（`Public/` 递归仅 21 个 `.h`） |
| 分层 | 框架 |
| 一句话职责 | AI 框架：`AAIController` 与感知（`UAIPerceptionComponent`）、行为树（`UBehaviorTreeComponent` / `UBlackboardComponent`）、寻路跟随（`UPathFollowingComponent`）、EQS 环境查询与 NavMesh 调试视图 |

## 二、目录结构

```
AIModule/
├── AIModule.Build.cs             # 模块构建脚本（57 行、2 处 if 分支）
├── AICodingStandard.md           # 模块自带的 AI 编码规范
├── AIModule.natvis
├── Classes/                      # 公开侧主体（UObject 反射类头）
│   ├── AIController.h / AITypes.h / DetourCrowdAIController.h / GridPathAIController.h
│   └── BehaviorTree/ Perception/ Navigation/ EnvironmentQuery/ Tasks/ Blueprint/ DataProviders/ HotSpots/ Actions/
├── Public/                       # 公开侧之一（14 个顶层 .h + GameplayDebugger/ 7 个 .h = 21 个）
└── Private/                      # 实现（9 个子目录：BehaviorTree/ Blueprint/ DataProviders/ EnvironmentQuery/
│                                 # GameplayDebugger/ HotSpots/ Navigation/ Perception/ Tasks/）
```

- 无 `Internal/`、无 `Tests/`（实测 0 命中）。

## 三、依赖关系

### 3.1 无条件依赖

| 模块 | 类型 | Build.cs 行 | 说明 |
|---|---|---|---|
| `Core` | 公开依赖 | 13 | |
| `CoreUObject` | 公开依赖 | 14 | |
| `Engine` | 公开依赖 | 15 | |
| `GameplayTags` | 公开依赖 | 16 | |
| `GameplayTasks` | 公开依赖 | 17 | `UAITask` 的基座 |
| `NavigationSystem` | 公开依赖 | 18 | |
| `AutoRTFM` | 私有依赖 | 24 | |
| `InputCore` | 私有依赖 | 25 | |
| `RHI` | 私有依赖 | 26 | |
| `RenderCore` | 私有依赖 | 27 | |

> **辅助函数已展开**：第 54 行 `SetupGameplayDebuggerSupport(Target)`（UBT `ModuleRules.cs` 第 1662-1700 行）——
> 按 `target.bUseGameplayDebugger` / `bUseGameplayDebuggerCore` 追加 `WITH_GAMEPLAY_DEBUGGER_CORE=1`、
> `WITH_GAMEPLAY_DEBUGGER=…`、`WITH_GAMEPLAY_DEBUGGER_MENU=…` 等**宏定义**；第二参只决定公开/私有；默认 `false` 走 else 分支，
> **仍以私有依赖追加 `GameplayDebugger`（编辑器目标再加 `GameplayDebuggerEditor`）**。**无其他未展开依赖。**

### 3.2 平台与配置条件依赖

> 全文 **2 处 `if` 分支**（第 31、41 行）。

| 依赖 / 项 | 类型 | 生效条件 | Build.cs 行 |
|---|---|---|---|
| `EditorFramework`、`UnrealEd`、`SlateCore`、`AITestSuite` | 私有依赖 | `Target.bBuildEditor == true` | 31-39 |
| `AITestSuite`（循环引用登记） | `CircularlyReferencedDependentModules` | 同上 | 38 |
| `Navmesh` | 私有依赖（+ `WITH_RECAST=1`，第 44 行） | `Target.bCompileRecast`（41-44） | 41-44 |
| `WITH_RECAST=0` | 编译定义 | `else` 分支 | 51 |

### 3.3 第三方静态依赖

调用 **0 处**——无第三方静态依赖（`Navmesh` 是模块依赖而非静态库）。

## 四、对外暴露面

> 公开侧主体为 `Classes/`（传统布局）+ `Public/`（21 个 `.h`，含 `GameplayDebugger/`）。

| 头文件 | 提供的能力 |
|---|---|
| `Engine/Source/Runtime/AIModule/Classes/AIController.h` | `AAIController`（第 87 行）→ `types/AAIController.md` |
| `Engine/Source/Runtime/AIModule/Classes/BehaviorTree/BehaviorTreeComponent.h` | `UBehaviorTreeComponent`（第 104 行） |
| `Engine/Source/Runtime/AIModule/Classes/BehaviorTree/BlackboardComponent.h` | `UBlackboardComponent`（第 42 行） |
| `Engine/Source/Runtime/AIModule/Classes/Perception/AIPerceptionComponent.h` | `UAIPerceptionComponent`（第 208 行） |
| `Engine/Source/Runtime/AIModule/Classes/Perception/PawnSensingComponent.h` | `UPawnSensingComponent`（第 22 行；**5.5 起废弃**，第 20 行 `UE_DEPRECATED_FORGAME(5.5, ...)`） |
| `Engine/Source/Runtime/AIModule/Classes/Navigation/PathFollowingComponent.h` | `UPathFollowingComponent`（第 216 行；30.58 KB） |
| `Engine/Source/Runtime/AIModule/Classes/BehaviorTree/BehaviorTree.h` | `UBehaviorTree` 资产 |
| `Engine/Source/Runtime/AIModule/Classes/AITypes.h` | AI 公共类型（19.3 KB） |
| `Engine/Source/Runtime/AIModule/Public/AIModule.h` | 模块接口 `IAIModule`（第 15 行） |

## 五、模块生命周期

```
文件：Engine/Source/Runtime/AIModule/Private/AIModule.cpp
行 37：class FAIModule : public IAIModule
行 55：IMPLEMENT_MODULE(FAIModule, AIModule)
```

- **继承链**：`FAIModule` → `IAIModule`（`Public/AIModule.h` 第 15 行）→ `IAISystemModule`（`Engine/Source/Runtime/Engine/Classes/AI/AISystemBase.h` 第 75 行）→ `IModuleInterface`。
- **`StartupModule()`**（第 57-88 行）要点：
  1. `LoadModulePtr<IModuleInterface>("NavigationSystem")`（第 59 行）
  2. `WITH_EDITOR` 下 `LoadModulePtr<IModuleInterface>("AITestSuite")`（第 60-61 行）
  3. `GIsEditor` 下注册资产分类 `"Artificial Intelligence"`（第 63-70 行）
  4. `WITH_EDITOR && ENABLE_VISUAL_LOG` 下注册 EQS VisualLogger 扩展（第 73-75 行）
  5. `WITH_GAMEPLAY_DEBUGGER` 下注册 7 个调试分类：AI / BehaviorTree / EQS / Navmesh / Perception / PerceptionSystem / NavGrid（第 77-87 行），并 `NotifyCategoriesChanged()`（第 86 行）
- **`ShutdownModule()`**（第 90 行起）：注销对应项——**注意未注销 `"PerceptionSystem"`**（第 99-109 行，与 Startup 注册不完全对称，如实记录）。
- **`SupportsDynamicReloading`**：未覆写（0 命中）。

## 六、关键约定与坑

1. **公开侧主体是 `Classes/`**（传统布局）：`PawnSensingComponent.h` 在 `Classes/Perception/` 下（不在 `Classes/` 根，也不在 `Public/`）。
2. **`UPawnSensingComponent` 已废弃**（5.5 起；第 20 行标注）——新代码应使用 AI Perception（`UAIPerceptionComponent`）。
3. **`bCompileRecast` 关闭时 `WITH_RECAST=0`** 且 `Navmesh` 私有依赖消失——依赖表随构建开关变化。
4. **Startup/Shutdown 的调试分类注册不对称**（`PerceptionSystem` 未注销）——如实记录，勿照抄为"对称清理"。
5. **数字口径**：`AIModule.Build.cs` 57 行（`ReadAllLines`）、2 处 `if`、0 处三方静态调用；`Public/` 递归 21 个 `.h`；模块合计 205 个 `.h`。取数命令见「取数说明」。

## 取数说明

以下命令的相对基准为 `Engine/Source`（实际路径按 `_meta/convention.md` 的本机环境块解析）：

| 断言 | 取数方式 |
|---|---|
| `WITH_GAMEPLAY_DEBUGGER` 下注册 **7** 个调试分类 | `[H]` 逐行通读 `Runtime/AIModule/Private/AIModule.cpp` 分类注册段（第 77-87 行）：AI / BehaviorTree / EQS / Navmesh / Perception / PerceptionSystem / NavGrid = **7** |
| 389 文件 / 205 头文件 | `[M]` 引擎磁盘递归计数：`(Get-ChildItem "Runtime/AIModule" -Recurse -File).Count` 得文件数；`(Get-ChildItem "Runtime/AIModule" -Recurse -File -Filter *.h).Count` 得头文件数（同 `_meta/engine-modules.json` 口径） |
| `Public/` 递归 21 个 `.h` | `[M]` `(Get-ChildItem "Runtime/AIModule/Public" -Recurse -File -Filter *.h).Count` |
| Build.cs 57 行、2 处 `if`、0 处三方静态调用 | `[M]` `[System.IO.File]::ReadAllLines("Runtime/AIModule/AIModule.Build.cs").Count`；`Select-String "Runtime/AIModule/AIModule.Build.cs" -Pattern '\bif\s*\(' -AllMatches`；`Select-String "Runtime/AIModule/AIModule.Build.cs" -Pattern 'AddEngineThirdPartyPrivateStaticDependencies' -AllMatches` |
| `SetupGameplayDebuggerSupport` 展开 | UBT `ModuleRules.cs` 第 1662-1700 行 |
| 全部行号引用 | 2026-10-10 对 UE 5.8.3 源码本机逐条核对 |

## 相关文档

- `types/AAIController.md` —— 本模块核心类型（同批产出）
- `modules/NavigationSystem-结构.md` —— 强关联模块（同批产出）
- `modules/GameplayTasks-结构.md` —— `UAITask` 的基类模块（同批产出）
- `modules/Engine-结构.md` —— `AActor` / `AController` 基类链所在模块

## 更新记录

- 2026-10-11 修正「辅助函数已展开」结论：原写"因未传第二参（默认 false）不追加 GameplayDebugger 依赖"，实际默认分支仍以私有依赖追加（编辑器目标再加 GameplayDebuggerEditor）；函数体行范围 1662-1677 → 1662-1700

- 2026-10-11 「取数说明」补入 1 行计数断言取数方式（`convention.md` 4.2 覆盖要求）

- 2026-10-11 按规范 4.2.1 为「取数说明」各行加方法标记（`[M]`/`[R]`/`[H]`）；`[M]` 行把原文省略成 `(...)` 的路径补全为白名单可执行命令，现由 `ue-doc-verify` 逐条实际执行比对
