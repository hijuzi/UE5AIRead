> 引擎版本：UE 5.8.3 (Build 58210709)
> 源码根：Engine/Source
> 生成技能：ue-type-api v1.0
> 生成时间：2026-10-10
> 校验状态：已校验（2026-10-11）

# FPacketDataView

## 一、类型概览

| 项 | 值 |
|---|---|
| 全限定名 | `FPacketDataView`（全局命名空间） |
| 定义位置 | `Engine/Source/Runtime/Net/Common/Public/Net/Common/Packets/PacketView.h` |
| 类型 | 类（**纯 C++ 值类型**；受限数据包数据视图） |
| 反射宏 | 无（`UCLASS` / `USTRUCT` / `GENERATED` 实测 0 命中） |
| 导出策略 | 无（模块内不存在任何 `*_API` 宏） |
| 所属模块 | `NetCommon`（`Engine/Source/Runtime/Net/Common`） |
| 说明 | **NetCommon 无类体 ≥60 行的达标类型**（最大者即本类，类体 59 行）——本版按放宽判据选取并如实标注（详见「取数说明」） |

## 二、继承链

**无基类**（第 47 行 `class FPacketDataView` 后直接 `{`）——链根（纯 C++ 类型，非 `UObject` 体系）。

## 三、声明片段

```
文件：Engine/Source/Runtime/Net/Common/Public/Net/Common/Packets/PacketView.h
行 43-47：/** Represent a restricted view of packet data, with bit-based size, allowing data to be
          reassigned to point elsewhere, but not allowing the data being pointed to, to be modified. */
          class FPacketDataView

文件：Engine/Source/Runtime/Net/Common/Public/Net/Common/Packets/PacketView.h
行 105：类体结束（};；文件 139 行）
```

## 四、公开 API

| 签名 | 说明 | 位置 |
|---|---|---|
| `FPacketDataView(const uint8*, int32, ECountUnits::BitType)` | 按位大小构造（指向外部数据，不接管所有权） | 第 66 行 |
| `FPacketDataView(const uint8*, int32, ECountUnits::ByteType)` | 按字节大小构造 | 第 79 行 |
| `GetData() const` | 只读数据指针 | 第 85 行 |
| `GetMutableData() const` | 数据指针（可变版） | 第 91 行 |
| `NumBits() const` | 位大小 | 第 96 行 |
| `NumBytes() const` | 字节大小 | 第 101 行 |

> 语义（源码文档注释，第 43-46 行）：**可重指向、不可改写所指数据**——数据包处理层的只读视图抽象。
> **不存在**：`NumBits` 之外的写接口；本类不含反射与虚函数（见第五节）。

## 五、扩展点

### 5.1 可覆写虚函数

**无**——类内 `virtual` 实测 0 处（纯函数值类型，无虚表设计）。

### 5.2 不建议覆写的内部虚函数

无。

## 六、生命周期

- **值语义**：作为参数/局部对象传递；指向的包缓冲由调用方（Sockets / PacketHandler 栈）持有——视图自身不管理内存。
- 典型消费方：`PacketHandler`（`PacketHandler.cpp` 第 586-587 行读取 `DataView.NumBits()`）；`FReceivedPacketView`（同文件第 112 行）携带本视图。

## 七、派生类（范围内）

搜索边界：派生类搜索**覆盖 Runtime 291 个模块 + `EnhancedInput` 插件全部 3 个模块（共 294 个模块）**。搜索模式 `\bpublic\s+FPacketDataView\b`（`*.h`）：Runtime **0 命中**；EnhancedInput **0**。

| 派生类 | — |
|---|---|
| （无） | 值类型，无派生 |

## 取数说明

| 断言 | 取数方式（相对基准：`Engine/Source`） |
|---|---|
| 搜索边界 294 个模块（Runtime 291 + `EnhancedInput` 插件 3） | `[M]` 插件 3 个模块（含白名单外的 `InputBlueprintNodes` / `InputEditor`）：`(Get-ChildItem "Engine/Plugins/EnhancedInput/Source" -Directory).Count` → 3；Runtime 291 见 `_meta/inventory.md` |
| 文件 139 行、类体 47-105 | `[M]` `[System.IO.File]::ReadAllLines("Engine/Source/Runtime/Net/Common/Public/Net/Common/Packets/PacketView.h").Count`（同文件 `^};` 检索定类体区间） |
| 类内 `virtual` = 0、派生 0 命中 | `[H]` `Select-String -Pattern 'virtual'` / `'\bpublic\s+FPacketDataView\b'`（`*.h`） |
| 代表类型放宽判据 | NetCommon 全部类型类体 < 60 行（最大 `FPacketDataView` 59 行）——由模块侦察枚举全部类型并测量类体行数后选定；判据放宽记录见 `docs/_meta/quality-report.md` 与 `modules/NetCommon-结构.md` 第六节 |
| 全部行号引用 | 2026-10-10 对 UE 5.8.3 源码本机逐条核对 |

## 相关文档

- `modules/NetCommon-结构.md` —— FPacketDataView 所在模块（同批产出）
- `types/UReplicationSystem.md` —— 同批类型
- `modules/RHI-结构.md` —— 另一"无导出宏 / 纯 C++ 类型"参照
- `modules/NetCore-结构.md` —— 网络底层核心（批 7）

## 更新记录

- 2026-10-11 搜索边界更正：派生搜索实覆盖 **294** 个模块（Runtime 291 + `EnhancedInput` 插件 3），原文误作"纳入范围的 292 个模块"（292 是白名单口径，搜索实际连 `InputBlueprintNodes` / `InputEditor` 一并覆盖，本文件命中的插件侧结果即来自 `InputEditor`）；同时在「取数说明」补入该边界取数方式（`convention.md` 4.2）

- 2026-10-11 按规范 4.2.1 为「取数说明」各行加方法标记（`[M]`/`[R]`/`[H]`）；`[M]` 行把原文省略成 `(...)` 的路径补全为白名单可执行命令，现由 `ue-doc-verify` 逐条实际执行比对
