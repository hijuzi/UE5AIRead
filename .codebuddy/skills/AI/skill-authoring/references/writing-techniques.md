# 写作技巧详解

SKILL.md 主体怎么写，才能让 AI 稳定照做。以下每一条都来自实战踩坑，按重要性排序。

## 目录

- [1. description 写好了，一切就成功了一半](#1-description-写好了)
- [2. 开头说清：做什么、为什么、要不要做](#2-开头说清)
- [3. 用祈使句下指令，解释"为什么"](#3-用祈使句下指令)
- [4. 给出"改之前 vs 改之后"的对比](#4-改之前-vs-改之后)
- [5. Few-Shot：多给几个例子](#5-few-shot)
- [6. 善用表格与 ASCII 流程图](#6-表格与-ascii-流程图)
- [7. 复杂逻辑抽成脚本](#7-复杂逻辑抽成脚本)
- [8. 提供多种方案适配不同场景](#8-提供多种方案)
- [9. 把易错点和边界标出来](#9-易错点和边界)
- [10. FAQ 不是摆设](#10-faq)
- [11. 长背景放 references/ 并写明读取时机](#11-长背景放-references)

---

## 1. description 写好了

`description` 决定 AI 判断"现在说的这件事该不该用这个 Skill"。写得笼统，AI 不知道何时用；写得太窄，该触发的场景又漏了。**这是触发成败的关键字段，也是 Level 1 唯一常驻上下文的内容。**

反面案例：

```yaml
description: 处理代码迁移
```

正面案例：

```yaml
description: >
  将项目中的旧版 HTTP 客户端迁移到新版统一请求库。
  适用于 Go 项目中使用了 old-http-client 模块、
  需要替换为 unified-httpclient 的场景。
  包含 import 路径替换、请求参数适配和错误处理改造。
```

要点：

- **写清"做什么 + 什么场景触发 + 什么场景不触发"**。不适用说明往往比适用说明更有效。
- **用通用语言 + 具体技术关键词**，不要堆内部黑话。`处理 TCC 的 v3 迁移，适配 QCMS 的新规范` AI 无从匹配；应写成 `将旧版事务补偿组件（TCC，Try-Confirm-Cancel）迁移到 v3……`。
- **宁可稍微"推"一点**：模型倾向于漏触发，把"用户会怎么说"的常见表述也写进去。
- **自测方法**：自己构造 20 条提问（10 条该触发、10 条不该触发），看 AI 是否每次都判对；命中率不够就回来改措辞。边界模糊的句子（"帮我检查一下这个函数"）最有价值。

## 2. 开头说清

别让 AI 猜意图。每个 Skill 上来就讲清三件事：**做什么、为什么做、怎么判断是否需要做**。

反面案例：

```markdown
# API 对接
把旧的 API 调用改成新的。
```

正面案例：

````markdown
## 目标

将项目中的 HTTP 请求从 `old-http-client` 迁移到 `unified-httpclient`，实现统一的请求层管理。

## 适用判断

执行前检查项目是否使用了旧版客户端：

```bash
grep "old-http-client" go.mod
```

如果**未使用**该模块，可跳过此 Skill。
````

要点：

1. **把起点和终点说清楚** —— 从哪迁到哪，别含糊。
2. **告诉 AI 什么时候不用做** —— 给前置检查条件，能及时跳过。
3. **给具体检查命令**，而不是模糊描述。

## 3. 用祈使句下指令

两个原则特别管用。

**第一，别用商量口吻，直接说做什么。**

```markdown
# ❌ 不推荐
你应该检查 Go 版本，然后你需要选择合适的方案。

# ✅ 推荐
检查 Go 版本。根据版本号选择对应方案：
- Go < 1.18 → 使用 interface{} 做泛型替代
- Go >= 1.18 → 使用原生泛型（type parameters）
```

**第二，与其一堆 MUST，不如讲清为什么。**

```markdown
# ❌ 不推荐
必须使用参数化查询。
绝对不能拼接字符串。
必须验证所有输入。

# ✅ 推荐
使用参数化查询而非字符串拼接来构建 SQL。
字符串拼接会导致 SQL 注入漏洞——攻击者可以输入
`'; DROP TABLE users; --` 来删除整张表。
```

AI 理解了背后的道理，遇到你没预料到的情况也能做出合理判断；光靠 MUST 只会死记硬背，换个场景就失效。

## 4. 改之前 vs 改之后

这是 Skill 中最关键的部分——让 AI 清楚知道"改什么"和"改成什么"。

**方式一：注释标注（适合简单变更）**

```go
// Before
import oldhttp "github.com/example/old-http-client"

// After
import uhttp "github.com/example/unified-httpclient"
```

**方式二：完整文件对比（适合复杂变更）** —— 分别给出 Before / After 的完整文件。

**方式三：Diff 格式（最直观，推荐）**

```diff
--- a/pkg/request/client.go
+++ b/pkg/request/client.go
@@ -3,7 +3,7 @@
 package request
-import oldhttp "github.com/example/old-http-client"
+import uhttp "github.com/example/unified-httpclient"

-    return oldhttp.Do(
+    return uhttp.Do(
```

其他语言同理，例如 Python 里 `requests.get(url)` → `httpx.Client(timeout=30).get(url)`。

## 5. Few-Shot

在 Skill 里放 3–5 个高质量的输入/输出示例，AI 表现会稳定很多。光靠文字描述，AI 可能理解偏；给了具体示例，它就知道"原来你要的是这个效果"。

原则：

- **覆盖典型场景**：正常、边界、错误各来一个。
- **输入输出成对出现**：每个示例都要有"给什么"和"出什么"。
- **示例之间有差异**：别搞 3 个长得差不多的，要能展示不同的处理分支。
- **先放最典型的**：AI 更倾向模仿前面的示例，把最常见场景放第一个。

### 完整示例：代码审查 Skill 的报告格式

````markdown
## 审查报告格式

按以下格式输出代码审查结果。下面给出三个不同场景的完整示例。

### 示例 1：安全漏洞（严重问题）

**输入**：

```java
public User getUser(String name) {
    String sql = "SELECT * FROM users WHERE name = '" + name + "'";
    return jdbcTemplate.queryForObject(sql, new UserRowMapper());
}
```

**输出**：

#### 🔴 严重问题

- **[第2行] SQL 注入风险**：使用字符串拼接构建 SQL 查询。
  - 修复建议：使用参数化查询 `"SELECT * FROM users WHERE name = ?"`
  - 风险等级：Critical

#### 🟡 改进建议

- **[第1行] 缺少参数校验**：`name` 参数未做空值检查。
  - 修复建议：添加 `Objects.requireNonNull(name, "name must not be null")`

### 示例 2：空指针风险（中等问题）

**输入**：

```java
public String getDisplayName(User user) {
    return user.getProfile().getNickname().toUpperCase();
}
```

**输出**：

#### 🟡 改进建议

- **[第2行] 空指针风险**：链式调用中任一环返回 null 将抛 NullPointerException。
  - 修复建议：使用 `Optional` 链式处理
  - 风险等级：Major

#### 🟢 可选优化

- **[第1行] 方法缺少 Javadoc**：公共方法建议补充文档注释。

### 示例 3：代码规范（轻微问题）

**输入**：

```java
public class user_service {
    private static final int max_retry = 3;

    public List<User> GetAllUsers() {
        List<User> Data = userRepository.findAll();
        return Data;
    }
}
```

**输出**：

#### 🟢 可选优化

- **[第1行] 类名命名不规范**：`user_service` 应使用 PascalCase → `UserService`
- **[第2行] 常量命名不规范**：`max_retry` 应改为 `MAX_RETRY`
- **[第4行] 方法名命名不规范**：`GetAllUsers` 应改为 `getAllUsers`
- **[第5行] 局部变量命名不规范**：`Data` 应改为 `data`

✅ **无安全问题**：未发现 SQL 注入、硬编码凭据等安全风险。
````

三个示例从严重到轻微递进，覆盖了审查 Skill 的主要判断分支。AI 看完就能举一反三，遇到混合场景也知道怎么分级输出。

非代码审查类 Skill 同理：准备 3 个左右示例，分别对应"最常见的情况""稍有变化的情况""边界/特殊情况"。

## 6. 表格与 ASCII 流程图

很多任务不是一条路走到底。用表格或流程图把不同情况列出来，AI 就不容易搞混。好处：流程一目了然、分支清晰、AI 读图比读长段文字更准确、纯文本无需画图工具。

**表格化场景分类**：

| 情形 | 特征 | 处理方案 | 自动/手动 |
|---|---|---|---|
| 直接 import | `import "github.com/old/pkg"` | 直接替换 import 路径 | 自动 |
| 别名 import | `import alias "github.com/old/pkg"` | 替换路径，保留别名 | 自动 |
| 点导入 | `. "github.com/old/pkg"` | 替换路径，检查冲突符号 | 自动 |
| 接口依赖 | 通过接口类型间接引用 | 需确认接口签名兼容性 | 手动 |
| 反射调用 | 通过 `reflect` 间接引用类型 | 需要追踪反射调用链 | 手动 |

**决策流程图**：

```
输入：待处理的 import 语句
         ↓
  是否为直接 import？ ──── 是 → 自动替换 import 路径
         ↓ 否
  是否为别名 import？ ──── 是 → 替换路径，保留别名
         ↓ 否
  是否为点导入？ ────── 是 → 替换路径，检查符号冲突
         ↓ 否
  标记为需手动处理 → 输出待处理清单供开发者确认
```

**线性流程图**（适合顺序执行的步骤）：

```
┌─────────────────────────────────────────────────┐
│             HTTP 客户端迁移流程                    │
├─────────────────────────────────────────────────┤
│  Step 1: 环境检查                                │
│  ├── 确认 Go 版本 >= 1.21                        │
│  ├── 确认项目使用旧版 HTTP 客户端                 │
│  └── 如未使用 → 跳过，流程结束                    │
│                       ↓                          │
│  Step 2: 依赖替换                                │
│  ├── go get 新版客户端模块                        │
│  ├── 移除旧版客户端依赖                           │
│  └── 运行 go mod tidy                            │
│                       ↓                          │
│  Step 3: 代码迁移与验证                           │
│  ├── 替换 import 路径、适配参数和结构体           │
│  └── go vet / go test / go build                │
└─────────────────────────────────────────────────┘
```

## 7. 复杂逻辑抽成脚本

前置检查或配置流程比较复杂时，别全堆在 SKILL.md 里，写成脚本放到 `scripts/`，正文直接调用。

脚本示例（`scripts/pre-check.sh`）：

```bash
#!/bin/bash
# 执行前环境检查
set -euo pipefail

echo "=== 1. 检查必要文件 ==="
for file in go.mod go.sum; do
  if [ ! -f "$file" ]; then
    echo "❌ 未找到 $file"
    exit 1
  fi
  echo "  ✅ $file 存在"
done

echo "=== 2. 检查旧版依赖 ==="
if grep -q "old-http-client" go.mod; then
  echo "  ⚠️ 发现旧版依赖 old-http-client，需要迁移"
else
  echo "  ℹ️ 未使用旧版依赖，可跳过迁移步骤"
fi
```

在 SKILL.md 里这样引用：

````markdown
## 前置检查

运行环境检查脚本确认项目状态：

```bash
bash scripts/pre-check.sh
```
````

脚本编写要点：

- 开头写 `set -euo pipefail`：遇错即停、未定义变量报错、管道错误传播。
- 检查必要命令是否存在（`command -v go`），缺失时明确报错。
- **跨平台注意**：macOS 的 BSD `sed` 与 Linux 的 GNU `sed` 有差异——`sed -r` 仅 GNU 支持，`sed -E` 两者都可用，统一用 `sed -E`；`sort -V` 在 macOS 原生不可用。
- **Windows 环境**：优先提供 `.ps1` 或 Python 脚本，避免硬依赖 bash；若必须用 bash，注明需 Git Bash / WSL。

## 8. 提供多种方案

同一个目标，不同项目结构可能完全不同。多准备几种方案，让 AI 按实际情况选。

````markdown
## HTTP 客户端改造

根据项目中 HTTP 客户端的实现方式选择方案：

### 方案 A：集中式请求封装（推荐）
适用于有统一请求工具函数的项目（如 `pkg/request/client.go`）。

### 方案 B：分散式直接调用
适用于各模块直接引用旧包、无统一封装的项目。
1. 全局搜索所有旧包 import（含别名）
2. 逐文件替换 import 路径和调用
3. 运行 `go vet ./...` 确保类型兼容

### 方案 C：渐进式迁移
适用于无法一次性完成迁移的大型项目。
1. 新建适配层（adapter），同时支持新旧客户端
2. 新代码用新客户端，旧代码逐步迁移
3. 迁移完成后移除适配层和旧依赖
````

## 9. 易错点和边界

AI 也会犯错，特别是一些人类凭经验才能避开的坑。在 Skill 里显眼地标出来，能省很多事。

```markdown
### ⚠️ 注意事项

**1. 避免误替换字符串内容**

批量替换时，确保只替换代码导入，不要修改：
- 字符串常量中的包名（如日志信息、注释）
- 配置文件中的描述文本
- 测试用例中的断言字符串

**2. 保持中文标点不变**

批量操作常见误替换：中文引号 `“”` 被改成英文 `""`，中文句号 `。` 被改成 `.`。

**3. 处理类型不兼容**

旧包和新包的类型定义可能不一致：
- `oldhttp.Options` → `uhttp.Config`（结构体名称变化）
- `Timeout int` → `Timeout time.Duration`（字段类型变化）
- `error` → `*ErrorResponse`（错误类型变化，需检查类型断言）
```

## 10. FAQ

写得好的 FAQ 能帮 AI 处理那些"说不清道不明"的边界情况。

```markdown
## 常见问题

### Q: 为什么推荐编译时条件构建，而非运行时配置切换？

运行时判断（`if config.Env == "prod" {...}`）的问题：
1. 代码冗余：所有环境代码都编译进二进制
2. 安全风险：非目标环境逻辑可能通过反编译泄露
3. 维护困难：条件判断分散各处

编译时条件构建（Go build tags / Maven profiles）的优势：
1. 编译隔离：只编译目标环境代码
2. 零运行时开销
3. 集中管理

### Q: 迁移过程中如何保证线上稳定性？

1. 先在预发布环境验证
2. 使用 Feature Flag 控制切换
3. 保留旧版回退路径
4. 全量验证后再清理旧代码
```

## 11. 长背景放 references

SKILL.md 只保留"做什么"和"怎么做"。背景介绍、历史沿革、架构演进这一类内容写进 `references/`，在步骤中显式引用：

```markdown
## 背景

详见 [架构演进说明](references/architecture-history.md)。

## 操作步骤

（直接进入正题）
```

反模式警示：一篇 SKILL.md 写了 300 行背景还没进入正题，AI 的注意力是有限的——前面的"噪音"越多，后面真正重要的指令被遵循的概率越低。
