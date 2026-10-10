> 引擎版本：UE 5.8.3 (Build 58210709)
> 源码根：Engine/Source
> 生成技能：ue-type-api v1.0
> 生成时间：2026-10-10
> 校验状态：已校验（2026-10-10）

# SWidget

## 一、类型概览

| 项 | 值 |
|---|---|
| 全限定名 | `SWidget`（全局命名空间） |
| 定义位置 | `Engine/Source/Runtime/SlateCore/Public/Widgets/SWidget.h` |
| 类型 | 类（纯 C++，非反射类型） |
| 反射宏 | 无（`UCLASS` / `GENERATED_BODY` 等实测 0 命中） |
| 导出策略 | 类声明行**无**导出宏（第 163 行 `class SWidget`）；导出经类体内宏注入：`SLATE_DECLARE_WIDGET_API(SWidget, FSlateControlledConstruction, SLATECORE_API)`（第 167 行；宏定义在 `SlateControlledConstruction.h` 第 22-45 行——`SLATECORE_API` 用于宏内 `PrivateRegisterAttributes` 静态成员，第 37 行）；成员另逐条标注 `SLATECORE_API` |
| 所属模块 | `SlateCore`（`Engine/Source/Runtime/SlateCore`） |

## 二、继承链

```
FSlateControlledConstruction      （Engine/Source/Runtime/SlateCore/Public/Widgets/SlateControlledConstruction.h 第 84 行；无基类子句 = C++ 链根；含纯虚 GetWidgetClass，第 96 行）
  └─ SWidget                      （Engine/Source/Runtime/SlateCore/Public/Widgets/SWidget.h 第 163-165 行）
TSharedFromThis<SWidget>          （Core 模板：Engine/Source/Runtime/Core/Public/Templates/SharedPointer.h 第 1706 行；其私有基类链未继续追溯）
```

- 多继承：`class SWidget : public FSlateControlledConstruction, public TSharedFromThis<SWidget>`（第 163-165 行；后者注释：`Enables 'this->AsShared()'`）。
- **头文件第 143 行明确警示：`STOP. DO NOT INHERIT DIRECTLY FROM WIDGET!`**——常规做法是继承 `SCompoundWidget` / `SLeafWidget` / `SPanel`（见第七节：范围内直接派生仅 7 个）。

## 三、声明片段

```
文件：Engine/Source/Runtime/SlateCore/Public/Widgets/SWidget.h
行 163-167：class SWidget / : public FSlateControlledConstruction, / public TSharedFromThis<SWidget> / { / SLATE_DECLARE_WIDGET_API(...)

文件：Engine/Source/Runtime/SlateCore/Public/Widgets/SWidget.h
行 1667-1681：protected 构造区（SWidget() 第 1675 行；SWidgetConstruct 第 1678 行；注释：隐藏默认构造，使用 SNew(...)）

文件：Engine/Source/Runtime/SlateCore/Public/Widgets/SWidget.h
行 2067：类体结束（};；文件 2,156 行）
```

## 四、公开 API

| 签名 | 说明 | 位置（SWidget.h） |
|---|---|---|
| `Paint(...)` | 绘制入口（非虚，框架调用） | 第 294 行 |
| `SlatePrepass()`（2 重载） | 布局预处理 | 第 669 / 675 行 |
| `GetDesiredSize()` | 期望尺寸 | 第 695 行 |
| `GetParentWidget()` | 父级（inline） | 第 704 行 |
| `SetEnabled(...)` / `IsEnabled()` | 启用态 | 第 992 / 998 行 |
| `IsHovered()` / `IsDirectlyHovered()` | 悬停态 | 第 1039 / 1045 行 |
| `GetVisibility()` / `SetVisibility(...)`（虚） | 可见性 | 第 1065 / 1068 行 |
| `SetToolTipText(...)` / `SetToolTip(...)` | 提示信息 | 第 1373-1379 行 |
| `SetCursor(...)` / `GetCursor()`（虚，protected） | 光标 | 第 1382 / 1390 行 |
| `GetTypeAsString()` / `GetType()` | 类型查询 | 第 1556 / 1559 行 |
| `GetReadableLocation()` / `GetTag()`（虚） | 调试位置 / 标签 | 第 1564 / 1570 行 |
| `GetTickSpaceGeometry()` / `GetPaintSpaceGeometry()` | 几何缓存访问 | 第 1599 / 1605 行 |
| `GetRenderOpacity()` / `SetRenderOpacity(...)` | 渲染不透明度 | 第 1214 / 1220 行 |
| `NeedsPrepass()` / `SetCanTick(...)` / `GetCanTick()` | 布局与 Tick 开关 | 第 665 / 677 / 678 行 |
| `GetPersistentState()` | 持久状态 | 第 691 行 |
| `GetChildren()`（纯虚）/ `GetAllChildren()` | 子级体系 | 第 899 / 907 行 |
| `AddMetadata<T>()` / `RemoveMetaData(...)` / `FindOrAddMetaData<T>()` | 控件元数据 | 第 1439 / 1449 / 1469 行 |

## 五、扩展点

### 5.1 可覆写虚函数

> 类内 `virtual` 声明 **77 条**（口径见取数说明）；下表为设计上常用的覆写点（行号均指 SWidget.h）。

**布局 / 尺寸**

| 虚函数 | 位置 | 备注 |
|---|---|---|
| `ComputeDesiredSize(float)`（纯虚） | 第 774 行（protected） | 必须实现 |
| `OnArrangeChildren(...)`（纯虚） | 第 1780 行（**private 段**） | 派生类可覆写，外部不可调用 |
| `CacheDesiredSize(...)` | 第 759 行 | 缓存布局 |
| `CustomPrepass(...)` | 第 753 行 | 自定义预处理 |
| `GetChildren()`（纯虚）/ `GetAllChildren()` | 第 899 / 907 行 | 子级 |
| `GetRelativeLayoutScale(...)` | 第 876 行 | 子级缩放 |
| `ValidatePathToChild(...)` | 第 701 行 | 命中路径校验 |

**绘制**

| `OnPaint(...)`（纯虚） | 第 1771 行（**private 段**） | 派生类可覆写，外部不可调用 |
| `OnClippingChanged()` | 第 1753 行 | — |
| `GetFocusBrush()` | 第 1731 行 | — |

**输入（键盘 / 鼠标 / 触摸 / 拖放）**

| 虚函数 | 位置 |
|---|---|
| `OnKeyChar` / `OnPreviewKeyDown` / `OnKeyDown` / `OnKeyUp` / `OnAnalogValueChanged` | 第 335 / 348 / 357 / 366 / 375 行 |
| `OnMouseButtonDown` / `OnPreviewMouseButtonDown` / `OnMouseButtonUp` / `OnMouseMove` / `OnMouseEnter` / `OnMouseLeave` / `OnMouseWheel` / `OnMouseButtonDoubleClick` | 第 388-461 行（连续区块） |
| `OnDragDetected` / `OnDragEnter` / `OnDragLeave` / `OnDragOver` / `OnDrop` | 第 497-545 行 |
| `OnTouchGesture` / `OnTouchStarted` / `OnTouchMoved` / `OnTouchEnded` / `OnTouchForceChanged` / `OnTouchFirstMove` / `OnMotionDetected` | 第 557-600 行 |

**焦点 / Tick / 其它**

| `Tick(...)` | 第 303 行 |
| `OnFocusReceived` / `OnFocusLost` / `OnFocusChanging` | 第 316 / 323 / 326 行 |
| `CreateAccessibleWidget()` | 第 658 行 |
| `OnAddedMetadata(...)` / `OnRemovedMetadata(...)` | 第 1482 / 1486 行 |
| `ComputeVolatility()` | 第 1737 行 |

### 5.2 不建议覆写的内部虚函数

| 虚函数 | 原因 |
|---|---|
| `Prepass_Internal`（第 1782 行） | 内部预处理实现细节 |
| `Debug_GetChildrenForReflector()`（第 914 行） | 调试期反射器专用 |

## 六、生命周期

- 纯 C++ 类（非 `UObject`）：无 `BeginPlay` / `Tick` 类引擎钩子。
- 生命周期由 Slate 框架驱动：`SNew(...)` 声明式构造（protected `SWidget()` 第 1675 行 + `SWidgetConstruct` 第 1678 行）→ 加入父级 → 布局（`SlatePrepass` / `ComputeDesiredSize`）→ 绘制（`OnPaint`）→ 可选逐帧（`Tick`，受 `SetCanTick` 控制）→ 移除与析构。
- 构造协议由声明式语法模板（`TSlateDecl` / `SNew`，定义在 `Public/Widgets/DeclarativeSyntaxSupport.h`）驱动；精确调用链属 `flows/` 范畴（暂无 Slate 流程产物）。

## 七、派生类（范围内）

搜索边界：派生类搜索**仅覆盖本版纳入范围的 292 个模块**（Runtime 291 个 + `EnhancedInput` 插件），引擎其余部分（Editor / Developer / Platforms / 未纳入的 Plugins）未覆盖。搜索模式 `\bpublic\s+SWidget\b`（`*.h`）：Runtime **7 行 / 7 文件**；EnhancedInput **0 行**。

| 直接派生类 | 位置 |
|---|---|
| `SPanel` | `Engine/Source/Runtime/SlateCore/Public/Widgets/SPanel.h` 第 29 行 |
| `SLeafWidget` | `Engine/Source/Runtime/SlateCore/Public/Widgets/SLeafWidget.h` 第 28 行 |
| `SCompoundWidget` | `Engine/Source/Runtime/SlateCore/Public/Widgets/SCompoundWidget.h` 第 21 行 |
| `SRichTextBlock` | `Engine/Source/Runtime/Slate/Public/Widgets/Text/SRichTextBlock.h` 第 34 行 |
| `SMultiLineEditableText` | `Engine/Source/Runtime/Slate/Public/Widgets/Text/SMultiLineEditableText.h` 第 48 行 |
| `SWeakWidget` | `Engine/Source/Runtime/Slate/Public/Widgets/SWeakWidget.h` 第 23 行 |
| `SEditableText` | `Engine/Source/Runtime/Slate/Public/Widgets/Input/SEditableText.h` 第 46 行 |

**直接派生仅 7 个**是正常现象：绝大多数控件经 `SCompoundWidget` / `SLeafWidget` / `SPanel` 间接派生（与头文件第 143 行警示一致）。

## 取数说明

| 断言 | 取数方式（相对基准：`Engine/Source`） |
|---|---|
| 文件 2,156 行、类体 163-2067 | `[System.IO.File]::ReadAllLines(...).Count` + `^};` 检索 |
| 类内 `virtual` 77 条 | `Select-String -Pattern '^\s*SLATECORE_API virtual'` 行数（61）+ `^\s*virtual` 行数（21）− 类外 `FPopupLayer` 5 行 = **77** |
| 派生统计：Runtime 7 / EnhancedInput 0 | `Select-String -Pattern '\bpublic\s+SWidget\b'`（`*.h`） |
| 全部行号引用 | 2026-10-10 对 UE 5.8.3 源码本机逐条核对 |

## 相关文档

- `modules/SlateCore-结构.md` —— SWidget 所在模块（同批产出）
- `types/SCompoundWidget.md` —— 常规控件的实用基类（同批产出）
- `modules/Slate-结构.md` —— 高层框架模块（同批产出）
- `modules/UMG-结构.md` —— 蓝图侧 UI 模块（同批产出）
