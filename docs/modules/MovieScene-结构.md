> 引擎版本：UE 5.8.3 (Build 58210709)
> 源码根：Engine/Source
> 生成技能：ue-module-structure v1.0
> 生成时间：2026-10-10
> 校验状态：已校验（2026-10-10）

# MovieScene 模块结构

## 一、模块定位

| 项 | 值 |
|---|---|
| 路径 | `Engine/Source/Runtime/MovieScene` |
| 类别 | Runtime |
| 规模 | 500 文件 / 287 头文件（`_meta/engine-modules.json` 2026-10-10 口径）；公开侧 280 个 `.h`（顶层 61 + 14 个子目录） |
| 分层 | 框架 |
| 一句话职责 | 序列（Sequencer）**数据模型层**：`UMovieSceneSequence` / `UMovieScene` 资产与轨道/段（`UMovieSceneTrack` / `UMovieSceneSection`）、求值模板与编译（Evaluation / Compilation）、播放（`UMovieSceneSequencePlayer`）与序列实体系统（EntitySystem） |

## 二、目录结构

```
MovieScene/
├── MovieScene.Build.cs           # 模块构建脚本（39 行；0 处 if 分支）
├── MovieScene.natvis
├── Public/                       # 公开侧（61 个顶层 .h + 14 个子目录，共 280 个 .h）
│   └── 子目录：Bindings/ Channels/ Compilation/ Conditions/ Containers/ Decorations/
│              EntitySystem/ Evaluation/ EventHandlers/ Generators/ MetaData/ Sections/ Tracks/ Variants/
└── Private/                      # 实现（14 个子目录，含 Tests/）
```

- 无模块级聚合头；最接近的便捷聚合是 `Public/Evaluation/MovieSceneEvaluation.h`（595 B，11 条 include 转发）。
- `Tests/` 位于 `Private/Tests/`，本版标注不展开。

## 三、依赖关系

### 3.1 无条件依赖

| 模块 | 类型 | Build.cs 行 | 说明 |
|---|---|---|---|
| `Core` | 公开依赖 | 20 | |
| `CoreUObject` | 公开依赖 | 21 | |
| `InputCore` | 公开依赖 | 22 | |
| `Engine` | 公开依赖 | 23 | |
| `SlateCore` | 公开依赖 | 24 | |
| `TimeManagement` | 公开依赖 | 25 | |
| `UniversalObjectLocator` | 公开依赖 | 26 | 同时出现在私有包含路径（第 14 行） |
| `MovieSceneTracks` | 私有包含路径 | 12 | 仅包含路径 |
| `TargetPlatform` | 私有包含路径 | 13 | 仅包含路径 |
| `AutoRTFM` | 私有依赖 | 33 | 同时出现在私有包含路径（第 11 行） |

> **辅助函数已展开**：第 37 行 `SetupIrisSupport(Target)`（未传第二参、默认 `false`）→ **追加私有依赖 `IrisCore`**
> （UBT `ModuleRules.cs` 第 1760 行）+ `UE_NET_HAS_IRIS_FASTARRAY_BINDING=1`、`UE_WITH_IRIS=1` 两个宏。
> **本模块无其他未展开依赖。**

### 3.2 平台与配置条件依赖

**无**——`MovieScene.Build.cs` 全文 **0 处 `if` 分支**（实测）。

### 3.3 第三方静态依赖

`AddEngineThirdPartyPrivateStaticDependencies` 调用 **0 处**——无第三方静态依赖。

## 四、对外暴露面

> 公开侧共 280 个 `.h`；下表为核心契约。

| 头文件 | 提供的能力 |
|---|---|
| `Engine/Source/Runtime/MovieScene/Public/MovieSceneSequence.h` | `UMovieSceneSequence`（第 71 行）→ `types/UMovieSceneSequence.md` |
| `Engine/Source/Runtime/MovieScene/Public/MovieScene.h` | `UMovieScene`（第 360 行，`: public UMovieSceneDecorationContainerObject`） |
| `Engine/Source/Runtime/MovieScene/Public/MovieSceneSignedObject.h` | `UMovieSceneSignedObject`（第 71 行）——序列资产签名基类 |
| `Engine/Source/Runtime/MovieScene/Public/MovieSceneTrack.h` | `UMovieSceneTrack`（第 203 行） |
| `Engine/Source/Runtime/MovieScene/Public/MovieSceneSection.h` | `UMovieSceneSection`（第 242 行） |
| `Engine/Source/Runtime/MovieScene/Public/MovieSceneSequencePlayer.h` | `UMovieSceneSequencePlayer`（第 176 行，`: UObject, IMovieScenePlayer`） |
| `Engine/Source/Runtime/MovieScene/Public/IMovieScenePlayer.h` | `IMovieScenePlayer`（第 88 行，纯 C++ 接口） |
| `Engine/Source/Runtime/MovieScene/Public/MovieSceneBinding.h` | 绑定与引用体系 |
| `Engine/Source/Runtime/MovieScene/Public/Evaluation/MovieSceneEvaluationTemplate.h` | 求值模板（**在 `Evaluation/` 子目录**） |
| `Engine/Source/Runtime/MovieScene/Public/MovieSceneFwd.h` | 前置声明集中头（第 28-30 行示例） |
| `Engine/Source/Runtime/MovieScene/Public/IMovieSceneModule.h` | 模块接口 `IMovieSceneModule`（第 28 行） |

## 五、模块生命周期

```
文件：Engine/Source/Runtime/MovieScene/Private/MovieSceneModule.cpp
行 191-193：class FMovieSceneModule / : public IMovieSceneModule / , public TSharedFromThis<FMovieSceneModule>
行 203：virtual void StartupModule() override（定义 203-229 行）
行 231：virtual void ShutdownModule() override（定义 231-236 行）
行 369：IMPLEMENT_MODULE(FMovieSceneModule, MovieScene);
```

- **接口**：`IMovieSceneModule : IModuleInterface`（`Public/IMovieSceneModule.h` 第 28-29 行）。
- **`StartupModule()`** 要点：
  1. `FModuleManager::Get().LoadModuleChecked("UniversalObjectLocator");`（第 208 行）
  2. 注册 EntitySystem 调试 GUID（第 211-216 行）
  3. `ModuleHandle = MakeShareable(this, FNoopDefaultDeleter());`（第 222 行）
  4. `FBuiltInComponentTypes::Get();` 与 `PlaybackClientTracker = MakeUnique<FPlaybackClientTracker>();`（第 224-226 行）
  5. `FCoreDelegates::OnAllModuleLoadingPhasesComplete.AddStatic(&UMovieSceneEntitySystem::StaticInitialize);`（第 228 行）
- **`ShutdownModule()`**：`PlaybackClientTracker.Reset();`（第 233 行）、`UE::MovieScene::FBuiltInComponentTypes::Destroy();`（第 235 行）。
- **`SupportsDynamicReloading`**：未覆写（0 命中）。

## 六、关键约定与坑

1. **`UMovieScene` 不是 `UMovieSceneSequence` 的派生类**（两者是兄弟关系：`UMovieScene` 经 `UMovieSceneDecorationContainerObject` 体系）——按"MovieScene 是 Sequence 的子类"直觉写代码/文档都会出错（详见 `types/UMovieSceneSequence.md` 第七节）。
2. **`GetPlaybackRange` 在 `UMovieScene`**（`MovieScene.h` 第 803 行），**`IsLocked` 在 `UMovieSceneSection`**（第 603 行）——都不在 `UMovieSceneSequence` 上。
3. **`Public/MovieScenePlayer.h` 不存在**（实测 0 命中；只有 `IMovieScenePlayer.h`、`MovieSceneLegacyPlayer.h`、`MovieSceneSequencePlayer.h`）；`MovieSceneEvaluationTemplate.h` 在 `Evaluation/` 子目录而非 Public 根。
4. **`SetupIrisSupport` 追加 `IrisCore` 私有依赖**（第 37 行）——静态只读 `Add*` 调用会漏。
5. **数字口径**：`MovieScene.Build.cs` 39 行（`ReadAllLines`）、0 处 `if`、0 处三方静态调用；公开侧 280 个 `.h`（顶层 61）。取数命令见「取数说明」。

## 取数说明

以下命令的相对基准为 `Engine/Source`（实际路径按 `_meta/convention.md` 的本机环境块解析）：

| 断言 | 取数方式 |
|---|---|
| 500 文件 / 287 头文件 | `_meta/engine-modules.json` 中 `Module -eq 'MovieScene'` 行的 `Files`、`Headers` 字段 |
| 公开侧 280 个 `.h`（顶层 61） | `(Get-ChildItem "Runtime/MovieScene/Public" -Recurse -File -Filter *.h).Count` 与顶层计数 |
| Build.cs 39 行、0 处 `if`、0 处三方静态调用 | `[System.IO.File]::ReadAllLines(...).Count`；`\bif\s*\(` 与 `AddEngineThirdPartyPrivateStaticDependencies` 全匹配计数 |
| `SetupIrisSupport` 展开 | UBT `ModuleRules.cs` 第 1747-1762 行 |
| 全部行号引用 | 2026-10-10 对 UE 5.8.3 源码本机逐条核对 |

## 相关文档

- `types/UMovieSceneSequence.md` —— 本模块核心类型（同批产出）
- `modules/GameplayTasks-结构.md` —— 同批模块
- `modules/CoreUObject-结构.md` —— `UMovieSceneSignedObject` 的基类链所在模块
- `modules/Engine-结构.md` —— `LevelSequence` 等消费方参照
