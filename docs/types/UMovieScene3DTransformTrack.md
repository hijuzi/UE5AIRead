> 引擎版本：UE 5.8.3 (Build 58210709)
> 源码根：Engine/Source
> 生成技能：ue-type-api v1.0
> 生成时间：2026-10-10
> 校验状态：已校验（2026-10-10）

# UMovieScene3DTransformTrack

## 一、类型概览

| 项 | 值 |
|---|---|
| 全限定名 | `UMovieScene3DTransformTrack`（全局命名空间） |
| 定义位置 | `Engine/Source/Runtime/MovieSceneTracks/Public/Tracks/MovieScene3DTransformTrack.h` |
| 类型 | 类（反射类型；属性轨道——最常用的"变换"轨道） |
| 反射宏 | `UCLASS(MinimalAPI)`（第 56 行）+ **`GENERATED_UCLASS_BODY()`**（第 61 行；**不是** `GENERATED_BODY()`） |
| 导出策略 | `MinimalAPI` + 成员级 `MOVIESCENETRACKS_API`（第 82、83 行，2 处） |
| 所属模块 | `MovieSceneTracks`（`Engine/Source/Runtime/MovieSceneTracks`） |

## 二、继承链

```
UObjectBase            （Engine/Source/Runtime/CoreUObject/Public/UObject/UObjectBase.h 第 66 行；链根）
  └─ UObjectBaseUtility（Engine/Source/Runtime/CoreUObject/Public/UObject/UObjectBaseUtility.h 第 44 行）
       └─ UObject      （Engine/Source/Runtime/CoreUObject/Public/UObject/Object.h 第 98 行）
            └─ UMovieSceneSignedObject（Engine/Source/Runtime/MovieScene/Public/MovieSceneSignedObject.h 第 71 行；UCLASS 第 70 行）
                 └─ UMovieSceneDecorationContainerObject（Engine/Source/Runtime/MovieScene/Public/Decorations/MovieSceneDecorationContainer.h 第 108 行；UCLASS 第 107 行）
                      └─ UMovieSceneTrack（Engine/Source/Runtime/MovieScene/Public/MovieSceneTrack.h 第 203 行；UCLASS 第 202 行；混入 IMovieSceneTrackVirtualAPI）
                           └─ UMovieSceneNameableTrack（Engine/Source/Runtime/MovieScene/Public/MovieSceneNameableTrack.h 第 22 行；UCLASS 第 21 行）
                                └─ UMovieScenePropertyTrack（MovieSceneTracks/Public/Tracks/MovieScenePropertyTrack.h 第 29 行；UCLASS 第 28 行）
                                     └─ UMovieScene3DTransformTrack（第 57 行；`: public UMovieScenePropertyTrack, public IMovieSceneBlenderSystemSupport`）
```

> 注意：**`UMovieSceneTrack` 与 `UMovieSceneSignedObject` 之间隔着 `UMovieSceneDecorationContainerObject`**（5.8 的中间层）；链共 6 级。

## 三、声明片段

```
文件：Engine/Source/Runtime/MovieSceneTracks/Public/Tracks/MovieScene3DTransformTrack.h
行 56-61：UCLASS(MinimalAPI) / class UMovieScene3DTransformTrack / : public UMovieScenePropertyTrack
          / , public IMovieSceneBlenderSystemSupport / { / GENERATED_UCLASS_BODY()

文件：Engine/Source/Runtime/MovieSceneTracks/Public/Tracks/MovieScene3DTransformTrack.h
行 91：类体结束（};；文件 91 行；同文件含辅助结构 FTrajectoryKey 第 16-51 行）
```

## 四、公开 API

> 类内 public 段**共 9 条**（其余能力由基类提供），全列如下：

| 签名 | 说明 | 位置 |
|---|---|---|
| `SupportsType(TSubclassOf<UMovieSceneSection>) const`（虚） | 判定支持的段类型 | 第 67 行 |
| `CreateNewSection()`（虚） | 创建配套段（`UMovieScene3DTransformSection`） | 第 68 行 |
| `CanRename() const`（虚；`WITH_EDITORONLY_DATA`） | 是否可改名（返回 true） | 第 71 行 |
| `GetDisplayName() const`（虚；编辑器） | 显示名 | 第 72 行 |
| `GetBlenderSystem() const`（虚） | 取混合系统类 | 第 76 行 |
| `SetBlenderSystem(TSubclassOf<UMovieSceneBlenderSystem>)`（虚） | 设置混合系统 | 第 77 行 |
| `GetSupportedBlenderSystems(TArray<...>&) const`（虚） | 支持的混合系统清单 | 第 78 行 |
| `GetTrajectoryData(FFrameNumber, int32, TRange<FFrameNumber>) const`（`MOVIESCENETRACKS_API`；`WITH_EDITOR`） | 轨迹采样数据 | 第 82 行 |
| `GetLabelColor(const FMovieSceneLabelParams&) const`（虚；`MOVIESCENETRACKS_API`） | 标签颜色 | 第 83 行 |

> 基类 `UMovieScenePropertyTrack`（同模块 `Public/Tracks/MovieScenePropertyTrack.h` 第 29 行）提供属性名/路径绑定与段查找 API（如 `SetPropertyNameAndPath`、`FindSection` 系列）。
> 数据成员：`BlenderSystemClass`（`TSubclassOf<UMovieSceneBlenderSystem>`，private，第 89-90 行）。
> **不存在**：`GetFriction` 等不适用；本类无"Play/Stop"类运行时 API（轨道数据由序列求值驱动）。

## 五、扩展点

### 5.1 可覆写虚函数（类内 8 条，全列）

| 组 | 成员（行号） |
|---|---|
| `UMovieSceneTrack` 契约 | `SupportsType`(67)、`CreateNewSection`(68) |
| 编辑器显示 | `CanRename`(71)、`GetDisplayName`(72)、`GetLabelColor`(83) |
| Blender 系统（`IMovieSceneBlenderSystemSupport`） | `GetBlenderSystem`(76)、`SetBlenderSystem`(77)、`GetSupportedBlenderSystems`(78) |

非虚对外 API：`GetTrajectoryData`（第 82 行）。

### 5.2 不建议覆写的内部虚函数

无。

## 六、生命周期

- 轨道对象由 `UMovieScene` 持有（`DefaultToInstanced` 语义经基类 `UMovieSceneTrack`）；配套段的创建经 `CreateNewSection()`（第 68 行），由编辑器/运行时按需调用。
- 求值经 EntitySystem 层（`MovieSceneTracks/Public/Systems/` 下的属性系统）驱动；通道数据存于 `UMovieScene3DTransformSection`（`Public/Sections/MovieScene3DTransformSection.h` 第 215 行）。

## 七、派生类（范围内）

搜索边界：派生类搜索**仅覆盖本版纳入范围的 292 个模块**（Runtime 291 个 + `EnhancedInput` 插件）。搜索模式 `\bpublic\s+UMovieScene3DTransformTrack\b`（`*.h`）：Runtime **0 命中**；EnhancedInput **0**（另以 `Engine/Source` 全树复核仍为 0）。

| 派生类 | — |
|---|---|
| （无） | 引擎内无派生类 |

> 同族参照：配套段类 `UMovieScene3DTransformSection`（`MovieSceneTracks/Public/Sections/MovieScene3DTransformSection.h` 第 215 行）；基类 `UMovieScenePropertyTrack`（第 29 行）。

## 取数说明

| 断言 | 取数方式（相对基准：`Engine/Source`） |
|---|---|
| 文件 91 行、类体 56-91 | `[System.IO.File]::ReadAllLines(...).Count` + `^};` 检索 |
| 类内 `virtual` 8 条 | `Select-String -Pattern 'virtual'` + `override` 全匹配交叉核对 |
| 派生统计：0 命中 | `Select-String -Pattern '\bpublic\s+UMovieScene3DTransformTrack\b'`（`*.h`） |
| 全部行号引用 | 2026-10-10 对 UE 5.8.3 源码本机逐条核对 |

## 相关文档

- `modules/MovieSceneTracks-结构.md` —— UMovieScene3DTransformTrack 所在模块（同批产出）
- `types/UMovieSceneSequence.md` —— 序列资产基类（批 6）
- `modules/MovieScene-结构.md` —— `UMovieSceneTrack` / `UMovieSceneSection` 所在模块（批 6）
- `types/UObject.md` —— 基类链终点（已校验）
