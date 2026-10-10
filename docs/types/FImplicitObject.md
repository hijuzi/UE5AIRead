> 引擎版本：UE 5.8.3 (Build 58210709)
> 源码根：Engine/Source
> 生成技能：ue-type-api v1.0
> 生成时间：2026-10-10
> 校验状态：已校验（2026-10-10）

# FImplicitObject

## 一、类型概览

| 项 | 值 |
|---|---|
| 全限定名 | `Chaos::FImplicitObject`（命名空间 `Chaos`） |
| 定义位置 | `Engine/Source/Runtime/Experimental/Chaos/Public/Chaos/ImplicitObject.h` |
| 类型 | 类（**纯 C++ 抽象基类**；非 UObject；隐式几何体系的根类） |
| 反射宏 | 无（实测 0 命中） |
| 导出策略 | 逐成员 `CHAOS_API`（类声明行无宏） |
| 所属模块 | `Chaos`（`Engine/Source/Runtime/Experimental/Chaos`） |

## 二、继承链

```
Chaos::FChaosRefCountedObject（Engine/Source/Runtime/Experimental/Chaos/Public/Chaos/RefCountedObject.h 第 14 行；无基类=链根；含虚析构第 18 行、AddRef 第 37 行）
  └─ Chaos::FImplicitObject（ImplicitObject.h 第 110 行，`: public FChaosRefCountedObject`）
```

## 三、声明片段

```
文件：Engine/Source/Runtime/Experimental/Chaos/Public/Chaos/ImplicitObject.h
（namespace Chaos 第 19-620 行内）
行 110：class FImplicitObject : public FChaosRefCountedObject
行 112 / 539 / 601：public: / protected: / private:
行 603：类体结束（};；文件 640 行）

同文件配套：`typedef FImplicitObject FImplicitObject3;`（第 617 行）；自由函数模板 `MakeImplicitObjectPtr` / `MakeImplicitObjectConstPtr`（第 622-640 行，全局命名空间）
```

## 四、公开 API

| 签名 | 说明 | 位置 |
|---|---|---|
| `FImplicitObject(int32 Flags, EImplicitObjectType = Unknown)` | 构造（`CHAOS_API`） | 第 117 行 |
| 拷贝/移动构造 | `= delete`（引用计数语义） | 第 118 / 119 行 |
| `SerializationFactory(...)`（static） | 序列化工厂 | 第 115 行 |
| `GetType() const` / `GetNestedType() const` / `GetCollisionType() const` | 类型查询 | 第 199 / 198 / 202 行 |
| `GetRadiusf() const`（虚） | 半径（`GetRadius` 5.6 起弃用，第 208 行） | 第 209 行 |
| `GetMarginf() const`（虚） | 碰撞边距（`GetMargin` 5.6 起弃用，第 210-211 行） | 第 212 行 |
| `IsValidGeometry() const`（虚） | 几何有效性 | 第 216 行 |
| `CopyGeometry()` / `DeepCopyGeometry()` / `DeepCopyGeometryWithScale(...)`（虚） | 复制体系（另有 5 个 5.5 弃用入口，第 224-236 行） | 第 218 / 220 / 221 行 |
| `IsUnderlyingUnion()` / `IsUnderlyingMesh()`（`CHAOS_API`） | 类型判定 | 第 239 / 242 行 |
| `SignedDistance(const FVec3&) const` / `Normal(const FVec3&) const` | 距离场查询 | 第 245 / 248 行 |
| `PhiWithNormal(const FVec3&, FVec3&) const = 0`（**纯虚**） | 距离+法线（核心几何接口） | 第 251 行 |
| `PhiWithNormalScaled(...)`（虚） | 带缩放版 | 第 254 行 |
| `BoundingBox() const`（虚；`FAABB3`） | 局部包围盒 | 第 266 行 |
| `CalculateTransformedBounds(const FRigidTransform3&) const`（虚） | 变换后包围盒 | 第 269 行 |
| `IsConvex() const` / `SetConvex(bool)` | 凸性（非虚） | 第 277 / 278 行 |
| `Overlap(...)`（虚，第 372 行）/ `ToString() const`（虚，第 391 行） | 相交测试 / 字符串 | 见左 |
| `SerializeImp(FArchive&)` / `Serialize(FArchive&)`（虚）/ `Serialize(FChaosArchive&)`（虚） | 序列化三入口 | 第 396 / 403 / 408 行 |
| `GetTypeHash() const = 0`（**纯虚**） | 类型哈希（另一核心契约） | 第 412 行 |
| `GetTypeName()`（虚，第 414 行）/ `GetMaterialIndex(uint32) const`（虚，第 418 行） | 名称 / 材质索引 | 见左 |
| `GetMaterialIndex` / `GetOffsetOfMargin()`（static，第 214 行）等 | 反射偏移辅助 | 见左 |

> **不存在**：`GetLocalBounds`（实测 0 命中）；`Support` / `SupportCore` 是**派生几何类**的成员（如 `Box.h` 第 378 行），基类没有。

## 五、扩展点

### 5.1 可覆写虚函数（类内 44 处 `virtual` 声明）

| 组 | 成员（行号） |
|---|---|
| 生命周期 | `~FImplicitObject`(120，`override`) |
| 类型 / 尺寸 | `GetNestedType`(198)、`GetRadiusf`(209)、`GetMarginf`(212)、`GetTypeName`(414) |
| 有效性与复制 | `IsValidGeometry`(216)、`CopyGeometry`(218)、`CopyGeometryWithScale`(219)、`DeepCopyGeometry`(220)、`DeepCopyGeometryWithScale`(221)（含 5.5 弃用组 224-236） |
| 距离 / 包围盒 | `PhiWithNormal`(**纯虚**,251)、`PhiWithNormalScaled`(254)、`BoundingBox`(266)、`CalculateTransformedBounds`(269) |
| 诊断 | `IsPerformanceWarning`(288)、`PerformanceWarningAndSimplifaction`(289) |
| 碰撞查询（可覆写加速） | `Raycast`(299)、`FindMostOpposingFace`(320)、`FindMostOpposingFaceScaled`(326)、`FindClosestFaceAndVertices`(351)、`FindGeometryOpposingNormal`(365)、`Overlap`(372)、`AccumulateAllImplicitObjects`(378)、`FindAllIntersectingObjects`(389)、`ToString`(391) |
| 序列化 / 哈希 / 材质 | `Serialize(FArchive&)`(403)、`Serialize(FChaosArchive&)`(408)、`GetTypeHash`(**纯虚**,412)、`GetMaterialIndex`(418) |
| 层级遍历 Impl（注释标注 "should not be public"） | `CountObjectsInHierarchyImpl`(480)、`CountLeafObjectsInHierarchyImpl`(484)、`VisitOverlappingLeafObjectsImpl`(490)、`VisitLeafObjectsImpl`(507)、`VisitObjectsImpl`(520)、`IsOverlappingBoundsImpl`(534) |
| private 虚函数 | `FindClosestIntersectionImp(...)`（第 602 行） |

> 两条必须实现的契约：`PhiWithNormal`（第 251 行）与 `GetTypeHash`（第 412 行）。

### 5.2 不建议覆写的内部虚函数

`FindClosestIntersectionImp`（private，第 602 行）与 `*Impl` 遍历组（第 480-534 行，源码注释明确"不应公开"）。

## 六、生命周期

- **引用计数对象**：基类 `FChaosRefCountedObject`（`AddRef` 第 37 行）；生产/持有经智指针（`FImplicitObjectPtr` 系列，工厂函数第 622-640 行）。
- 序列化经 `FChaosArchive`（第 408 行）；几何在物理求解器（`FPBDRigidsSolver` 等）中作为碰撞形状使用。

## 七、派生类（范围内）

搜索边界：派生类搜索**仅覆盖本版纳入范围的 292 个模块**（Runtime 291 个 + `EnhancedInput` 插件）。搜索模式 `\bpublic\s+FImplicitObject\b`（`*.h`）：Runtime **23 命中 / 20 文件**（全部位于 `Chaos/Public/Chaos/`）；EnhancedInput **0**。

| 代表派生类 | 位置 |
|---|---|
| `TBox` / `FBoxFloat3` | `Engine/Source/Runtime/Experimental/Chaos/Public/Chaos/Box.h` 第 22 / 569 行 |
| `TSphere` | `Engine/Source/Runtime/Experimental/Chaos/Public/Chaos/Sphere.h` 第 27 行 |
| `FCapsule` / `FTaperedCapsule` | `Engine/Source/Runtime/Experimental/Chaos/Public/Chaos/Capsule.h` 第 22 行 / `TaperedCapsule.h` 第 12 行 |
| `FConvex` | `Engine/Source/Runtime/Experimental/Chaos/Public/Chaos/Convex.h` 第 25 行 |
| `FHeightField` | `Engine/Source/Runtime/Experimental/Chaos/Public/Chaos/HeightField.h` 第 36 行 |
| `FLevelSet` / `FMLLevelSet` | `Engine/Source/Runtime/Experimental/Chaos/Public/Chaos/Levelset.h` 第 29 行 / `MLLevelset.h` 第 37 行 |
| `FImplicitObjectUnion` | `Engine/Source/Runtime/Experimental/Chaos/Public/Chaos/ImplicitObjectUnion.h` 第 26 行 |
| `FTriangleMeshImplicitObject final` | `Engine/Source/Runtime/Experimental/Chaos/Public/Chaos/TriangleMeshImplicitObject.h` 第 570 行 |
| `FImplicitObjectScaled` / `FImplicitObjectInstanced` | `Engine/Source/Runtime/Experimental/Chaos/Public/Chaos/ImplicitObjectScaled.h` 第 414 / 25 行 |

> 完整 20 个文件（另含 `Cylinder.h`、`Plane.h`、`TaperedCylinder.h`、`ImplicitObjectTransformed.h`、`ImplicitObjectIntersection.h`、`SkinnedTriangleMesh.h`、`WeightedLatticeImplicitObject.h`、`ExtrudedTaperedCapsule.h` 与 4.27 起弃用的 `Triangle.h` 等）。

## 取数说明

| 断言 | 取数方式（相对基准：`Engine/Source`） |
|---|---|
| 文件 640 行、类体 110-603 | `[System.IO.File]::ReadAllLines(...).Count` + `^};` 检索 |
| 类内 `virtual` 44 处 | content 模式枚举（44 行清单）+ 全文件通读交叉核对；含 2 行注释提及"virtual" |
| 派生统计：23 命中 / 20 文件；EnhancedInput 0 | `Select-String -Pattern '\bpublic\s+FImplicitObject\b'`（`*.h`） |
| 全部行号引用 | 2026-10-10 对 UE 5.8.3 源码本机逐条核对 |

## 相关文档

- `modules/Chaos-结构.md` —— FImplicitObject 所在模块（同批产出）
- `types/ARecastNavMesh.md` —— 同批类型
- `modules/PhysicsCore-结构.md` —— 引擎物理接口层（批 7）
- `types/FRHIResource.md` —— 另一"引用计数基类"参照（批 4）
