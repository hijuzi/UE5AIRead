> 引擎版本：UE 5.8.3 (Build 58210709)
> 源码根：Engine/Source
> 生成技能：ue-type-api v1.0
> 生成时间：2026-10-10
> 校验状态：已校验（2026-10-10）

# FSceneInterface

## 一、类型概览

| 项 | 值 |
|---|---|
| 全限定名 | `FSceneInterface`（全局命名空间） |
| 定义位置 | `Engine/Source/Runtime/Engine/Public/SceneInterface.h`（**定义在 Engine 模块**；由 Renderer 模块的 `FScene` 实现） |
| 类型 | 类（纯 C++ 抽象接口，非反射类型） |
| 反射宏 | 无（`UCLASS` / `GENERATED_BODY` 等实测 0 命中） |
| 导出策略 | 类声明行**无**类级导出宏（第 119 行 `class FSceneInterface`）；成员级 `ENGINE_API`（第 122、150、734 行与嵌套类静态方法第 640-641 行）——**不是** `RENDERER_API`（该文件 0 命中） |
| 所属模块 | **Engine**（定义）；唯一实现 `FScene` 在 `Renderer` 模块 |

## 二、继承链

**无基类**（第 119-120 行：`class FSceneInterface` 后直接 `{`）——它就是链根，是**纯抽象接口**（166 条虚函数中 100 条为纯虚）。

## 三、声明片段

```
文件：Engine/Source/Runtime/Engine/Public/SceneInterface.h
行 119-121：class FSceneInterface / { / public:

文件：Engine/Source/Runtime/Engine/Public/SceneInterface.h
行 815-816：protected: / virtual ~FSceneInterface() = default;

文件：Engine/Source/Runtime/Engine/Public/SceneInterface.h
行 825：类体结束（};；文件 825 行）
```

## 四、公开 API

| 签名 | 说明 | 位置（SceneInterface.h） |
|---|---|---|
| `FSceneInterface(ERHIFeatureLevel::Type)` | 构造（`ENGINE_API`） | 第 122 行 |
| `AddPrimitive(UPrimitiveComponent*)`（纯虚） | 登记图元 | 第 131 行 |
| `RemovePrimitive(UPrimitiveComponent*)`（纯虚） | 注销图元 | 第 137 行 |
| `ReleasePrimitive(...)`（纯虚） | 释放图元 | 第 139 行 |
| `UpdatePrimitiveTransform(UPrimitiveComponent*)`（纯虚） | 变换更新 | 第 157 行 |
| `UpdateAllPrimitiveSceneInfos(...)`（纯虚，另有 `ENGINE_API` 非虚重载） | 批量刷新图元 | 第 149 / 150 行 |
| `GetPrimitiveSceneInfo(int32 / FPrimitiveComponentId)`（纯虚 ×2） | 图元信息查询 | 第 183 / 186 行 |
| `AddLight(ULightComponent*)` / `RemoveLight(...)`（纯虚） | 光源增删 | 第 196 / 203 行 |
| `AddDecal(UDecalComponent*)` / `RemoveDecal(...)`（纯虚） | 贴花增删 | 第 244 / 250 行 |
| `UpdateLightTransform` / `UpdateLightColorAndBrightness`（纯虚） | 光源更新 | 第 358 / 364 行 |
| `AddPrimitive(FPrimitiveSceneDesc*)` / `RemovePrimitive` / `UpdatePrimitiveTransform`（纯虚组） | 描述符路径重载 | 第 568 / 569 / 571 行 |
| `Release()`（纯虚） | 显式释放场景 | 第 594 行 |
| `GetWorld()`（纯虚） | 所属世界 | 第 621 行 |
| `GetRenderScene()`（纯虚，const / 非 const 各一） | 取实现侧 `FScene*` | 第 627 / 628 行 |
| `GetPrimitiveSceneProxies()`（纯虚） | 代理列表 | 第 761 行 |
| `GetFeatureLevel()` / `GetShaderPlatform()` | **非虚** inline 访问器（读 protected 成员） | 第 730 / 732 行 |

> `GetSceneName` 等名称 API **不存在**（实测 0 命中；对照 `GetWorld` 在同类范围内命中 80+ 文件，证明检索有效）。

## 五、扩展点

### 5.1 可覆写虚函数

> 类内 `virtual` 共 **166 条**（逐行通读口径；其中**纯虚 100 条**、带默认实现 66 条）。按语义分组（骨架如下，完整清单以头文件为准）：

**a) 场景突变（增删 / 更新）——117 条**

| 组 | 代表成员（行号） |
|---|---|
| Primitive | `AddPrimitive`(131)、`RemovePrimitive`(137)、`ReleasePrimitive`(139)、`BatchAddPrimitives`(142)、`UpdatePrimitiveTransform`(157)、`UpdatePrimitiveAttachment`(162)、`UpdateCustomPrimitiveData`(176) |
| Light | `AddLight`(196)、`RemoveLight`(203)、`AddInvisibleLight`(210)、`BatchAddLights`(217)、`SetSkyLight`(233)、`DisableSkyLight`(234) |
| Decal | `AddDecal`(244)、`UpdateDecalTransform`(256)、`BatchUpdateDecals`(259) |
| 反射捕获（默认空实现） | `AddReflectionCapture`(262)、`AllocateReflectionCaptures`(277)、`ResetReflectionCaptures`(287) |
| 雾 / 大气 / 云 / 毛发 / 物理场 / 风 | `AddExponentialHeightFog`(391)、`AddSkyAtmosphere`(425)、`AddVolumetricCloud`(450)、`AddHairStrands`(463)、`SetPhysicsField`(493)、`AddWindSource`(520)、`AddSpeedTreeWind`(550) |
| 生命周期 / 帧 | `Release`(594)、`StartFrame`(768)、`EndFrame`(769) |
| 已废弃（5.8） | `UpdateStaticDrawLists`(375)、`RequiresHitProxies`(615) 等（头文件内标 `UE_DEPRECATED(5.8, ...)`） |

**b) 查询 / 访问——44 条**

`GetPrimitiveSceneInfo`(183/186)、`GetPreviousLocalToWorld`(190)、`HasSkyLightRequiringLightingBuild`(236)、`GetPrimitiveUniformShaderParameters_RenderThread`(346)、`GetSkyAtmosphereSceneInfo`(435)、`GetWindSources_RenderThread`(535)、`GetRelevantLights`(601)、`GetWorld`(621)、`GetRenderScene`(627/628)、`GetGPUSkinCache`(667)、`IsEditorScene`(726)、`GetPrimitiveSceneProxies`(761)、`GetFrameNumber`(770) 等。

**c) 其它——5 条**

嵌套类 `IPrimitiveTransformUpdater` 析构(638)、`Export(FArchive&)`(702)、编辑器 `InitializePixelInspector`(746) / `AddPixelInspectorRequest`(755)、本类析构 `~FSceneInterface`(816)。

### 5.2 不建议覆写的内部虚函数

无——全部虚函数均为接口契约面；析构为 protected（仅供派生类）。**实现者（`FScene`）需要给出全部 100 个纯虚方法的实现。**

## 六、生命周期

- 纯 C++ 接口：无 `UObject` 生命周期钩子。
- 实例由引擎创建并挂到 `UWorld`（实现方 `FScene` 由 Renderer 模块在渲染线程侧管理）；`StartFrame` / `EndFrame`（第 768 / 769 行）为逐帧驱动点；`Release()`（第 594 行）为显式释放入口。
- 逐帧时序与线程边界属 `flows/` 范畴（暂无渲染流程产物）。

## 七、派生类（范围内）

搜索边界：派生类搜索**仅覆盖本版纳入范围的 292 个模块**（Runtime 291 个 + `EnhancedInput` 插件）。搜索模式 `\bpublic\s+FSceneInterface\b`（`*.h`）：Runtime **1 命中 / 1 文件**；EnhancedInput **0 命中**。

| 派生类 | 位置 | 备注 |
|---|---|---|
| `FScene` | `Engine/Source/Runtime/Renderer/Private/ScenePrivate.h` 第 1624 行 | **唯一实现**（Private 头；类注释：渲染器模块私有的场景实现） |

> 扩展验证：`Engine/Source` 全树同样仅 1 命中；`Engine/Plugins` 全树 0 命中。

## 取数说明

| 断言 | 取数方式（相对基准：`Engine/Source`） |
|---|---|
| 文件 825 行、类体 119-825 | `[System.IO.File]::ReadAllLines(...).Count` + `^};` 检索 |
| 虚函数 166 条（纯虚 100） | 逐行通读统计（该环境工具 count 模式异常，口径已注明）；`^\s*virtual` 内容模式复核 ≥128 条不冲突 |
| 派生统计：Runtime 1 / EnhancedInput 0 | `Select-String -Pattern '\bpublic\s+FSceneInterface\b'`（`*.h`） |
| 全部行号引用 | 2026-10-10 对 UE 5.8.3 源码本机逐条核对 |

## 相关文档

- `modules/Renderer-结构.md` —— 唯一实现（`FScene`）所在模块（同批产出）
- `modules/Engine-结构.md` —— 本接口的定义模块
- `types/FRenderResource.md` —— 渲染资源生命周期基类
- `modules/RenderCore-结构.md` —— 下层渲染公共层
