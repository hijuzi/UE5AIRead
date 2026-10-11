> 引擎版本：UE 5.8.3 (Build 58210709)
> 源码根：Engine/Source
> 生成技能：ue-type-api v1.0
> 生成时间：2026-10-10
> 校验状态：已校验（2026-10-11）

# UPhysicalMaterial

## 一、类型概览

| 项 | 值 |
|---|---|
| 全限定名 | `UPhysicalMaterial`（全局命名空间） |
| 定义位置 | `Engine/Source/Runtime/PhysicsCore/Public/PhysicalMaterials/PhysicalMaterial.h` |
| 类型 | 类（反射类型；物理材质资产） |
| 反射宏 | `UCLASS(BlueprintType, Blueprintable, CollapseCategories, HideCategories = Object, MinimalAPI)`（第 102 行）+ `GENERATED_UCLASS_BODY()`（第 105 行；**注意不是 `GENERATED_BODY`**） |
| 导出策略 | `MinimalAPI` + 逐成员 `PHYSICSCORE_API`（11 处：第 107、108、225、226、228、229、232、235、237、239、242 行）；类级无宏（实测全模块 `class PHYSICSCORE_API` 0 命中） |
| 所属模块 | `PhysicsCore`（`Engine/Source/Runtime/PhysicsCore`） |

> 说明：**不存在 `UPhysicalMaterialCore`**（全引擎实测 0 命中，另用 5.5/5.7 源码对照复核）——本类即物理材质在 PhysicsCore 层的实际实现。

## 二、继承链

```
UObjectBase            （Engine/Source/Runtime/CoreUObject/Public/UObject/UObjectBase.h 第 66 行；链根）
  └─ UObjectBaseUtility（Engine/Source/Runtime/CoreUObject/Public/UObject/UObjectBaseUtility.h 第 44 行）
       └─ UObject      （Engine/Source/Runtime/CoreUObject/Public/UObject/Object.h 第 98 行）
            └─ UPhysicalMaterial（Engine/Source/Runtime/PhysicsCore/Public/PhysicalMaterials/PhysicalMaterial.h 第 103 行）
```

## 三、声明片段

```
文件：Engine/Source/Runtime/PhysicsCore/Public/PhysicalMaterials/PhysicalMaterial.h
行 102-105：UCLASS(..., MinimalAPI) / class UPhysicalMaterial : public UObject / { / GENERATED_UCLASS_BODY()

文件：Engine/Source/Runtime/PhysicsCore/Public/PhysicalMaterials/PhysicalMaterial.h
行 247：类体结束（};；文件 250 行）
```

## 四、公开 API

> 数据经 **public 字段** 直接访问（本类没有 Get* 访问器，见下方"不存在"）。

| 成员 | 说明 | 位置 |
|---|---|---|
| `~UPhysicalMaterial()` / `UPhysicalMaterial(FVTableHelper&)` | 析构 / 构造辅助 | 第 107 / 108 行 |
| `Friction`（float） | 摩擦系数 | 第 115 行 |
| `StaticFriction`（float） | 静摩擦 | 第 119 行 |
| `FrictionCombineMode`（`TEnumAsByte<EFrictionCombineMode::Type>`） | 摩擦合并模式 | 第 123 行 |
| `bOverrideFrictionCombineMode`（bool） | 覆盖合并模式 | 第 127 行 |
| `Restitution`（float） | 弹性系数 | 第 131 行 |
| `RestitutionCombineMode` / `bOverrideRestitutionCombineMode` | 弹性合并 | 第 135 / 139 行 |
| `Density`（float） | 密度 | 第 147 行 |
| `SleepLinearVelocityThreshold` / `SleepAngularVelocityThreshold` / `SleepCounterThreshold` | 睡眠阈值 | 第 151 / 155 / 159 行 |
| `RaiseMassToPower`（float） | 质量幂次 | 第 167 行 |
| `SurfaceType`（`TEnumAsByte<EPhysicalSurface>`） | 表面类型 | 第 181 行 |
| `Strength` / `DamageModifier` | 强度 / 损伤修正（`FPhysicalMaterialStrength` / `FPhysicalMaterialDamageModifier`） | 第 184 / 187 行 |
| `DebugColor`（`FLinearColor`） | 调试色 | 第 191 行 |
| `SoftCollisionMode` / `SoftCollisionThickness` / `BaseFrictionImpulse` | 软碰撞参数 | 第 204 / 209 / 215 行 |
| `GetPhysicsMaterial()` | 取底层物理材质句柄（`FPhysicsMaterialHandle&`） | 第 235 行 |
| `static RebuildPhysicalMaterials()` | 重建全部物理材质 | 第 226 行 |
| `static SetEngineDefaultPhysMaterial(...)` / `SetEngineDefaultDestructiblePhysMaterial(...)` | 引擎默认材质设置 | 第 237 / 239 行 |
| `static DetermineSurfaceType(...)` | 由材质推导表面类型 | 第 242 行 |
| `MaterialHandle`（`TUniquePtr<FPhysicsMaterialHandle>`，private 语义的句柄） / `UserData`（`FChaosUserData`） | 底层句柄与用户数据 | 第 219 / 221 行 |

> **不存在**（本类内 0 命中）：`GetFriction` / `GetRestitution` / `GetFrictionCombineMode` / `GetRestitutionCombineMode` / `GetDensity` / `GetSurfaceType`（材质访问器形式）——请直接读字段；`GetPhysicalMaterialFromPrimitive` 全引擎 0 命中。

## 五、扩展点

### 5.1 可覆写虚函数（类内 5 条，全列）

| 虚函数 | 用途 | 位置 |
|---|---|---|
| `~UPhysicalMaterial()` | 虚析构 | 第 107 行 |
| `PostEditChangeProperty(...)`（override；`WITH_EDITOR`） | 属性变更 | 第 225 行 |
| `PostLoad()`（override） | 加载后（按需创建底层句柄） | 第 228 行 |
| `FinishDestroy()`（override） | 销毁 | 第 229 行 |
| `Serialize(FArchive&)`（override） | 序列化 | 第 232 行 |

### 5.2 不建议覆写的内部虚函数

无——5 条均为常规 UObject 覆写面。

## 六、生命周期

- 资产型对象：`PostLoad`（第 228 行）后按需创建底层物理句柄（`EnsurePhysicsMaterialCreated()`，第 246 行）；`FinishDestroy`（第 229 行）释放。
- **并列关系澄清**：`UPhysicalMaterialMask`（Engine/Source/Runtime/Engine/Classes/PhysicalMaterials/PhysicalMaterialMask.h 第 21 行）与 `UChaosPhysicalMaterial`（同模块 `Chaos/ChaosPhysicalMaterial.h` 第 22 行）都**直接派生 `UObject`**，与本类并列而非父子。

## 七、派生类（范围内）

搜索边界：`Engine/Source` 全树（覆盖 Runtime 291 个 + EnhancedInput）；搜索模式 `\bpublic\s+UPhysicalMaterial\b`（`*.h`）：**0 命中**。

| 派生类 | — |
|---|---|
| （无） | 本类在引擎内**无派生类**（叶子类）；材质差异化靠资产实例而非子类 |

## 取数说明

| 断言 | 取数方式（相对基准：`Engine/Source`） |
|---|---|
| 搜索范围 `Engine/Source` 全树，其中 Runtime **291** 个模块 | `[R]` 对 `_meta/engine-modules.json` 按 `Category` 字段等于 `Runtime` 计数 = **291**；搜索范围另含 `EnhancedInput` 插件 |
| 文件 250 行、类体 102-247 | `[M]` `[System.IO.File]::ReadAllLines("Engine/Source/Runtime/PhysicsCore/Public/PhysicalMaterials/PhysicalMaterial.h").Count`（同文件 `^};` 检索定类体区间） |
| 类内 `virtual` 5 条 | `[H]` `Select-String -Pattern 'virtual'` 全匹配 + 逐段核对 |
| `UPhysicalMaterialCore` 不存在 | 全 `Engine/Source`（及 Intermediate）内容搜索 0 命中；5.5/5.7 源码对照复核 |
| 派生 0 命中 | `[H]` `Select-String -Pattern '\bpublic\s+UPhysicalMaterial\b'`（`*.h`） |
| 全部行号引用 | 2026-10-10 对 UE 5.8.3 源码本机逐条核对 |

## 相关文档

- `modules/PhysicsCore-结构.md` —— UPhysicalMaterial 所在模块（同批产出）
- `types/UDeveloperSettings.md` —— 同模块 `UPhysicsSettingsCore` 的基类（批 5 产出）
- `modules/Engine-结构.md` —— `FPhysScene_Chaos` 等 Engine 侧物理入口
- `types/UObject.md` —— 基类链终点（已校验）

## 更新记录

- 2026-10-11 「获取器 0 命中」限定口径到本类（同模块 `PhysicalMaterialPropertyBase.h:45` 有同名 `GetSurfaceType`）

- 2026-10-11 「取数说明」补入 1 行计数断言取数方式（`convention.md` 4.2 覆盖要求）

- 2026-10-11 按规范 4.2.1 为「取数说明」各行加方法标记（`[M]`/`[R]`/`[H]`）；`[M]` 行把原文省略成 `(...)` 的路径补全为白名单可执行命令，现由 `ue-doc-verify` 逐条实际执行比对
