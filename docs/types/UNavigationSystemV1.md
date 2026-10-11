> 引擎版本：UE 5.8.3 (Build 58210709)
> 源码根：Engine/Source
> 生成技能：ue-type-api v1.0
> 生成时间：2026-10-10
> 校验状态：已校验（2026-10-11）

# UNavigationSystemV1

## 一、类型概览

| 项 | 值 |
|---|---|
| 全限定名 | `UNavigationSystemV1`（全局命名空间） |
| 定义位置 | `Engine/Source/Runtime/NavigationSystem/Public/NavigationSystem.h` |
| 类型 | 类（反射类型；世界级导航系统） |
| 反射宏 | `UCLASS(Within=World, config=Engine, defaultconfig, MinimalAPI)`（第 290 行；**`Within=World`**——每 World 一个实例）+ `GENERATED_BODY()`（第 293 行） |
| 导出策略 | `MinimalAPI` + 逐成员 `NAVIGATIONSYSTEM_API`（如第 298、301、1177 行） |
| 所属模块 | `NavigationSystem`（`Engine/Source/Runtime/NavigationSystem`） |

## 二、继承链

```
UObjectBase            （Engine/Source/Runtime/CoreUObject/Public/UObject/UObjectBase.h 第 66 行；链根）
  └─ UObjectBaseUtility（Engine/Source/Runtime/CoreUObject/Public/UObject/UObjectBaseUtility.h 第 44 行）
       └─ UObject      （Engine/Source/Runtime/CoreUObject/Public/UObject/Object.h 第 98 行）
            └─ UNavigationSystemBase（Engine/Source/Runtime/Engine/Classes/AI/NavigationSystemBase.h 第 244 行，
                                      `UCLASS(Abstract, config = Engine, defaultconfig, Transient, MinimalAPI)` 第 243 行）
                 └─ UNavigationSystemV1（Engine/Source/Runtime/NavigationSystem/Public/NavigationSystem.h 第 291 行）
```

## 三、声明片段

```
文件：Engine/Source/Runtime/NavigationSystem/Public/NavigationSystem.h
行 290-293：UCLASS(Within=World, ...) / class UNavigationSystemV1 : public UNavigationSystemBase / { / GENERATED_BODY()

文件：Engine/Source/Runtime/NavigationSystem/Public/NavigationSystem.h
行 1486：类体结束（};；文件 1,530 行；其后 1488-1531 为 UNavigationSystemModuleConfig）
```

## 四、公开 API

| 签名 | 说明 | 位置（NavigationSystem.h） |
|---|---|---|
| `UNavigationSystemV1(...)` / `~UNavigationSystemV1()` | 构造 / 析构 | 第 298 / 299 行 |
| `static GetNavigationSystem(UObject*)` | 取实例（蓝图） | 第 502 行 |
| `static FindPathToLocationSynchronously(...)` | 同步寻路（位置目标） | 第 535 行 |
| `static FindPathToActorSynchronously(...)` | 同步寻路（Actor 目标） | 第 541 行 |
| `static GetPathLength(...)` | 路径长度（静态蓝图版） | 第 524 行 |
| `static NavigationRaycast(...)` | 导航射线检测 | 第 548 行 |
| `static K2_ProjectPointToNavigation` / `K2_GetRandomReachablePointInRadius` / `K2_GetRandomLocationInNavigableRadius` | 蓝图投影 / 随机点 | 第 506 / 511 / 516 行 |
| `FindPathSync(...)` / `FindPathAsync(...)` | 实例寻路（同步 / 异步） | 第 650 / 668 行 |
| `GetRandomPoint(...)` / `GetRandomReachablePointInRadius(...)` / `GetRandomPointInNavigableRadius(...)` | 随机点 | 第 685 / 691 / 697 行 |
| `GetPathLength(const FVector&, const FVector&, ...)` | 实例路径长度 | 第 705 行 |
| `ProjectPointToNavigation(...)`（inline + 导出重载） | 投影到导航 | 第 712 / 718 行 |
| `GetDefaultNavDataInstance(...)` | 默认导航数据 | 第 743 行 |
| `static GetCurrent(UWorld*)` / `GetCurrent(UObject*)` | 当前世界的系统实例 | 第 1177 / 1178 行 |
| `UnregisterNavData(...)` / `ReleaseInitialBuildingLock()` | 注销导航数据 / 释放构建锁 | 第 844 / 901 行 |
| `RegisterNavData(...)`（**protected**） | 注册导航数据 | 第 1331 行 |

> `GetPathLengthSynchronously` 命名未找到（**未确认 ≠ 不存在**，未扩大范围验证）。

## 五、扩展点

### 5.1 可覆写虚函数（≥61 条；工具计数为下限，分组如下）

**a) UObject 生命周期覆写**

| `PostInitProperties`(613)、`FinishDestroy`(614)、`PostEditChangeChainProperty`(617，编辑器)、`PostEditChangeProperty`(618，编辑器)、`Tick`(622，**导航增量构建/更新钩子**)、`GetWorld`(624，inline)、`ApplyWorldOffset`(806) |
|---|

**b) 导航系统生命周期（基类 `UNavigationSystemBase` 契约 override）**

| `GetMainNavData`(745)、`SetBuildBounds`(749)、`GetNavigableWorldBounds`(751)、`ContainsNavData`(753)、`ComputeNavDataBounds`(754)、`AddNavigationDataChunk`(755)、`RemoveNavigationDataChunk`(756)、`FillNavigationDataChunkActor`(757)、`IsNavigationBuilt`(775)、`OnNavigationGenerationFinished`(1103)、`CleanUp`(1127)、`OnInitializeActors`(1132)、`OnWorldInitDone`(1135)、`IsWorldInitDone`(1138)、`InitializeForWorld`(1180)、`ShouldCreateNavigationSystemInstance`(1199)、`Configure`(1470)、`AppendConfig`(1471) |
|---|

**c) 其它扩展点（节选）**

`UpdateNavDataActiveTiles`(474)、`CreateCrowdManager`(632)、`GetNavDataForProps` ×3(723/728/740)、`GetNavDataForAgentName`(732)、`CreateNavigationDataInstanceInLevel`(767)、`IsThereAnywhereToBuildNavigation`(777)、`ShouldLoadNavigationOnClient`(782)、`ShouldDiscardSubLevelNavData`(783)、`RegisterInvoker`(824/826)、`UnregisterInvoker`(828/830)、`UnregisterUnusedNavData`(849)、`RequestRegistrationDeferred`(852)、`ConditionalPopulateNavOctree`(864)、`ConstructNavOctree`(867)、`ProcessRegistrationCandidates`(870)、`PerformNavigationBoundsUpdate`(876)、`GatherNavigationBounds`(882)、`GetIsAutoUpdateEnabled`(1159)、`RebuildDirtyAreas`(1386)、`RebuildAll`(1392)、`DestroyNavOctree`(1427)、`GetNavigationBoundsForNavData`(1468)。

### 5.2 不建议覆写的内部虚函数

无单列——b) 组均为基类契约（实现者义务面）。

## 六、生命周期

- **`Within=World`**：实例挂在 `UWorld` 上；由 `UNavigationSystemModuleConfig`（同文件第 1491-1492 行）按世界配置创建（引擎侧调用），`GetCurrent`（第 1177 行）取当前世界的实例。
- 构建流程：`InitializeForWorld`（第 1180 行）→ 生成/加载导航数据（`NavData`）→ `Tick`（第 622 行）驱动增量重建（`RebuildDirtyAreas` 第 1386 行）；卸载经 `CleanUp`（第 1127 行）、`DestroyNavOctree`（第 1427 行）。
- 完整时序属 `flows/` 范畴（暂无导航流程产物）。

## 七、派生类（范围内）

搜索边界：`Engine/Source` 全树（含 Runtime 与 EnhancedInput）；搜索模式 `\bpublic\s+UNavigationSystemV1\b`（`*.h`）：**0 命中**（另以字面量二次确认仍为 0）。

| 派生类 | — |
|---|---|
| （无） | 引擎内无派生类；系统扩展经子类化 `UNavigationSystemBase`（Engine）或配置类实现 |

## 取数说明

| 断言 | 取数方式（相对基准：`Engine/Source`） |
|---|---|
| 文件 1,530 行、类体 290-1486 | `[M]` `[System.IO.File]::ReadAllLines("Engine/Source/Runtime/NavigationSystem/Public/NavigationSystem.h").Count`（同文件 `^};` 检索定类体区间） |
| 类内 `virtual` ≥61 条 | `[H]` content 模式（28 条随输出截断，计入下限）；count 模式在本环境异常已注明 |
| 派生 0 命中 | `[H]` `Select-String -Pattern '\bpublic\s+UNavigationSystemV1\b'`（`*.h`）+ 字面量复核 |
| 全部行号引用 | 2026-10-10 对 UE 5.8.3 源码本机逐条核对 |

## 相关文档

- `modules/NavigationSystem-结构.md` —— UNavigationSystemV1 所在模块（同批产出）
- `modules/AIModule-结构.md`、`types/AAIController.md` —— 导航的主要消费方（同批产出）
- `modules/Engine-结构.md` —— `UNavigationSystemBase` 定义模块
- `types/UObject.md` —— 基类链终点（已校验）

## 更新记录

- 2026-10-11 按规范 4.2.1 为「取数说明」各行加方法标记（`[M]`/`[R]`/`[H]`）；`[M]` 行把原文省略成 `(...)` 的路径补全为白名单可执行命令，现由 `ue-doc-verify` 逐条实际执行比对
