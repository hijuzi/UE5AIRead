> 引擎版本：UE 5.8.3 (Build 58210709)
> 源码根：Engine/Source
> 生成技能：ue-module-structure v1.0
> 生成时间：2026-10-10
> 校验状态：已校验（2026-10-11）

# AnimationCore 模块结构

## 一、模块定位

| 项 | 值 |
|---|---|
| 路径 | `Engine/Source/Runtime/AnimationCore` |
| 类别 | Runtime |
| 规模 | 33 文件 / 18 头文件（`_meta/engine-modules.json` 2026-10-10 口径；公开侧 17 + `Private/` 1） |
| 分层 | 动画 |
| 一句话职责 | 动画**基础类型与算法层**：欧拉变换/轴/约束描述（`Constraint.h`）、骨骼索引与权重（`BoneIndices.h` / `BoneWeights.h`）、IK 算法入口声明（TwoBoneIK / CCDIK / FABRIK / SplineIK / SoftIK）、节点层级（`NodeHierarchy.h`）与数据源注册表 |

## 二、目录结构

```
AnimationCore/
├── AnimationCore.Build.cs   # 模块构建脚本（23 行、0 处 if 分支）
├── Public/                  # 公开侧 17 个 .h（无子目录，单层）
│   ├── EulerTransform.h / CommonAnimTypes.h / Constraint.h（19.22 KB）/ NodeHierarchy.h / NodeChain.h /
│   │   BoneIndices.h / BoneWeights.h（43.86 KB）/ AngularLimit.h / TransformNoScale.h
│   ├── TwoBoneIK.h / CCDIK.h / FABRIK.h / SplineIK.h / SoftIK.h（IK 算法入口）
│   └── AnimationCoreLibrary.h / AnimationDataSource.h / AnimationCore.h
└── Private/                 # 14 个文件（含 AnimationCoreUtil.h 与各算法 .cpp）+ Tests/（BoneWeightsTests.cpp）
```

- 无 `Internal/`；`Tests/` 位于 `Private/Tests/`。

## 三、依赖关系

### 3.1 无条件依赖

| 模块 | 类型 | Build.cs 行 | 说明 |
|---|---|---|---|
| `Core` | 公开依赖 | 18 | |
| `CoreUObject` | 公开依赖 | 19 | |
| `Engine` | 私有包含路径 | 12 | **仅包含路径** |

> 辅助函数检查：**无**——无未展开依赖。

### 3.2 平台与配置条件依赖

**无**——全文 **0 处 `if` 分支**（实测）。

### 3.3 第三方静态依赖

调用 **0 处**——无第三方静态依赖。

## 四、对外暴露面

> 公开侧共 17 个 `.h`；核心如下。

| 头文件 | 提供的能力 |
|---|---|
| `Engine/Source/Runtime/AnimationCore/Public/EulerTransform.h` | `FEulerTransform`（第 31 行）→ `types/FEulerTransform.md`；`EEulerRotationOrder` 枚举（第 20 行） |
| `Engine/Source/Runtime/AnimationCore/Public/CommonAnimTypes.h` | `FAxis`（第 13 行） |
| `Engine/Source/Runtime/AnimationCore/Public/Constraint.h` | 约束描述体系：`FTransformConstraint`（第 285 行）、`FConstraintDescription`（第 182 行）、`FConstraintDescriptor`（第 509 行）、`FTransformConstraintDescription`（第 419 行）、`FAimConstraintDescription`（第 464 行） |
| `Engine/Source/Runtime/AnimationCore/Public/BoneIndices.h` | `FBoneIndexBase`（第 13 行）/ `FCompactPoseBoneIndex`（第 66 行）/ `FMeshPoseBoneIndex`（第 76 行）/ `FSkeletonPoseBoneIndex`（第 86 行） |
| `Engine/Source/Runtime/AnimationCore/Public/BoneWeights.h` | `TBoneWeights`（第 389 行）/ `FBoneWeights`（第 524 行）体系 |
| `Engine/Source/Runtime/AnimationCore/Public/NodeHierarchy.h` | `FNodeHierarchyData`（第 38 行）/ `FNodeHierarchyWithUserData`（第 198 行） |
| `Engine/Source/Runtime/AnimationCore/Public/AnimationDataSource.h` | `UAnimationDataSourceRegistry`（第 20 行） |
| `Engine/Source/Runtime/AnimationCore/Public/TwoBoneIK.h`、`CCDIK.h`、`FABRIK.h`、`SplineIK.h`、`SoftIK.h` | IK 算法入口声明（纯函数层） |

> **`SkeletonPose.h` 不存在**（实测 False）；**`FBoneIndices` 不作为公开类型存在**（Engine 内 `PoseAsset.cpp` 有同名局部工具结构，非公开类型）。

## 五、模块生命周期

```
文件：Engine/Source/Runtime/AnimationCore/Private/AnimationCore.cpp
行 10：IMPLEMENT_MODULE(FDefaultModuleImpl, AnimationCore);
行 12：DEFINE_LOG_CATEGORY(LogAnimationCore);
```

- **无自定义模块类**——直接复用 `FDefaultModuleImpl`（**本套件第 2 例**，继 `Navmesh` 之后）；`StartupModule` / `ShutdownModule` / `SupportsDynamicReloading` 全 **0 覆写**。
- 日志分类：`AnimationCore.h` 第 12 行声明，`AnimationCore.cpp` 第 12 行定义。

## 六、关键约定与坑

1. **`FDefaultModuleImpl` 第 2 例**（Navmesh 之后）；无任何生命周期代码。
2. **文件名不可猜**：`SkeletonPose.h` 不存在；`FBoneIndices` 不是公开类型（见第四节注）。
3. **IK 算法头是"声明入口"**：`TwoBoneIK.h` 等只有函数声明，实现在 `Private/`（如 `TwoBoneIK.cpp` 8.42 KB）。
4. **数字口径**：`AnimationCore.Build.cs` 23 行（`ReadAllLines`）、0 处 `if`、0 处三方静态调用；公开侧 17 个 `.h`（模块合计 18）。取数命令见「取数说明」。

## 取数说明

以下命令的相对基准为 `Engine/Source`（实际路径按 `_meta/convention.md` 的本机环境块解析）：

| 断言 | 取数方式 |
|---|---|
| 33 文件 / 18 头文件 | `[M]` 引擎磁盘递归计数：`(Get-ChildItem "Runtime/AnimationCore" -Recurse -File).Count` 得文件数；`(Get-ChildItem "Runtime/AnimationCore" -Recurse -File -Filter *.h).Count` 得头文件数（同 `_meta/engine-modules.json` 口径） |
| 公开侧 17 个 `.h` | `[M]` `(Get-ChildItem "Runtime/AnimationCore/Public" -Recurse -File -Filter *.h).Count` |
| Build.cs 23 行、0 处 `if`、0 处三方静态调用 | `[M]` `[System.IO.File]::ReadAllLines("Runtime/AnimationCore/AnimationCore.Build.cs").Count`；`Select-String "Runtime/AnimationCore/AnimationCore.Build.cs" -Pattern '\bif\s*\(' -AllMatches`；`Select-String "Runtime/AnimationCore/AnimationCore.Build.cs" -Pattern 'AddEngineThirdPartyPrivateStaticDependencies' -AllMatches` |
| 全部行号引用 | 2026-10-10 对 UE 5.8.3 源码本机逐条核对 |

## 相关文档

- `types/FEulerTransform.md` —— 本模块代表类型（同批产出）
- `modules/AnimGraphRuntime-结构.md` —— 同批模块（下游节点库）
- `modules/MovieSceneTracks-结构.md` —— `FEulerTransform` 的跨模块消费方（批 9）
- `modules/Navmesh-结构.md` —— 另一 `FDefaultModuleImpl` 先例（批 11）

## 更新记录

- 2026-10-11 按规范 4.2.1 为「取数说明」各行加方法标记（`[M]`/`[R]`/`[H]`）；`[M]` 行把原文省略成 `(...)` 的路径补全为白名单可执行命令，现由 `ue-doc-verify` 逐条实际执行比对
