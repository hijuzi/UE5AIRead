> 引擎版本：UE 5.8.3 (Build 58210709)
> 源码根：Engine/Source
> 生成技能：ue-module-structure v1.0
> 生成时间：2026-10-10
> 校验状态：已校验（2026-10-10）

# Renderer 模块结构

## 一、模块定位

| 项 | 值 |
|---|---|
| 路径 | `Engine/Source/Runtime/Renderer` |
| 类别 | Runtime |
| 规模 | 781 文件 / 388 头文件（`_meta/engine-modules.json` 2026-10-10 口径）；公开侧 48 个 `.h`（顶层 42 + 子目录 6） |
| 分层 | 渲染 |
| 一句话职责 | 场景渲染的实现层：`FScene`（`FSceneInterface` 的渲染器实现）与 `FSceneRenderer`、网格绘制通道（`FMeshPassProcessor`）、Lumen / Nanite / 阴影 / 后处理等渲染特性——工作在 RenderCore/RHI 之上 |

## 二、目录结构

```
Renderer/
├── Renderer.Build.cs             # 模块构建脚本（62 行、1 处 if 分支）
├── Public/                       # 公开侧（42 个顶层 .h；子目录 InstanceCulling/、PostProcess/、VT/ 含 6 个 .h；共 48 个 .h）
├── Private/                      # 实现（24 个子目录；顶层约 285 条目；含 Tests/）
└── Internal/                     # 内部共享（7 个 .h + MaterialCache/、PostProcess/、VT/）
```

- 无模块级聚合头（实测 0 命中；`MeshPassProcessor.h` 等均为具体头而非转发）。
- `Tests/` 位于 `Private/Tests/`（`RayTracingTestbed.cpp`、`VirtualTextureTestbed.cpp`），本版标注不展开。

## 三、依赖关系

### 3.1 无条件依赖

| 模块 | 类型 | Build.cs 行 | 说明 |
|---|---|---|---|
| `Core` | 公开依赖 | 19 | |
| `Engine` | 公开依赖 | 20 | |
| `CoreUObject` | 私有依赖 | 44 | |
| `ApplicationCore` | 私有依赖 | 45 | |
| `RenderCore` | 私有依赖 | 46 | |
| `ImageWriteQueue` | 私有依赖 | 47 | |
| `RHI` | 私有依赖 | 48 | |
| `MaterialShaderQualitySettings` | 私有依赖 | 49 | |
| `StateStream` | 私有依赖 | 50 | |
| `TraceLog` | 私有依赖 | 51 | |
| `Shaders` | 私有包含路径 | 15 | 着色器源码模块（本版不产出该模块文档） |
| `HeadMountedDisplay` | 私有包含路径 + 动态加载 | 55 / 56 | 双列表同时登记 |
| `EyeTracker` | 私有包含路径 + 动态加载 | 57 / 58 | 双列表同时登记 |

> 另有无条件项：`PrivateIncludePaths`（第 9-13 行，含第 11 行 `EngineDirectory + "/Shaders/Private"`，注释 `For HaltonUtilities.ush`）；
> `RuntimeDependencies`（第 60 行：`$(EngineDir)/Content/Renderer/TessellationTable.bin`）。
> 辅助函数检查：**无**自定义辅助函数/属性，无 UBT 辅助函数调用——**无未展开依赖**。

### 3.2 平台与配置条件依赖

> 全文 **仅 1 处 `if` 分支**（第 24 行）。

| 依赖 | 类型 | 生效条件 | Build.cs 行 |
|---|---|---|---|
| `TargetPlatform`、`GeometryCore`、`NaniteUtilities` | 私有依赖 | `Target.bBuildEditor == true` | 24-33 |

### 3.3 第三方静态依赖

`AddEngineThirdPartyPrivateStaticDependencies` 调用 **0 处**——无第三方静态依赖。

## 四、对外暴露面

> 公开侧共 48 个 `.h`（顶层 42 + 子目录 6）；下表为核心契约。

| 头文件 | 提供的能力 |
|---|---|
| `Engine/Source/Runtime/Renderer/Public/MeshPassProcessor.h`（89.85 KB） | `FMeshPassProcessor`（第 2258 行，`: public IPSOCollector`）——网格绘制通道处理器 |
| `Engine/Source/Runtime/Renderer/Public/SceneRendererInterface.h` | `ISceneRenderer`（第 51 行）——场景渲染器接口（新一代渲染架构） |
| `Engine/Source/Runtime/Renderer/Public/ScreenPass.h`（28.42 KB） | 屏幕通道框架（全屏 Pass） |
| `Engine/Source/Runtime/Renderer/Public/SystemTextures.h` | 系统纹理（`FSystemTextures`） |
| `Engine/Source/Runtime/Renderer/Public/PrimitiveSceneInfo.h` | `FPrimitiveSceneInfo` 场景图元信息 |
| `Engine/Source/Runtime/Renderer/Public/SceneUniformBuffer.h` | 场景 UniformBuffer |
| `Engine/Source/Runtime/Renderer/Public/TemporalUpscaler.h` | 时域超分接口 |
| `Engine/Source/Runtime/Renderer/Public/VolumeRendering.h` | 体积渲染 |
| `Engine/Source/Runtime/Renderer/Public/HairStrandsInterface.h`（25.2 KB） | 头发渲染接口（**顶层**文件，无 `HairStrands/` 子目录） |
| `Engine/Source/Runtime/Renderer/Public/ComputeSystemInterface.h` | 计算调度接口 |
| `Engine/Source/Runtime/Renderer/Public/GPUSceneWriter.h` | GPU 场景写入器 |
| `Engine/Source/Runtime/Renderer/Public/GlobalDistanceFieldParameters.h` | 全局距离场参数 |
| `Engine/Source/Runtime/Renderer/Public/VariableRateShadingImageManager.h` | 可变速率着色图像管理 |
| `Engine/Source/Runtime/Renderer/Public/RayTracingInstance.h` | 光追实例描述 |

> `PostProcess/` 公开子目录只有 3 个头：`DrawRectangle.h`、`PostProcessHMD.h`、`PostProcessMaterialInputs.h`（实测）。

## 五、模块生命周期

```
文件：Engine/Source/Runtime/Renderer/Private/Renderer.cpp
行 68：IMPLEMENT_MODULE(FRendererModule, Renderer);

文件：Engine/Source/Runtime/Renderer/Private/RendererModule.h
行 31：class FRendererModule final : public IRendererModule
行 35：virtual bool SupportsDynamicReloading() override { return true; }
```

- **模块类**：`FRendererModule final : IRendererModule`（第 31 行）；基类 `IRendererModule : IModuleInterface` 定义在 **RenderCore**（`Engine/Source/Runtime/RenderCore/Public/RendererInterface.h` 第 220 行）。
- **`SupportsDynamicReloading` 显式覆写为 `true`**（第 35 行）——本套件已产出文档的模块中**首个显式覆写者**（其余模块均未覆写）。
- **`StartupModule()`**（`Renderer.cpp` 第 135-198 行）要点：
  1. `MESH_DRAW_COMMAND_STATS` 下创建 `FMeshDrawCommandStatsManager`（第 137-139 行）
  2. `GScreenSpaceDenoiser = IScreenSpaceDenoiser::GetDefaultDenoiser();`（第 141 行）
  3. 初始化 4 个全局设施：`FRendererOnScreenNotification::Get(); FVirtualTextureSystem::Initialize(); FMaterialCacheTagProvider::Initialize(); FMaterialCacheVirtualTextureAllocator::Initialize();`（第 143-146 行）
  4. `RHI_RAYTRACING` 下创建 `FRayTracingGeometryManager`（第 149 行）、`Nanite::GRayTracingManager.Initialize();`（第 151 行）
  5. 注册 `StopRenderingThreadDelegate`（第 154-162 行；回调等待 RDG 与 SceneRenderBuilder 的异步删除任务）
  6. 初始化 3 个全局 UniformBuffer（第 164-167 行）
  7. 注册 `FCoreDelegates::GetOnPostEngineInit()`（第 169-190 行：PathTracing RTPO、MeshEdges / SkinnedMeshDebug / VisualizeColorGrading 视图扩展）
  8. `WITH_STATE_STREAM` 下创建 `FRendererStateStreamManager` 并注册 StateStream（第 192-197 行）
- **`ShutdownModule()`**（第 200 行起）：逆序拆除（默认 denoiser / Lumen / VisualizeLightShape 等，第 218-230 行）。

## 六、关键约定与坑

1. **`FSceneInterface` 不在本模块**——定义在 **Engine**（`Engine/Source/Runtime/Engine/Public/SceneInterface.h` 第 119 行）；本模块的 `FScene`（`Private/ScenePrivate.h` 第 1624 行，`: public FSceneInterface`）是其实现。`FSceneView`（`Engine/Source/Runtime/Engine/Public/SceneView.h` 第 1481 行）与 `FPrimitiveSceneProxy`（`Engine/Source/Runtime/Engine/Public/PrimitiveSceneProxy.h` 第 291 行）也都在 **Engine**。
2. **`FSceneRenderer` 在 Private**：`Private/SceneRendering.h` 第 2218 行（`: public FSceneRendererBase`）；`FSceneRendererBase : ISceneRenderer`（同文件第 2153 行）；公开接口是 `Public/SceneRendererInterface.h` 第 51 行的 `ISceneRenderer`。按 `Public/SceneRendering.h` 猜路径会落空。
3. **`GPUScene.h` / `GlobalDistanceField.h` / `RayTracing/RayTracingScene.h` 都在 Private**；`HairStrandsInterface.h` 在 Public **顶层**。
4. **数字口径**：`Renderer.Build.cs` 62 行（`ReadAllLines`）、1 处 `if`、0 处三方静态调用；Public 顶层 42 个 `.h`、递归 48 个；Private 子目录 24 个。取数命令见「取数说明」。

## 取数说明

以下命令的相对基准为 `Engine/Source`（实际路径按 `_meta/convention.md` 的本机环境块解析）：

| 断言 | 取数方式 |
|---|---|
| 781 文件 / 388 头文件 | `_meta/engine-modules.json` 中 `Module -eq 'Renderer'` 行的 `Files`、`Headers` 字段 |
| 公开侧 48 个 `.h`（顶层 42） | `(Get-ChildItem "Runtime/Renderer/Public" -Recurse -File -Filter *.h).Count` 与顶层计数 |
| Build.cs 62 行、1 处 `if`、0 处三方静态调用 | `[System.IO.File]::ReadAllLines(...).Count`；`\bif\s*\(` 与 `AddEngineThirdPartyPrivateStaticDependencies` 全匹配计数 |
| 全部行号引用 | 2026-10-10 对 UE 5.8.3 源码本机逐条核对 |

## 相关文档

- `types/FSceneInterface.md` —— 本模块实现（`FScene`）的场景接口（同批产出）
- `modules/RenderCore-结构.md` —— 下层渲染公共层（`IRendererModule` 接口在这里）
- `modules/RHI-结构.md` —— 底层硬件接口抽象
- `modules/Engine-结构.md` —— 场景/图元代理的宿主模块
- `types/FRenderResource.md` —— 渲染资源生命周期基类
