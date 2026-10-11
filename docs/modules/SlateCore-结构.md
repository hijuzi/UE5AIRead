> 引擎版本：UE 5.8.3 (Build 58210709)
> 源码根：Engine/Source
> 生成技能：ue-module-structure v1.0
> 生成时间：2026-10-10
> 校验状态：已校验（2026-10-11）

# SlateCore 模块结构

## 一、模块定位

| 项 | 值 |
|---|---|
| 路径 | `Engine/Source/Runtime/SlateCore` |
| 类别 | Runtime |
| 规模 | 327 文件 / 189 头文件（`_meta/engine-modules.json` 2026-10-10 口径）；公开侧 155 个 `.h`（递归计数） |
| 分层 | UI |
| 一句话职责 | Slate 声明式 UI 的**底层与基类层**：`SWidget` 控件基类与声明式语法、绘制（`FSlateDrawElement`）、输入回复（`FReply`）、样式与笔刷（`FSlateBrush`/`FSlateStyleSet`）、字体（`FSlateFontInfo`）、布局槽体系（`FChildren`） |

## 二、目录结构

```
SlateCore/
├── SlateCore.Build.cs            # 模块构建脚本（63 行、5 处 if 分支）
├── Public/                       # 公开侧（16 个子目录 + 3 个根文件、155 个 .h）
│   ├── 根文件：SlateCore.h（聚合头）、SlateGlobals.h、SlotBase.h
│   └── Animation/ Application/ Brushes/ Containers/ Debugging/ FastUpdate/ Fonts/ Input/
│       Layout/ Rendering/ Sound/ Styling/ Textures/ Trace/ Types/ Widgets/
└── Private/                      # 实现（16 个子目录 + 4 个文件；含 Test/ 测试目录）
```

- 公开侧为 `Public/`；无 `Internal/`、无 `Tests/`（测试目录是 `Private/Test/`，单数，本版标注不展开）。

## 三、依赖关系

### 3.1 无条件依赖

| 模块 | 类型 | Build.cs 行 | 说明 |
|---|---|---|---|
| `Core` | 公开依赖 | 15 | |
| `CoreUObject` | 公开依赖 | 16 | |
| `DeveloperSettings` | 公开依赖 | 17 | |
| `InputCore` | 公开依赖 | 18 | |
| `Json` | 公开依赖 | 19 | |
| `TraceLog` | 公开依赖 | 20 | |
| `ImageCore` | 私有依赖 | 24 | |

> 辅助函数检查：**无**自定义辅助函数/属性，无 UBT 辅助函数调用——**无未展开依赖**。

### 3.2 平台与配置条件依赖

> 全文 **5 处 `if` 分支**（第 27、32、34、44、58 行）。

| 依赖 | 类型 | 生效条件 | Build.cs 行 |
|---|---|---|---|
| `ApplicationCore` | 公开依赖 | `Target.bCompileAgainstApplicationCore` | 27-30 |

> 其余条件分支作用于**第三方静态依赖**（见 3.3）；`Server` 分支（第 52-56 行）只设置
> `WITH_FREETYPE=0` / `WITH_HARFBUZZ=0` 宏，不追加任何模块依赖。

### 3.3 第三方静态依赖

`AddEngineThirdPartyPrivateStaticDependencies` 全文调用 **5 处**：

| 三方库 | 生效条件 | Build.cs 行 |
|---|---|---|
| `FreeType2` | `Type != Server` 且 `bCompileFreeType` | 36 |
| `ICU` | `Type != Server` 且 `bCompileICU` | 46 |
| `HarfBuzz` | `Type != Server` | 49 |
| `Nanosvg` | `Type != Server` | 50 |
| `XInput` | `Platform == Win64` | 60 |

## 四、对外暴露面

> 公开侧共 155 个 `.h`（16 个子目录）；下表为核心契约。

| 头文件 | 提供的能力 |
|---|---|
| `Public/SlateCore.h` | 聚合头（第 131 行 include `Widgets/SCompoundWidget.h`） |
| `Public/Widgets/SWidget.h` | `SWidget`（第 163 行）——所有 Slate 控件基类（→ `types/SWidget.md`） |
| `Public/Widgets/SCompoundWidget.h` | `SCompoundWidget`（第 21 行）（→ `types/SCompoundWidget.md`） |
| `Public/Widgets/SWindow.h` | `SWindow`（第 240 行）窗口 |
| `Public/Widgets/SBoxPanel.h` | `SBoxPanel`（第 33 行）盒式布局 |
| `Public/Widgets/SOverlay.h` | `SOverlay`（第 43 行）叠层 |
| `Public/Widgets/SLeafWidget.h` | `SLeafWidget`（第 27 行）叶控件基类 |
| `Public/Widgets/Images/SImage.h` | `SImage` 图片控件 |
| `Public/Widgets/DeclarativeSyntaxSupport.h` | `SNew` / `SLATE_BEGIN_ARGS` 声明式语法 |
| `Public/Layout/Children.h` | 子级槽体系（如 `TSingleWidgetChildrenWithBasicLayoutSlot`，第 406 行） |
| `Public/Styling/SlateBrush.h` | `FSlateBrush`（第 235 行） |
| `Public/Styling/SlateStyle.h` | `FSlateStyleSet`（第 27 行） |
| `Public/Styling/SlateTypes.h` | 样式类型集合（98.92 KB，模块内最大公开头之一） |
| `Public/Fonts/SlateFontInfo.h` | `FSlateFontInfo`（第 146 行） |
| `Public/Input/Reply.h` | `FReply` 输入回复 |
| `Public/Rendering/DrawElements.h` | 绘制元素（`FSlateDrawElement`） |
| `Public/Types/SlateEnums.h` | 公共枚举（`EVisibility` 等） |
| `Public/SlateGlobals.h` | Slate 全局状态 |

## 五、模块生命周期

```
文件：Engine/Source/Runtime/SlateCore/Private/SlateCoreModule.h
行 21：class FSlateCoreModule : public IModuleInterface（位于 namespace UE 内，第 19 行起）

文件：Engine/Source/Runtime/SlateCore/Private/SlateCoreModule.cpp
行 77：IMPLEMENT_MODULE(UE::FSlateCoreModule, SlateCore);
```

- **模块类**：`UE::FSlateCoreModule : IModuleInterface`（**在 `UE` 命名空间内**，全限定名 `UE::FSlateCoreModule`）
- **`StartupModule()`**（cpp 第 48-51 行）：唯一行为 `SlateCoreModuleInstance = this;`（第 50 行，写入文件内全局指针）
- **`ShutdownModule()`**（cpp 第 53-56 行）：`SlateCoreModuleInstance = nullptr;`（第 55 行）
- **构造函数**（cpp 第 33-46 行）：`WITH_SLATE_DEBUGGING` 下创建 7 个调试器对象（如 `SlateDebuggerPaint` 第 39 行）
- **`SupportsDynamicReloading`**：未覆写（0 命中）；无 Tick、无控制台命令/委托注册

## 六、关键约定与坑

1. **类级导出是"宏注入"**：`SWidget` / `SCompoundWidget` 的声明行**不带** `SLATECORE_API` 前缀；导出经类体内 `SLATE_DECLARE_WIDGET_API(...)`（`SWidget.h` 第 167 行 / `SCompoundWidget.h` 第 23 行；宏定义在 `Public/Widgets/SlateControlledConstruction.h` 第 22-45 行）——按 `class SLATECORE_API SWidget` 检索零命中属预期。
2. **`SWidget` 中 `OnPaint` / `OnArrangeChildren` 是 private 虚函数**（`SWidget.h` 第 1771 / 1780 行）、`ComputeDesiredSize` 是 protected（第 774 行）——派生类可覆写，外部不可调用。
3. **测试目录是 `Private/Test/`（单数）**，不是 `Tests/`。
4. **数字口径**：`SlateCore.Build.cs` 63 行、5 处 `if`、5 处三方静态调用；公开侧 16 个子目录、155 个 `.h`。取数命令见「取数说明」。

## 取数说明

以下命令的相对基准为 `Engine/Source`（实际路径按 `_meta/convention.md` 的本机环境块解析）：

| 断言 | 取数方式 |
|---|---|
| `WITH_SLATE_DEBUGGING` 下创建 **7** 个调试器对象；`SupportsDynamicReloading` **0** 命中 | `[H]` 逐行通读 cpp 第 33-46 行调试器创建段 → **7**；对 `Runtime/SlateCore/` 按 `SupportsDynamicReloading` 检索 → **0** |
| 327 文件 / 189 头文件 | `[M]` 引擎磁盘递归计数：`(Get-ChildItem "Runtime/SlateCore" -Recurse -File).Count` 得文件数；`(Get-ChildItem "Runtime/SlateCore" -Recurse -File -Filter *.h).Count` 得头文件数（同 `_meta/engine-modules.json` 口径） |
| 公开侧 155 个 `.h`、16 个子目录 | `[M]` `(Get-ChildItem "Runtime\SlateCore\Public" -Recurse -File -Filter *.h).Count`、目录计数命令 |
| Build.cs 63 行、5 处 `if`、5 处三方静态调用 | `[M]` `[System.IO.File]::ReadAllLines("Runtime/SlateCore/SlateCore.Build.cs").Count`；`Select-String "Runtime/SlateCore/SlateCore.Build.cs" -Pattern '\bif\s*\(' -AllMatches`；`Select-String "Runtime/SlateCore/SlateCore.Build.cs" -Pattern 'AddEngineThirdPartyPrivateStaticDependencies' -AllMatches` |
| 全部行号引用 | 2026-10-10 对 UE 5.8.3 源码本机逐条核对 |

## 相关文档

- `types/SWidget.md` —— 本模块控件基类（同批产出）
- `types/SCompoundWidget.md` —— 本模块复合控件基类（同批产出）
- `modules/Slate-结构.md` —— 上层框架模块（同批产出）
- `modules/UMG-结构.md` —— 蓝图侧 UI 模块（同批产出）
- `modules/Core-结构.md` —— 上游地基模块（已校验）

## 更新记录

- 2026-10-11 修正两处行号：`SlateDebuggerPaint` 对象创建 40 → 39；`SLeafWidget` 类关键字 28 → 27

- 2026-10-11 「取数说明」补入 1 行计数断言取数方式（`convention.md` 4.2 覆盖要求）

- 2026-10-11 按规范 4.2.1 为「取数说明」各行加方法标记（`[M]`/`[R]`/`[H]`）；`[M]` 行把原文省略成 `(...)` 的路径补全为白名单可执行命令，现由 `ue-doc-verify` 逐条实际执行比对
