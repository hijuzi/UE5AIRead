> 引擎版本：UE 5.8.3 (Build 58210709)
> 源码根：Engine/Source
> 生成技能：ue-module-structure v1.0
> 生成时间：2026-10-10
> 校验状态：已校验（2026-10-10）

# UniversalObjectLocator 模块结构

## 一、模块定位

| 项 | 值 |
|---|---|
| 路径 | `Engine/Source/Runtime/UniversalObjectLocator` |
| 类别 | Runtime |
| 规模 | 32 文件 / 18 头文件（`_meta/engine-modules.json` 2026-10-10 口径；公开侧 **17** + `Private/` 1） |
| 分层 | 框架 |
| 一句话职责 | 通用对象定位器框架：把对象/子对象引用表示为**可序列化的定位器**（`FUniversalObjectLocator`），经 Fragment 类型（`subobj` / `uobj` / `ls_lazy_obj_ptr` …）解析回对象——MovieScene / LevelSequence 动态绑定与资产引用的底座 |

## 二、目录结构

```
UniversalObjectLocator/
├── UniversalObjectLocator.Build.cs   # 模块构建脚本（19 行、0 处 if 分支）
├── UniversalObjectLocator.natvis
├── Public/                           # 公开侧 17 个 .h + 1 个 .inl
│   ├── UniversalObjectLocator.h / UniversalObjectLocatorFragment.h / UniversalObjectLocatorFragmentType.h /
│   │   UniversalObjectLocatorFragmentTypeHandle.h / UniversalObjectLocatorParameterTypeHandle.h /
│   │   UniversalObjectLocatorResolveParams.h / UniversalObjectLocatorInitializeParams.h /
│   │   UniversalObjectLocatorInitializeResult.h / UniversalObjectLocatorStringParams.h /
│   │   UniversalObjectLocatorStringUtils.h / UniversalObjectLocatorType.h / UniversalObjectLocatorFwd.h /
│   │   UniversalObjectLocatorFragmentDebugging.h / IUniversalObjectLocatorModule.h /
│   │   SubObjectLocator.h / DirectPathObjectLocator.h
│   └── + UniversalObjectLocatorResolveParameterBuffer.inl
└── Private/                          # UniversalObjectLocatorRegistry.h + 11 个 .cpp
```

- 无 `Internal/`、无 `Tests/`；无聚合头（`UniversalObjectLocatorFwd.h` 为前置声明集合，被 9 个公开头包含）。

## 三、依赖关系

### 3.1 无条件依赖

| 模块 | 类型 | Build.cs 行 | 说明 |
|---|---|---|---|
| `Core` | 公开依赖 | 13 | |
| `CoreUObject` | 公开依赖 | 14 | |
| `HTTP` | 公开依赖 | 15 | 网络路径解析场景 |

> 警告等级：`UnsafeTypeCastWarningLevel = WarningLevel.Error;`（第 9 行）。
> 辅助函数检查：**无**——无未展开依赖。

### 3.2 平台与配置条件依赖

**无**——全文 **0 处 `if` 分支**（实测）。

### 3.3 第三方静态依赖

调用 **0 处**——无第三方静态依赖。

## 四、对外暴露面

> 公开侧共 17 个 `.h`；核心如下。

| 头文件 | 提供的能力 |
|---|---|
| `Engine/Source/Runtime/UniversalObjectLocator/Public/UniversalObjectLocator.h` | `FUniversalObjectLocator`（第 31 行）→ `types/FUniversalObjectLocator.md` |
| `Engine/Source/Runtime/UniversalObjectLocator/Public/UniversalObjectLocatorFragment.h` | `FUniversalObjectLocatorFragment`（第 35 行，`alignas(8)`） |
| `Engine/Source/Runtime/UniversalObjectLocator/Public/UniversalObjectLocatorFragmentType.h` | `FFragmentType`（第 69 行）——Fragment 类型描述 |
| `Engine/Source/Runtime/UniversalObjectLocator/Public/UniversalObjectLocatorFragmentTypeHandle.h`、`UniversalObjectLocatorParameterTypeHandle.h` | 类型句柄（8 位索引封装） |
| `Engine/Source/Runtime/UniversalObjectLocator/Public/UniversalObjectLocatorResolveParams.h` | `FResolveParams`（第 46 行）/ `FResolveResult`（第 204 行） |
| `Engine/Source/Runtime/UniversalObjectLocator/Public/UniversalObjectLocatorInitializeParams.h`、`UniversalObjectLocatorInitializeResult.h` | `FInitializeParams`（第 15 行）等 |
| `Engine/Source/Runtime/UniversalObjectLocator/Public/IUniversalObjectLocatorModule.h` | `IUniversalObjectLocatorModule`（第 37 行；`RegisterFragmentType` 模板第 70 行；`RegisterFragmentTypeImpl` 纯虚第 129 行） |
| `Engine/Source/Runtime/UniversalObjectLocator/Public/SubObjectLocator.h`、`DirectPathObjectLocator.h` | 内置 Fragment 类型（`subobj` / `uobj`） |
| `Engine/Source/Runtime/UniversalObjectLocator/Public/UniversalObjectLocatorStringParams.h`、`UniversalObjectLocatorStringUtils.h`、`UniversalObjectLocatorFragmentDebugging.h` | 字符串解析与调试 |

> **注册表在 Private**：`FRegistry`（`Private/UniversalObjectLocatorRegistry.h` 第 14 行，`: FGCObject`；`Get()` 第 17 行）——外部只能经模块接口访问。

## 五、模块生命周期

```
文件：Engine/Source/Runtime/UniversalObjectLocator/Private/UniversalObjectLocatorModule.cpp
行 17-18：class FUniversalObjectLocatorModule / : public IUniversalObjectLocatorModule（位于 namespace UE::UniversalObjectLocator）
行 93：IMPLEMENT_MODULE(UE::UniversalObjectLocator::FUniversalObjectLocatorModule, UniversalObjectLocator);
```

- **`StartupModule()`**（第 25-43 行）：
  1. `FDelayedAutoRegisterHelper(EDelayedRegisterRunPhase::ObjectSystemReady, ...)`（第 28-29 行，延迟到对象系统就绪）
  2. 注册 Fragment 类型 `"subobj"` → `FSubObjectLocator`（第 32-34 行）
  3. 注册 Fragment 类型 `"uobj"` → `FDirectPathObjectLocator`（第 38-39 行）
  4. 落库经 `RegisterFragmentTypeImpl`（第 50-64 行；`checkf` 限制 Fragment 类型数 ≤ uint8 上限）
  5. 调试可视化 ID 与状态登记（第 23 行 GGuid；第 61 行 `FVisualizerDebuggingState::Assign`）
- **`ShutdownModule()`**（第 45-48 行）：近空；`UnregisterFragmentTypeImpl`（第 66-69 行）仅置空槽位、**索引不回收**。
- **`SupportsDynamicReloading`**：未覆写（0 命中）。
- **消费实例（跨模块证据）**：LevelSequence 模块 Startup 注册 `"ls_lazy_obj_ptr"`（`LevelSequence/Private/LevelSequenceModule.cpp` 第 26 行）；Engine 注册 `FActorLocatorFragment` / `FAssetLocatorFragment` / `FAnimInstanceLocatorFragment`（`Engine/Source/Runtime/Engine/Private/UnrealEngine.cpp` 第 416 / 422 / 427 行）。

## 六、关键约定与坑

1. **公开侧是 17 个 `.h`**（模块合计 18 = 17 + `Private/UniversalObjectLocatorRegistry.h`）；`Public/UniversalObjectLocatorRegistry.h` **不存在**。
2. **注册表类名是 `FRegistry`**（Private），不存在 `FUniversalObjectLocatorRegistry` / `FFragmentTypeRegistry`（实测 0 命中）。
3. **类名先验修正**：`FResolveParams`（非 `FUniversalObjectLocatorResolveParams`）、`FInitializeParams`（非 `FUniversalObjectLocatorInitializeParams`）、`FParseStringParams`——都在 `UE::UniversalObjectLocator` 命名空间内。
4. **有 `.inl` 伴生头**（`UniversalObjectLocatorResolveParameterBuffer.inl`）。
5. **依赖含 `HTTP`**（第 15 行）。
6. **数字口径**：`UniversalObjectLocator.Build.cs` 19 行（`ReadAllLines`）、0 处 `if`、0 处三方静态调用；公开侧 17 个 `.h`。取数命令见「取数说明」。

## 取数说明

以下命令的相对基准为 `Engine/Source`（实际路径按 `_meta/convention.md` 的本机环境块解析）：

| 断言 | 取数方式 |
|---|---|
| 32 文件 / 18 头文件 | `_meta/engine-modules.json` 中 `Module -eq 'UniversalObjectLocator'` 行的 `Files`、`Headers` 字段；公开 17 + Private 1 复核 |
| 公开侧 17 个 `.h` | `(Get-ChildItem "Runtime/UniversalObjectLocator/Public" -Recurse -File -Filter *.h).Count` |
| Build.cs 19 行、0 处 `if`、0 处三方静态调用 | `[System.IO.File]::ReadAllLines(...).Count`；`\bif\s*\(` 与 `AddEngineThirdPartyPrivateStaticDependencies` 全匹配计数 |
| 全部行号引用 | 2026-10-10 对 UE 5.8.3 源码本机逐条核对 |

## 相关文档

- `types/FUniversalObjectLocator.md` —— 本模块代表类型（同批产出）
- `modules/TimeManagement-结构.md` —— 同批模块
- `modules/LevelSequence-结构.md` —— 首个跨模块消费者（`ls_lazy_obj_ptr`，批 9）
- `types/UMovieSceneSequence.md` —— 动态绑定契约（批 6）
