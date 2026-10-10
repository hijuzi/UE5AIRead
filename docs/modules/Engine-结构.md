> 引擎版本：UE 5.8.3 (Build 58210709)
> 源码根：Engine/Source
> 生成技能：ue-module-structure v1.0
> 生成时间：2026-10-10
> 校验状态：已校验（2026-10-10）

# Engine 模块结构

## 一、模块定位

| 项 | 值 |
|---|---|
| 路径 | `Engine/Source/Runtime/Engine` |
| 类别 | Runtime |
| 规模 | 4,037 文件 / 2,404 头文件（`_meta/engine-modules.json` 2026-10-10 口径）；公开侧双目录：`Classes/` 908 个 `.h` + `Public/` 1,296 个 `.h`（递归计数） |
| 分层 | 框架 |
| 一句话职责 | 游戏框架与运行时核心：`AActor`/`UWorld`/`ULevel`、组件与子系统、玩家/控制器体系、资源类型（`UTexture`/`UStaticMesh` 等）与引擎循环——连接 Core/CoreUObject 地基与上层游戏代码 |

## 二、目录结构

```
Engine/
├── Engine.Build.cs               # 模块构建脚本（521 行、25 处 if 分支）
├── Classes/                      # 公开侧之一（传统布局；37 个子目录、908 个 .h、顶层无文件）
│   └── GameFramework/ Components/ Engine/ AI/ Animation/ Kismet/ Particles/ PhysicsEngine/ Sound/ …
├── Public/                       # 公开侧之二（现代布局；46 个子目录 + 顶层 390 个 .h，合计 1,296 个 .h）
│   └── EngineMinimal.h（聚合头）、EngineSharedPCH.h（共享 PCH）等
├── Private/                      # 实现（62 个子目录；含 Tests/）
└── Internal/                     # 内部共享（45 项：如 MaterialCache/、ShaderCompiler/、SkeletalMeshUpdater.h）
```

- 公开侧为 `Classes/` + `Public/` **双目录并存**；`Classes/` 顶层无文件、仅子目录。
- 测试代码分布在 `Classes/Tests/`（2 个 `.h`）、`Public/Tests/`、`Private/Tests/`（25 项），本版标注不展开。
- `Internal/` 不在公开契约内。

## 三、依赖关系

### 3.1 无条件依赖

| 类型 | 模块（行号） |
|---|---|
| 公开依赖（79-119，37 个） | `Core`(81)、`CoreOnline`(82)、`CoreUObject`(83)、`FieldNotification`(84)、`NetCore`(85)、`ImageCore`(86)、`Json`(87)、`JsonUtilities`(88)、`SlateCore`(89)、`Slate`(90)、`InputCore`(91)、`Messaging`(92)、`MessagingCommon`(93)、`RenderCore`(94)、`AnalyticsET`(95)、`RHI`(96)、`Sockets`(97)、`AssetRegistry`(98，注释"临时依赖")、`EngineMessages`(99)、`EngineSettings`(100)、`SynthBenchmark`(101)、`GameplayTags`(102)、`PacketHandler`(103)、`AudioPlatformConfiguration`(104)、`MeshDescription`(105)、`StaticMeshDescription`(106)、`SkeletalMeshDescription`(107)、`PakFile`(108)、`NetworkReplayStreaming`(109)、`PhysicsCore`(110)、`SignalProcessing`(111)、`StateStream`(112)、`AudioExtensions`(113)、`DeveloperSettings`(114)、`AudioLinkCore`(115)、`CookOnTheFly`(116)、`IoStoreOnDemandCore`(117) |
| 私有依赖（150-179，26 个） | `AnimationCore`(152)、`AutoRTFM`(153)、`AppFramework`(154)、`BandwidthMeasurementTool`(155)、`BuildSettings`(156)、`Networking`(157)、`Landscape`(158)、`UMG`(159)、`Projects`(160)、`TypedElementFramework`(161)、`TypedElementRuntime`(162)、`MaterialShaderQualitySettings`(163)、`MoviePlayerProxy`(164)、`CinematicCamera`(165)、`Analytics`(166)、`AudioMixer`(167)、`AudioMixerCore`(168)、`IntelISPC`(169)、`TraceLog`(170)、`Icmp`(171)、`UniversalObjectLocator`(172)、`XmlParser`(173)、`IoStoreOnDemand`(174)、`HTTP`(175)、`GeometryCore`(176)、`DownlinkBandwidthManager`(177) |
| 公开包含路径（18-31） | `AnimationCore`(20)、`AudioExtensions`(21)、`AudioMixer`(22)、`AudioMixerCore`(23)、`InputCore`(24)、`MovieSceneCapture`(25)、`PacketHandler`(26)、`Renderer`(27)、`RHI`(28)、`Shaders`(29) |
| 公开包含路径（132-148） | `TypedElementFramework`(134)、`TypedElementRuntime`(135)、`NetCore`(136)、`RenderCore`(137)、`CoreUObject`(138)、`CoreOnline`(139)、`PhysicsCore`(140)、`ChaosCore`(141)、`DeveloperSettings`(142)、`NetCommon`(143)、`Slate`(144)、`Sockets`(145)、`MeshDescription`(146) |
| 公开包含路径（单条） | `ClothingSystemRuntimeInterface`(459) |
| 私有包含路径（模块形式 39-53） | `DerivedDataCache`(41)、`DesktopPlatform`(42)、`DistributedBuildInterface`(43)、`TargetPlatform`(44)、`ImageWrapper`(45)、`ImageWriteQueue`(46)、`HeadMountedDisplay`(47)、`EyeTracker`(48)、`MRMesh`(49)、`Advertising`(50)、`AutomationWorker`(51) |
| 私有包含路径（模块形式 228-234） | `MessagingRpc`(230)、`PortalRpc`(231)、`PortalServices`(232) |
| 私有包含路径（路径式 33-37） | `NetCore/Private`(35) |
| 动态加载（191-197） | `RadAudioDecoder`(191)、`BinkAudioDecoder`(192)、`VorbisAudioDecoder`(193)、`OpusAudioDecoder`(194)、`AdpcmAudioDecoder`(195)、`EyeTracker`(197) |
| 动态加载（267-278） | `AnimGraphRuntime`(267)；`MovieScene`(272)、`MovieSceneCapture`(273)、`MovieSceneTracks`(274)、`LevelSequence`(275)、`HeadMountedDisplay`(276)、`MRMesh`(277)、`StreamingPauseRendering`(278) |
| 动态加载（368-375、400-402） | `NullNetworkReplayStreaming`(370)、`LocalFileNetworkReplayStreaming`(371)、`HttpNetworkReplayStreaming`(372)、`Advertising`(373)；`MassCore`(400)、`MassEntity`(401)、`MassSignals`(402) |
| 循环引用（248-257） | `GameplayTags`(250)、`Landscape`(251)、`UMG`(252)、`MaterialShaderQualitySettings`(253)、`CinematicCamera`(254)、`AudioMixer`(255)、`MaterialUtilities`(256)——列入 `CircularlyReferencedDependentModules` |
| 公开依赖（单条） | `ClothingSystemRuntimeInterface`(460) |

> **辅助函数已展开**（两处调用均在 Build.cs 构造体内）：
> - `SetupModulePhysicsSupport(Target)`（第 456 行调用），函数体在 UBT 的 `Engine/Source/Programs/UnrealBuildTool/Configuration/Rules/ModuleRules.cs` 第 1793-1813 行：
>   追加公开包含路径 `Chaos`；**公开依赖** `PhysicsCore`、`ChaosCore`、`Chaos`、`NNE`；并转调 `SetupModuleChaosVisualDebuggerSupport`（第 1775-1788 行）——当 `target.bCompileChaosVisualDebuggerSupport` 为真时再追加公开依赖 `ChaosVDRuntime`。
> - `SetupIrisSupport(Target, bIrisAddAsPublicDependency)`（第 515 行调用；`bIrisAddAsPublicDependency = true` 见第 514 行），函数体在同文件第 1747-1762 行：
>   因传入 `true`，`IrisCore` 以**公开依赖**加入（第 1756 行）；并添加 `UE_NET_HAS_IRIS_FASTARRAY_BINDING=1`、`UE_WITH_IRIS=1`。
> - `PhysicsCore` 已在第 110 行无条件公开依赖中——此处为重复加入，非笔误。

### 3.2 平台与配置条件依赖

> `Engine.Build.cs` 全文含 **25 处 `if` 分支**（含 2 处 `else if`），下表按条件归并。

| 依赖 | 类型 | 生效条件 | Build.cs 行 |
|---|---|---|---|
| `SlateReflector`、`TranslationEditor` | 私有包含路径 + 动态加载 | 非 Shipping 或 `bCompileAgainstEditor` | 55-69 |
| `EditorAnalyticsSession` | 私有依赖 | 非 Shipping 或 `bCompileAgainstEditor` | 71-76 |
| `ApplicationCore` | 公开依赖 | `bCompileAgainstApplicationCore` | 121-123 |
| `IoStoreOnDemand` | 私有依赖 | `bCompileIoStoreOnDemand` | 126-128 |
| `SparseVolumeTexture` | 动态加载 | `bBuildWithEditorOnlyData && bBuildEditor` | 181-184 |
| `Localization` | 私有包含路径 + 动态加载 | 非 Shipping | 199-202 |
| `TextureBuildUtilities`、`Horde`（公开依赖）；`RawMesh`、`Zen`、`EditorToolEvents`（私有依赖） | 混合 | `bCompileAgainstEditor` | 206-225 |
| `MessagingRpc`、`PortalRpc`、`PortalServices` | 私有依赖 | `bCompileAgainstEditor` | 236-245 |
| `Foliage` | 私有包含路径 | `bCompileAgainstEditor` | 260-262 |
| `Media`、`SlateNullRenderer`、`SlateRHIRenderer` | 私有包含路径 + 动态加载 | `Type != Server` | 282-298 |
| `PerfCounters` | 私有依赖 | `Type == Server 或 Editor` | 301-303 |
| `MaterialUtilities`、`MeshUtilities`、`MeshUtilitiesCommon`、`AnimationDataController`、`AnimationBlueprintEditor`、`RawMesh`、`CollisionAnalyzer`、`LogVisualizer`、`GraphEditor`、`MaterialEditor` | 公开/私有包含路径 + 私有依赖 + 动态加载 + 循环引用（明细见第 306-337 行） | `bCompileAgainstEditor` | 306-337 |
| `WindowsTargetPlatform`、`WindowsPlatformEditor` | 动态加载 | 上条内嵌：`Platform == Win64` | 339-346 |
| `MacTargetPlatform`、`MacPlatformEditor` | 动态加载 | 上条内嵌：`Platform == Mac`（else if） | 348-355 |
| `LinuxTargetPlatform`、`LinuxPlatformEditor` | 动态加载 | 上条内嵌：Unix 平台组（else if） | 357-364 |
| `LiveCoding` | 动态加载 | `bWithLiveCoding` | 377-379 |
| `ImageWrapper` | 动态加载 | `Type != Server` | 382-388 |
| `DeveloperToolSettings` | 私有依赖 | `!bBuildRequiresCookedData && bCompileAgainstEngine` | 393-395 |
| `InterchangeCore`、`Kismet`、`ToolMenus`、`UnrealEd`（公开包含路径）；`AssetTools`、`AssetDefinition`、`Documentation`、`HierarchicalLODUtilities`、`MeshBuilder`、`NaniteBuilder`（私有包含路径）；`DerivedDataCache`、`Kismet`、`TextureCompressor`、`UnrealEd`（私有依赖）；`AnimationModifiers`、`AssetTools`、`HierarchicalLODUtilities`、`LevelInstanceEditor`、`NaniteBuilder`、`MassEntityEditor`、`SVGDistanceField`（动态加载）；`UnrealEd`、`Kismet`（循环引用） | 混合 | `bBuildEditor == true` | 404-454 |
| `ClothingSystemEditorInterface`（私有依赖 + 私有包含路径）、`DesktopPlatform`（私有依赖） | 混合 | `bBuildEditor` | 462-466 |
| Mac 系统框架（`AVFoundation`、`CoreVideo`、`CoreMedia`） | 系统框架 | `Platform == Mac` | 476-481 |
| `AndroidRuntimeSettings` | 私有包含路径 | Android 平台组 | 484-486 |
| `IOSPlatformFeatures`（公开包含路径）、`IOSRuntimeSettings`（私有包含路径） | 混合 | IOS 平台组 | 490-493 |
| Stats 内容文件（`RuntimeDependencies`） | 运行时依赖 | `bBuildEditor 或非 Shipping` | 500-502 |

### 3.3 第三方静态依赖

`AddEngineThirdPartyPrivateStaticDependencies` 全文调用 **1 处**：

| 三方库 | 生效条件 | Build.cs 行 |
|---|---|---|
| `UEWavComp` | `bBuildWithEditorOnlyData && bBuildEditor` | 185-187 |

> 第三方库以**模块**形式引入的（如 `IntelISPC` 第 169 行）列在 3.1，不属本表。

## 四、对外暴露面

> 公开侧为 `Classes/` + `Public/`（合计 2,204 个 `.h`）；下表为框架核心头（存在性已逐一核验）。

| 头文件 | 提供的能力 |
|---|---|
| `Engine/Source/Runtime/Engine/Public/EngineMinimal.h` | 聚合头（最小包含集） |
| `Engine/Source/Runtime/Engine/Classes/GameFramework/Actor.h` | `AActor`（详见 `types/AActor.md`） |
| `Engine/Source/Runtime/Engine/Classes/GameFramework/Pawn.h` | `APawn` |
| `Engine/Source/Runtime/Engine/Classes/GameFramework/PlayerController.h` | `APlayerController` |
| `Engine/Source/Runtime/Engine/Classes/GameFramework/GameModeBase.h` | `AGameModeBase` |
| `Engine/Source/Runtime/Engine/Classes/GameFramework/Info.h` | `AInfo`（无变换框架 Actor 基类） |
| `Engine/Source/Runtime/Engine/Classes/Components/ActorComponent.h` | `UActorComponent` |
| `Engine/Source/Runtime/Engine/Classes/Components/SceneComponent.h` | `USceneComponent` |
| `Engine/Source/Runtime/Engine/Classes/Engine/World.h` | `UWorld` |
| `Engine/Source/Runtime/Engine/Classes/Engine/Level.h` | `ULevel` |
| `Engine/Source/Runtime/Engine/Classes/Engine/Engine.h` | `UEngine`（全局单例 `GEngine`） |
| `Engine/Source/Runtime/Engine/Classes/Engine/GameInstance.h` | `UGameInstance` |
| `Engine/Source/Runtime/Engine/Classes/Engine/Player.h` | `UPlayer` |
| `Engine/Source/Runtime/Engine/Classes/Engine/DataAsset.h` | `UDataAsset` |
| `Engine/Source/Runtime/Engine/Classes/Engine/AssetManager.h` | `UAssetManager` |
| `Engine/Source/Runtime/Engine/Classes/Engine/EngineTypes.h` | 引擎公共枚举 / 结构 |
| `Engine/Source/Runtime/Engine/Classes/Engine/EngineBaseTypes.h` | 引擎基类型（含 `FActorTickFunction`） |
| `Engine/Source/Runtime/Engine/Classes/Engine/Texture.h` | `UTexture` |
| `Engine/Source/Runtime/Engine/Classes/Engine/StaticMesh.h` | `UStaticMesh` |
| `Engine/Source/Runtime/Engine/Classes/Engine/Blueprint.h` | `UBlueprint` |

## 五、模块生命周期

```
文件：Engine/Source/Runtime/Engine/Private/UnrealEngine.cpp
行 294：IMPLEMENT_MODULE( FEngineModule, Engine );

文件：Engine/Source/Runtime/Engine/Public/EngineModule.h
行 13：class FEngineModule : public FDefaultModuleImpl

文件：Engine/Source/Runtime/Engine/Private/UnrealEngine.cpp
行 319：void FEngineModule::StartupModule()

文件：Engine/Source/Runtime/Engine/Private/UnrealEngine.cpp
行 436：void FEngineModule::ShutdownModule()
```

- **模块类**：`FEngineModule : FDefaultModuleImpl`（声明 `EngineModule.h` 第 13-19 行；覆写 `StartupModule`/`ShutdownModule`）
- **`SupportsDynamicReloading`**：未覆写（模块内 0 命中）
- **`StartupModule()` 行为要点**（均在 `Private/UnrealEngine.cpp`）：
  1. 第 324 行：注册 `FPersistentObjectRef` 的 OnUseOuter 委托
  2. 第 328 行：`GGetMapNameDelegate.BindStatic(&GetMapNameStatic)`
  3. 第 330-337 行：为 `r.Shadow.CacheWPOPrimitives`、`r.ShowMaterialDrawEvents` 挂变更回调
  4. 第 339-340 行：挂接纹理流送挂起 / 恢复任务函数指针
  5. 第 342-345 行：`InitScreenPercentage(); InitCustomDepth(); FParticleSystemWorldManager::OnStartup();`
  6. 第 347-349 行：`WITH_EDITOR` 下 `USkinnedMeshComponent::BindWorldDelegates()`
  7. 第 351-371 行：绑定 `FInstancedStruct` 网络序列化委托；注册组件接口实现者
  8. 第 373-433 行：注册 `IPrimitiveComponent` provider；经 `FDelayedAutoRegisterHelper`（`ObjectSystemReady`）初始化网络对象工厂等
- **`ShutdownModule()`**（第 436-465 行）：按注册项反向清理

## 六、关键约定与坑

1. **公开侧双目录**：`Classes/`（908 个 `.h`，37 个子目录，**顶层无文件**——传统布局）+ `Public/`（1,296 个 `.h`，46 个子目录 + 390 个顶层 `.h`）。**`Classes/EngineMinimal.h` 不存在**——聚合头是 `Public/EngineMinimal.h`。
2. **辅助函数会追加依赖**（`SetupModulePhysicsSupport` / `SetupIrisSupport`，见 3.1 附注）——只静态读 Build.cs 的 `Add*` 调用会漏 `Chaos` / `ChaosCore` / `NNE` / `IrisCore` / `ChaosVDRuntime`（函数体在 UBT `ModuleRules.cs`）。
3. **`Engine` ↔ `GameplayTags` 相互公开依赖（循环）**：第 102 行公开依赖 `GameplayTags`，第 250 行将其列入 `CircularlyReferencedDependentModules`；`GameplayTags.Build.cs` 第 14 行反向公开依赖 `Engine`。
4. **第 469-474 行的 Win64 分支内两处 `Add` 均被注释**（含 `HeadMountedDisplay`）——该分支当前**零生效依赖**，复述时勿当作有效项。
5. **重复出现勿去重**：`PhysicsCore`（110 + `SetupModulePhysicsSupport`）、`NetCore`（85 / 136）、`CoreUObject`（83 / 138）、`RHI`（28 / 96）、`Slate`（90 / 144）等多组同时出现在"依赖表"与"包含路径表"，如实记录。
6. **数字口径**：`Engine.Build.cs` 521 行（`ReadAllLines`）、25 处 `if` 分支、三方静态依赖 1 处；`Classes/` 908 个 `.h`、`Public/` 1,296 个 `.h`。取数命令见「取数说明」。

## 取数说明

以下命令的相对基准为 `Engine/Source`（实际路径按 `_meta/convention.md` 的本机环境块解析）：

| 断言 | 取数方式 |
|---|---|
| 4,037 文件 / 2,404 头文件 | `_meta/engine-modules.json` 中 `Module -eq 'Engine'` 行的 `Files`、`Headers` 字段 |
| `Classes/` 908、`Public/` 1,296 个 `.h`；顶层 390 个 `.h`、37 / 46 个子目录 | `(Get-ChildItem "Runtime/Engine/Classes" -Recurse -File -Filter *.h).Count` 等目录计数命令 |
| `Engine.Build.cs` 521 行、25 处 `if`、1 处三方静态调用 | `[System.IO.File]::ReadAllLines(...).Count`；`\bif\s*\(` 与 `AddEngineThirdPartyPrivateStaticDependencies` 全匹配计数 |
| 辅助函数展开 | UBT `ModuleRules.cs` 第 1747-1762（Iris）与 1793-1813（Physics）行 |
| 全部行号引用 | 2026-10-10 对 UE 5.8.3 源码本机逐条核对 |

## 相关文档

- `types/AActor.md` —— 本模块框架核心类型（同批产出）
- `modules/GameplayTags-结构.md` —— 互为公开依赖的模块（同批产出）
- `types/UObject.md` —— 基类链终点（已校验）
- `modules/CoreUObject-结构.md` —— 上游地基模块（已校验）
- `modules/Core-结构.md` —— 上游地基模块（已校验）
- `flows/UObject创建流程.md` —— 对象创建主路径（已校验）

## 更新记录

- 2026-10-10 修正「四、对外暴露面」20 处路径（模块内相对形式 → 安装根完整形式）；修正「取数说明」命令示例路径分隔符（反斜杠 → 正斜杠）——两者均由 `verify-refs.ps1` 机器初筛报出
