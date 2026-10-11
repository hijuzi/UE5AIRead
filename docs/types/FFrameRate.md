> 引擎版本：UE 5.8.3 (Build 58210709)
> 源码根：Engine/Source
> 生成技能：ue-type-api v1.0
> 生成时间：2026-10-10
> 校验状态：已校验（2026-10-11）

# FFrameRate

## 一、类型概览

| 项 | 值 |
|---|---|
| 全限定名 | `FFrameRate`（全局命名空间） |
| 定义位置 | `Engine/Source/Runtime/Core/Public/Misc/FrameRate.h`（**所属模块为 `Core`**——随本批 TimeManagement 模块产出并如实标注，同 `types/FSceneInterface.md` 先例） |
| 类型 | 结构体（值类型；帧率） |
| 反射宏 | 本头无 `USTRUCT` / `GENERATED_BODY`（源码注释第 33 行：改数据需同步 `NoExportTypes.h`）；反射镜像在 `Engine/Source/Runtime/CoreUObject/Public/UObject/NoExportTypes.h` 第 2175-2176 行（`USTRUCT(noexport, BlueprintType, meta=...MakeFrameRate/BreakFrameRate)`） |
| 导出策略 | 成员级 `CORE_API`（第 125 / 137 / 142 / 219 行等 7 处）；inline 成员无宏 |
| 所属模块 | `Core`（`Engine/Source/Runtime/Core`） |

## 二、继承链

**无基类**（第 20-21 行：`struct FFrameRate` 后直接 `{`）——值类型，链根。

## 三、声明片段

```
文件：Engine/Source/Runtime/Core/Public/Misc/FrameRate.h
行 20：struct FFrameRate
行 38 / 43：int32 Numerator; / int32 Denominator;（数据成员）
行 220：结构体结束（};；文件 334 行）

同文件配套：自由函数 ParseFrameRate（第 329 行）/ TryParseString（第 334 行）
```

## 四、公开 API

| 签名 | 说明 | 位置 |
|---|---|---|
| `FFrameRate()` | 默认构造（60000/1，常见 60fps 默认值，第 26 行） | 第 25 行 |
| `FFrameRate(uint32, uint32)` | 分子/分母构造 | 第 29 行 |
| `IsValid() const` | 分母 > 0（第 50 行） | 第 48 行 |
| `AsInterval() const` | 每帧秒数（1/rate） | 第 58 行 |
| `AsDecimal() const` | 小数帧率 | 第 65 行 |
| `AsSeconds(FFrameTime) const` / `AsFrameTime(double) const` / `AsFrameNumber(double) const` | 帧↔秒换算 | 第 73 / 81 / 89 行 |
| `IsMultipleOf(FFrameRate) const` / `IsFactorOf(FFrameRate) const` | 帧率整除关系 | 第 94 / 99 行 |
| `static TransformTime(FFrameTime, FFrameRate, FFrameRate)`（虚表外核心工具） | 帧率换算 | 第 109 行 |
| `static Snap(FFrameTime, FFrameRate, FFrameRate)` | 吸附到目标帧率 | 第 119 行 |
| `ToPrettyText() const`（`CORE_API`） | 显示文本 | 第 125 行 |
| `ComputeGridSpacing(...) const`（`CORE_API`） | 时间轴网格间隔计算 | 第 137 行 |
| `MaxSeconds() const`（`CORE_API`） | 最大可表示时长 | 第 142 行 |
| `Reciprocal() const` | 倒数帧率 | 第 147 行 |
| `Serialize(FArchive&)`（`CORE_API`） | 序列化 | 第 219 行 |
| 运算符族（第 152-217 行） | `==` / `!=` / `*` / `/`（含 `FFrameTime / FFrameRate`、`TRange<FFrameNumber> / FFrameRate`）、`GetTypeHash`、`operator<<` | 见左 |

> **不存在**（实测 0 命中）：`GetFrameCount`、`GetFrameCountForTime`、`IsNormalized`、`GetDecimalRounding`。

## 五、扩展点

### 5.1 可覆写虚函数

**无**——文件内 `virtual` 实测 0 处（不可派生替换行为）。

扩展经**自由函数**：`ParseFrameRate`（第 329 行）、`TryParseString`（第 334 行）与运算符族。

### 5.2 不建议覆写的内部虚函数

无。

## 六、生命周期

- **值语义**：默认构造为 60000/1；序列化（第 219 行）与文本解析（第 329 / 334 行）成对。
- 与 `FFrameTime` 的换算（第 73-89 行）是 Sequencer / 动画 / 时间码链路的核心工具函数。

## 七、派生类（范围内）

搜索边界：派生类搜索**覆盖 Runtime 291 个模块 + `EnhancedInput` 插件全部 3 个模块（共 294 个模块）**。搜索模式 `\bpublic\s+FFrameRate\b`（`*.h`）：Runtime **1 命中 / 1 文件**；EnhancedInput **0**。

| 派生类 | 位置 | 状态 |
|---|---|---|
| `FLiveLinkFrameRate : public FFrameRate` | `Engine/Source/Runtime/LiveLinkInterface/Public/LiveLinkTypes.h` 第 538 行 | **4.20 起已弃用**（注释建议直接用 `FFrameRate`） |

> 配套类型（均在 Core）：`FFrameTime`（`Engine/Source/Runtime/Core/Public/Misc/FrameTime.h` 第 15 行）、`FFrameNumber`（`Misc/FrameNumber.h` 第 17 行）、`FQualifiedFrameTime`（`Misc/QualifiedFrameTime.h` 第 12 行）、`FTimecode`（`Misc/Timecode.h` 第 18 行）。

## 取数说明

| 断言 | 取数方式（相对基准：`Engine/Source`） |
|---|---|
| 搜索边界 294 个模块（Runtime 291 + `EnhancedInput` 插件 3） | `[M]` 插件 3 个模块（含白名单外的 `InputBlueprintNodes` / `InputEditor`）：`(Get-ChildItem "Engine/Plugins/EnhancedInput/Source" -Directory).Count` → 3；Runtime 291 见 `_meta/inventory.md` |
| 文件 334 行、结构体 20-220 | `[M]` `[System.IO.File]::ReadAllLines("Engine/Source/Runtime/Core/Public/Misc/FrameRate.h").Count`（同文件 `^};` 检索定类体区间） |
| 类内 `virtual` = 0；`USTRUCT` 0 命中 | `[M]` `Select-String "Engine/Source/Runtime/Core/Public/Misc/FrameRate.h" -Pattern 'virtual' -AllMatches`（类体区间核对） |
| 派生统计：Runtime 1 / EnhancedInput 0 | `[H]` `Select-String -Pattern '\bpublic\s+FFrameRate\b'`（`*.h`） |
| 全部行号引用 | 2026-10-10 对 UE 5.8.3 源码本机逐条核对 |

## 相关文档

- `modules/TimeManagement-结构.md` —— 本批模块（上层设施）
- `types/FUniversalObjectLocator.md` —— 同批类型
- `modules/MovieScene-结构.md` —— 时间轴消费方（批 6）
- `modules/Core-结构.md` —— FFrameRate 的真实归属模块（批 1）

## 更新记录

- 2026-10-11 搜索边界更正：派生搜索实覆盖 **294** 个模块（Runtime 291 + `EnhancedInput` 插件 3），原文误作"纳入范围的 292 个模块"（292 是白名单口径，搜索实际连 `InputBlueprintNodes` / `InputEditor` 一并覆盖，本文件命中的插件侧结果即来自 `InputEditor`）；同时在「取数说明」补入该边界取数方式（`convention.md` 4.2）

- 2026-10-11 按规范 4.2.1 为「取数说明」各行加方法标记（`[M]`/`[R]`/`[H]`）；`[M]` 行把原文省略成 `(...)` 的路径补全为白名单可执行命令，现由 `ue-doc-verify` 逐条实际执行比对
