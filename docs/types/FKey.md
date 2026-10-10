> 引擎版本：UE 5.8.3 (Build 58210709)
> 源码根：Engine/Source
> 生成技能：ue-type-api v1.0
> 生成时间：2026-10-10
> 校验状态：已校验（2026-10-10）

# FKey

## 一、类型概览

| 项 | 值 |
|---|---|
| 全限定名 | `FKey`（全局命名空间） |
| 定义位置 | `Engine/Source/Runtime/InputCore/Classes/InputCoreTypes.h`（**Classes/ 目录**，非 Public） |
| 类型 | 结构体（反射类型；输入键值） |
| 反射宏 | `USTRUCT(BlueprintType,Blueprintable)`（第 48 行）+ `GENERATED_USTRUCT_BODY()`（第 51 行） |
| 导出策略 | 类级无导出宏（第 49 行）；逐成员 `INPUTCORE_API`（FKey 内 40+ 处） |
| 所属模块 | `InputCore` |

## 二、继承链

**无基类**（第 49-50 行：`struct FKey` 后直接 `{`）——链根（值语义结构体）。

## 三、声明片段

```
文件：Engine/Source/Runtime/InputCore/Classes/InputCoreTypes.h
行 48-51：USTRUCT(BlueprintType,Blueprintable) / struct FKey / { / GENERATED_USTRUCT_BODY()
行 118：private:
行 127：类体结束（};；文件 876 行）
```

> 同文件配套：`FKeyDetails`(145)、`FTouchId`(283)、`EKeys`(345)、`FInputKeyManager`(847)、`UInputCoreTypes`(872)；模板特化 `TStructOpsTypeTraits<FKey>`（第 129-130 行，`WithPostScriptConstruct = true` 等第 138 行区间）。

## 四、公开 API

| 签名 | 说明 | 位置 |
|---|---|---|
| `FKey()` | 默认构造（`NAME_None`） | 第 53 行 |
| `FKey(const FName)` / `FKey(const TCHAR*)` / `FKey(const ANSICHAR*)` | 构造 | 第 57 / 62 / 67 行 |
| `IsValid() const` | 是否有效键 | 第 72 行 |
| `IsModifierKey() const` | 修饰键（Ctrl/Shift…） | 第 73 行 |
| `IsGamepadKey() const` | 手柄键 | 第 74 行 |
| `IsTouch() const` | 触摸 | 第 75 行 |
| `IsMouseButton() const` | 鼠标键 | 第 76 行 |
| `IsDigital() const` / `IsAnalog() const` | 数字/模拟量 | 第 81 / 82 行 |
| `IsDeprecated() const` | 是否废弃键 | 第 87 行 |
| `GetDisplayName(bool) const` | 显示名（FText） | 第 89 行 |
| `ToString() const` | 字符串 | 第 90 行 |
| `GetFName() const` | 键名（FName） | 第 91 行 |
| `GetMenuCategory() const` | 菜单分类 | 第 92 行 |
| `GetPairedAxis() const` / `GetPairedAxisKey() const` | 配对轴 | 第 93 / 94 行 |
| `GetVirtualKey() const` | 虚拟键 | 第 95 行 |
| `IsSameResolvedKey(const FKey&) const` | 解析后等价判定 | 第 101 行 |
| `operator==` / `operator!=` / `operator<` / `GetTypeHash`（friend） | 比较与哈希（比较 `KeyName`；`<` 用 `LexicalLess`） | 第 109 / 110 / 111 / 112 行 |
| `SyntheticCharPrefix`（static const TCHAR*） | 合成字符前缀 | 第 116 行 |

> private 成员：`KeyName`（`UPROPERTY(EditAnywhere, Category="Input")`，第 120-121 行）、`KeyDetails`（`mutable TSharedPtr<FKeyDetails>`，第 123 行）；`friend struct EKeys`（第 114 行）。

## 五、扩展点

### 5.1 可覆写虚函数

**无**——结构体内 `virtual` 实测 0 处（文件内 5 处 "virtual" 命中均为注释文本，如第 99 行 "virtual key name"）。

扩展机制：

| 机制 | 说明 | 位置 |
|---|---|---|
| `TStructOpsTypeTraits<FKey>` 特化 | 文本化/序列化兼容：`WithStructuredSerializeFromMismatchedTag` / `WithExportTextItem` / `WithImportTextItem` / `WithPostSerialize` / `WithPostScriptConstruct`（第 138 行）/ `WithCopy` 均 true（注释：`Necessary so that TSharedPtr<FKeyDetails> Data is copied around`） | 第 129-139 行 |
| `friend struct EKeys` | 键表可访问私有成员 | 第 114 行 |

### 5.2 不建议覆写的内部虚函数

无。

## 六、生命周期

- **值语义键标识**：内部仅 `FName KeyName` + 惰性 `KeyDetails`（首次访问时 `ConditionalLookupKeyDetails` 补齐，第 125 行）。
- 配套 **`EKeys`**（第 345 行）为静态键表（成员形如 `static INPUTCORE_API const FKey AnyKey;`，第 347 行），是构造常用 `FKey` 的入口。

## 七、派生类（范围内）

搜索边界：派生类搜索**仅覆盖本版纳入范围的 292 个模块**（Runtime 291 个 + `EnhancedInput` 插件）。搜索模式 `\bpublic\s+FKey\b` 与 `:\s*public\s+FKey\b`（`*.h`）：Runtime **0 命中**；EnhancedInput **0**（另以 `Engine/Source` 全树复核仍为 0）。

| 派生类 | — |
|---|---|
| （无） | 值类型，无派生 |

## 取数说明

| 断言 | 取数方式（相对基准：`Engine/Source`） |
|---|---|
| 文件 876 行、类体 48-127 | `[System.IO.File]::ReadAllLines(...).Count` + `^};` 检索 |
| 类内 `virtual` = 0 | `Select-String -Pattern '\bvirtual\b'` 逐行核对（命中均为注释） |
| 派生统计：0 命中 | `Select-String -Pattern ':\s*public\s+FKey\b\|\bpublic\s+FKey\b'`（`*.h`） |
| 全部行号引用 | 2026-10-10 对 UE 5.8.3 源码本机逐条核对 |

## 相关文档

- `modules/InputCore-结构.md` —— FKey 所在模块（同批产出）
- `types/FSlateElementBatcher.md` —— 同批类型
- `types/UInputAction.md` —— 上层输入动作（批 3）
- `modules/EnhancedInput-结构.md` —— 输入系统（批 3）
