> 引擎版本：UE 5.8.3 (Build 58210709)
> 源码根：Engine/Source
> 生成技能：ue-module-structure v1.0
> 生成时间：2026-10-10
> 校验状态：已校验（2026-10-11）

# SlateRHIRenderer 模块结构

## 一、模块定位

| 项 | 值 |
|---|---|
| 路径 | `Engine/Source/Runtime/SlateRHIRenderer` |
| 类别 | Runtime |
| 规模 | 47 文件 / 24 头文件（`_meta/engine-modules.json` 口径；公开侧 7 + `Private/` 17） |
| 分层 | UI 渲染 |
| 一句话职责 | Slate 的 RHI 渲染后端：`FSlateRHIRenderer`（渲染器）、`FSlateRHIResourceManager`（资源/图集管理）、字体图集工厂与模块接口——把 Slate 元素批次经 RHI 落到 GPU |

## 二、目录结构

```
SlateRHIRenderer/
├── SlateRHIRenderer.Build.cs     # 模块构建脚本（31 行、0 处 if 分支）
├── Public/                       # 公开侧仅 7 个 .h（顶层 1 + FX/ 3 + Interfaces/ 3；无 Public/Rendering/）
│   ├── SlateRHIRendererSettings.h
│   ├── FX/（SlateFXSubsystem.h / SlateRHIPostBufferBlur.h / SlateRHIPostBufferProcessor.h）
│   └── Interfaces/（ISlate3DRenderer.h / ISlateRHIRendererModule.h / SlateRHIRenderingPolicyInterface.h）
└── Private/                      # 17 个 .h + 20 个 .cpp（SlateRHIRenderer.cpp 76 KB / SlateRHIRenderingPolicy.cpp 79 KB / SlateRHIResourceManager.cpp 38 KB …）
```

- **实现类多在 `Private/`**：`FSlateRHIRenderer final : public FSlateRenderer`（`Private/SlateRHIRenderer.h` 第 40 行）、`FSlateRHIResourceManager : ISlateAtlasProvider, FSlateShaderResourceManager, FTickableGameObject`（`Private/SlateRHIResourceManager.h` 第 114 行）。
- 无 `Internal/`、无 `Tests/`；无聚合头。

## 三、依赖关系

### 3.1 无条件依赖

| 模块 | 类型 | Build.cs 行 | 说明 |
|---|---|---|---|
| `SlateBaseRenderer` | 公开依赖 | 11 | 唯一公开依赖 |
| `Core` | 私有依赖 | 17 | |
| `CoreUObject` | 私有依赖 | 18 | |
| `DeveloperSettings` | 私有依赖 | 19 | 设置类基类 |
| `Slate` | 私有依赖 | 20 | |
| `SlateCore` | 私有依赖 | 21 | |
| `Engine` | 私有依赖 | 22 | |
| `RHI` | 私有依赖 | 23 | |
| `RenderCore` | 私有依赖 | 24 | |
| `Renderer` | 私有依赖 | 25 | **场景渲染器模块**（意外依赖边） |
| `ImageCore` | 私有依赖 | 26 | |
| `HeadMountedDisplay` | 私有依赖 | 27 | |

> 辅助函数检查：**无**——无未展开依赖。

### 3.2 平台与配置条件依赖

**无**——`SlateRHIRenderer.Build.cs` 全文 **0 处 `if` 分支**（实测）。

### 3.3 第三方静态依赖

调用 **0 处**——无第三方静态依赖。

## 四、对外暴露面

> 公开侧共 7 个 `.h`（全列）。

| 头文件 | 提供的能力 |
|---|---|
| `Engine/Source/Runtime/SlateRHIRenderer/Public/Interfaces/ISlateRHIRendererModule.h` | 模块接口 `ISlateRHIRendererModule`（第 21-22 行）：4 条纯虚工厂——`CreateSlateRHIRenderer`（31）/ `CreateSlate3DRenderer`（33）/ `CreateSlateFontAtlasFactory`（35）/ `CreateInstanceBuffer`（37） |
| `Engine/Source/Runtime/SlateRHIRenderer/Public/Interfaces/ISlate3DRenderer.h` | 3D 渲染接口（`FSlateDrawBuffer` 等前置声明） |
| `Engine/Source/Runtime/SlateRHIRenderer/Public/Interfaces/SlateRHIRenderingPolicyInterface.h` | 渲染策略接口 |
| `Engine/Source/Runtime/SlateRHIRenderer/Public/SlateRHIRendererSettings.h` | 渲染设置（基于 `UDeveloperSettings` 设置体系，见 `modules/DeveloperSettings-结构.md`） |
| `Engine/Source/Runtime/SlateRHIRenderer/Public/FX/SlateFXSubsystem.h` 等 3 个 | FX 子系统与后处理缓冲 |

## 五、模块生命周期

```
文件：Engine/Source/Runtime/SlateRHIRenderer/Private/SlateRHIRendererModule.cpp
行 100-101：class FSlateRHIRendererModule / : public ISlateRHIRendererModule（**仅 .cpp 内定义，无头文件**）
行 132-133：virtual void StartupModule( ) override { } / virtual void ShutdownModule( ) override { }
行 161：IMPLEMENT_MODULE( FSlateRHIRendererModule, SlateRHIRenderer )
```

- **启动/关闭为空实现**；实际初始化在**惰性路径** `ConditionalCreateResources()`（第 137-150 行）：创建 `FSlateRHIResourceManager`（第 141 行）、两枚 `FSlateFontCache`（Game 线程第 146 行 / Render 线程第 147 行）、组装 `FSlateFontServices`（第 149 行）。
- 同文件顶部：`FSlateRHIFontAtlasFactory : public ISlateFontAtlasFactory`（第 19 行起）。
- **`SupportsDynamicReloading`**：未覆写（本轮检索 0 命中）。

## 六、关键约定与坑

1. **公开侧只有 7 个头**（顶层 1 + FX 3 + Interfaces 3），**没有 `Public/Rendering/` 目录**——`SlateRHIRenderer.h` / `SlateRHIResourceManager.h` 都在 **`Private/`**；按"公开渲染类"直觉找路径会落空。
2. **模块类 `FSlateRHIRendererModule` 仅在 `.cpp` 内定义**（无头文件）；对外契约是 `Public/Interfaces/ISlateRHIRendererModule.h`。
3. **`FSlateElementBatcher` 与 `FSlateFontCache` 不在本模块**（在 **SlateCore**；本模块经 `FSlateFontServices` 组装两枚 `FSlateFontCache` 使用）。
4. **私有依赖含 `Renderer` 模块**（第 25 行）——Slate 渲染后端依赖场景渲染器模块（依赖图中的意外边）。
5. **数字口径**：`SlateRHIRenderer.Build.cs` 31 行（`ReadAllLines`）、0 处 `if`、0 处三方静态调用；公开侧 7 个 `.h`（模块合计 24）。取数命令见「取数说明」。

## 取数说明

以下命令的相对基准为 `Engine/Source`（实际路径按 `_meta/convention.md` 的本机环境块解析）：

| 断言 | 取数方式 |
|---|---|
| 47 文件 / 24 头文件 | `[M]` 引擎磁盘递归计数：`(Get-ChildItem "Runtime/SlateRHIRenderer" -Recurse -File).Count` 得文件数；`(Get-ChildItem "Runtime/SlateRHIRenderer" -Recurse -File -Filter *.h).Count` 得头文件数（同 `_meta/engine-modules.json` 口径） |
| 公开侧 7 个 `.h` | `[M]` `(Get-ChildItem "Runtime/SlateRHIRenderer/Public" -Recurse -File -Filter *.h).Count` |
| Build.cs 31 行、0 处 `if`、0 处三方静态调用 | `[M]` `[System.IO.File]::ReadAllLines("Runtime/SlateRHIRenderer/SlateRHIRenderer.Build.cs").Count`；`Select-String "Runtime/SlateRHIRenderer/SlateRHIRenderer.Build.cs" -Pattern '\bif\s*\(' -AllMatches`；`Select-String "Runtime/SlateRHIRenderer/SlateRHIRenderer.Build.cs" -Pattern 'AddEngineThirdPartyPrivateStaticDependencies' -AllMatches` |
| 全部行号引用 | 2026-10-10 对 UE 5.8.3 源码本机逐条核对 |

## 相关文档

- `types/FSlateElementBatcher.md` —— 渲染链关键批处理类（归属 SlateCore，随本批产出）
- `modules/SlateCore-结构.md` —— `FSlateElementBatcher` / `FSlateFontCache` 的真实归属（批 3）
- `modules/Renderer-结构.md` —— 私有依赖的场景渲染器（批 5）
- `modules/InputCore-结构.md` —— 同批模块

## 更新记录

- 2026-10-11 修正 `FSlateRHIResourceManager` 创建行号：139 为守卫语句，创建在 141

- 2026-10-11 按规范 4.2.1 为「取数说明」各行加方法标记（`[M]`/`[R]`/`[H]`）；`[M]` 行把原文省略成 `(...)` 的路径补全为白名单可执行命令，现由 `ue-doc-verify` 逐条实际执行比对
