> 引擎版本：UE 5.8.3 (Build 58210709)
> 源码根：Engine/Source
> 生成技能：ue-module-structure v1.0
> 生成时间：2026-10-10
> 校验状态：已校验（2026-10-11）

# UMG 模块结构

## 一、模块定位

| 项 | 值 |
|---|---|
| 路径 | `Engine/Source/Runtime/UMG` |
| 类别 | Runtime |
| 规模 | 315 文件 / 168 头文件（`_meta/engine-modules.json` 2026-10-10 口径）；公开侧 164 个 `.h`（递归计数） |
| 分层 | UI |
| 一句话职责 | 蓝图侧 UI 体系：`UUserWidget`（用户控件）、`UWidget` / `UPanelWidget` 与全套内置控件（`UTextBlock` / `UImage` / `UButton` / `UCanvasPanel`…）、`UWidgetTree` 与 `UWidgetBlueprintGeneratedClass`、控件动画（`UWidgetAnimation`） |

## 二、目录结构

```
UMG/
├── UMG.Build.cs                  # 模块构建脚本（62 行、1 处 if 分支）
├── Public/                       # 公开侧（8 个子目录 + 3 个根文件、164 个 .h）
│   ├── 根文件：IUMGModule.h、UMG.h（聚合头）、UMGStyle.h
│   └── Animation/ Binding/ Blueprint/ Components/ Editor/ Extensions/ FieldNotification/ Slate/
└── Private/                      # 实现（6 个子目录 + 12 个文件；含 UserWidget.cpp 等）
```

- 无 `Internal/`、`Tests/` 仅 `Private/Binding/States/Tests/` 下一处。

## 三、依赖关系

### 3.1 无条件依赖

| 模块 | 类型 | Build.cs 行 | 说明 |
|---|---|---|---|
| `Core` | 私有依赖 | 11 | |
| `TraceLog` | 私有依赖 | 12 | |
| `CoreUObject` | 私有依赖 | 13 | |
| `DeveloperSettings` | 私有依赖 | 14 | |
| `Engine` | 私有依赖 | 15 | |
| `InputCore` | 私有依赖 | 16 | |
| `Slate` | 私有依赖 | 17 | |
| `SlateCore` | 私有依赖 | 18 | |
| `RenderCore` | 私有依赖 | 19 | |
| `Renderer` | 私有依赖 | 20 | |
| `RHI` | 私有依赖 | 21 | |
| `ApplicationCore` | 私有依赖 | 22 | |
| `FieldNotification` | 公开依赖 | 28 | |
| `HTTP` | 公开依赖 | 29 | |
| `MovieScene` | 公开依赖 | 30 | |
| `MovieSceneTracks` | 公开依赖 | 31 | |
| `PropertyPath` | 公开依赖 | 32 | |
| `TimeManagement` | 公开依赖 | 33 | |
| `SlateRHIRenderer` | 私有包含路径 | 39 | 仅加包含路径 |
| `ImageWrapper` | 私有包含路径 | 40 | 同上 |
| `TargetPlatform` | 私有包含路径 | 41 | 同上 |

> 注意依赖方向：UMG 对 `Core` / `Slate` / `SlateCore` 等是**私有**依赖；公开依赖是 `FieldNotification` / `HTTP` / `MovieScene*` 等。
> 辅助函数检查：**无**自定义辅助函数/属性，无 UBT 辅助函数调用——**无未展开依赖**。

### 3.2 平台与配置条件依赖

> 全文 **1 处 `if` 分支**（第 45 行）。

| 依赖 | 类型 | 生效条件 | Build.cs 行 |
|---|---|---|---|
| `ImageWrapper` | 动态加载 | `Type != Server` | 47-51 |
| `SlateRHIRenderer` | 私有依赖 | `Type != Server`（注释：依赖它的实现需以 `#if !UE_SERVER` 守卫） | 55-59 |

### 3.3 第三方静态依赖

`AddEngineThirdPartyPrivateStaticDependencies` 调用 **0 处**——本模块无第三方静态依赖。

## 四、对外暴露面

> 公开侧共 164 个 `.h`；下表为核心契约（均为实测存在）。

| 头文件 | 提供的能力 |
|---|---|
| `Public/UMG.h` | 聚合头（第 32-159 行逐条 include 全部控件与蓝图头） |
| `Public/Blueprint/UserWidget.h` | `UUserWidget`（第 280 行）→ `types/UUserWidget.md` |
| `Public/Components/Widget.h` | `UWidget`（第 216 行，`: public UVisual, public INotifyFieldValueChanged`） |
| `Public/Components/PanelWidget.h` | `UPanelWidget`（第 14 行） |
| `Public/Components/ContentWidget.h` | 内容面板基类头（787 B） |
| `Public/Components/TextBlock.h` | `UTextBlock`（第 23 行） |
| `Public/Components/Image.h` | `UImage` |
| `Public/Components/Button.h` | `UButton` |
| `Public/Components/CanvasPanel.h` | `UCanvasPanel` |
| `Public/Components/SlateWrapperTypes.h` | Slate 包装事件类型（注意：在 `Components/` 下，**不在 Public 根**） |
| `Public/Blueprint/WidgetTree.h` | `UWidgetTree`（第 19 行） |
| `Public/Blueprint/WidgetBlueprintGeneratedClass.h` | `UWidgetBlueprintGeneratedClass`（第 80 行，`: public UBlueprintGeneratedClass`） |
| `Public/Animation/WidgetAnimation.h` | `UWidgetAnimation`（第 25 行，`: public UMovieSceneSequence`） |
| `Public/Slate/SObjectWidget.h` | `SObjectWidget`（第 30 行，`: public SCompoundWidget, public FGCObject`）Slate 桥 |

## 五、模块生命周期

```
文件：Engine/Source/Runtime/UMG/Private/UMGModule.cpp
行 13：class FUMGModule : public IUMGModule

文件：Engine/Source/Runtime/UMG/Private/UMGModule.cpp
行 51：IMPLEMENT_MODULE(FUMGModule, UMG);
```

- **接口**：`IUMGModule : IModuleInterface`（`Public/IUMGModule.h` 第 11 行；接口体为空，无纯虚函数）
- **`StartupModule()`**（第 22-34 行）：`WITH_EDITOR` 且 `GIsEditor` 下——`FUMGStyle::Initialize();`（第 27 行）、`FModuleManager::Get().LoadModule(TEXT("UMGEditor"));`（第 32 行，注释：让运行中的游戏重新编译控件蓝图时可用）
- **`ShutdownModule()`**（第 37-45 行）：编辑器下 `FUMGStyle::Shutdown();`（第 42 行）
- **`SupportsDynamicReloading`**：未覆写（0 命中）

## 六、关键约定与坑

1. **类声明不带类级导出宏**：UE 5.8 的 UMG 采用 `UCLASS(..., MinimalAPI)` + 成员级 `UMG_API`（如 `UserWidget.h` 第 297 行 `UMG_API virtual bool Initialize();`）——`class UMG_API UUserWidget` 形式全库 0 命中（实测）。
2. **`SlateWrapperTypes.h` 不在 Public 根**：实际路径 `Public/Components/SlateWrapperTypes.h`。
3. **构建表方向勿写反**：UMG → `Slate` / `SlateCore` / `Core` 均为**私有**依赖。
4. **无 `Tests/`**（顶层与 `Public/` 无；`Private/Binding/States/Tests/` 下有一处）。
5. **数字口径**：`UMG.Build.cs` 62 行、1 处 `if`、0 处三方静态调用；公开侧 164 个 `.h`。取数命令见「取数说明」。

## 取数说明

以下命令的相对基准为 `Engine/Source`（实际路径按 `_meta/convention.md` 的本机环境块解析）：

| 断言 | 取数方式 |
|---|---|
| 315 文件 / 168 头文件 | `[M]` 引擎磁盘递归计数：`(Get-ChildItem "Runtime/UMG" -Recurse -File).Count` 得文件数；`(Get-ChildItem "Runtime/UMG" -Recurse -File -Filter *.h).Count` 得头文件数（同 `_meta/engine-modules.json` 口径） |
| 公开侧 164 个 `.h`、8 个子目录 | `[M]` `(Get-ChildItem "Runtime\UMG\Public" -Recurse -File -Filter *.h).Count`、目录计数命令 |
| Build.cs 62 行、1 处 `if`、0 处三方静态调用 | `[M]` `[System.IO.File]::ReadAllLines("Runtime/UMG/UMG.Build.cs").Count`；`Select-String "Runtime/UMG/UMG.Build.cs" -Pattern '\bif\s*\(' -AllMatches`；`Select-String "Runtime/UMG/UMG.Build.cs" -Pattern 'AddEngineThirdPartyPrivateStaticDependencies' -AllMatches` |
| 全部行号引用 | 2026-10-10 对 UE 5.8.3 源码本机逐条核对 |

## 相关文档

- `types/UUserWidget.md` —— 本模块核心类型（同批产出）
- `modules/Slate-结构.md`、`modules/SlateCore-结构.md` —— 底层 UI 模块（同批产出）
- `types/SWidget.md`、`types/SCompoundWidget.md` —— Slate 侧基类（同批产出）
- `modules/Engine-结构.md` —— `UUserWidget` 宿主框架模块（已校验）

## 更新记录

- 2026-10-11 修正「无 `Tests/`」结论：`Private/Binding/States/Tests/` 下实有 `WidgetStateBitfieldTests.cpp`（原文两处均作"均无"）

- 2026-10-11 按规范 4.2.1 为「取数说明」各行加方法标记（`[M]`/`[R]`/`[H]`）；`[M]` 行把原文省略成 `(...)` 的路径补全为白名单可执行命令，现由 `ue-doc-verify` 逐条实际执行比对
