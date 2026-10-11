> 引擎版本：UE 5.8.3 (Build 58210709)
> 源码根：Engine/Source
> 生成技能：ue-type-api v1.0
> 生成时间：2026-10-10
> 校验状态：已校验（2026-10-11）

# FRHIResource

## 一、类型概览

| 项 | 值 |
|---|---|
| 全限定名 | `FRHIResource`（全局命名空间） |
| 定义位置 | `Engine/Source/Runtime/RHI/Public/RHIResources.h` |
| 类型 | 类（纯 C++，非反射类型） |
| 反射宏 | 无（`UCLASS` / `GENERATED_BODY` 等实测 0 命中） |
| 导出策略 | 类声明行**无**类级导出宏（第 53 行 `class FRHIResource`）；成员逐个标注 `RHI_API`（第 56、61、65、69、70、132 行）——`class RHI_API FRHIResource` 全库 0 命中 |
| 所属模块 | `RHI`（`Engine/Source/Runtime/RHI`） |

## 二、继承链

**无基类**（第 53-54 行：`class FRHIResource` 后直接 `{`）——**它就是链根**，不继承 `FRefCountedObject` 或 `FDeferredCleanupInterface`（实测：两个类名均未出现在类体内）。引用计数由自身嵌套类 `FAtomicFlags` 实现（第 141-220 行；成员见第 221 行）。

## 三、声明片段

```
文件：Engine/Source/Runtime/RHI/Public/RHIResources.h
行 52-55：/** The base type of RHI resources. */ / class FRHIResource / { / public:

文件：Engine/Source/Runtime/RHI/Public/RHIResources.h
行 141-145：嵌套 FAtomicFlags 类（MarkedForDeleteBit = 1 << 30 / DeletingBit = 1 << 31 / NumRefsMask）

文件：Engine/Source/Runtime/RHI/Public/RHIResources.h
行 236：类体结束（};；文件 5,927 行）
```

## 四、公开 API

| 签名 / 成员 | 说明 | 位置 |
|---|---|---|
| `FRHIResource(ERHIResourceType)` | 构造（传入资源类型） | 第 56 行 |
| `AddRef()` | 增加引用（原子操作） | 第 73-78 行 |
| `Release()` | 减少引用；归零时触发 `MarkForDelete()` | 第 80-91 行 |
| `GetRefCount()` | 当前引用数 | 第 93-98 行 |
| `IsValid()` | 是否有效（未被标记删除 / 非删除中） | 第 100-103 行 |
| `DisableLifetimeExtension()` | 禁止生命周期延长 | 第 105-109 行 |
| `GetType()` | 资源类型（`ERHIResourceType`） | 第 111 行 |
| `GetOwnerName()` / `SetOwnerName(...)` | 拥有者名（受 `#if RHI_ENABLE_RESOURCE_INFO` 门控） | 第 113 / 122 行 |
| `static DeleteResources(...)` / `static GatherResourcesToDelete(...)` | 删除队列操作 | 第 69 / 70 行 |
| `static BeginTrackingResource(...)` 等 4 个追踪函数 | 资源追踪（条件编译） | 第 134-137 行 |

> 数据成员：`mutable FAtomicFlags AtomicFlags`（第 221 行，引用计数与删除状态位）、
> `const ERHIResourceType ResourceType`（第 223 行，**每实例**常量——不是 static）；
> `#if RHI_ENABLE_RESOURCE_INFO` 下另有 `bBeingTracked` / `OwnerName`（第 226-229 行）。
> 友元：`FDynamicRHI`（第 67 行）、`FRHICommandListExecutor`（第 68 行）、`FRHICommandListImmediate`（第 235 行）。

## 五、扩展点

### 5.1 可覆写虚函数

| 虚函数 | 位置 | 说明 |
|---|---|---|
| `GetResourceInfo(FRHIResourceInfo&) const` | 第 132 行 | 提供资源调试信息；受 `#if RHI_ENABLE_RESOURCE_INFO` 门控（宏定义见 `Engine/Source/Runtime/RHI/Public/RHIFwd.h` 第 17 行） |

（类体内共 2 处 `virtual`，另一处为析构，见 5.2。）

### 5.2 不建议覆写的内部虚函数 / 内部成员

| 成员 | 位置 | 原因 |
|---|---|---|
| `virtual ~FRHIResource()`（protected） | 第 61 行 | 注释明确：RHI 资源只应经删除队列销毁——不要直接析构 / `delete` |
| `MarkForDelete()`（private） | 第 65 行 | 删除标记内部流程（由 `Release` 归零触发） |
| 嵌套 `FAtomicFlags` | 第 141-220 行 | 引用计数位域实现（`MarkedForDeleteBit` / `DeletingBit` / `NumRefsMask`，第 143-145 行） |

## 六、生命周期

- 纯 C++ 对象：无 `UObject` 生命周期钩子。
- **引用计数语义**：`AddRef` / `Release`（第 73 / 80 行）；`Release` 归零 → `MarkForDelete()` → 由 RHI 删除队列（`DeleteResources`，第 69 行）延迟销毁——**不要直接 `delete` FRHIResource 派生对象**。
- 持有方式：智能指针别名（`RHIFwd.h` 第 100-139 行，如 `FTextureRHIRef = TRefCountPtr<FRHITexture>`，第 130 行）。

## 七、派生类（范围内）

搜索边界：派生类搜索**覆盖 Runtime 291 个模块 + `EnhancedInput` 插件全部 3 个模块（共 294 个模块）**，引擎其余部分（Editor / Developer / Platforms / 未纳入的 Plugins）未覆盖。搜索模式 `\bpublic\s+FRHIResource\b`（`*.h`）：Runtime 命中 **28 行 / 4 文件**；EnhancedInput 命中 **0**。

| 派生类 / 组 | 位置 | 备注 |
|---|---|---|
| 25 个直接派生类 | 均在 `Engine/Source/Runtime/RHI/Public/RHIResources.h`：如 `FRHISamplerState`（第 633 行）、`FRHIShader`（第 842 行）、`FRHIUniformBuffer`（第 1262 行）、`FRHIViewableResource`（第 1314 行）、`FRHIGPUFence`（第 2397 行）、`FRHIRenderQueryPool`（第 2490 行）、`FRHIViewport`（第 2544 行）、`FRHIView`（第 3304 行）、`FRHICustomPresent`（第 4365 行） | 同文件内定义 |
| `FRHIShaderLibrary` | `Engine/Source/Runtime/RHI/Public/RHIShaderLibrary.h` 第 14 行 | — |
| `FRHIResourceCollection` | `Engine/Source/Runtime/RHI/Public/RHIResourceCollection.h` 第 45 行 | — |
| `FRHIDescriptorRange` | `Engine/Source/Runtime/RHI/Public/RHIDescriptorRange.h` 第 103 行 | — |
| 代表性间接派生 | `FRHIBuffer`（`RHIResources.h` 第 1627 行，经 `FRHIViewableResource`）；`FRHITexture`（第 2167 行，经 `FRHIViewableResource`）；`FRHITextureReference`（`RHITextureReference.h` 第 7 行，经 `FRHITexture`） | — |

## 取数说明

| 断言 | 取数方式（相对基准：`Engine/Source`） |
|---|---|
| 搜索边界 294 个模块（Runtime 291 + `EnhancedInput` 插件 3） | `[M]` 插件 3 个模块（含白名单外的 `InputBlueprintNodes` / `InputEditor`）：`(Get-ChildItem "Engine/Plugins/EnhancedInput/Source" -Directory).Count` → 3；Runtime 291 见 `_meta/inventory.md` |
| 文件 5,927 行、类体 53-236 | `[M]` `[System.IO.File]::ReadAllLines("Engine/Source/Runtime/RHI/Public/RHIResources.h").Count`（同文件 `^};` 检索定类体区间） |
| 类内 `virtual` 2 处 | `[M]` 类体内计数（第 53-236 行；全文 74 处，其余属 `FRHIResource` 之外的类型，不计入本类）：`Select-String "Engine/Source/Runtime/RHI/Public/RHIResources.h" -Pattern 'virtual' -AllMatches -Range 53-236` |
| 派生统计：Runtime 28 行 / 4 文件；EnhancedInput 0 | `[H]` `Select-String -Pattern '\bpublic\s+FRHIResource\b'`（`*.h`） |
| 全部行号引用 | 2026-10-10 对 UE 5.8.3 源码本机逐条核对 |

## 相关文档

- `modules/RHI-结构.md` —— FRHIResource 所在模块（同批产出）
- `types/FRenderResource.md` —— RenderCore 侧资源基类（同批产出）
- `modules/RenderCore-结构.md` —— 上层渲染公共层（同批产出）
- `modules/Core-结构.md` —— 上游地基模块（已校验）

## 更新记录

- 2026-10-11 搜索边界更正：派生搜索实覆盖 **294** 个模块（Runtime 291 + `EnhancedInput` 插件 3），原文误作"纳入范围的 292 个模块"（292 是白名单口径，搜索实际连 `InputBlueprintNodes` / `InputEditor` 一并覆盖，本文件命中的插件侧结果即来自 `InputEditor`）；同时在「取数说明」补入该边界取数方式（`convention.md` 4.2）

- 2026-10-11 按规范 4.2.1 为「取数说明」各行加方法标记（`[M]`/`[R]`/`[H]`）；`[M]` 行把原文省略成 `(...)` 的路径补全为白名单可执行命令，现由 `ue-doc-verify` 逐条实际执行比对
- 2026-10-11 「类内 `virtual` 2 处」明确为**类体内**（第 53-236 行）口径，命令用 `-Range` 复算（全文为 74 处）
