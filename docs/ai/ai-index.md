> 引擎版本：UE 5.8.3 (Build 58210709)
> 源码根：Engine/Source
> 生成技能：ue-ai-index v1.0
> 生成时间：2026-10-10
> 校验状态：不适用（重组索引，非事实文档）

# UE5 引擎文档 · AI 检索索引

> 使用方式：先查「一、检索路由」定位产物与章节，再按路径读取；
> 「三/四/五」是高频锚点速查，可直接引用；「六」用于判断边界，防止外推。
> **样本量：69 篇——白名单 10 + 第二批 8 + 第三批 8 + 第四批 8，共 34 个模块已覆盖；未覆盖范围见第六节，"零命中"不代表不存在。**

## 一、检索路由

**① 地基层（Core / CoreUObject）**

| 要查什么 | 去哪篇 | 关键章节 |
|---|---|---|
| Core 模块定位、依赖三表、暴露面、生命周期 | `modules/Core-结构.md` | 一、二、三、四、五 |
| CoreUObject 模块（含 `SetupVerse()` 展开） | `modules/CoreUObject-结构.md` | 三、六 |
| `UObject` 继承链 / 生命周期钩子 / 派生边界 | `types/UObject.md` | 二、四、五、七 |
| `FName` 用法与 UEOps 比较机制 | `types/FName.md` | 三、四 |
| 对象创建主路径（`NewObject` 5 层 + 12 类分支） | `flows/UObject创建流程.md` | 四、六、七 |

**② 游戏框架（Engine / GameplayTags / EnhancedInput / GameplayTasks / AIModule / NavigationSystem / Navmesh）**

| 要查什么 | 去哪篇 | 关键章节 |
|---|---|---|
| Engine 模块（双公开目录、专属依赖展开、入口行为） | `modules/Engine-结构.md` | 二、三、五、六 |
| `AActor` API / 生命周期 / 派生类（80 个） | `types/AActor.md` | 四、五、七 |
| GameplayTags 模块 / `FGameplayTag` 匹配语义 | `modules/GameplayTags-结构.md`、`types/FGameplayTag.md` | 三/六、四 |
| EnhancedInput 模块 / `UInputAction` 配置面 | `modules/EnhancedInput-结构.md`、`types/UInputAction.md` | 二/三/六、四 |
| GameplayTasks 模块 / `UGameplayTask` 生命周期 | `modules/GameplayTasks-结构.md`、`types/UGameplayTask.md` | 三/四/六、四/五 |
| AIModule 模块 / `AAIController`（45 虚函数分组） | `modules/AIModule-结构.md`、`types/AAIController.md` | 三/五/六、四/五 |
| NavigationSystem 模块 / `UNavigationSystemV1` | `modules/NavigationSystem-结构.md`、`types/UNavigationSystemV1.md` | 三/五/六、四/五 |
| Navmesh 模块（Recast/Detour）/ `ARecastNavMesh` | `modules/Navmesh-结构.md`、`types/ARecastNavMesh.md` | 三/四/六、四/五/七 |

**③ 序列 / 时间与设置（MovieScene / MovieSceneTracks / LevelSequence / TimeManagement / UniversalObjectLocator / DeveloperSettings）**

| 要查什么 | 去哪篇 | 关键章节 |
|---|---|---|
| MovieScene 模块 / `UMovieSceneSequence` 绑定契约 | `modules/MovieScene-结构.md`、`types/UMovieSceneSequence.md` | 三/四/六、四/五/七 |
| MovieSceneTracks 模块 / `UMovieScene3DTransformTrack` | `modules/MovieSceneTracks-结构.md`、`types/UMovieScene3DTransformTrack.md` | 三/四/六、四/五/七 |
| LevelSequence 模块 / `ULevelSequence` 资产与 MetaData | `modules/LevelSequence-结构.md`、`types/ULevelSequence.md` | 三/四/六、四/五/七 |
| TimeManagement 模块（时间步/时间码提供者/估算） | `modules/TimeManagement-结构.md` | 四、五、六 |
| `FFrameRate` 帧率值类型（**归属 Core**） | `types/FFrameRate.md` | 四、五、七 |
| UniversalObjectLocator 模块（对象定位器框架） | `modules/UniversalObjectLocator-结构.md` | 四、五、六 |
| `FUniversalObjectLocator` 解析/文本化 | `types/FUniversalObjectLocator.md` | 四、六、七 |
| DeveloperSettings 模块 / `UDeveloperSettings` | `modules/DeveloperSettings-结构.md`、`types/UDeveloperSettings.md` | 三/四/六、四/五 |

**④ 输入与 UI（InputCore / SlateCore / Slate / UMG / SlateRHIRenderer）**

| 要查什么 | 去哪篇 | 关键章节 |
|---|---|---|
| InputCore 模块 / `FKey` 键值 | `modules/InputCore-结构.md`、`types/FKey.md` | 三/四/六、四/五 |
| SlateCore 模块 / `SWidget` / `SCompoundWidget` | `modules/SlateCore-结构.md`、`types/SWidget.md`、`types/SCompoundWidget.md` | 三/四/六、四/五 |
| Slate 模块 / UMG 模块 / `UUserWidget` | `modules/Slate-结构.md`、`modules/UMG-结构.md`、`types/UUserWidget.md` | 四/六、三/四/六、四/五 |
| SlateRHIRenderer 模块 / `FSlateElementBatcher` 批处理 | `modules/SlateRHIRenderer-结构.md`、`types/FSlateElementBatcher.md` | 二/三/五/六、四/五/六 |

**⑤ 网络与物理（NetCore / NetCommon / IrisCore / Sockets / PacketHandler / Chaos / PhysicsCore）**

| 要查什么 | 去哪篇 | 关键章节 |
|---|---|---|
| NetCore 模块 / `FFastArraySerializer` | `modules/NetCore-结构.md`、`types/FFastArraySerializer.md` | 三/四/六、四/五 |
| NetCommon 模块 / `FPacketDataView` 包视图 | `modules/NetCommon-结构.md`、`types/FPacketDataView.md` | 二/四/六、四/五 |
| IrisCore 模块 / `UReplicationSystem` | `modules/IrisCore-结构.md`、`types/UReplicationSystem.md` | 三/四/六、四/五/七 |
| Sockets 模块（平台套接字层） / `FSocket`（29 纯虚契约） | `modules/Sockets-结构.md`、`types/FSocket.md` | 三/四/五/六、四/五/七 |
| PacketHandler 模块（处理组件链） / `PacketHandler` 容器 | `modules/PacketHandler-结构.md`、`types/PacketHandler.md` | 四、五、六、四/五/七 |
| Chaos 模块 / `FImplicitObject` 隐式几何 | `modules/Chaos-结构.md`、`types/FImplicitObject.md` | 三/四/六、四/五/七 |
| PhysicsCore 模块 / `UPhysicalMaterial` | `modules/PhysicsCore-结构.md`、`types/UPhysicalMaterial.md` | 三/四/六、四/五 |

**⑥ 渲染（RHI / RenderCore / Renderer）**

| 要查什么 | 去哪篇 | 关键章节 |
|---|---|---|
| RHI 抽象层 / `FRHIResource` 引用计数 | `modules/RHI-结构.md`、`types/FRHIResource.md` | 三/五/六、四/五/六 |
| RenderCore（RDG/Shader）/ `FRenderResource` | `modules/RenderCore-结构.md`、`types/FRenderResource.md` | 三/四/六、四/五/六 |
| Renderer 模块 / `FSceneInterface`（Engine 定义） | `modules/Renderer-结构.md`、`types/FSceneInterface.md` | 二/三/五/六、四/五/七 |

**⑦ 音频与动画（AudioMixer / AudioExtensions / AnimationCore / AnimGraphRuntime）**

| 要查什么 | 去哪篇 | 关键章节 |
|---|---|---|
| AudioMixer 模块（音频渲染核心） / `FMixerDevice` | `modules/AudioMixer-结构.md`、`types/FMixerDevice.md` | 三/四/五/六、四/五/七 |
| AudioExtensions 模块（扩展契约层） / `IAudioEndpoint` | `modules/AudioExtensions-结构.md`、`types/IAudioEndpoint.md` | 四、五、六、四/五/七 |
| AnimationCore 模块（基础类型/IK 算法声明） / `FEulerTransform` | `modules/AnimationCore-结构.md`、`types/FEulerTransform.md` | 三/四/五/六、四/六/七 |
| AnimGraphRuntime 模块（节点库） / `FAnimNode_BlendSpacePlayer` | `modules/AnimGraphRuntime-结构.md`、`types/FAnimNode_BlendSpacePlayer.md` | 三/四/五/六、四/五/七 |

## 二、产物清单

**模块文档（34）**

| 产物 | 一句话 | 校验 |
|---|---|---|
| `modules/Core-结构.md`、`modules/CoreUObject-结构.md` | 底层基础库 / 对象模型与反射 | 已校验（2026-10-10） |
| `modules/Engine-结构.md` | 游戏框架与运行时核心 | 已校验（2026-10-10） |
| `modules/GameplayTags-结构.md`、`modules/EnhancedInput-结构.md` | 标签 / 增强输入 | 已校验（2026-10-10） |
| `modules/GameplayTasks-结构.md`、`modules/AIModule-结构.md` | 异步任务 / AI 框架 | 已校验（2026-10-10） |
| `modules/NavigationSystem-结构.md`、`modules/Navmesh-结构.md` | 导航系统 / Recast 实现层 | 已校验（2026-10-10） |
| `modules/MovieScene-结构.md`、`modules/MovieSceneTracks-结构.md` | 序列数据模型 / 轨道实现 | 已校验（2026-10-10） |
| `modules/LevelSequence-结构.md`、`modules/TimeManagement-结构.md` | 关卡序列 / 时间设施 | 已校验（2026-10-10） |
| `modules/UniversalObjectLocator-结构.md`、`modules/DeveloperSettings-结构.md` | 对象定位器 / 设置基础 | 已校验（2026-10-10） |
| `modules/InputCore-结构.md`、`modules/SlateCore-结构.md` | 输入基础 / Slate 底层 | 已校验（2026-10-10） |
| `modules/Slate-结构.md`、`modules/UMG-结构.md`、`modules/SlateRHIRenderer-结构.md` | Slate 高层 / UMG / Slate RHI 后端 | 已校验（2026-10-10） |
| `modules/RHI-结构.md`、`modules/RenderCore-结构.md`、`modules/Renderer-结构.md` | 三层渲染栈 | 已校验（2026-10-10） |
| `modules/NetCore-结构.md`、`modules/NetCommon-结构.md`、`modules/IrisCore-结构.md` | 网络三兄弟 | 已校验（2026-10-10） |
| `modules/Sockets-结构.md`、`modules/PacketHandler-结构.md` | 平台套接字 / 处理组件链 | 已校验（2026-10-10） |
| `modules/Chaos-结构.md`、`modules/PhysicsCore-结构.md` | 物理求解器 / 引擎物理接口 | 已校验（2026-10-10） |
| `modules/AudioMixer-结构.md`、`modules/AudioExtensions-结构.md` | 音频渲染核心 / 扩展契约 | 已校验（2026-10-10） |
| `modules/AnimationCore-结构.md`、`modules/AnimGraphRuntime-结构.md` | 动画基础类型 / 节点运行时 | 已校验（2026-10-10） |

**类型文档（34）**

| 产物 | 一句话 | 校验 |
|---|---|---|
| `types/FName.md`、`types/UObject.md`、`types/AActor.md` | 名称 / 对象 / 场景实体 | 已校验（2026-10-10） |
| `types/FGameplayTag.md`、`types/UInputAction.md`、`types/UGameplayTask.md` | 标签 / 输入动作 / 异步任务 | 已校验（2026-10-10） |
| `types/AAIController.md`、`types/UNavigationSystemV1.md`、`types/ARecastNavMesh.md` | AI 控制器 / 导航系统 / 导航数据 Actor | 已校验（2026-10-10） |
| `types/UMovieSceneSequence.md`、`types/UMovieScene3DTransformTrack.md`、`types/ULevelSequence.md` | 序列基类 / 3D 变换轨道 / 关卡序列资产 | 已校验（2026-10-10） |
| `types/FFrameRate.md`、`types/FUniversalObjectLocator.md`、`types/UDeveloperSettings.md` | 帧率（Core）/ 对象定位器 / 设置基类 | 已校验（2026-10-10） |
| `types/FKey.md`、`types/SWidget.md`、`types/SCompoundWidget.md`、`types/UUserWidget.md` | 键值 / Slate 控件 | 已校验（2026-10-10） |
| `types/FSlateElementBatcher.md`、`types/FRHIResource.md`、`types/FRenderResource.md`、`types/FSceneInterface.md` | 批处理 / 渲染资源 / 场景接口 | 已校验（2026-10-10） |
| `types/FFastArraySerializer.md`、`types/FPacketDataView.md`、`types/UReplicationSystem.md` | 增量数组复制 / 包视图 / Iris 系统 | 已校验（2026-10-10） |
| `types/FSocket.md`、`types/PacketHandler.md` | 套接字抽象 / 处理组件链容器 | 已校验（2026-10-10） |
| `types/FImplicitObject.md`、`types/UPhysicalMaterial.md` | 隐式几何 / 物理材质 | 已校验（2026-10-10） |
| `types/FMixerDevice.md`、`types/IAudioEndpoint.md` | 混合器设备 / 音频端点 | 已校验（2026-10-10） |
| `types/FEulerTransform.md`、`types/FAnimNode_BlendSpacePlayer.md` | 欧拉变换 / 混合空间播放节点 | 已校验（2026-10-10） |

**流程文档（1）**

| 产物 | 一句话 | 校验 |
|---|---|---|
| `flows/UObject创建流程.md` | `NewObject` 主路径 | 已校验（2026-10-10） |

## 三、API 速查

| 想用 | 要点 | 位置 | 出处产物 |
|---|---|---|---|
| 创建对象 | `NewObject<T>(...)`（3 载重） | `.../CoreUObject/Public/UObject/UObjectGlobals.h` 行 1929-1993 | `flows/UObject创建流程.md` |
| FName / UObject 生命周期 | `UEOpEquals`（808）；`PostInitProperties`（226）→ `FinishDestroy`（382） | `NameTypes.h`；`Object.h` | `types/FName.md`、`types/UObject.md` |
| Actor / AI / 导航 | `GetActorLocation`（2502）；`RunBehaviorTree`（262）；`FindPath`（1444） | `Actor.h`；`AIController.h`；`RecastNavMesh.h` | 对应 3 篇类型文档 |
| 任务 / 序列 / 设置 | `ReadyForActivation`（157）；`GetMovieScene`（217）；`CreateNewSection`（68）；`FindOrAddMetaDataByClass`（195） | 四篇类型文档对应位置 | `types/*.md` |
| 帧率换算 | `AsDecimal`（65）/ `AsFrameTime`（81）/ `TransformTime`（109 静态） | `.../Core/Public/Misc/FrameRate.h` | `types/FFrameRate.md` |
| 对象定位器 | `Resolve`（70）/ `SyncFind`（106）/ `FromString`（160 静态工厂） | `.../UniversalObjectLocator/Public/UniversalObjectLocator.h` | `types/FUniversalObjectLocator.md` |
| 键值 / UI 批处理 | `GetFName`（91）/ `IsGamepadKey`（74）；`AddElements`（257）/ `ResetBatches`（280） | `InputCoreTypes.h`；`ElementBatcher.h` | `types/FKey.md` 等 |
| 增量数组 / 包视图 / Iris | `MarkItemDirty`（441）；`NumBits`（96）；`NetUpdate`（238）/ `SendRPC`（426） | 对应头文件 | 4 篇类型文档 |
| 套接字 | `Send`（190）/ `Recv`（221）/ `Close`（93 纯虚） | `.../Sockets/Public/Sockets.h` | `types/FSocket.md` |
| 处理组件链 | `Tick`（315）/ `IncomingHigh`（350）/ `AddHandler`（323）；组件 `Initialize`（865 纯虚） | `.../PacketHandler/Public/PacketHandler.h` | `types/PacketHandler.md` |
| 隐式几何 / 物理材质 | `PhiWithNormal`（251 纯虚）/ `GetTypeHash`（412 纯虚）；`DetermineSurfaceType`（242） | `ImplicitObject.h`；`PhysicalMaterial.h` | 2 篇类型文档 |
| 音频设备 / 端点 | `GetAudioMixerPlatform`（268）/ `AudioRenderThreadCommand`（356）；`OnAudioCallback`（140 虚） | `AudioMixerDevice.h`；`IAudioEndpoint.h` | 2 篇类型文档 |
| 欧拉变换 / 动画节点 | `ToFTransform`（84）/ `FromFTransform`（90）；`SetBlendSpace`（206）/ `SetPosition`（207） | `EulerTransform.h`；`AnimNode_BlendSpacePlayer.h` | 2 篇类型文档 |
| 模块入口参考 | `FRendererModule`（true）；三个 `false`（NetCore/IrisCore/NetCommon）+ Socket `false`；`FDefaultModuleImpl`（Navmesh / AnimationCore）；零覆写（TimeManagement） | 各 `modules/*-结构.md` 五 | 各模块文档 |

## 四、约定与坑

| # | 约定 / 坑 | 出处产物 |
|---|---|---|
| 1 | `TMap`/`TSet`/`FString` 宏注入式定义——字面搜 `class TMap` 零命中属预期 | `modules/Core-结构.md` |
| 2 | Core 依赖表重复项勿去重；`Internal/` 不是公开边界；`CollectGarbage` 在 `UObjectGlobals.h`（952） | Core / CoreUObject 两篇 六 |
| 3 | `UObject` 类在 `Object.h`；类声明无类级导出宏 | `modules/CoreUObject-结构.md` 六 |
| 4 | `SetupVerse()` / `SetupIrisSupport()` / `SetupModulePhysicsSupport()` / `SetupGameplayDebuggerSupport()` / `SetupModuleChaosVisualDebuggerSupport()` 会追加依赖或宏（UBT `ModuleRules.cs`） | 多篇 |
| 5 | FName 无 `operator==` 字面定义；`FinishDestroy()` 的 `Super::` 必须在末尾 | `types/FName.md`、`types/UObject.md` |
| 6 | Engine 公开侧 `Classes/` + `Public/` 双目录；不推荐裸写 `Engine/Classes/…` 引路径（解析歧义） | `modules/Engine-结构.md` 六 |
| 7 | `FGameplayTag` 用 `GENERATED_USTRUCT_BODY()`；EnhancedInput 在 Plugins 下且无类级导出宏 | GameplayTags / EnhancedInput 各篇 |
| 8 | `SWidget`/`SCompoundWidget`/`SWindow` 在 SlateCore；`SWidget` 头警示不要直接继承；UMG 无类级 API 宏形式 | Slate / UMG 各篇 |
| 9 | RHI 无自定义模块类；`FRenderResource` 不继承 `FDeferredCleanupInterface`；`FRHIResource` 只能经删除队列销毁 | RHI / RenderCore 各篇 |
| 10 | `FSceneInterface`/`FSceneView`/`FPrimitiveSceneProxy` 在 **Engine**；`FSceneRenderer` 在 Renderer/Private；Renderer 是首个热重载 `true` 覆写者 | `modules/Renderer-结构.md`、`types/FSceneInterface.md` |
| 11 | `NetCore` 路径 `Runtime/Net/Core`；`FNetBitReader` 等在 CoreUObject；NetCore/IrisCore/NetCommon 均显式 `false` 热重载 | Net 三篇 五、六 |
| 12 | `UPhysicalMaterialCore` **不存在**；`FPhysScene_Chaos`/`FPhysInterface_Chaos` 在 Engine | PhysicsCore 两篇 六 |
| 13 | GameplayTasks：`Classes/`+`Public/` 双目录；`UGameplayTask_TimeLimitedAction` 不存在；`UGameplayTask` 无蓝图事件 | GameplayTasks 两篇 |
| 14 | AIModule 公开侧在 `Classes/`；`UPawnSensingComponent` 5.5 起废弃；Startup/Shutdown 调试分类注册不对称 | `modules/AIModule-结构.md` 六 |
| 15 | `UNavigationSystemBase` 在 Engine；`UNavigationSystemV1` 是 `Within=World`；`RegisterNavData` 是 protected | NavigationSystem 两篇 |
| 16 | **`UMovieScene` 不是 `UMovieSceneSequence` 派生类**；`GetPlaybackRange` 在 UMovieScene；`Public/MovieScenePlayer.h` 不存在 | MovieScene 两篇 |
| 17 | `UPlatformSettings` 等**不**派生 `UDeveloperSettings`；设置头都在 `Public/Engine/` 子目录 | DeveloperSettings 两篇 |
| 18 | `FFastArraySerializer` 回调故意非虚；`NetDeltaSerialize` 子类自写；`Items` 在子类 | `types/FFastArraySerializer.md` |
| 19 | **Chaos 路径含 `Experimental/`**；`FPBDRigidsEvolution`/`FPhysicsSolver`/`FGeometryParticleHandle` 是别名；`PBDRigidsSolver.h` 在 Public 顶层 | `modules/Chaos-结构.md` 六 |
| 20 | `FImplicitObject` 44 虚函数、2 纯虚；`Support` 只在派生几何类；`GetLocalBounds` 不存在 | `types/FImplicitObject.md` |
| 21 | Navmesh **无自定义模块类**；`Public/` 顶层 0 个 .h；Recast 为 `.tps` 源码内嵌（v1.4.2） | `modules/Navmesh-结构.md` 六 |
| 22 | **`ARecastNavMesh` 归属 NavigationSystem**；`GetConfig` 在基类（657）；`GetDebugGeometry` 不存在 | `types/ARecastNavMesh.md` |
| 23 | NetCommon **无导出宏、无反射**；无达标类型（放宽取 `FPacketDataView` 59 行） | `modules/NetCommon-结构.md` 六 |
| 24 | IrisCore 路径 `Net/Iris`；`UReplicationSystem`/`UReplicationBridge` 在全局而 `FNetSerializer` 等在 `UE::Net` | `modules/IrisCore-结构.md` 六 |
| 25 | `UReplicationSystem` **0 虚函数**；扩展经 `FReplicationSystemFactory`（939）与注册式子对象 | `types/UReplicationSystem.md` |
| 26 | `UMovieScene3DTransformTrack` 用 `GENERATED_UCLASS_BODY()`；类内 public 仅 9 条 | `types/UMovieScene3DTransformTrack.md` |
| 27 | MovieSceneTracks：轨道在 `Public/Tracks/`、段在 `Public/Sections/`；`MovieSceneTracksModule.h` 不存在 | `modules/MovieSceneTracks-结构.md` 六 |
| 28 | LevelSequence 接口是 `ILevelSequenceModule.h`；模块类混入 `FSelfRegisteringExec`；Startup 向 CDO 注入 MetaData | `modules/LevelSequence-结构.md` 六 |
| 29 | `ULevelSequence` 用 `GENERATED_UCLASS_BODY()`；35 虚函数；范围内派生 0（Plugins 内 2） | `types/ULevelSequence.md` |
| 30 | **`FKey` 在 `Classes/`**；InputCore **未覆写 ShutdownModule**；`FInputDeviceId` 在 Core（518） | `modules/InputCore-结构.md`、`types/FKey.md` |
| 31 | SlateRHIRenderer 公开仅 7 头；实现类在 `Private/`；模块类仅存在于 `.cpp`；私有依赖含 `Renderer` | `modules/SlateRHIRenderer-结构.md` 六 |
| 32 | **`FSlateElementBatcher` 归属 SlateCore**（0 虚函数，扩展经渲染策略）；`FSlateFontCache` 同 | `types/FSlateElementBatcher.md` |
| 33 | 前序批次既有约定（派生边界、Plugins 归属、命名陷阱等）沿用上版（第 1–32 条） | 前 53 篇产物 |
| 34 | **帧率/时间码基础类型在 Core**（`Misc/FrameRate.h` 等）；TimeManagement **零生命周期覆写**（有模块类但不覆写 Startup/Shutdown） | `modules/TimeManagement-结构.md` 六 |
| 35 | `FFrameRate` 无 `GetFrameCount`/`IsNormalized`；唯一派生 `FLiveLinkFrameRate` 4.20 起弃用；反射镜像在 `NoExportTypes.h`（2175） | `types/FFrameRate.md` 四、七 |
| 36 | UOL 公开 **17** 头（非 18）；注册表类名是 **`FRegistry`**（Private；非 `FUniversalObjectLocatorRegistry`）；`FResolveParams`/`FInitializeParams` 无前缀 | `modules/UniversalObjectLocator-结构.md` 六 |
| 37 | `FUniversalObjectLocator` 无 `Serialize`/`IsValid`/`MakeRoot`——序列化走 traits 钩子（ExportTextItem 等 234-236） | `types/FUniversalObjectLocator.md` 四、六 |
| 38 | AudioMixer：`AudioMixerSource.h` 在 **Private**；`IAudioMixerPlatformInterface` 在 **AudioMixerCore**；含 5 个三方静态库；`ShutdownModule` 未覆写 | `modules/AudioMixer-结构.md` 六 |
| 39 | **`IAudioExtensionPlugin` 只是头文件名**（无同名类型）；模块头文件名拼写为 `AudioExtentionsModule.h` | `modules/AudioExtensions-结构.md` 六 |
| 40 | `FMixerDevice` 非 UObject（65 虚函数、三基类 `FAudioDevice`/`IAudioMixer`/`FGCObject`）；`IAudioEndpoint` 为本批音频侧代表类型（工厂族均 < 60 行） | `types/FMixerDevice.md`、`types/IAudioEndpoint.md` |
| 41 | **`FSocket` 在 `Sockets.h`**（无 `FSocket.h`）；Sockets 双 `false`（热重载 + 自动关停）；29 纯虚是平台实现者契约 | `modules/Sockets-结构.md`、`types/FSocket.md` |
| 42 | **`FPacketHandler`/`FPacketHandlerComponent` 不存在**——类是 `PacketHandler`/`HandlerComponent`（无前缀）；模块根在 `Runtime/PacketHandlers/` 分组目录下 | `modules/PacketHandler-结构.md` 六 |
| 43 | `PacketHandler` 容器类 0 虚函数——多态在 `HandlerComponent`（`IsValid`/`Initialize` 纯虚）；虚函数族行 757-872 | `types/PacketHandler.md` 五 |
| 44 | AnimationCore **第 2 个 `FDefaultModuleImpl` 模块**；`SkeletonPose.h` 不存在；`FBoneIndices` 非公开类型 | `modules/AnimationCore-结构.md` 六 |
| 45 | `FAnimNode_SequencePlayer`/`FAnimNode_Base`/`FAnimInstanceProxy` 均在 **Engine**；AnimGraphRuntime 提供叶子节点（`FAnimNode_BlendSpacePlayer` 基类链 4 级在 Engine） | `modules/AnimGraphRuntime-结构.md` 四、`types/FAnimNode_BlendSpacePlayer.md` 二 |

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

**已覆盖**（69 篇）：

- **模块 34 个**：白名单 10 + 第二批 8（`Renderer`、`GameplayTasks`、`AIModule`、`NavigationSystem`、`MovieScene`、`DeveloperSettings`、`NetCore`、`PhysicsCore`）+ 第三批 8（`MovieSceneTracks`、`LevelSequence`、`IrisCore`、`NetCommon`、`Chaos`、`Navmesh`、`InputCore`、`SlateRHIRenderer`）+ 第四批 8（`TimeManagement`、`UniversalObjectLocator`、`AudioMixer`、`AudioExtensions`、`Sockets`、`PacketHandler`、`AnimationCore`、`AnimGraphRuntime`）
- 类型 34 个（每模块一个代表类型；4 篇为随批跨模块归属：`FSceneInterface`→Engine、`ARecastNavMesh`→NavigationSystem、`FSlateElementBatcher`→SlateCore、`FFrameRate`→Core，均如实标注）
- 流程 1 条

**未覆盖（防止外推）**：

- **第四批之外**：引擎共 2,403 个模块、纳入范围 292 个（覆盖 **34/292**）；Editor / Developer / Platforms / 未纳入 Plugins **全部未覆盖**
- **第五批候选（未开跑）**：`GeometryCore`/`GeometryFramework`、`AssetRegistry`、`MassEntity`、`MediaUtils`/`MediaAssets`、`MovieSceneCapture`、`ChaosCore`/`ChaosSolverEngine`、`Landscape`/`Foliage`、`dtNavMesh` 补篇等
- **Plugins 未纳入**：`GameplayAbilities`（GAS）、`TemplateSequence`、`TimedDataMonitor` 等需先扩范围讨论
- `flows/` 仅 1 条：渲染、网络复制、AI 行为树、导航构建、序列求值/播放、音频渲染**均无流程产物**
- `types/FPacketDataView.md`：NetCommon 无达标类型，为放宽判据产物（已标注）；`types/IAudioEndpoint.md`：音频工厂族均 < 60 行，按代表性择定（已标注）
- `types/UNavigationSystemV1.md` 虚函数计数为**下限**；`types/FFastArraySerializer.md` 派生清单为统计 + 代表
- **样本量**：69 篇；后续新增产物后需重跑 ⑥
