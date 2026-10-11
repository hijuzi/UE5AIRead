> 引擎版本：UE 5.8.3 (Build 58210709)
> 源码根：Engine/Source
> 生成技能：ue-type-api v1.0
> 生成时间：2026-10-10
> 校验状态：已校验（2026-10-11）

# FFastArraySerializer

## 一、类型概览

| 项 | 值 |
|---|---|
| 全限定名 | `FFastArraySerializer`（全局命名空间） |
| 定义位置 | `Engine/Source/Runtime/Net/Core/Classes/Net/Serialization/FastArraySerializer.h`（**注意路径多一层 `Net/`**） |
| 类型 | 结构体（反射类型，非 `UObject` 体系） |
| 反射宏 | `USTRUCT()`（第 407 行）+ `GENERATED_USTRUCT_BODY()`（第 410 行）——**无参数、无 BlueprintType**（实测该文件 0 命中） |
| 导出策略 | 结构体声明行无导出宏（第 408 行）；成员级 `NETCORE_API`（第 412、413、596-599 行等）；大量成员为 inline 模板，无需导出 |
| 所属模块 | `NetCore`（`Engine/Source/Runtime/Net/Core`） |

## 二、继承链

**无基类**（第 408 行：`struct FFastArraySerializer` 后直接 `{`）——链根。
使用方式是**子类结构体继承它**，并把序列化的数组声明在子类中（见第七节与第 723-725 行注释要求：数组须为子类顶层 `UPROPERTY`）。

## 三、声明片段

```
文件：Engine/Source/Runtime/Net/Core/Classes/Net/Serialization/FastArraySerializer.h
行 407-410：USTRUCT() / struct FFastArraySerializer / { / GENERATED_USTRUCT_BODY()

文件：Engine/Source/Runtime/Net/Core/Classes/Net/Serialization/FastArraySerializer.h
行 297-300：USTRUCT() / struct FFastArraySerializerItem / { / GENERATED_USTRUCT_BODY()（配套元素类型）

文件：Engine/Source/Runtime/Net/Core/Classes/Net/Serialization/FastArraySerializer.h
行 745：类体结束（};；文件 1,882 行）
```

## 四、公开 API

| 签名 / 成员 | 说明 | 位置 |
|---|---|---|
| 构造 / 析构（`NETCORE_API`） | — | 第 412 / 413 行 |
| `ItemMap`（`TMap<int32, int32>`） | 复制 ID → 数组下标映射 | 第 416 行 |
| `IDCounter` / `ArrayReplicationKey`（`UPROPERTY(NotReplicated)`） | ID 计数 / 数组复制键 | 第 419-420 / 423-424 行 |
| `GuidReferencesMap` / `GuidReferencesMap_StructDelta` | GUID 引用追踪 | 第 427 / 430 行 |
| `MarkItemDirty(FFastArraySerializerItem&)` | 单元素标脏 | 第 441 行 |
| `MarkArrayDirty()` | 数组标脏 | 第 457 行 |
| `IncrementArrayReplicationKey()` | 递增复制键 | 第 467 行 |
| `FastArrayDeltaSerialize<T, Serializer>(...)`（static 模板） | **增量序列化核心**（trait 调用入口） | 第 493-494 行 |
| `PreReplicatedRemove` / `PostReplicatedAdd` / `PostReplicatedChange`（inline 空实现） | 客户端回调（**故意非 virtual**，见第五节） | 第 501 / 508 / 515 行 |
| `FPostReplicatedReceiveParameters`（嵌套结构） | 接收参数（部分成员 5.4 起废弃，第 525-526 行） | 第 521-527 行 |
| `CPostReplicatedReceiveFuncable`（嵌套） | `PostReplicatedReceive` 编译期探测 | 第 533 行 |
| `ShouldWriteFastArrayItem(...)` | 写过滤 | 第 544 行 |
| `SetDeltaSerializationEnabled(bool)` / `GetDeltaSerializationFlags()` | 增量序列化开关 / 标志 | 第 549 / 568 行 |
| `GetMaxNumberOfAllowedChangesPerUpdate()` / `...DeletionsPerUpdate()`（static + `NETCORE_API` 静态成员与 CVar，第 596-599 行） | 测试限额 | 第 573 / 578 行 |
| `CachePushModelState(...)`（`WITH_PUSH_MODEL`） | Push Model 状态缓存 | 第 584 行 |

> **不存在**（实测 0 命中）：
> - `NetDeltaSerialize` **成员**——实际机制是静态模板 `FastArrayDeltaSerialize`（第 493 行）；`NetDeltaSerialize` 由**子类自行声明**（本文件第 102 行的示例在 `#if 0` 折叠块内）。
> - `GetArraySerializer`（整个 Runtime 0 命中）。
> - `Items` 成员——在**子类**中声明（本文件仅第 99 行示例引用，位于 `#if 0` 内）。

## 五、扩展点

### 5.1 可覆写虚函数

**无——类内 `virtual` 命中 0。** 三个复制回调（第 499 / 506 / 513 行注释）**故意非虚**：由模板代码（`FastArrayDeltaSerialize`）做编译期探测调用；子类按同名同签名声明即可被调用。

### 5.2 不建议覆写的内部虚函数

无。（注：同文件的 `FNetFastTArrayBaseState : public INetDeltaBaseState`（第 263 行）含虚函数——`IsStateEqual` 第 271 行、`CountBytes` 第 285 行——属增量状态类，与序列化器本身无关。）

## 六、生命周期

- 纯值语义结构体（通常作为 `UObject` 的 `UPROPERTY` 成员）；无 `UObject` 钩子。
- 运行时链路：属性复制 → `TStructOpsTypeTraits<子类>`（`WithNetDeltaSerializer = true`；示例在第 109-114 行，**位于 `#if 0` 折叠块**）→ `FastArrayDeltaSerialize`（第 493 行）→ 回调（第 501 / 508 / 515 行）。
- 完整复制链路属 `flows/` 范畴（暂无网络流程产物）。

## 七、派生类（范围内）

搜索边界：派生类搜索**覆盖 Runtime 291 个模块 + `EnhancedInput` 插件全部 3 个模块（共 294 个模块）**。搜索模式 `\bpublic\s+FFastArraySerializer\b`（`*.h`）：Runtime **3 命中 / 3 文件**（其中 1 处为 `#if 0` 示例，**真实派生 2 个**）；EnhancedInput **0**。

| 派生结构体 | 位置 | 备注 |
|---|---|---|
| `FIrisFastArraySerializer` | `Engine/Source/Runtime/Net/Iris/Public/Iris/ReplicationState/IrisFastArraySerializer.h` 第 26 行 | Iris 复制系统扩展 |
| `FWorldPartitionDestructibleHLODState` | `Engine/Source/Runtime/Engine/Public/WorldPartition/HLOD/DestructibleHLODComponent.h` 第 55 行 | 世界分区 HLOD |
| （示例，不计入） | `Engine/Source/Runtime/Net/Core/Classes/Net/Serialization/FastArraySerializer.h` 第 94 行 `FExampleArray` | 位于 `#if 0` 内，非真实派生 |

> 范围外（Plugins，仅记录）：GameplayAbilities 的 `FActiveGameplayEffectsContainer` / `FGameplayAbilitySpecContainer` 等 6 个 + UIFramework 5 个 + MassReplication / InstancedActors / Lobby 各 1 个，共 14 个。

## 取数说明

| 断言 | 取数方式（相对基准：`Engine/Source`） |
|---|---|
| 范围外（Plugins）派生：`GameplayAbilities` **6** 个 + 其余插件 **14** 个 | `[H]` 在 `Engine/Plugins` 下按 `public FFastArraySerializer` 派生模式检索（`*.h`），按插件分组计数 |
| 搜索边界 294 个模块（Runtime 291 + `EnhancedInput` 插件 3） | `[M]` 插件 3 个模块（含白名单外的 `InputBlueprintNodes` / `InputEditor`）：`(Get-ChildItem "Engine/Plugins/EnhancedInput/Source" -Directory).Count` → 3；Runtime 291 见 `_meta/inventory.md` |
| 文件 1,882 行、类体 407-745 | `[M]` `[System.IO.File]::ReadAllLines("Engine/Source/Runtime/Net/Core/Classes/Net/Serialization/FastArraySerializer.h").Count`（同文件 `^};` 检索定类体区间） |
| 类内 `virtual` 0 条 | `[H]` 逐行通读统计（该环境工具 count 模式异常，口径已注明） |
| 派生统计：3 命中 / 3 文件（1 为 `#if 0` 示例）；EnhancedInput 0 | `[H]` `Select-String -Pattern '\bpublic\s+FFastArraySerializer\b'`（`*.h`），Runtime 与 Plugins 分别独立查询 |
| 全部行号引用 | 2026-10-10 对 UE 5.8.3 源码本机逐条核对 |

## 相关文档

- `modules/NetCore-结构.md` —— FFastArraySerializer 所在模块（同批产出）
- `modules/GameplayTasks-结构.md` —— 公开依赖 NetCore 的模块（同批产出）
- `modules/CoreUObject-结构.md` —— `CoreNet.h`（网络原语）的宿主模块
- `types/UObject.md` —— 典型宿主对象（已校验）

## 更新记录

- 2026-10-11 搜索边界更正：派生搜索实覆盖 **294** 个模块（Runtime 291 + `EnhancedInput` 插件 3），原文误作"纳入范围的 292 个模块"（292 是白名单口径，搜索实际连 `InputBlueprintNodes` / `InputEditor` 一并覆盖，本文件命中的插件侧结果即来自 `InputEditor`）；同时在「取数说明」补入该边界取数方式（`convention.md` 4.2）

- 2026-10-11 「取数说明」补入 1 行计数断言取数方式（`convention.md` 4.2 覆盖要求）

- 2026-10-11 按规范 4.2.1 为「取数说明」各行加方法标记（`[M]`/`[R]`/`[H]`）；`[M]` 行把原文省略成 `(...)` 的路径补全为白名单可执行命令，现由 `ue-doc-verify` 逐条实际执行比对
