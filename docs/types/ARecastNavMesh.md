> 引擎版本：UE 5.8.3 (Build 58210709)
> 源码根：Engine/Source
> 生成技能：ue-type-api v1.0
> 生成时间：2026-10-10
> 校验状态：已校验（2026-10-11）

# ARecastNavMesh

## 一、类型概览

| 项 | 值 |
|---|---|
| 全限定名 | `ARecastNavMesh`（全局命名空间） |
| 定义位置 | `Engine/Source/Runtime/NavigationSystem/Public/NavMesh/RecastNavMesh.h`（**所属模块为 `NavigationSystem`**，不是 `Navmesh`——随本批 Navmesh 模块产出并如实标注，同 `types/FSceneInterface.md` 之于 Renderer 的先例） |
| 类型 | 类（反射类型；Recast 导航数据 Actor） |
| 反射宏 | `UCLASS(config=Engine, defaultconfig, hidecategories=(Input,Rendering,Tags,Transformation,Actor,Layers,Replication), notplaceable, MinimalAPI)`（第 570 行）+ **`GENERATED_UCLASS_BODY()`**（第 573 行） |
| 导出策略 | `MinimalAPI` + 逐成员 `NAVIGATIONSYSTEM_API` |
| 所属模块 | `NavigationSystem`（`Engine/Source/Runtime/NavigationSystem`） |

## 二、继承链

```
UObjectBase            （Engine/Source/Runtime/CoreUObject/Public/UObject/UObjectBase.h 第 66 行；链根）
  └─ UObjectBaseUtility（Engine/Source/Runtime/CoreUObject/Public/UObject/UObjectBaseUtility.h 第 44 行）
       └─ UObject      （Engine/Source/Runtime/CoreUObject/Public/UObject/Object.h 第 98 行）
            └─ AActor  （Engine/Source/Runtime/Engine/Classes/GameFramework/Actor.h 第 282 行）
                 └─ ANavigationData（Engine/Source/Runtime/NavigationSystem/Public/NavigationData.h 第 540 行，`: public AActor, public INavigationDataInterface`）
                      └─ ARecastNavMesh（RecastNavMesh.h 第 571 行）
```

## 三、声明片段

```
文件：Engine/Source/Runtime/NavigationSystem/Public/NavMesh/RecastNavMesh.h
行 570-573：UCLASS(...MinimalAPI) / class ARecastNavMesh : public ANavigationData / { / GENERATED_UCLASS_BODY()

文件：Engine/Source/Runtime/NavigationSystem/Public/NavMesh/RecastNavMesh.h
行 1643：类体结束（};；文件 1,680 行）

条件编译：类体内 WITH_RECAST 块（第 1007-1633 行）——非 Recast 构建走 1616-1632 的 stub 实现（如 GetBounds 返回空 FBox）
```

## 四、公开 API

| 签名 | 说明 | 位置 |
|---|---|---|
| `CleanUp()`（虚） | 清理导航数据 | 第 1040 行 |
| `GetRandomPoint(...)` / `GetRandomReachablePointInRadius(...)`（虚） | 随机点 | 第 1043 / 1046 行 |
| `FindMoveAlongSurface(...)`（虚） | 沿表面移动 | 第 1049 行 |
| `ProjectPoint(...)` / `BatchProjectPoints(...)`（虚） | 投影 | 第 1053 / 1057 行 |
| `CalcPathCost(...)` / `CalcPathLength(...)` / `CalcPathLengthAndCost(...)`（虚） | 路径代价/长度 | 第 1064 / 1065 / 1066 行 |
| `ConstructRenderingComponent()`（虚） | 可视化组件 | 第 1069 行 |
| `GetBounds() const`（虚，inline → `GetNavMeshBounds()`） | 包围盒 | 第 1071 行 |
| `ApplyWorldOffset(...)`（虚） | 世界偏移 | 第 1073 行 |
| `GetTileSizeUU() const` | 瓦片尺寸（UU） | 第 1125 行 |
| `GetNavMeshBounds() const` / `GetNavMeshTileBounds(...) const` | 导航网格包围盒 | 第 1131 / 1138 行 |
| `GetNavMeshTilesAt(...) const` / `GetNavMeshTilesCount() const` | 瓦片查询 | 第 1165 / 1168 行 |
| `GetDebugGeometryForTile(...) const`（含 FNavTileRef 重载第 1247 行） | 调试几何 | 第 1240 行 |
| `static FindPath(...)` | 静态寻路 | 第 1444 行 |
| `K2_ReplaceAreaInTileBounds(...)`（`UFUNCTION(BlueprintCallable)`） | 批量替换区域 | 第 1642 行 |
| 其他 | `Serialize`(577)、`PostInitProperties`(1014)、`PostLoad`(1015)、`PostRegisterAllComponents`(1016) 等 | 见左 |

> **不存在于本类**：`GetConfig`（在基类 `ANavigationData` 第 657 行，inline）；`GetDebugGeometry` 确切名（仅 `GetDebugGeometryForTile`）。

## 五、扩展点

### 5.1 可覆写虚函数

> 文件内 `\bvirtual\b` 全匹配 **89 处**、`\boverride\b` **79 处**。分组：

| 组 | 代表（行号） |
|---|---|
| **a) UObject / AActor 生命周期与编辑器（14）** | `Serialize`(577)、`CanEditChange`(580)、`PostInitProperties`(1014)、`PostLoad`(1015)、`PostRegisterAllComponents`(1016)、`PostEditChangeChainProperty`(1026)、`PostEditChangeProperty`(1027)、`PostEditUndo`(1028)、`PostTransacted`(1029)、`CleanUp`(1040)、`ApplyWorldOffset`(1073)、`GetWorldPartitionNavigationDataBuilderOverlap`(1084)、`OnRegistered`(1102)、`OnUnregistered`(1103) |
| **b) ANavigationData / 查询覆写（39）** | `GetRandomPoint` 系列（1043-1046）、`FindMoveAlongSurface`(1049)、`ProjectPoint`/`BatchProjectPoints`(1053/1057)、`CalcPath*`(1064-1066)、`GetBounds`(1071)、`ConstructRenderingComponent`(1069)、`FindPath`(1444)、以及 stub 分支（1616-1632）等 |
| **c) 其它（余量 36）** | 瓦片/生成/调试相关 |

### 5.2 不建议覆写的内部虚函数

无单列——b) 组为 `ANavigationData` 契约（实现者义务面）。

## 六、生命周期

- **nav data Actor**：挂在关卡中（`notplaceable`，由导航系统生成/加载）；导航网格的构建经 `FRecastNavMeshGenerator`（见第七节）。
- 查询面（投影/随机点/寻路/调试几何）供 `UNavigationSystemV1`（`types/UNavigationSystemV1.md`）与 `AAIController` 使用。

## 七、派生类（范围内）

搜索边界：派生类搜索**覆盖 Runtime 291 个模块 + `EnhancedInput` 插件全部 3 个模块（共 294 个模块）**。搜索模式 `\bpublic\s+ARecastNavMesh\b`（`*.h`）：Runtime **0 命中**；EnhancedInput **0**（另以 `Engine/Source` 全树复核仍为 0；同模式命中的仅前向声明，如 `RecastNavMesh.h` 第 54 行）。

| 派生类 | — |
|---|---|
| （无） | 叶子类 |

> 配套定位：`FRecastNavMeshGenerator`（`NavigationSystem/Public/NavMesh/RecastNavMeshGenerator.h` 第 765 行，`: public FNavDataGenerator`；注释"Class that handles generation of the whole Recast-based navmesh"）；`ANavigationData`（`NavigationData.h` 第 540 行）。

## 取数说明

| 断言 | 取数方式（相对基准：`Engine/Source`） |
|---|---|
| 搜索边界 294 个模块（Runtime 291 + `EnhancedInput` 插件 3） | `[M]` 插件 3 个模块（含白名单外的 `InputBlueprintNodes` / `InputEditor`）：`(Get-ChildItem "Engine/Plugins/EnhancedInput/Source" -Directory).Count` → 3；Runtime 291 见 `_meta/inventory.md` |
| 文件 1,680 行、类体 570-1643 | `[M]` `[System.IO.File]::ReadAllLines("Engine/Source/Runtime/NavigationSystem/Public/NavMesh/RecastNavMesh.h").Count`（同文件 `^};` 检索定类体区间） |
| `virtual` 89 / `override` 79 | `[M]` 类体内计数（第 570-1643 行）：`Select-String "Engine/Source/Runtime/NavigationSystem/Public/NavMesh/RecastNavMesh.h" -Pattern 'virtual' -AllMatches -Range 570-1643`；同文件同区间 `-Pattern 'override' -AllMatches -Range 570-1643` |
| 派生统计：0 命中 | `[H]` `Select-String -Pattern '\bpublic\s+ARecastNavMesh\b'`（`*.h`） |
| 全部行号引用 | 2026-10-10 对 UE 5.8.3 源码本机逐条核对 |

## 相关文档

- `modules/Navmesh-结构.md` —— 同批模块（其消费的 Recast/Detour 实现层）
- `types/UNavigationSystemV1.md` —— 导航系统（批 8）
- `modules/NavigationSystem-结构.md` —— ARecastNavMesh 的真实归属模块（批 8）
- `types/AAIController.md` —— 主要消费方（批 8）

## 更新记录

- 2026-10-11 搜索边界更正：派生搜索实覆盖 **294** 个模块（Runtime 291 + `EnhancedInput` 插件 3），原文误作"纳入范围的 292 个模块"（292 是白名单口径，搜索实际连 `InputBlueprintNodes` / `InputEditor` 一并覆盖，本文件命中的插件侧结果即来自 `InputEditor`）；同时在「取数说明」补入该边界取数方式（`convention.md` 4.2）

- 2026-10-11 按规范 4.2.1 为「取数说明」各行加方法标记（`[M]`/`[R]`/`[H]`）；`[M]` 行把原文省略成 `(...)` 的路径补全为白名单可执行命令，现由 `ue-doc-verify` 逐条实际执行比对
- 2026-10-11 「`virtual` 89 / `override` 79」明确为**类体内**（第 570-1643 行）口径，命令用 `-Range` 复算（全文为 92 / 80）
