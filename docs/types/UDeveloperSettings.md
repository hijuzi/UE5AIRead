> 引擎版本：UE 5.8.3 (Build 58210709)
> 源码根：Engine/Source
> 生成技能：ue-type-api v1.0
> 生成时间：2026-10-10
> 校验状态：已校验（2026-10-11）

# UDeveloperSettings

## 一、类型概览

| 项 | 值 |
|---|---|
| 全限定名 | `UDeveloperSettings`（全局命名空间） |
| 定义位置 | `Engine/Source/Runtime/DeveloperSettings/Public/Engine/DeveloperSettings.h` |
| 类型 | 类（反射类型；设置类基类） |
| 反射宏 | `UCLASS(Abstract, MinimalAPI)`（第 22 行）——**注意：无 `config=`**（config 由派生类自行指定）+ `GENERATED_BODY()`（第 25 行） |
| 导出策略 | `MinimalAPI` + 逐成员 `DEVELOPERSETTINGS_API`（第 28、31、33、35、39、41、48、51、55、70、72 行，共 11 处）；类声明行不带宏（第 23 行） |
| 所属模块 | `DeveloperSettings`（`Engine/Source/Runtime/DeveloperSettings`） |

## 二、继承链

```
UObjectBase            （Engine/Source/Runtime/CoreUObject/Public/UObject/UObjectBase.h 第 66 行；链根）
  └─ UObjectBaseUtility（Engine/Source/Runtime/CoreUObject/Public/UObject/UObjectBaseUtility.h 第 44 行）
       └─ UObject      （Engine/Source/Runtime/CoreUObject/Public/UObject/Object.h 第 98 行）
            └─ UDeveloperSettings（Engine/Source/Runtime/DeveloperSettings/Public/Engine/DeveloperSettings.h 第 23 行）
```

## 三、声明片段

```
文件：Engine/Source/Runtime/DeveloperSettings/Public/Engine/DeveloperSettings.h
行 22-25：UCLASS(Abstract, MinimalAPI) / class UDeveloperSettings : public UObject / { / GENERATED_BODY()

文件：Engine/Source/Runtime/DeveloperSettings/Public/Engine/DeveloperSettings.h
行 77：类体结束（};；文件 77 行）
```

## 四、公开 API

| 签名 / 成员 | 说明 | 位置 |
|---|---|---|
| `UDeveloperSettings(...)` | 构造（默认 `FObjectInitializer::Get()`） | 第 28 行 |
| `GetContainerName()`（虚） | 配置容器名（Project / Editor 判定；实现见 `Engine/Source/Runtime/DeveloperSettings/Private/Engine/DeveloperSettings.cpp` 第 18-34 行） | 第 31 行 |
| `GetCategoryName()`（虚） | 设置分类名（实现第 36-66 行） | 第 33 行 |
| `GetSectionName()`（虚） | 段名（默认 `GetClass()->GetFName()`，实现第 68-76 行） | 第 35 行 |
| `GetSectionText()`（虚；`WITH_EDITOR`） | 显示名（默认取 DisplayName） | 第 39 行 |
| `GetSectionDescription()`（虚；`WITH_EDITOR`） | 描述（默认取 ToolTip） | 第 41 行 |
| `SupportsAutoRegistration()`（虚，inline；`WITH_EDITOR`） | 返回 `false` 可关闭设置面板自动注册 | 第 44 行 |
| `OnSettingChanged()` | 设置变更多播委托（`FOnSettingsChanged`，第 47 行声明） | 第 48 行 |
| `PostEditChangeProperty(...)`（override；`WITH_EDITOR`） | 属性变更响应（设置面板回调） | 第 51 行 |
| `GetCustomSettingsWidget()`（虚） | 自定义设置控件（默认返回空） | 第 55 行 |

> protected 成员：`CategoryName`(63)、`SectionName`(66)、`ImportConsoleVariableValues()`(70)、`ExportValuesToConsoleVariables(...)`(72)、`SettingsChangedDelegate`(75)。
> `GetOwnerCustomSectionName` 在 `Engine/Source` 内**不存在**（实测 0 命中）；`TryUpdateDefaultConfigFile` / `ReloadConfig` / `GetDefaultConfigFilename` **继承自 `UObject`**（`Object.h` 第 1306 / 1425 / 1339 行），不在本类。

## 五、扩展点

### 5.1 可覆写虚函数（类内 8 条，全列）

| 虚函数 | 用途 | 位置 |
|---|---|---|
| `GetContainerName()` | 配置容器（Project / Editor） | 第 31 行 |
| `GetCategoryName()` | 设置分类 | 第 33 行 |
| `GetSectionName()` | 段名 | 第 35 行 |
| `GetSectionText()` | 显示名（编辑器） | 第 39 行 |
| `GetSectionDescription()` | 描述（编辑器） | 第 41 行 |
| `SupportsAutoRegistration()` | 是否自动注册 | 第 44 行 |
| `PostEditChangeProperty(...)` | UObject 覆写（设置面板回调） | 第 51 行 |
| `GetCustomSettingsWidget()` | 自定义设置控件 | 第 55 行 |

### 5.2 不建议覆写的内部虚函数

无。

## 六、生命周期

- 多数为编辑器 / 配置期对象：无 `Tick` / `BeginPlay` 类运行时钩子。
- **config 语义**：派生类经 `UCLASS(config=...)` 绑定 ini 段；读写由继承自 `UObject` 的 `TryUpdateDefaultConfigFile()` / `ReloadConfig()` 驱动（`Object.h` 第 1306 / 1425 行）。
- 自动注册：编辑器下设置类被自动收进 Project Settings 面板（`SupportsAutoRegistration()` 可关闭）。

## 七、派生类（范围内）

搜索边界：派生类搜索**覆盖 Runtime 291 个模块 + `EnhancedInput` 插件全部 3 个模块（共 294 个模块）**。搜索模式 `\bpublic\s+UDeveloperSettings\b`（`*.h`）：Runtime **38 文件 / 42 处命中**；EnhancedInput 插件 **1 命中**（在 `InputEditor` 模块内）。

| 代表派生类 | 位置 | 备注 |
|---|---|---|
| `UDeveloperSettingsBackedByCVars` | `Engine/Source/Runtime/DeveloperSettings/Public/Engine/DeveloperSettingsBackedByCVars.h` 第 20 行 | 同模块；再覆写 `PostInitProperties` / `PostEditChangeProperty`（第 27 / 29 行） |
| `UGameplayTagsDeveloperSettings` | `Engine/Source/Runtime/GameplayTags/Classes/GameplayTagsSettings.h` 第 193 行 | 批 2 模块内 |
| `UEnhancedInputEditorProjectSettings` | `Engine/Plugins/EnhancedInput/Source/InputEditor/Public/EnhancedInputEditorSettings.h` 第 19 行 | 批 3 模块内（InputEditor） |
| `UEnhancedInputDeveloperSettings` | `Engine/Plugins/EnhancedInput/Source/EnhancedInput/Public/EnhancedInputDeveloperSettings.h` 第 43 行 | **间接**（经 `UDeveloperSettingsBackedByCVars`） |
| `UEnhancedInputEditorSettings` | `Engine/Plugins/EnhancedInput/Source/InputEditor/Public/EnhancedInputEditorSettings.h` 第 39 行 | **间接**（经 `UDeveloperSettingsBackedByCVars`） |

> Runtime 内 38 个文件覆盖 Engine / UMG / PhysicsCore / Landscape / GameplayTags / LevelSequence / MassEntity / CinematicCamera 等模块；完整清单按「取数说明」命令复现。
> **注意：`UPlatformSettings`、`UPlatformSettingsManager`、`UGameplayTagsSettings` 均不派生自本类**（实测分别直接派生 `UObject` / 派生自 `UGameplayTagsList`）——按名字猜继承关系会出错。

## 取数说明

| 断言 | 取数方式（相对基准：`Engine/Source`） |
|---|---|
| `GetOwnerCustomSectionName` 在 `Engine/Source` 内 **0** 命中 | `[H]` 对 `Engine/Source` 全树按 `GetOwnerCustomSectionName` 检索（`*.h` / `*.cpp`）→ **0** |
| 搜索边界 294 个模块（Runtime 291 + `EnhancedInput` 插件 3） | `[M]` 插件 3 个模块（含白名单外的 `InputBlueprintNodes` / `InputEditor`）：`(Get-ChildItem "Engine/Plugins/EnhancedInput/Source" -Directory).Count` → 3；Runtime 291 见 `_meta/inventory.md` |
| 文件 77 行、类体 22-77 | `[M]` `[System.IO.File]::ReadAllLines("Engine/Source/Runtime/DeveloperSettings/Public/Engine/DeveloperSettings.h").Count`（同文件 `^};` 检索定类体区间） |
| 类内 `virtual` 8 条 | `[H]` `Select-String -Pattern 'virtual'` 全匹配 + 逐段核对 |
| 派生统计：Runtime 38 文件 / 42 命中；EnhancedInput 1 | `[H]` `Select-String -Pattern '\bpublic\s+UDeveloperSettings\b'`（`*.h`）；工具头部计数 = 文件条目数，逐文件求和 = 命中数 |
| 全部行号引用 | 2026-10-10 对 UE 5.8.3 源码本机逐条核对 |

## 相关文档

- `modules/DeveloperSettings-结构.md` —— UDeveloperSettings 所在模块（同批产出）
- `modules/GameplayTags-结构.md` —— 派生类 `UGameplayTagsDeveloperSettings` 的宿主
- `modules/EnhancedInput-结构.md` —— 派生类 `UEnhancedInputDeveloperSettings` 的宿主
- `modules/CoreUObject-结构.md` —— 基类链所在模块（已校验）

## 更新记录

- 2026-10-11 搜索边界更正：派生搜索实覆盖 **294** 个模块（Runtime 291 + `EnhancedInput` 插件 3），原文误作"纳入范围的 292 个模块"（292 是白名单口径，搜索实际连 `InputBlueprintNodes` / `InputEditor` 一并覆盖，本文件命中的插件侧结果即来自 `InputEditor`）；同时在「取数说明」补入该边界取数方式（`convention.md` 4.2）

- 2026-10-11 「取数说明」补入 1 行计数断言取数方式（`convention.md` 4.2 覆盖要求）

- 2026-10-11 按规范 4.2.1 为「取数说明」各行加方法标记（`[M]`/`[R]`/`[H]`）；`[M]` 行把原文省略成 `(...)` 的路径补全为白名单可执行命令，现由 `ue-doc-verify` 逐条实际执行比对
