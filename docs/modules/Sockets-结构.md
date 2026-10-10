> 引擎版本：UE 5.8.3 (Build 58210709)
> 源码根：Engine/Source
> 生成技能：ue-module-structure v1.0
> 生成时间：2026-10-10
> 校验状态：已校验（2026-10-10）

# Sockets 模块结构

## 一、模块定位

| 项 | 值 |
|---|---|
| 路径 | `Engine/Source/Runtime/Sockets` |
| 类别 | Runtime |
| 规模 | 49 文件 / 30 头文件（`_meta/engine-modules.json` 2026-10-10 口径；公开侧 15 + `Private/` 15） |
| 分层 | 网络 |
| 一句话职责 | 平台套接字抽象层：`FSocket`（虚基类）、`ISocketSubsystem`（平台子系统工厂）、`FInternetAddr`（地址）、BSD 套接字实现与 Windows / Unix / Mac / Android / IOS 平台目录、多通道 TCP 与网络消息设施 |

## 二、目录结构

```
Sockets/
├── Sockets.Build.cs   # 模块构建脚本（21 行、0 处 if 分支）
├── Public/            # 公开侧 15 个 .h（全部顶层、无子目录）
│   ├── Sockets.h / SocketSubsystem.h / SocketTypes.h / SocketSubsystemModule.h / SocketSubsystemPackage.h
│   ├── IPAddress.h / AddressInfoTypes.h / IPAddressAsyncResolve.h
│   ├── MultichannelTCP.h / MultichannelTcpSender.h / MultichannelTcpReceiver.h /
│   │   MultichannelTcpSocket.h / MultichannelTcpGlobals.h
│   └── NetworkMessage.h / ServerTOC.h
└── Private/           # 6 个子目录（Android/ BSDSockets/ IOS/ Mac/ Unix/ Windows/）+ 15 .h + 18 .cpp
```

- 无 `Internal/`、无 `Tests/`；无聚合头（`Sockets.h` 自身直接定义 `FSocket`，非转发伞头）。

## 三、依赖关系

### 3.1 无条件依赖

| 模块 | 类型 | Build.cs 行 | 说明 |
|---|---|---|---|
| `NetCommon` | 公开包含路径 | 9 | **仅包含路径** |
| `Core` | 私有依赖 | 13 | |
| `NetCommon` | 私有依赖 | 14 | **重复项**（第 9 行包含路径 + 第 14 行链接依赖） |

> `PublicDefinitions.Add("SOCKETS_PACKAGE=1");`（第 17 行）；警告等级第 19 行。
> 辅助函数检查：**无**——无未展开依赖。

### 3.2 平台与配置条件依赖

**无**——全文 **0 处 `if` 分支**（实测；平台差异下沉到 `Private/` 的平台目录与 BSD 实现）。

### 3.3 第三方静态依赖

调用 **0 处**——无第三方静态依赖。

## 四、对外暴露面

> 公开侧共 15 个 `.h`；核心如下。

| 头文件 | 提供的能力 |
|---|---|
| `Engine/Source/Runtime/Sockets/Public/Sockets.h` | `FSocket`（第 18 行，`: TSharedFromThis<FSocket, ESPMode::ThreadSafe>`）→ `types/FSocket.md` |
| `Engine/Source/Runtime/Sockets/Public/SocketSubsystem.h` | `ISocketSubsystem`（第 57 行；`Get()` 第 64 行；`CreateSocket` 主纯虚第 128 行；`DestroySocket` 第 168 行）；`FUniqueSocket` 别名（第 51 行）、`FSocketDeleter`（第 537 行） |
| `Engine/Source/Runtime/Sockets/Public/SocketSubsystemModule.h` | `FSocketSubsystemModule`（第 12 行） |
| `Engine/Source/Runtime/Sockets/Public/SocketTypes.h` | 协议/枚举（`FNetworkProtocolTypes` 第 25 行、`ESocketReceiveFlags` 第 52 行、`ESocketWaitConditions` 第 79 行） |
| `Engine/Source/Runtime/Sockets/Public/IPAddress.h` | `FInternetAddr`（第 21 行） |
| `Engine/Source/Runtime/Sockets/Public/MultichannelTcpSender.h` 等 4 个 | 多通道 TCP |
| `Engine/Source/Runtime/Sockets/Public/NetworkMessage.h` | 网络消息（`NFS_Messages` / `NFS_Channels` 命名空间） |

> **`Public/FSocket.h` 不存在**——`FSocket` 定义在 `Sockets.h`（第 18 行）；`SocketTypes.h` 仅前置于第 11 行。

## 五、模块生命周期

```
文件：Engine/Source/Runtime/Sockets/Private/SocketSubsystemModule.cpp
行 9：IMPLEMENT_MODULE( FSocketSubsystemModule, Sockets );
```

- **模块类**：`FSocketSubsystemModule : public IModuleInterface`（`Public/SocketSubsystemModule.h` 第 12 行）。
- **`StartupModule()`**（声明第 58 行；实现 `SocketSubsystemModule.cpp` 第 114-119 行）：创建默认平台子系统 `DefaultSocketSubsystem = CreateSocketSubsystem( *this );`（第 119 行；平台 extern 工厂声明第 12 行）；子系统模块懒加载（头文件第 51-57 行 `IsModuleLoaded`/`LoadModule`）。
- **`ShutdownModule()`**（声明第 64 行；实现 `SocketSubsystemModule.cpp` 第 122-138 行）：`DestroySocketSubsystem( *this )`（第 125 行）→ 遍历各子系统 `Shutdown()`（第 131 行）→ `UnloadModule`（第 136 行）。
- **`SupportsDynamicReloading` 显式覆写为 `false`**（头文件第 71-74 行）——已产出模块中**第 5 个显式覆写者**（Renderer=`true`；NetCore/IrisCore/NetCommon=`false`）；另有 `SupportsAutomaticShutdown` 显式 `false`（第 81-84 行）。

## 六、关键约定与坑

1. **`Public/FSocket.h` 不存在**（实测 False）——`FSocket` 在 `Public/Sockets.h` 第 18 行；`SocketTypes.h` 只有前置声明。
2. **平台实现全部在 `Private/`**（BSDSockets 为通用实现，另有 Android/IOS/Mac/Unix/Windows 六个平台目录）。
3. **双 `false` 覆写**：动态热重载与自动关停均显式关闭（第 71-84 行）。
4. **`NetCommon` 双引用**（包含路径 + 私有依赖）——Sockets 是 NetCommon 的消费者（与本套件 NetCommon 文档互链）。
5. **数字口径**：`Sockets.Build.cs` 21 行（`ReadAllLines`）、0 处 `if`、0 处三方静态调用；公开侧 15 个 `.h`（模块合计 30）。取数命令见「取数说明」。

## 取数说明

以下命令的相对基准为 `Engine/Source`（实际路径按 `_meta/convention.md` 的本机环境块解析）：

| 断言 | 取数方式 |
|---|---|
| 49 文件 / 30 头文件 | `_meta/engine-modules.json` 中 `Module -eq 'Sockets'` 行的 `Files`、`Headers` 字段；公开 15 + Private 15 复核 |
| 公开侧 15 个 `.h` | `(Get-ChildItem "Runtime/Sockets/Public" -Recurse -File -Filter *.h).Count` |
| Build.cs 21 行、0 处 `if`、0 处三方静态调用 | `[System.IO.File]::ReadAllLines(...).Count`；`\bif\s*\(` 与 `AddEngineThirdPartyPrivateStaticDependencies` 全匹配计数 |
| 全部行号引用 | 2026-10-10 对 UE 5.8.3 源码本机逐条核对 |

## 相关文档

- `types/FSocket.md` —— 本模块代表类型（同批产出）
- `modules/PacketHandler-结构.md` —— 同批模块（消费方之一）
- `modules/NetCommon-结构.md` —— 被本模块引用的公共层（批 10）
- `modules/NetCore-结构.md` —— 网络栈底层（批 7）
