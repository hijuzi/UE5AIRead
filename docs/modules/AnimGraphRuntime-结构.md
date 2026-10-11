> 引擎版本：UE 5.8.3 (Build 58210709)
> 源码根：Engine/Source
> 生成技能：ue-module-structure v1.0
> 生成时间：2026-10-10
> 校验状态：已校验（2026-10-11）

# AnimGraphRuntime 模块结构

## 一、模块定位

| 项 | 值 |
|---|---|
| 路径 | `Engine/Source/Runtime/AnimGraphRuntime` |
| 类别 | Runtime |
| 规模 | 175 文件 / 90 头文件（`_meta/engine-modules.json` 2026-10-10 口径；公开侧 90：顶层 25 + 4 个子目录） |
| 分层 | 动画 |
| 一句话职责 | 动画图**运行时节点库**：混合空间/分层混合/骨骼控制（TwoBoneIK、AnimDynamics 等）节点、蓝图库族（`KismetAnimationLibrary` 等）、RBF 插值、动画图与 Sequencer 的桥接 |

## 二、目录结构

```
AnimGraphRuntime/
├── AnimGraphRuntime.Build.cs   # 模块构建脚本（38 行、0 处 if 分支）
├── Public/                     # 90 个 .h
│   ├── 顶层 25 个：KismetAnimationLibrary.h / AnimationStateMachineLibrary.h / BlendSpacePlayerLibrary.h /
│   │   SequencePlayerLibrary.h / SequenceEvaluatorLibrary.h / SkeletalControlLibrary.h / AnimSequencerInstance.h /
│   │   PlayMontageCallbackProxy.h / MirrorAnimLibrary.h / AnimationCustomVersion.h 等
│   └── 子目录（4）：AnimNodes/ BoneControllers/ AnimNotifies/ RBF/
└── Private/                    # 23 个 .cpp + 3 个子目录（AnimNodes/ BoneControllers/ RBF/）
```

- 无 `Internal/`、无 `Tests/`；无聚合头。

## 三、依赖关系

### 3.1 无条件依赖

| 模块 | 类型 | Build.cs 行 | 说明 |
|---|---|---|---|
| `Core` | 公开依赖 | 12 | |
| `CoreUObject` | 公开依赖 | 13 | |
| `Engine` | 公开依赖 | 14 | |
| `AnimationCore` | 公开依赖 | 15 | 同批模块 |
| `GeometryCollectionEngine` | 公开依赖（**第 2 次 AddRange**） | 34 | `PublicDependencyModuleNames` 共出现 2 次（第 10、32 行） |
| `TraceLog` | 私有依赖 | 21 | |

> 辅助函数检查：**`SetupModulePhysicsSupport(Target)`（第 25 行，已展开）**——UBT `ModuleRules.cs` 第 1793 行起定义，追加物理相关包含路径与定义。

### 3.2 平台与配置条件依赖

**无**——全文 **0 处 `if` 分支**（实测）。

### 3.3 第三方静态依赖

| 库 | 条件 | Build.cs 行 |
|---|---|---|
| `Eigen` | 无条件（第 27 行注释：外部用户无需感知） | 28-30 |

## 四、对外暴露面

> 公开侧共 90 个 `.h`；核心如下。

| 头文件 | 提供的能力 |
|---|---|
| `Engine/Source/Runtime/AnimGraphRuntime/Public/AnimNodes/AnimNode_BlendSpacePlayer.h` | `FAnimNode_BlendSpacePlayer`（第 117 行）→ `types/FAnimNode_BlendSpacePlayer.md` |
| `Engine/Source/Runtime/AnimGraphRuntime/Public/AnimNodes/AnimNode_LayeredBoneBlend.h` | `FAnimNode_LayeredBoneBlend`（第 21 行，`: FAnimNode_Base`） |
| `Engine/Source/Runtime/AnimGraphRuntime/Public/BoneControllers/AnimNode_TwoBoneIK.h` | `FAnimNode_TwoBoneIK`（第 20 行，`: FAnimNode_SkeletalControlBase`） |
| `Engine/Source/Runtime/AnimGraphRuntime/Public/BoneControllers/AnimNode_AnimDynamics.h` 等 | 骨骼控制节点族 |
| `Engine/Source/Runtime/AnimGraphRuntime/Public/KismetAnimationLibrary.h`、`AnimationStateMachineLibrary.h`、`BlendSpacePlayerLibrary.h`、`SequencePlayerLibrary.h`、`SequenceEvaluatorLibrary.h`、`SkeletalControlLibrary.h` | 蓝图库族 |
| `Engine/Source/Runtime/AnimGraphRuntime/Public/AnimSequencerInstance.h`、`SequencerAnimationOverride.h` | 动画图 ↔ Sequencer 桥接 |
| `Engine/Source/Runtime/AnimGraphRuntime/Public/RBF/`（子目录） | RBF 插值 |

> **归属修正（三个常见误判）**：
> - `FAnimNode_SequencePlayer` 在 **Engine**（`Engine/Source/Runtime/Engine/Classes/Animation/AnimNode_SequencePlayer.h` 第 81 行）——本模块仅有前置声明（`SequencePlayerLibrary.h` 第 12 行）；
> - `FAnimNode_Base` 在 **Engine**（`Engine/Source/Runtime/Engine/Classes/Animation/AnimNodeBase.h` 第 720 行）；
> - `FAnimInstanceProxy` 在 **Engine**（`Engine/Source/Runtime/Engine/Public/Animation/AnimInstanceProxy.h` 第 143 行）；
> - `AnimNode_Root.h` 也不在本模块（在 Engine）。

## 五、模块生命周期

```
文件：Engine/Source/Runtime/AnimGraphRuntime/Private/AnimGraphRuntimeModule.cpp
行 16：class FAnimGraphRuntimeModule : public IModuleInterface
行 101：IMPLEMENT_MODULE(FAnimGraphRuntimeModule, AnimGraphRuntime);
```

- **`StartupModule()`（第 19-21 行）与 `ShutdownModule()`（第 23-25 行）均为空实现**（启动期不注册）。
- 附带注册动作走**静态初始化**：`static FAutoConsoleCommand AuditLoadedAnimGraphs(...)`（第 28 行起）——控制台命令 `a.AuditLoadedAnimGraphs` 统计已加载动画图的节点内存。
- `SupportsDynamicReloading`：未覆写（0 命中）。

## 六、关键约定与坑

1. **`Public/AnimNodes/AnimNode_SequencePlayer.h` 不存在**（在 Engine）；**`AnimNode_TwoBoneIK.h` 在 `BoneControllers/`**（不在 `AnimNodes/`）；`AnimNode_Root.h` 在 Engine。
2. **`SetupModulePhysicsSupport` 会追加物理包含路径/宏**（第 25 行）——引用依赖时勿漏展开（另含 Eigen 三方静态依赖）。
3. **空 Startup/Shutdown**：注册动作走静态初始化（控制台命令）——排查"模块加载时发生了什么"时不要只看 StartupModule。
4. **数字口径**：`AnimGraphRuntime.Build.cs` 38 行（`ReadAllLines`）、0 处 `if`、1 个三方静态库（Eigen）；公开侧 90 个 `.h`（顶层 25）。取数命令见「取数说明」。

## 取数说明

以下命令的相对基准为 `Engine/Source`（实际路径按 `_meta/convention.md` 的本机环境块解析）：

| 断言 | 取数方式 |
|---|---|
| 175 文件 / 90 头文件 | `[M]` 引擎磁盘递归计数：`(Get-ChildItem "Runtime/AnimGraphRuntime" -Recurse -File).Count` 得文件数；`(Get-ChildItem "Runtime/AnimGraphRuntime" -Recurse -File -Filter *.h).Count` 得头文件数（同 `_meta/engine-modules.json` 口径） |
| 公开侧 90 个 `.h`（顶层 25） | `[M]` `(Get-ChildItem "Runtime/AnimGraphRuntime/Public" -Recurse -File -Filter *.h).Count` 与顶层计数 |
| Build.cs 38 行、0 处 `if`、1 库三方静态调用 | `[M]` `[System.IO.File]::ReadAllLines("Runtime/AnimGraphRuntime/AnimGraphRuntime.Build.cs").Count`；`Select-String "Runtime/AnimGraphRuntime/AnimGraphRuntime.Build.cs" -Pattern '\bif\s*\(' -AllMatches`；`Select-String "Runtime/AnimGraphRuntime/AnimGraphRuntime.Build.cs" -Pattern 'AddEngineThirdPartyPrivateStaticDependencies' -AllMatches` |
| 全部行号引用 | 2026-10-10 对 UE 5.8.3 源码本机逐条核对 |

## 相关文档

- `types/FAnimNode_BlendSpacePlayer.md` —— 本模块代表类型（同批产出）
- `modules/AnimationCore-结构.md` —— 同批模块（基础类型层）
- `modules/Engine-结构.md` —— `FAnimNode_Base` / `FAnimInstanceProxy` / `FAnimNode_SequencePlayer` 归属
- `modules/MovieSceneTracks-结构.md` —— 动画轨道消费方（批 9）

## 更新记录

- 2026-10-11 按规范 4.2.1 为「取数说明」各行加方法标记（`[M]`/`[R]`/`[H]`）；`[M]` 行把原文省略成 `(...)` 的路径补全为白名单可执行命令，现由 `ue-doc-verify` 逐条实际执行比对
