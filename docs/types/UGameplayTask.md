> 引擎版本：UE 5.8.3 (Build 58210709)
> 源码根：Engine/Source
> 生成技能：ue-type-api v1.0
> 生成时间：2026-10-10
> 校验状态：已校验（2026-10-11）

# UGameplayTask

## 一、类型概览

| 项 | 值 |
|---|---|
| 全限定名 | `UGameplayTask`（全局命名空间） |
| 定义位置 | `Engine/Source/Runtime/GameplayTasks/Classes/GameplayTask.h` |
| 类型 | 类（反射类型；异步任务基类） |
| 反射宏 | `UCLASS(Abstract, BlueprintType, meta = (ExposedAsyncProxy=AsyncTask), config = Game, MinimalAPI)`（第 144 行）+ `GENERATED_BODY()`（第 147 行） |
| 导出策略 | `MinimalAPI` + 逐成员 `GAMEPLAYTASKS_API`（该文件 38 处，如第 157、229、273 行） |
| 所属模块 | `GameplayTasks`（`Engine/Source/Runtime/GameplayTasks`） |

## 二、继承链

```
UObjectBase            （Engine/Source/Runtime/CoreUObject/Public/UObject/UObjectBase.h 第 66 行；链根）
  └─ UObjectBaseUtility（Engine/Source/Runtime/CoreUObject/Public/UObject/UObjectBaseUtility.h 第 44 行）
       └─ UObject      （Engine/Source/Runtime/CoreUObject/Public/UObject/Object.h 第 98 行）
            └─ UGameplayTask（GameplayTask.h 第 145 行，`: public UObject, public IGameplayTaskOwnerInterface`）

第二基类：IGameplayTaskOwnerInterface（Engine/Source/Runtime/GameplayTasks/Classes/GameplayTaskOwnerInterface.h 第 20 行；
          UINTERFACE 包装类 `UGameplayTaskOwnerInterface : public UInterface` 第 14-15 行）
```

## 三、声明片段

```
文件：Engine/Source/Runtime/GameplayTasks/Classes/GameplayTask.h
行 144-147：UCLASS(...) / class UGameplayTask : public UObject, public IGameplayTaskOwnerInterface / { / GENERATED_BODY()

文件：Engine/Source/Runtime/GameplayTasks/Classes/GameplayTask.h
行 393：类体结束（};；文件 442 行；其后为 NewTask<T> 模板实现）
```

## 四、公开 API

| 签名 / 成员 | 说明 | 位置（GameplayTask.h） |
|---|---|---|
| `UGameplayTask(const FObjectInitializer&)` | 构造 | 第 153 行 |
| `ReadyForActivation()`（`UFUNCTION(BlueprintCallable)`） | 就绪并请求激活（**蓝图入口**） | 第 157 行 |
| `Activate()`（虚；protected） | 激活实现（覆写点） | 第 162 行 |
| `InitTask(IGameplayTaskOwnerInterface&, uint8)`（protected） | 初始化宿主与优先级 | 第 165 行 |
| `InitSimulatedTask(UGameplayTasksComponent&)`（虚） | 网络模拟端初始化 | 第 168 行 |
| `TickTask(float)`（虚；空实现） | 逐帧 | 第 171 行 |
| `ExternalConfirm(bool)` / `ExternalCancel()`（虚） | 外部确认结束 / 取消 | 第 174 / 177 行 |
| `MarkOwnerFinished()` | 宿主结束标记（inline） | 第 180 行 |
| `GetDebugString()`（虚） | 调试串 | 第 183 行 |
| `GetWorld()`（override） | 世界 | 第 186 行 |
| `GetOwnerActor()` / `GetAvatarActor()` | 宿主 / 化身 Actor | 第 189 / 192 行 |
| `TaskOwnerEnded()` | 宿主结束流程 | 第 222 行 |
| `EndTask()`（`UFUNCTION(BlueprintCallable)`） | 结束任务（**蓝图入口**） | 第 229 行 |
| `IsSupportedForNetworking()`（override） | 网络支持（受 `bSimulatedTask`） | 第 231 行 |
| `GetState()` / `IsActive()` / `IsPaused()` / `IsFinished()` | 状态查询（inline） | 第 244-247 行 |
| `GetChildTask()` | 子任务 | 第 249 行 |
| `AddRequiredResource(...)` / `AddRequiredResourceSet(...)` / `AddClaimedResource(...)` / `AddClaimedResourceSet(...)` | 资源声明（4 个 Add* 系列） | 第 273-281 行 |
| `GetTaskStateName()` | 状态名（字符串） | 第 289 行 |
| `OnDestroy(bool)`（虚；protected） | 销毁回调（覆写点） | 第 297 行 |
| `Pause()` / `Resume()`（虚；protected） | 暂停 / 恢复 | 第 303 / 304 行 |

> **不存在**（实测 0 命中）：`GetTaskState()`（实际为 `GetState()`，第 244 行）、`AddResource()` / `RequestResource()`（实际为 4 个 `AddRequiredResource*` / `AddClaimedResource*`，第 273-281 行）。

## 五、扩展点

### 5.1 可覆写虚函数（类内 21 条；**0 条纯虚**）

| 组 | 成员（行号） |
|---|---|
| 任务生命周期（核心覆写面） | `Activate`(162)、`InitSimulatedTask`(168)、`TickTask`(171)、`ExternalConfirm`(174)、`ExternalCancel`(177)、`OnDestroy`(297)、`Pause`(303)、`Resume`(304) |
| 查询 / 网络 | `GetDebugString`(183)、`GetWorld`(186)、`IsSupportedForNetworking`(231)、`IsWaitingOnRemotePlayerdata`(285)、`IsWaitingOnAvatar`(287)、`RegisterReplicationFragments`(316) |
| 宿主接口实现（`IGameplayTaskOwnerInterface` 的 6 个 override） | 第 307-312 行（`GetGameplayTasksComponent` / `GetGameplayTaskOwner` / `GetGameplayTaskAvatar` / `GetGameplayTaskDefaultPriority` / `OnGameplayTaskInitialized` / `OnGameplayTaskDeactivated`） |
| 调试（`WITH_GAMEPLAYTASK_DEBUG`） | `GenerateDebugDescription`(391) |

> **蓝图事件：无**（`BlueprintNativeEvent` / `BlueprintImplementableEvent` 均 0 命中）；蓝图可达仅 `ReadyForActivation` / `EndTask` 两处 `BlueprintCallable`。

### 5.2 不建议覆写的内部虚函数

无。

## 六、生命周期

- 任务对象由 `UGameplayTasksComponent` 驱动：请求激活（`ReadyForActivation`）→ `Activate` → 运行（`TickTask`）→ `EndTask` / `ExternalCancel` → `OnDestroy`；宿主结束经 `TaskOwnerEnded`（第 222 行）。
- 网络模拟（`InitSimulatedTask`）与资源调度（`UGameplayTaskResource`）链路属 `flows/` 范畴（暂无 GameplayTasks 流程产物）。

## 七、派生类（范围内）

搜索边界：派生类搜索**覆盖 Runtime 291 个模块 + `EnhancedInput` 插件全部 3 个模块（共 294 个模块）**。搜索模式 `\bpublic\s+UGameplayTask\b`（`*.h`）：Runtime **5 命中 / 5 文件**；EnhancedInput **0**。

| 派生类 | 位置 |
|---|---|
| `UAITask` | `Engine/Source/Runtime/AIModule/Classes/Tasks/AITask.h` 第 24 行（批 8 模块） |
| `UGameplayTask_WaitDelay` | `Engine/Source/Runtime/GameplayTasks/Classes/Tasks/GameplayTask_WaitDelay.h` 第 12 行 |
| `UGameplayTask_ClaimResource` | `Engine/Source/Runtime/GameplayTasks/Classes/Tasks/GameplayTask_ClaimResource.h` 第 15 行 |
| `UGameplayTask_SpawnActor` | `Engine/Source/Runtime/GameplayTasks/Classes/Tasks/GameplayTask_SpawnActor.h` 第 29 行 |
| `UGameplayTask_TimeLimitedExecution` | `Engine/Source/Runtime/GameplayTasks/Classes/Tasks/GameplayTask_TimeLimitedExecution.h` 第 18 行 |

## 取数说明

| 断言 | 取数方式（相对基准：`Engine/Source`） |
|---|---|
| 搜索边界 294 个模块（Runtime 291 + `EnhancedInput` 插件 3） | `[M]` 插件 3 个模块（含白名单外的 `InputBlueprintNodes` / `InputEditor`）：`(Get-ChildItem "Engine/Plugins/EnhancedInput/Source" -Directory).Count` → 3；Runtime 291 见 `_meta/inventory.md` |
| 文件 442 行、类体 144-393 | `[M]` `[System.IO.File]::ReadAllLines("Engine/Source/Runtime/GameplayTasks/Classes/GameplayTask.h").Count`（同文件 `^};` 检索定类体区间） |
| 类内 `virtual` 21 条 | `[H]` `Select-String -Pattern 'virtual'` 全匹配 + 逐段核对 |
| 派生统计：Runtime 5 / EnhancedInput 0 | `[H]` `Select-String -Pattern '\bpublic\s+UGameplayTask\b'`（`*.h`） |
| 全部行号引用 | 2026-10-10 对 UE 5.8.3 源码本机逐条核对 |

## 相关文档

- `modules/GameplayTasks-结构.md` —— UGameplayTask 所在模块（同批产出）
- `types/UMovieSceneSequence.md` —— 同批类型
- `modules/AIModule-结构.md` —— `UAITask` 派生类的宿主模块（同批产出）
- `types/UObject.md` —— 基类链终点（已校验）

## 更新记录

- 2026-10-11 修正 `GAMEPLAYTASKS_API` 处数（26 → 38）

- 2026-10-11 搜索边界更正：派生搜索实覆盖 **294** 个模块（Runtime 291 + `EnhancedInput` 插件 3），原文误作"纳入范围的 292 个模块"（292 是白名单口径，搜索实际连 `InputBlueprintNodes` / `InputEditor` 一并覆盖，本文件命中的插件侧结果即来自 `InputEditor`）；同时在「取数说明」补入该边界取数方式（`convention.md` 4.2）

- 2026-10-11 按规范 4.2.1 为「取数说明」各行加方法标记（`[M]`/`[R]`/`[H]`）；`[M]` 行把原文省略成 `(...)` 的路径补全为白名单可执行命令，现由 `ue-doc-verify` 逐条实际执行比对
