> 引擎版本：UE 5.8.3 (Build 58210709)
> 源码根：Engine/Source
> 生成技能：ue-module-structure v1.0
> 生成时间：2026-10-10
> 校验状态：已校验（2026-10-11）

# MovieSceneTracks 模块结构

## 一、模块定位

| 项 | 值 |
|---|---|
| 路径 | `Engine/Source/Runtime/MovieSceneTracks` |
| 类别 | Runtime |
| 规模 | 394 文件 / 200 头文件（`_meta/engine-modules.json` 2026-10-10 口径）；公开侧 182 个 `.h`（顶层 11 + 11 个子目录） |
| 分层 | 框架 |
| 一句话职责 | MovieScene 数据模型的**具体轨道/段实现层**：3D 变换、音频、骨骼动画、事件、相机切换等轨道与段（Tracks / Sections）、求值实体系统（Systems）、预动画状态（PreAnimatedState）与通道（Channels） |

## 二、目录结构

```
MovieSceneTracks/
├── MovieSceneTracks.Build.cs     # 模块构建脚本（43 行、1 处 if 分支）
├── Public/                       # 公开侧（182 个 .h：顶层 11 + 11 个子目录）
│   └── 子目录：Bindings/ Channels/ Conditions/ EntitySystem/ Evaluation/ PreAnimatedState/
│              Sections/ Systems/ Tests/ TrackInstances/ Tracks/
└── Private/                      # 实现（11 个子目录 + 顶层 .cpp/.h；含 Tests/）
```

- `Tests/`：`Public/Tests/`（2 个 `.h`）与 `Private/Tests/`（8 个文件），本版标注不展开。
- 无聚合头（无 `MovieSceneTracks.h`；`Public/MovieSceneTracksFwd.h`（196 B）为前置声明头）。

## 三、依赖关系

### 3.1 无条件依赖

| 模块 | 类型 | Build.cs 行 | 说明 |
|---|---|---|---|
| `Core` | 公开依赖 | 11 | |
| `CoreUObject` | 公开依赖 | 12 | |
| `Engine` | 公开依赖 | 13 | |
| `MovieScene` | 公开依赖 | 14 | 数据模型层（批 6 已出文档） |
| `TimeManagement` | 公开依赖 | 15 | |
| `AnimationCore` | 公开依赖 | 16 | |
| `Constraints` | 公开依赖 | 17 | |
| `AudioMixer` | 公开依赖 | 18 | |
| `SlateCore` | 公开依赖 | 19 | |
| `AnimGraphRuntime` | 私有依赖 | 24 | |
| `PropertyPath` | 私有依赖 | 25 | |

> 辅助函数检查：**无**（无 UBT 辅助调用）——无未展开依赖。

### 3.2 平台与配置条件依赖

> 全文 **1 处 `if` 分支**（第 28 行）。

| 依赖 | 类型 | 生效条件 | Build.cs 行 |
|---|---|---|---|
| `BlueprintGraph` | 公开依赖 | `Target.bBuildWithEditorOnlyData && Target.bBuildEditor` | 32 |
| `AnimationBlueprintLibrary`、`DataLayerEditor`、`EditorFramework`、`UnrealEd` | 私有依赖 | 同上 | 36-39 |

### 3.3 第三方静态依赖

调用 **0 处**——无第三方静态依赖。

## 四、对外暴露面

> 公开侧共 182 个 `.h`；核心如下。

| 头文件 | 提供的能力 |
|---|---|
| `Engine/Source/Runtime/MovieSceneTracks/Public/IMovieSceneTracksModule.h` | `IMovieSceneTracksModule`（第 23 行） |
| `Engine/Source/Runtime/MovieSceneTracks/Public/Tracks/MovieScene3DTransformTrack.h` | `UMovieScene3DTransformTrack`（第 57 行）→ `types/UMovieScene3DTransformTrack.md` |
| `Engine/Source/Runtime/MovieSceneTracks/Public/Tracks/MovieScenePropertyTrack.h` | `UMovieScenePropertyTrack`（第 29 行）——属性轨道基类 |
| `Engine/Source/Runtime/MovieSceneTracks/Public/Tracks/MovieSceneAudioTrack.h` | `UMovieSceneAudioTrack`（第 22 行） |
| `Engine/Source/Runtime/MovieSceneTracks/Public/Tracks/MovieSceneSkeletalAnimationTrack.h` | `UMovieSceneSkeletalAnimationTrack`（第 18 行） |
| `Engine/Source/Runtime/MovieSceneTracks/Public/Tracks/MovieSceneCameraCutTrack.h` | `UMovieSceneCameraCutTrack`（第 29 行） |
| `Engine/Source/Runtime/MovieSceneTracks/Public/Tracks/MovieSceneEventTrack.h` | `UMovieSceneEventTrack`（第 32 行） |
| `Engine/Source/Runtime/MovieSceneTracks/Public/Sections/MovieScene3DTransformSection.h` | `UMovieScene3DTransformSection`（第 215 行） |
| `Engine/Source/Runtime/MovieSceneTracks/Public/MovieSceneTracksComponentTypes.h` | 组件类型注册（Startup 时强制初始化） |
| `Engine/Source/Runtime/MovieSceneTracks/Public/MovieSceneTracksSettings.h` | 模块设置 |
| `Engine/Source/Runtime/MovieSceneTracks/Public/Systems/`（子目录，59 个条目） | 求值实体系统（如 `MovieScene3DTransformPropertySystem.h`） |

## 五、模块生命周期

```
文件：Engine/Source/Runtime/MovieSceneTracks/Private/MovieSceneTracksModule.cpp
行 20-21：class FMovieSceneTracksModule / : public IMovieSceneTracksModule
行 59：IMPLEMENT_MODULE(FMovieSceneTracksModule, MovieSceneTracks);
```

- **接口**：`IMovieSceneTracksModule : IModuleInterface`（`Public/IMovieSceneTracksModule.h` 第 23-24 行；静态 `GetEvaluationGroupName` 第 51 行带 `MOVIESCENETRACKS_API`）。
- **`StartupModule()`**（第 24-41 行）：
  1. `IMovieSceneModule& MovieSceneModule = IMovieSceneModule::Get();`（第 26 行）
  2. 注册 3 个求值组：`PreEvaluation`（掩码 0x8FFF，第 28-30 行）、`SpawnObjects`（0x0FFF，第 32-34 行）、`PostEvaluation`（0x0008，第 36-38 行）
  3. `UE::MovieScene::FMovieSceneTracksComponentTypes::Get();`（第 40 行，强制初始化组件类型注册）
- **`ShutdownModule()`**（第 43-45 行）：空实现。
- **`SupportsDynamicReloading`**：未覆写（0 命中）。

## 六、关键约定与坑

1. **公开侧主体在 `Public/Tracks/`**（顶层 11 个 `.h` 之外）；**`MovieSceneTracksModule.h` 不存在**（模块接口是 `IMovieSceneTracksModule.h`）。
2. **`Public/Systems/MovieSceneTransformSystem.h` 不存在**（实测 0 命中）——实际为 `MovieScene3DTransformPropertySystem.h`、`MovieSceneComponentTransformSystem.h` 等。
3. **类无类级导出宏**（`UCLASS(MinimalAPI)`），`MOVIESCENETRACKS_API` 仅成员级（如 `UMovieScene3DTransformTrack` 第 82-83 行）。
4. **数字口径**：`MovieSceneTracks.Build.cs` 43 行（`ReadAllLines`）、1 处 `if`、0 处三方静态调用；公开侧 182 个 `.h`（顶层 11）、Private 18 个 `.h`。取数命令见「取数说明」。

## 取数说明

以下命令的相对基准为 `Engine/Source`（实际路径按 `_meta/convention.md` 的本机环境块解析）：

| 断言 | 取数方式 |
|---|---|
| `Public/Tests/` **2** 个 `.h`、`Private/Tests/` **8** 个文件、Private 侧 **18** 个 `.h` | `[M]` `(Get-ChildItem "Runtime/MovieSceneTracks/Public/Tests" -Recurse -File -Filter *.h).Count` → 2；`(Get-ChildItem "Runtime/MovieSceneTracks/Private/Tests" -Recurse -File).Count` → 8；`(Get-ChildItem "Runtime/MovieSceneTracks/Private" -Recurse -File -Filter *.h).Count` → 18 |
| 394 文件 / 200 头文件 | `[M]` 引擎磁盘递归计数：`(Get-ChildItem "Runtime/MovieSceneTracks" -Recurse -File).Count` 得文件数；`(Get-ChildItem "Runtime/MovieSceneTracks" -Recurse -File -Filter *.h).Count` 得头文件数（同 `_meta/engine-modules.json` 口径） |
| 公开侧 182 个 `.h`（顶层 11） | `[M]` `(Get-ChildItem "Runtime/MovieSceneTracks/Public" -Recurse -File -Filter *.h).Count` 与顶层计数 |
| Build.cs 43 行、1 处 `if`、0 处三方静态调用 | `[M]` `[System.IO.File]::ReadAllLines("Runtime/MovieSceneTracks/MovieSceneTracks.Build.cs").Count`；`Select-String "Runtime/MovieSceneTracks/MovieSceneTracks.Build.cs" -Pattern '\bif\s*\(' -AllMatches`；`Select-String "Runtime/MovieSceneTracks/MovieSceneTracks.Build.cs" -Pattern 'AddEngineThirdPartyPrivateStaticDependencies' -AllMatches` |
| 全部行号引用 | 2026-10-10 对 UE 5.8.3 源码本机逐条核对 |

## 相关文档

- `types/UMovieScene3DTransformTrack.md` —— 本模块代表类型（同批产出）
- `modules/MovieScene-结构.md` —— 数据模型层（批 6）
- `types/UMovieSceneSequence.md` —— 序列资产基类（批 6）
- `modules/LevelSequence-结构.md` —— 消费方模块（同批产出）
- `modules/Engine-结构.md` —— `AActor` 等基类链所在模块

## 更新记录

- 2026-10-11 修正 `Private/Tests/` 文件数（9 → 8）

- 2026-10-11 「取数说明」补入 1 行计数断言取数方式（`convention.md` 4.2 覆盖要求）

- 2026-10-11 按规范 4.2.1 为「取数说明」各行加方法标记（`[M]`/`[R]`/`[H]`）；`[M]` 行把原文省略成 `(...)` 的路径补全为白名单可执行命令，现由 `ue-doc-verify` 逐条实际执行比对
- 2026-10-11 模块文件数更正：**393 → 394**（`engine-modules.json` 原记 393 为陈旧值，磁盘实数 394）；该行取数方式同时改为引擎磁盘命令
