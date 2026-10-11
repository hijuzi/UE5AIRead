> 引擎版本：UE 5.8.3 (Build 58210709)
> 源码根：Engine/Source
> 生成技能：ue-module-structure v1.0
> 生成时间：2026-10-10
> 校验状态：已校验（2026-10-11）

# AudioMixer 模块结构

## 一、模块定位

| 项 | 值 |
|---|---|
| 路径 | `Engine/Source/Runtime/AudioMixer` |
| 类别 | Runtime |
| 规模 | 78 文件 / 40 头文件（`_meta/engine-modules.json` 2026-10-10 口径；公开侧 19 + `Classes/` 5 + `Private/` 16） |
| 分层 | 音频 |
| 一句话职责 | 引擎音频渲染核心：混合器设备（`FMixerDevice`）、源/子混音图（`FMixerSubmix` 树）、子混音效果与生成器源、Quartz 音乐时钟、SoundFileIO 与第三方编解码（Ogg / Vorbis / Opus） |

## 二、目录结构

```
AudioMixer/
├── AudioMixer.Build.cs   # 模块构建脚本（56 行、0 处 if 分支）
├── Classes/              # 5 个 .h（UBT 默认公共包含路径）
├── Public/               # 公开侧 19 个 .h（顶层 11 + Components/ 1 + Quartz/ 6 + SoundFileIO/ 1）
│   ├── 顶层：AudioMixerDevice.h / AudioMixerSubmix.h / AudioMixerBus.h / AudioMixerBlueprintLibrary.h /
│   │        AudioBusSubsystem.h / AudioDeviceNotificationSubsystem.h / AudioMixerModule.h /
│   │        FileDecoder.h / SoundWaveDecoder.h / IAudioMixerGeneratorSource.h / AudioRenderSchedulerTester.h
└── Private/              # 5 个子目录（Components/ Effects/ Generators/ Quartz/ SoundFileIO/）+ 16 .h + 37 .cpp
```

- 无 `Internal/`、无 `Tests/`（实测 0 命中）。

## 三、依赖关系

### 3.1 无条件依赖

| 模块 | 类型 | Build.cs 行 | 说明 |
|---|---|---|---|
| `Core` | 公开依赖 | 17 | |
| `CoreUObject` | 公开依赖 | 18 | |
| `AudioLinkEngine` | 公开依赖 | 19 | |
| `Engine` | 私有依赖 | 26 | |
| `NonRealtimeAudioRenderer` | 私有依赖 | 27 | |
| `AudioMixerCore` | 私有依赖 | 28 | 启动时强制加载 |
| `SignalProcessing` | 私有依赖 | 29 | 启动时强制加载 |
| `AudioPlatformConfiguration` | 私有依赖 | 30 | |
| `SoundFieldRendering` | 私有依赖 | 31 | |
| `AudioExtensions` | 私有依赖 | 32 | 同批模块 |
| `AudioLinkCore` | 私有依赖 | 33 | |
| `HeadMountedDisplay` | 私有依赖 | 34 | |
| `TraceLog` | 私有依赖 | 35 | |

> **重复项（如实）**：`TargetPlatform` 第 9（私有）/10（公开包含路径）行；`Engine` 第 12（公开包含路径）/26 行；`NonRealtimeAudioRenderer` 第 27 行 + 第 50 行；`SoundFieldRendering` 第 31 行 + 第 51 行。
> **循环引用登记**（第 48 行注释 `Circular references that need to be cleaned up`）：`CircularlyReferencedDependentModules.AddRange`（第 48-51 行）。
> 辅助函数检查：**无**——无未展开依赖。

### 3.2 平台与配置条件依赖

**无**——全文 **0 处 `if` 分支**（实测）。

### 3.3 第三方静态依赖

`AddEngineThirdPartyPrivateStaticDependencies`（第 39-45 行）——**本套件首个含三方静态依赖的模块**：

| 库 | 条件 | Build.cs 行 |
|---|---|---|
| `UEOgg` | 无条件 | 40 |
| `Vorbis` | 无条件 | 41 |
| `VorbisFile` | 无条件 | 42 |
| `libOpus` | 无条件 | 43 |
| `UELibSampleRate` | 无条件 | 44 |

## 四、对外暴露面

> 公开侧共 19 个 `.h`；核心如下。

| 头文件 | 提供的能力 |
|---|---|
| `Engine/Source/Runtime/AudioMixer/Public/AudioMixerDevice.h` | `FMixerDevice`（第 123 行，`namespace Audio`）→ `types/FMixerDevice.md` |
| `Engine/Source/Runtime/AudioMixer/Public/AudioMixerSubmix.h` | `FMixerSubmix`（第 112 行）——子混音树节点 |
| `Engine/Source/Runtime/AudioMixer/Public/AudioMixerBus.h` | 子混音输出总线 |
| `Engine/Source/Runtime/AudioMixer/Public/AudioMixerBlueprintLibrary.h` | 音频蓝图库 |
| `Engine/Source/Runtime/AudioMixer/Public/AudioBusSubsystem.h`、`AudioDeviceNotificationSubsystem.h` | 音频总线/设备通知子系统 |
| `Engine/Source/Runtime/AudioMixer/Public/Quartz/`（6 个） | Quartz 音乐时钟子系统 |
| `Engine/Source/Runtime/AudioMixer/Public/IAudioMixerGeneratorSource.h` / `FileDecoder.h` / `SoundWaveDecoder.h` | 生成器源与文件解码 |
| `Engine/Source/Runtime/AudioMixer/Public/AudioMixerModule.h` | 370 B 桩头 |

> **`IAudioMixerPlatformInterface` 不在本模块**——在 `AudioMixerCore`（`Engine/Source/Runtime/AudioMixerCore/Public/AudioMixer.h` 第 422 行）；平台后端扩展点归属 AudioMixerCore。

## 五、模块生命周期

```
文件：Engine/Source/Runtime/AudioMixer/Private/AudioMixerModule.cpp
行 6：class FAudioMixerModule : public IModuleInterface（仅 .cpp 内定义，无公开模块头）
行 17：IMPLEMENT_MODULE(FAudioMixerModule, AudioMixer);
```

- **`StartupModule()`**（第 10-14 行）：强制加载 `AudioMixerCore`（第 12 行）与 `SignalProcessing`（第 13 行）。
- **`ShutdownModule` 未覆写**（模块内 0 命中）；`SupportsDynamicReloading` 未覆写。

## 六、关键约定与坑

1. **`Public/AudioMixerSource.h` 不存在**——在 **`Private/AudioMixerSource.h`**（第 30 行 `class FMixerSource`）。
2. **`Public/IAudioMixerPlatformInterface.h` 不存在**——平台接口头在 AudioMixerCore（见第四节）。
3. **模块类仅存在于 `.cpp`**（无 `Public/AudioMixerModule.h` 模块类头；该文件是 370 B 桩头）。
4. **三方编解码链**：Ogg/Vorbis/Opus/SampleRate 五个静态库（第 40-44 行）——音频解码链接语境。
5. **数字口径**：`AudioMixer.Build.cs` 56 行（`ReadAllLines`）、0 处 `if`、5 个三方静态库；公开侧 19 个 `.h`（模块合计 40）。取数命令见「取数说明」。

## 取数说明

以下命令的相对基准为 `Engine/Source`（实际路径按 `_meta/convention.md` 的本机环境块解析）：

| 断言 | 取数方式 |
|---|---|
| 78 文件 / 40 头文件 | `[M]` 引擎磁盘递归计数：`(Get-ChildItem "Runtime/AudioMixer" -Recurse -File).Count` 得文件数；`(Get-ChildItem "Runtime/AudioMixer" -Recurse -File -Filter *.h).Count` 得头文件数（同 `_meta/engine-modules.json` 口径） |
| 公开侧 19 个 `.h` | `[M]` `(Get-ChildItem "Runtime/AudioMixer/Public" -Recurse -File -Filter *.h).Count` |
| Build.cs 56 行、0 处 `if`、1 处三方静态调用（含 5 个库：`UEOgg` / `Vorbis` / `VorbisFile` / `libOpus` / `UELibSampleRate`，第 39-45 行） | `[M]` `[System.IO.File]::ReadAllLines("Runtime/AudioMixer/AudioMixer.Build.cs").Count`；`Select-String "Runtime/AudioMixer/AudioMixer.Build.cs" -Pattern '\bif\s*\(' -AllMatches`；`Select-String "Runtime/AudioMixer/AudioMixer.Build.cs" -Pattern 'AddEngineThirdPartyPrivateStaticDependencies' -AllMatches` |
| 全部行号引用 | 2026-10-10 对 UE 5.8.3 源码本机逐条核对 |

## 相关文档

- `types/FMixerDevice.md` —— 本模块核心类型（同批产出）
- `modules/AudioExtensions-结构.md` —— 同批模块（扩展契约层）
- `modules/Engine-结构.md` —— `FAudioDevice` 基类所在模块
- `modules/RenderCore-结构.md` —— 另一"含第三方静态依赖/强制加载子模块"参照

## 更新记录

- 2026-10-11 修正 `Private/` 下 `.cpp` 计数（20 → 37）

- 2026-10-11 按规范 4.2.1 为「取数说明」各行加方法标记（`[M]`/`[R]`/`[H]`）；`[M]` 行把原文省略成 `(...)` 的路径补全为白名单可执行命令，现由 `ue-doc-verify` 逐条实际执行比对
- 2026-10-11 口径更正：「5 库三方静态调用」改为「**1 处**三方静态调用（含 5 个库）」——原文把"库数"写成"调用次数"口径，与命令不符
