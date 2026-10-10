> 引擎版本：UE 5.8.3 (Build 58210709)
> 源码根：Engine/Source
> 生成技能：ue-type-api v1.0
> 生成时间：2026-10-10
> 校验状态：已校验（2026-10-10）

# SCompoundWidget

## 一、类型概览

| 项 | 值 |
|---|---|
| 全限定名 | `SCompoundWidget`（全局命名空间） |
| 定义位置 | `Engine/Source/Runtime/SlateCore/Public/Widgets/SCompoundWidget.h`（**位于 SlateCore，不在 Slate**） |
| 类型 | 类（纯 C++，非反射类型） |
| 反射宏 | 无（实测 0 命中） |
| 导出策略 | 类声明行**无**导出宏（第 21 行）；宏注入：`SLATE_DECLARE_WIDGET_API(SCompoundWidget, SWidget, SLATECORE_API)`（第 23 行）；成员逐条 `SLATECORE_API`（第 78-104 行） |
| 所属模块 | `SlateCore`（`Engine/Source/Runtime/SlateCore`） |

## 二、继承链

```
FSlateControlledConstruction      （Engine/Source/Runtime/SlateCore/Public/Widgets/SlateControlledConstruction.h 第 84 行；链根）
  └─ SWidget                      （Engine/Source/Runtime/SlateCore/Public/Widgets/SWidget.h 第 163 行）
       └─ SCompoundWidget         （Engine/Source/Runtime/SlateCore/Public/Widgets/SCompoundWidget.h 第 21 行）
```

## 三、声明片段

```
文件：Engine/Source/Runtime/SlateCore/Public/Widgets/SCompoundWidget.h
行 17-23：类注释（"most non-primitive widgets"的基类；含 protected ChildSlot）/ class SCompoundWidget : public SWidget / { / SLATE_DECLARE_WIDGET_API(...)

文件：Engine/Source/Runtime/SlateCore/Public/Widgets/SCompoundWidget.h
行 106-113：FCompoundWidgetOneChildSlot 槽类型定义（第 106 行）与 ChildSlot 成员（第 113 行）

文件：Engine/Source/Runtime/SlateCore/Public/Widgets/SCompoundWidget.h
行 124：类体结束（};；文件 124 行）
```

## 四、公开 API

| 签名 / 成员 | 说明 | 位置 |
|---|---|---|
| `ChildSlot`（`FCompoundWidgetOneChildSlot`，protected） | 唯一子槽（默认带对齐与边距；槽族 `TSingleWidgetChildrenWithBasicLayoutSlot` 定义在 `Layout/Children.h` 第 406 行） | 第 113 行 |
| `GetContentScale()` / `SetContentScale(...)` | 内容缩放 | 第 32 / 42 行 |
| `GetColorAndOpacity()` / `SetColorAndOpacity(...)` | 颜色与不透明度 | 第 50 / 60 行 |
| `SetForegroundColor(...)` | 前景色 | 第 70 行 |
| `GetChildren()`（override） | 返回子级 | 第 79 行 |
| `OnArrangeChildren(...)`（override） | 排列 | 第 80 行 |
| `GetForegroundColor()`（override） | 前景色读取 | 第 81 行 |
| `SetVisibility(...)`（override **final**） | 可见性——**派生子类不可再重写** | 第 84 行 |
| `ComputeDesiredSize(...)`（override） | 期望尺寸 | 第 88 行（protected） |
| `GetContentScaleAttribute()` / `GetColorAndOpacityAttribute()` / `GetForegroundColorAttribute()`（protected） | 属性引用访问器 | 第 92 / 95 / 98 行 |
| 构造 / 析构（protected） | `SCompoundWidget()`（注释：`Disallow public construction`）/ `~SCompoundWidget()` | 第 103-104 行 |

> **本类头文件中没有 `Construct(...)`、没有 `SLATE_BEGIN_ARGS`、没有 `SetContent`**（实测均 0 命中）——
> 构造协议由声明式语法模板（`TSlateDecl` / `SNew`，`Public/Widgets/DeclarativeSyntaxSupport.h`）在**声明侧**驱动，
> `ChildSlot` 直接在声明式构造中赋值。

## 五、扩展点

### 5.1 可覆写虚函数

类内 `virtual` 共 **7 条，全列**：

| 虚函数 | 位置 | 说明 |
|---|---|---|
| `OnPaint(...)` | 第 78 行 | 绘制 |
| `GetChildren()` | 第 79 行 | 子级 |
| `OnArrangeChildren(...)` | 第 80 行 | 排列 |
| `GetForegroundColor()` | 第 81 行 | 前景色 |
| `SetVisibility(...)`（**final**） | 第 84 行 | 不可再覆写 |
| `ComputeDesiredSize(...)` | 第 88 行（protected） | 期望尺寸 |
| `~SCompoundWidget()` | 第 104 行（protected） | 析构 |

### 5.2 不建议覆写的内部虚函数

无——类内 7 条虚函数均为正常覆写面；更底层的布局/输入虚函数在基类 `SWidget`（见 `types/SWidget.md` 5.1/5.2）。

## 六、生命周期

- 纯 C++ 控件基类：无 `UObject` 生命周期钩子。
- 用法（源码注释第 17-19 行）：作为"所有非原始控件（non-primitive widgets）"的基类；`ChildSlot` 承载唯一子级；自定义控件通常经 `SNew(MyWidget)` 声明式构造。
- 框架驱动的布局 / 绘制顺序属 `flows/` 范畴（暂无 Slate 流程产物）。

## 七、派生类（范围内）

搜索边界：派生类搜索**仅覆盖本版纳入范围的 292 个模块**（Runtime 291 个 + `EnhancedInput` 插件），引擎其余部分（Editor / Developer / Platforms / 未纳入的 Plugins）未覆盖。搜索模式 `\bpublic\s+SCompoundWidget\b`（`*.h`）：Runtime 命中 **89 行 / 84 文件**（Slate 46 / AdvancedWidgets 12 / AppFramework 6 / WidgetCarousel 4 / SlateCore 3 / UMG 3 / TimeManagement 2 / GameMenuBuilder 2 / WebBrowser 2 / Engine 1 / PreLoadScreen 1 / Interchange 1 / Experimental 1）；EnhancedInput **0**。

| 代表派生类 | 位置 | 备注 |
|---|---|---|
| `SWindow` | `Engine/Source/Runtime/SlateCore/Public/Widgets/SWindow.h` 第 240-242 行 | 直接（另 `: public FSlateInvalidationRoot`） |
| `SBorder` | `Engine/Source/Runtime/Slate/Public/Widgets/Layout/SBorder.h` 第 30 行 | 直接 |
| `SButton` | `Engine/Source/Runtime/Slate/Public/Widgets/Input/SButton.h` 第 32 行 | **间接**（经 `SBorder`） |
| `STableViewBase` | `Engine/Source/Runtime/Slate/Public/Widgets/Views/STableViewBase.h` 第 115 行 | 直接 |
| `SListView` | `Engine/Source/Runtime/Slate/Public/Widgets/Views/SListView.h` 第 263 行 | **间接**（经 `STableViewBase`） |
| `SObjectWidget` | `Engine/Source/Runtime/UMG/Public/Slate/SObjectWidget.h` 第 30 行 | Slate/UMG 桥（另 `: public FGCObject`） |

完整清单按「取数说明」中的命令复现。

## 取数说明

| 断言 | 取数方式（相对基准：`Engine/Source`） |
|---|---|
| 文件 124 行、类体 21-124 | `[System.IO.File]::ReadAllLines(...).Count` + `^};` 检索 |
| 类内 `virtual` 7 条 | `Select-String ... -Pattern 'virtual'` 全匹配 + 逐段核对 |
| 派生统计：Runtime 89 行 / 84 文件；EnhancedInput 0 | `Select-String -Pattern '\bpublic\s+SCompoundWidget\b'`（`*.h`），按模块分组计数 |
| 全部行号引用 | 2026-10-10 对 UE 5.8.3 源码本机逐条核对 |

## 相关文档

- `modules/SlateCore-结构.md` —— SCompoundWidget 所在模块（同批产出）
- `types/SWidget.md` —— 基类（同批产出）
- `modules/Slate-结构.md` —— 派生类密集的模块（同批产出）
- `modules/UMG-结构.md` —— `SObjectWidget` 所在模块（同批产出）

## 更新记录

- 2026-10-10 将「七、派生类」统计由下界描述（84 文件 / ≥89 行）修正为全量精确值（89 行 / 84 文件）
