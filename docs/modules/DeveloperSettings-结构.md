> 引擎版本：UE 5.8.3 (Build 58210709)
> 源码根：Engine/Source
> 生成技能：ue-module-structure v1.0
> 生成时间：2026-10-10
> 校验状态：已校验（2026-10-11）

# DeveloperSettings 模块结构

## 一、模块定位

| 项 | 值 |
|---|---|
| 路径 | `Engine/Source/Runtime/DeveloperSettings` |
| 类别 | Runtime |
| 规模 | 10 文件 / 4 头文件（`_meta/engine-modules.json` 2026-10-10 口径；本模块极简） |
| 分层 | 框架 |
| 一句话职责 | 设置基础设施：`UDeveloperSettings`（设置类基类，config 驱动 + 编辑器设置面板自动注册）、`UDeveloperSettingsBackedByCVars`、平台设置体系（`UPlatformSettings` / `UPlatformSettingsManager`） |

## 二、目录结构

```
DeveloperSettings/
├── DeveloperSettings.Build.cs    # 模块构建脚本（17 行；0 处 if 分支）
├── Public/Engine/                # 公开侧（4 个 .h，全部在此目录）
│   ├── DeveloperSettings.h               # UDeveloperSettings
│   ├── DeveloperSettingsBackedByCVars.h  # UDeveloperSettingsBackedByCVars
│   ├── PlatformSettings.h                # UPlatformSettings
│   └── PlatformSettingsManager.h         # UPlatformSettingsManager
└── Private/                      # 实现（DeveloperSettingsModule.cpp + Engine/ 下 4 个 .cpp）
```

- 无 `Internal/`、无 `Tests/`（实测 0 命中）；无聚合头。

## 三、依赖关系

### 3.1 无条件依赖

| 模块 | 类型 | Build.cs 行 | 说明 |
|---|---|---|---|
| `Core` | 私有依赖 | 11 | |
| `CoreUObject` | 私有依赖 | 12 | |
| `Projects` | 私有依赖 | 13 | |

> 本模块**无公开依赖列表**；辅助函数检查：**无**——无未展开依赖。

### 3.2 平台与配置条件依赖

**无**——`DeveloperSettings.Build.cs` 全文 **0 处 `if` 分支**（实测）。

### 3.3 第三方静态依赖

调用 **0 处**——无第三方静态依赖。

## 四、对外暴露面

> 公开侧共 4 个 `.h`（全在 `Public/Engine/` 子目录下）。

| 头文件 | 提供的能力 |
|---|---|
| `Engine/Source/Runtime/DeveloperSettings/Public/Engine/DeveloperSettings.h` | `UDeveloperSettings`（第 23 行，`: public UObject`）→ `types/UDeveloperSettings.md` |
| `Engine/Source/Runtime/DeveloperSettings/Public/Engine/DeveloperSettingsBackedByCVars.h` | `UDeveloperSettingsBackedByCVars`（第 20 行） |
| `Engine/Source/Runtime/DeveloperSettings/Public/Engine/PlatformSettings.h` | `UPlatformSettings`（第 58 行）、相关 `USTRUCT`（第 23 行起） |
| `Engine/Source/Runtime/DeveloperSettings/Public/Engine/PlatformSettingsManager.h` | `UPlatformSettingsManager`（第 40 行） |

## 五、模块生命周期

```
文件：Engine/Source/Runtime/DeveloperSettings/Private/DeveloperSettingsModule.cpp
行 6：class FDeveloperSettingsModule : public IModuleInterface
行 22：IMPLEMENT_MODULE(FDeveloperSettingsModule, DeveloperSettings );
```

- **`StartupModule()`**（第 14-17 行）与 **`ShutdownModule()`**（第 18-21 行）**均为空实现**——本模块不含任何启动注册逻辑（设置类经反射自动发现，见类型篇）。
- **`SupportsDynamicReloading`**：未覆写（模块内 0 命中）。

## 六、关键约定与坑

1. **`UPlatformSettings` 不派生自 `UDeveloperSettings`**（实测：`PlatformSettings.h` 第 58 行 `: public UObject`）；`UPlatformSettingsManager` 同样直接派生 `UObject`（第 40 行）——平台设置与 DeveloperSettings 基类是**并列**的两套体系，不要按名字假定继承关系。
2. **公开头都在 `Public/Engine/` 子目录**——按 `Public/DeveloperSettings.h` 猜路径会落空。
3. **模块入口为空实现**：`FDeveloperSettingsModule` 不做任何注册——设置类的注册由引擎的反射/配置系统完成，不是模块启动逻辑。
4. **数字口径**：`DeveloperSettings.Build.cs` 17 行（`ReadAllLines`）、0 处 `if`、0 处三方静态调用；公开侧 4 个 `.h`。取数命令见「取数说明」。

## 取数说明

以下命令的相对基准为 `Engine/Source`（实际路径按 `_meta/convention.md` 的本机环境块解析）：

| 断言 | 取数方式 |
|---|---|
| 10 文件 / 4 头文件 | `[M]` 引擎磁盘递归计数：`(Get-ChildItem "Runtime/DeveloperSettings" -Recurse -File).Count` 得文件数；`(Get-ChildItem "Runtime/DeveloperSettings" -Recurse -File -Filter *.h).Count` 得头文件数（同 `_meta/engine-modules.json` 口径） |
| 公开侧 4 个 `.h`（均在 `Public/Engine/`） | `[M]` `(Get-ChildItem "Runtime/DeveloperSettings/Public" -Recurse -File -Filter *.h).Count` |
| Build.cs 17 行、0 处 `if`、0 处三方静态调用 | `[M]` `[System.IO.File]::ReadAllLines("Runtime/DeveloperSettings/DeveloperSettings.Build.cs").Count`；`Select-String "Runtime/DeveloperSettings/DeveloperSettings.Build.cs" -Pattern '\bif\s*\(' -AllMatches`；`Select-String "Runtime/DeveloperSettings/DeveloperSettings.Build.cs" -Pattern 'AddEngineThirdPartyPrivateStaticDependencies' -AllMatches` |
| 全部行号引用 | 2026-10-10 对 UE 5.8.3 源码本机逐条核对 |

## 相关文档

- `types/UDeveloperSettings.md` —— 本模块核心类型（同批产出）
- `modules/CoreUObject-结构.md` —— `UObject` 基类链所在模块
- `modules/GameplayTags-结构.md` —— 其派生类 `UGameplayTagsDeveloperSettings` 的宿主模块

## 更新记录

- 2026-10-11 按规范 4.2.1 为「取数说明」各行加方法标记（`[M]`/`[R]`/`[H]`）；`[M]` 行把原文省略成 `(...)` 的路径补全为白名单可执行命令，现由 `ue-doc-verify` 逐条实际执行比对
