> 引擎版本：UE 5.8.3 (Build 58210709)
> 源码根：Engine/Source
> 生成技能：ue-type-api v1.0
> 生成时间：2026-10-10
> 校验状态：已校验（2026-10-10）

# FUniversalObjectLocator

## 一、类型概览

| 项 | 值 |
|---|---|
| 全限定名 | `FUniversalObjectLocator`（全局命名空间） |
| 定义位置 | `Engine/Source/Runtime/UniversalObjectLocator/Public/UniversalObjectLocator.h` |
| 类型 | 结构体（反射值类型；对象定位器） |
| 反射宏 | `USTRUCT(BlueprintType, Category=GameFramework, meta=(HasNativeMake="/Script/Engine.UniversalObjectLocatorScriptingExtensions.MakeUniversalObjectLocator"))`（第 30 行）+ `GENERATED_BODY()`（第 33 行） |
| 导出策略 | 类级无宏（第 31 行）；成员级 `UNIVERSALOBJECTLOCATOR_API`（26 处，含第 160 行静态工厂） |
| 所属模块 | `UniversalObjectLocator`（`Engine/Source/Runtime/UniversalObjectLocator`） |

## 二、继承链

**无基类**（第 31 行无 `: public X` 子句）；`TStructOpsTypeTraits<FUniversalObjectLocator>` 特化（第 264 行）佐证其为无双基类的值类型——链根。

## 三、声明片段

```
文件：Engine/Source/Runtime/UniversalObjectLocator/Public/UniversalObjectLocator.h
行 30-33：USTRUCT(...) / struct FUniversalObjectLocator / { / GENERATED_BODY()
行 249-250：UPROPERTY() / TArray<FUniversalObjectLocatorFragment> Fragments;（数据成员）
行 254：结构体结束（};；文件 274 行；其后第 256 行起为模板定义与 traits 特化）
```

## 四、公开 API

| 签名 | 说明 | 位置 |
|---|---|---|
| `FUniversalObjectLocator()` | 默认构造 | 第 44 行 |
| `FUniversalObjectLocator(UObject*, UObject* Context, UObject* StopAtContext)` | 从对象捕获（可指定停止层级） | 第 54 行 |
| `IsEmpty() const` | 是否空定位器 | 第 59 行 |
| `Resolve(const FResolveParams&) const` → `FResolveResult` | 同步解析（带参数） | 第 70 行 |
| `AsyncFind(UObject*) const` / `AsyncLoad` / `AsyncUnload` | 异步查找/加载/卸载 | 第 79 / 88 / 97 行 |
| `SyncFind(UObject*) const` / `SyncLoad` / `SyncUnload` | 同步族 | 第 106 / 115 / 124 行 |
| `GetLastFragmentType() const` / `GetLastFragmentTypeHandle() const` | 末段类型查询 | 第 129 / 134 行 |
| `ToString(FStringBuilderBase&) const` | 文本化 | 第 141 行 |
| `TryParseString(FStringView, const FParseStringParams&)` | 解析（返回解析结果） | 第 150 行 |
| `static FromString(FStringView, const FParseStringParams&)` | **静态工厂**（唯一） | 第 160 行 |
| `Reset()` / `Reset(UObject*, UObject*, UObject*)` | 重置 | 第 167 / 177 行 |
| `AddFragment(FUniversalObjectLocatorFragment&&)` / 模板版 `AddFragment<T>(...)` | 追加片段 | 第 184 / 191 行 |
| `GetLastFragment()`（×2 重载） | 末段访问 | 第 197 / 202 行 |
| `ForEachFragment(TFunctionRef<...>) const` | 遍历片段 | 第 209 行 |
| `GetDefaultFlags() const` | 默认标志 | 第 214 行 |
| 运算符 / 文本化钩子 | `operator==`(220) / `!=`(226) / `GetTypeHash`(231)；`ExportTextItem`(234) / `ImportTextItem`(235) / `SerializeFromMismatchedTag`(236) | 见左 |

> **不存在**（实测 0 命中）：`IsValid`、`Serialize`、`MakeRoot`。

## 五、扩展点

### 5.1 可覆写虚函数

**无**——类内 `virtual` 实测 0 处。

扩展路径（模块级）：

| 机制 | 说明 | 位置 |
|---|---|---|
| Fragment 类型注册 | `IUniversalObjectLocatorModule::RegisterFragmentType<T>(...)` 模板 → 私有 `RegisterFragmentTypeImpl` 纯虚 | `IUniversalObjectLocatorModule.h` 第 70 / 129 行 |
| 自定义 Fragment | 继承/实现 Fragment 数据 + `FFragmentType` 描述（第 69 行）与两个 8 位句柄类型 | 同模块 Public/ |
| 内置类型样例 | `subobj`（`SubObjectLocator.h`）/ `uobj`（`DirectPathObjectLocator.h`） | 见左 |

### 5.2 不建议覆写的内部虚函数

无（结构体内无虚函数）。

## 六、生命周期

- **值语义 + 三态解析**：构造捕获（第 54 行）→ `Resolve` / 异步 `AsyncFind→AsyncLoad→AsyncUnload`（第 70-124 行）→ 文本化（`ToString` / `TryParseString` / `FromString`，第 141-160 行）。
- **序列化**走 traits 钩子（`ExportTextItem` / `ImportTextItem` / `SerializeFromMismatchedTag`，第 234-236 行）而非 `Serialize`——与 `TStructOpsTypeTraits` 特化（第 264 行）配套。
- 调试支持：`UE_UNIVERSALOBJECTLOCATOR_DEBUG`（`UniversalObjectLocatorFragmentDebugging.h` 第 7-8 行，默认 `!UE_BUILD_SHIPPING`）。

## 七、派生类（范围内）

搜索边界：派生类搜索**仅覆盖本版纳入范围的 292 个模块**（Runtime 291 个 + `EnhancedInput` 插件）。搜索模式 `\bpublic\s+FUniversalObjectLocator\b`（`*.h`）：Runtime **0 命中**；EnhancedInput **0**（另以 `Engine/Source` 全树复核仍为 0）。

| 派生类 | — |
|---|---|
| （无） | 终端值类型 |

> 配套定位：`FUniversalObjectLocatorFragment`（同头目录 `UniversalObjectLocatorFragment.h` 第 35 行）、`FResolveParams`（`UniversalObjectLocatorResolveParams.h` 第 46 行）/ `FResolveResult`（同文件第 204 行）、`FInitializeParams`（`UniversalObjectLocatorInitializeParams.h` 第 15 行）、`FFragmentType`（`UniversalObjectLocatorFragmentType.h` 第 69 行）、`FParseStringParams`（`UniversalObjectLocatorStringParams.h` 第 25 行）。

## 取数说明

| 断言 | 取数方式（相对基准：`Engine/Source`） |
|---|---|
| 文件 274 行、结构体 31-254 | `[System.IO.File]::ReadAllLines(...).Count` + `^};` 检索 |
| 类内 `virtual` = 0；派生 0 命中 | `Select-String -Pattern 'virtual'` / `'\bpublic\s+FUniversalObjectLocator\b'`（`*.h`） |
| 成员级导出 26 处 | `Select-String -Pattern 'UNIVERSALOBJECTLOCATOR_API'` 全匹配计数 |
| 全部行号引用 | 2026-10-10 对 UE 5.8.3 源码本机逐条核对 |

## 相关文档

- `modules/UniversalObjectLocator-结构.md` —— FUniversalObjectLocator 所在模块（同批产出）
- `types/FFrameRate.md` —— 同批类型
- `modules/LevelSequence-结构.md` —— 跨模块消费者（批 9）
- `types/UMovieSceneSequence.md` —— 动态绑定体系（批 6）
