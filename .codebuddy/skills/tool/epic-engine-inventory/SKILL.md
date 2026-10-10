---
name: epic-engine-inventory
description: 盘点本机通过 Epic Games Launcher 安装的 Unreal Engine 引擎：读取 Launcher 的 Manifest 清单，输出每个引擎的版本号与安装目录，并可校验磁盘上的引擎是否真实可用。当用户问"装了几个 UE 引擎""UE 装在哪""引擎安装路径是什么""哪个版本可用""找不到引擎版本"，双击 .uproject 提示引擎版本缺失，需要为工程关联或切换引擎版本，或需要把引擎路径喂给打包/构建脚本时，都应使用本技能。仅适用于 Windows（macOS/Linux 的清单路径不同）；不用于安装、下载、卸载引擎，也不用于引擎内的 C++ 编码问题。Use when listing installed Unreal Engine versions or locating their installation directories.
metadata:
  category: tool
  version: "1.1"
  platform: Windows
---

# Epic 引擎安装盘点

读取 Epic Games Launcher 的 Manifest 清单，列出本机安装的 Unreal Engine **引擎本体**，输出每个引擎的版本号与安装目录。

## 关键约束（先看这三条）

1. **必须按 `TechnicalType` 过滤。** 只有 `engines/ue5,engines` 是引擎；`plugins/engine,codeproject` 是插件（Fab、Quixel Bridge、Figma、蓝图助手等）。不加过滤会把插件当引擎——Epic 会把插件装进与引擎同级的目录，磁盘上因此会出现"名字像引擎、里面没有引擎"的目录。**本机实测**：`E:\EpicGames` 下有 4 个 `UE_*` 目录，但引擎只有 3 个——`UE_5.6` 目录存在却没有 `UnrealEditor.exe`，它只是插件（FabPlugin_5.6、QuixelBridge_5.6 等）的落点。
2. **只扫清单目录顶层的 `*.item`，不要递归进 `Pending\`。** 那里的条目是尚未应用的安装/更新，混进来会重复计数。
3. **找不到清单目录时如实告知用户**（本机没装 Launcher，或从未装过引擎），不要臆造路径、也不要凭目录名推测。

脚本已实现以上三条。只有在必须改用内联命令时才需手动遵守。

## 适用判断

- **操作系统**：仅 Windows。清单位于 `%ProgramData%\Epic\EpicGamesLauncher\Data\Manifests\`。macOS 路径不同（`~/Library/Application Support/Epic/...`），本技能未覆盖。
- **执行前确认清单目录存在**：

```powershell
Test-Path "$env:ProgramData\Epic\EpicGamesLauncher\Data\Manifests"
```

返回 `False` 时停止，直接告知用户本机没有 Launcher 的安装记录。

- **不适用**：安装 / 下载 / 卸载引擎（引导用户去 Launcher 操作），以及引擎内的 C++ 开发问题。若用户只是想知道"某个 `.uproject` 用什么引擎打开"，仍先跑本技能拿到本地引擎名单再比对。

## 执行步骤

### Step 1: 选择输出模式

| 场景 | 命令 |
|---|---|
| 只想看装了哪些引擎（默认） | `.\scripts\list-engines.ps1` |
| 引擎疑似被删或损坏，要确认可用性 | `.\scripts\list-engines.ps1 -Verify` |
| 输出给其他脚本或工具消费 | `.\scripts\list-engines.ps1 -AsJson` |

脚本路径相对本技能目录。

### Step 2: 运行

```powershell
.\scripts\list-engines.ps1 -Verify
```

环境不允许执行脚本文件时（如 ExecutionPolicy 受限），改用内联等价命令：

```powershell
Get-ChildItem "$env:ProgramData\Epic\EpicGamesLauncher\Data\Manifests\*.item" |
    ForEach-Object { Get-Content $_.FullName -Raw -Encoding UTF8 | ConvertFrom-Json } |
    Where-Object { $_.TechnicalType -eq 'engines/ue5,engines' } |
    Select-Object AppName,
                  @{n='Version';e={($_.AppVersionString -split '\+')[0]}},
                  InstallLocation |
    Format-Table -AutoSize
```

> 读清单必须带 `-Encoding UTF8`。清单是 UTF-8 文本，用 `-Encoding Unicode`（UTF-16）会报 `无效的 JSON 基元`。

### Step 3: 解读输出

见下方"结果解读"。

## 输出格式

默认三列，按引擎名排序：

| 列 | 来源字段 | 说明 |
|---|---|---|
| `Engine` | `AppName` | 引擎标识，如 `UE_5.8` |
| `Version` | `AppVersionString` 截断到第一个 `+` | 精确小版本，如 `5.8.2-56702186` |
| `InstallLocation` | `InstallLocation` | 安装根目录，引擎在 `<该路径>\Engine\` 下 |

`-Verify` 追加 `Usable` 列，检查 `<InstallLocation>\Engine\Binaries\Win64\UnrealEditor.exe` 是否存在。

**示例 1：默认输出（本机实测）**

```
Engine Version        InstallLocation
------ -------        ---------------
UE_5.5 5.5.4-40574608 E:\EpicGames\UE_5.5
UE_5.7 5.7.4-51494982 E:\EpicGames\UE_5.7
UE_5.8 5.8.2-56702186 E:\EpicGames\UE_5.8
```

**示例 2：`-Verify`，清单与磁盘一致**

```
Engine Version        InstallLocation     Usable
------ -------        ---------------     ------
UE_5.5 5.5.4-40574608 E:\EpicGames\UE_5.5   True
```

**示例 3：`-AsJson`，供其他脚本消费**

```json
[
  { "Engine": "UE_5.8", "Version": "5.8.2-56702186", "InstallLocation": "E:\\EpicGames\\UE_5.8" }
]
```

**示例 4：异常——清单目录不存在**（不要重试，也不要换路径猜）

```
list-engines.ps1 : Epic manifest directory not found:
C:\ProgramData\Epic\EpicGamesLauncher\Data\Manifests
```

**示例 5：边界——只有插件、没有引擎**

```
WARNING: No engine installation found in the manifest list (plugin entries only).
```

说明本机只有 Fab / Quixel 之类的插件安装项，没有引擎本体。此时**不要**把插件目录当引擎报给用户。

## 结果解读

拿到输出后主动核对下面两件事，这是本技能最常见的两个触发场景：

```
拿到引擎列表
     ↓
用户在问某个具体的 .uproject 吗？
     ├── 是 → 读该工程的 EngineAssociation，与列表比对
     │         ├── 命中   → 告知"用 <版本> 打开，路径 <InstallLocation>"
     │         └── 未命中 → 情形 A
     └── 否 → 用户报告过引擎打不开 / 被删了吗？
               ├── 是 → 跑 -Verify，按情形 B 处理
               └── 否 → 直接呈现列表结果
```

### 情形 A：工程关联的引擎不存在

读工程根目录 `*.uproject` 的 `EngineAssociation` 字段：

```powershell
(Get-Content .\MyGame.uproject -Raw | ConvertFrom-Json).EngineAssociation
```

与引擎列表对不上时，用户双击工程会收到"找不到引擎版本"。给两条路，并说明代价：

| 方案 | 做法 | 代价 |
|---|---|---|
| 补装 | 在 Launcher 里安装该版本 | 需要下载数 GB |
| 改关联 | 右键 `.uproject` → Switch Unreal Engine version | **C++ 工程需重新生成工程文件**（`.sln` / `.vcxproj`），不是只改一行 JSON；跨大版本还可能触发编译错误或 API 变更 |

### 情形 B：清单与磁盘不一致

Manifest 记录的是"Launcher 认为装了什么"，**不代表磁盘真实状态**——用户手动删过引擎文件、或安装中断时，清单仍在但引擎已不可用。只有 `-Verify` 显示 `Usable = False` 时才能下"引擎已损坏"的结论。

`Usable = False` 时：在 Launcher 里对该版本执行"验证"修复，或卸载后重装。**不要直接改清单文件。**

## 完成检查

- [ ] 输出中每一条都来自 `TechnicalType -eq 'engines/ue5,engines'` 的清单项
- [ ] 引擎数与 `<InstallLocation>\Engine\` 目录数**不**要求相等——对不上时应判为"清单与磁盘可能不一致"，跑 `-Verify` 后再下结论
- [ ] 用户给了 `.uproject` 时，已读取 `EngineAssociation` 并与列表比对
- [ ] 报告结论时附上 `InstallLocation` 原始路径，不只给版本号
- [ ] 清单目录不存在时，明确说明"本机没有安装记录"，未臆造路径

## 常见问题

### Q: 能用 `LauncherInstalled.dat` 代替 Manifest 吗？

能读，但不可靠。它位于 `%ProgramData%\Epic\UnrealEngineLauncher\`，格式更简单，但会与 Manifest 漂移——实测出现过"Manifest 里有、汇总里没有"的条目，而且它不含 `TechnicalType`，无法区分引擎与插件。**本技能统一以 Manifest 为准。** 完整对比见 `references/manifest-format.md`。

### Q: 为什么不能只用目录名判断装了哪些引擎？

因为 Epic 会把插件安装到与引擎同级的目录。本机实测：`E:\EpicGames` 下有 4 个 `UE_*` 目录，引擎只有 3 个；`UE_5.6` 里没有 `UnrealEditor.exe`，只有插件。只看目录名会多报一个引擎。

### Q: `Version` 为什么要截断到第一个 `+`？

`AppVersionString` 形如 `5.8.2-56702186+++UE5+Release-5.8-Windows`，第一个 `+` 之后是构建渠道信息，对判断"哪个引擎可用"没有价值。

### Q: 引擎装在非默认盘（如 D:）会漏掉吗？

不会。清单里的 `InstallLocation` 是绝对路径，与默认安装盘无关。

## 注意事项

- **改脚本时保持纯 ASCII。** Windows PowerShell 5.1 对没有 BOM 的脚本文件按 ANSI 解码，非 ASCII 字面量会乱码，乱码后的字节还可能吞掉紧随其后的引号——表现出来不是语法错误，而是"脚本能跑但结果全空"，极难排查。中文说明写在本文件里，不要写进 `.ps1`。
- 清单目录只读，不要写入或修改 Manifest 文件。
- 同一版本可能同时存在引擎项和插件项（如 `UE_5.8` 与 `FabPlugin_5.8`），过滤后只剩引擎，无需额外去重。

## 参考文件

- `references/manifest-format.md` —— 三处数据源对比、Manifest 关键字段与 `TechnicalType` 取值语义、本机实测证据，以及需要手动核查清单时的排查命令。
