> 引擎版本：UE 5.8.3 (Build 58210709)
> 源码根：Engine/Source
> 生成技能：ue-type-api v1.0
> 生成时间：2026-10-10
> 校验状态：已校验（2026-10-10）

# FGameplayTag

## 一、类型概览

| 项 | 值 |
|---|---|
| 全限定名 | `FGameplayTag`（全局命名空间） |
| 定义位置 | `Engine/Source/Runtime/GameplayTags/Classes/GameplayTagContainer.h` |
| 类型 | 结构体（反射类型，非 `UObject` 体系的值类型） |
| 反射宏 | `USTRUCT(BlueprintType, meta = (HasNativeMake = "/Script/GameplayTags.BlueprintGameplayTagLibrary.MakeLiteralGameplayTag", HasNativeBreak = "/Script/GameplayTags.BlueprintGameplayTagLibrary.GetTagName", DisableSplitPin))`（第 40 行）+ `GENERATED_USTRUCT_BODY()`（第 43 行） |
| 导出策略 | 成员级宏：结构体声明行**无**导出宏（第 41 行）；成员前带 `GAMEPLAYTAGS_API`（如第 57、91 行）；部分成员为 `inline` 无需导出（如第 69 行 `operator==`） |
| 所属模块 | `GameplayTags`（`Engine/Source/Runtime/GameplayTags`） |

> 注意：本类型（以及同文件多数结构体）使用的是 **`GENERATED_USTRUCT_BODY()`**（第 43 行），不是 `GENERATED_BODY()`——引用反射代码时以实测为准。

## 二、继承链

**无基类**（第 41-42 行：`struct FGameplayTag` 后直接 `{`）。它是按值使用的轻量类型，不参与类继承体系；范围内无派生类（边界见第七节）。

## 三、声明片段

```
文件：Engine/Source/Runtime/GameplayTags/Classes/GameplayTagContainer.h
行 40-43：USTRUCT(...) / struct FGameplayTag / { / GENERATED_USTRUCT_BODY()

文件：Engine/Source/Runtime/GameplayTags/Classes/GameplayTagContainer.h
行 222-223：UPROPERTY(VisibleAnywhere, Category = GameplayTags, SaveGame) / FName TagName;

文件：Engine/Source/Runtime/GameplayTags/Classes/GameplayTagContainer.h
行 230：类体结束（};；文件 1,142 行）
```

## 四、公开 API

> 无 `UFUNCTION` 反射标注（蓝图暴露经 `USTRUCT(BlueprintType)` 与配套蓝图库函数实现）；全文**零虚函数**（见取数说明）。

| 签名 | 说明 | 位置 |
|---|---|---|
| `static FGameplayTag RequestGameplayTag(const FName&, bool ErrorIfNotFound=true)` | 按名查标签（静态） | 第 57 行 |
| `static bool IsValidGameplayTagString(const FString&, FText*, FString*)` | 字符串合法性校验（静态，可回带修正串） | 第 66 行 |
| `operator==` / `operator!=` / `operator<` | 比较运算符（inline，按内部 `TagName`） | 第 69 / 74 / 79 行 |
| `MatchesTag(const FGameplayTag&)` | 层级匹配（父标签可匹配其后代） | 第 91 行 |
| `MatchesTagExact(...)` | 精确匹配（inline） | 第 100 行 |
| `MatchesTagDepth(...)` | 匹配深度（0/负值语义见头文件） | 第 117 行 |
| `MatchesAny(const FGameplayTagContainer&)` | 与容器任一匹配 | 第 126 行 |
| `MatchesAnyExact(...)` | 与容器精确匹配 | 第 135 行 |
| `IsValid()` | 有效性（inline） | 第 138 行 |
| `GetSingleTagContainer()` | 转为单标签容器 | 第 144 行 |
| `RequestDirectParent()` | 取直接父标签 | 第 147 行 |
| `GetTypeHash(const FGameplayTag&)` | 哈希（friend inline；可作 `TMap`/`TSet` 键） | 第 168 行 |
| `ToString()` | 字符串化（inline） | 第 174 行 |
| `GetTagName()` | 取内部 `FName`（inline） | 第 180 行 |
| `static const FGameplayTag EmptyTag` | 空标签常量 | 第 212 行 |
| `explicit FGameplayTag(const FName&)` | 从 `FName` 构造 | 第 219 行 |
| 数据成员 `FName TagName` | 唯一存储（`UPROPERTY`，第 222-223 行） | 第 223 行 |

配套类型（同文件）：`FGameplayTagContainer`（第 247 行）、`FGameplayTagQuery`（第 737 行）、`FGameplayTagQueryExpression`（第 865 行）；同目录：`UGameplayTagsManager`（`Classes/GameplayTagsManager.h` 第 336 行）、`FNativeGameplayTag`（`Public/NativeGameplayTags.h` 第 58 行）。

## 五、扩展点

### 5.1 可覆写虚函数

**无。** `FGameplayTag` 全文零虚函数（实测：`virtual` 全匹配 0 处，见取数说明）——不可扩展，按值语义使用。

### 5.2 不建议覆写的内部虚函数

无（同上）。

## 六、生命周期

- 非 `UObject` 值类型：无 `BeginPlay` / `Tick` 类钩子；构造与拷贝即全部语义。
- 标签语义由**全局标签表**定义：`UGameplayTagsManager` 单例在模块启动时被动实例化（`Engine/Source/Runtime/GameplayTags/Private/GameplayTagsModule.cpp` 第 25 行 `UGameplayTagsManager::Get();`），模块关闭时置空（同文件第 43 行）。
- `FGameplayTag` 自身仅持一个 `FName`（第 223 行）；标签注册、查询与重定向的完整链路属 `flows/` 范畴（尚无产物）。

## 七、派生类（范围内）

搜索边界：派生类搜索**仅覆盖本版纳入范围的 292 个模块**（Runtime 291 个 + `EnhancedInput` 插件）；引擎其余部分（Editor / Developer / Platforms / 未纳入的 Plugins）未覆盖。搜索模式 `\bpublic\s+FGameplayTag\b`（`*.h`）：Runtime 命中 **0**、EnhancedInput 命中 **0**。

| 派生类 | 模块 |
|---|---|
| （无命中） | — |

该类型按值语义使用，无派生是预期结果（结构体可被继承但引擎内无此用法）。

## 取数说明

| 断言 | 取数方式（相对基准：`Engine/Source`） |
|---|---|
| 零虚函数 | `Select-String "Runtime\GameplayTags\Classes\GameplayTagContainer.h" -Pattern 'virtual' -AllMatches` 全匹配计数 → 0 |
| 文件 1,142 行、类体 41-230 行 | `[System.IO.File]::ReadAllLines(...)` 计数 + `^};` 检索 |
| 派生 0 命中 | 模式 `\bpublic\s+FGameplayTag\b`，范围 `Runtime` 与 `Engine/Plugins/EnhancedInput/Source`，glob `*.h` |
| 全部行号引用 | 2026-10-10 对 UE 5.8.3 源码本机逐条核对 |

## 相关文档

- `modules/GameplayTags-结构.md` —— FGameplayTag 所在模块（同批产出）
- `types/AActor.md` —— 同批产出的 Engine 代表类型
- `modules/Engine-结构.md` —— 主消费方模块（同批产出）
- `flows/UObject创建流程.md` —— 对象创建主路径（已校验）
