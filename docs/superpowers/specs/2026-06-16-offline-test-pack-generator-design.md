# 离线测试包生成器设计

## 目标

为应届生简历教练 agent 增加一个本地离线测试包生成器。它不调用任何大模型 API，只把现有 Markdown 资产组装成可复制到 ChatGPT、Claude、Gemini 或其他平台中试跑的测试输入，并生成评估记录模板。

第一版用于验证提示词质量，而不是提供真实对话产品。测试者复制生成的案例提示词到目标模型后，人工记录输出是否满足评估清单。

## 使用场景

用户希望检查第一阶段 agent 资产包是否可用。测试器应支持一条命令生成 6 个测试案例的完整试跑材料，使每个案例都能独立复制、独立评估、独立记录结果。

典型流程：

1. 运行本地生成脚本。
2. 打开生成目录中的 `README.md`。
3. 逐个复制 `case_XX_prompt.md` 到目标模型。
4. 把模型表现记录到 `evaluation_report.md`。
5. 根据失败项回到主提示词、模块提示词或知识卡片中迭代。

## 范围

第一版包含：

- 读取现有 agent 资产。
- 为 6 个测试案例生成 6 份完整测试输入。
- 为每次测试运行创建独立输出目录。
- 生成评估报告模板。
- 生成本次测试运行说明。
- 增加一个验证脚本，检查测试包输出是否完整。

第一版不包含：

- 不调用 API。
- 不自动选择模型。
- 不保存模型回答。
- 不自动评分。
- 不做网页界面。
- 不引入数据库。

## 文件结构

新增文件建议如下：

```text
agent/
  tests/
    generate_offline_test_pack.ps1
    verify_offline_test_pack.ps1
  test_runs/
    .gitkeep
```

每次运行生成目录：

```text
agent/test_runs/YYYYMMDD-HHMMSS/
  README.md
  case_01_prompt.md
  case_02_prompt.md
  case_03_prompt.md
  case_04_prompt.md
  case_05_prompt.md
  case_06_prompt.md
  evaluation_report.md
```

`agent/test_runs/` 保存本地试跑产物。默认不提交具体运行目录，只保留 `.gitkeep`，避免把大量临时测试记录放进 Git。

## 输入资产

生成器读取：

- `agent/prompts/main_agent.md`
- `agent/modules/*.md`
- `agent/knowledge_cards/*.md`
- `agent/output_templates/*.md`
- `agent/tests/cases/*.md`
- `agent/tests/evaluation_checklist.md`

所有输入文件必须是 UTF-8 Markdown。脚本应在文件缺失时失败，并说明缺失路径。

## 生成内容

每个 `case_XX_prompt.md` 包含以下部分：

1. 测试说明：告诉测试者把整份内容复制到目标模型中。
2. 主提示词：来自 `agent/prompts/main_agent.md`。
3. 模块提示词：第一版直接包含全部 7 个模块，保证案例独立完整。
4. 知识卡片：第一版直接包含全部知识卡片，减少路由遗漏。
5. 输出模板：包含全部输出模板，方便模型按场景选择。
6. 测试案例：来自对应的 `agent/tests/cases/*.md`。
7. 回答要求：要求模型按案例目标输出，并遵守真实性边界。

`evaluation_report.md` 包含：

- 测试时间。
- 测试平台和模型。
- 每个案例的通过状态。
- 失败原因。
- 触发的评估清单条目。
- 需要改进的 agent 文件。
- 下一轮修改建议。

## 数据流

```text
现有 agent 资产
  -> 生成脚本读取并校验路径
  -> 按测试案例组合 Markdown
  -> 写入独立 test_runs 目录
  -> 验证脚本检查生成文件完整性
  -> 人工复制到目标模型试跑
  -> 人工填写 evaluation_report.md
```

## 错误处理

- 如果必需输入文件缺失，脚本退出并列出缺失文件。
- 如果输出目录已存在，脚本创建新的时间戳目录，不覆盖旧结果。
- 如果没有找到 6 个测试案例，脚本退出并说明实际数量。
- 如果写入文件失败，脚本退出并显示目标路径。
- 验证脚本只检查结构完整性，不判断模型回答质量。

## 验收标准

- 一条命令能生成一个新的 `agent/test_runs/YYYYMMDD-HHMMSS/` 目录。
- 目录中包含 6 份 `case_XX_prompt.md`。
- 每份案例提示词都包含主提示词、模块提示词、知识卡片、输出模板和对应测试案例。
- `evaluation_report.md` 能记录模型、案例、是否通过、失败原因和改进建议。
- `README.md` 能说明如何复制试跑和如何填写评估报告。
- `agent/tests/verify_agent_pack.ps1` 仍然通过。
- 新增的测试包验证脚本能检查最近一次或指定目录的输出完整性。

## 风险与约束

- 测试包会比较长，复制到某些模型时可能触发上下文长度限制。第一版优先完整性，后续可按案例精简模块和知识卡片。
- 人工评估带有主观性，因此评估报告需要记录失败原因和对应清单条目。
- 因为不调用 API，第一版不能自动判断 agent 输出质量。
- Windows PowerShell 5.1 对 UTF-8 无 BOM 脚本中的中文字符串可能存在编码风险；脚本中应尽量使用 ASCII 输出，中文内容主要来自 Markdown 文件。

## 后续演进

如果 A1 验证顺利，可以继续扩展：

- A2：允许测试者把模型回答粘贴回本地文件，并生成半自动评估记录。
- A3：接入模型 API，自动运行案例并生成报告。
- 增加案例级资产选择，减少每份提示词长度。
- 增加回归测试记录，用于比较多轮提示词修改前后的表现。
