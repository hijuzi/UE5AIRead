> 引擎版本：UE 5.8.3 (Build 58210709)
> 源码根：Engine/Source
> 生成技能：ue-type-api v1.0
> 生成时间：2026-10-10
> 校验状态：已校验（2026-10-10）

# UUserWidget

## 一、类型概览

| 项 | 值 |
|---|---|
| 全限定名 | `UUserWidget`（全局命名空间） |
| 定义位置 | `Engine/Source/Runtime/UMG/Public/Blueprint/UserWidget.h` |
| 类型 | 类（反射类型） |
| 反射宏 | `UCLASS(Abstract, editinlinenew, BlueprintType, Blueprintable, meta=( DontUseGenericSpawnObject="True", DisableNativeTick), MinimalAPI)`（第 279 行）+ `GENERATED_BODY()`（第 282 行） |
| 导出策略 | `MinimalAPI` + 成员级 `UMG_API`（如第 286 行构造、第 297 行 `Initialize`）；类声明行不带导出宏（第 280 行） |
| 所属模块 | `UMG`（`Engine/Source/Runtime/UMG`） |

## 二、继承链

```
UObjectBase            （Engine/Source/Runtime/CoreUObject/Public/UObject/UObjectBase.h 第 66 行；链根）
  └─ UObjectBaseUtility（Engine/Source/Runtime/CoreUObject/Public/UObject/UObjectBaseUtility.h 第 44 行）
       └─ UObject      （Engine/Source/Runtime/CoreUObject/Public/UObject/Object.h 第 98 行）
            └─ UVisual（Engine/Source/Runtime/UMG/Public/Components/Visual.h 第 12 行，`: public UObject`）
                 └─ UWidget（Engine/Source/Runtime/UMG/Public/Components/Widget.h 第 216 行，`: public UVisual, public INotifyFieldValueChanged`）
                      └─ UUserWidget（…/UMG/Public/Blueprint/UserWidget.h 第 280 行，`: public UWidget, public INamedSlotInterface`）
```

接口：`INamedSlotInterface`（`Components/NamedSlotInterface.h` 第 22 行；`UINTERFACE` 第 16 行）。

派生方向：范围内真实派生 1 个（见第七节）。

## 三、声明片段

```
文件：Engine/Source/Runtime/UMG/Public/Blueprint/UserWidget.h
行 279-282：UCLASS(..., MinimalAPI) / class UUserWidget : public UWidget, public INamedSlotInterface / { / GENERATED_BODY()

文件：Engine/Source/Runtime/UMG/Public/Blueprint/UserWidget.h
行 1521-1524：public: / UPROPERTY(Transient, DuplicateTransient, TextExportTransient) / WidgetTree 成员

文件：Engine/Source/Runtime/UMG/Public/Blueprint/UserWidget.h
行 1807：类体结束（};；文件 1,839 行）
```

## 四、公开 API

> 关键条目节选；完整接口见头文件（1,839 行）。

| 签名 / 成员 | 说明 | 位置 |
|---|---|---|
| `Initialize()`（虚） | 控件初始化（返回是否成功） | 第 297 行 |
| `OnInitialized()` | 蓝图 `OnInitialized` 事件的 C++ 入口 | 第 508 行 |
| `PreConstruct(bool IsDesignTime)` | 蓝图 `PreConstruct` 事件（设计时也调用） | 第 523 行 |
| `Construct()` | 蓝图 `Construct` 事件（构建 UI 时） | 第 531 行 |
| `Destruct()` | 蓝图 `Destruct` 事件（移除时） | 第 538 行 |
| `Tick(FGeometry, float)` | 蓝图 `Tick` 事件入口 | 第 547 行 |
| `OnPaint(FPaintContext&)` | 蓝图绘制事件入口 | 第 553 行 |
| `GetWidgetFromName(const FName&)` | 按名取子树控件 | 第 1426 行 |
| `GetRootWidget()` / `GetSlateWidgetFromName(...)` | 根控件 / 取底层 Slate 控件 | 第 1420 / 1423 行 |
| `AddToViewport(int32 ZOrder)` / `RemoveFromViewport()` | 加入/移除视口（后者自 5.1 起废弃） | 第 342 / 358 行 |
| `SetPositionInViewport(...)` | 视口定位 | 第 368 行 |
| `GetIsVisible()` | 可见性（已废弃，指向 `IsInViewport`） | 第 393 行 |
| `GetOwningLocalPlayer()` / `GetOwningPlayer()` / `GetOwningPlayerPawn()` | 所属玩家链路 | 第 408 / 430 / 454 行 |
| `PlayAnimation(...)` / `PlayAnimationForward(...)` / `PlayAnimationReverse(...)` / `StopAnimation(...)` | 控件动画控制（返回 `FWidgetAnimationHandle`） | 第 1193 / 1220 / 1233 / 1241 行 |
| `WidgetTree`（`TObjectPtr<UWidgetTree>`） | 控件树成员（由蓝图初始化） | 第 1524 行 |

> `IsInViewport()` **不在 UUserWidget**——定义在基类 `UWidget`（`Components/Widget.h` 第 549 行）。

## 五、扩展点

### 5.1 可覆写虚函数

> 类内 `virtual` 声明 **79 条**（逐段枚举口径，见取数说明）。

**a) 生命周期 Native\*（C++ 侧覆写点，均为 `protected`，第 1572 行起）**

| 虚函数 | 对应蓝图事件 | 位置 |
|---|---|---|
| `NativeOnInitialized()` | `OnInitialized` | 第 1582 行 |
| `NativePreConstruct()` | `PreConstruct` | 第 1583 行 |
| `NativeConstruct()` | `Construct` | 第 1584 行 |
| `NativeDestruct()` | `Destruct` | 第 1585 行 |
| `NativeTick(const FGeometry&, float)` | `Tick` | 第 1586 行 |

**b) 绘制**

| `NativePaint(...)` | 第 1592 行（protected） | 自定义绘制 |

**c) 输入 / 交互（39 条，第 1597-1636 行连续区块，均为 protected）**

覆盖：`NativeOnFocusReceived` / `NativeOnFocusLost` / `NativeOnKeyDown` / `NativeOnMouseButtonDown` / `NativeOnMouseMove` / `NativeOnMouseWheel` / `NativeOnDragDetected` / `NativeOnDrop` / `NativeOnTouchStarted` / `NativeOnCursorQuery` / `NativeOnMouseCaptureLost` 等（逐条行号见该区块；完整清单以头文件为准）。

**d) 动画**

| `OnAnimationStarted_Implementation(...)` | 第 947 行（对应蓝图事件第 945 行） |
| `OnAnimationFinished_Implementation(...)` | 第 957 行（对应蓝图事件第 954 行） |
| `OnAnimationStartedPlaying(...)` | 第 981 行（自 5.6 起废弃） |
| `OnAnimationFinishedPlaying(...)` | 第 984 行（自 5.6 起废弃） |

其余 override（`GetWorld` / `GetOwningLocalPlayer` / `GetOwningPlayer` 等）共 12 条，分布于第 289-430 行。

### 5.2 不建议覆写的内部虚函数

| 虚函数 | 原因 |
|---|---|
| `InitializeNativeClassData()`（第 313 行） | 原生类数据初始化（框架内部） |
| `RebuildWidget()` / `OnWidgetRebuilt()`（第 1576 / 1577 行） | 底层 Slate 控件重建流程 |
| `CreateInputComponent(...)` / `DestroyInputComponent()`（第 1740 / 1761 行） | 输入组件生命周期（框架管理） |

## 六、生命周期

- **创建**：`Initialize()`（第 297 行，`CreateWidget` 流程驱动）→ `NativeOnInitialized` → 设计/构建：`NativePreConstruct` → `NativeConstruct`（加入游戏后）。
- **运行**：`NativeTick`（受 `TickFrequency` 控制；`UCLASS` meta 含 `DisableNativeTick` 提示）。
- **移除**：`NativeDestruct`（第 1585 行）。
- **动画**：`PlayAnimation` 系列（第 1193 行起）驱动；播放状态经 `OnAnimationStarted_Implementation` / `OnAnimationFinished_Implementation`（第 947 / 957 行）回调。
- 各阶段与 `UWidget` / `SWidget`（`SObjectWidget`）的跨类调用链属 `flows/` 范畴（暂无 UMG 流程产物）。

## 七、派生类（范围内）

搜索边界：派生类搜索**仅覆盖本版纳入范围的 292 个模块**（Runtime 291 个 + `EnhancedInput` 插件），引擎其余部分（Editor / Developer / Platforms / 未纳入的 Plugins）未覆盖。搜索模式 `\bpublic\s+UUserWidget\b`（`*.h`）：Runtime 命中 **2 行 / 2 文件**（其中 1 行为文档注释示例，见下）；EnhancedInput 命中 **0**。

| 派生类 | 位置 | 备注 |
|---|---|---|
| `ULevelSequenceBurnIn` | `Engine/Source/Runtime/LevelSequence/Public/LevelSequenceBurnIn.h` 第 17 行 | 范围内**唯一真实派生** |
| （注释示例） | `Engine/Source/Runtime/UMG/Public/Components/ListViewBase.h` 第 579 行 | 文档注释中的 `class UMyUserWidget : public UUserWidget` 示例，**非真实派生** |

> 多数 `UUserWidget` 派生类分布在 Editor 与 Plugins（如 CommonUI、EditorUtilityWidget、电影渲染管线），**属覆盖范围之外**——不要据此推断"引擎只有这一个派生"。

## 取数说明

| 断言 | 取数方式（相对基准：`Engine/Source`） |
|---|---|
| 文件 1,839 行、类体 280-1807 | `[System.IO.File]::ReadAllLines(...).Count` + `^};` 检索 |
| 类内 `virtual` 79 条 | 全文 `virtual` 全匹配 80 处（含注释）；类体逐段枚举 79 条声明 |
| 派生统计：Runtime 2 行 / 2 文件（1 注释）；EnhancedInput 0 | `Select-String -Pattern '\bpublic\s+UUserWidget\b'`（`*.h`） |
| 全部行号引用 | 2026-10-10 对 UE 5.8.3 源码本机逐条核对 |

## 相关文档

- `modules/UMG-结构.md` —— UUserWidget 所在模块（同批产出）
- `types/SWidget.md`、`types/SCompoundWidget.md` —— 底层 Slate 控件体系（同批产出）
- `modules/Slate-结构.md`、`modules/SlateCore-结构.md` —— 底层 UI 模块（同批产出）
- `types/UObject.md` —— 基类链终点（已校验）
