> 引擎版本：UE 5.8.3 (Build 58210709)
> 源码根：Engine/Source
> 生成技能：ue-ai-index v1.0
> 生成时间：2026-10-10
> 校验状态：不适用（重组索引，非事实文档）

# UE5 引擎文档 · AI 检索索引

> 使用方式：先查「一、检索路由」定位产物与章节，再按路径读取；
> 「三/四/五」是高频锚点速查，可直接引用；「六」用于判断边界，防止外推。
> **样本量：21 篇——白名单 10 个模块全部覆盖；未覆盖范围见第六节，"零命中"不代表不存在。**

## 一、检索路由

**地基层（Core / CoreUObject）**

| 要查什么 | 去哪篇 | 关键章节 |
|---|---|---|
| Core 模块定位、目录、依赖三表、暴露面、生命周期 | `modules/Core-结构.md` | 一、二、三、四、五 |
| CoreUObject 模块（含 `SetupVerse()` 展开） | `modules/CoreUObject-结构.md` | 三、六 |
| `UObject` 继承链 / 生命周期钩子 / 派生边界 | `types/UObject.md` | 二、四、五、七 |
| `FName` 用法与 UEOps 比较机制 | `types/FName.md` | 三、四 |
| 对象创建主路径（`NewObject` 5 层 + 12 类分支） | `flows/UObject创建流程.md` | 四、六、七 |

**框架层（Engine / GameplayTags / EnhancedInput）**

| 要查什么 | 去哪篇 | 关键章节 |
|---|---|---|
| Engine 模块（双公开目录、专属依赖展开、入口行为） | `modules/Engine-结构.md` | 二、三、五、六 |
| `AActor` API / 生命周期 / 派生类（80 个） | `types/AActor.md` | 四、五、七 |
| GameplayTags 模块（含 `SetupIrisSupport` 展开） | `modules/GameplayTags-结构.md` | 三、六 |
| `FGameplayTag` 匹配语义与比较 | `types/FGameplayTag.md` | 四 |
| EnhancedInput 模块（Plugins 路径、无聚合头） | `modules/EnhancedInput-结构.md` | 二、三、六 |
| `UInputAction` 配置面（值类型 / 触发器 / 修饰器） | `types/UInputAction.md` | 四 |

**UI 层（SlateCore / Slate / UMG）**

| 要查什么 | 去哪篇 | 关键章节 |
|---|---|---|
| SlateCore（控件基类与声明式语法） | `modules/SlateCore-结构.md` | 三、四、六 |
| `SWidget` 基类 API 与 77 条虚函数分组 | `types/SWidget.md` | 四、五 |
| `SCompoundWidget`（自定义控件基类，含 `ChildSlot`） | `types/SCompoundWidget.md` | 四、五 |
| Slate（`FSlateApplication`、高层控件） | `modules/Slate-结构.md` | 四、六 |
| UMG（蓝图侧 UI 体系） | `modules/UMG-结构.md` | 三、四、六 |
| `UUserWidget` API / Native\* 覆写点 / 动画 | `types/UUserWidget.md` | 四、五 |

**渲染层（RHI / RenderCore）**

| 要查什么 | 去哪篇 | 关键章节 |
|---|---|---|
| RHI 抽象层（无自定义模块类；后端动态加载矩阵） | `modules/RHI-结构.md` | 三、五、六 |
| `FRHIResource` 引用计数与删除队列语义 | `types/FRHIResource.md` | 四、五、六 |
| RenderCore（RDG / Shader / 资源生命周期） | `modules/RenderCore-结构.md` | 三、四、六 |
| `FRenderResource` 的 Init/Release 覆写模型 | `types/FRenderResource.md` | 四、五、六 |

## 二、产物清单

| 产物 | 类型 | 一句话内容 | 校验状态 |
|---|---|---|---|
| `modules/Core-结构.md` | 模块 | 引擎最底层基础库 | 已校验（2026-10-10） |
| `modules/CoreUObject-结构.md` | 模块 | UObject 对象模型与反射系统 | 已校验（2026-10-10） |
| `modules/Engine-结构.md` | 模块 | 游戏框架与运行时核心（4,037 文件） | 已校验（2026-10-10） |
| `modules/GameplayTags-结构.md` | 模块 | 层级化标签基础设施 | 已校验（2026-10-10） |
| `modules/EnhancedInput-结构.md` | 模块 | 增强输入系统运行时（Plugins 下） | 已校验（2026-10-10） |
| `modules/SlateCore-结构.md` | 模块 | Slate 底层与控件基类层 | 已校验（2026-10-10） |
| `modules/Slate-结构.md` | 模块 | Slate 高层框架与控件集 | 已校验（2026-10-10） |
| `modules/UMG-结构.md` | 模块 | 蓝图侧 UI 体系 | 已校验（2026-10-10） |
| `modules/RHI-结构.md` | 模块 | 渲染硬件接口抽象 | 已校验（2026-10-10） |
| `modules/RenderCore-结构.md` | 模块 | RHI 之上的渲染公共层（RDG/Shader） | 已校验（2026-10-10） |
| `types/FName.md` | 类型 | 名称索引值类型 | 已校验（2026-10-10） |
| `types/UObject.md` | 类型 | 所有 UE 对象基类 | 已校验（2026-10-10） |
| `types/AActor.md` | 类型 | 场景实体基类 | 已校验（2026-10-10） |
| `types/FGameplayTag.md` | 类型 | 标签值类型 | 已校验（2026-10-10） |
| `types/UInputAction.md` | 类型 | 输入动作资产 | 已校验（2026-10-10） |
| `types/SWidget.md` | 类型 | Slate 控件基类 | 已校验（2026-10-10） |
| `types/SCompoundWidget.md` | 类型 | 复合控件基类 | 已校验（2026-10-10） |
| `types/UUserWidget.md` | 类型 | 用户控件基类 | 已校验（2026-10-10） |
| `types/FRHIResource.md` | 类型 | RHI 资源基类 | 已校验（2026-10-10） |
| `types/FRenderResource.md` | 类型 | 渲染线程资源基类 | 已校验（2026-10-10） |
| `flows/UObject创建流程.md` | 流程 | `NewObject` 主路径 | 已校验（2026-10-10） |

## 三、API 速查

| 想用 | 要点 | 位置 | 出处产物 |
|---|---|---|---|
| 创建对象 | `NewObject<T>(...)`（3 载重） | `.../CoreUObject/Public/UObject/UObjectGlobals.h` 行 1929-1993 | `flows/UObject创建流程.md` |
| FName 构造 / 比较 / 排序 | 三形态构造；`UEOpEquals`（行 808）合成 `==`；`FastLess`/`LexicalLess`（820/826） | `.../Core/Public/UObject/NameTypes.h` | `types/FName.md` |
| UObject 生命周期钩子 | `PostInitProperties`（226）→ `BeginDestroy`/`IsReadyForFinishDestroy`/`FinishDestroy`（361/368/382） | `.../CoreUObject/Public/UObject/Object.h` | `types/UObject.md` |
| Actor 位置 / 变换 | `GetActorLocation`（2502）/ `SetActorLocation`（1636）/ `GetActorTransform`（2496） | `.../Engine/Classes/GameFramework/Actor.h` | `types/AActor.md` |
| Actor 生命周期 | `BeginPlay`（2125）/ `EndPlay`（2132）/ `Tick`（3060）/ `Destroy`（2327）/ `PrimaryActorTick`（318） | 同上 | `types/AActor.md` |
| 标签查询 | `RequestGameplayTag`（57）/ `MatchesTag`（91）/ `MatchesAny`（126）/ `IsValid`（138） | `.../GameplayTags/Classes/GameplayTagContainer.h` | `types/FGameplayTag.md` |
| 输入动作配置 | `ValueType`（115-116）/ `Triggers`（134-135）/ `Modifiers`（144-145） | `.../EnhancedInput/Public/InputAction.h` | `types/UInputAction.md` |
| 自定义控件基类 | `ChildSlot`（113）；覆写 `OnPaint`（78）/`ComputeDesiredSize`（88） | `.../SlateCore/Public/Widgets/SCompoundWidget.h` | `types/SCompoundWidget.md` |
| 控件基类虚函数组 | 布局（`ComputeDesiredSize` 774）/ 绘制（`OnPaint` 1771）/ 输入（`OnKeyDown` 357 起） | `.../SlateCore/Public/Widgets/SWidget.h` | `types/SWidget.md` |
| 用户控件 | `AddToViewport`（342）/ `GetWidgetFromName`（1426）/ `NativeConstruct`（1584）/ `PlayAnimation`（1193） | `.../UMG/Public/Blueprint/UserWidget.h` | `types/UUserWidget.md` |
| RHI 资源引用 | `AddRef`（73）/ `Release`（80）/ `GetRefCount`（93）；只能经删除队列销毁 | `.../RHI/Public/RHIResources.h` | `types/FRHIResource.md` |
| 渲染资源初始化 | `BeginInitResource`（218）→ `InitResource`（96）→ `InitRHI`（83） | `.../RenderCore/Public/RenderResource.h` | `types/FRenderResource.md` |
| 模块入口参考 | `FCoreModule`；`FCoreUObjectModule`；`FEngineModule`（UnrealEngine.cpp 294）；`FSlateCoreModule`（`UE::` 命名空间） | 各 `modules/*-结构.md` 五 | 各模块文档 |

## 四、约定与坑

| # | 约定 / 坑 | 出处产物 |
|---|---|---|
| 1 | `TMap`/`TSet`/`FString` 宏注入式定义——字面搜 `class TMap` 零命中属预期 | `modules/Core-结构.md` 六 |
| 2 | Core 依赖表重复项勿去重（`AtomicQueue`/`AutoRTFM`） | `modules/Core-结构.md` 3.1 |
| 3 | Core 的 `Internal/` 不是公开边界 | `modules/Core-结构.md` 六 |
| 4 | 不存在 `Logging/Log.h` | `modules/Core-结构.md` 六 |
| 5 | `UObject` 类在 `Object.h`（无 `UObject.h`）；类声明无类级导出宏 | `modules/CoreUObject-结构.md` 六 |
| 6 | `CollectGarbage` 在 `UObjectGlobals.h` 行 952，不在 `GarbageCollection.h` | `modules/CoreUObject-结构.md` 六 |
| 7 | `SetupVerse()` / `SetupIrisSupport()` / `SetupModulePhysicsSupport()` 会追加依赖（函数体在 UBT `ModuleRules.cs`） | CoreUObject / GameplayTags / Engine 三篇 |
| 8 | CoreUObject 的 `libpas` 条件由 `GlobalDefinitions` 判断 | `modules/CoreUObject-结构.md` 六 |
| 9 | FName 无 `operator==` 字面定义（UEOps 合成）；排序运算符被删除 | `types/FName.md` 三、四 |
| 10 | FName 默认构造 `ToString()` 是 `"None"`；`UE_FNAME_OUTLINE_NUMBER` 改变布局 | `types/FName.md` 一、四 |
| 11 | FName 未声明 `final`——"不应被继承"≠"不可被继承" | `types/FName.md` 七 |
| 12 | `UObject::FinishDestroy()` 的 `Super::` 调用必须在子类方法末尾 | `types/UObject.md` 5.1 |
| 13 | UObject/AActor 派生统计有边界（Runtime + EnhancedInput） | 对应两篇 七 |
| 14 | `PostInitProperties` 由 `~FObjectInitializer` 驱动，在构造函数链**之后** | `flows/UObject创建流程.md` 4.3 |
| 15 | Engine 公开侧是 `Classes/` + `Public/` 双目录；**`Classes/EngineMinimal.h` 不存在**（聚合头在 `Public/`） | `modules/Engine-结构.md` 六 |
| 16 | Engine 的 Win64 分支（469-474）两处 Add 全被注释——零生效依赖 | `modules/Engine-结构.md` 六 |
| 17 | `Engine` ↔ `GameplayTags` 互为公开依赖（循环，Engine 侧列入 `CircularlyReferencedDependentModules`） | 两篇 3.1/六 |
| 18 | `FGameplayTag` 用 `GENERATED_USTRUCT_BODY()`（不是 `GENERATED_BODY()`） | `modules/GameplayTags-结构.md` 六 |
| 19 | EnhancedInput 在 **Plugins** 下；类无类级导出宏（`#define UE_API ENHANCEDINPUT_API`）；无聚合头 | `modules/EnhancedInput-结构.md` 六 |
| 20 | `SWidget`/`SCompoundWidget`/`SWindow` 等在 **SlateCore** 而非 Slate | `modules/Slate-结构.md` 六 |
| 21 | `SWidget` 头文件第 143 行警示不要直接继承；`OnPaint`/`OnArrangeChildren` 为 private 虚 | `types/SWidget.md` 五 |
| 22 | UMG 无 `class UMG_API ...` 形式（MinimalAPI + 成员宏）；`SlateWrapperTypes.h` 在 `Components/` 下 | `modules/UMG-结构.md` 六 |
| 23 | RHI 无自定义模块类（`IMPLEMENT_MODULE(FDefaultModuleImpl, RHI)`）；`RHIStaticStates.h` 在 RenderCore、`RHIPipelineState.h` 不存在 | `modules/RHI-结构.md` 五、六 |
| 24 | `FRenderResource` 不继承 `FDeferredCleanupInterface`；重建入口 `UpdateRHI()` 非虚 | `types/FRenderResource.md` 二、五 |
| 25 | `FRHIResource` 只能经删除队列销毁（不要直接 `delete`） | `types/FRHIResource.md` 五、六 |

## 五、流程锚点

`UObject` 创建（`NewObject` 主路径，5 层；出处 `flows/UObject创建流程.md`）：

- 入口 `NewObject<T>()`：`Engine/Source/Runtime/CoreUObject/Public/UObject/UObjectGlobals.h` 行 1929-1993
- 主调度 `StaticConstructObject_Internal`：`.../Private/UObject/UObjectGlobals.cpp` 行 4803-4875
- 分配注册 `StaticAllocateObject`：行 3431-3838（自动命名 3509；查重 3516；分配 3564；placement new 3766-3771）
- 全局注册 `UObjectBase::AddObject`：`.../Private/UObject/UObjectBase.cpp` 行 169
- 构造函数分派：`(*ClassConstructor)(FObjectInitializer(...))` 行 4851
- 收尾驱动 `~FObjectInitializer`：行 4026-4131 → `PostConstructInit` 行 4134-4376
- 扩展点调用：`PostInitProperties` 行 4320；`PostInitInstance` 行 4342
- 未覆盖分支：12 类中 10 类未展开，见产物第七节

## 六、覆盖与空缺

**已覆盖**（21 篇）：

- 模块 **10/10**（白名单全部）：`Core`、`CoreUObject`、`Engine`、`GameplayTags`、`EnhancedInput`、`SlateCore`、`Slate`、`UMG`、`RHI`、`RenderCore`
- 类型 10 个：每模块一个代表类型（约定：未穷尽各模块其余类）
- 流程 1 条：`NewObject` 主路径

**未覆盖（防止外推）**：

- **白名单之外**：引擎共 2,403 个模块、纳入范围 292 个；Editor / Developer / Platforms / 未纳入 Plugins **全部未覆盖**；第二批候选（`Renderer`、`MovieScene`、`Net`、`AIModule`、`NavigationSystem`、`PhysicsCore`、`GameplayTasks`、`DeveloperSettings`）未开跑
- **各模块的其余类型**未成篇（代表类型约定）——需要时按类名用 ③ 现产
- `flows/UObject创建流程.md`：12 类关键分支中 10 类未展开；蓝图构造脚本执行点未定位——**不可推断"蓝图无构造脚本"**
- `types/UUserWidget.md`：多数派生类在 Editor/Plugins（范围外）——范围内真实派生仅 1 个
- `types/SCompoundWidget.md` 与 `types/FRenderResource.md`：派生清单为统计 + 代表类（全量按各篇取数说明命令复现）
- 渲染侧**无流程产物**（RHI/RDG 的调用链未追踪）
- **样本量**：21 篇；后续新增产物后需重跑 ⑥
