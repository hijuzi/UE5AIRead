> 引擎版本：UE 5.8.3 (Build 58210709)
> 源码根：Engine/Source
> 生成技能：ue-type-api v1.0
> 生成时间：2026-10-10
> 校验状态：已校验（2026-10-11）

# FName

## 一、类型概览

| 项 | 值 |
|---|---|
| 全限定名 | `FName`（全局命名空间） |
| 定义位置 | `Engine/Source/Runtime/Core/Public/UObject/NameTypes.h` |
| 类型 | 类（值类型语义，非 `UObject` 体系） |
| 反射宏 | 无（同头文件 `USTRUCT` 零出现——非反射类型） |
| 导出策略 | 成员级宏 + 编译期开关：类名前**无**导出宏（第 631 行 `class FName`）；成员前带 `CORE_API`；`UE_FNAME_OUTLINE_NUMBER`（默认 0，第 38-40 行）为 1 时，`GetComparisonIndex` / `GetDisplayIndex` / `GetNumber` 从 `FORCEINLINE` 内联实现（第 641-672 行）改为 `CORE_API` 外链声明（第 638-639、657-659 行） |
| 所属模块 | `Core`（`Engine/Source/Runtime/Core`） |

## 二、继承链

`FName` **无基类**——不继承任何类型（非 `UObject` 体系的值类型）；范围内无派生类（边界见第七节）。

## 三、声明片段

```
文件：Engine/Source/Runtime/Core/Public/UObject/NameTypes.h
行 38-40：#ifndef UE_FNAME_OUTLINE_NUMBER / #define UE_FNAME_OUTLINE_NUMBER 0（默认关闭）

文件：Engine/Source/Runtime/Core/Public/UObject/NameTypes.h
行 631-635：class FName 声明与开头（类名前无导出宏；constexpr 静态成员 bHasIntrusiveUnsetOptionalState）

文件：Engine/Source/Runtime/Core/Public/UObject/NameTypes.h
行 1257-1267：私有成员布局（ComparisonIndex；Number 仅在 !UE_FNAME_OUTLINE_NUMBER 时内联；DisplayIndex 仅在 WITH_CASE_PRESERVING_NAME 时存在）

文件：Engine/Source/Runtime/Core/Public/UObject/NameTypes.h
行 808：UEOpEquals(FName Other)——== 与 != 的合成来源，见第六节

文件：Engine/Source/Runtime/Core/Public/Misc/UEOps.h
行 8-33：UEOps 全局比较运算符框架的契约（类型定义成员 UEOpEquals 即自动获得 operator== / operator!=）

文件：Engine/Source/Runtime/Core/Public/UObject/NameTypes.h
行 1871-1884：排序运算符被显式删除（无正确默认排序；替代见第四节 FastLess / LexicalLess）
```

## 四、公开 API

> 本类型非反射类型，以下全部无 `UFUNCTION` 等反射标注（标注列统一为"无"）。

| 签名 | 说明 | 位置 |
|---|---|---|
| `FName()`（默认构造） | 默认构造的名称为 `None`——其 `ToString()` 返回 `"None"` 而非空串（第 746-747 行注释） | — |
| `FName(const WIDECHAR* / ANSICHAR* / UTF8CHAR*)` | 从字符串查找/注册 | 第 1079-1081 行 |
| `FName(..., EFindName FindType)` | `FNAME_Find` 只查找、`FNAME_Add` 注册 | 第 1083-1085 行 |
| `FName(int32 Len, const ..., EFindName)` | 带长度的字符串构造 | 第 1088-1090 行 |
| `FName(EName Ename)` | 从静态枚举构造（如 `NAME_None`） | 第 978 行 |
| `FName(const ..., int32 InInternalNumber)` | 带实例编号构造 | 第 1116-1120 行 |
| `GetComparisonIndex()` | 比较用名称表索引（大小写不敏感的比较基准） | 第 638-653 行 |
| `GetDisplayIndex()` | 显示用索引（大小写保留；由 `WITH_CASE_PRESERVING_NAME` 决定是否独立） | 第 639-653 行 |
| `GetNumber()` | 实例编号（内部存储为"实际值 + 1"） | 第 655-672 行 |
| `IsNone()` | 是否为 `None` | 第 832 行 |
| `IsValid()` | 索引是否在名称表范围内 | 第 847 行 |
| `ToString()`（含无分配重载与 `ToStringTruncate`） | 转字符串 | 第 697-776 行 |
| `GetPlainNameString()` | 取不含编号的字符串（有动态分配与免分配两种） | 第 675-678 行 |
| `AppendString(...)` | 追加到既有字符串 | 第 783-784 行 |
| `GetStringLength()` | `ToString()` 将产生的字符数（不含结尾空字符） | 第 725 行 |
| `UEOpEquals(FName)` / `UEOpEquals(FIntrusiveUnsetOptionalState)` | **比较的唯一手写入口**；`==` / `!=` 由 `Misc/UEOps.h` 机制合成（见第六节） | 第 808、814 行 |
| `static bool Equals(FName, FWideStringView / const ANSICHAR* / const WIDECHAR* / EName / FMinimalName / FScriptName / FMemoryImageName)` | 跨类型比较重载族 | 第 1360-1405 行 |
| `FastLess(const FName&)` / `LexicalLess(const FName&)` | 排序替代（`<` 等已删除，见第六节） | 第 820、826 行 |
| `friend uint32 GetTypeHash(FName)` | 可作 `TMap` / `TSet` 键 | 第 1385、1402 行 |
| `static FName CreateFromDisplayId(FNameEntryId, int32)` / `static FName FindNumberedName(FNameEntryId, int32)` | 底层构造 | 第 1021、1030 行 |
| `static FNameEntry const* GetEntry(FNameEntryId)` | 访问名称表条目 | 第 1194-1195 行 |
| `static void TearDown()` | 拆除名称体系；注释明确 **TearDown 之后不得再使用 FName** | 第 1236 行 |

配套类型（同头文件）：`FNameEntryId`、`FNameEntry`、`FNameEntrySerialized`、`FMinimalName`、`FScriptName`、`FMemoryImageName`、`FLazyName`、`FNameBuilder`（第 1938 行）、`FDisplayNameEntryId`（第 1893 行）。

## 五、扩展点

### 5.1 可覆写虚函数

**无。** FName 全文零虚函数（实测：`virtual` 出现 0 次，见取数说明）——不存在为继承设计的扩展点。

### 5.2 不建议覆写的内部虚函数

无（同上；FName 不是可扩展的基类）。

## 六、生命周期

- FName 非 `UObject`，无 `BeginPlay` / `Tick` 之类的运行时生命周期钩子。
- **构造期语义**：构造 FName 即在全局名称表中查找/注册"字符串 + 编号"对；是否注册由构造参数 `EFindName` 决定（`FNAME_Find` 只查找不注册）。
- **体系终点**：`FName::TearDown()`（第 1236 行）——引擎关闭时拆除名称体系，注释明确此后不得再使用 FName。
- 名称-编号对的完整查找/注册调用链不在本篇范围（属 `flows/`）。

## 七、派生类（范围内）

搜索边界：派生类搜索**覆盖 Runtime 291 个模块 + `EnhancedInput` 插件全部 3 个模块（共 294 个模块）**，引擎其余部分（Editor / Developer / Platforms / 未纳入的 Plugins）未覆盖。搜索模式 `\bpublic\s+FName\b`（`*.h`），命中 **0**。

| 派生类 | 模块 |
|---|---|
| （无命中） | — |

补充：FName **未声明 `final`**（第 631 行），技术上可派生；但该类型按值语义使用，范围内无任何派生类——准确说法是"**不应被继承**"，而非"不可被继承"。

## 取数说明

| 断言 | 取数方式（相对基准：`Engine/Source`） |
|---|---|
| 搜索边界 294 个模块（Runtime 291 + `EnhancedInput` 插件 3） | `[M]` 插件 3 个模块（含白名单外的 `InputBlueprintNodes` / `InputEditor`）：`(Get-ChildItem "Engine/Plugins/EnhancedInput/Source" -Directory).Count` → 3；Runtime 291 见 `_meta/inventory.md` |
| 零虚函数 | `(Select-String "Runtime\Core\Public\UObject\NameTypes.h" -Pattern 'virtual' -AllMatches \| ForEach-Object Matches \| Measure-Object).Count` → 0 |
| 文件 1,953 行、类体 631-1418 行 | `[M]` `[System.IO.File]::ReadAllLines("Engine/Source/Runtime/Core/Public/UObject/NameTypes.h").Count`（同文件 `^};` 检索定类体区间） |
| 派生类 0 命中 | `[H]` 搜索模式 `\bpublic\s+FName\b`，路径 `Runtime` 与 `Engine/Plugins/EnhancedInput/Source`，glob `*.h` |
| `USTRUCT` 0 次 | `[M]` `Select-String "Engine/Source/Runtime/Core/Public/UObject/NameTypes.h" -Pattern 'USTRUCT' -AllMatches` |
| 全部行号引用 | 2026-10-10 对 UE 5.8.3 源码本机逐条核对 |

## 相关文档

- `modules/Core-结构.md` —— FName 所在模块（同批产出）
- `modules/CoreUObject-结构.md` —— 对象命名体系依赖 FName（同批产出）
- `types/UObject.md` —— 同批产出
- `flows/UObject创建流程.md` —— 对象创建主路径（已校验）

## 更新记录

- 2026-10-11 搜索边界更正：派生搜索实覆盖 **294** 个模块（Runtime 291 + `EnhancedInput` 插件 3），原文误作"纳入范围的 292 个模块"（292 是白名单口径，搜索实际连 `InputBlueprintNodes` / `InputEditor` 一并覆盖，本文件命中的插件侧结果即来自 `InputEditor`）；同时在「取数说明」补入该边界取数方式（`convention.md` 4.2）

- 2026-10-11 按规范 4.2.1 为「取数说明」各行加方法标记（`[M]`/`[R]`/`[H]`）；`[M]` 行把原文省略成 `(...)` 的路径补全为白名单可执行命令，现由 `ue-doc-verify` 逐条实际执行比对
