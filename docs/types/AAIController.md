> 引擎版本：UE 5.8.3 (Build 58210709)
> 源码根：Engine/Source
> 生成技能：ue-type-api v1.0
> 生成时间：2026-10-10
> 校验状态：已校验（2026-10-11）

# AAIController

## 一、类型概览

| 项 | 值 |
|---|---|
| 全限定名 | `AAIController`（全局命名空间） |
| 定义位置 | `Engine/Source/Runtime/AIModule/Classes/AIController.h` |
| 类型 | 类（反射类型） |
| 反射宏 | `UCLASS(ClassGroup = AI, BlueprintType, Blueprintable, MinimalAPI)`（第 86 行）+ `GENERATED_BODY()`（第 89 行） |
| 导出策略 | `MinimalAPI` + 逐成员 `AIMODULE_API`（该文件 57+ 处，如第 158、172、262、390 行） |
| 所属模块 | `AIModule`（`Engine/Source/Runtime/AIModule`） |

## 二、继承链

```
UObjectBase            （Engine/Source/Runtime/CoreUObject/Public/UObject/UObjectBase.h 第 66 行；链根）
  └─ UObjectBaseUtility（Engine/Source/Runtime/CoreUObject/Public/UObject/UObjectBaseUtility.h 第 44 行）
       └─ UObject      （Engine/Source/Runtime/CoreUObject/Public/UObject/Object.h 第 98 行）
            └─ AActor  （Engine/Source/Runtime/Engine/Classes/GameFramework/Actor.h 第 282 行）
                 └─ AController（Engine/Source/Runtime/Engine/Classes/GameFramework/Controller.h 第 40 行，`: public AActor, public INavAgentInterface`）
                      └─ AAIController（Engine/Source/Runtime/AIModule/Classes/AIController.h 第 87 行）
```

第二~五基类（第 87 行）：`IAIPerceptionListenerInterface`、`IGameplayTaskOwnerInterface`、`IGenericTeamAgentInterface`、`IVisualLoggerDebugSnapshotInterface`。

## 三、声明片段

```
文件：Engine/Source/Runtime/AIModule/Classes/AIController.h
行 86-89：UCLASS(..., MinimalAPI) / class AAIController : public AController, ... / { / GENERATED_BODY()

文件：Engine/Source/Runtime/AIModule/Classes/AIController.h
行 458：类体结束（};；文件 470 行；其后为 FAISystem 前置声明区）
```

## 四、公开 API

| 签名 | 说明 | 位置（AIController.h） |
|---|---|---|
| `AAIController(...)` | 构造 | 第 158 行 |
| `MoveToActor(...)` | 移动到 Actor | 第 172 行 |
| `MoveToLocation(...)` | 移动到位置 | 第 187 行 |
| `MoveTo(const FAIMoveRequest&, ...)`（虚） | 通用移动请求 | 第 196 行 |
| `PauseMove(...)` / `ResumeMove(...)` | 暂停 / 恢复移动 | 第 221 / 224 行 |
| `StopMovement()`（虚） | 停止移动 | 第 227 行 |
| `GetCurrentMoveRequestID()` / `GetMoveStatus()` / `HasPartialPath()` / `GetImmediateMoveDestination()` | 移动状态查询 | 第 236 / 246 / 250 / 254 行 |
| `RunBehaviorTree(UBehaviorTree*)`（虚） | 运行行为树 | 第 262 行 |
| `UseBlackboard(...)` | 使用黑板资产 | 第 282 行 |
| `GetFocalPoint()` / `GetFocusActor()` | 焦点查询 | 第 302 / 320 行 |
| `SetPerceptionComponent(...)` / `GetPerceptionComponent()`（override） | 感知组件 | 第 390 / 394 行 |
| `GetPathFollowingComponent()` / `GetAIPerceptionComponent()` / `GetBrainComponent()` / `GetBlackboardComponent()` | 组件访问（inline） | 第 444 / 446 / 450 / 451 行 |
| `SetPathFollowingComponent(...)` | 设置跟随组件 | 第 457 行 |
| `ClaimTaskResource(...)` / `UnclaimTaskResource(...)` | GameplayTask 资源 | 第 288 / 291 行 |
| `static ToggleAIIgnorePlayers()` / `AreAIIgnoringPlayers()` / `static bool bAIIgnorePlayers` | AI 调试开关 | 第 435 / 436 / 439 行 |

## 五、扩展点

### 5.1 可覆写虚函数（类内 45 条，分组）

| 组 | 成员（行号） |
|---|---|
| **a) 生命周期 / 框架覆写（17）** | `SetPawn`(160)、`SetControlRotation`(266)、`Tick`(344)、`PostInitializeComponents`(345)、`PostRegisterAllComponents`(346)、`OnPossess`(351)、`OnUnPossess`(352)、`ShouldPostponePathUpdates`(355)、`DisplayDebug`(356)、`GrabDebugSnapshot`(359，`ENABLE_VISUAL_LOG`)、`Reset`(362)、`LineOfSightTo`(371)、`OnGameplayTaskInitialized`(422)、`OnGameplayTaskActivated`(423)、`OnGameplayTaskDeactivated`(424)、`OnGameplayTaskResourcesClaimed`(427)、`GetDebugIcon`(432) |
| **b) 移动 / 路径（11）** | `MoveTo`(196)、`RequestMove`(199)、`FindPathForMoveRequest`(206)、`PreparePathfinding`(215，废弃)、`RequestPathAndMove`(218，废弃)、`StopMovement`(227)、`OnMoveCompleted`(230 / 233)、`MergePaths`(272)、`IsFollowingAPath`(399)、`GetPathFollowingAgent`(400) |
| **c) 感知 / 黑板 / 朝向（8）** | `ShouldSyncBlackboardWith`(285)、`InitializeBlackboard`(297)、`GetFocalPointOnActor`(308)、`ActorsPerceptionUpdated`(375)、`UpdateControlRotation`(378)、`SetFocalPoint`(381)、`SetFocus`(384)、`ClearFocus`(388) |
| **d) 其它（9）** | `RunBehaviorTree`(262)、`CleanupBrainComponent`(269)、`GetPerceptionComponent`(394)、`SetGenericTeamId`(408)、`GetGenericTeamId`(409)、`GetGameplayTasksComponent`(414)、`GetGameplayTaskOwner`(415)、`GetGameplayTaskAvatar`(416)、`GetGameplayTaskDefaultPriority`(417) |

> 蓝图事件：`OnUsingBlackBoard(...)`（`BlueprintImplementableEvent`，第 294-295 行）。
> protected 配置位：`bStartAILogicOnPossess`（第 97-98 行）、`bStopAILogicOnUnposses`（第 102-103 行）。
> b) 组中 3 个 `UE_DEPRECATED_FORGAME` 入口（第 215 / 218 / 233 行）不要用于新代码。

### 5.2 不建议覆写的内部虚函数

无——45 条均为框架覆写面。

## 六、生命周期

- Controller 体系：进入 `OnPossess`（第 351 行）→ `Tick`（第 344 行）驱动行为树 / 感知更新 → 退出 `OnUnPossess`（第 352 行）；移动请求（`MoveTo*`）由 `UPathFollowingComponent` 执行，完成回调 `OnMoveCompleted`（第 230 行）。
- 详细时序属 `flows/` 范畴（暂无 AI 流程产物）。

## 七、派生类（范围内）

搜索边界：派生类搜索**覆盖 Runtime 291 个模块 + `EnhancedInput` 插件全部 3 个模块（共 294 个模块）**。搜索模式 `\bpublic\s+AAIController\b`（`*.h`）：Runtime **2 命中 / 2 文件**；EnhancedInput **0**。

| 派生类 | 位置 |
|---|---|
| `ADetourCrowdAIController` | `Engine/Source/Runtime/AIModule/Classes/DetourCrowdAIController.h` 第 14 行 |
| `AGridPathAIController` | `Engine/Source/Runtime/AIModule/Classes/GridPathAIController.h` 第 9 行 |

## 取数说明

| 断言 | 取数方式（相对基准：`Engine/Source`） |
|---|---|
| 搜索边界 294 个模块（Runtime 291 + `EnhancedInput` 插件 3） | `[M]` 插件 3 个模块（含白名单外的 `InputBlueprintNodes` / `InputEditor`）：`(Get-ChildItem "Engine/Plugins/EnhancedInput/Source" -Directory).Count` → 3；Runtime 291 见 `_meta/inventory.md` |
| 文件 470 行、类体 86-458 | `[M]` `[System.IO.File]::ReadAllLines("Engine/Source/Runtime/AIModule/Classes/AIController.h").Count`（同文件 `^};` 检索定类体区间） |
| 类内 `virtual` 45 条（a17+b11+c8+d9） | `[H]` content 模式逐行枚举（工具行头计数不可靠，口径已注明） |
| 派生统计：Runtime 2 / EnhancedInput 0 | `[H]` `Select-String -Pattern '\bpublic\s+AAIController\b'`（`*.h`） |
| 全部行号引用 | 2026-10-10 对 UE 5.8.3 源码本机逐条核对 |

## 相关文档

- `modules/AIModule-结构.md` —— AAIController 所在模块（同批产出）
- `types/UNavigationSystemV1.md` —— 同批类型
- `types/AActor.md` —— 基类链中的 `AActor`（批 2 产出）
- `types/UGameplayTask.md` —— `IGameplayTaskOwnerInterface` 关联（同批产出）

## 更新记录

- 2026-10-11 搜索边界更正：派生搜索实覆盖 **294** 个模块（Runtime 291 + `EnhancedInput` 插件 3），原文误作"纳入范围的 292 个模块"（292 是白名单口径，搜索实际连 `InputBlueprintNodes` / `InputEditor` 一并覆盖，本文件命中的插件侧结果即来自 `InputEditor`）；同时在「取数说明」补入该边界取数方式（`convention.md` 4.2）

- 2026-10-11 按规范 4.2.1 为「取数说明」各行加方法标记（`[M]`/`[R]`/`[H]`）；`[M]` 行把原文省略成 `(...)` 的路径补全为白名单可执行命令，现由 `ue-doc-verify` 逐条实际执行比对
