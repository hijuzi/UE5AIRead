> 引擎版本：UE 5.8.3 (Build 58210709)
> 源码根：Engine/Source
> 生成技能：ue-type-api v1.0
> 生成时间：2026-10-10
> 校验状态：已校验（2026-10-11）

# FSlateElementBatcher

## 一、类型概览

| 项 | 值 |
|---|---|
| 全限定名 | `FSlateElementBatcher`（全局命名空间） |
| 定义位置 | `Engine/Source/Runtime/SlateCore/Public/Rendering/ElementBatcher.h`（**所属模块为 `SlateCore`**——随本批 SlateRHIRenderer 模块产出并如实标注，同 `types/FSceneInterface.md` 之于 Renderer 的先例） |
| 类型 | 类（纯 C++；无反射） |
| 反射宏 | 无（`UCLASS` / `GENERATED` 实测 0 命中） |
| 导出策略 | 逐成员 `SLATECORE_API`（类声明行无宏；第 249 / 250 / 257 / 280 行等） |
| 所属模块 | `SlateCore`（`Engine/Source/Runtime/SlateCore`） |
| 选型说明 | Slate 渲染链的核心概念"元素批处理"的实现类；其与 `FSlateFontCache` 均归 SlateCore，由 SlateRHIRenderer 侧（`FSlateFontServices` / 渲染策略）组装调用 |

## 二、继承链

**无基类**（第 245-246 行：`class FSlateElementBatcher` 后直接 `{`）——链根（纯 C++ 类）。

## 三、声明片段

```
文件：Engine/Source/Runtime/SlateCore/Public/Rendering/ElementBatcher.h
行 242-245：/** A class which batches Slate elements for rendering. */ / class FSlateElementBatcher
行 526：类体结束（};；文件 526 行）
```

## 四、公开 API（类内 public 段 12 条，全列）

| 签名 | 说明 | 位置 |
|---|---|---|
| `FSlateElementBatcher(TSharedRef<FSlateRenderingPolicy>)`（`SLATECORE_API`） | 构造（注入渲染策略） | 第 249 行 |
| `~FSlateElementBatcher()`（`SLATECORE_API`） | 析构 | 第 250 行 |
| `AddElements(FSlateWindowElementList&)`（`SLATECORE_API`） | **主入口**：收集窗口元素并生成批次 | 第 257 行 |
| `RequiresVsync() const` | 是否需要垂直同步 | 第 262 行 |
| `HasFXPassses() const` | 是否有后处理通道 | 第 265 行 |
| `CompositeHDRViewports() const` | 是否合成 HDR 视口 | 第 267 行 |
| `GetUsedSlatePostBuffers() const` | 使用的后处理缓冲位掩码 | 第 269 行 |
| `GetResourceUpdatingPostBuffers() const` | 需要更新资源的缓冲 | 第 271 行 |
| `SetResourceUpdatingPostBuffers(ESlatePostRT)` | 设置更新缓冲 | 第 273 行 |
| `SetCompositeHDRViewports(bool)` | 设置 HDR 合成 | 第 275 行 |
| `ResetBatches()`（`SLATECORE_API`） | 清空批次（复用） | 第 280 行 |
| `PackVertexColor(const FLinearColor&) const`（inline） | 顶点色打包（sRGB 感知） | 第 282 行 |

## 五、扩展点

### 5.1 可覆写虚函数

**无**——类内 `virtual` 实测 0 处（文件内 2 处 "virtual" 命中均为注释文本："virtual texture feedback"，第 167 / 237 行）。

### 5.2 不建议覆写的内部虚函数

无。

## 六、生命周期

- **单次批处理周期**：`AddElements`（第 257 行，把窗口元素列表转成绘制批次）→ 由 SlateRHIRenderer / 渲染策略提交 → `ResetBatches`（第 280 行）复用实例。
- 构造时注入 `FSlateRenderingPolicy`（第 249 行）——批处理与渲染策略解耦（策略在 `SlateRHIRenderer/Private/SlateRHIRenderingPolicy.h`）。

## 七、派生类（范围内）

搜索边界：派生类搜索**覆盖 Runtime 291 个模块 + `EnhancedInput` 插件全部 3 个模块（共 294 个模块）**。搜索模式 `\bpublic\s+FSlateElementBatcher\b`（`*.h`）：Runtime **0 命中**；EnhancedInput **0**。

| 派生类 | — |
|---|---|
| （无） | 无派生（扩展经渲染策略而非子类化） |

> 配套定位：`FSlateRenderingPolicy`（`Engine/Source/Runtime/SlateRHIRenderer/Private/SlateRHIRenderingPolicy.h`）；`FSlateDrawBuffer`（`Engine/Source/Runtime/SlateCore/Public/Rendering/SlateDrawBuffer.h` 第 19 行，`: public FGCObject`）；字体链 `FSlateFontCache`（`Engine/Source/Runtime/SlateCore/Public/Fonts/FontCache.h` 第 756 行）。

## 取数说明

| 断言 | 取数方式（相对基准：`Engine/Source`） |
|---|---|
| 类内 public 段 **12** 条 | `[H]` 逐行通读 `SlateElementBatcher.h` 类体 public 段，登记全部成员函数 = **12** |
| 搜索边界 294 个模块（Runtime 291 + `EnhancedInput` 插件 3） | `[M]` 插件 3 个模块（含白名单外的 `InputBlueprintNodes` / `InputEditor`）：`(Get-ChildItem "Engine/Plugins/EnhancedInput/Source" -Directory).Count` → 3；Runtime 291 见 `_meta/inventory.md` |
| 文件 526 行、类体 245-526 | `[M]` `[System.IO.File]::ReadAllLines("Engine/Source/Runtime/SlateCore/Public/Rendering/ElementBatcher.h").Count`（同文件 `^};` 检索定类体区间） |
| 类内 `virtual` = 0 | `[H]` `Select-String -Pattern '\bvirtual\b'` 逐行核对（命中均为 "virtual texture" 注释） |
| 派生统计：0 命中 | `[H]` `Select-String -Pattern '\bpublic\s+FSlateElementBatcher\b'`（`*.h`） |
| 全部行号引用 | 2026-10-10 对 UE 5.8.3 源码本机逐条核对 |

## 相关文档

- `modules/SlateRHIRenderer-结构.md` —— 本批模块（渲染链上游）
- `modules/SlateCore-结构.md` —— FSlateElementBatcher 的真实归属模块（批 3）
- `types/SWidget.md`、`types/SCompoundWidget.md` —— 元素来源（批 3）
- `types/FKey.md` —— 同批类型

## 更新记录

- 2026-10-11 搜索边界更正：派生搜索实覆盖 **294** 个模块（Runtime 291 + `EnhancedInput` 插件 3），原文误作"纳入范围的 292 个模块"（292 是白名单口径，搜索实际连 `InputBlueprintNodes` / `InputEditor` 一并覆盖，本文件命中的插件侧结果即来自 `InputEditor`）；同时在「取数说明」补入该边界取数方式（`convention.md` 4.2）

- 2026-10-11 「取数说明」补入 1 行计数断言取数方式（`convention.md` 4.2 覆盖要求）

- 2026-10-11 按规范 4.2.1 为「取数说明」各行加方法标记（`[M]`/`[R]`/`[H]`）；`[M]` 行把原文省略成 `(...)` 的路径补全为白名单可执行命令，现由 `ue-doc-verify` 逐条实际执行比对
