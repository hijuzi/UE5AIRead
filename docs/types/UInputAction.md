> 引擎版本：UE 5.8.3 (Build 58210709)
> 源码根：Engine/Source
> 生成技能：ue-type-api v1.0
> 生成时间：2026-10-10
> 校验状态：已校验（2026-10-10）

# UInputAction

## 一、类型概览

| 项 | 值 |
|---|---|
| 全限定名 | `UInputAction`（全局命名空间） |
| 定义位置 | `Engine/Plugins/EnhancedInput/Source/EnhancedInput/Public/InputAction.h` |
| 类型 | 类（反射类型；数据资产） |
| 反射宏 | `UCLASS(MinimalAPI, BlueprintType)`（第 54 行）+ `GENERATED_BODY()`（类体首部） |
| 导出策略 | `MinimalAPI` + 逐成员 `UE_API`：`#define UE_API ENHANCEDINPUT_API`（第 11 行）、`#undef UE_API`（第 283 行）；类声明行不带宏（第 55 行） |
| 所属模块 | `EnhancedInput`（`Engine/Plugins/EnhancedInput/Source/EnhancedInput`） |

## 二、继承链

```
UObjectBase            （Engine/Source/Runtime/CoreUObject/Public/UObject/UObjectBase.h 第 66 行；链根）
  └─ UObjectBaseUtility（Engine/Source/Runtime/CoreUObject/Public/UObject/UObjectBaseUtility.h 第 44 行）
       └─ UObject      （Engine/Source/Runtime/CoreUObject/Public/UObject/Object.h 第 98 行）
            └─ UDataAsset（Engine/Source/Runtime/Engine/Classes/Engine/DataAsset.h 第 17 行；`UCLASS(abstract, MinimalAPI, ...)` 第 16 行）
                 └─ UInputAction（…/EnhancedInput/Public/InputAction.h 第 55 行）
```

派生方向：范围内仅测试类 1 个（见第七节）。

## 三、声明片段

```
文件：Engine/Plugins/EnhancedInput/Source/EnhancedInput/Public/InputAction.h
行 54-55：UCLASS(MinimalAPI, BlueprintType) / class UInputAction : public UDataAsset

文件：Engine/Plugins/EnhancedInput/Source/EnhancedInput/Public/InputAction.h
行 11： #define UE_API ENHANCEDINPUT_API（成员级导出开关；文件尾第 283 行 #undef）

文件：Engine/Plugins/EnhancedInput/Source/EnhancedInput/Public/InputAction.h
行 154：类体结束（};；文件共 283 行）
```

## 四、公开 API

> 本类型是数据资产：逻辑（触发/修饰求值）在 `UInputTrigger` / `UInputModifier` 与子系统侧；下表为其配置面。

| 签名 / 成员 | 说明 | 位置 |
|---|---|---|
| `GetPlayerMappableKeySettings()` | 取可重映射键设置（inline） | 第 84 行 |
| `ActionDescription`（`FText`） | 描述文本（EditAnywhere / BlueprintReadOnly） | 第 87-88 行 |
| `bTriggerWhenPaused`（bool） | 暂停时仍响应 | 第 91-92 行 |
| `bConsumeInput`（bool） | 消费低优先级映射的输入 | 第 95-96 行 |
| `bConsumesActionAndAxisMappings`（bool） | 兼容消费旧版轴映射 | 第 103-104 行 |
| `bReserveAllMappings`（bool） | 预留所有映射 | 第 107-108 行 |
| `TriggerEventsThatConsumeLegacyKeys`（int32 位掩码） | 旧版按键消费事件 | 第 111-112 行 |
| `ValueType`（`EInputActionValueType`，默认 `Boolean`） | 动作值类型 | 第 115-116 行 |
| `AccumulationBehavior`（`EInputActionAccumulationBehavior`） | 多触发器累加行为 | 第 126-127 行 |
| `Triggers`（`TArray<TObjectPtr<UInputTrigger>>`，Instanced） | 触发器列表 | 第 134-135 行 |
| `Modifiers`（`TArray<TObjectPtr<UInputModifier>>`，Instanced） | 修饰器列表 | 第 144-145 行 |
| `GetSupportedTriggerEvents()` | 支持的触发事件集合（编辑器） | 第 72 行 |
| `PlayerMappableKeySettings`（protected） | 用户设置字段 | 第 152-153 行 |

> `UInputAction` **没有** `GetValueType()` 方法——该方法属于 `FInputActionValue`（`InputActionValue.h` 第 124 行）；
> 值类型经 `ValueType` 成员读取。

## 五、扩展点

### 5.1 可覆写虚函数

类内 `virtual` 共 **2 处，均为编辑器专用**（`#if WITH_EDITOR` 区段）：

| 虚函数 | 用途 | 位置 |
|---|---|---|
| `PostEditChangeProperty(...)`（override） | 属性变更响应 | 第 63 行 |
| `IsDataValid(...)`（override） | 资产校验 | 第 64 行 |

> 非编辑器构建下**无任何可覆写虚函数**——该类型是纯数据资产。

### 5.2 不建议覆写的内部虚函数

无。

## 六、生命周期

- 数据资产（`UDataAsset`）：无 `Tick` / `BeginPlay` 类运行时钩子；运行期由 `UEnhancedInputLocalPlayerSubsystem` / `UEnhancedPlayerInput` 消费（完整链路属 `flows/` 范畴，暂无产物）。
- 编辑器钩子：`PostEditChangeProperty` / `IsDataValid`（仅 `WITH_EDITOR`）。

## 七、派生类（范围内）

搜索边界：派生类搜索**仅覆盖本版纳入范围的 292 个模块**（Runtime 291 个 + `EnhancedInput` 插件），引擎其余部分（Editor / Developer / Platforms / 未纳入的 Plugins）未覆盖。搜索模式 `\bpublic\s+UInputAction\b`（`*.h`）：Runtime **0 命中**；`EnhancedInput` 插件 **1 命中**。

| 派生类 | 位置 | 备注 |
|---|---|---|
| `UTestMappableKeysAction` | `Engine/Plugins/EnhancedInput/Source/InputEditor/Private/Tests/InputTestFramework.h` 第 141 行 | 测试类（InputEditor 模块内） |

## 取数说明

| 断言 | 取数方式（相对基准：`Engine/Source`；本类型在 `Engine/Plugins/` 下） |
|---|---|
| 文件 283 行、类体 54-154 | `[System.IO.File]::ReadAllLines(...).Count` + `^};` 检索 |
| 类内 `virtual` 2 处 | `Select-String ... -Pattern 'virtual'` 全匹配 + 逐段核对（其余 `virtual` 不在本类体内） |
| 派生统计 | 模式 `\bpublic\s+UInputAction\b`，范围 `Runtime` 与 `Engine/Plugins/EnhancedInput/Source`，glob `*.h` |
| 全部行号引用 | 2026-10-10 对 UE 5.8.3 源码本机逐条核对 |

## 相关文档

- `modules/EnhancedInput-结构.md` —— UInputAction 所在模块（同批产出）
- `modules/Engine-结构.md` —— `UDataAsset` 基类所在模块（已校验）
- `modules/CoreUObject-结构.md` —— 基类链所在模块（已校验）
- `types/AActor.md` —— 输入组件的宿主（同批产出）
