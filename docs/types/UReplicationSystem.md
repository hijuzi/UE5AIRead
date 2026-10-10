> 引擎版本：UE 5.8.3 (Build 58210709)
> 源码根：Engine/Source
> 生成技能：ue-type-api v1.0
> 生成时间：2026-10-10
> 校验状态：已校验（2026-10-10）

# UReplicationSystem

## 一、类型概览

| 项 | 值 |
|---|---|
| 全限定名 | `UReplicationSystem`（**全局命名空间**；文件内的 `UE::Net` 块服务于配套类型） |
| 定义位置 | `Engine/Source/Runtime/Net/Iris/Public/Iris/ReplicationSystem/ReplicationSystem.h` |
| 类型 | 类（反射类型；Iris 复制系统核心） |
| 反射宏 | `UCLASS(transient)`（第 78 行）+ `GENERATED_BODY()`（第 81 行）；**无 `MinimalAPI`** |
| 导出策略 | 逐成员 `IRISCORE_API`（本文件约 100 处类内 + 9 处类外） |
| 所属模块 | `IrisCore`（`Engine/Source/Runtime/Net/Iris`） |

## 二、继承链

```
UObjectBase            （Engine/Source/Runtime/CoreUObject/Public/UObject/UObjectBase.h 第 66 行；链根）
  └─ UObjectBaseUtility（Engine/Source/Runtime/CoreUObject/Public/UObject/UObjectBaseUtility.h 第 44 行）
       └─ UObject      （Engine/Source/Runtime/CoreUObject/Public/UObject/Object.h 第 98 行）
            └─ UReplicationSystem（ReplicationSystem.h 第 79 行）
```

**叶子类**（范围内无派生类，见第七节）。

## 三、声明片段

```
文件：Engine/Source/Runtime/Net/Iris/Public/Iris/ReplicationSystem/ReplicationSystem.h
行 78-81：UCLASS(transient) / class UReplicationSystem : public UObject / { / GENERATED_BODY()

文件：Engine/Source/Runtime/Net/Iris/Public/Iris/ReplicationSystem/ReplicationSystem.h
行 921：类体结束（};；文件 996 行）

配套：public 嵌套结构 FReplicationSystemParams（第 89-211 行；含 ForwardNetRPCCallDelegate 第 174 行等创建参数）
```

## 四、公开 API

| 签名 | 说明 | 位置 |
|---|---|---|
| `GetId() const` | 实例 ID（inline） | 第 214 行 |
| `GetMaxConnectionCount() const` | 最大连接数 | 第 217 行 |
| `IsServer() const` | 是否服务器（inline） | 第 220 行 |
| `AllowObjectReplication()` | 是否允许对象复制（inline） | 第 229 行 |
| `NetUpdate(float)` | 复制系统主驱动 | 第 238 行 |
| `PreReceiveUpdate()` / `PostReceiveUpdate()` | 接收周期钩子 | 第 247 / 250 行 |
| `AddConnection(uint32, ...)` / `RemoveConnection(uint32)` | 连接管理 | 第 270 / 276 行 |
| `SetReplicationView(uint32, const UE::Net::FReplicationView&)` | 每连接视图 | 第 324 行 |
| `SetPrioritizer(...)` | 设置对象优先级器 | 第 346 行 |
| `GetDataStream(uint32, FName)` | 取数据流 | 第 374 行 |
| `RegisterNetBlobHandler(UNetBlobHandler*)` | 注册 NetBlob 处理器 | 第 406 行 |
| `SendRPC(...)` | 发送 RPC | 第 426 行 |
| `GetReplicationBridge() const` | 取复制桥（`UObjectReplicationBridge*`） | 第 452 行 |
| `GetNetTokenStore()` | 网络 Token 存储 | 第 462 行 |
| `IsNetRefHandleAssigned(...) const` | 句柄是否已分配 | 第 482 行 |
| `CreateGroup(FName)` | 创建对象组 | 第 508 行 |
| `CreateFilter(...)` | 创建对象过滤器 | 第 590 行 |
| `ForceNetUpdate(FNetRefHandle)` | 强制复制 | 第 781 行 |

> 反射属性：`ReplicationBridge`（`UPROPERTY(transient)`，第 903-904 行）、`NetRefHandleGenerator`（`UPROPERTY()`，第 919-920 行）。

## 五、扩展点

### 5.1 可覆写虚函数

**类内 `virtual` = 0 处**（实测；即 `UReplicationSystem` **不是**继承扩展点设计）。实际扩展路径：

| 机制 | 说明 | 位置 |
|---|---|---|
| 工厂生命周期 | `UE::Net::FReplicationSystemFactory`：`CreateReplicationSystem(...)`（第 939 行）/ `DestroyReplicationSystem(...)`（第 945 行）/ 静态 `ReplicationSystems`（第 965 行） | 第 931-966 行 |
| 注册式子对象 | `RegisterNetBlobHandler`（406）、`SetPrioritizer`（346）、`CreateFilter`（590） | 见左 |
| 委托 | `GetDelegates()`（第 847 行，`FReplicationSystemDelegates&`） | 第 847 行 |
| friend 白名单 | `FReplicationSystemFactory`（第 868 行）、`UNetDriver`（第 880 行） | 见左 |

### 5.2 不建议覆写的内部虚函数

无（类内无虚函数）。

## 六、生命周期

- 由 **工厂创建**：`FReplicationSystemFactory::CreateReplicationSystem(FReplicationSystemParams)`（第 939 行）；参数结构含对象↔句柄映射委托（第 200 / 210 行）。
- 驱动：`NetUpdate`（第 238 行）/ `PreReceiveUpdate` / `PostReceiveUpdate`（第 247 / 250 行）；对象经 `UReplicationBridge` 挂入（`GetReplicationBridge` 第 452 行）。
- 与 NetDriver 集成：`friend UNetDriver`（第 880 行）——网络驱动创建并驱动复制系统。

## 七、派生类（范围内）

搜索边界：派生类搜索**仅覆盖本版纳入范围的 292 个模块**（Runtime 291 个 + `EnhancedInput` 插件）。搜索模式 `\bpublic\s+UReplicationSystem\b`（`*.h`）：Runtime **0 命中**；EnhancedInput **0**（另以 `Engine/Source` 全树 + `*.h/*.cpp/*.inl` 复核仍为 0）。

| 派生类 | — |
|---|---|
| （无） | 叶子类；扩展经工厂参数与注册式子对象 |

## 取数说明

| 断言 | 取数方式（相对基准：`Engine/Source`） |
|---|---|
| 文件 996 行、类体 78-921 | `[System.IO.File]::ReadAllLines(...).Count` + `^};` 检索 |
| 类内 `virtual` = 0 | `Select-String -Pattern 'virtual'` 全匹配（同目录 `ReplicationBridge.h` 21 处为阳性对照） |
| 派生统计：0 命中 | `Select-String -Pattern '\bpublic\s+UReplicationSystem\b'`（`*.h`） |
| 全部行号引用 | 2026-10-10 对 UE 5.8.3 源码本机逐条核对 |

## 相关文档

- `modules/IrisCore-结构.md` —— UReplicationSystem 所在模块（同批产出）
- `types/FPacketDataView.md` —— 同批类型
- `modules/NetCore-结构.md` —— 基础序列化层（批 7）
- `types/UObject.md` —— 基类链终点（已校验）
