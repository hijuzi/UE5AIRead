> 引擎版本：UE 5.8.3 (Build 58210709)
> 源码根：Engine/Source
> 生成技能：ue-type-api v1.0
> 生成时间：2026-10-10
> 校验状态：已校验（2026-10-10）

# ULevelSequence

## 一、类型概览

| 项 | 值 |
|---|---|
| 全限定名 | `ULevelSequence`（全局命名空间） |
| 定义位置 | `Engine/Source/Runtime/LevelSequence/Public/LevelSequence.h` |
| 类型 | 类（反射类型；关卡序列资产——`UMovieSceneSequence` 的主实现） |
| 反射宏 | `UCLASS(BlueprintType, MinimalAPI)`（第 22 行）+ **`GENERATED_UCLASS_BODY()`**（第 26 行） |
| 导出策略 | `MinimalAPI` + 逐成员 `LEVELSEQUENCE_API`（35 条 virtual 均带该宏） |
| 所属模块 | `LevelSequence`（`Engine/Source/Runtime/LevelSequence`） |

## 二、继承链

```
UObjectBase            （Engine/Source/Runtime/CoreUObject/Public/UObject/UObjectBase.h 第 66 行；链根）
  └─ UObjectBaseUtility（Engine/Source/Runtime/CoreUObject/Public/UObject/UObjectBaseUtility.h 第 44 行）
       └─ UObject      （Engine/Source/Runtime/CoreUObject/Public/UObject/Object.h 第 98 行）
            └─ UMovieSceneSignedObject（Engine/Source/Runtime/MovieScene/Public/MovieSceneSignedObject.h 第 71 行）
                 └─ UMovieSceneSequence（Engine/Source/Runtime/MovieScene/Public/MovieSceneSequence.h 第 71 行）
                      └─ ULevelSequence（LevelSequence.h 第 23 行；`: public UMovieSceneSequence, public IInterface_AssetUserData`）
```

## 三、声明片段

```
文件：Engine/Source/Runtime/LevelSequence/Public/LevelSequence.h
行 22-26：UCLASS(BlueprintType, MinimalAPI) / class ULevelSequence
          / : public UMovieSceneSequence, public IInterface_AssetUserData / { / GENERATED_UCLASS_BODY()

文件：Engine/Source/Runtime/LevelSequence/Public/LevelSequence.h
行 316：类体结束（};；文件 316 行）
```

## 四、公开 API

| 签名 | 说明 | 位置 |
|---|---|---|
| `Initialize()`（虚） | 初始化 | 第 37 行 |
| `BindPossessableObject(...)`（虚，覆写基类纯虚） | 绑定可拥有对象 | 第 42 行 |
| `CanPossessObject(...)`（虚，覆写纯虚） | 是否可拥有 | 第 43 行 |
| `FindBindingFromObject(...)`（虚，现行版） | 由对象反查绑定 | 第 47 行（旧版第 46 行已废弃） |
| `GetMovieScene() const`（虚，覆写纯虚） | 取数据容器 | 第 50 行 |
| `MakeSpawnableTemplateFromInstance(...)`（虚） | 派生 spawnable 模板 | 第 58 行 |
| `CreateDirectorInstance(...)`（虚） | 创建 Director | 第 60 行 |
| `GetBindingReferences() const`（虚） | 绑定引用集合 | 第 61 行 |
| `GetAssetRegistryTags(...) const`（虚；编辑器） | 资产注册表标签 | 第 83 行 |
| `PostDuplicate(bool)`（虚） | 复制后处理（修绑） | 第 99 行 |
| `SetDirectorBlueprint(UBlueprint*)` / `GetDirectorBlueprint() const` | Director 蓝图 | 第 115 / 120 行 |
| `FindMetaDataByClass(...) const`（`UFUNCTION`，inline） | 按类查 MetaData | 第 179 行 |
| `FindOrAddMetaDataByClass(...)`（`UFUNCTION`，inline） | 查或加 MetaData | 第 195 行 |
| `CopyMetaData(UObject*)`（`UFUNCTION`，inline） | 复制 MetaData | 第 217 行 |
| `RemoveMetaDataByClass(...)`（`UFUNCTION`，inline） | 移除 MetaData | 第 241 行 |
| `PostDuplicateEvent`（static 委托） | 复制事件 | 第 91 行 |
| 数据成员 | `MovieScene`（第 32 行）、`BindingReferences`（第 151 行）、`MetaDataObjects`（第 308 行）、`AssetUserData`（第 315 行） | 见左 |

> 模板版 `FindMetaData<T>` / `FindOrAddMetaData<T>` / `CopyMetaData<T>` / `RemoveMetaData<T>`（第 256 / 268 / 284 / 298 行）仅存在于 `WITH_EDITORONLY_DATA`（第 248 行起）。

## 五、扩展点

### 5.1 可覆写虚函数（类内 35 条，分组）

| 组 | 成员（行号） |
|---|---|
| **序列契约覆写**（基类纯虚/虚的实现，核心扩展面） | `Initialize`(37)、`BindPossessableObject`(42)、`CanPossessObject`(43)、`GatherExpiredObjects`(49)、`GetMovieScene`(50)、`GetParentObject`(51)、`UnbindPossessableObjects`(52)、`UnbindObjects`(53)、`UnbindInvalidObjects`(54)、`AllowsSpawnableObjects`(55)、`AllowsCustomBindings`(56)、`CanRebindPossessable`(57)、`MakeSpawnableTemplateFromInstance`(58)、`CanAnimateObject`(59)、`CreateDirectorInstance`(60)、`GetBindingReferences`(61) |
| UObject / 资产 | `PostLoad`(62)、`PostInitProperties`(67)、`Rename`(68)、`AddAssetUserData`(72)、`RemoveUserDataOfClass`(73)、`GetAssetUserDataOfClass`(74)、`GetAssetUserDataArray`(75)、`PostDuplicate`(99) |
| 编辑器 / 注册 | `IsTrackSupportedImpl`(80)、`IsFilterSupportedImpl`(81)、`GetAssetRegistryTagMetadata`(82)、`GetAssetRegistryTags`(83)、`ThreadedPostLoadAssetRegistryTagsOverride`(87)、`IterateDynamicBindings`(109) |
| protected 工厂 | `CreatePossessable`(126)、`CreateSpawnable`(127) |

### 5.2 不建议覆写的内部虚函数

无——a) 组为基类契约（实现者面），b)~d) 为常规覆写面。

## 六、生命周期

- 资产对象：CDO 在模块 Startup 时被注入 `UMovieSceneMetaData` / `UMovieSceneShotMetaData`（`Private/LevelSequenceModule.cpp` 第 33-36 行）——即每个关卡序列都带基础 MetaData。
- **`MovieScene` 子对象**（第 32 行）持有轨道、段与绑定数据；播放由 `ULevelSequencePlayer`（`LevelSequencePlayer.h` 第 75 行，经 `ALevelSequenceActor`）驱动。
- 绑定解析（UOL 定位器）与播放时序属 `flows/` 范畴（暂无 Sequencer 流程产物）。

## 七、派生类（范围内）

搜索边界：派生类搜索**仅覆盖本版纳入范围的 292 个模块**（Runtime 291 个 + `EnhancedInput` 插件）。搜索模式 `\bpublic\s+ULevelSequence\b`（`*.h`）：Runtime **0 命中**；EnhancedInput **0**。

| 派生类 | — |
|---|---|
| （无） | 范围内无派生类 |

> 范围外（Plugins，仅记录）：`UCineAssembly`（`Engine/Plugins/VirtualProduction/CinematicAssemblyTools/Source/CineAssemblyTools/Public/CineAssembly.h` 第 64 行）、`UAvaSequence`（`Engine/Plugins/VirtualProduction/Avalanche/Source/AvalancheSequence/Public/AvaSequence.h` 第 32 行）。

## 取数说明

| 断言 | 取数方式（相对基准：`Engine/Source`） |
|---|---|
| 文件 316 行、类体 22-316 | `[System.IO.File]::ReadAllLines(...).Count` + `^};` 检索 |
| 类内 `virtual` 35 条 | `Select-String -Pattern 'virtual'` 全匹配 + 逐段核对 |
| 派生统计：Runtime 0 / EnhancedInput 0 | `Select-String -Pattern '\bpublic\s+ULevelSequence\b'`（`*.h`） |
| 全部行号引用 | 2026-10-10 对 UE 5.8.3 源码本机逐条核对 |

## 相关文档

- `modules/LevelSequence-结构.md` —— ULevelSequence 所在模块（同批产出）
- `types/UMovieSceneSequence.md` —— 基类（批 6）
- `types/UMovieScene3DTransformTrack.md` —— 同批类型
- `modules/UMG-结构.md` —— `ULevelSequenceBurnIn` 基类所在模块
