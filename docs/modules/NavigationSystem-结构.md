> 引擎版本：UE 5.8.3 (Build 58210709)
> 源码根：Engine/Source
> 生成技能：ue-module-structure v1.0
> 生成时间：2026-10-10
> 校验状态：已校验（2026-10-10）

# NavigationSystem 模块结构

## 一、模块定位

| 项 | 值 |
|---|---|
| 路径 | `Engine/Source/Runtime/NavigationSystem` |
| 类别 | Runtime |
| 规模 | 107 文件 / 59 头文件（`_meta/engine-modules.json` 2026-10-10 口径；公开侧 57 + `Private/` 2） |
| 分层 | 框架 |
| 一句话职责 | 导航系统实现：`UNavigationSystemV1`（世界级导航系统）、`ANavigationData` / `ARecastNavMesh`（导航数据与 Recast 实现）、导航区域 / 过滤器 / 图（NavAreas、NavFilters、NavGraph）、导航链接与修饰（NavLink / NavModifier） |

## 二、目录结构

```
NavigationSystem/
├── NavigationSystem.Build.cs     # 模块构建脚本（82 行、4 处 if 分支）
├── DevDocs/                      # 开发文档（How To Optimize Navmesh Generation.md）
├── Public/                       # 公开侧（57 个 .h：顶层 30 + NavAreas/ 7 + NavFilters/ 2 + NavGraph/ 3 + NavMesh/ 15）
└── Private/                      # 实现（25 个文件 + 4 个子目录：NavAreas/ NavFilters/ NavGraph/ NavMesh/）
```

- 无 `Internal/`、无 `Tests/`（实测 0 命中）；无纯聚合头（`NavigationSystem.h` 自身含大量类定义，20 处 include 但非转发头）。

## 三、依赖关系

### 3.1 无条件依赖

| 模块 | 类型 | Build.cs 行 | 说明 |
|---|---|---|---|
| `Chaos` | 公开依赖 | 15 | 另经 `SetupModulePhysicsSupport` 重复注入（见下） |
| `Core` | 公开依赖 | 16 | |
| `CoreUObject` | 公开依赖 | 17 | |
| `Engine` | 公开依赖 | 18 | |
| `GeometryCollectionEngine` | 公开依赖 | 19 | |
| `DerivedDataCache` | 私有包含路径 | 26 | 仅包含路径 |
| `TargetPlatform` | 私有包含路径 | 27 | 仅包含路径 |
| `RHI` | 私有依赖 | 33 | |
| `RenderCore` | 私有依赖 | 34 | |

> **辅助函数已展开**：第 38 行 `SetupModulePhysicsSupport(Target)`（UBT `ModuleRules.cs` 第 1793-1813 行）→
> 追加公开包含路径 `Chaos`；公开依赖 `PhysicsCore`、`ChaosCore`、`Chaos`（**与第 15 行显式项重复**）、`NNE`；
> `WITH_CLOTH_COLLISION_DETECTION=1`；条件追加 `ChaosVDRuntime`。
> **本模块不移除**注入的依赖（对比：`PhysicsCore` 模块会 `Remove` 自引用，见 `modules/PhysicsCore-结构.md` 第六节）。

### 3.2 平台与配置条件依赖

> 全文 **4 处 `if` 分支**（第 40、44、53、72 行）。

| 依赖 / 项 | 类型 | 生效条件 | Build.cs 行 |
|---|---|---|---|
| `Navmesh`（私有依赖）+ `WITH_RECAST=1` | 混合 | `Target.bCompileRecast` | 40-43 |
| `WITH_NAVMESH_SEGMENT_LINKS=1` / `=0` | 编译定义 | 嵌套：`bCompileNavmeshSegmentLinks` | 44-51 |
| `WITH_NAVMESH_CLUSTER_LINKS=1` / `=0` | 编译定义 | 嵌套：`bCompileNavmeshClusterLinks` | 53-60 |
| `WITH_RECAST=0` / `CLUSTER_LINKS=0` / `SEGMENT_LINKS=0` | 编译定义 | `else` 分支 | 62-70 |
| `EditorFramework`、`UnrealEd`（公开依赖）+ `SourceControl`（私有依赖） | 混合 | `Target.bBuildEditor == true` | 72-78 |
| `UnrealEd`（循环引用登记） | `CircularlyReferencedDependentModules` | 同上 | 78 |

### 3.3 第三方静态依赖

调用 **0 处**——无第三方静态依赖（Recast / Navmesh 以**模块**形式私有依赖，第 42 行）。

## 四、对外暴露面

> 公开侧共 57 个 `.h`；核心如下。

| 头文件 | 提供的能力 |
|---|---|
| `Engine/Source/Runtime/NavigationSystem/Public/NavigationSystem.h`（78.68 KB） | `UNavigationSystemV1`（第 291 行）→ `types/UNavigationSystemV1.md` |
| `Engine/Source/Runtime/NavigationSystem/Public/NavigationData.h`（51.88 KB） | `ANavigationData`（第 540 行，`: AActor, INavigationDataInterface`） |
| `Engine/Source/Runtime/NavigationSystem/Public/NavMesh/RecastNavMesh.h` | `ARecastNavMesh` 导航实现 |
| `Engine/Source/Runtime/NavigationSystem/Public/NavigationPath.h` | `UNavigationPath`（第 21 行） |
| `Engine/Source/Runtime/NavigationSystem/Public/NavAreas/NavArea.h` | `UNavArea`（第 14 行，`: public UNavAreaBase`） |
| `Engine/Source/Runtime/NavigationSystem/Public/NavFilters/NavigationQueryFilter.h` | 查询过滤器 |
| `Engine/Source/Runtime/NavigationSystem/Public/NavGraph/NavigationGraph.h` | 导航图 |
| `Engine/Source/Runtime/NavigationSystem/Public/NavLinkComponent.h` | `UNavLinkComponent`（第 16 行，**Public 顶层**） |
| `Engine/Source/Runtime/NavigationSystem/Public/NavMesh/NavMeshBoundsVolume.h` | `ANavMeshBoundsVolume` |
| `Engine/Source/Runtime/NavigationSystem/Public/NavigationSystemModule.h` | 模块接口 `INavSysModule`（第 14 行） |

## 五、模块生命周期

```
文件：Engine/Source/Runtime/NavigationSystem/Private/NavigationSystemModule.cpp
行 16：class FNavigationSystemModule : public INavSysModule
行 32：IMPLEMENT_MODULE(FNavigationSystemModule, NavigationSystem)
```

- **接口**：`INavSysModule : IModuleInterface`（`Public/NavigationSystemModule.h` 第 14 行；静态 `Get()` 第 25-28 行、`IsAvailable()` 第 35-38 行）。
- **`StartupModule()`**（第 39-47 行）：**全部逻辑在 `#if WITH_EDITOR` 内**（非编辑器构建下为空实现）——注册 2 个委托：
  `FWorldDelegates::OnPreWorldInitialization` → `INavLinkCustomInterface::OnPreWorldInitialization`（第 43 行）；
  `FCoreDelegates::GetOnPostEngineInit()` → `ANavMeshBoundsVolume::OnPostEngineInit`（第 44 行）。
  第 41 行留有源码注释 `mz@todo bind to all the delegates in FNavigationSystem`（**未绑定全部委托**，如实记录）。
- **`ShutdownModule()`**（第 48-55 行）：移除上述 2 个委托（第 53-54 行）。
- **`SupportsDynamicReloading`**：未覆写（0 命中）。
- 另：`UNavigationSystemModuleConfig`（`NavigationSystem.h` 第 1491-1492 行）定义于同头文件尾部，负责按世界配置创建导航系统实例（由引擎调用；详见 `types/UNavigationSystemV1.md` 第六节）。

## 六、关键约定与坑

1. **`Public/NavigationSystemBase.h` 不在本模块**——`UNavigationSystemV1` 的基类 `UNavigationSystemBase` 定义在 **Engine**（`Engine/Source/Runtime/Engine/Classes/AI/NavigationSystemBase.h` 第 244 行）；本模块内无该文件（实测 0 命中）。
2. **`NavLinkComponent.h` 在 Public 顶层**（不存在 `NavModifiers/` 子目录）。
3. **`SetupModulePhysicsSupport` 注入的 `PhysicsCore` / `ChaosCore` / `NNE` 不移除**（本模块不为自己做清理）；`Chaos` 与第 15 行显式项重复。
4. **StartupModule 仅编辑器构建生效**（`WITH_EDITOR` 包裹）——运行时构建下不做任何委托注册。
5. **数字口径**：`NavigationSystem.Build.cs` 82 行（`ReadAllLines`）、4 处 `if`、0 处三方静态调用；公开侧 57 个 `.h`（模块合计 59）。取数命令见「取数说明」。

## 取数说明

以下命令的相对基准为 `Engine/Source`（实际路径按 `_meta/convention.md` 的本机环境块解析）：

| 断言 | 取数方式 |
|---|---|
| 107 文件 / 59 头文件 | `_meta/engine-modules.json` 中 `Module -eq 'NavigationSystem'` 行的 `Files`、`Headers` 字段 |
| 公开侧 57 个 `.h` | `(Get-ChildItem "Runtime/NavigationSystem/Public" -Recurse -File -Filter *.h).Count` |
| Build.cs 82 行、4 处 `if`、0 处三方静态调用 | `[System.IO.File]::ReadAllLines(...).Count`；`\bif\s*\(` 与 `AddEngineThirdPartyPrivateStaticDependencies` 全匹配计数 |
| `SetupModulePhysicsSupport` 展开 | UBT `ModuleRules.cs` 第 1793-1813 行 |
| 全部行号引用 | 2026-10-10 对 UE 5.8.3 源码本机逐条核对 |

## 相关文档

- `types/UNavigationSystemV1.md` —— 本模块核心类型（同批产出）
- `modules/AIModule-结构.md` —— 强关联模块（同批产出）
- `modules/PhysicsCore-结构.md` —— 共享 `SetupModulePhysicsSupport` 的模块（同批产出）
- `modules/Engine-结构.md` —— `UNavigationSystemBase` 与 `AActor` 基类链所在模块
