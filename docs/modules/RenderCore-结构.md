> 引擎版本：UE 5.8.3 (Build 58210709)
> 源码根：Engine/Source
> 生成技能：ue-module-structure v1.0
> 生成时间：2026-10-10
> 校验状态：已校验（2026-10-11）

# RenderCore 模块结构

## 一、模块定位

| 项 | 值 |
|---|---|
| 路径 | `Engine/Source/Runtime/RenderCore` |
| 类别 | Runtime |
| 规模 | 212 文件 / 121 头文件（`_meta/engine-modules.json` 2026-10-10 口径）；公开侧 105 个 `.h`（递归：顶层 103 + 子目录 2） |
| 分层 | 渲染 |
| 一句话职责 | RHI 之上的渲染公共层：`FRenderResource` 资源生命周期、`FShader` / `FGlobalShader` 与着色器参数宏、**RDG（Render Dependency Graph）**、渲染目标池、着色器编译与库 |

## 二、目录结构

```
RenderCore/
├── RenderCore.Build.cs           # 模块构建脚本（72 行、6 处 if 分支）
├── RenderCore.natvis
├── Public/                       # 公开侧（103 个顶层 .h + 5 个 .inl；子目录 Animation/、ProfilingDebugging/；合计 105 个 .h）
├── Private/                      # 实现（2 个子目录 + 3 个 .h：RenderGraphPrivate.h、RenderGraphResourcePool.h 等）
└── Internal/                     # 内部共享（7 项：ShaderCompilerDefinitions.h、ShaderLibrary/ 等）
```

- 无 `Tests/`。

## 三、依赖关系

### 3.1 无条件依赖

| 模块 | 类型 | Build.cs 行 | 说明 |
|---|---|---|---|
| `RHI` | 公开依赖 | 12 | 同时出现在公开包含路径（第 48 行） |
| `CoreUObject` | 公开依赖 | 12 | |
| `Shaders` | 私有包含路径 | 14 | 仅包含路径 |
| `TargetPlatform` | 私有包含路径 | 14 | 编辑器分支还会动态加载它（见 3.2） |
| `Json` | 私有依赖 | 17 | 注释：着色器库资产信息与帧转储 |
| `BuildSettings` | 私有依赖 | 19 | |
| `Core` | 私有依赖 | 41 | |
| `Projects` | 私有依赖 | 42 | |
| `ApplicationCore` | 私有依赖 | 43 | |
| `TraceLog` | 私有依赖 | 44 | |
| `StateStream` | 私有依赖 | 45 | |
| `RHI` | 公开包含路径 | 48 | 与第 12 行重复出现，勿去重 |

> 辅助函数检查：**无**自定义辅助函数/属性，无 UBT 辅助函数调用——**无未展开依赖**。

### 3.2 平台与配置条件依赖

> 全文 **6 处 `if` 分支**（第 21、28、34、50、59、67 行）。

| 依赖 / 项 | 类型 | 生效条件 | Build.cs 行 |
|---|---|---|---|
| `TargetPlatform`（动态加载）+ `IoStoreUtilities`（私有包含路径） | 混合 | `bBuildEditor == true` | 21-25 |
| `ImageWrapper` | 私有依赖 | `else if`：非 Program 且（Development 或 DebugGame）且 Desktop 平台 | 28-31 |
| GPUDumpViewer 源码（`RuntimeDependencies`） | 运行时依赖 | 非 Shipping（注释：供 `r.DumpGPU` 命令） | 34-37 |
| `DerivedDataCache` | 私有依赖（编辑器）/ 私有包含路径（else 分支，第 56 行） | `bBuildEditor` 与否二选一 | 50-57 |
| `OpenGLDrv` | 公开包含路径 | Windows / Android / Linux 平台组（注释：`For IOpenGLDynamicRHI::RHIGenerateMips`） | 59-65 |
| `ALLOW_SHADERMAP_TRACKING=1`（私有定义） | 编译定义 | 非 Shipping | 67-70 |

### 3.3 第三方静态依赖

`AddEngineThirdPartyPrivateStaticDependencies` 调用 **0 处**——本模块无第三方静态依赖。

## 四、对外暴露面

> 公开侧共 105 个 `.h`；核心头如下（均为实测存在）。

| 头文件 | 提供的能力 |
|---|---|
| `Public/RenderResource.h`（15.98 KB） | `FRenderResource`（第 36 行）→ `types/FRenderResource.md` |
| `Public/RenderGraphBuilder.h`（53.2 KB） | `FRDGBuilder`（第 50 行）——RDG 构建器 |
| `Public/RenderGraphResources.h`（44.15 KB） | `FRDGResource`（第 134 行）等 RDG 资源 |
| `Public/RenderGraphUtils.h`（60.74 KB） | RDG 工具集 |
| `Public/Shader.h`（109.51 KB） | `FShader`（第 816 行） |
| `Public/GlobalShader.h`（18.37 KB） | `FGlobalShader`（第 282 行，`: public FShader`） |
| `Public/ShaderParameterStruct.h` | 参数结构（`SHADER_PARAMETER_STRUCT` 家族） |
| `Public/ShaderParameterMacros.h`（75.31 KB） | 着色器参数宏 |
| `Public/RenderTargetPool.h` | `FRenderTargetPool`（第 98 行，`: public FRenderResource`） |
| `Public/RHIStaticStates.h`（15.3 KB） | RHI 静态状态——**注意：在本模块，不在 RHI** |
| `Public/VertexFactory.h` | `FVertexFactory`（第 655 行） |
| `Public/UniformBuffer.h` | `TUniformBuffer`（第 28 行） |
| `Public/CommonRenderResources.h` | 公共渲染资源 |
| `Public/ClearQuad.h` | 清屏四边形 |
| `Public/RenderUtils.h`（31.29 KB） | 渲染工具 |
| `Public/ShaderCore.h`（61.86 KB） | 着色器核心 |

## 五、模块生命周期

```
文件：Engine/Source/Runtime/RenderCore/Private/RenderCore.cpp
行 27：class FRenderCoreModule : public FDefaultModuleImpl

文件：Engine/Source/Runtime/RenderCore/Private/RenderCore.cpp
行 46：IMPLEMENT_MODULE(FRenderCoreModule, RenderCore);
```

- **模块类**：`FRenderCoreModule : FDefaultModuleImpl`（第 27 行）
- **`StartupModule()`**（第 31-38 行）：注册 CVar sink（第 34 行，回调 `UpdateShaderDevelopmentMode`）；`InitRenderGraph();`（第 36 行——RDG 调试命令解析，如 `rdgimmediate`、`rdgvalidation`，位于 `#if RDG_ENABLE_DEBUG_WITH_ENGINE` 段第 502-553 行）；`InitPixelRenderCounters();`（第 37 行）
- **`ShutdownModule()`**（第 40-43 行）：`ShutdownRenderGraph();`（第 42 行 → `FRDGBuilder::WaitForAsyncDeleteTask()`）
- **`SupportsDynamicReloading`**：未覆写（模块内 0 命中；接口默认返回 `true`，`Engine/Source/Runtime/Core/Public/Modules/ModuleInterface.h` 第 88-91 行）
- 日志：`LogRendererCore`（第 48 行）

## 六、关键约定与坑

1. **`FRenderResource` 不继承 `FDeferredCleanupInterface`**（5.8 实测：类声明无基类子句，见 `types/FRenderResource.md`）；`FDeferredCleanupInterface` 出现在其**派生类**上（如 `FShaderMapResource`，`Public/Shader.h` 第 335 行）——旧版本记忆勿沿用。
2. **RDG 的实现就在本模块**：`FRDGBuilder` 在 `Public/RenderGraphBuilder.h` 第 50 行；调试命令经 `InitRenderGraph()` 解析。
3. **`RHIStaticStates.h` 在本模块**（不在 RHI）；引擎中**不存在** `RHIPipelineState.h`。
4. **重复出现勿去重**：`RHI` 同时在公开依赖（12）与公开包含路径（48）；`TargetPlatform` 在无条件包含路径（14）与编辑器动态加载（23）两处。
5. **数字口径**：`RenderCore.Build.cs` 72 行（`ReadAllLines`）、6 处 `if`、0 处三方静态调用；公开侧 105 个 `.h`。取数命令见「取数说明」。

## 取数说明

以下命令的相对基准为 `Engine/Source`（实际路径按 `_meta/convention.md` 的本机环境块解析）：

| 断言 | 取数方式 |
|---|---|
| 212 文件 / 121 头文件 | `[M]` 引擎磁盘递归计数：`(Get-ChildItem "Runtime/RenderCore" -Recurse -File).Count` 得文件数；`(Get-ChildItem "Runtime/RenderCore" -Recurse -File -Filter *.h).Count` 得头文件数（同 `_meta/engine-modules.json` 口径） |
| 公开侧 105 个 `.h`（顶层 103 + 子目录 2） | `[M]` `(Get-ChildItem "Runtime\RenderCore\Public" -Recurse -File -Filter *.h).Count` |
| Build.cs 72 行、6 处 `if`、0 处三方静态调用 | `[M]` `[System.IO.File]::ReadAllLines("Runtime/RenderCore/RenderCore.Build.cs").Count`；`Select-String "Runtime/RenderCore/RenderCore.Build.cs" -Pattern '\bif\s*\(' -AllMatches`；`Select-String "Runtime/RenderCore/RenderCore.Build.cs" -Pattern 'AddEngineThirdPartyPrivateStaticDependencies' -AllMatches` |
| 全部行号引用 | 2026-10-10 对 UE 5.8.3 源码本机逐条核对 |

## 相关文档

- `types/FRenderResource.md` —— 本模块资源基类（同批产出）
- `modules/RHI-结构.md` —— 下层 RHI 抽象层（同批产出）
- `types/FRHIResource.md` —— RHI 侧资源基类（同批产出）
- `modules/Core-结构.md` —— 上游地基模块（已校验）

## 更新记录

- 2026-10-11 按规范 4.2.1 为「取数说明」各行加方法标记（`[M]`/`[R]`/`[H]`）；`[M]` 行把原文省略成 `(...)` 的路径补全为白名单可执行命令，现由 `ue-doc-verify` 逐条实际执行比对
