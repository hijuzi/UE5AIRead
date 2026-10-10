> 引擎版本：UE 5.8.3 (Build 58210709)
> 源码根：Engine/Source
> 生成技能：ue-module-structure v1.0
> 生成时间：2026-10-10
> 校验状态：已校验（2026-10-10）

# AudioExtensions 模块结构

## 一、模块定位

| 项 | 值 |
|---|---|
| 路径 | `Engine/Source/Runtime/AudioExtensions` |
| 类别 | Runtime |
| 规模 | 32 文件 / 19 头文件（`_meta/engine-modules.json` 2026-10-10 口径；公开侧 18 + `Private/` 1） |
| 分层 | 音频 |
| 一句话职责 | 音频扩展**契约层**：空间化/遮挡/混响/源数据覆盖工厂（`IAudioExtensionPlugin.h` 家族）、音频端点（`IAudioEndpoint`）、参数接口注册与传输、Soundfield 格式/端点工厂——第三方音频插件对接引擎的接口集合 |

## 二、目录结构

```
AudioExtensions/
├── AudioExtensions.Build.cs   # 模块构建脚本（27 行、0 处 if 分支）
├── Public/                    # 公开侧 18 个 .h（无子目录，单层）
│   ├── IAudioExtensionPlugin.h（708 行；插件工厂族）/ IAudioEndpoint.h / IAudioModulation.h /
│   │   IAudioParameterInterfaceRegistry.h / IAudioParameterTransmitter.h / IAudioPropertiesDetailsInjector.h /
│   │   IAudioProxyInitializer.h / IAudioDecoderOverride.h / ISoundfieldFormat.h / ISoundfieldEndpoint.h /
│   │   ISoundWaveCloudStreaming.h / IWaveformTransformation.h / AudioParameter.h /
│   │   AudioParameterControllerInterface.h / AudioPropertiesSheetAssetBase.h /
│   │   AudioUnknown.h / SoundGeneratorOutput.h / AudioExtensionsLog.h
└── Private/                   # 13 个文件（含模块头 AudioExtentionsModule.h——文件名拼写如实保留 "Extentions"）
```

- 无 `Internal/`、无 `Tests/`（实测 0 命中）。

## 三、依赖关系

### 3.1 无条件依赖

| 模块 | 类型 | Build.cs 行 | 说明 |
|---|---|---|---|
| `Core` | 公开依赖 | 12 | |
| `CoreUObject` | 公开依赖 | 13 | |
| `SignalProcessing` | 公开依赖 | 14 | |
| `AudioMixerCore` | 公开依赖 | 15 | 启动时强制加载 |
| `AudioMixer` | 公开包含路径 | 22 | **仅包含路径、非链接依赖** |

> 辅助函数检查：**无**——无未展开依赖；无 `PrivateDependencyModuleNames`（不存在）。

### 3.2 平台与配置条件依赖

**无**——全文 **0 处 `if` 分支**（实测）。

### 3.3 第三方静态依赖

调用 **0 处**——无第三方静态依赖。

## 四、对外暴露面

> 公开侧共 18 个 `.h`；核心如下。

| 头文件 | 提供的能力 |
|---|---|
| `Engine/Source/Runtime/AudioExtensions/Public/IAudioExtensionPlugin.h`（708 行） | 插件工厂族：`IAudioPluginFactory`（第 195 行）、`IAudioSpatializationFactory`（第 245 行）、`IAudioSourceDataOverrideFactory`（第 403 行）、`IAudioOcclusionFactory`（第 483 行）、`IAudioModulationFactory`（第 554 行）、`IAudioReverbFactory`（第 588 行），以及实例接口 `IAudioSpatialization`（第 298 行）、`IAudioReverb`（第 620 行）、`IAudioPluginListener`（第 673 行）等 |
| `Engine/Source/Runtime/AudioExtensions/Public/IAudioEndpoint.h` | `IAudioEndpoint`（第 80 行）→ `types/IAudioEndpoint.md` |
| `Engine/Source/Runtime/AudioExtensions/Public/ISoundfieldFormat.h` | `ISoundfieldFactory`（第 253 行，`: IModularFeature`）等 Soundfield 编解码工厂族 |
| `Engine/Source/Runtime/AudioExtensions/Public/ISoundfieldEndpoint.h` | `ISoundfieldEndpoint`（第 63 行）/ `ISoundfieldEndpointFactory`（第 167 行） |
| `Engine/Source/Runtime/AudioExtensions/Public/IAudioModulation.h` | 调制体系（`IAudioModulationManager` 第 192 行） |
| `Engine/Source/Runtime/AudioExtensions/Public/IAudioParameterInterfaceRegistry.h` | 参数接口注册表（第 193 行） |
| `Engine/Source/Runtime/AudioExtensions/Public/IAudioParameterTransmitter.h` | `IParameterTransmitter`（第 57 行） |
| `Engine/Source/Runtime/AudioExtensions/Public/IAudioProxyInitializer.h`、`AudioParameter.h`、`IWaveformTransformation.h`、`ISoundWaveCloudStreaming.h` | 代理初始化 / 参数 / 波形变换 / 云流 |

> **没有名为 `IAudioExtensionPlugin` 的类型**——它只是头文件名（实测 0 命中）；按该名搜类型会落空。

## 五、模块生命周期

```
文件：Engine/Source/Runtime/AudioExtensions/Private/AudioExtensionsModule.cpp
行 43：IMPLEMENT_MODULE(FAudioExtensionsModule, AudioExtensions);
```

- **模块类**：`FAudioExtensionsModule final : public IModuleInterface`（`Private/AudioExtentionsModule.h` 第 6 行，**文件名拼写为 "Extentions"**；`Get()` 第 9 行）。
- **`StartupModule()`**（第 23-41 行）：强制加载 `SignalProcessing`（第 39 行）与 `AudioMixerCore`（第 40 行）。
- **`ShutdownModule` 未覆写**（0 命中）；`SupportsDynamicReloading` 未覆写。

## 六、关键约定与坑

1. **`IAudioExtensionPlugin` 是头文件名、不是类型**（模块内 0 命中同名类型）——该头声明的是"工厂 + 实例"接口族（见第四节）。
2. **模块头文件名有拼写错误存留**：`AudioExtentionsModule.h`（Extentions）；按正确拼写 `AudioExtensionsModule.h` 找会落空（`Public/AudioExtensionsModule.h` 实测 False）。
3. **类名先验修正**：`IAudioParameterInterface.h` 不存在（实际 `IAudioParameterInterfaceRegistry.h`）；`IAudioParameterTransmitter.h` 内的类型叫 `IParameterTransmitter`。
4. **公开侧 18 个 `.h`**（模块合计 19 = 18 + Private 1）；公开侧无子目录（单层 18 个）。
5. **数字口径**：`AudioExtensions.Build.cs` 27 行（`ReadAllLines`）、0 处 `if`、0 处三方静态调用；公开侧 18 个 `.h`。取数命令见「取数说明」。

## 取数说明

以下命令的相对基准为 `Engine/Source`（实际路径按 `_meta/convention.md` 的本机环境块解析）：

| 断言 | 取数方式 |
|---|---|
| 32 文件 / 19 头文件 | `_meta/engine-modules.json` 中 `Module -eq 'AudioExtensions'` 行的 `Files`、`Headers` 字段；公开 18 + Private 1 复核 |
| 公开侧 18 个 `.h` | `(Get-ChildItem "Runtime/AudioExtensions/Public" -Recurse -File -Filter *.h).Count` |
| Build.cs 27 行、0 处 `if`、0 处三方静态调用 | `[System.IO.File]::ReadAllLines(...).Count`；`\bif\s*\(` 与 `AddEngineThirdPartyPrivateStaticDependencies` 全匹配计数 |
| 全部行号引用 | 2026-10-10 对 UE 5.8.3 源码本机逐条核对 |

## 相关文档

- `types/IAudioEndpoint.md` —— 本模块代表类型（同批产出）
- `modules/AudioMixer-结构.md` —— 同批模块（渲染实现层）
- `modules/Core-结构.md` —— `IModularFeature` 机制所在（批 1）
- `modules/EnhancedInput-结构.md` —— 另一"插件契约层"参照（批 3）
