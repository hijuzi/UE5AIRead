> 引擎版本：UE 5.8.3 (Build 58210709)
> 源码根：Engine/Source
> 生成技能：ue-type-api v1.0
> 生成时间：2026-10-10
> 校验状态：已校验（2026-10-11）

# UMovieSceneSequence

## 一、类型概览

| 项 | 值 |
|---|---|
| 全限定名 | `UMovieSceneSequence`（全局命名空间） |
| 定义位置 | `Engine/Source/Runtime/MovieScene/Public/MovieSceneSequence.h` |
| 类型 | 类（反射类型；序列资产基类） |
| 反射宏 | `UCLASS(abstract, MinimalAPI, Config = Engine, BlueprintType)`（第 70 行）+ `GENERATED_BODY()`（第 78 行） |
| 导出策略 | `MinimalAPI` + 逐成员 `MOVIESCENE_API`（该文件 20 处）；类声明行不带宏（第 71 行） |
| 所属模块 | `MovieScene`（`Engine/Source/Runtime/MovieScene`） |

## 二、继承链

```
UObjectBase            （Engine/Source/Runtime/CoreUObject/Public/UObject/UObjectBase.h 第 66 行；链根）
  └─ UObjectBaseUtility（Engine/Source/Runtime/CoreUObject/Public/UObject/UObjectBaseUtility.h 第 44 行）
       └─ UObject      （Engine/Source/Runtime/CoreUObject/Public/UObject/Object.h 第 98 行）
            └─ UMovieSceneSignedObject（Engine/Source/Runtime/MovieScene/Public/MovieSceneSignedObject.h 第 71 行；`UCLASS(MinimalAPI)` 第 70 行）
                 └─ UMovieSceneSequence（Engine/Source/Runtime/MovieScene/Public/MovieSceneSequence.h 第 71 行）
```

> **重要**：`UMovieScene` **不是**本类的派生类——它继承 `UMovieSceneDecorationContainerObject`（`Decorations/MovieSceneDecorationContainer.h` 第 108-109 行），与本类是"兄弟"（同属 SignedObject 体系）。见第七节。

## 三、声明片段

```
文件：Engine/Source/Runtime/MovieScene/Public/MovieSceneSequence.h
行 70-73：UCLASS(..., MinimalAPI, ...) / class UMovieSceneSequence / : public UMovieSceneSignedObject / {

文件：Engine/Source/Runtime/MovieScene/Public/MovieSceneSequence.h
行 78：GENERATED_BODY()

文件：Engine/Source/Runtime/MovieScene/Public/MovieSceneSequence.h
行 468：类体结束（};；文件 468 行）
```

## 四、公开 API

| 签名 | 说明 | 位置（MovieSceneSequence.h） |
|---|---|---|
| `MakeLocatorForObject(...)` | 为对象生成定位器（UOL） | 第 92 行 |
| `GetBindingReferences()`（2 重载） | 绑定引用集合 | 第 97 / 102 行 |
| `BindPossessableObject(...)`（**纯虚**） | 绑定可拥有对象 | 第 119 行 |
| `CanPossessObject(...)`（**纯虚**） | 是否可拥有 | 第 128 行 |
| `LocateBoundObjects(...)`（现行 4 参数版；另有 3 个 5.4/5.5 废弃重载） | 定位已绑定对象 | 第 178 行（旧版 138 / 149 / 160 行） |
| `FindPossessableObjectId(...)` / `FindBindingFromObject(...)` | 反查绑定 GUID | 第 187 / 190 行 |
| `GetMovieScene()`（**纯虚**） | 取序列数据容器（`UMovieScene*`） | 第 217 行 |
| `GetParentObject(...)`（**纯虚**） | 父对象 | 第 225 行 |
| `AllowsSpawnableObjects()` / `AllowsCustomBindings()` | 能力开关 | 第 232 / 239 行 |
| `UnbindPossessableObjects(...)` / `UnbindObjects(...)` / `UnbindInvalidObjects(...)`（**纯虚**） | 解绑 | 第 247 / 256 / 264 行 |
| `MakeSpawnableTemplateFromInstance(...)` / `CanRebindPossessable(...)` / `CanAnimateObject(...)` | 派生品/重绑/动画能力 | 第 273 / 281 / 289 行 |
| `CreatePossessable(...)` / `CreateSpawnable(...)` | 创建绑定项 | 第 294 / 299 行 |
| `CreateDirectorInstance(...)` | Director 实例 | 第 304 行 |
| `OverrideNetworkMask(...)` | 网络掩码 | 第 309 行 |
| `FindBindingByTag(...)` / `FindBindingsByTag(...)`（`UFUNCTION(BlueprintCallable)`） | 按标签查绑定 | 第 315 / 321 行 |
| `GetEarliestTimecodeSource()`（`UFUNCTION`） | 最早时间码源 | 第 327 行 |
| `GetDisplayName()`（虚；编辑器） | 显示名 | 第 434 行 |
| `IsTrackSupported(...)` / `IsFilterSupported(...)` | 支持性检查 | 第 439 / 447 行 |
| 数据成员 | `CompiledData`（Instanced，第 398-399 行）、`DefaultCompletionMode`（config，第 404-405 行）、`bParentContextsAreSignificant` / `bPlayableDirectly` / `SequenceFlags`（第 414-425 行） | 见左 |

> **不存在于本类**（实测 0 命中）：`GetPlaybackRange`（在 `UMovieScene`，`MovieScene.h` 第 803 行）、`GetMovieSceneLength`、`MakeRange`、`IsLocked`（在 `UMovieSceneSection`，第 603 行）。

## 五、扩展点

### 5.1 可覆写虚函数

> 类内 `virtual` 全匹配 **35 条**（含 **7 条纯虚**：第 119、128、217、225、247、256、264 行）。分组：

| 组 | 代表（行号） |
|---|---|
| 绑定 / 解绑 / 定位（主要覆写面） | `MakeLocatorForObject`(92)、`BindPossessableObject`(119 纯虚)、`CanPossessObject`(128 纯虚)、`LocateBoundObjects`(178)、`FindBindingFromObject`(190)、`GatherExpiredObjects`(207) |
| 场景与父级 | `GetMovieScene`(217 纯虚)、`GetParentObject`(225 纯虚)、`AllowsSpawnableObjects`(232)、`AllowsCustomBindings`(239) |
| possessable / spawnable 生命周期 | `UnbindPossessableObjects`(247 纯虚)、`UnbindObjects`(256 纯虚)、`UnbindInvalidObjects`(264 纯虚)、`MakeSpawnableTemplateFromInstance`(273)、`CanRebindPossessable`(281)、`CanAnimateObject`(289)、`CreatePossessable`(294)、`CreateSpawnable`(299) |
| director / 网络 | `CreateDirectorInstance`(304)、`OverrideNetworkMask`(309) |
| UObject 覆写 | `PostLoad`(337)、`PreSave`(338)、`BeginDestroy`(339)、`PostDuplicate`(340)、`Serialize`(342) |
| 编辑器期 | `IterateDynamicBindings`(330)、`GetCustomBrushForBinding`(332)、`GetDisplayName`(434)、`IsTrackSupportedImpl`(442)、`IsFilterSupportedImpl`(450) |
| 子序列兼容 | `IsCompatibleSubSequence`(462)、`IsCompatibleAsSubSequence`(467) |

### 5.2 不建议覆写的内部虚函数

无——7 条纯虚是接口契约（实现者必须给出），其余为常规覆写面。

## 六、生命周期

- 资产型对象（`config = Engine`）：无 `Tick` / `BeginPlay`；编译数据经 `GetOrCreateCompiledData()`（第 389 行）懒构建。
- 播放由 `UMovieSceneSequencePlayer`（`MovieSceneSequencePlayer.h` 第 176 行，`: UObject, IMovieScenePlayer, IMovieSceneSequenceTickManagerClient`）驱动。
- 播放时序与求值链路属 `flows/` 范畴（暂无 Sequencer 流程产物）。

## 七、派生类（范围内）

搜索边界：派生类搜索**覆盖 Runtime 291 个模块 + `EnhancedInput` 插件全部 3 个模块（共 294 个模块）**。搜索模式 `\bpublic\s+UMovieSceneSequence\b`（`*.h`）：Runtime **4 命中 / 4 文件**；EnhancedInput **0**。

| 派生类 | 位置 | 备注 |
|---|---|---|
| `ULevelSequence` | `Engine/Source/Runtime/LevelSequence/Public/LevelSequence.h` 第 23-24 行 | 主代表（`: public UMovieSceneSequence, public IInterface_AssetUserData`） |
| `UWidgetAnimation` | `Engine/Source/Runtime/UMG/Public/Animation/WidgetAnimation.h` 第 25 行 | UMG 控件动画（批 3 已出模块文档） |
| `UMovieSceneTestSequence` | `Engine/Source/Runtime/MovieSceneTracks/Public/Tests/MovieSceneTestDataBuilders.h` 第 28 行 | 测试类 |
| `UTestMovieSceneSequence` | `Engine/Source/Runtime/MovieScene/Private/Tests/MovieSceneTestObjects.h` 第 64 行 | 测试类（Private） |

> 范围外（Plugins，仅记录）：`UTemplateSequence`、`UActorSequence`、`UNiagaraSequence`、`UMetaHumanSceneSequence` 等 8 个。
> **另一个易错点**：`UMovieScene` 不是派生类（见第二节）；`UMovieSceneTrack` / `UMovieSceneSection` 也都不是（它们继承 `UMovieSceneDecorationContainerObject`）。

## 取数说明

| 断言 | 取数方式（相对基准：`Engine/Source`） |
|---|---|
| 搜索边界 294 个模块（Runtime 291 + `EnhancedInput` 插件 3） | `[M]` 插件 3 个模块（含白名单外的 `InputBlueprintNodes` / `InputEditor`）：`(Get-ChildItem "Engine/Plugins/EnhancedInput/Source" -Directory).Count` → 3；Runtime 291 见 `_meta/inventory.md` |
| 文件 468 行、类体 70-468 | `[M]` `[System.IO.File]::ReadAllLines("Engine/Source/Runtime/MovieScene/Public/MovieSceneSequence.h").Count`（同文件 `^};` 检索定类体区间） |
| 类内 `virtual` 35 条（纯虚 7） | `[H]` `Select-String -Pattern 'virtual'` 全匹配 + `PURE_VIRTUAL\(UMovieSceneSequence::` 计数 |
| 派生统计：Runtime 4 / EnhancedInput 0 | `[H]` `Select-String -Pattern '\bpublic\s+UMovieSceneSequence\b'`（`*.h`） |
| 全部行号引用 | 2026-10-10 对 UE 5.8.3 源码本机逐条核对 |

## 相关文档

- `modules/MovieScene-结构.md` —— UMovieSceneSequence 所在模块（同批产出）
- `types/UGameplayTask.md` —— 同批类型
- `modules/UMG-结构.md` —— 派生类 `UWidgetAnimation` 的宿主
- `types/UObject.md` —— 基类链终点（已校验）

## 更新记录

- 2026-10-11 搜索边界更正：派生搜索实覆盖 **294** 个模块（Runtime 291 + `EnhancedInput` 插件 3），原文误作"纳入范围的 292 个模块"（292 是白名单口径，搜索实际连 `InputBlueprintNodes` / `InputEditor` 一并覆盖，本文件命中的插件侧结果即来自 `InputEditor`）；同时在「取数说明」补入该边界取数方式（`convention.md` 4.2）

- 2026-10-11 按规范 4.2.1 为「取数说明」各行加方法标记（`[M]`/`[R]`/`[H]`）；`[M]` 行把原文省略成 `(...)` 的路径补全为白名单可执行命令，现由 `ue-doc-verify` 逐条实际执行比对
