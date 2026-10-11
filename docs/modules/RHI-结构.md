> 引擎版本：UE 5.8.3 (Build 58210709)
> 源码根：Engine/Source
> 生成技能：ue-module-structure v1.0
> 生成时间：2026-10-10
> 校验状态：已校验（2026-10-11）

# RHI 模块结构

## 一、模块定位

| 项 | 值 |
|---|---|
| 路径 | `Engine/Source/Runtime/RHI` |
| 类别 | Runtime |
| 规模 | 108 文件 / 62 头文件（`_meta/engine-modules.json` 2026-10-10 口径；其中公开侧 57 个 `.h`） |
| 分层 | 渲染 |
| 一句话职责 | 渲染硬件接口抽象层：`FRHIResource` 资源模型、`FRHICommandList` 命令列表、`FDynamicRHI` 后端接口与着色器平台/管线状态——平台后端（D3D12 / Vulkan / …）实现于此接口之下 |

## 二、目录结构

```
RHI/
├── RHI.Build.cs                  # 模块构建脚本（68 行、9 处 if 分支）
├── Public/                       # 公开侧（54 个顶层 .h；子目录 Android/ IOS/ Tests/ Windows/ 含 3 个 .h；共 57 个 .h）
├── Private/                      # 实现（4 个子目录 + 32 个 .cpp + 1 个 .h）
└── Internal/                     # 内部共享（RHIShaderPlatformConfig.h、RHIUniformBufferUtilities.h）
```

- 模块入口直接使用 UBT 框架类（无自定义模块类，见第五节）。
- 无聚合头；公共头事实上的"多包含中心"是 `RHICommandList.h`（10 处 `#include "RHI..."`）。

## 三、依赖关系

### 3.1 无条件依赖

| 模块 | 类型 | Build.cs 行 | 说明 |
|---|---|---|---|
| `Core` | 私有依赖 | 13 | |
| `TraceLog` | 私有依赖 | 14 | |
| `ApplicationCore` | 私有依赖 | 15 | |
| `Cbor` | 私有依赖 | 16 | CBOR 序列化（以模块形式引入，不属三方静态表） |
| `BuildSettings` | 私有依赖 | 17 | |

> 另有无条件项：`bRequiresPlatformSDK = true;`（第 11 行）；公开定义 `WITH_MGPU`（第 23 行，取值含 Windows 平台组判断）。
> 本模块**无公开依赖列表**；辅助函数检查：**无**——无未展开依赖。

### 3.2 平台与配置条件依赖

> 全文 **9 处 `if` 分支**（第 18、25、29、32、37、44、49、57、62 行）。

| 依赖 / 项 | 类型 | 生效条件 | Build.cs 行 |
|---|---|---|---|
| `WindowsD3D` | 私有依赖 | Windows 平台组 | 18-21 |
| `NullDrv` | 动态加载 | `bCompileAgainstEngine` | 25-27 |
| `D3D11RHI`、`D3D12RHI` | 动态加载 | 引擎目标且**非 Server**（嵌套，第 29 行）且 Windows 平台组 | 37-41 |
| `VulkanRHI` | 动态加载 | 引擎目标且非 Server 且（Windows 平台组或 Unix 平台组） | 44-47 |
| `OpenGLDrv` | 动态加载 | 引擎目标且非 Server 且（Windows 平台组或（Linux 且非 Server）） | 49-53 |
| `RHI_WANT_RESOURCE_INFO=1`（公开定义） | 编译定义 | 非 Shipping 且（非 Test 或 `bTrackRHIResourceInfoForTest`） | 32-35 |
| `ProfileVisualizer` | 私有包含路径 | 非 Shipping | 57-60 |
| `TargetPlatform` | 私有包含路径 + 动态加载 | `bBuildEditor` | 62-66 |

### 3.3 第三方静态依赖

`AddEngineThirdPartyPrivateStaticDependencies` 调用 **0 处**——本模块无第三方静态依赖（`Cbor` 等以模块形式引入的列在 3.1）。

## 四、对外暴露面

> 公开侧 57 个 `.h`；核心头如下（均为实测存在）。

| 头文件 | 提供的能力 |
|---|---|
| `Public/RHIResources.h`（196.65 KB） | RHI 资源模型：`FRHIResource` 及全部资源类型（→ `types/FRHIResource.md`） |
| `Public/RHICommandList.h`（188.69 KB） | `FRHICommandListBase`（第 453 行）、`FRHICommandList`（第 3590 行）、`FRHICommandListImmediate`（第 4388 行） |
| `Public/DynamicRHI.h`（62.01 KB） | `FDynamicRHI`（第 198 行）后端接口；`IDynamicRHIModule`（第 1466 行） |
| `Public/RHIDefinitions.h`（59.09 KB） | RHI 枚举与定义 |
| `Public/RHIFwd.h` | 前向声明 + 引用别名（如 `FTextureRHIRef` 第 130 行）；`RHI_ENABLE_RESOURCE_INFO` 宏（第 17 行） |
| `Public/RHI.h`（23.63 KB） | 主头（含 `RHIDefinitions.h` 等 6 处包含） |
| `Public/RHIShaderParameters.h` | 着色器参数绑定模型 |
| `Public/RHIUtilities.h`（27.09 KB） | 工具集 |
| `Public/RHIResourceUtils.h` | 资源工具 |
| `Public/RHIStats.h` | 统计 |
| `Public/RHIGlobals.h` | 全局配置 |
| `Public/RHITextureReference.h` | `FRHITextureReference`（第 7 行） |
| `Public/RHIResourceCollection.h` | `FRHIResourceCollection`（第 45 行） |
| `Public/RHIDescriptorRange.h` | `FRHIDescriptorRange`（第 103 行） |
| `Public/RHIShaderLibrary.h` | `FRHIShaderLibrary`（第 14 行） |
| `Public/PipelineStateCache.h` | 管线状态缓存 |
| `Public/GPUProfiler.h` | GPU 性能分析 |

> 注意：`RHIStaticStates.h` **不在本模块**（在 RenderCore）；引擎中**不存在** `RHIPipelineState.h`（实测 0 命中）；`UnrealClient.h` 在 Engine。见第六节。

## 五、模块生命周期

```
文件：Engine/Source/Runtime/RHI/Private/RHI.cpp
行 35：IMPLEMENT_MODULE(FDefaultModuleImpl, RHI);
```

- **入口直接使用 UBT 框架类**：模块类即 `FDefaultModuleImpl`（定义在 `Engine/Source/Runtime/Core/Public/Modules/ModuleManager.h` 第 884-886 行；注释原文：`A default minimal implementation of a module that does nothing at startup and shutdown`）——**本模块没有自定义模块类**；模块内 `StartupModule` / `ShutdownModule` / `SupportsDynamicReloading` 全部 0 命中（无覆写）。
- 文件级模块设施：`DEFINE_LOG_CATEGORY(LogRHI);`（第 38 行）、`IMPLEMENT_TYPE_LAYOUT(...)` ×2（第 40-41 行）、静态 CVar（如第 47 行 `CVarDisableEngineAndAppRegistration`）。

## 六、关键约定与坑

1. **RHI 没有自己的模块类**——入口是 `IMPLEMENT_MODULE(FDefaultModuleImpl, RHI)`（第 35 行）。不要把 `IRHITestModule`（`Public/Tests/RHIUnitTests.h` 第 7 行）或 `IDynamicRHIModule`（`Public/DynamicRHI.h` 第 1466 行）误当模块类——它们是接口。
2. **不要按名字猜模块归属**：`RHIStaticStates.h` 在 **RenderCore**；`UnrealClient.h` 在 **Engine**；`RHIPipelineState.h` **不存在**（实测 0 命中）。
3. **无聚合头**；公共头"包含中心"是 `RHICommandList.h`。
4. **数字口径**：`RHI.Build.cs` 68 行（`ReadAllLines`）、9 处 `if`、0 处三方静态调用；公开侧 57 个 `.h`（模块合计 62 个 `.h`）。取数命令见「取数说明」。

## 取数说明

以下命令的相对基准为 `Engine/Source`（实际路径按 `_meta/convention.md` 的本机环境块解析）：

| 断言 | 取数方式 |
|---|---|
| 108 文件 / 62 头文件 | `[M]` 引擎磁盘递归计数：`(Get-ChildItem "Runtime/RHI" -Recurse -File).Count` 得文件数；`(Get-ChildItem "Runtime/RHI" -Recurse -File -Filter *.h).Count` 得头文件数（同 `_meta/engine-modules.json` 口径） |
| 公开侧 57 个 `.h` | `[M]` `(Get-ChildItem "Runtime\RHI\Public" -Recurse -File -Filter *.h).Count` |
| Build.cs 68 行、9 处 `if`、0 处三方静态调用 | `[M]` `[System.IO.File]::ReadAllLines("Runtime/RHI/RHI.Build.cs").Count`；`Select-String "Runtime/RHI/RHI.Build.cs" -Pattern '\bif\s*\(' -AllMatches`；`Select-String "Runtime/RHI/RHI.Build.cs" -Pattern 'AddEngineThirdPartyPrivateStaticDependencies' -AllMatches` |
| 全部行号引用 | 2026-10-10 对 UE 5.8.3 源码本机逐条核对 |

## 相关文档

- `types/FRHIResource.md` —— 本模块资源基类（同批产出）
- `modules/RenderCore-结构.md` —— 上层渲染公共层（同批产出）
- `types/FRenderResource.md` —— RenderCore 侧资源基类（同批产出）
- `modules/Core-结构.md` —— 上游地基模块（已校验）

## 更新记录

- 2026-10-11 按规范 4.2.1 为「取数说明」各行加方法标记（`[M]`/`[R]`/`[H]`）；`[M]` 行把原文省略成 `(...)` 的路径补全为白名单可执行命令，现由 `ue-doc-verify` 逐条实际执行比对
