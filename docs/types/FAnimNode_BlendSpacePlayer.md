> 引擎版本：UE 5.8.3 (Build 58210709)
> 源码根：Engine/Source
> 生成技能：ue-type-api v1.0
> 生成时间：2026-10-10
> 校验状态：已校验（2026-10-10）

# FAnimNode_BlendSpacePlayer

## 一、类型概览

| 项 | 值 |
|---|---|
| 全限定名 | `FAnimNode_BlendSpacePlayer`（全局命名空间） |
| 定义位置 | `Engine/Source/Runtime/AnimGraphRuntime/Public/AnimNodes/AnimNode_BlendSpacePlayer.h` |
| 类型 | 结构体（反射类型；动画图"混合空间播放"节点） |
| 反射宏 | `USTRUCT(BlueprintInternalUseOnly)`（第 116 行）+ `GENERATED_BODY()`（第 119 行） |
| 导出策略 | 类级无宏；成员级 `ANIMGRAPHRUNTIME_API`（第 186-196、200-209 行逐函数） |
| 所属模块 | `AnimGraphRuntime`（`Engine/Source/Runtime/AnimGraphRuntime`） |

## 二、继承链

```
FAnimNode_Base（Engine/Source/Runtime/Engine/Classes/Animation/AnimNodeBase.h 第 720 行；USTRUCT 第 719 行；链根）
  └─ FAnimNode_AssetPlayerRelevancyBase（Engine/Source/Runtime/Engine/Classes/Animation/AnimNode_RelevantAssetPlayerBase.h 第 13 行）
       └─ FAnimNode_AssetPlayerBase（Engine/Source/Runtime/Engine/Classes/Animation/AnimNode_AssetPlayerBase.h 第 14 行）
            └─ FAnimNode_BlendSpacePlayerBase（AnimNode_BlendSpacePlayer.h 第 15 行）
                 └─ FAnimNode_BlendSpacePlayer（本文件第 117 行，`: public FAnimNode_BlendSpacePlayerBase`）
```

> **注意**：整条基类链中除 `...Base`（第 15 行，本文件内）外**全部在 Engine 模块**——AnimGraphRuntime 只提供叶子节点。

## 三、声明片段

```
文件：Engine/Source/Runtime/AnimGraphRuntime/Public/AnimNodes/AnimNode_BlendSpacePlayer.h （302 行）
行 116-119：USTRUCT(BlueprintInternalUseOnly) / struct FAnimNode_BlendSpacePlayer : public FAnimNode_BlendSpacePlayerBase / { / GENERATED_BODY()
行 211：类体结束（};）
同文件另外两个类型：FAnimNode_BlendSpacePlayerBase（第 13-112 行）；FAnimNode_BlendSpacePlayer_Standalone（第 213-302 行）
```

## 四、公开 API

> 类内 public 段共 **21 条**（全部为 `override`），分两族：

**同步组（11 条）**

| 成员 | 位置 |
|---|---|
| `GetGroupName` / `SetGroupName` | 第 186 / 192 行 |
| `GetGroupRole` / `SetGroupRole` | 第 187 / 193 行 |
| `GetOverridePositionWhenJoiningSyncGroupAsLeader` / `SetOverridePositionWhenJoiningSyncGroupAsLeader` | 第 188 / 194 行 |
| `GetGroupMethod` / `SetGroupMethod` | 第 189 / 195 行 |
| `GetIgnoreForRelevancyTest` / `SetIgnoreForRelevancyTest` | 第 190 / 196 行 |
| `IsLooping` | 第 191 行 |

**数据组（10 条）**

| 成员 | 位置 |
|---|---|
| `GetBlendSpace` / `SetBlendSpace(UBlendSpace*)` | 第 200 / 206 行 |
| `GetPosition` / `SetPosition(FVector)` | 第 201 / 207 行 |
| `GetStartPosition` | 第 202 行 |
| `GetPlayRate` / `SetPlayRate(float)` | 第 203 / 208 行 |
| `ShouldResetPlayTimeWhenBlendSpaceChanges` / `SetResetPlayTimeWhenBlendSpaceChanges` | 第 204 / 205 行 |
| `SetLoop(bool)` | 第 209 行 |

> 数据成员：`BlendSpace`（`TObjectPtr<UBlendSpace>`，第 181 行）。

## 五、扩展点

### 5.1 可覆写虚函数（类内 21 条，全列）

| 组 | 成员（行号） |
|---|---|
| 同步组（`FAnimNode_AssetPlayerBase` 契约） | `GetGroupName`(186)、`GetGroupRole`(187)、`GetOverridePositionWhenJoiningSyncGroupAsLeader`(188)、`GetGroupMethod`(189)、`GetIgnoreForRelevancyTest`(190)、`IsLooping`(191)、`SetGroupName`(192)、`SetGroupRole`(193)、`SetOverridePositionWhenJoiningSyncGroupAsLeader`(194)、`SetGroupMethod`(195)、`SetIgnoreForRelevancyTest`(196) |
| 数据组（混合空间播放契约） | `GetBlendSpace`(200)、`GetPosition`(201)、`GetStartPosition`(202)、`GetPlayRate`(203)、`ShouldResetPlayTimeWhenBlendSpaceChanges`(204)、`SetResetPlayTimeWhenBlendSpaceChanges`(205)、`SetBlendSpace`(206)、`SetPosition`(207)、`SetPlayRate`(208)、`SetLoop`(209) |

### 5.2 不建议覆写的内部虚函数

无——21 条均为基类契约的标准化实现（节点以数据成员 + Get/Set 对暴露配置）。

## 六、生命周期

- **动画图求值**：作为"资产播放器"节点（`FAnimNode_AssetPlayerBase` 家族）参与每帧图求值；配置经 Get/Set 对读写（蓝图侧有 `BlendSpacePlayerLibrary` 库函数操作）。
- **对照事实**：同族的 `FAnimNode_SequencePlayer` 定义在 **Engine**（`Engine/Source/Runtime/Engine/Classes/Animation/AnimNode_SequencePlayer.h` 第 81 行）——动画节点实现分散在 Engine 与 AnimGraphRuntime 两模块，按名找节点需先确认模块归属。

## 七、派生类（范围内）

搜索边界：派生类搜索**仅覆盖本版纳入范围的 292 个模块**（Runtime 291 个 + `EnhancedInput` 插件）。搜索模式 `\bpublic\s+FAnimNode_BlendSpacePlayer\b`（`*.h`）：Runtime **3 命中 / 3 文件**；EnhancedInput **0**。

| 派生类 | 位置 |
|---|---|
| `FAnimNode_RotationOffsetBlendSpace` | `Engine/Source/Runtime/AnimGraphRuntime/Public/AnimNodes/AnimNode_RotationOffsetBlendSpace.h` 第 14 行 |
| `FAnimNode_BlendSpaceEvaluator` | `Engine/Source/Runtime/AnimGraphRuntime/Public/AnimNodes/AnimNode_BlendSpaceEvaluator.h` 第 16 行 |
| `FAnimNode_AimOffsetLookAt` | `Engine/Source/Runtime/AnimGraphRuntime/Public/AnimNodes/AnimNode_AimOffsetLookAt.h` 第 16 行 |

> 配套定位：`FAnimNode_BlendSpacePlayerBase`（本文件第 15 行，63 行）；`FAnimNode_BlendSpacePlayer_Standalone`（本文件第 213 行）；`FAnimNode_Base`（`Engine/Source/Runtime/Engine/Classes/Animation/AnimNodeBase.h` 第 720 行）。

## 取数说明

| 断言 | 取数方式（相对基准：`Engine/Source`） |
|---|---|
| 文件 302 行、类体 116-211 | `[System.IO.File]::ReadAllLines(...).Count` + `^};` 检索 |
| 类内 `virtual` 21 条 | `Select-String -Pattern '\bvirtual\b'` 逐行核对（全文件 63 行，含 Base/Standalone 段） |
| 派生统计：Runtime 3 / EnhancedInput 0 | `Select-String -Pattern '\bpublic\s+FAnimNode_BlendSpacePlayer\b'`（`*.h`） |
| 全部行号引用 | 2026-10-10 对 UE 5.8.3 源码本机逐条核对 |

## 相关文档

- `modules/AnimGraphRuntime-结构.md` —— FAnimNode_BlendSpacePlayer 所在模块（同批产出）
- `types/FEulerTransform.md` —— 同批类型
- `modules/Engine-结构.md` —— `FAnimNode_Base` / `FAnimNode_SequencePlayer` 归属
- `types/SWidget.md` —— 另一"节点/组件式体系"参照（批 3）
