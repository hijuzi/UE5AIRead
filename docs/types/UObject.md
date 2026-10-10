> 引擎版本：UE 5.8.3 (Build 58210709)
> 源码根：Engine/Source
> 生成技能：ue-type-api v1.0
> 生成时间：2026-10-10
> 校验状态：已校验（2026-10-10）

# UObject

## 一、类型概览

| 项 | 值 |
|---|---|
| 全限定名 | `UObject`（全局命名空间） |
| 定义位置 | `Engine/Source/Runtime/CoreUObject/Public/UObject/Object.h` |
| 类型 | 类（反射类型） |
| 反射宏 | `UCLASS(Abstract, MinimalAPI, Config = Engine)`（第 97 行）+ `GENERATED_BODY()`（第 100 行） |
| 导出策略 | `MinimalAPI`：仅 `StaticClass()` 等反射必需符号随类导出（类名前无导出宏，第 98 行）；成员函数逐个标注 `COREUOBJECT_API`（如第 226 行 `PostInitProperties`） |
| 所属模块 | `CoreUObject`（`Engine/Source/Runtime/CoreUObject`） |

## 二、继承链

```
UObjectBase                            （Engine/Source/Runtime/CoreUObject/Public/UObject/UObjectBase.h 第 66 行；声明行无基类子句，为链的根）
  └─ UObjectBaseUtility                （Engine/Source/Runtime/CoreUObject/Public/UObject/UObjectBaseUtility.h 第 44 行，: public UObjectBase）
       └─ UObject                      （Engine/Source/Runtime/CoreUObject/Public/UObject/Object.h 第 98 行，: public UObjectBaseUtility）
```

派生方向：范围内直接派生类数量级为数百（统计与边界见第七节）。

## 三、声明片段

```
文件：Engine/Source/Runtime/CoreUObject/Public/UObject/Object.h
行 91-100：类注释、UCLASS(Abstract, MinimalAPI, Config = Engine)、class UObject : public UObjectBaseUtility、GENERATED_BODY()

文件：Engine/Source/Runtime/CoreUObject/Public/UObject/Object.h
行 1839：类体结束（};；文件共 1,932 行）
```

## 四、公开 API

> 节选核心 API；完整接口见头文件（`Object.h` 含 120 处 `virtual`，多为生命周期钩子，见第五节）。

| 签名 | 说明 | 位置 |
|---|---|---|
| `GetClass()` | 运行时类型（`UClass*`） | `UObjectBase.h` 第 223 行 |
| `GetOuter()` | 外部对象 | `UObjectBase.h` 第 229 行 |
| `GetFName()` | 对象名（`FName`） | `UObjectBase.h` 第 239 行 |
| `GetUniqueID()` | 进程内唯一 ID | `UObjectBase.h` 第 217 行 |
| `GetName()` | 对象名（字符串） | `UObjectBaseUtility.h` 第 453 行 |
| `GetFullName(...)` | 全名（可指定 `StopOuter`；含免分配重载） | `UObjectBaseUtility.h` 第 352-370 行 |
| `GetPathName(...)` | 路径名（含免分配重载） | `UObjectBaseUtility.h` 第 381-387 行 |
| `GetTypedOuter<T>()` / `GetTypedOuter(UClass*)` | 类型化 Outer 查询 | `UObjectBaseUtility.h` 第 543-553 行 |
| `IsA<T>()` / `IsA(UClass*)` | 类型判定 | `UObjectBaseUtility.h` 第 633-656 行 |
| `GetWorld()`（虚） | 所属世界 | `Object.h` 第 711 行 |
| `ImplementsGetWorld()`（虚） | `GetWorld()` 是否被实现 | `Object.h` 第 718 行 |
| `CreateDefaultSubobject<T>(...)` 模板族 | 创建默认子对象（构造期使用） | `Object.h` 第 150-196 行 |
| `GetDefaultSubobjects(...)` / `GetDefaultSubobjectByName(...)` | 查询默认子对象 | `Object.h` 第 202、208 行 |
| `StaticClass()` | 类静态访问器（由 `GENERATED_BODY()` 生成，`Object.h` 无手写声明） | — |

## 五、扩展点

### 5.1 可覆写虚函数

> "何时被调用"依据源码注释（括号内为声明行）。

| 虚函数 | 何时被调用 | 覆写注意 |
|---|---|---|
| `PostInitProperties()`（226） | C++ 构造函数与属性初始化完成后、任何序列化之前（注释 222-226） | 创建路径最常用介入点；完整调用链见 `flows/` |
| `PostReinitProperties()`（232） | 属性被覆盖后（含从 CDO 初始化子对象）；一生可多次（注释 228-232） | 与只调一次的 `PostInitProperties` 相区分 |
| `PostCDOContruct()`（238） | CDO 的 C++ 构造函数之后（注释 234-238） | 处理 CDO 构造递归 |
| `PostCDOCompiled(...)`（250） | 蓝图编译器生成 CDO 完成后（注释 245-252） | editor |
| `PreSaveRoot(...)`（278） | `SavePackage` 中、保存根对象之前（注释 255-262） | 返回值传给 `PostSaveRoot` |
| `PostSaveRoot(...)`（270） | 包保存完成后做清理（注释 264-270） | — |
| `IsReadyForAsyncPostLoad()`（340） | 异步加载中、`PostLoad()` 之前（注释 337-340） | — |
| `PostLoad()`（346） | 对象从磁盘加载后立即；不用于新建对象（注释 342-346） | 默认在游戏线程执行 |
| `PostLoadSubobjects(...)`（355） | 为加载的对象实例化组件时（注释 348-355） | — |
| `Serialize(...)`（388-389） | 归档读写与引用收集（注释 384-389） | 双签名：`FArchive` / `FStructuredArchive::FRecord` |
| `BeginDestroy()`（361） | 决定销毁时立即调用，可开始异步清理（注释 357-361） | — |
| `IsReadyForFinishDestroy()`（368） | `BeginDestroy` 之后轮询检查异步清理是否完成（注释 363-368） | 返回 `true` 才会进入 `FinishDestroy` |
| `FinishDestroy()`（382） | 完成销毁；此后不得再访问对象内存（注释 377-382） | **`Super::FinishDestroy()` 应在子类方法末尾调用**（注释的 warning） |
| `PostEditChangeProperty(...)`（473） | 编辑器属性变更 | editor |
| `PostEditChangeChainProperty(...)`（479） | 编辑器链式属性变更 | editor |
| `PostTransacted(...)`（498） | 事务对象事件 | editor |
| `PostLinkerChange()`（374） | 链接器变化（注释 370-374） | editor |
| `GetLifetimeReplicatedProps(...)`（1044） | 收集属性复制列表（`TArray<FLifetimeProperty>&`） | 网络 |
| `IsSupportedForNetworking()`（1064） | 是否支持网络复制 | 网络 |
| `PreNetReceive()`（1073）/ `PostNetReceive()`（1076） | 网络属性接收前 / 后 | 网络 |

### 5.2 不建议覆写的内部虚函数

| 虚函数 | 原因 |
|---|---|
| `GetDetailedInfoInternal()`（第 219 行） | `protected`；注释明确"只应由 `GetDetailedInfo` 调用"（`GetDetailedInfo` 可安全用于空指针） |
| `CheckDefaultSubobjectsInternal()`（第 1790 行） | 名称与用途指示内部校验流程 |

## 六、生命周期

- **创建**：构造链结束 → `PostInitProperties`（主路径调用链见 `flows/UObject创建流程.md`，已校验）。
- **加载**：异步路径先经 `IsReadyForAsyncPostLoad` 检查 → `PostLoad`；仅对从磁盘加载的对象发生。
- **运行期**：`Serialize` 由归档读写按需驱动。
- **销毁**：`BeginDestroy` →（轮询）`IsReadyForFinishDestroy` → `FinishDestroy`。
- 编辑器另有一组钩子：`PostCDOCompiled`、`PostEditChangeProperty`、`PostEditChangeChainProperty`、`PostTransacted`、`PostLinkerChange`。
- 本篇只写时机；跨类调用链不在本篇范围（属 `flows/`）。

## 七、派生类（范围内）

搜索边界：派生类搜索**仅覆盖本版纳入范围的 292 个模块**（Runtime 291 个 + `EnhancedInput` 插件），引擎其余部分（Editor / Developer / Platforms / 未纳入的 Plugins）未覆盖。搜索模式 `\bpublic\s+UObject\b`（`*.h`，区分大小写）：Runtime 命中 **648 行 / 575 文件**；EnhancedInput 命中 **8 行**。

直接派生类数量级为数百，**完整枚举不可读**——下表列代表性直接派生类，全量清单按「取数说明」中的命令复现。

| 直接派生类 | 位置 | 角色 |
|---|---|---|
| `UField` | `Engine/Source/Runtime/CoreUObject/Public/UObject/Class.h` 第 171 行 | 反射体系入口（`UStruct` / `UFunction` / `UClass` 等的根） |
| `UPackage` | `Engine/Source/Runtime/CoreUObject/Public/UObject/Package.h` 第 216 行 | 包 |
| `UWorld`（final） | `Engine/Source/Runtime/Engine/Classes/Engine/World.h` 第 931 行 | 世界 |
| `ULevel` | `Engine/Source/Runtime/Engine/Classes/Engine/Level.h` 第 419 行 | 关卡 |
| `AActor` | `Engine/Source/Runtime/Engine/Classes/GameFramework/Actor.h` 第 282 行 | 场景实体 |
| `UActorComponent` | `Engine/Source/Runtime/Engine/Classes/Components/ActorComponent.h` 第 160 行 | 组件 |
| `UEngine` | `Engine/Source/Runtime/Engine/Classes/Engine/Engine.h` 第 726 行 | 引擎单例（`GEngine` 声明见第 4111 行） |
| `UGameInstance` | `Engine/Source/Runtime/Engine/Classes/Engine/GameInstance.h` 第 151 行 | 游戏实例 |
| `UPlayer` | `Engine/Source/Runtime/Engine/Classes/Engine/Player.h` 第 17 行 | 玩家（本地/网络） |
| `UDataAsset` | `Engine/Source/Runtime/Engine/Classes/Engine/DataAsset.h` 第 17 行 | 数据资产 |
| `UGameplayTagsManager` | `Engine/Source/Runtime/GameplayTags/Classes/GameplayTagsManager.h` 第 336 行 | 标签体系管理器（批 2 模块） |

## 取数说明

| 断言 | 取数方式（相对基准：`Engine/Source`） |
|---|---|
| `Object.h` 1,932 行、类体 98-1839、120 处 `virtual` | `ReadAllLines` 计数 + `^\};` 检索 + `virtual` 全匹配计数 |
| 派生统计：Runtime 648 行 / 575 文件；EnhancedInput 8 行 | `Select-String -Pattern '\bpublic\s+UObject\b' -CaseSensitive`（`*.h`；行数 = 匹配行总数，文件数 = 按 Path 分组计数） |
| 全量派生清单复现 | `search_content: pattern="\bpublic\s+UObject\b" glob="*.h"`，范围 `Runtime` 与 `Engine/Plugins/EnhancedInput/Source` |
| 基类链 3 级 | 三个类声明行实测：`UObjectBase.h` 第 66 行 / `UObjectBaseUtility.h` 第 44 行 / `Object.h` 第 98 行 |
| 全部行号引用 | 2026-10-10 对 UE 5.8.3 源码本机逐条核对 |

## 相关文档

- `modules/CoreUObject-结构.md` —— UObject 所在模块（同批产出）
- `modules/Core-结构.md` —— `FName` 等基础类型来源（同批产出）
- `types/FName.md` —— 对象名体系（同批产出）
- `flows/UObject创建流程.md` —— 对象创建主路径（已校验）

## 更新记录

- 2026-10-10 修正「二、继承链」与「七、派生类」共 14 处路径写法：模块内相对形式 → 相对安装根完整形式（`Engine/Source/Runtime/...`），符合 `_meta/convention.md` 第二节；其中 8 处由 `verify-refs.ps1` 初筛报出（`Engine/Classes/...` 形式解析失败）
