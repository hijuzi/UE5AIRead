> 引擎版本：UE 5.8.3 (Build 58210709)
> 源码根：Engine/Source
> 生成技能：ue-type-api v1.0
> 生成时间：2026-10-10
> 校验状态：已校验（2026-10-10）

# AActor

## 一、类型概览

| 项 | 值 |
|---|---|
| 全限定名 | `AActor`（全局命名空间） |
| 定义位置 | `Engine/Source/Runtime/Engine/Classes/GameFramework/Actor.h` |
| 类型 | 类（反射类型） |
| 反射宏 | `UCLASS(BlueprintType, Blueprintable, config=Engine, meta=(ShortTooltip="An Actor is an object that can be placed or spawned in the world."), MinimalAPI)`（第 281 行）+ `GENERATED_BODY()`（第 284 行） |
| 导出策略 | `MinimalAPI`：类声明行**无**导出宏（第 282 行 `class AActor : public UObject`）；成员逐个标注 `ENGINE_API`（如第 288 行构造函数、第 2125 行 `BeginPlay`） |
| 所属模块 | `Engine`（`Engine/Source/Runtime/Engine`） |

## 二、继承链

```
UObjectBase            （Engine/Source/Runtime/CoreUObject/Public/UObject/UObjectBase.h 第 66 行；链根）
  └─ UObjectBaseUtility（Engine/Source/Runtime/CoreUObject/Public/UObject/UObjectBaseUtility.h 第 44 行）
       └─ UObject      （Engine/Source/Runtime/CoreUObject/Public/UObject/Object.h 第 98 行）
            └─ AActor  （Engine/Source/Runtime/Engine/Classes/GameFramework/Actor.h 第 282 行）
```

派生方向：范围内直接派生类 80 个（边界与统计见第七节）。

## 三、声明片段

```
文件：Engine/Source/Runtime/Engine/Classes/GameFramework/Actor.h
行 281-284：UCLASS(..., MinimalAPI) / class AActor : public UObject / { / GENERATED_BODY()

文件：Engine/Source/Runtime/Engine/Classes/GameFramework/Actor.h
行 4676：类体结束（};；文件共 5,077 行）
```

## 四、公开 API

> 节选核心 API；完整接口见头文件（`Actor.h` 5,077 行）。「K2_」为蓝图命名包装。

| 签名 | 说明 | 位置（Actor.h） |
|---|---|---|
| `GetActorLocation()` | 世界位置（inline 包装 `K2_GetActorLocation`，第 1568 行） | 第 2502 行 |
| `SetActorLocation(...)` | 设置位置（可 sweep） | 第 1636 行 |
| `GetActorRotation()` | 世界旋转 | 第 2508 行 |
| `GetActorTransform()` | 世界变换（const 引用返回） | 第 2496 行 |
| `SetActorTransform(...)` | 设置变换 | 第 1800 行 |
| `GetActorScale3D()` / `SetActorScale3D(...)` | 缩放 | 第 1710 / 1706 行 |
| `GetOwner()` | 拥有者（inline 实现第 4972 行） | 第 2992 行 |
| `GetInstigator()` | 发起者（`APawn*`） | 第 1452 行 |
| `GetWorld()` | 所属世界（`override final`） | 第 3766 行 |
| `GetLevel()` | 所属关卡 | 第 3371 行 |
| `GetComponents(...)` | 组件收集（5 个模板重载） | 第 3982-4069 行 |
| `FindComponentByClass(...)` / `GetComponentByClass(...)` | 组件查询（含模板版） | 第 3788 / 3792 行 |
| `PrimaryActorTick` | Tick 函数结构（`FActorTickFunction` 成员） | 第 318 行 |
| `BeginPlay()` / `EndPlay(...)` | 生命周期钩子（虚） | 第 2125 / 2132 行 |
| `Tick(...)` / `TickActor(...)` | 逐帧回调（虚） | 第 3060 / 2921 行 |
| `SetLifeSpan(...)` / `LifeSpanExpired()` | 寿命设置 / 到期回调 | 第 2307 / 2940 行 |
| `Destroy(...)` | 销毁 | 第 2327 行 |
| `SetActorHiddenInGame(...)` / `SetActorEnableCollision(...)` | 可见性 / 碰撞开关 | 第 1922 / 1926 行 |

## 五、扩展点

### 5.1 可覆写虚函数

> 本类型 `virtual` 全匹配计数 256（含注释行，见取数说明）；下表为设计上常用的覆写点。

| 虚函数 | 何时被调用 | 位置（Actor.h） | 覆写注意 |
|---|---|---|---|
| `PostInitProperties()`（override） | 构造链结束、属性初始化完成后 | 第 2343 行 | 见 `types/UObject.md` 5.1；常用初始化点 |
| `PostLoad()`（override） | 对象从磁盘加载后 | 第 2348 行 | 仅加载路径 |
| `PostActorCreated()` | 生成型创建完成后（非加载） | 第 2937 行 | — |
| `PreInitializeComponents()` / `PostInitializeComponents()` | 组件注册前 / 后 | 第 3124 / 3127 行 | 组件相关初始化的正确时机 |
| `BeginPlay()` / `EndPlay(reason)` | 进入游戏 / 退出（销毁、关卡切换等） | 第 2125 / 2132 行 | 游戏逻辑起点与终点 |
| `TickActor(...)` / `Tick(DeltaSeconds)` | 逐帧（由 `PrimaryActorTick` 调度） | 第 2921 / 3060 行 | 通常覆写 `Tick` |
| `PostRegisterAllComponents()` / `PostUnregisterAllComponents()` | 组件注册 / 注销全部完成后 | 第 3238 / 3253 行 | — |
| `Destroyed()` | `Destroy` 后、内存回收前 | 第 3569 行 | — |
| `BeginDestroy()`（override） | 销毁开始（可异步清理） | 第 2369 行 | 见 `types/UObject.md` 5.1 |
| `SetLifeSpan(...)` / `LifeSpanExpired()` | 寿命到期 | 第 2307 / 2940 行 | — |
| `NotifyActorBeginOverlap(...)` / `NotifyActorEndOverlap(...)` | 重叠事件 | 第 2191 / 2204 行 | 蓝图另有 `Receive` 版 |
| `NotifyHit(...)` | 命中事件 | 第 2291 行 | — |
| `SetActorHiddenInGame(...)`（虚） | 可见性变更 | 第 1922 行 | — |
| `GetLifetimeReplicatedProps(...)` | 收集网络复制列表 | 第 306 行 | 网络 |
| `PreReplication(...)` / `PostNetReceive()` / `PostNetInit()` | 网络同步钩子 | 第 990 / 2946 / 2958 行 | 网络 |

### 5.2 不建议覆写的内部虚函数

| 虚函数 | 原因 |
|---|---|
| `CheckDefaultSubobjectsInternal()`（第 2342 行，override） | 默认子对象一致性校验（内部流程） |
| `ProcessEvent(...)`（第 2344 行）/ `GetFunctionCallspace(...)`（第 2345 行）/ `CallRemoteFunction(...)`（第 2346 行） | 反射与网络调用分派内部机制——覆写会破坏蓝图/网络调用链 |

## 六、生命周期

- **生成**：构造（`ENGINE_API AActor();` 第 288 行）→ `PostInitProperties`（第 2343 行）→ 组件初始化（`PreInitializeComponents` / `PostInitializeComponents`，第 3124 / 3127 行）→ `PostActorCreated`（第 2937 行）。
- **加载**：`PostLoad`（第 2348 行）→ `PostLoadSubobjects`（第 2349 行）。
- **运行**：`BeginPlay`（第 2125 行）→ 每帧 `TickActor` / `Tick`（受 `PrimaryActorTick` 配置驱动）→ 网络事件钩子。
- **结束**：`EndPlay(reason)`（第 2132 行）→ `Destroyed()`（第 3569 行）→ `BeginDestroy()`（第 2369 行）→ GC 回收。
- 构造路径的完整调用链见 `flows/UObject创建流程.md`；各钩子的精确触发时序属 `flows/` 范畴，本篇只写时机。

## 七、派生类（范围内）

搜索边界：派生类搜索**仅覆盖本版纳入范围的 292 个模块**（Runtime 291 个 + `EnhancedInput` 插件），引擎其余部分（Editor / Developer / Platforms / 未纳入的 Plugins）未覆盖。搜索模式 `\bpublic\s+AActor\b`（`*.h`）：Runtime 命中 **80 行 / 80 文件**；EnhancedInput 命中 **0 行**。

| 代表派生类 | 位置 | 备注 |
|---|---|---|
| `APawn` | `Engine/Source/Runtime/Engine/Classes/GameFramework/Pawn.h` 第 43 行 | 直接（`: public AActor, public INavAgentInterface`） |
| `AController` | `Engine/Source/Runtime/Engine/Classes/GameFramework/Controller.h` 第 40 行 | 直接（`: public AActor, public INavAgentInterface`） |
| `AHUD` | `Engine/Source/Runtime/Engine/Classes/GameFramework/HUD.h` 第 36 行 | 直接 |
| `APlayerController` | `Engine/Source/Runtime/Engine/Classes/GameFramework/PlayerController.h` 第 262 行 | 间接（经 `AController`） |
| `ACharacter` | `Engine/Source/Runtime/Engine/Classes/GameFramework/Character.h` 第 338 行 | 间接（经 `APawn`） |
| `AGameModeBase` | `Engine/Source/Runtime/Engine/Classes/GameFramework/GameModeBase.h` 第 47 行 | 间接（经 `AInfo`） |
| `AGameStateBase` | `Engine/Source/Runtime/Engine/Classes/GameFramework/GameStateBase.h` 第 32 行 | 间接（经 `AInfo`） |
| `APlayerState` | `Engine/Source/Runtime/Engine/Classes/GameFramework/PlayerState.h` 第 41 行 | 间接（经 `AInfo`） |

完整清单按「取数说明」中的命令复现（80 个文件，含 `WorldPartition/`、`Net/`、各 Experimental 模块下的派生类）。

## 取数说明

| 断言 | 取数方式（相对基准：`Engine/Source`） |
|---|---|
| `Actor.h` 5,077 行、类体 282-4676 | `[System.IO.File]::ReadAllLines(...).Count` + `^};` 检索 |
| `virtual` 全匹配 256 | `Select-String (Join-Path "Runtime/Engine" "Classes/GameFramework/Actor.h") -Pattern 'virtual' -AllMatches` 全匹配计数 |
| 派生统计：Runtime 80 行 / 80 文件；EnhancedInput 0 行 | `Select-String -Pattern '\bpublic\s+AActor\b'`（`*.h`；行数 = 匹配行总数，文件数 = 按 Path 分组计数） |
| 全量派生清单复现 | `search_content: pattern="\bpublic\s+AActor\b" glob="*.h"`，范围 `Runtime` 与 `Engine/Plugins/EnhancedInput/Source` |
| 全部行号引用 | 2026-10-10 对 UE 5.8.3 源码本机逐条核对 |

## 相关文档

- `modules/Engine-结构.md` —— AActor 所在模块（同批产出）
- `modules/CoreUObject-结构.md` —— 基类链所在模块
- `types/UObject.md` —— 基类（生命周期钩子的语义母本）
- `types/FName.md` —— 对象名体系（同批产出）
- `flows/UObject创建流程.md` —— 对象创建主路径（已校验）

## 更新记录

- 2026-10-10 修正「取数说明」中命令示例的路径写法（反斜杠形式与裸子串形式先后触发机器初筛的路径告警与误解析，最终改用 `Join-Path` 拆分字符串形式）
