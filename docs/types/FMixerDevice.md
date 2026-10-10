> 引擎版本：UE 5.8.3 (Build 58210709)
> 源码根：Engine/Source
> 生成技能：ue-type-api v1.0
> 生成时间：2026-10-10
> 校验状态：已校验（2026-10-10）

# FMixerDevice

## 一、类型概览

| 项 | 值 |
|---|---|
| 全限定名 | `Audio::FMixerDevice`（命名空间 `Audio`） |
| 定义位置 | `Engine/Source/Runtime/AudioMixer/Public/AudioMixerDevice.h` |
| 类型 | 类（纯 C++；**非 UObject**——文件内的 `UENUM` 服务于枚举，类本身无反射） |
| 导出策略 | 逐成员 `AUDIOMIXER_API`（类声明行无宏） |
| 所属模块 | `AudioMixer`（`Engine/Source/Runtime/AudioMixer`） |

## 二、继承链

```
Audio::FMixerDevice（AudioMixerDevice.h 第 123-125 行）
  ├─ FAudioDevice（Engine/Source/Runtime/Engine/Public/AudioDevice.h 第 416 行，`: public FExec`）
  │    └─ FExec（Engine/Source/Runtime/Core/Public/Misc/Exec.h 第 28 行；链根，无基类）
  ├─ IAudioMixer（Engine/Source/Runtime/AudioMixerCore/Public/AudioMixer.h 第 139 行；无基类）
  └─ FGCObject（Engine/Source/Runtime/CoreUObject/Public/UObject/GCObject.h 第 127 行；无基类）
```

## 三、声明片段

```
文件：Engine/Source/Runtime/AudioMixer/Public/AudioMixerDevice.h （namespace Audio 第 42 行起）
行 123-125：class FMixerDevice : public FAudioDevice, public IAudioMixer, public FGCObject
行 577：类体结束（};；文件 579 行）
```

## 四、公开 API

| 签名 | 说明 | 位置 |
|---|---|---|
| `FMixerDevice(IAudioMixerPlatformInterface*)` | 构造（注入平台后端） | 第 128 行 |
| `FindSubmixInstanceByObjectId(uint32)` / `GetSubmixInstance(const USoundSubmixBase*) const` | 子混音实例查询 | 第 235 / 237 行 |
| `GetFactoryForSubmixInstance(USoundSubmix*)` | 子混音的 Soundfield 工厂 | 第 242 行 |
| `CheckAudioThread() const` / `CheckAudioRenderingThread() const` / `IsAudioRenderingThread() const` | 线程断言与判定 | 第 246-248 行 |
| `GetMixerSourceVoice()` / `GetNumSources() const` | 源声部管理 | 第 251 / 253 行 |
| `GetAudioLinkFactory() const` | AudioLink 工厂 | 第 256 行 |
| `GetAudioMixerPlatform() const`（inline） | 平台后端访问 | 第 268 行 |
| `Get3DChannelMap(...)` / `Get2DChannelMap(...) const`（含 static 版） | 声道映射 | 第 271 / 274 / 275 行 |
| `GetDeviceSampleRate() const` / `GetDeviceOutputChannels() const` | 设备参数 | 第 277 / 278 行 |
| `GetSourceManager()` | 源管理器 | 第 280 行 |
| `GetBaseDefaultSubmix()` / `GetMainSubmix()` / `GetReverbSubmix()` / `GetEQSubmix()` | 内置子混音访问 | 第 285-288 行 |
| `AddSubmixEffect(USoundSubmix*, FSoundEffectSubmixPtr)` | 挂载子混音效果 | 第 308 行 |
| `static IsEndpointSubmix(const USoundSubmixBase*)` | 判定端点子混音 | 第 340 行 |
| `MakePatch(int32, int32, float) const` | 创建音频补丁输出 | 第 342 行 |
| `AudioRenderThreadCommand(TFunction<void()>)` | 音频渲染线程命令 | 第 356 行 |
| `DrawSubmixes(...) const` | 调试绘制 | 第 362 行 |
| `CreateGeneratorSource(ISoundGeneratorRef)`（`UE_EXPERIMENTAL(5.8, ...)`，第 378 行） | 生成器源工厂 | 第 379 行 |

## 五、扩展点

### 5.1 可覆写虚函数

> 类体内 `\bvirtual\b` 全匹配 **65 处**；分组：

| 组 | 规模 | 代表（行号） |
|---|---|---|
| `//~ Begin FAudioDevice` 契约区（第 131-220 行） | **58 处** | `UpdateDeviceDeltaTime`(132)、`Exec`(148，`UE_ALLOW_EXEC_COMMANDS` 内) 等 |
| `//~ Begin IAudioMixer` 区（第 222-225 行） | 2 处 | `OnProcessAudioStream`(223)、`OnAudioStreamShutdown`(224) |
| `//~ Begin FGCObject` 区（第 227-233 行） | 2 处 | `AddReferencedObjects`(228)、`GetReferencerName`(229) |
| 中段其它覆写 | 3 处 | `GetMainSubmixObject`(283)、`InitSoundSubmixes`(382)、`OnListenerUpdated`(384) |

### 5.2 不建议覆写的内部虚函数

无单列——A 组为 `FAudioDevice` 实现者义务面（音频设备抽象的核心契约）。

## 六、生命周期

- **设备创建**：构造注入 `IAudioMixerPlatformInterface`（第 128 行；接口在 AudioMixerCore，`AudioMixerCore/Public/AudioMixer.h` 第 422 行）。
- **音频渲染循环**：`IAudioMixer::OnProcessAudioStream` / `OnAudioStreamShutdown`（第 223-224 行）；音频线程命令投递经 `AudioRenderThreadCommand`（第 356 行）。
- **GC 集成**：`FGCObject::AddReferencedObjects`（第 228 行）——混合器持有的 UObject 引用参与 GC。

## 七、派生类（范围内）

搜索边界：派生类搜索**仅覆盖本版纳入范围的 292 个模块**（Runtime 291 个 + `EnhancedInput` 插件）。搜索模式 `\bpublic\s+FMixerDevice\b`（`*.h`）：Runtime **0 命中**；EnhancedInput **0**（另以 `Engine/Source` 全树复核仍为 0）。

| 派生类 | — |
|---|---|
| （无） | 叶子类 |

> 配套定位：`FMixerSubmix`（`AudioMixer/Public/AudioMixerSubmix.h` 第 112 行）、`FMixerSource`（`AudioMixer/Private/AudioMixerSource.h` 第 30 行）、`IAudioMixerPlatformInterface`（`AudioMixerCore/Public/AudioMixer.h` 第 422 行）。

## 取数说明

| 断言 | 取数方式（相对基准：`Engine/Source`） |
|---|---|
| 文件 579 行、类体 123-577 | `[System.IO.File]::ReadAllLines(...).Count` + `^};` 检索 |
| 类内 `virtual` 65 处 | content 模式枚举 + 全文件通读交叉核对 |
| 派生统计：0 命中 | `Select-String -Pattern '\bpublic\s+FMixerDevice\b'`（`*.h`） |
| 全部行号引用 | 2026-10-10 对 UE 5.8.3 源码本机逐条核对 |

## 相关文档

- `modules/AudioMixer-结构.md` —— FMixerDevice 所在模块（同批产出）
- `types/IAudioEndpoint.md` —— 同批类型
- `modules/Engine-结构.md` —— `FAudioDevice` 归属
- `modules/RHI-结构.md` —— 另一"设备抽象 + 后端接口"参照（批 4）
