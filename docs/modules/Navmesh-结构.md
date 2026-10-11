> 引擎版本：UE 5.8.3 (Build 58210709)
> 源码根：Engine/Source
> 生成技能：ue-module-structure v1.0
> 生成时间：2026-10-10
> 校验状态：已校验（2026-10-11）

# Navmesh 模块结构

## 一、模块定位

| 项 | 值 |
|---|---|
| 路径 | `Engine/Source/Runtime/Navmesh` |
| 类别 | Runtime |
| 规模 | 79 文件 / 30 头文件（`_meta/engine-modules.json` 2026-10-10 口径；公开侧 30，全部在子目录、顶层 0） |
| 分层 | 框架（导航实现层） |
| 一句话职责 | Recast/Detour 实现层：Recast 体素化与网格生成（Recast/）、Detour 导航网格查询（Detour/）、人群避障（DetourCrowd/）、瓦片缓存（DetourTileCache/）与调试绘制（DebugUtils/）——由 `NavigationSystem` 模块消费 |

## 二、目录结构

```
Navmesh/
├── Navmesh.Build.cs              # 模块构建脚本（31 行、2 处 if 分支）
├── Recast.tps / Recast-License.txt / Recast-Readme.txt
│                                 # 第三方登记：Recast v1.4.2（Location: Private/Recast/）
├── RecastDemo/                   # 发行附带目录（Bin/、Source.zip；不参与模块编译）
├── Public/                       # 公开侧 30 个 .h（顶层 0；全部在 5 个子目录）
│   ├── Recast/（4）Detour/（11）DetourCrowd/（7）DetourTileCache/（2）DebugUtils/（6）
└── Private/                      # 实现（5 个子目录 + NavmeshModule.cpp；递归 .cpp 35）
```

## 三、依赖关系

### 3.1 无条件依赖

| 模块 | 类型 | Build.cs 行 | 说明 |
|---|---|---|---|
| `Core` | 私有依赖 | 9 | **唯一依赖**（`PrivateDependencyModuleNames.AddRange(new string[] { "Core" })`） |

> 无公开依赖列表；辅助函数检查：**无**——无未展开依赖。

### 3.2 平台与配置条件依赖

> 全文 **2 处 `if` 分支**（第 12、21 行）——均为**编译定义**，不涉及模块依赖。

| 项 | 类型 | 生效条件 | Build.cs 行 |
|---|---|---|---|
| `WITH_NAVMESH_SEGMENT_LINKS=1` / `=0` | 编译定义 | `Target.bCompileNavmeshSegmentLinks` | 12-19 |
| `WITH_NAVMESH_CLUSTER_LINKS=1` / `=0` | 编译定义 | `Target.bCompileNavmeshClusterLinks` | 21-28 |

### 3.3 第三方静态依赖

Build.cs 内调用 **0 处**；Recast 以 `.tps` 登记方式引入（`Recast v1.4.2`，位置 `Private/Recast/`）——**不经静态库链接**。

## 四、对外暴露面

> 公开侧共 30 个 `.h`；核心如下。

| 头文件 | 提供的能力 |
|---|---|
| `Engine/Source/Runtime/Navmesh/Public/Detour/DetourNavMesh.h`（46.75 KB） | `dtNavMesh`（第 549 行，约 497 行的核心类） |
| `Engine/Source/Runtime/Navmesh/Public/Detour/DetourNavMeshQuery.h` | `dtNavMeshQuery`（第 348 行）/ `dtQueryFilter`（第 95 行） |
| `Engine/Source/Runtime/Navmesh/Public/DetourCrowd/DetourCrowd.h` | `dtCrowd`（第 235 行） |
| `Engine/Source/Runtime/Navmesh/Public/Recast/Recast.h`（72.05 KB） | `rcContext`（第 164 行）/ `rcConfig`（第 259 行）等生成管线 |
| `Engine/Source/Runtime/Navmesh/Public/DetourTileCache/DetourTileCache.h` | `dtTileCache`（第 115 行） |
| `Engine/Source/Runtime/Navmesh/Public/DebugUtils/`（6 个头） | Recast/Detour 调试绘制 |

> 消费方证据：`NavigationSystem/Public/NavMesh/RecastNavMeshGenerator.h` 第 22 行 include `Detour/DetourNavMesh.h`；`AIModule/Private/Navigation/CrowdManager.cpp` 第 19 行同样引用。
> **`ARecastNavMesh` / `FRecastNavMeshGenerator` 不在本模块**（在 `NavigationSystem`；类型文档见 `types/ARecastNavMesh.md`）。

## 五、模块生命周期

```
文件：Engine/Source/Runtime/Navmesh/Private/NavmeshModule.cpp （全文 5 行）
行 5：IMPLEMENT_MODULE(FDefaultModuleImpl, Navmesh);
```

- **无自定义模块类**——直接复用 `FDefaultModuleImpl`（Core 提供）；无 `StartupModule` / `ShutdownModule` 覆写（模块内 0 命中）。
- 编译开关经 UBT 传入本模块宏（`WITH_NAVMESH_SEGMENT_LINKS` / `WITH_NAVMESH_CLUSTER_LINKS`，供 `NavigationSystem` 等消费方读取）。

## 六、关键约定与坑

1. **`Public/` 顶层无 `.h`**（30 个全在 5 个子目录）；`Public/RecastNavMesh.h`、`Public/NavmeshModule.h` 均**不存在**（实测 False）。
2. **无自定义模块类**：`IMPLEMENT_MODULE(FDefaultModuleImpl, ...)` 直接复用 Core 的默认实现——本套件遇到的第一个此类模块。
3. **Recast 是源码内嵌**（`.tps` 登记 + `Private/Recast/`），不是第三方静态库；`RecastDemo/` 是发行附带目录，不参与编译。
4. **数字口径**：`Navmesh.Build.cs` 31 行（`ReadAllLines`）、2 处 `if`（仅编译定义）、0 处三方静态调用；公开侧 30 个 `.h`（顶层 0）。取数命令见「取数说明」。

## 取数说明

以下命令的相对基准为 `Engine/Source`（实际路径按 `_meta/convention.md` 的本机环境块解析）：

| 断言 | 取数方式 |
|---|---|
| 79 文件 / 30 头文件 | `[M]` 引擎磁盘递归计数：`(Get-ChildItem "Runtime/Navmesh" -Recurse -File).Count` 得文件数；`(Get-ChildItem "Runtime/Navmesh" -Recurse -File -Filter *.h).Count` 得头文件数（同 `_meta/engine-modules.json` 口径） |
| 公开侧 30 个 `.h`（顶层 0） | `[M]` `(Get-ChildItem "Runtime/Navmesh/Public" -Recurse -File -Filter *.h).Count` 与顶层计数 |
| Build.cs 31 行、2 处 `if`、0 处三方静态调用 | `[M]` `[System.IO.File]::ReadAllLines("Runtime/Navmesh/Navmesh.Build.cs").Count`；`Select-String "Runtime/Navmesh/Navmesh.Build.cs" -Pattern '\bif\s*\(' -AllMatches`；`Select-String "Runtime/Navmesh/Navmesh.Build.cs" -Pattern 'AddEngineThirdPartyPrivateStaticDependencies' -AllMatches` |
| 全部行号引用 | 2026-10-10 对 UE 5.8.3 源码本机逐条核对 |

## 相关文档

- `types/ARecastNavMesh.md` —— 导航数据 Actor（归属 NavigationSystem，随本批产出）
- `modules/NavigationSystem-结构.md` —— 消费者模块（批 8）
- `modules/Chaos-结构.md` —— 同批模块
- `modules/AIModule-结构.md` —— `dtCrowd` 的另一消费方（批 8）

## 更新记录

- 2026-10-11 按规范 4.2.1 为「取数说明」各行加方法标记（`[M]`/`[R]`/`[H]`）；`[M]` 行把原文省略成 `(...)` 的路径补全为白名单可执行命令，现由 `ue-doc-verify` 逐条实际执行比对
