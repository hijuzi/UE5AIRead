> 引擎版本：UE 5.8.3 (Build 58210709)
> 源码根：Engine/Source
> 生成技能：ue-module-structure v1.0
> 生成时间：2026-10-10
> 校验状态：已校验（2026-10-11）

# PhysicsCore 模块结构

## 一、模块定位

| 项 | 值 |
|---|---|
| 路径 | `Engine/Source/Runtime/PhysicsCore` |
| 类别 | Runtime |
| 规模 | 65 文件 / 42 头文件（`_meta/engine-modules.json` 2026-10-10 口径；公开侧 40 + `Private/` 2） |
| 分层 | 框架（物理底层） |
| 一句话职责 | 物理底层核心与 Chaos 集成：`FChaosScene`（Chaos 场景）、公共接口层（`FChaosEngineInterface`、场景查询 `SQAccelerator`/`SQVisitor`）、核心数据类（`UPhysicalMaterial`、`UBodySetupCore`、`FBodyInstanceCore`）与物理设置（`UPhysicsSettingsCore`） |

## 二、目录结构

```
PhysicsCore/
├── PhysicsCore.Build.cs          # 模块构建脚本（31 行；0 处 if 分支）
├── Public/                       # 公开侧（40 个 .h：顶层 33 + Chaos/ 5 + PhysicalMaterials/ 2）
│   ├── 顶层示例：PhysicsCore.h（日志）/ PhysicsCoreModule.h（模块接口）/ BodySetupCore.h /
│   │             BodyInstanceCore.h / CollisionShape.h / SQAccelerator.h / SQVisitor.h ...
│   ├── Chaos/                    # ChaosScene.h、ChaosEngineInterface.h、ChaosConstraintSettings.h、
│   │                             # ChaosPhysicalMaterial.h、ChaosUserEntity.h
│   └── PhysicalMaterials/        # PhysicalMaterial.h、PhysicalMaterialPropertyBase.h
└── Private/                      # 实现（22 个 .cpp + 2 个 .h，无子目录）
```

- 无 `Internal/`、无 `Tests/`；无聚合头（`PhysicsCore.h` 仅 8 行日志声明）。

## 三、依赖关系

### 3.1 无条件依赖

| 模块 | 类型 | Build.cs 行 | 说明 |
|---|---|---|---|
| `Core` | 私有依赖 | 11 | |
| `CoreUObject` | 私有依赖 | 12 | |
| `DeveloperSettings` | 公开依赖 | 18 | `UPhysicsSettingsCore` 的基类所在模块 |

> **辅助函数已展开**：第 22 行 `SetupModulePhysicsSupport(Target)`（UBT `ModuleRules.cs` 第 1793-1813 行）会追加——
> 公开包含路径 `Chaos`；公开依赖 `PhysicsCore`（**自引用**）、`ChaosCore`、`Chaos`、`NNE`；`WITH_CLOTH_COLLISION_DETECTION=1`；
> 并转调 `SetupModuleChaosVisualDebuggerSupport`（条件追加 `ChaosVDRuntime`）。
> **本模块的自引用清理**（第 25-27 行）：`PublicIncludePathModuleNames.Remove("PhysicsCore");`、
> `PublicDependencyModuleNames.Remove("PhysicsCore");`（源码注释：`SetupModulePhysicsSupport adds a dependency on PhysicsCore, but we are PhysicsCore!`）。
> 另：`PrivateDefinitions.Add("CHAOS_INCLUDE_LEVEL_1=1");`（第 29 行）。

### 3.2 平台与配置条件依赖

**无**——`PhysicsCore.Build.cs` 全文 **0 处 `if` 分支**（实测）。

### 3.3 第三方静态依赖

调用 **0 处**——无第三方静态依赖。

## 四、对外暴露面

> 公开侧共 40 个 `.h`；核心如下。

| 头文件 | 提供的能力 |
|---|---|
| `Engine/Source/Runtime/PhysicsCore/Public/PhysicalMaterials/PhysicalMaterial.h` | `UPhysicalMaterial`（第 103 行）→ `types/UPhysicalMaterial.md` |
| `Engine/Source/Runtime/PhysicsCore/Public/Chaos/ChaosScene.h` | `FChaosScene`（第 84 行，`#if WITH_ENGINE : public FGCObject`） |
| `Engine/Source/Runtime/PhysicsCore/Public/Chaos/ChaosEngineInterface.h`（33.3 KB） | `FChaosEngineInterface`（第 346 行） |
| `Engine/Source/Runtime/PhysicsCore/Public/Chaos/ChaosPhysicalMaterial.h` | `UChaosPhysicalMaterial`（第 22 行） |
| `Engine/Source/Runtime/PhysicsCore/Public/BodySetupCore.h` | `UBodySetupCore`（第 18 行） |
| `Engine/Source/Runtime/PhysicsCore/Public/BodyInstanceCore.h` | `FBodyInstanceCore`（第 15 行，`USTRUCT(BlueprintType)`） |
| `Engine/Source/Runtime/PhysicsCore/Public/PhysicsSettingsCore.h` | `UPhysicsSettingsCore`（第 19 行，`: public UDeveloperSettings`） |
| `Engine/Source/Runtime/PhysicsCore/Public/PhysicsInterfaceDeclaresCore.h` | 前向声明集中头：`FPhysScene_Chaos`（第 83 行）、`typedef FPhysScene_Chaos FPhysScene;`（第 90 行）、`typedef FPhysInterface_Chaos FPhysicsInterface;`（第 89 行） |
| `Engine/Source/Runtime/PhysicsCore/Public/SQAccelerator.h` / `SQVisitor.h` / `ChaosSQTypes.h` | 场景查询（SQ）体系 |
| `Engine/Source/Runtime/PhysicsCore/Public/PhysicsCoreModule.h` | 模块接口 `IPhysicsCoreModule`（第 11 行） |

## 五、模块生命周期

```
文件：Engine/Source/Runtime/PhysicsCore/Private/PhysicsCoreModule.cpp
行 6：IMPLEMENT_MODULE( IPhysicsCoreModule, PhysicsCore );
```

- **模块类就是空接口 `IPhysicsCoreModule : IModuleInterface`**（`Public/PhysicsCoreModule.h` 第 11 行，类体为空）——`StartupModule` / `ShutdownModule` / `SupportsDynamicReloading` **全部未覆写**（模块内 0 命中）。
- 另一空接口 `IPhysicsSQModule`（`Public/PhysicsSQ.h` 第 11 行）**未作为模块入口实例化**（模块内无对应 `IMPLEMENT_MODULE`）。
- 日志：`LogPhysicsCore`（`Private/PhysicsCore.cpp` 第 8 行，非模块启动路径）。

## 六、关键约定与坑

1. **`UPhysicalMaterialCore` 不存在**——实测全引擎 0 命中（另用 5.5/5.7 源码对照复核）；本模块的实际类是 **`UPhysicalMaterial`**（`Public/PhysicalMaterials/PhysicalMaterial.h` 第 103 行）。
2. **`FPhysScene_Chaos` 与 `FPhysInterface_Chaos` 的定义在 Engine 模块**（`Engine/Source/Runtime/Engine/Public/Physics/Experimental/PhysScene_Chaos.h` 第 116 行、`PhysInterface_Chaos.h` 第 34 行）；本模块只有前向声明与 typedef（`PhysicsInterfaceDeclaresCore.h` 第 83 / 89 / 90 行）。本模块自己的场景类是 **`FChaosScene`**（`Chaos/ChaosScene.h` 第 84 行）。
3. **自引用移除技巧**：`SetupModulePhysicsSupport` 会把自己（PhysicsCore）加入依赖，本模块随后 `Remove`（第 26-27 行）——而其他调用同一辅助函数的模块（如 `Engine`、`NavigationSystem`）**不会**移除，依赖表差异属预期行为。
4. **`Public/Chaos/PhysicsObject.h` 不在本模块**（在 Chaos 模块：`Engine/Source/Runtime/Experimental/Chaos/Public/Chaos/PhysicsObject.h`）。
5. **数字口径**：`PhysicsCore.Build.cs` 31 行（`ReadAllLines`）、0 处 `if`、0 处三方静态调用；公开侧 40 个 `.h`。取数命令见「取数说明」。

## 取数说明

以下命令的相对基准为 `Engine/Source`（实际路径按 `_meta/convention.md` 的本机环境块解析）：

| 断言 | 取数方式 |
|---|---|
| 65 文件 / 42 头文件 | `[M]` 引擎磁盘递归计数：`(Get-ChildItem "Runtime/PhysicsCore" -Recurse -File).Count` 得文件数；`(Get-ChildItem "Runtime/PhysicsCore" -Recurse -File -Filter *.h).Count` 得头文件数（同 `_meta/engine-modules.json` 口径） |
| 公开侧 40 个 `.h` | `[M]` `(Get-ChildItem "Runtime/PhysicsCore/Public" -Recurse -File -Filter *.h).Count` |
| Build.cs 31 行、0 处 `if`、0 处三方静态调用 | `[M]` `[System.IO.File]::ReadAllLines("Runtime/PhysicsCore/PhysicsCore.Build.cs").Count`；`Select-String "Runtime/PhysicsCore/PhysicsCore.Build.cs" -Pattern '\bif\s*\(' -AllMatches`；`Select-String "Runtime/PhysicsCore/PhysicsCore.Build.cs" -Pattern 'AddEngineThirdPartyPrivateStaticDependencies' -AllMatches` |
| `SetupModulePhysicsSupport` 展开与自引用清理 | UBT `ModuleRules.cs` 第 1793-1813 行；`PhysicsCore.Build.cs` 第 25-27 行 |
| 全部行号引用 | 2026-10-10 对 UE 5.8.3 源码本机逐条核对 |

## 相关文档

- `types/UPhysicalMaterial.md` —— 本模块核心类型（同批产出）
- `types/UDeveloperSettings.md` —— `UPhysicsSettingsCore` 的基类（批 5 产出）
- `modules/Engine-结构.md` —— `FPhysScene_Chaos` / `FPhysInterface_Chaos` 的定义模块
- `modules/NavigationSystem-结构.md` —— 同样调用 `SetupModulePhysicsSupport` 的模块（同批产出）

## 更新记录

- 2026-10-11 按规范 4.2.1 为「取数说明」各行加方法标记（`[M]`/`[R]`/`[H]`）；`[M]` 行把原文省略成 `(...)` 的路径补全为白名单可执行命令，现由 `ue-doc-verify` 逐条实际执行比对
