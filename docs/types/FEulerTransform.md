> 引擎版本：UE 5.8.3 (Build 58210709)
> 源码根：Engine/Source
> 生成技能：ue-type-api v1.0
> 生成时间：2026-10-10
> 校验状态：已校验（2026-10-11）

# FEulerTransform

## 一、类型概览

| 项 | 值 |
|---|---|
| 全限定名 | `FEulerTransform`（全局命名空间） |
| 定义位置 | `Engine/Source/Runtime/AnimationCore/Public/EulerTransform.h` |
| 类型 | 结构体（反射值类型；欧拉角表达的变换） |
| 反射宏 | `USTRUCT(BlueprintType)`（第 30 行）+ `GENERATED_BODY()`（第 33 行） |
| 导出策略 | 类级无宏；成员级 `ANIMATIONCORE_API` **仅 1 处**（第 40 行 `Identity`） |
| 所属模块 | `AnimationCore`（`Engine/Source/Runtime/AnimationCore`） |

## 二、继承链

**无基类**（第 31-32 行：`struct FEulerTransform` 后直接 `{`）——值类型链根。

## 三、声明片段

```
文件：Engine/Source/Runtime/AnimationCore/Public/EulerTransform.h （119 行）
行 30-33：USTRUCT(BlueprintType) / struct FEulerTransform / { / GENERATED_BODY()
行 114：结构体结束（};）
同文件配套：EEulerRotationOrder 枚举（第 20 行）；TBaseStructure<FEulerTransform> 特化（第 116-119 行）
```

## 四、公开 API

| 签名 | 说明 | 位置 |
|---|---|---|
| `typedef FVector::FReal FReal` | 精度别名 | 第 35 行 |
| `static const FEulerTransform Identity`（`ANIMATIONCORE_API`，定义于 `Private/EulerTransform.cpp` 第 8 行） | 单位变换 | 第 40 行 |
| `FEulerTransform()` | 默认构造 | 第 42 行 |
| `FEulerTransform(const FVector&, const FRotator&, const FVector&)` | 位置/旋转/缩放构造 | 第 49 行 |
| `FEulerTransform(const FRotator&, const FVector&, const FVector&)` | 旋转/位置/缩放构造 | 第 56 行 |
| `explicit FEulerTransform(const FTransform&)` | 从 `FTransform` 转换 | 第 63 行 |
| `Location` / `Rotation` / `Scale`（各带 `UPROPERTY(EditAnywhere, BlueprintReadWrite)`） | 数据成员 | 第 73 / 77 / 81 行 |
| `ToFTransform() const` | 转 `FTransform` | 第 84 行 |
| `FromFTransform(const FTransform&)` | 自 `FTransform` 赋值 | 第 90 行 |
| `Equals(const FEulerTransform&, FReal Tolerance) const` | 容差比较 | 第 98 行 |
| `GetLocation()` / `GetRotation()`（`FQuat`）/ `Rotator()` / `GetScale3D()` | 访问器 | 第 105 / 106 / 107 / 108 行 |
| `SetLocation(...)` / `SetRotation(FQuat)` / `SetRotator(FRotator)` / `SetScale3D(...)` | 设置器 | 第 109 / 110 / 111 / 112 行 |
| `NormalizeRotation()` | 归一化（空实现，为接口一致性保留） | 第 113 行 |

## 五、扩展点

### 5.1 可覆写虚函数

**无**——文件内 `virtual` 实测 **0 处**（值类型）。扩展经 `FTransform` 转换（第 84 / 90 行）与反射序列化。

### 5.2 不建议覆写的内部虚函数

无。

## 六、生命周期

- **值语义**：可经 `UPROPERTY(BlueprintReadWrite)` 在蓝图读写（第 72-81 行）；与 `FTransform` 双向互转（第 84 / 90 行）——注意 `FTransform` 内部存 `FQuat`，本类型存 `FRotator`（欧拉角，方便直接编辑角度）。
- 序列化经 USTRUCT 反射通道（无显式 `Serialize`）。

## 七、派生类（范围内）

搜索边界：派生类搜索**覆盖 Runtime 291 个模块 + `EnhancedInput` 插件全部 3 个模块（共 294 个模块）**。搜索模式 `\bpublic\s+FEulerTransform\b`（`*.h`）：Runtime **0 命中**；EnhancedInput **0**。

| 派生类 | — |
|---|---|
| （无） | 值类型，无派生 |

> 配套定位：`FAxis`（`AnimationCore/Public/CommonAnimTypes.h` 第 13 行，48 行）、`FTransformConstraint`（`AnimationCore/Public/Constraint.h` 第 285 行，40 行）、`EEulerRotationOrder`（本文件第 20 行）。
> 跨模块消费（证据）：`MovieScene`（`MovieScenePropertyTemplate.h` 等）、`MovieSceneTracks`（`MovieScene3DTransformSection.cpp` 等）——全引擎 15 个文件 / 5 个模块引用。

## 取数说明

| 断言 | 取数方式（相对基准：`Engine/Source`） |
|---|---|
| 跨模块消费证据 **15** 处 | `[H]` 在 `Runtime/MovieScene` 与 `Runtime/MovieSceneTracks` 内按 `FEulerTransform` 检索（`*.h` + `*.cpp`，区分大小写），逐一登记引用点 = **15** |
| 搜索边界 294 个模块（Runtime 291 + `EnhancedInput` 插件 3） | `[M]` 插件 3 个模块（含白名单外的 `InputBlueprintNodes` / `InputEditor`）：`(Get-ChildItem "Engine/Plugins/EnhancedInput/Source" -Directory).Count` → 3；Runtime 291 见 `_meta/inventory.md` |
| 文件 119 行、结构体 30-114 | `[M]` `[System.IO.File]::ReadAllLines("Engine/Source/Runtime/AnimationCore/Public/EulerTransform.h").Count`（同文件 `^};` 检索定类体区间） |
| `virtual` = 0；`ANIMATIONCORE_API` 仅 1 处 | `[M]` `Select-String "Engine/Source/Runtime/AnimationCore/Public/EulerTransform.h" -Pattern 'virtual' -AllMatches`（类体区间核对） |
| 派生统计：0 命中 | `[H]` `Select-String -Pattern '\bpublic\s+FEulerTransform\b'`（`*.h`） |
| 全部行号引用 | 2026-10-10 对 UE 5.8.3 源码本机逐条核对 |

## 相关文档

- `modules/AnimationCore-结构.md` —— FEulerTransform 所在模块（同批产出）
- `types/FAnimNode_BlendSpacePlayer.md` —— 同批类型
- `modules/MovieSceneTracks-结构.md` —— 跨模块消费方（批 9）
- `types/FGameplayTag.md` —— 另一"轻量值类型"参照（批 2）

## 更新记录

- 2026-10-11 修正 `FAxis` 结构体行数（47 → 48）

- 2026-10-11 搜索边界更正：派生搜索实覆盖 **294** 个模块（Runtime 291 + `EnhancedInput` 插件 3），原文误作"纳入范围的 292 个模块"（292 是白名单口径，搜索实际连 `InputBlueprintNodes` / `InputEditor` 一并覆盖，本文件命中的插件侧结果即来自 `InputEditor`）；同时在「取数说明」补入该边界取数方式（`convention.md` 4.2）

- 2026-10-11 「取数说明」补入 1 行计数断言取数方式（`convention.md` 4.2 覆盖要求）

- 2026-10-11 按规范 4.2.1 为「取数说明」各行加方法标记（`[M]`/`[R]`/`[H]`）；`[M]` 行把原文省略成 `(...)` 的路径补全为白名单可执行命令，现由 `ue-doc-verify` 逐条实际执行比对
