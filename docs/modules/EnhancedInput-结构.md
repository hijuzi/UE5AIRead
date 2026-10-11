> 引擎版本：UE 5.8.3 (Build 58210709)
> 源码根：Engine/Source
> 生成技能：ue-module-structure v1.0
> 生成时间：2026-10-10
> 校验状态：已校验（2026-10-11）

# EnhancedInput 模块结构

## 一、模块定位

| 项 | 值 |
|---|---|
| 路径 | `Engine/Plugins/EnhancedInput/Source/EnhancedInput` |
| 类别 | Plugins（插件 `EnhancedInput` 的运行时模块） |
| 规模 | 42 文件 / 21 头文件（`_meta/engine-modules.json` 2026-10-10 口径） |
| 分层 | 框架 |
| 一句话职责 | 增强输入系统的运行时实现：`UInputAction`（动作资产）、`UInputMappingContext`（映射上下文）、`UInputTrigger` / `UInputModifier`（触发与修饰）、`UEnhancedInputComponent` / `UEnhancedPlayerInput` 与子系统——现行标准输入方案 |

## 二、目录结构

```
EnhancedInput/
├── EnhancedInput.Build.cs        # 模块构建脚本（27 行；0 处 if 分支）
├── Public/                       # 公开侧（20 个 .h + UserSettings/ 1 个 .h）
│   ├── InputAction.h / InputMappingContext.h / EnhancedInputComponent.h / EnhancedInputSubsystems.h
│   ├── EnhancedPlayerInput.h / InputTriggers.h / InputModifiers.h / InputActionValue.h
│   └── UserSettings/EnhancedInputUserSettings.h
└── Private/                      # 实现（20 个 .cpp；含 UserSettings/）
```

- 公开侧为单目录 `Public/`；无 `Internal/`、无 `Tests/`；**无聚合头**（不存在 `EnhancedInput.h`，实测 0 命中）。

## 三、依赖关系

### 3.1 无条件依赖

| 模块 | 类型 | Build.cs 行 | 说明 |
|---|---|---|---|
| `ApplicationCore` | 私有依赖 | 14 | |
| `Core` | 私有依赖 | 15 | |
| `CoreUObject` | 私有依赖 | 16 | |
| `Engine` | 私有依赖 | 17 | |
| `InputCore` | 私有依赖 | 18 | |
| `Slate` | 私有依赖 | 19 | |
| `SlateCore` | 私有依赖 | 20 | |
| `DeveloperSettings` | 私有依赖 | 21 | |
| `GameplayTags` | 私有依赖 | 22 | |

> 本模块**无公开依赖列表**（Build.cs 中不存在 `PublicDependencyModuleNames`）；依赖列表唯一、无重复。
> 辅助函数检查：**无**自定义辅助函数/属性，无 UBT 辅助函数调用——**无未展开依赖**。

### 3.2 平台与配置条件依赖

**无**——`EnhancedInput.Build.cs` 全文 **0 处 `if` 分支**（实测）。

### 3.3 第三方静态依赖

`AddEngineThirdPartyPrivateStaticDependencies` 调用 **0 处**——本模块无第三方静态依赖。

## 四、对外暴露面

> 公开侧共 21 个 `.h`，本模块规模小，**全列**。

| 头文件 | 提供的能力 |
|---|---|
| `InputAction.h` | `UInputAction`（第 55 行）动作资产 |
| `InputMappingContext.h` | `UInputMappingContext`（第 87 行）映射上下文 |
| `EnhancedInputComponent.h` | `UEnhancedInputComponent`（第 373 行）绑定入口组件 |
| `EnhancedInputSubsystems.h` | `UEnhancedInputLocalPlayerSubsystem`（第 21 行） |
| `EnhancedPlayerInput.h` | `UEnhancedPlayerInput`（第 94 行） |
| `InputTriggers.h` | `UInputTrigger`（第 113 行）及内置触发器 |
| `InputModifiers.h` | `UInputModifier`（第 16 行）及内置修饰器 |
| `InputActionValue.h` | `FInputActionValue`（第 124 行 `GetValueType()`） |
| `EnhancedInputSubsystemInterface.h` | 子系统接口 |
| `EnhancedInputModule.h` | 模块接口 `IEnhancedInputModule`（第 27 行） |
| `EnhancedInputLibrary.h` | 蓝图函数库 |
| `EnhancedActionKeyMapping.h` | 键映射描述 |
| `EnhancedInputActionDelegateBinding.h` | 蓝图委托绑定 |
| `InputDebugKeyDelegateBinding.h` | 调试键绑定 |
| `InputMappingQuery.h` | 映射查询 |
| `PlayerMappableInputConfig.h` | 可重映射配置 |
| `PlayerMappableKeySettings.h` | 可重映射键设置 |
| `EnhancedInputDeveloperSettings.h` | 开发者设置 |
| `EnhancedInputPlatformSettings.h` | 平台设置 |
| `EnhancedInputWorldProcessor.h` | 世界处理器 |
| `UserSettings/EnhancedInputUserSettings.h` | 用户设置 |

## 五、模块生命周期

```
文件：Engine/Plugins/EnhancedInput/Source/EnhancedInput/Private/EnhancedInputModule.cpp
行 27：class FEnhancedInputModule : public IEnhancedInputModule, public FTickableGameObject

文件：Engine/Plugins/EnhancedInput/Source/EnhancedInput/Private/EnhancedInputModule.cpp
行 234：IMPLEMENT_MODULE(FEnhancedInputModule, EnhancedInput)
```

- **接口**：`IEnhancedInputModule : IModuleInterface`（`Public/EnhancedInputModule.h` 第 27 行）
- **模块类**还实现 `FTickableGameObject`（非专用服务器时以 `Always` 频率 Tick，第 37-53 行）
- **`StartupModule()`**（第 236-281 行）要点：
  1. 创建蓝图库对象并 `AddToRoot()`（第 238-239 行）
  2. 注册按键菜单分类与已废弃 ComboKey（第 243-244 行）
  3. 非专用服务器下挂 HUD 调试回调（第 247-251 行，`ENABLE_DRAW_DEBUG`）
  4. 注册 4 条 cheat 控制台命令：`Input.+action`（第 254 行）、`Input.-action`（261）、`Input.+key`（268）、`Input.-key`（275）
- **`ShutdownModule()`**（第 283-295 行）：注销控制台命令、释放根引用
- **`SupportsDynamicReloading`**：未覆写（模块内 0 命中）

## 六、关键约定与坑

1. **类声明不带类级导出宏**：使用 `UCLASS(MinimalAPI, ...)` + 逐成员 `UE_API`（各公开头文件顶部 `#define UE_API ENHANCEDINPUT_API`，如 `InputAction.h` 第 11 行；文件尾 `#undef UE_API` 第 283 行）——按 `class ENHANCEDINPUT_API UInputAction` 检索会零命中。
2. **模块位于 Plugins 下**：真实路径 `Engine/Plugins/EnhancedInput/Source/EnhancedInput`，**不是** `Engine/Source/Runtime/...`。
3. **无聚合头**（不存在 `EnhancedInput.h`）——按需包含具体头文件。
4. **数字口径**：`EnhancedInput.Build.cs` 27 行（`ReadAllLines`）、0 处 `if`、0 处三方静态调用；公开侧 21 个 `.h`。取数命令见「取数说明」。

## 取数说明

以下命令的相对基准为 `Engine/Source`（实际路径按 `_meta/convention.md` 的本机环境块解析；本模块在 `Engine/Plugins/` 下）：

| 断言 | 取数方式 |
|---|---|
| `WITH_EDITOR` 下注册 **4** 条 cheat 命令 | `[H]` 逐行通读注册段（第 254 / 261 / 268 / 275 行）：`Input.+action`、`Input.-action`、`Input.+key`、`Input.-key` = **4** |
| 42 文件 / 21 头文件 | `[M]` 引擎磁盘递归计数：`(Get-ChildItem "Engine/Plugins/EnhancedInput/Source/EnhancedInput" -Recurse -File).Count` 得文件数；`(Get-ChildItem "Engine/Plugins/EnhancedInput/Source/EnhancedInput" -Recurse -File -Filter *.h).Count` 得头文件数（同 `_meta/engine-modules.json` 口径） |
| Build.cs 27 行、0 处 `if`、0 处三方静态调用 | `[M]` `[System.IO.File]::ReadAllLines("Engine/Plugins/EnhancedInput/Source/EnhancedInput/EnhancedInput.Build.cs").Count`；`Select-String "Engine/Plugins/EnhancedInput/Source/EnhancedInput/EnhancedInput.Build.cs" -Pattern '\bif\s*\(' -AllMatches`；`Select-String "Engine/Plugins/EnhancedInput/Source/EnhancedInput/EnhancedInput.Build.cs" -Pattern 'AddEngineThirdPartyPrivateStaticDependencies' -AllMatches` |
| 公开侧 21 个 `.h` | `[H]` 目录枚举（`Public/` + `Public/UserSettings/`） |
| 全部行号引用 | 2026-10-10 对 UE 5.8.3 源码本机逐条核对 |

## 相关文档

- `types/UInputAction.md` —— 本模块核心类型（同批产出）
- `modules/Engine-结构.md` —— 承载输入组件的框架模块（已校验）
- `modules/Core-结构.md` —— 上游地基模块
- `flows/UObject创建流程.md` —— 对象创建主路径（已校验）

## 更新记录

- 2026-10-11 「取数说明」补入 1 行计数断言取数方式（`convention.md` 4.2 覆盖要求）

- 2026-10-11 按规范 4.2.1 为「取数说明」各行加方法标记（`[M]`/`[R]`/`[H]`）；`[M]` 行把原文省略成 `(...)` 的路径补全为白名单可执行命令，现由 `ue-doc-verify` 逐条实际执行比对
