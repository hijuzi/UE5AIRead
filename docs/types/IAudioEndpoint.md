> 引擎版本：UE 5.8.3 (Build 58210709)
> 源码根：Engine/Source
> 生成技能：ue-type-api v1.0
> 生成时间：2026-10-10
> 校验状态：已校验（2026-10-10）

# IAudioEndpoint

## 一、类型概览

| 项 | 值 |
|---|---|
| 全限定名 | `IAudioEndpoint`（全局命名空间） |
| 定义位置 | `Engine/Source/Runtime/AudioExtensions/Public/IAudioEndpoint.h` |
| 类型 | 类（纯 C++ 接口；**非 UObject**——文件内 `UCLASS` 服务于同文件的设置基类） |
| 导出策略 | 逐成员 `AUDIOEXTENSIONS_API`（类声明行无宏） |
| 所属模块 | `AudioExtensions`（`Engine/Source/Runtime/AudioExtensions`） |

> 同文件配套族：`IAudioEndpointSettingsProxy`（第 42 行）→ `UAudioEndpointSettingsBase`（第 53 行）/ `FDummyEndpointSettingsProxy`（第 62 行）/ `UDummyEndpointSettings`（第 67 行）；工厂 `IAudioEndpointFactory : public IModularFeature`（第 201 行）。

## 二、继承链

**无基类**（第 80-81 行：`class IAudioEndpoint` 后直接 `{`）——接口链根。

## 三、声明片段

```
文件：Engine/Source/Runtime/AudioExtensions/Public/IAudioEndpoint.h
行 80：class IAudioEndpoint
行 193：类体结束（};；文件 254 行）
```

## 四、公开 API

> 类内共 16 个条目（public 5 + protected 11）。

| 签名 | 说明 | 位置 |
|---|---|---|
| `virtual ~IAudioEndpoint() = default` | 虚析构 | 第 83 行 |
| `PatchNewInput(float, float&, int32&)`（`AUDIOEXTENSIONS_API`） | 创建输入补丁（返回 `Audio::FPatchInput`） | 第 97 行 |
| `SetNewSettings(TUniquePtr<IAudioEndpointSettingsProxy>&&)` | 更新设置 | 第 104 行 |
| `ProcessAudioIfNeccessary()` | 驱动一次处理 | 第 109 行 |
| `virtual IsImplemented()` | 是否已实现（可覆写） | 第 114 行 |
| `virtual float GetSampleRate() const`（protected，`AUDIOEXTENSIONS_API`） | 采样率 | 第 121 行 |
| `virtual int32 GetNumChannels() const`（protected，`AUDIOEXTENSIONS_API`） | 通道数 | 第 124 行 |
| `virtual bool EndpointRequiresCallback() const { return false; }`（protected） | 是否需要回调 | 第 132 行 |
| `virtual int32 GetDesiredNumFrames() const { return 0; }`（protected） | 期望帧数 | 第 133 行 |
| `virtual bool OnAudioCallback(...) { return false; }`（protected） | **核心回调**（默认未消费） | 第 140 行 |
| `PopAudio(float*, int32)`（protected，`AUDIOEXTENSIONS_API`） | 取出音频数据 | 第 152 行 |
| `PollSettings(TFunctionRef<void(const IAudioEndpointSettingsProxy*)>)`（protected） | 轮询设置变更 | 第 160 行 |
| `DisconnectAllInputs()`（protected） | 断开全部输入 | 第 166 行 |
| `StartRunningAsyncCallback()` / `StopRunningAsyncCallback()`（protected） | 异步回调启停 | 第 171 / 172 行 |
| `RunCallbackSynchronously()`（protected） | 同步运行回调 | 第 177 行 |

## 五、扩展点

### 5.1 可覆写虚函数（类内 7 处，全列）

| 组 | 成员（行号） |
|---|---|
| 生命周期 | 析构(83) |
| 状态与参数 | `IsImplemented`(114)、`GetSampleRate`(121)、`GetNumChannels`(124) |
| 回调模型 | `EndpointRequiresCallback`(132)、`GetDesiredNumFrames`(133)、`OnAudioCallback`(140) |

> 实现者覆写 `OnAudioCallback` / `GetSampleRate` / `GetNumChannels` 等即可接入自定义音频端点；创建经工厂 `IAudioEndpointFactory`（第 201 行，`: IModularFeature`）。

### 5.2 不建议覆写的内部虚函数

无。

## 六、生命周期

- **典型时序**：`PatchNewInput`（第 97 行，建输入补丁）→ `SetNewSettings`（第 104 行）→ `ProcessAudioIfNeccessary`（第 109 行）→ 回调（异步 `StartRunningAsyncCallback` 第 171 行 / 同步 `RunCallbackSynchronously` 第 177 行 → `OnAudioCallback` 第 140 行）→ `PopAudio`（第 152 行）供给下游 → `DisconnectAllInputs`（第 166 行）。
- 设置代理经 `PollSettings`（第 160 行）轮询（`IAudioEndpointSettingsProxy` 第 42 行）。

## 七、派生类（范围内）

搜索边界：派生类搜索**仅覆盖本版纳入范围的 292 个模块**（Runtime 291 个 + `EnhancedInput` 插件）。搜索模式 `\bpublic\s+IAudioEndpoint\b`（`*.h`）：Runtime **0 命中**；EnhancedInput **0**（另以 `Engine/Source` 全树复核，仅 `FDummyEndpointSettingsProxy : public IAudioEndpointSettingsProxy` 前缀误配，非真派生）。

| 派生类 | — |
|---|---|
| （无） | 接口；实现者经工厂注册（`IModularFeature`） |

> 同族参照：`IAudioSpatializationFactory`（`AudioExtensions/Public/IAudioExtensionPlugin.h` 第 245 行）、`IAudioReverbFactory`（同文件第 588 行）——空间化/混响等经典扩展工厂；`ISoundfieldFactory`（`AudioExtensions/Public/ISoundfieldFormat.h` 第 253 行）。

## 取数说明

| 断言 | 取数方式（相对基准：`Engine/Source`） |
|---|---|
| 文件 254 行、类体 80-193 | `[System.IO.File]::ReadAllLines(...).Count` + `^};` 检索 |
| 类内 `virtual` 7 处 | content 模式枚举 + 全文件通读交叉核对 |
| 派生统计：0 命中 | `Select-String -Pattern '\bpublic\s+IAudioEndpoint\b'`（`*.h`） |
| 全部行号引用 | 2026-10-10 对 UE 5.8.3 源码本机逐条核对 |

## 相关文档

- `modules/AudioExtensions-结构.md` —— IAudioEndpoint 所在模块（同批产出）
- `types/FMixerDevice.md` —— 同批类型
- `types/FRenderResource.md` —— 另一"虚接口覆写模型"参照（批 4）
- `modules/EnhancedInput-结构.md` —— 另一"IModularFeature 扩展点"参照（批 3）
