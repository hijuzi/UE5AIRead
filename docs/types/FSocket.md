> 引擎版本：UE 5.8.3 (Build 58210709)
> 源码根：Engine/Source
> 生成技能：ue-type-api v1.0
> 生成时间：2026-10-10
> 校验状态：已校验（2026-10-11）

# FSocket

## 一、类型概览

| 项 | 值 |
|---|---|
| 全限定名 | `FSocket`（全局命名空间） |
| 定义位置 | `Engine/Source/Runtime/Sockets/Public/Sockets.h`（**不是** `FSocket.h`——该文件实测不存在） |
| 类型 | 类（纯 C++ 抽象基类；非 UObject；平台套接字接口） |
| 导出策略 | 逐成员 `SOCKETS_API`（12 处）；类声明行无宏 |
| 所属模块 | `Sockets`（`Engine/Source/Runtime/Sockets`） |

## 二、继承链

```
FSocket（Sockets.h 第 18 行，`: public TSharedFromThis<FSocket, ESPMode::ThreadSafe>`）
  └─ TSharedFromThis（Engine/Source/Runtime/Core/Public/Templates/SharedPointer.h 第 1706 行，`: private UE::Core::Private::FSharedFromThisBase`——注意为 private 继承）
       └─ FSharedFromThisBase（Engine/Source/Runtime/Core/Public/Templates/SharedPointerInternals.h 第 858 行；链根，空结构）
```

## 三、声明片段

```
文件：Engine/Source/Runtime/Sockets/Public/Sockets.h
行 18：class FSocket : public TSharedFromThis<FSocket, ESPMode::ThreadSafe>
行 494：类体结束（};；文件 494 行）
```

## 四、公开 API

| 签名 | 说明 | 位置 |
|---|---|---|
| `FSocket()` / `FSocket(ESocketType, const FString&, const FName&)` | 构造（`SOCKETS_API`） | 第 34 / 75 行 |
| `virtual ~FSocket()`（`SOCKETS_API`） | 虚析构 | 第 78 行 |
| `virtual Shutdown(ESocketShutdownMode) = 0` | 关闭连接方向 | 第 86 行 |
| `virtual Close() = 0` | 关闭套接字 | 第 93 行 |
| `virtual ReleaseNativeSocket()`（非纯虚，默认 0） | 交出原生句柄 | 第 101 行 |
| `virtual Bind(const FInternetAddr&) = 0` | 绑定 | 第 109 行 |
| `virtual Connect(const FInternetAddr&) = 0` | 连接 | 第 117 行 |
| `virtual Listen(int32) = 0` | 监听 | 第 125 行 |
| `virtual WaitForPendingConnection(bool&, const FTimespan&) = 0` | 等待入连接 | 第 135 行 |
| `virtual HasPendingData(uint32&) = 0` | 是否有待读数据 | 第 154 行 |
| `virtual Accept(...)`（2 重载，均纯虚） | 接受连接 | 第 162 / 171 行 |
| `virtual SendTo(...)`（`SOCKETS_API`，非纯虚） | 无连接发送 | 第 181 行 |
| `virtual Send(const uint8*, int32, int32&)`（`SOCKETS_API`，非纯虚） | 发送 | 第 190 行 |
| `virtual RecvFrom(...)`（`SOCKETS_API`，非纯虚） | 带源地址接收 | 第 206 行 |
| `virtual Recv(uint8*, int32, int32&, ESocketReceiveFlags::Type)`（`SOCKETS_API`，非纯虚） | 接收 | 第 221 行 |
| `virtual Wait(ESocketWaitConditions::Type, FTimespan) = 0` | 条件等待 | 第 241 行 |
| `virtual GetPeerAddress(FInternetAddr&) = 0` | 对端地址 | 第 263 行 |
| `virtual SetNonBlocking(bool) = 0` / `virtual SetNoDelay(bool) = 0` | 选项 | 第 271 / 287 行 |
| 选项族（广播/多播/缓冲/延迟） | `SetBroadcast`(279)、`JoinMulticastGroup`(298/310)、`LeaveMulticastGroup`(319/329)、`SetMulticastLoopback`(342)、`SetMulticastTtl`(355)、`SetMulticastInterface`(366)、`SetReuseAddr`(374)、`SetLinger`(383)、`SetRecvErr`(391)、`SetSendBufferSize`(400)、`SetReceiveBufferSize`(409) | 见左 |
| 只读访问器（inline 非虚） | `GetSocketType()`(468)、`GetDescription()`(479)、`GetProtocol()`(490) | 见左 |

## 五、扩展点

### 5.1 可覆写虚函数（类内 40 处；**29 纯虚 + 11 非纯虚**）

| 组 | 成员（行号） |
|---|---|
| 生命周期/连接 | `~FSocket`(78)、`Shutdown`(86)、`Close`(93)、`Bind`(109)、`Connect`(117)、`Listen`(125)、`WaitForPendingConnection`(135)、`Wait`(241) |
| 收发/接受 | `HasPendingData`(154)、`Accept`(162/171 纯虚)；`ReleaseNativeSocket`(101)、`SendTo`(181)、`Send`(190)、`RecvFrom`(206)、`Recv`(221)、`RecvMulti`(232)、`RecvFromWithPktInfo`(460)（非纯虚，基类提供默认实现） |
| 状态/地址 | `GetConnectionState`(248)、`GetAddress`(255)、`GetPeerAddress`(263)、`GetPortNo`(435) |
| 选项 | `SetNonBlocking`(271)、`SetBroadcast`(279)、`SetNoDelay`(287)、`SetMulticastLoopback`(342)、`SetMulticastTtl`(355)、`SetMulticastInterface`(366)、`SetReuseAddr`(374)、`SetLinger`(383)、`SetRecvErr`(391)、`SetSendBufferSize`(400)、`SetReceiveBufferSize`(409)、`SetRetrieveTimestamp`(417)、`SetSendSegmentationOffloadSize`(427)、`SetIpPktInfo`(443) |
| 多播组 | `JoinMulticastGroup`(298/310)、`LeaveMulticastGroup`(319/329) |

### 5.2 不建议覆写的内部虚函数

无单列——**全部虚函数都是平台实现者（`FSocketBSD` 等）的义务面**：29 条纯虚构成平台套接字的完整契约。

## 六、生命周期

- **创建/销毁配对**：创建经 `ISocketSubsystem::CreateSocket`（`SocketSubsystem.h` 第 128 行主纯虚；第 140 行另有 `CreateUniqueSocket` 便捷函数）；销毁经 `DestroySocket`（第 168 行）——`FSocketDeleter`（第 537 行）+ `FUniqueSocket` 别名（第 51 行）封装此语义；源码注释警告 **SocketSubsystem 必须比其创建的套接字存活更久**。
- **共享语义**：经 `TSharedFromThis`（第 18 行）以 `TSharedPtr` 传递。

## 七、派生类（范围内）

搜索边界：派生类搜索**覆盖 Runtime 291 个模块 + `EnhancedInput` 插件全部 3 个模块（共 294 个模块）**。搜索模式 `\bpublic\s+FSocket\b`（`*.h`）：Runtime **1 命中 / 1 文件**；EnhancedInput **0**。

| 派生类 | 位置 |
|---|---|
| `FSocketBSD : public FSocket` | `Engine/Source/Runtime/Sockets/Private/BSDSockets/SocketsBSD.h` 第 43-44 行（BSD 通用实现） |

> 范围外（Plugins，仅记录 5 处）：`FSteamSocket`（SteamSockets）、`FSocketSteam`（SocketSubsystemSteamIP）、`FSocketEOS`（SocketSubsystemEOS）、`FSocketBeaconUnitTest`（OnlineSubsystemUtils 测试）、`FPlayFabPartySocket`（PlayFabParty）。

## 取数说明

| 断言 | 取数方式（相对基准：`Engine/Source`） |
|---|---|
| 搜索边界 294 个模块（Runtime 291 + `EnhancedInput` 插件 3） | `[M]` 插件 3 个模块（含白名单外的 `InputBlueprintNodes` / `InputEditor`）：`(Get-ChildItem "Engine/Plugins/EnhancedInput/Source" -Directory).Count` → 3；Runtime 291 见 `_meta/inventory.md` |
| 文件 494 行、类体 18-494 | `[M]` `[System.IO.File]::ReadAllLines("Engine/Source/Runtime/Sockets/Public/Sockets.h").Count`（同文件 `^};` 检索定类体区间） |
| `virtual` 40 处（29 纯虚 + 11 非纯虚） | `[H]` content 模式逐行枚举 + 全文件通读交叉核对 |
| 派生统计：Runtime 1 / EnhancedInput 0 | `[H]` `Select-String -Pattern '\bpublic\s+FSocket\b'`（`*.h`） |
| 全部行号引用 | 2026-10-10 对 UE 5.8.3 源码本机逐条核对 |

## 相关文档

- `modules/Sockets-结构.md` —— FSocket 所在模块（同批产出）
- `types/PacketHandler.md` —— 同批类型
- `modules/NetCommon-结构.md` —— 包视图/特征层（批 10）
- `types/FRHIResource.md` —— 另一"平台抽象基类"参照（批 4）

## 更新记录

- 2026-10-11 搜索边界更正：派生搜索实覆盖 **294** 个模块（Runtime 291 + `EnhancedInput` 插件 3），原文误作"纳入范围的 292 个模块"（292 是白名单口径，搜索实际连 `InputBlueprintNodes` / `InputEditor` 一并覆盖，本文件命中的插件侧结果即来自 `InputEditor`）；同时在「取数说明」补入该边界取数方式（`convention.md` 4.2）

- 2026-10-11 按规范 4.2.1 为「取数说明」各行加方法标记（`[M]`/`[R]`/`[H]`）；`[M]` 行把原文省略成 `(...)` 的路径补全为白名单可执行命令，现由 `ue-doc-verify` 逐条实际执行比对
