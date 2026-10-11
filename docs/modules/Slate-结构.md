> 引擎版本：UE 5.8.3 (Build 58210709)
> 源码根：Engine/Source
> 生成技能：ue-module-structure v1.0
> 生成时间：2026-10-10
> 校验状态：已校验（2026-10-11）

# Slate 模块结构

## 一、模块定位

| 项 | 值 |
|---|---|
| 路径 | `Engine/Source/Runtime/Slate` |
| 类别 | Runtime |
| 规模 | 465 文件 / 267 头文件（`_meta/engine-modules.json` 2026-10-10 口径）；公开侧 239 个 `.h`（递归）、Private 28 个 `.h` |
| 分层 | UI |
| 一句话职责 | Slate 的**高层框架与控件集**：`FSlateApplication`（应用单例、窗口与输入路由）、停靠与通知体系、`SButton` / `STextBlock` / `SListView` 等常用控件、MultiBox 菜单框架——**基础控件基类在 SlateCore**（见第六节第 1 条） |

## 二、目录结构

```
Slate/
├── Slate.Build.cs                # 模块构建脚本（79 行、9 处 if 分支）
├── Public/                       # 公开侧（3 个子目录 + 9 个根 .h、239 个 .h）
│   ├── 根文件：Slate.h、SlateBasics.h、SlateExtras.h、SlateFwd.h、SlateMaterialBrush.h、
│   │           SlateOptMacros.h、SlateScope.h、SlateSettings.h、SlateSharedPCH.h
│   └── Framework/ Navigation/ Widgets/（Widgets/ 下含 Text/ Input/ Layout/ Views/ Docking/ …）
└── Private/                      # 实现（Framework/ Navigation/ Test/ Widgets/ + SlateModule.cpp；28 个 .h）
```

- 测试目录为 `Private/Test/`（单数），本版标注不展开；无 `Internal/`、无 `Tests/`。

## 三、依赖关系

### 3.1 无条件依赖

| 模块 | 类型 | Build.cs 行 | 说明 |
|---|---|---|---|
| `Core` | 公开依赖 | 20 | |
| `CoreUObject` | 公开依赖 | 21 | |
| `InputCore` | 公开依赖 | 22 | |
| `Json` | 公开依赖 | 23 | |
| `SlateCore` | 公开依赖 | 24 | 基类与底层控件在 SlateCore |
| `ImageWrapper` | 公开依赖 | 25 | |
| `TraceLog` | 私有依赖 | 29 | |

> 辅助函数检查：**无**自定义辅助函数/属性，无 UBT 辅助函数调用——**无未展开依赖**。

### 3.2 平台与配置条件依赖

> 全文 **9 处 `if` 分支**（第 10、32、37、41、46、52、60、65、72 行）。

| 依赖 / 项 | 类型 | 生效条件 | Build.cs 行 |
|---|---|---|---|
| `bRequiresPlatformSDK = true`（平台 SDK 开关） | 配置项 | IOS 平台组 | 10-13 |
| `ApplicationCore` | 公开依赖 | `bCompileAgainstApplicationCore` | 32-35 |
| `MacMenu` | 动态加载 | `Platform == Mac` | 46-49 |
| Slate 内容资产（`.ttf` / `.png` / `.svg` / `.tps` / DebugNonUFS） | 运行时依赖 | `bUsesSlate` | 52-58 |
| `*.cur` 光标文件 | 运行时依赖 | `bUsesSlate` 且 Win64（嵌套） | 60-63 |
| 项目内容目录 | 运行时依赖 | `bUsesSlate` 且 `ProjectFile != null`（嵌套） | 65-69 |
| `Settings` | 动态加载 | `bBuildDeveloperTools` | 72-75 |

### 3.3 第三方静态依赖

`AddEngineThirdPartyPrivateStaticDependencies` 全文调用 **2 处**：

| 三方库 | 生效条件 | Build.cs 行 |
|---|---|---|
| `XInput` | `Platform == Win64` | 39 |
| `SDL3` | Linux 平台组（`else if`） | 43 |

## 四、对外暴露面

> 公开侧共 239 个 `.h`；下表为核心契约（均为实测存在）。

| 头文件 | 提供的能力 |
|---|---|
| `Public/SlateBasics.h` | 常用聚合头（第 60 行 include `Widgets/SCompoundWidget.h`） |
| `Public/Slate.h` | 主聚合头 |
| `Public/Framework/Application/SlateApplication.h` | `FSlateApplication`（第 249 行，`: public FSlateApplicationBase, public FGenericApplicationMessageHandler`）应用单例 |
| `Public/Framework/SlateDelegates.h` | 框架级委托 |
| `Public/Widgets/Input/SButton.h` | `SButton`（第 32 行 `class SButton : public SBorder`；第 34 行 `SLATE_DECLARE_WIDGET_API(SButton, SBorder, SLATE_API)`） |
| `Public/Widgets/Text/STextBlock.h` | `STextBlock` |
| `Public/Widgets/Views/STableViewBase.h` | `STableViewBase`（第 115 行） |
| `Public/Widgets/Views/SListView.h` | `SListView`（第 263 行，`: public STableViewBase, ...`） |
| `Public/Widgets/Layout/SScrollBox.h` | `SScrollBox`（第 82 行） |
| `Public/Widgets/Layout/SBorder.h` | `SBorder`（第 30 行） |

## 五、模块生命周期

```
文件：Engine/Source/Runtime/Slate/Private/SlateModule.cpp
行 11-12：class FSlateModule : public IModuleInterface

文件：Engine/Source/Runtime/Slate/Private/SlateModule.cpp
行 32：IMPLEMENT_MODULE(FSlateModule, Slate);
```

- **模块类**：`FSlateModule : IModuleInterface`（第 11-12 行，直接实现接口）
- **`StartupModule()`**（第 14-20 行）：`FAnimatedAttributeManager::Get().SetupTick();`（第 16 行）；`PLATFORM_MAC` 下 `LoadModule("MacMenu")`（第 17-19 行，与 Build.cs 第 48 行动态加载一致）
- **`ShutdownModule()`**（第 22-27 行）：`TeardownTick()`（第 24 行）；`PLATFORM_MAC` 下 `UnloadModule("MacMenu")`（第 25-27 行）
- **`SupportsDynamicReloading`**：未覆写（0 命中）

## 六、关键约定与坑

1. **基础控件基类不在本模块**：`SWidget` / `SCompoundWidget` / `SWindow` / `SBoxPanel` / `SOverlay` / `SLeafWidget` / `SImage` 均在 **SlateCore**（实测：在 Slate 模块内搜索这些文件 0 命中；Slate 通过 Build.cs 第 24 行公开依赖 SlateCore）——按"界面控件都在 Slate"的直觉猜路径会引到不存在的文件。
2. **控件类导出经宏注入**：如 `SButton` 用 `SLATE_DECLARE_WIDGET_API(SButton, SBorder, SLATE_API)`（`SButton.h` 第 34 行），类声明行不带导出宏。
3. **测试目录是 `Private/Test/`（单数）**。
4. **数字口径**：`Slate.Build.cs` 79 行、9 处 `if`、2 处三方静态调用；公开侧 239 个 `.h`（另：Private 28 个 `.h`，模块合计 267）。取数命令见「取数说明」。

## 取数说明

以下命令的相对基准为 `Engine/Source`（实际路径按 `_meta/convention.md` 的本机环境块解析）：

| 断言 | 取数方式 |
|---|---|
| Private 侧 **28** 个 `.h`（公开侧 **239**，模块合计 **267**）；`SupportsDynamicReloading` **0** 命中 | `[M]` `(Get-ChildItem "Runtime/Slate/Private" -Recurse -File -Filter *.h).Count` → 28；`(Get-ChildItem "Runtime/Slate/Public" -Recurse -File -Filter *.h).Count` → 239 |
| 465 文件 / 267 头文件 | `[M]` 引擎磁盘递归计数：`(Get-ChildItem "Runtime/Slate" -Recurse -File).Count` 得文件数；`(Get-ChildItem "Runtime/Slate" -Recurse -File -Filter *.h).Count` 得头文件数（同 `_meta/engine-modules.json` 口径） |
| 公开侧 239 个 `.h`、3 个子目录 | `[M]` `(Get-ChildItem "Runtime\Slate\Public" -Recurse -File -Filter *.h).Count`、目录计数命令 |
| Build.cs 79 行、9 处 `if`、2 处三方静态调用 | `[M]` `[System.IO.File]::ReadAllLines("Runtime/Slate/Slate.Build.cs").Count`；`Select-String "Runtime/Slate/Slate.Build.cs" -Pattern '\bif\s*\(' -AllMatches`；`Select-String "Runtime/Slate/Slate.Build.cs" -Pattern 'AddEngineThirdPartyPrivateStaticDependencies' -AllMatches` |
| 全部行号引用 | 2026-10-10 对 UE 5.8.3 源码本机逐条核对 |

## 相关文档

- `modules/SlateCore-结构.md` —— 底层与基类模块（同批产出）
- `types/SWidget.md`、`types/SCompoundWidget.md` —— 本模块控件的基类（同批产出）
- `modules/UMG-结构.md` —— 蓝图侧 UI 模块（同批产出）
- `modules/Core-结构.md` —— 上游地基模块（已校验）

## 更新记录

- 2026-10-11 「取数说明」补入 1 行计数断言取数方式（`convention.md` 4.2 覆盖要求）

- 2026-10-11 按规范 4.2.1 为「取数说明」各行加方法标记（`[M]`/`[R]`/`[H]`）；`[M]` 行把原文省略成 `(...)` 的路径补全为白名单可执行命令，现由 `ue-doc-verify` 逐条实际执行比对
