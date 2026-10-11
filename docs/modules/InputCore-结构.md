> 引擎版本：UE 5.8.3 (Build 58210709)
> 源码根：Engine/Source
> 生成技能：ue-module-structure v1.0
> 生成时间：2026-10-10
> 校验状态：已校验（2026-10-11）

# InputCore 模块结构

## 一、模块定位

| 项 | 值 |
|---|---|
| 路径 | `Engine/Source/Runtime/InputCore` |
| 类别 | Runtime |
| 规模 | 21 文件 / 11 头文件（`_meta/engine-modules.json` 2026-10-10 口径；公开侧 10 + `Classes/` 1） |
| 分层 | 输入 |
| 一句话职责 | 输入基础类型层：`FKey` 键值类型与 `EKeys` 键表（`Classes/InputCoreTypes.h`）、平台输入（GenericPlatform / Windows / Mac / Linux / IOS / Android 的 `*PlatformInput`）与调试接口（`IInputDebuggingInterface`）——Engine / EnhancedInput 输入栈的底层依赖 |

## 二、目录结构

```
InputCore/
├── InputCore.Build.cs        # 模块构建脚本（23 行、2 处 if 分支）
├── Classes/InputCoreTypes.h  # FKey(49) / FKeyDetails(145) / FTouchId(283) / EKeys(345) / FInputKeyManager(847) / UInputCoreTypes(872)
├── Public/                   # 公开侧 10 个 .h
│   ├── InputCore.h / InputCoreModule.h / IInputDebuggingInterface.h
│   ├── GenericPlatform/GenericPlatformInput.h      # FGenericPlatformInput(11)
│   ├── Windows/ Mac/ Linux/ IOS/ Android/          # 各平台 *PlatformInput（Mac/IOS 为类级 INPUTCORE_API）
│   └── HAL/PlatformInput.h
└── Private/                  # 6 个 .cpp：InputCore.cpp / InputCoreModule.cpp / InputCoreTypes.cpp(103.95 KB) + 6 个平台实现目录
```

- 无 `Internal/`、无 `Tests/`（实测 0 命中）。

## 三、依赖关系

### 3.1 无条件依赖

| 模块 | 类型 | Build.cs 行 | 说明 |
|---|---|---|---|
| `Core`、`CoreUObject` | 公开依赖 | 11 | 单条 `AddRange(new string[] { "Core", "CoreUObject" })` |

> `bRequiresPlatformSDK = true;`（第 9 行）；警告等级第 21 行；辅助函数检查：**无**——无未展开依赖。

### 3.2 平台与配置条件依赖

> 全文 **2 处 `if` 分支**（第 13、17 行）——均为**私有包含路径**（非链接依赖）。

| 模块 | 类型 | 生效条件 | Build.cs 行 |
|---|---|---|---|
| `ApplicationCore` | 私有包含路径 | `Target.IsInPlatformGroup(UnrealPlatformGroup.IOS)` | 13-16 |
| `SDL3` | 私有包含路径 | `Target.IsInPlatformGroup(UnrealPlatformGroup.Linux)` | 17-20 |

### 3.3 第三方静态依赖

调用 **0 处**——无第三方静态依赖。

## 四、对外暴露面

| 头文件 | 提供的能力 |
|---|---|
| `Engine/Source/Runtime/InputCore/Classes/InputCoreTypes.h` | `FKey`（第 49 行）→ `types/FKey.md`；另有 `FKeyDetails`（145）/ `FTouchId`（283）/ `EKeys`（345）/ `FInputKeyManager`（847）/ `UInputCoreTypes`（872） |
| `Engine/Source/Runtime/InputCore/Public/InputCoreModule.h` | 模块类 `FInputCoreModule`（第 8 行） |
| `Engine/Source/Runtime/InputCore/Public/InputCore.h` | 聚合小头（include Module + Types，第 5-6 行） |
| `Engine/Source/Runtime/InputCore/Public/IInputDebuggingInterface.h` | `IInputDebuggingInterface`（第 13 行，`: IModuleInterface, IModularFeature`） |
| `Engine/Source/Runtime/InputCore/Public/GenericPlatform/GenericPlatformInput.h` | `FGenericPlatformInput`（第 11 行） |
| `Engine/Source/Runtime/InputCore/Public/Windows/WindowsPlatformInput.h` | `FWindowsPlatformInput`（第 8 行） |
| `Engine/Source/Runtime/InputCore/Public/Mac/MacPlatformInput.h` | `FMacPlatformInput`（第 8 行，类级 `INPUTCORE_API`） |
| `Engine/Source/Runtime/InputCore/Public/IOS/IOSPlatformInput.h` | `FIOSPlatformInput`（第 8 行，类级 `INPUTCORE_API`） |
| `Engine/Source/Runtime/InputCore/Public/Linux/LinuxPlatformInput.h` | `FLinuxPlatformInput`（第 9 行） |
| `Engine/Source/Runtime/InputCore/Public/Android/AndroidPlatformInput.h` | `FAndroidPlatformInput`（第 8 行） |
| `Engine/Source/Runtime/InputCore/Public/HAL/PlatformInput.h` | 平台分发 |

> **`FInputDeviceId` 不在本模块**（在 Core：`Engine/Source/Runtime/Core/Public/Misc/CoreMiscDefines.h` 第 518 行；CoreUObject 侧有 UHT 镜像 `NoExportTypes.h` 第 2617 行）。

## 五、模块生命周期

```
文件：Engine/Source/Runtime/InputCore/Private/InputCore.cpp
行 7：IMPLEMENT_MODULE( FInputCoreModule, InputCore );
```

- **模块类**：`FInputCoreModule : public IModuleInterface`（`Public/InputCoreModule.h` 第 8 行）。
- **覆写情况（特殊）**：**仅覆写 `StartupModule`**（声明第 18 行；实现 `Private/InputCoreModule.cpp` 第 5 行，**空实现**）——**未覆写 `ShutdownModule`**（模块内实测 0 命中）；`SupportsDynamicReloading` 未覆写（0 命中）。
- 即模块启动/关闭均无注册逻辑，纯类型容器模块。

## 六、关键约定与坑

1. **`FKey` 在 `Classes/`**（不在 `Public/`）——`Public/InputCoreTypes.h` 实测不存在；`#include "InputCoreTypes.h"` 按裸名包含（UBT 自动把 `Classes/` 加入公开包含路径）。
2. **未覆写 `ShutdownModule`**（0 命中）——与"成对覆写"惯例不同，按实测记录。
3. **平台 struct 导出不一致**：Mac / IOS 有类级 `INPUTCORE_API`（各第 8 行），Windows / Linux / Android / Generic 无。
4. **数字口径**：`InputCore.Build.cs` 23 行（`ReadAllLines`）、2 处 `if`（均包含路径）、0 处三方静态调用；公开侧 10 个 `.h` + `Classes/` 1 个。取数命令见「取数说明」。

## 取数说明

以下命令的相对基准为 `Engine/Source`（实际路径按 `_meta/convention.md` 的本机环境块解析）：

| 断言 | 取数方式 |
|---|---|
| 21 文件 / 11 头文件 | `[M]` 引擎磁盘递归计数：`(Get-ChildItem "Runtime/InputCore" -Recurse -File).Count` 得文件数；`(Get-ChildItem "Runtime/InputCore" -Recurse -File -Filter *.h).Count` 得头文件数（同 `_meta/engine-modules.json` 口径） |
| 公开侧 10 个 `.h`（Public）+ 1（Classes） | `[M]` `(Get-ChildItem "Runtime/InputCore/Public" -Recurse -File -Filter *.h).Count` 等 |
| Build.cs 23 行、2 处 `if`、0 处三方静态调用 | `[M]` `[System.IO.File]::ReadAllLines("Runtime/InputCore/InputCore.Build.cs").Count`；`Select-String "Runtime/InputCore/InputCore.Build.cs" -Pattern '\bif\s*\(' -AllMatches`；`Select-String "Runtime/InputCore/InputCore.Build.cs" -Pattern 'AddEngineThirdPartyPrivateStaticDependencies' -AllMatches` |
| 全部行号引用 | 2026-10-10 对 UE 5.8.3 源码本机逐条核对 |

## 相关文档

- `types/FKey.md` —— 本模块代表类型（同批产出）
- `modules/EnhancedInput-结构.md` —— 上层输入系统（批 3）
- `modules/SlateRHIRenderer-结构.md` —— 同批模块
- `modules/Core-结构.md` —— `FInputDeviceId` 的实际宿主

## 更新记录

- 2026-10-11 按规范 4.2.1 为「取数说明」各行加方法标记（`[M]`/`[R]`/`[H]`）；`[M]` 行把原文省略成 `(...)` 的路径补全为白名单可执行命令，现由 `ue-doc-verify` 逐条实际执行比对
