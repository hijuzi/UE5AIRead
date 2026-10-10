> 引擎版本：UE 5.8.3 (Build 58210709)
> 源码根：Engine/Source
> 生成技能：ue-flow-trace v1.0
> 生成时间：2026-10-10
> 校验状态：已校验（2026-10-10）

# UObject 创建流程（`NewObject` 主路径）

## 一、追踪边界

| 项 | 本次范围 |
|---|---|
| 入口点 | `NewObject<T>()` @ `Engine/Source/Runtime/CoreUObject/Public/UObject/UObjectGlobals.h` 行 1929-1993（三个模板重载，游戏代码最常用第一个） |
| 终止条件 | 停到叶子实现：`PostConstructInit()` 的直接下游（`InitProperties`、`InstanceSubobjects`、`PostInitProperties`、`PostInitInstance`）只列名称与位置，不展开其内部 |
| 深度上限 | 5 层（从 `NewObject` 算起；第 5 层为 `~FObjectInitializer` → `PostConstructInit`） |
| 未覆盖分支 | ① 对象替换/重建路径（`StaticAllocateObject` 中同名对象已存在的分支）；② 异步加载路径；③ 编辑器事务与编辑器校验路径；④ CDO 首次创建触发的递归重入；⑤ 循环依赖延迟初始化（`USE_CIRCULAR_DEPENDENCY_LOAD_DEFERRING`）；⑥ Verse 类路径；⑦ Remote object 与 AutoRTFM 事务分支；⑧ 蓝图构造脚本的执行点（已定位 `PostInitInstance` 覆写，未向下追） |

> 主路径假设：默认配置（非编辑器、非异步）、类为原生类（`CLASS_Native`）、对象为新建而非替换、游戏线程调用。

### 引用文件的完整路径对照

正文时序树中使用短名，对照如下（均为相对安装根）：

| 短名 | 完整路径 |
|---|---|
| `UObjectGlobals.h` | `Engine/Source/Runtime/CoreUObject/Public/UObject/UObjectGlobals.h` |
| `UObjectGlobals.cpp` | `Engine/Source/Runtime/CoreUObject/Private/UObject/UObjectGlobals.cpp` |
| `UObjectBase.cpp` | `Engine/Source/Runtime/CoreUObject/Private/UObject/UObjectBase.cpp` |
| `Class.h` | `Engine/Source/Runtime/CoreUObject/Public/UObject/Class.h` |
| `Class.cpp` | `Engine/Source/Runtime/CoreUObject/Private/UObject/Class.cpp` |
| `Object.h` | `Engine/Source/Runtime/CoreUObject/Public/UObject/Object.h` |
| `ObjectMacros.h` | `Engine/Source/Runtime/CoreUObject/Public/UObject/ObjectMacros.h` |
| `UObjectPartials.cpp` | `Engine/Source/Runtime/CoreUObject/Private/UObject/UObjectPartials.cpp` |
| `PackageReload.cpp` | `Engine/Source/Runtime/CoreUObject/Private/UObject/PackageReload.cpp` |
| `VVMVerseClass.cpp` | `Engine/Source/Runtime/CoreUObject/Private/VerseVM/VVMVerseClass.cpp` |
| `BlueprintGeneratedClass.cpp` | `Engine/Source/Runtime/Engine/Private/BlueprintGeneratedClass.cpp` |

## 二、机制概述

`NewObject` 是运行时创建 `UObject` 实例的统一入口。它把五件事串成一条原子流程：**分配内存 → 建立对象身份（Class / Outer / Name）并注册到全局对象表 → 执行 C++ 构造函数 → 按 archetype 初始化属性与子对象 → 触发初始化扩展点**。引擎内部的 CDO 创建、反序列化实例化、对象复制（`DuplicateObject`）与蓝图类实例化均复用同一入口（`StaticConstructObject_Internal`）。Gameplay 程序员通过 `NewObject` 创建对象，并通过 `PostInitProperties` 等虚函数介入初始化；理解本条链路是判断"覆写哪个扩展点、在哪一层介入"的前提。

## 三、参与者

| 类型 / 类 | 所属模块 | 在链路中的角色 |
|---|---|---|
| `NewObject<T>`（模板） | `CoreUObject` | 入口：参数打包为 `FStaticConstructObjectParameters` |
| `FStaticConstructObjectParameters` | `CoreUObject` | 参数载体（Class / Outer / Name / Flags / Template / 回调） |
| `StaticConstructObject_Internal` | `CoreUObject` | 主调度函数（唯一核心，所有创建路径汇聚于此） |
| `StaticAllocateObject` | `CoreUObject` | 内存分配 + 对象头初始化 + 全局注册 |
| `GUObjectAllocator` | `CoreUObject` | 实际内存分配器（`AllocateUObject`） |
| `UObjectBase` | `CoreUObject` | 对象头布局（Class / Outer / Flags / Name），`AddObject` 写入全局表 |
| `GUObjectArray` | `CoreUObject` | 全局对象数组，GC 可见性的来源 |
| `FObjectInitializer` | `CoreUObject` | 构造上下文管理器：登记子对象、驱动属性初始化 |
| `UClass::ClassConstructor`（函数指针） | `CoreUObject` | 构造函数分派器，实际指向 `InternalConstructor<TClass>` |
| `InternalConstructor<T>` / `__DefaultConstructor` | `CoreUObject` | 构造函数包装：完成 placement new 调用真正的 C++ 构造函数 |
| `UObject` 及派生类 | `CoreUObject` / 各模块 | 真正的 C++ 构造函数体（如 `AActor::AActor`） |
| `FGCReconstructionGuard` | `CoreUObject` | 构造期间的 GC 保护（防止对象在构造完成前被移动/回收） |
| `FUObjectThreadContext` | `CoreUObject` | 线程局部构造上下文（`IsInConstructor` 计数、initializer 栈） |
| `UClass::PostInitInstance` | `CoreUObject` | 类级实例初始化扩展点（虚） |
| `UObject::PostInitProperties` | `CoreUObject` | 属性初始化扩展点（虚，最常用的介入点） |
| `FCoreUObjectDelegates::OnObjectConstructed` | `CoreUObject` | 对象构造完成委托（`WITH_EDITOR` 下广播） |
| `UBlueprintGeneratedClass` / `UVerseClass` | `Engine` / `CoreUObject` | `PostInitInstance` 的已知覆写者 |

## 四、调用时序

> 缩进表示调用层级；每跳末尾为调用类型标注。
> 调用类型：**直接**（可静态搜到）、**间接**（运行时函数指针 / 虚函数表分派）、**委托**、**反射**。

### 4.1 入口与参数打包（第 1 层）

```
[1] NewObject<T>(Outer, Class, Name, Flags, Template, ...)      UObjectGlobals.h 行 1929-1955
     ├─ 直接 FObjectInitializer::AssertIfInConstructor(...)      行 1936（断言，非机制）
     ├─ 直接 CheckIsClassChildOf_Internal(T::StaticClass(), ...)  行 1941（DO_CHECK）
     ├─ 直接 FStaticConstructObjectParameters Params(Class)       行 1944-1951
     └─ 直接 StaticConstructObject_Internal(Params)               行 1953 ──→ [2]
```

另两个重载同构：`NewObject<T>(Outer)`（行 1957-1970，打包 1965-1966、调用 1968）、
`NewObject<T>(Outer, Name, Flags, ...)`（行 1972-1993，打包 1982-1989、调用 1991）。
默认 `Outer` 为 transient package（行 1959）。

### 4.2 分配与注册（第 2 → 4 层）

```
[2] StaticConstructObject_Internal(Params)                    UObjectGlobals.cpp 行 4803-4875
     ├─ 直接 StaticAllocateObject(...)                          行 4845 ──→ [3]
     │
[3] StaticAllocateObject(...)                                 UObjectGlobals.cpp 行 3431-3838
     ├─ 直接 MakeUniqueObjectName(InOuter, InClass)             行 3509（仅 Name == None；实现 行 2621）
     ├─ 直接 StaticFindObjectFastInternal(...)                  行 3516（仅显式 Name：查重）
     ├─ 直接 GUObjectAllocator.AllocateUObject(...)             行 3564
     │       TotalSize = InClass->GetPropertiesSize()           行 3549
     ├─ 直接 FMemory::Memzero(...) / new ((void*)Obj) UObjectBase 行 3766-3771
     │       └─ 直接 UObjectBase::AddObject(...)                 UObjectBase.cpp 行 169
     │              ├─ GUObjectArray.AllocateUObjectIndex(...)   行 269（分配全局索引）
     │              └─ HashObject(this)                          行 271（入名字哈希表）
     └─ return Obj                                              行 3837
```

`UObjectBase` placement new（行 3767）是**对象头初始化点**：写入 Class / Outer / Flags（含 `RF_NeedInitialization`）。

### 4.3 构造函数分派（第 3 → 4 层）

```
[2] StaticConstructObject_Internal 续
     └─ 间接（函数指针分派）(*InClass->ClassConstructor)(FObjectInitializer(Result, Params))
         │                                                   行 4851
         │   ClassConstructor 实际值 = InternalConstructor<TClass>
         │   （填充点：ObjectMacros.h 行 2309 / 2402 → Class.h 行 4941 存入 UClass）
         │
         ├─ 先构造实参临时对象 FObjectInitializer(Result, Params)   UObjectGlobals.cpp 行 3926-3940
         │    └─ 直接 Construct_Internal()                          行 3939 → 行 3954-4005
         │         ├─ ThreadContext.IsInConstructor++               行 3963（全局状态）
         │         ├─ ThreadContext.ConstructedObject = Obj         行 3965
         │         └─ ThreadContext.PushInitializer(this)           行 3966
         │
         ├─ 间接 InternalConstructor<TClass> → T::__DefaultConstructor(X)
         │       Class.h 行 4978-4982；宏 ObjectMacros.h 行 1950-1968
         │       └─ 间接（placement new）new((EInternal*)X.GetObj())TClass(X)
         │              宏展开：ObjectMacros.h 行 1954（带 initializer 版）
         │              └─ C++ 构造函数链（派生类 → ... → 基类），可见锚点：
         │                  UObject::UObject(const FObjectInitializer&)  UObjectGlobals.cpp 行 3893-3904
         │                   ├─ ObjectInitializer.Obj = this             行 3902
         │                   └─ 直接 FinalizeSubobjectClassInitialization()  行 3903
         │                          （UObjectGlobals.h 行 1574-1577：关闭"子对象类设置"窗口）
         │
         └─ 完整表达式结束 → 析构临时对象 ~FObjectInitializer()     行 4026-4131 ──→ [5]
              （注意：`PostInitProperties` 由析构驱动，发生在整个构造函数链执行完之后）
```

> `.gen.cpp` 说明：`__DefaultConstructor` 的实例由 UHT 写入各模块的 `*.gen.cpp`（构建产物，不在
> `Engine/Source` 树内）。宏本体与调用链锚点即上面引用的 `ObjectMacros.h` 行 1950-1968。

### 4.4 初始化收尾（第 5 层，下游已截断）

```
[5] ~FObjectInitializer()                                      UObjectGlobals.cpp 行 4026-4131
     ├─ 直接 ThreadContext.IsInConstructor--                    行 4054；还原 ConstructedObject 行 4056
     ├─ 直接 Obj->ClearInternalFlags(PendingConstruction)       行 4072
     ├─ 直接 ObjectArchetype 缺省 = Class->GetDefaultObject()   行 4080-4083（可能触发 CDO 创建，见第七节）
     └─ 直接 PostConstructInit()                                行 4109 ──→ [5']
[5'] FObjectInitializer::PostConstructInit()                   行 4134-4376
     ├─ 直接 UE::CoreUObject::Private::ConstructPartials(...)   行 4231（UObjectPartials.cpp 行 171）
     ├─ 直接 InitProperties(Obj, BaseClass, Defaults, ...)      行 4243（archetype/CDO 属性复制）── 已截断
     ├─ 直接 InitSubobjectProperties(bAllowInstancing)          行 4247 → 行 4383-4403（4395 逐子对象 InitProperties）── 已截断
     ├─ 直接 Obj->LoadConfig(...)                               行 4274（仅 CDO 或 CLASS_PerObjectConfig 类）── 已截断
     ├─ 直接 PropertyInitCallback()                             行 4293（来自 Params 的 C++ 回调）
     ├─ 直接 InstanceSubobjects(...)                            行 4299 → 行 4405（4422 Class->InstanceSubobjectTemplates）── 已截断
     ├─ 虚   Subobject->PostReinitProperties()                  行 4307（基类空实现 行 3842-3844；
     │        实现取决于子对象实际类，任何派生类可覆写）
     ├─ 直接 PropertyPostInitCallbacks 逐个调用                 行 4310-4316
     ├─ 虚   Obj->PostInitProperties()                          行 4320（Object.h 行 226 声明为 virtual）
     │        已知实现：UObject::PostInitProperties              行 3846-3869
     │        （3864 GetClass()->CreatePersistentUberGraphFrame）
     │        实现类未知的部分：任意 UObject 派生类可覆写，按对象实际类判断
     ├─ 虚   Class->PostInitInstance(Obj, InstanceGraph)        行 4342（Class.h 行 4568 基类为空实现）
     │        已知覆写：UVerseClass（VVMVerseClass.cpp 行 441-443）
     │                  UBlueprintGeneratedClass（BlueprintGeneratedClass.cpp 行 1240-1243，转调父类）
     └─ 直接 Obj->ClearFlags(RF_NeedInitialization)             行 4372；Obj = nullptr 行 4375
```

> **截断说明**：`PostConstructInit` 的直接下游（`InitProperties` / `InitSubobjectProperties` /
> `InstanceSubobjects` / `PostInitProperties` / `PostInitInstance` 的内部实现）已达深度上限，
> 本次只列名称与位置，不再展开。

### 4.5 收尾（回到第 2 层）

```
[2] StaticConstructObject_Internal 续
     ├─ 直接 GCGuard.Unlock()                                   行 4854（构造全程受 GC 保护）
     ├─ 分支（编辑器）GIsEditor && GUndo && RF_Transactional
     │    └─ 直接 SaveToTransactionBuffer(Result, false)         行 4867 ── 未覆盖（编辑器路径）
     ├─ 委托 FCoreUObjectDelegates::OnObjectConstructed.Broadcast(Result)
     │                                                  行 4872（WITH_EDITOR）
     │      绑定点（本机 Runtime 内可见的唯一消费者）：
     │      FPackageReferencersHelper ::OnObjectConstructedHandle = ...AddRaw(...)
     │      PackageReload.cpp 行 92（编辑器内包装载重定向）
     └─ return Result                                           行 4874
```

### 4.6 环与递归标注

| 位置 | 类型 | 说明 |
|---|---|---|
| 构造函数体内调用 `CreateDefaultSubobject` → 行 5902 `StaticConstructObject_Internal(Params)` | **受控递归** | 子对象的 Outer = 父对象（`UObjectGlobals.cpp` 行 5885-5902）；子对象创建完成后登记到父对象的 `ComponentInits`（行 5906 / 5913）。这不是死环，是"构造期间的嵌套创建" |
| 行 4080-4083 `Class->GetDefaultObject()` / 行 4242 `BaseClass->GetDefaultObject(false)` | **条件递归** | 类 CDO 尚不存在时会触发 CDO 创建，重入本流程；本次未展开（见第七节） |

> **反射调用标注**：本条主路径上**未出现** `ProcessEvent` / UFunction 名字调用形式的反射跳。
> 蓝图类实例的构造脚本执行点未在本次边界内定位（已知入口 `UBlueprintGeneratedClass::PostInitInstance`，
> 5.8 中实现为转调父类）——若该下游存在字节码执行，属"反射调用，静态搜索不可见"，本次已截断，
> **不得据此推断"蓝图无构造脚本"**。

## 五、数据流

### 5.1 输入

| 输入 | 来源 | 缺省行为 |
|---|---|---|
| `Outer` | 调用方 | 重载 1/3 可传 nullptr；重载 2 默认 `GetTransientPackageAsObject()`（`UObjectGlobals.h` 行 1959） |
| `Class` | 调用方显式传入 / `T::StaticClass()` | 无缺省 |
| `Name` | 调用方 | `NAME_None` 时由 `MakeUniqueObjectName` 生成（`UObjectGlobals.cpp` 行 3509） |
| `Flags` | 调用方 | `RF_NoFlags` |
| `Template` | 调用方 | 空时按 archetype 规则解析（行 4833 `GetArchetypeFromRequiredInfo`；行 4080-4083 回退 CDO） |

### 5.2 变换点

| 阶段 | 变换 | 位置 |
|---|---|---|
| 参数打包 | 散参数 → `FStaticConstructObjectParameters` | `UObjectGlobals.h` 行 1944-1951 |
| 名字补全 | `None` → 唯一名（`ClassName_#`） | `UObjectGlobals.cpp` 行 3509 |
| 内存分配 | `TotalSize = Class->GetPropertiesSize()`，对齐后分配 | 行 3549、行 3564 |
| 对象头初始化 | 清零 + `UObjectBase` 构造：写入 Class / Outer / Flags（含 `RF_NeedInitialization`）/ Name | 行 3766-3771；`UObjectBase.cpp` 行 253 |
| 全局注册 | `AllocateUObjectIndex` 分配全局索引；`HashObject` 入哈希表 | `UObjectBase.cpp` 行 269、行 271 |
| 构造函数 | C++ 构造函数链执行：成员初始化、`CreateDefaultSubobject` 登记子对象 | `ObjectMacros.h` 行 1954；`UObjectGlobals.cpp` 行 5906 |
| archetype 决定 | CDO 用 SuperClass 作默认值源；普通对象用 archetype/CDO | 行 4080-4083、行 4235-4242 |
| 属性初始化 | 从 archetype/CDO 复制属性值 | 行 4243 |
| 子对象初始化 | 逐子对象按模板初始化；必要时 instancing | 行 4247、行 4299 |
| 类级初始化 | `PostInitInstance`（蓝图/Verse 类） | 行 4342 |
| 收尾 | 清除 `RF_NeedInitialization`（对象由此"对 GC/其他线程可见为完成态"） | 行 4367-4372 |

### 5.3 输出

- 新对象的 `UObject*`（`StaticConstructObject_Internal` 行 4874 返回，`NewObject<T>` 行 1954 `static_cast<T*>` 转类型）。
- 副作用：对象已存在于 `GUObjectArray` 中（对 GC 可见），名字已注册。

### 5.4 全局状态变更

| 状态 | 变更 | 位置 |
|---|---|---|
| `GUObjectArray` | 分配全局索引（对象对 GC 可见） | `UObjectBase.cpp` 行 269 |
| 名字哈希表 | `HashObject` | `UObjectBase.cpp` 行 271 |
| `FUObjectThreadContext` | `IsInConstructor++/--`；`ConstructedObject` 换入/还原；initializer 入栈/出栈 | `UObjectGlobals.cpp` 行 3963-3966、4054-4057、4127-4128 |
| GC 保护 | 构造全程持 `FGCReconstructionGuard`，完成后 `Unlock()` | 行 4843、行 4854 |
| 事务缓冲 | 编辑器下事务性对象写入 undo 缓冲 | 行 4867（编辑器分支，未覆盖） |

## 六、扩展点

链路上可被游戏代码介入的位置（按介入顺序）：

| 扩展点 | 类型 | 位置 | 说明 |
|---|---|---|---|
| 派生类构造函数 | C++ 覆写 | 各模块（如 `AActor::AActor`） | 创建子对象（`CreateDefaultSubobject`）、设置初始值；此时 `FObjectInitializer` 可用（行 3893-3904 会校验） |
| `PropertyInitCallback` | 回调 | `UObjectGlobals.h` 行 1833；调用点 行 4293 | 由 `FStaticConstructObjectParameters` 传入的 C++ 回调，在属性从 archetype 初始化后、`PostInitProperties` 前执行 |
| `PropertyPostInitCallbacks` | 回调 | `UObjectGlobals.h` 行 1769；调用点 行 4310-4316 | 支持多个回调，在 `PostInitProperties` 之后执行 |
| `UObject::PostInitProperties()` | 虚函数 | 声明 `Object.h` 行 226；基类实现 `UObjectGlobals.cpp` 行 3846-3869 | **最常用的介入点**；在构造函数链结束后被调用（由 `~FObjectInitializer` 驱动，行 4320） |
| `UObject::PostReinitProperties()` | 虚函数 | 基类实现 行 3842-3844 | 子对象属性被重新覆盖后调用（行 4307） |
| `UClass::PostInitInstance()` | 虚函数 | 声明 `Class.h` 行 4568（基类空实现） | 类级实例初始化；已知覆写：`UBlueprintGeneratedClass`（`BlueprintGeneratedClass.cpp` 行 1240-1243）、`UVerseClass`（`VVMVerseClass.cpp` 行 441-443） |
| `FCoreUObjectDelegates::OnObjectConstructed` | 委托 | 声明 `UObjectGlobals.h` 行 3377-3378；广播 行 4872 | `WITH_EDITOR` 下对象构造后广播；本机可见消费者：`PackageReload.cpp` 行 92（编辑器） |
| `UObject::PostCDOContruct()` | 虚函数 | 声明 `Object.h` 行 238 | 仅 CDO 构建路径触发（`Class.cpp` 行 5121、5744），**不在 `NewObject` 主路径上** |

## 七、关键分支与条件

| # | 分支 | 条件 | 位置 | 本次处理 |
|---|---|---|---|---|
| 1 | 自动命名 vs 显式命名 | `Name == None` | 行 3497-3512 | 主路径：走 `MakeUniqueObjectName` |
| 2 | 显式命名查重 | `Name != None` | 行 3513-3542 | 同名不同类为 Fatal；同名同类走复用 |
| 3 | 子对象复用 | `bCanRecycleSubobjects`（行 4829-4836 计算）且命中已存在子对象 | 行 4848-4852 | **未覆盖**：复用时不执行构造函数 |
| 4 | 对象替换/重建 | `Obj != nullptr`（已存在对象） | 行 3566-3737 | **未覆盖**：含 `ConditionalBeginDestroy` → `~UObject` 重建路径 |
| 5 | CDO 首次创建 | `Class->GetDefaultObject()` 发现 CDO 不存在 | 行 4080-4083、行 4242 | **未覆盖**：会递归重入本流程（CDO 路径另触发 `PostCDOContruct`，`Class.cpp` 行 5121） |
| 6 | 异步加载 | `IsInAsyncLoadingThread()` 等 | 行 3745-3754、行 3809-3817 | **未覆盖**：`NotifyConstructedDuringAsyncLoading` 分支 |
| 7 | 编辑器事务 | `GIsEditor && GUndo && RF_Transactional` | 行 4856-4869 | **未覆盖**：`SaveToTransactionBuffer` 分支 |
| 8 | 循环依赖延迟初始化 | `USE_CIRCULAR_DEPENDENCY_LOAD_DEFERRING` 且蓝图延迟条件命中 | 行 4091-4106 | **未覆盖**：`PostConstructInit` 被推迟 |
| 9 | Verse 类 | `Obj->GetClass()->GetClass()` 是 `UVerseClass` 等 | 行 3982-3995 | **未覆盖**：`SetupObjectInitializer` 分支 |
| 10 | 编辑器 FGCObject 校验 | `GIsEditor && GVerifyUObjectsAreNotFGCObjects` 且对象为原生 CDO | 行 3997-4004 | **未覆盖** |
| 11 | Remote object / AutoRTFM | `UE_WITH_REMOTE_OBJECT_HANDLE` / 事务开启 | 行 3764-3783 等处 | **未覆盖**：条件编译分支 |
| 12 | 蓝图构造脚本 | 类为 `UBlueprintGeneratedClass` | 行 4342 下游 | **未覆盖**：`PostInitInstance` 已定位（`BlueprintGeneratedClass.cpp` 行 1240-1243，5.8 中实现为转调父类），构造脚本的静态执行点未在本次范围内定位——**不可据此推断"蓝图无构造脚本"** |

> 分支 3、4、5 的判定逻辑与"是否存在"均以 5.8.3 源码为准；其他版本可能不同。

## 相关文档

- `docs/types/UObject.md` —— `UObject` 的继承链、公开 API 与扩展点
- `docs/types/FName.md` —— 对象名字（`MakeUniqueObjectName` 的产物类型）是非反射值类型
- `docs/modules/CoreUObject-结构.md` —— 本流程主要参与者所在模块
- `docs/modules/Core-结构.md` —— `FName` 所属模块
- `docs/_meta/convention.md` —— 引用格式与路径规范
