> 引擎版本：UE 5.8.3 (Build 58210709)
> 源码根：Engine/Source
> 生成技能：ue-module-structure v1.0
> 生成时间：2026-10-10
> 校验状态：已校验（2026-10-11）

# LevelSequence 模块结构

## 一、模块定位

| 项 | 值 |
|---|---|
| 路径 | `Engine/Source/Runtime/LevelSequence` |
| 类别 | Runtime |
| 规模 | 36 文件 / 19 头文件（`_meta/engine-modules.json` 2026-10-10 口径；公开侧 17 + `Private/` 2） |
| 分层 | 框架 |
| 一句话职责 | "关卡序列"层：`ULevelSequence` 资产、播放 Actor 与播放器（`ALevelSequenceActor` / `ULevelSequencePlayer`）、Director 与 BurnIn、绑定引用与生成器注册 |

## 二、目录结构

```
LevelSequence/
├── LevelSequence.Build.cs        # 模块构建脚本（47 行、1 处 if 分支）
├── Public/                       # 公开侧 17 个 .h（LevelSequence.h / LevelSequenceActor.h / LevelSequencePlayer.h /
│                                 # LevelSequenceDirector.h / LevelSequenceBurnIn.h / SequenceMediaController.h …）
└── Private/                      # 实现（16 个 .cpp + LevelSequenceModule.h / LegacyLazyObjectPtrFragment.h）
```

- 无 `Internal/`、无 `Tests/`（实测 0 命中）；无聚合头。

## 三、依赖关系

### 3.1 无条件依赖

| 模块 | 类型 | Build.cs 行 | 说明 |
|---|---|---|---|
| `Core` | 公开依赖 | 11 | |
| `CoreUObject` | 公开依赖 | 12 | |
| `Engine` | 公开依赖 | 13 | |
| `MovieScene` | 公开依赖 | 14 | |
| `MovieSceneTracks` | 公开依赖 | 15 | 同批模块 |
| `TimeManagement` | 公开依赖 | 16 | |
| `UMG` | 公开依赖 | 17 | BurnIn（`ULevelSequenceBurnIn : UUserWidget`）的基类模块 |
| `DeveloperSettings` | 私有依赖 | 23 | |
| `MediaAssets` | 私有依赖 | 24 | |
| `UniversalObjectLocator` | 私有依赖 | 25 | Startup 时动态加载 |

> 辅助函数检查：**无**——无未展开依赖。

### 3.2 平台与配置条件依赖

> 全文 **1 处 `if` 分支**（第 29 行）。

| 依赖 | 类型 | 生效条件 | Build.cs 行 |
|---|---|---|---|
| `ActorPickerMode`、`EditorFramework`、`PropertyEditor`、`UnrealEd` | 私有依赖 | `Target.bBuildEditor == true` | 33-36 |
| `SceneOutliner` | 私有包含路径 | 同上 | 42 |

### 3.3 第三方静态依赖

调用 **0 处**——无第三方静态依赖。

## 四、对外暴露面

> 公开侧共 17 个 `.h`；核心如下。

| 头文件 | 提供的能力 |
|---|---|
| `Engine/Source/Runtime/LevelSequence/Public/LevelSequence.h` | `ULevelSequence`（第 23 行）→ `types/ULevelSequence.md` |
| `Engine/Source/Runtime/LevelSequence/Public/LevelSequenceActor.h` | `ALevelSequenceActor`（第 66 行，`: AActor, IMovieScenePlaybackClient, IMovieSceneBindingOwnerInterface, IWorldPartitionObjectResolver`） |
| `Engine/Source/Runtime/LevelSequence/Public/LevelSequencePlayer.h` | `ULevelSequencePlayer`（第 75 行，`: UMovieSceneSequencePlayer, UE::MovieScene::FCameraCutPlaybackCapability`） |
| `Engine/Source/Runtime/LevelSequence/Public/LevelSequenceDirector.h` | `ULevelSequenceDirector`（第 21 行） |
| `Engine/Source/Runtime/LevelSequence/Public/LevelSequenceBurnIn.h` | `ULevelSequenceBurnIn`（第 17 行，`: UUserWidget`） |
| `Engine/Source/Runtime/LevelSequence/Public/LevelSequenceBindingReference.h` | 绑定引用体系 |
| `Engine/Source/Runtime/LevelSequence/Public/LevelSequenceActorSpawner.h` | 对象生成器（Startup 时注册） |
| `Engine/Source/Runtime/LevelSequence/Public/SequenceMediaController.h` | 媒体控制（同步媒体播放） |
| `Engine/Source/Runtime/LevelSequence/Public/ILevelSequenceModule.h` | 模块接口 `ILevelSequenceModule`（第 12 行） |

## 五、模块生命周期

```
文件：Engine/Source/Runtime/LevelSequence/Private/LevelSequenceModule.cpp
行 381：IMPLEMENT_MODULE(FLevelSequenceModule, LevelSequence);
```

- **模块类**：`FLevelSequenceModule : public ILevelSequenceModule, public FSelfRegisteringExec`（`Private/LevelSequenceModule.h` 第 15 行——含控制台 exec 混入）；接口 `ILevelSequenceModule : IModuleInterface`（`Public/ILevelSequenceModule.h` 第 12 行）。
- **`StartupModule()`**（`LevelSequenceModule.cpp` 第 19 行起）：
  1. `FModuleManager::Get().LoadModuleChecked<IUniversalObjectLocatorModule>("UniversalObjectLocator");`（第 23 行）
  2. 注册 UOL Fragment 类型 `ls_lazy_obj_ptr` → `FLegacyLazyObjectPtrFragment`（第 25-26 行）
  3. `RegisterObjectSpawner(...)`（第 28 行，`FLevelSequenceActorSpawner::CreateObjectSpawner`）
  4. `WITH_EDITOR`：向 `ULevelSequence` CDO 添加 `UMovieSceneMetaData` / `UMovieSceneShotMetaData`（第 33-36 行，`SetFlags(RF_Transient)`）
- **`ShutdownModule()`**（第 42 行起）：移除 CDO 上的 MetaData（第 47-48 行）；`UnregisterObjectSpawner`（第 52 行）。
- **`SupportsDynamicReloading`**：未覆写（0 命中）。

## 六、关键约定与坑

1. **`Public/LevelSequenceModule.h` 不存在**——模块接口头是 `Public/ILevelSequenceModule.h`，实现头在 `Private/LevelSequenceModule.h`（按 `Public/模块名Module.h` 猜路径会落空）。
2. **模块类混入 `FSelfRegisteringExec`**（自带控制台命令注册），与常规纯 `IModuleInterface` 模块不同。
3. **CDO 注入**：模块 Startup 会给 `ULevelSequence` CDO 挂 MetaData（第 33-36 行）——文档化"每个关卡序列实例都带基础 MetaData"的来源。
4. **数字口径**：`LevelSequence.Build.cs` 47 行（`ReadAllLines`）、1 处 `if`、0 处三方静态调用；公开侧 17 个 `.h`（模块合计 19）。取数命令见「取数说明」。

## 取数说明

以下命令的相对基准为 `Engine/Source`（实际路径按 `_meta/convention.md` 的本机环境块解析）：

| 断言 | 取数方式 |
|---|---|
| 36 文件 / 19 头文件 | `[M]` 引擎磁盘递归计数：`(Get-ChildItem "Runtime/LevelSequence" -Recurse -File).Count` 得文件数；`(Get-ChildItem "Runtime/LevelSequence" -Recurse -File -Filter *.h).Count` 得头文件数（同 `_meta/engine-modules.json` 口径） |
| 公开侧 17 个 `.h` | `[M]` `(Get-ChildItem "Runtime/LevelSequence/Public" -Recurse -File -Filter *.h).Count` |
| Build.cs 47 行、1 处 `if`、0 处三方静态调用 | `[M]` `[System.IO.File]::ReadAllLines("Runtime/LevelSequence/LevelSequence.Build.cs").Count`；`Select-String "Runtime/LevelSequence/LevelSequence.Build.cs" -Pattern '\bif\s*\(' -AllMatches`；`Select-String "Runtime/LevelSequence/LevelSequence.Build.cs" -Pattern 'AddEngineThirdPartyPrivateStaticDependencies' -AllMatches` |
| 全部行号引用 | 2026-10-10 对 UE 5.8.3 源码本机逐条核对 |

## 相关文档

- `types/ULevelSequence.md` —— 本模块代表类型（同批产出）
- `modules/MovieSceneTracks-结构.md` —— 同批模块
- `modules/MovieScene-结构.md`、`types/UMovieSceneSequence.md` —— 数据模型层（批 6）
- `modules/UMG-结构.md` —— `ULevelSequenceBurnIn` 的基类（`UUserWidget`）所在模块

## 更新记录

- 2026-10-11 按规范 4.2.1 为「取数说明」各行加方法标记（`[M]`/`[R]`/`[H]`）；`[M]` 行把原文省略成 `(...)` 的路径补全为白名单可执行命令，现由 `ue-doc-verify` 逐条实际执行比对
