> 引擎版本：UE 5.8.3 (Build 58210709)
> 源码根：Engine/Source
> 生成技能：ue-module-structure v1.0
> 生成时间：2026-10-10
> 校验状态：已校验（2026-10-11）

# Chaos 模块结构

## 一、模块定位

| 项 | 值 |
|---|---|
| 路径 | `Engine/Source/Runtime/Experimental/Chaos`（**模块名 `Chaos`**；注意位于 `Experimental/` 下） |
| 类别 | Runtime |
| 规模 | 847 文件 / 512 头文件（`_meta/engine-modules.json` 2026-10-10 口径）；公开侧 495 个 `.h`（顶层 17） |
| 分层 | 物理 |
| 一句话职责 | Chaos 物理求解器核心：隐式几何（`FImplicitObject` 体系）、PBD 粒子/刚体求解（`FPBDRigidsSolver` / `FPBDRigidsEvolution`）、求解器基座（`FPhysicsSolverBase`）、场（Field/）与几何集合（GeometryCollection/） |

## 二、目录结构

```
Experimental/Chaos/
├── Chaos.Build.cs                # 模块构建脚本（58 行、1 处 if 分支）
├── Public/                       # 公开侧（495 个 .h：顶层 17 + 8 个子目录）
│   ├── 顶层：ChaosModule.h / ChaosSolversModule.h / PBDRigidsSolver.h / PhysicsSolver.h / ChaosStats.h …
│   └── 子目录（8）：Chaos/ ChaosDebugDraw/ ChaosInsights/ ChaosVisualDebugger/ Field/ Framework/ GeometryCollection/ PhysicsProxy/
└── Private/                      # 实现（9 个子目录 + 16 个顶层文件；含 Tests/）
```

- 转发头：`Public/PhysicsSolver.h`（5 行，转发 `Declares.h` + `PBDRigidsSolver.h`）；**无 `Chaos.h` 总头**（0 命中）。
- `Tests/` 位于 `Private/Tests/`，本版标注不展开。

## 三、依赖关系

### 3.1 无条件依赖

| 模块 | 类型 | Build.cs 行 | 说明 |
|---|---|---|---|
| `AutoRTFM` | 公开依赖 | 16 | |
| `Core` | 公开依赖 | 17 | |
| `CoreUObject` | 公开依赖 | 18 | |
| `ChaosCore` | 公开依赖 | 19 | |
| `IntelISPC` | 公开依赖 | 20 | ISPC 向量化 |
| `TraceLog` | 公开依赖 | 21 | |
| `Voronoi` | 公开依赖 | 22 | |
| `GeometryCore` | 公开依赖 | 23 | 启动时按需加载（见第五节） |
| `ChaosVDRuntime` | 公开依赖 | 24 | |
| `TraceBasedDebuggers` | 公开依赖 | 25 | |
| `NNE` | 公开依赖 | 26 | |
| `Eigen` | 私有依赖 | 31 | |
| `MeshDescription` | 私有依赖 | 32 | |
| `PhysicsCore` | 私有包含路径 | 39 | 注释：`Needed because we include "ChaosEngineInterface.h"` |

> 定义：`COMPILE_WITHOUT_UNREAL_SUPPORT=0`（第 36 行）、`CHAOS_INCLUDE_LEVEL_1=1`（第 37 行）；
> `NumIncludedBytesPerUnityCPPOverride = 192 * 1024`（第 12 行，注释"半默认 unity 尺寸"）。
> **辅助函数已展开**：第 50 行 `SetupModuleChaosVisualDebuggerSupport(Target)`（UBT `ModuleRules.cs` 第 1775-1788 行）——
> 条件追加 `ChaosVDRuntime` 依赖与 `WITH_CHAOS_VISUAL_DEBUGGER` 宏（0/1）。

### 3.2 平台与配置条件依赖

> 全文 **1 处 `if` 分支**（第 41 行）。

| 项 | 类型 | 生效条件 | Build.cs 行 |
|---|---|---|---|
| `CHAOS_MEMORY_TRACKING=1` / `=0` | 编译定义（**非模块依赖**） | `Target.bUseChaosMemoryTracking == true` / else | 41-48 |

### 3.3 第三方静态依赖

调用 **0 处**——无第三方静态依赖（`Eigen` 为模块依赖，第 31 行）。
另：警告等级第 52 行；`StaticAnalyzerDisabledCheckers` 两项（第 54-55 行）。

## 四、对外暴露面

> 公开侧共 495 个 `.h`；核心如下。

| 头文件 | 提供的能力 |
|---|---|
| `Engine/Source/Runtime/Experimental/Chaos/Public/Chaos/ImplicitObject.h`（25.18 KB） | `FImplicitObject`（第 110 行）→ `types/FImplicitObject.md` |
| `Engine/Source/Runtime/Experimental/Chaos/Public/Chaos/ParticleHandle.h`（150.77 KB） | 粒子/几何粒子句柄体系 |
| `Engine/Source/Runtime/Experimental/Chaos/Public/Chaos/PBDRigidsEvolution.h`（41.2 KB） | `FPBDRigidsEvolutionBase`（第 274 行） |
| `Engine/Source/Runtime/Experimental/Chaos/Public/PBDRigidsSolver.h`（22.08 KB，**顶层**） | `FPBDRigidsSolver`（第 87 行，`: FPhysicsSolverBase`） |
| `Engine/Source/Runtime/Experimental/Chaos/Public/Chaos/Declares.h` | 别名集中头（`typedef FPBDRigidsSolver FPhysicsSolver;` 第 10 行） |
| `Engine/Source/Runtime/Experimental/Chaos/Public/Chaos/Framework/PhysicsSolverBase.h` | 求解器基座 |
| `Engine/Source/Runtime/Experimental/Chaos/Public/Chaos/ImplicitObjectUnion.h` | `FImplicitObjectUnion`（第 26 行） |
| `Engine/Source/Runtime/Experimental/Chaos/Public/Chaos/ImplicitObjectScaled.h` 等 | 几何子类族（20 个文件） |
| `Engine/Source/Runtime/Experimental/Chaos/Public/ChaosModule.h` | 模块类 `FChaosEngineModule`（第 7 行） |

## 五、模块生命周期

```
文件：Engine/Source/Runtime/Experimental/Chaos/Public/ChaosModule.h
行 7：class FChaosEngineModule : public IModuleInterface（StartupModule 第 11 行 / ShutdownModule 第 12 行，均 CHAOS_API）
文件：Engine/Source/Runtime/Experimental/Chaos/Private/ChaosModule.cpp
行 10：IMPLEMENT_MODULE(FChaosEngineModule, Chaos);
```

- **`StartupModule()`**（第 19-35 行）：
  1. 模块存在则加载 GeometryCore（第 21-24 行）
  2. 命令行 `SingleThreadedPhysics` → 置 `GSingleThreadedPhysics = 1` / `bSingleWorkerPhysics = true`（第 26-30 行）
  3. `#if CHAOS_VISUAL_DEBUGGER_ENABLED` 注册 CVD 事件处理（第 32-34 行）
- **`ShutdownModule()`**：反注册（第 37-42 行附近）。
- **`SupportsDynamicReloading`**：未覆写（0 命中）。

## 六、关键约定与坑

1. **路径含 `Experimental/`**：`Engine/Source/Runtime/Experimental/Chaos`；与 `PhysicsCore` 分工：Chaos=求解器核心，PhysicsCore=引擎物理接口层。
2. **类名别名陷阱**（字面搜类名会落空）：
   - `FPBDRigidsEvolution` 是 `using` 别名（`Chaos/PBDRigidsEvolutionFwd.h` 第 11 行 → `FPBDRigidsEvolutionGBF`）
   - `FPhysicsSolver` 是 `typedef`（`Chaos/Declares.h` 第 10 行 → `FPBDRigidsSolver`）
   - `FGeometryParticleHandle` 是别名（`Chaos/ParticleHandleFwd.h` 第 24 行）
3. **`PBDRigidsSolver.h` 在 `Public/` 顶层**（不在 `Chaos/` 子目录）——`Public/Chaos/PBDRigidsSolver.h` 实测不存在。
4. **数字口径**：`Chaos.Build.cs` 58 行（`ReadAllLines`）、1 处 `if`（仅编译定义）、0 处三方静态调用；公开侧 495 个 `.h`（顶层 17）。取数命令见「取数说明」。

## 取数说明

以下命令的相对基准为 `Engine/Source`（实际路径按 `_meta/convention.md` 的本机环境块解析）：

| 断言 | 取数方式 |
|---|---|
| 847 文件 / 512 头文件 | `[M]` 引擎磁盘递归计数：`(Get-ChildItem "Runtime/Experimental/Chaos" -Recurse -File).Count` 得文件数；`(Get-ChildItem "Runtime/Experimental/Chaos" -Recurse -File -Filter *.h).Count` 得头文件数（同 `_meta/engine-modules.json` 口径） |
| 公开侧 495 个 `.h`（顶层 17） | `[M]` `(Get-ChildItem "Runtime/Experimental/Chaos/Public" -Recurse -File -Filter *.h).Count` 与顶层计数 |
| Build.cs 58 行、1 处 `if`、0 处三方静态调用 | `[M]` `[System.IO.File]::ReadAllLines("Runtime/Experimental/Chaos/Chaos.Build.cs").Count`；`Select-String "Runtime/Experimental/Chaos/Chaos.Build.cs" -Pattern '\bif\s*\(' -AllMatches`；`Select-String "Runtime/Experimental/Chaos/Chaos.Build.cs" -Pattern 'AddEngineThirdPartyPrivateStaticDependencies' -AllMatches` |
| `SetupModuleChaosVisualDebuggerSupport` 展开 | UBT `ModuleRules.cs` 第 1775-1788 行 |
| 全部行号引用 | 2026-10-10 对 UE 5.8.3 源码本机逐条核对 |

## 相关文档

- `types/FImplicitObject.md` —— 本模块代表类型（同批产出）
- `modules/PhysicsCore-结构.md` —— 引擎物理接口层（批 7）
- `modules/Navmesh-结构.md` —— 同批模块
- `modules/Core-结构.md` —— `FDefaultModuleImpl` 等模块设施所在

## 更新记录

- 2026-10-11 按规范 4.2.1 为「取数说明」各行加方法标记（`[M]`/`[R]`/`[H]`）；`[M]` 行把原文省略成 `(...)` 的路径补全为白名单可执行命令，现由 `ue-doc-verify` 逐条实际执行比对
