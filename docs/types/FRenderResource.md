> 引擎版本：UE 5.8.3 (Build 58210709)
> 源码根：Engine/Source
> 生成技能：ue-type-api v1.0
> 生成时间：2026-10-10
> 校验状态：已校验（2026-10-11）

# FRenderResource

## 一、类型概览

| 项 | 值 |
|---|---|
| 全限定名 | `FRenderResource`（全局命名空间） |
| 定义位置 | `Engine/Source/Runtime/RenderCore/Public/RenderResource.h` |
| 类型 | 类（纯 C++，非反射类型） |
| 反射宏 | 无（`UCLASS` / `GENERATED_BODY` 实测 0 命中） |
| 导出策略 | 类声明行**无**类级导出宏（第 36 行）；成员逐个标注 `RENDERCORE_API`（如第 50、64、76 行）；内联成员不带 |
| 所属模块 | `RenderCore`（`Engine/Source/Runtime/RenderCore`） |

## 二、继承链

**无基类**（第 36-37 行：`class FRenderResource` 后直接 `{`）——链根。
**注意（与旧版本差异）**：5.8 中它**不继承** `FDeferredCleanupInterface`——该接口出现在其**派生类**上（如 `FShaderMapResource`，`Engine/Source/Runtime/RenderCore/Public/Shader.h` 第 335 行）。

## 三、声明片段

```
文件：Engine/Source/Runtime/RenderCore/Public/RenderResource.h
行 33-37：/** A rendering resource which is owned by the rendering thread. */ / class FRenderResource / {

文件：Engine/Source/Runtime/RenderCore/Public/RenderResource.h
行 19-24：enum class ERenderResourceState : uint8 { Default, BatchReleased, Deleted, };

文件：Engine/Source/Runtime/RenderCore/Public/RenderResource.h
行 212：类体结束（};；文件 522 行）
```

## 四、公开 API

| 签名 / 成员 | 说明 | 位置 |
|---|---|---|
| `FRenderResource()` / `FRenderResource(ERHIFeatureLevel::Type)` | 构造 | 第 64 / 67 行 |
| 拷贝 / 移动构造与赋值 | 4 个重载 | 第 70-73 行 |
| `InitRHI(FRHICommandListBase&)`（虚） | 创建 RHI 侧资源（**子类覆写点**） | 第 83 行 |
| `ReleaseRHI()`（虚） | 释放 RHI 侧资源（**子类覆写点**） | 第 90 行 |
| `InitResource(FRHICommandListBase&)`（虚） | 生命周期入口（注册并驱动 `InitRHI`） | 第 96 行 |
| `ReleaseResource()`（虚） | 生命周期出口（驱动 `ReleaseRHI` 并注销） | 第 102 行 |
| `UpdateRHI(FRHICommandListBase&)` | 已初始化则"释放 + 重建"（**非虚**） | 第 108 行 |
| `GetFriendlyName()`（虚） | 调试命名（默认 `"undefined"`） | 第 111 行 |
| `IsInitialized()` / `GetListIndex()` / `GetInitPhase()` | 状态查询（inline） | 第 114 / 116 / 117 行 |
| `SetOwnerName(...)` / `GetOwnerName()` | 拥有者名 | 第 120 / 127 行 |
| `SetResourceName(...)` / `GetResourceName()` | 资源名（受 `#if RHI_ENABLE_RESOURCE_INFO`） | 第 136 / 143 行 |
| `ResourceState`（`ERenderResourceState`） | 批释放状态机成员 | 第 211 行 |
| 静态：`ReleaseRHIForAllResources()` / `InitPreRHIResources()` / `ChangeFeatureLevel(...)` / `SetScopeName(...)` | 全局管理 | 第 50 / 53 / 56 / 59 行 |
| 非成员驱动函数：`BeginInitResource(...)`（第 218 / 220 行）、`BeginUpdateResourceRHI(...)`（233）、`BeginReleaseResource(...)`（239）、`StartBatchedRelease()`（245）、`EndBatchedRelease()`（251）、`ReleaseResourceAndFlush(...)`（257） | 渲染线程生命周期驱动 | 见左 |

> **`UpdateResource()` 与 `GetRHI()` 不存在于本类**：重初始化由非虚 `UpdateRHI()` 承担；
> `GetRHI()` 是派生类成员（如 `FVertexBuffer::GetRHI`，同文件第 389 行）。

## 五、扩展点

### 5.1 可覆写虚函数（类内 6 条，全列）

| 虚函数 | 位置 | 说明 |
|---|---|---|
| `InitRHI(FRHICommandListBase&)` | 第 83 行 | 创建 RHI 侧资源（基类空实现） |
| `ReleaseRHI()` | 第 90 行 | 释放 RHI 侧资源（基类空实现） |
| `InitResource(FRHICommandListBase&)` | 第 96 行 | 覆写时应调 `Super`（资源注册与线程模型由基类维护） |
| `ReleaseResource()` | 第 102 行 | 同上 |
| `GetFriendlyName()` | 第 111 行 | 调试命名 |
| `~FRenderResource()` | 第 76 行 | 虚析构 |

> **需要"重建资源"时不要找 `UpdateResource()` 覆写**——重初始化入口 `UpdateRHI()` 是**非虚**的（第 108 行）；
> 自定义重建逻辑应放在 `ReleaseRHI` + `InitRHI` 中。

### 5.2 不建议覆写的内部虚函数

无——6 条虚函数均为设计覆写面；批释放状态机（`ResourceState`）经 `StartBatchedRelease` / `EndBatchedRelease` 驱动，均为非虚。

## 六、生命周期

- 渲染线程持有的资源基类（头文件注释第 33-35 行：`A rendering resource which is owned by the rendering thread`）。
- **初始化**：`BeginInitResource(this)`（第 218 行）→ 入渲染线程列表 → `InitResource`（第 96 行）→ `InitRHI`（第 83 行）。
- **释放**：`BeginReleaseResource`（第 239 行）→ `ReleaseResource`（第 102 行）→ `ReleaseRHI`（第 90 行）。
- **批释放**：`StartBatchedRelease` / `EndBatchedRelease`（第 245 / 251 行）配合 `ResourceState` 状态机（第 211 行）。
- 线程与时序细节属 `flows/` 范畴（暂无渲染流程产物）。

## 七、派生类（范围内）

搜索边界：派生类搜索**覆盖 Runtime 291 个模块 + `EnhancedInput` 插件全部 3 个模块（共 294 个模块）**，引擎其余部分（Editor / Developer / Platforms / 未纳入的 Plugins）未覆盖。搜索模式 `\bpublic\s+FRenderResource\b`（`*.h`）：Runtime 命中 **63 文件 / 74 行**（RenderCore 14 / 21；Engine 28 / 30；Renderer 17 / 18；其它 4 文件 / 5 行）；EnhancedInput **0**。

| 代表派生类 | 位置 |
|---|---|
| `FTexture` | `Engine/Source/Runtime/RenderCore/Public/RenderResource.h` 第 260 行 |
| `FVertexBuffer` / `FIndexBuffer` / `FBufferWithRDG` | 同文件第 377 / 412 / 431 行 |
| `FVertexFactory` | `Engine/Source/Runtime/RenderCore/Public/VertexFactory.h` 第 655 行 |
| `TUniformBuffer` | `Engine/Source/Runtime/RenderCore/Public/UniformBuffer.h` 第 28 行 |
| `FRenderTargetPool` | `Engine/Source/Runtime/RenderCore/Public/RenderTargetPool.h` 第 98 行 |
| `FStaticMeshVertexBuffer` | `Engine/Source/Runtime/Engine/Public/Rendering/StaticMeshVertexBuffer.h` 第 149 行 |
| `FMaterialRenderProxy` | `Engine/Source/Runtime/Engine/Public/Materials/MaterialRenderProxy.h` 第 103 行 |
| `FSystemTextures` | `Engine/Source/Runtime/Renderer/Public/SystemTextures.h` 第 81 行 |
| `FD3D11ConstantBuffer` | `Engine/Source/Runtime/Windows/D3D11RHI/Public/D3D11ConstantBuffer.h` 第 32 行 |

完整清单按「取数说明」中的命令复现。

## 取数说明

| 断言 | 取数方式（相对基准：`Engine/Source`） |
|---|---|
| 搜索边界 294 个模块（Runtime 291 + `EnhancedInput` 插件 3） | `[M]` 插件 3 个模块（含白名单外的 `InputBlueprintNodes` / `InputEditor`）：`(Get-ChildItem "Engine/Plugins/EnhancedInput/Source" -Directory).Count` → 3；Runtime 291 见 `_meta/inventory.md` |
| 文件 522 行、类体 36-212 | `[M]` `[System.IO.File]::ReadAllLines("Engine/Source/Runtime/RenderCore/Public/RenderResource.h").Count`（同文件 `^};` 检索定类体区间） |
| 类内 `virtual` 6 条 | `[H]` `Select-String ... -Pattern 'virtual'` + 类体区间（第 36-212 行）逐行枚举 |
| 派生统计：Runtime 63 文件 / 74 行；EnhancedInput 0 | `[H]` `Select-String -Pattern '\bpublic\s+FRenderResource\b'`（`*.h`），按模块分组计数 |
| 全部行号引用 | 2026-10-10 对 UE 5.8.3 源码本机逐条核对 |

## 相关文档

- `modules/RenderCore-结构.md` —— FRenderResource 所在模块（同批产出）
- `types/FRHIResource.md` —— RHI 侧资源基类（同批产出）
- `modules/RHI-结构.md` —— 下层 RHI 抽象层（同批产出）
- `modules/Core-结构.md` —— 上游地基模块（已校验）

## 更新记录

- 2026-10-11 搜索边界更正：派生搜索实覆盖 **294** 个模块（Runtime 291 + `EnhancedInput` 插件 3），原文误作"纳入范围的 292 个模块"（292 是白名单口径，搜索实际连 `InputBlueprintNodes` / `InputEditor` 一并覆盖，本文件命中的插件侧结果即来自 `InputEditor`）；同时在「取数说明」补入该边界取数方式（`convention.md` 4.2）

- 2026-10-11 按规范 4.2.1 为「取数说明」各行加方法标记（`[M]`/`[R]`/`[H]`）；`[M]` 行把原文省略成 `(...)` 的路径补全为白名单可执行命令，现由 `ue-doc-verify` 逐条实际执行比对
