# Manifest 清单格式与数据源依据

主文件只讲"怎么做"；本文补"为什么这么做"，以及在需要手动核查时用得上的细节。**正常情况下不需要读本文**——只在怀疑脚本行为、要改脚本、或要向用户解释结论依据时才查阅。

## 目录

- [1. 三处数据源对比](#1-三处数据源对比)
- [2. TechnicalType：区分引擎与插件](#2-technicaltype区分引擎与插件)
- [3. Manifest 关键字段](#3-manifest-关键字段)
- [4. 本机实测证据](#4-本机实测证据)
- [5. 手动核查命令](#5-手动核查命令)
- [6. 已知坑](#6-已知坑)

---

## 1. 三处数据源对比

本机有三处记录引擎安装情况，可靠性不同：

| 来源 | 位置 | 特点 |
|---|---|---|
| **Manifest 清单** | `%ProgramData%\Epic\EpicGamesLauncher\Data\Manifests\*.item` | 每个安装项一个 JSON。字段齐全、可脚本化、含 `TechnicalType` 类型标识。**本技能使用此来源** |
| `LauncherInstalled.dat` | `%ProgramData%\Epic\UnrealEngineLauncher\` | 汇总列表，读起来更简单，但会与 Manifest 漂移（实测出现过清单里有、汇总里没有的条目），且不含 `TechnicalType` |
| Launcher 界面 | 库 → 引擎版本 → 齿轮 → 选项 | 直观，无法脚本化 |

选 Manifest 的真正理由就是 `TechnicalType` 这个字段——没有它就无法把插件从引擎里摘出来。

## 2. TechnicalType：区分引擎与插件

```
"TechnicalType": "engines/ue5,engines"        ← 引擎本体
"TechnicalType": "plugins/engine,codeproject" ← 插件（Fab、Quixel Bridge、Figma、蓝图助手等）
```

**只有 `engines/ue5,engines` 才是引擎。** 这不是吹毛求疵：Epic 会把插件安装到形如 `E:\EpicGames\UE_5.6` 的目录里，于是磁盘上会出现一个叫 `UE_5.6` 却没有引擎的目录。只看目录名会得出"装了 4 个引擎"的错误结论。

插件项的 `AppName` 不一定是可读名字——一部分是 Vault 缓存生成的标识（如 `Blueprin0777d1c84a45V15`、`AsyncLoa0a74ccc95d81V14`、`Figma2UM017a6d2c00e4V5`），另一部分是可读的（`FabPlugin_5.8`、`QuixelBridge_5.8`）。无论哪种，都不该出现在引擎列表里。

## 3. Manifest 关键字段

每个 `.item` 是一个 JSON 对象，本机实测有 60 余个字段。与本技能相关的：

| 字段 | 示例值 | 用途 |
|---|---|---|
| `AppName` | `UE_5.8` | 引擎标识，对应输出中的 `Engine` 列 |
| `AppVersionString` | `5.8.2-56702186+++UE5+Release-5.8-Windows` | 精确版本；截断到第一个 `+` |
| `InstallLocation` | `E:\EpicGames\UE_5.8` | 安装根目录 |
| `TechnicalType` | `engines/ue5,engines` | 类型过滤依据 |
| `MandatoryAppFolderName` | `UE_5.8` | 安装目录名（通常与 `AppName` 相同，不保证） |
| `bIsIncompleteInstall` | `false` | 是否为未完成的安装（本机全部为 `false`） |
| `bNeedsValidation` | `false` | Launcher 是否标记为需要验证 |
| `CatalogItemId` | `18b3b415bc434c5b974f50488360ca31` | 商店条目 ID |
| `StagingLocation` / `ManifestLocation` | — | 暂存区与清单自身位置 |

不需要读的字段（`ChunkDbs`、`PrereqSHA1Hash`、`SDMetaHash` 等）占绝大多数，不要把它们当判断依据。

## 4. 本机实测证据

在编写本技能时于本机实测（Windows）：

- 清单目录共 **15 个** `*.item` 文件：**3 个引擎项**（`UE_5.5`、`UE_5.7`、`UE_5.8`）+ **12 个插件项**（`FabPlugin_5.x`、`QuixelBridge_5.x`、`Figma2UM...`、`Blueprin...`、`AsyncLoa...`）。
- `E:\EpicGames` 下有 **4 个** `UE_*` 目录（`UE_5.5`、`UE_5.6`、`UE_5.7`、`UE_5.8`），但只有 3 个引擎——`E:\EpicGames\UE_5.6\Engine\Binaries\Win64\UnrealEditor.exe` 不存在。
- 插件项的 `InstallLocation` 指向的就是 `E:\EpicGames\UE_5.x`，即插件与引擎共目录。
- `Pending\` 子目录存在，但顶层 `*.item` 已足以得到正确结果。
- 全部引擎项 `bIsIncompleteInstall = false`。

结论：过滤 `TechnicalType` 是必需步骤，不是可选优化。

## 5. 手动核查命令

需要脱离脚本核对时用这些命令。

**列出全部清单项及其类型**（识别"引擎 vs 插件"）：

```powershell
$d = Join-Path $env:ProgramData 'Epic\EpicGamesLauncher\Data\Manifests'
Get-ChildItem -LiteralPath $d -Filter *.item -File | ForEach-Object {
    $j = Get-Content -LiteralPath $_.FullName -Raw -Encoding UTF8 | ConvertFrom-Json
    [PSCustomObject]@{
        AppName       = $j.AppName
        TechnicalType = $j.TechnicalType
        Loc           = $j.InstallLocation
        Incomplete    = $j.bIsIncompleteInstall
    }
} | Sort-Object TechnicalType, AppName | Format-Table -AutoSize
```

**确认某目录是否真的是引擎**（区分"目录存在"与"引擎可用"）：

```powershell
Test-Path -LiteralPath 'E:\EpicGames\UE_5.6\Engine\Binaries\Win64\UnrealEditor.exe'
```

**确认清单文件编码**（排查 JSON 解析失败）：

```powershell
$p = (Get-ChildItem "$env:ProgramData\Epic\EpicGamesLauncher\Data\Manifests" -Filter *.item -File |
      Select-Object -First 1).FullName
(Get-Content -LiteralPath $p -Encoding Byte -TotalCount 3) -join ','
# 本机实测：123,13,10 → 字节 { CR LF，即 UTF-8 且无 BOM（有 BOM 时首字节为 239,187,191）
```

## 6. 已知坑

| 坑 | 现象 | 处理 |
|---|---|---|
| 目录名冒充引擎 | 多报引擎（本机多报 1 个） | 必须按 `TechnicalType` 过滤 |
| `-Encoding Unicode` 读清单 | `ConvertFrom-Json: 无效的 JSON 基元` | 统一用 `-Encoding UTF8` |
| 递归扫到 `Pending\` | 引擎重复计数 | 只取顶层 `*.item` |
| 清单与磁盘漂移 | 清单有、引擎目录已被删 | 用 `-Verify` 判断，别只看清单 |
| 脚本非 ASCII 字面量 | "脚本能跑但结果全空"（引号被吞） | `.ps1` 保持纯 ASCII，中文写在 `SKILL.md` |
