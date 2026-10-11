> 引擎版本：UE 5.8.3 (Build 58210709)
> 源码根：Engine/Source
> 生成技能：ue-module-structure v1.0
> 生成时间：2026-10-10
> 校验状态：已校验（2026-10-11）

# NetCommon 模块结构

## 一、模块定位

| 项 | 值 |
|---|---|
| 路径 | `Engine/Source/Runtime/Net/Common`（**模块名 `NetCommon`**；`Net/` 三兄弟中最小） |
| 类别 | Runtime |
| 规模 | 5 文件 / 3 头文件（模块极小，全清单见下） |
| 分层 | 框架 |
| 一句话职责 | 网络公共层：数据包视图（`FPacketDataView` / `FReceivedPacketView`）、数据包特征（`FOutPacketTraits` / `FInPacketTraits`）与套接字错误码（`ESocketErrors`）——Sockets / PacketHandler / Engine 网络栈共享的基础类型 |

## 二、目录结构（全清单）

```
Net/Common/
├── NetCommon.Build.cs                                  # 20 行、0 处 if 分支
├── Private/Net/Common/NetCommonModule.cpp              # 唯一实现（第 7-8 行"Force export"强制包含 PacketTraits.h）
└── Public/Net/Common/
    ├── Packets/PacketTraits.h     # FOutPacketTraits(20) / FInPacketTraits(46)，均在**全局命名空间**
    ├── Packets/PacketView.h       # FPacketBufferView(18) / FPacketDataView(47) / FReceivedPacketView(112) / FPacketTimestamp(134)
    └── Sockets/SocketErrors.h     # ESocketErrors(8)（62 行枚举）
```

- 无 `Internal/`、无 `Tests/`；公开头间依赖：`PacketView.h` 反向包含另两个头（第 6-7 行）。

## 三、依赖关系

### 3.1 无条件依赖

| 模块 | 类型 | Build.cs 行 | 说明 |
|---|---|---|---|
| `Core` | 公开依赖 | 14 | **唯一依赖** |

> 警告等级：`UnsafeTypeCastWarningLevel = WarningLevel.Error;`（第 18 行）。
> 辅助函数检查：**无**——无未展开依赖。

### 3.2 平台与配置条件依赖

**无**——`NetCommon.Build.cs` 全文 **0 处 `if` 分支**（实测）。

### 3.3 第三方静态依赖

调用 **0 处**——无第三方静态依赖。

## 四、对外暴露面

> 公开侧共 3 个 `.h`（全列）。

| 头文件 | 提供的能力 |
|---|---|
| `Engine/Source/Runtime/Net/Common/Public/Net/Common/Packets/PacketView.h` | `FPacketDataView`（第 47 行）→ `types/FPacketDataView.md`；含 `FReceivedPacketView`（112）/ `FPacketBufferView`（18）/ `FPacketTimestamp`（134） |
| `Engine/Source/Runtime/Net/Common/Public/Net/Common/Packets/PacketTraits.h` | `FOutPacketTraits`（第 20 行）/ `FInPacketTraits`（第 46 行），均在**全局命名空间**（`namespace UE::Net` 仅包住一行前置声明） |
| `Engine/Source/Runtime/Net/Common/Public/Net/Common/Sockets/SocketErrors.h` | `ESocketErrors`（第 8 行，62 行枚举；Runtime 内 17 个文件引用（Editor 另 2 个）） |

> **模块无任何导出宏**（不存在 `NETCOMMON_API`）；类型为纯 C++（无反射）。跨模块可见性经 include path 传递：`Sockets` 模块公开引用；Engine 模块的 Build.cs 以 `PublicIncludePathModuleNames` 引用（**仅包含路径、非链接依赖**）。

## 五、模块生命周期

```
文件：Engine/Source/Runtime/Net/Common/Private/Net/Common/NetCommonModule.cpp
行 10：class FNetCommonModule : public IModuleInterface
行 28：IMPLEMENT_MODULE(FNetCommonModule, NetCommon);
```

- **`StartupModule()`**（第 13-15 行）与 **`ShutdownModule()`**（第 17-19 行）**均为空实现**。
- **`SupportsDynamicReloading` 显式覆写为 `false`**（第 21-23 行）——已产出模块中第 4 个显式覆写者（Renderer=`true`、NetCore=`false`、IrisCore=`false`、本模块=`false`）。
- 文件级要点：第 7-8 行 `// Force export` + `#include "Net/Common/Packets/PacketTraits.h"`。

## 六、关键约定与坑

1. **无导出宏、无反射**：模块内不存在任何 `*_API` 宏；跨模块使用靠 include path（Engine 未把 NetCommon 加入链接依赖）。
2. **无达标代表类型**：全部 `class/struct` 类体 < 60 行（最大者 `FPacketDataView` 59 行）——本版按放宽判据取 `FPacketDataView` 成篇（详见类型文档「取数说明」）。
3. **Net 三兄弟**：`Core`（NetCore，公开依赖 NetCommon）、`Common`（本模块）、`Iris`（IrisCore）——模块名与目录名不一致的情况在这里连续出现。
4. **数字口径**：`NetCommon.Build.cs` 20 行（`ReadAllLines`）、0 处 `if`、0 处三方静态调用；模块合计 5 个文件 / 3 个头文件。取数命令见「取数说明」。

## 取数说明

以下命令的相对基准为 `Engine/Source`（实际路径按 `_meta/convention.md` 的本机环境块解析）：

| 断言 | 取数方式 |
|---|---|
| `SupportsDynamicReloading`：本模块为已产出模块中第 **4** 个显式覆写者 | `[H]` 逐模块核对创建函数：`Renderer`(true) / `NetCore`(false) / `IrisCore`(false) / **本模块**(false) = 第 **4** 个 |
| 5 文件 / 3 头文件 | `[M]` 引擎磁盘递归计数：`(Get-ChildItem "Runtime/Net/Common" -Recurse -File).Count` 得文件数；`(Get-ChildItem "Runtime/Net/Common" -Recurse -File -Filter *.h).Count` 得头文件数（同 `_meta/engine-modules.json` 口径） |
| Build.cs 20 行、0 处 `if`、0 处三方静态调用 | `[M]` `[System.IO.File]::ReadAllLines("Runtime/Net/Common/NetCommon.Build.cs").Count`；`Select-String "Runtime/Net/Common/NetCommon.Build.cs" -Pattern '\bif\s*\(' -AllMatches`；`Select-String "Runtime/Net/Common/NetCommon.Build.cs" -Pattern 'AddEngineThirdPartyPrivateStaticDependencies' -AllMatches` |
| 全部行号引用 | 2026-10-10 对 UE 5.8.3 源码本机逐条核对 |

## 相关文档

- `types/FPacketDataView.md` —— 本模块代表类型（同批产出）
- `modules/NetCore-结构.md` —— 公开依赖本模块（批 7）
- `modules/IrisCore-结构.md` —— 同批模块
- `modules/RHI-结构.md` —— 另一小模块参照（无自定义模块类 / 极简入口）

## 更新记录

- 2026-10-11 「取数说明」补入 1 行计数断言取数方式（`convention.md` 4.2 覆盖要求）

- 2026-10-11 按规范 4.2.1 为「取数说明」各行加方法标记（`[M]`/`[R]`/`[H]`）；`[M]` 行把原文省略成 `(...)` 的路径补全为白名单可执行命令，现由 `ue-doc-verify` 逐条实际执行比对
