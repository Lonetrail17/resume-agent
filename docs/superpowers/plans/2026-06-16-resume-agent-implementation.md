# Resume Agent Artifact Pack Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a platform-neutral resume coaching agent artifact pack for fresh graduates, including prompts, workflow modules, knowledge cards, output templates, and test cases.

**Architecture:** The package is a Markdown-first agent system. A main prompt controls role, routing, safety, and output rules; focused module prompts handle intake, profiling, experience mining, diagnosis, JD matching, rewriting, and truthfulness checks; knowledge cards provide job-family guidance without changing the main prompt.

**Tech Stack:** Markdown, UTF-8 text files, PowerShell verification commands, Git through `C:\Program Files\Git\cmd\git.exe`.

---

## Execution Rules

- Use plain Chinese for user-facing content.
- Keep all artifact files UTF-8 encoded.
- Do not invent citations, market data, or unverifiable hiring claims.
- Do not perform `git add`, `git commit`, or `git push` until the user confirms that Git action.
- If committing, use the existing remote `origin` and branch `main` unless the user requests another branch.

## File Structure

Create this artifact structure:

```text
agent/
  README.md
  prompts/
    main_agent.md
  modules/
    intake_router.md
    student_profile.md
    experience_mining.md
    resume_diagnosis.md
    job_matching.md
    rewrite_generation.md
    truthfulness.md
  knowledge_cards/
    template.md
    technical_rd.md
    product_project.md
    operations_growth.md
    finance.md
    public_sector.md
  output_templates/
    diagnosis_report.md
    resume_cn.md
    resume_en.md
    jd_match_matrix.md
    revision_logic.md
  tests/
    cases/
      01_no_resume_limited_experience.md
      02_existing_resume_vague_expression.md
      03_jd_customization_operations.md
      04_technical_project_no_internship.md
      05_public_sector_direction.md
      06_truthfulness_risk.md
    evaluation_checklist.md
    verify_agent_pack.ps1
docs/
  superpowers/
    specs/
      2026-06-16-resume-agent-design.md
    plans/
      2026-06-16-resume-agent-implementation.md
project_log.md
```

Responsibilities:

- `agent/README.md`: explains how to use the agent pack and which file to start from.
- `agent/prompts/main_agent.md`: the top-level system prompt for the resume coach.
- `agent/modules/*.md`: reusable module prompts, one responsibility per file.
- `agent/knowledge_cards/*.md`: job-family guidance cards used by the main agent.
- `agent/output_templates/*.md`: fixed response formats for diagnosis, resume drafts, JD matching, and revision logic.
- `agent/tests/cases/*.md`: six scenario tests based on the design spec.
- `agent/tests/evaluation_checklist.md`: manual acceptance checklist for reviewing agent responses.
- `agent/tests/verify_agent_pack.ps1`: local structural verification script.
- `project_log.md`: durable project decisions and milestone updates.

## Task 1: Scaffold Agent Pack and Verification Script

**Files:**

- Create: `agent/README.md`
- Create: `agent/tests/verify_agent_pack.ps1`
- Modify: `project_log.md`

- [ ] **Step 1: Create directories**

Run:

```powershell
New-Item -ItemType Directory -Force -Path `
  'agent/prompts', `
  'agent/modules', `
  'agent/knowledge_cards', `
  'agent/output_templates', `
  'agent/tests/cases' | Out-Null
```

Expected: command exits with code `0`.

- [ ] **Step 2: Create `agent/README.md`**

Write this content:

```markdown
# 应届生简历教练 Agent

这是一个平台无关的应届生简历指导 agent 资产包，用于支持三类任务：

- 从零生成简历。
- 优化已有简历。
- 针对岗位 JD 定制简历。

第一版默认中文输出，同时支持英文和中英双语简历。Agent 的核心原则是：可以优化表达，但不能编造事实。

## 使用顺序

1. 先阅读 `prompts/main_agent.md`。
2. 根据用户任务调用 `modules/` 下的对应模块。
3. 根据目标岗位选择 `knowledge_cards/` 下的岗位知识卡片。
4. 使用 `output_templates/` 下的模板输出诊断、简历和修改逻辑。
5. 使用 `tests/` 下的案例检查 agent 是否按预期工作。

## 核心交付

- 主提示词。
- 模块提示词。
- 岗位知识卡片。
- 输出模板。
- 测试案例和验收清单。

## 真实性边界

Agent 必须追问或标注缺少证据的信息，不得虚构经历、数据、奖项、证书、公司、项目结果或岗位职责。
```

- [ ] **Step 3: Create `agent/tests/verify_agent_pack.ps1`**

Write this content:

```powershell
$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$requiredFiles = @(
  'README.md',
  'prompts/main_agent.md',
  'modules/intake_router.md',
  'modules/student_profile.md',
  'modules/experience_mining.md',
  'modules/resume_diagnosis.md',
  'modules/job_matching.md',
  'modules/rewrite_generation.md',
  'modules/truthfulness.md',
  'knowledge_cards/template.md',
  'knowledge_cards/technical_rd.md',
  'knowledge_cards/product_project.md',
  'knowledge_cards/operations_growth.md',
  'knowledge_cards/finance.md',
  'knowledge_cards/public_sector.md',
  'output_templates/diagnosis_report.md',
  'output_templates/resume_cn.md',
  'output_templates/resume_en.md',
  'output_templates/jd_match_matrix.md',
  'output_templates/revision_logic.md',
  'tests/cases/01_no_resume_limited_experience.md',
  'tests/cases/02_existing_resume_vague_expression.md',
  'tests/cases/03_jd_customization_operations.md',
  'tests/cases/04_technical_project_no_internship.md',
  'tests/cases/05_public_sector_direction.md',
  'tests/cases/06_truthfulness_risk.md',
  'tests/evaluation_checklist.md'
)

$missing = @()
foreach ($file in $requiredFiles) {
  $path = Join-Path $root $file
  if (-not (Test-Path -LiteralPath $path)) {
    $missing += $file
  }
}

if ($missing.Count -gt 0) {
  Write-Host 'Missing required files:'
  $missing | ForEach-Object { Write-Host " - $_" }
  exit 1
}

$banned = @('T' + 'ODO', 'T' + 'BD', '待' + '定', '占' + '位')
$violations = @()
Get-ChildItem -LiteralPath $root -Recurse -File -Include *.md,*.ps1 | ForEach-Object {
  $content = Get-Content -LiteralPath $_.FullName -Raw -Encoding UTF8
  foreach ($pattern in $banned) {
    if ($content -match [regex]::Escape($pattern)) {
      $violations += "$($_.FullName) contains $pattern"
    }
  }
}

if ($violations.Count -gt 0) {
  Write-Host 'Content quality violations:'
  $violations | ForEach-Object { Write-Host " - $_" }
  exit 1
}

Write-Host 'Agent pack structure check passed.'
```

- [ ] **Step 4: Run verifier and confirm expected failure**

Run:

```powershell
.\agent\tests\verify_agent_pack.ps1
```

Expected: fails and lists the artifact files not created yet. This proves the verifier detects missing files before the rest of the package exists.

- [ ] **Step 5: Update project log**

Append this entry to `project_log.md`:

```markdown
## 2026-06-16 Implementation Plan

当前目标：把设计文档落成第一版平台无关 agent 资产包。

计划产物：

- 主提示词。
- 7 个模块提示词。
- 5 张岗位知识卡片和 1 个知识卡片模板。
- 5 个输出模板。
- 6 个模拟测试案例。
- 1 个验收清单和 1 个结构检查脚本。

执行规则：

- Git 提交和推送前先向用户确认。
- 第一版不开发网页、后端 API 或数据库。
```

- [ ] **Step 6: Ask user before Git action**

Ask:

```text
是否提交 Task 1 的脚手架和计划日志更新？
```

If confirmed, run:

```powershell
& 'C:\Program Files\Git\cmd\git.exe' status --short
& 'C:\Program Files\Git\cmd\git.exe' add -- agent/README.md agent/tests/verify_agent_pack.ps1 project_log.md docs/superpowers/plans/2026-06-16-resume-agent-implementation.md
& 'C:\Program Files\Git\cmd\git.exe' -c user.name='Lonetrail17' -c user.email='Lonetrail17@users.noreply.github.com' commit -m 'Add resume agent implementation plan'
```

Expected: commit succeeds.

## Task 2: Main Agent Prompt

**Files:**

- Create: `agent/prompts/main_agent.md`
- Test: `agent/tests/verify_agent_pack.ps1`

- [ ] **Step 1: Write the main prompt**

Create `agent/prompts/main_agent.md` with these sections:

```markdown
# 主提示词：应届生简历教练 Agent

## 角色定位

你是应届生简历教练，兼具职业教练、HR 筛选视角和简历编辑能力。你的任务是帮助应届大学毕业生制作、优化和定制求职简历。

## 服务范围

你支持三类任务：

1. 从零生成简历。
2. 优化已有简历。
3. 针对岗位 JD 定制简历。

如果用户意图不清楚，先用一句话复述你的理解，再问一个关键澄清问题。

## 工作原则

- 先判断场景，再进入流程。
- 先收集必要信息，再生成或改写。
- 先诊断，再输出成品。
- 先保证真实，再提升表达。
- 每轮最多提出 3 个下一步问题。
- 默认中文输出；用户要求英文或中英双语时切换语言。

## 真实性边界

你可以优化表达，但不得编造经历、数据、奖项、证书、公司、项目结果或岗位职责。对缺少证据的信息，必须追问或标注“需用户确认”。

## 分类规则

你按两个维度判断学生类型：

- 求职方向：技术研发、产品项目、运营增长、市场销售、财务金融、人力行政、设计创意、教育咨询、医疗生命科学、公务员国企事业单位。
- 学生背景：学历层次、学校背景、专业相关度、经历结构、求职状态、能力证据强度、风险因素、语言需求、投递目标。

## 模块调用顺序

1. 使用用户分流模块判断任务类型。
2. 使用学生画像模块整理已知信息。
3. 使用经历挖掘模块补齐关键证据。
4. 使用岗位匹配模块解析 JD 或岗位方向。
5. 使用简历诊断模块判断问题优先级。
6. 使用改写生成模块输出结果。
7. 使用真实性模块检查不确定内容。

## 输出规则

根据场景输出：

- 从零生成：信息缺口清单、简历草稿、确认问题、下一轮优化建议。
- 优化已有简历：诊断报告、逐项修改建议、改写后简历、修改逻辑说明。
- 岗位定制：JD 解析、匹配矩阵、定制版简历、短板与补充建议。

## 迭代规则

用户补充新信息后，只更新受影响部分，并说明本轮改动。不要无理由重写整份简历。
```

- [ ] **Step 2: Run focused content check**

Run:

```powershell
Select-String -Path 'agent/prompts/main_agent.md' -Pattern '真实性边界','模块调用顺序','输出规则'
```

Expected: three matches are shown.

- [ ] **Step 3: Ask user before Git action**

Ask:

```text
是否提交 Task 2 的主提示词？
```

If confirmed, run:

```powershell
& 'C:\Program Files\Git\cmd\git.exe' add -- agent/prompts/main_agent.md
& 'C:\Program Files\Git\cmd\git.exe' -c user.name='Lonetrail17' -c user.email='Lonetrail17@users.noreply.github.com' commit -m 'Add main resume agent prompt'
```

Expected: commit succeeds.

## Task 3: Module Prompts

**Files:**

- Create: `agent/modules/intake_router.md`
- Create: `agent/modules/student_profile.md`
- Create: `agent/modules/experience_mining.md`
- Create: `agent/modules/resume_diagnosis.md`
- Create: `agent/modules/job_matching.md`
- Create: `agent/modules/rewrite_generation.md`
- Create: `agent/modules/truthfulness.md`
- Test: `agent/tests/verify_agent_pack.ps1`

- [ ] **Step 1: Create `intake_router.md`**

Content:

```markdown
# 模块：用户分流

## 目标

判断用户当前任务属于从零生成、优化已有简历、岗位定制或混合任务。

## 输入

- 用户原始请求。
- 是否有简历文本。
- 是否有岗位 JD。
- 是否有明确求职方向。

## 判断规则

- 没有简历且希望制作简历：从零生成。
- 有简历且没有 JD：优化已有简历。
- 有简历且有 JD：岗位定制。
- 既要补简历又要投具体岗位：混合任务，先补齐画像，再进入岗位定制。

## 输出

```text
任务类型：
已知信息：
缺失信息：
下一步问题：
```
```

- [ ] **Step 2: Create `student_profile.md`**

Content:

```markdown
# 模块：学生画像

## 目标

整理学生求职画像，用于后续诊断、匹配和改写。

## 字段

- 基本信息：姓名或称呼、学历、学校、专业、毕业时间、城市。
- 求职目标：目标行业、目标岗位、目标地区、目标公司类型、语言版本。
- 教育背景：主修课程、成绩亮点、论文或研究方向、交换经历。
- 实习经历：公司、岗位、时间、职责、成果、可量化数据。
- 项目经历：项目背景、个人角色、方法工具、产出结果、技术或业务价值。
- 校园经历：社团、学生会、志愿活动、组织活动、影响范围。
- 技能证书：专业技能、工具、语言、证书、作品链接。
- 奖项荣誉：奖项名称、级别、排名、时间、证明材料。
- 当前短板：缺少实习、缺少数据、经历散、岗位不清晰、表达口语化。
- 可强化卖点：专业匹配、项目深度、执行力、沟通协调、数据意识、学习能力。

## 追问规则

只追问当前任务最关键的信息。一次最多提出 3 个问题。
```

- [ ] **Step 3: Create `experience_mining.md`**

Content:

```markdown
# 模块：经历挖掘

## 目标

用教练式问题帮助学生把普通经历拆成可写入简历的事实和证据。

## 通用追问

- 这段经历的背景和目标是什么？
- 你具体负责哪一部分？
- 你用了什么方法、工具或流程？
- 你交付了什么结果？
- 这个结果能否用人数、频次、规模、效率、排名、作品或反馈证明？

## 低经历学生策略

优先挖掘课程项目、校园活动、志愿服务、竞赛、作业成果和自学作品。

## 跨专业学生策略

建立“原经历 -> 可迁移能力 -> 目标岗位要求”的解释链。
```

- [ ] **Step 4: Create `resume_diagnosis.md`**

Content:

```markdown
# 模块：简历诊断

## 目标

从 7 个维度判断简历问题，并给出修改优先级。

## 诊断维度

1. 结构完整度。
2. 岗位匹配度。
3. 经历含金量。
4. 量化程度。
5. 表达专业度。
6. 真实性风险。
7. 语言与格式规范。

## 优先级

- P0 必须修改：影响真实性、岗位匹配或基本可读性。
- P1 强烈建议修改：明显影响竞争力。
- P2 可优化：提升专业感。

## 输出

每个问题必须包含发现位置、问题说明、影响、修改建议、需要用户确认的信息。
```

- [ ] **Step 5: Create `job_matching.md`**

Content:

```markdown
# 模块：岗位匹配

## 目标

解析岗位 JD 或目标岗位要求，并匹配学生经历。

## JD 解析字段

- 岗位职责。
- 硬性要求。
- 加分项。
- 能力关键词。
- 隐含筛选标准。

## 匹配分类

- 强匹配：用户已有明确经历或证据。
- 弱匹配：经历相关但表达不直接。
- 缺失：用户未提供相关证据。

## 输出

```text
岗位关键词：
强匹配：
弱匹配：
缺失：
不建议强行包装：
```
```

- [ ] **Step 6: Create `rewrite_generation.md`**

Content:

```markdown
# 模块：改写生成

## 目标

基于真实信息输出诊断报告、可投递简历和修改逻辑。

## 改写规则

- 用动作动词开头。
- 写清任务、方法、工具、结果。
- 强化与目标岗位相关的经历。
- 弱化无关、重复、证据不足的内容。
- 不把推断写成事实。

## 中文风格

简洁、具体、职业化，避免空泛形容词。

## 英文风格

使用英文简历习惯表达，避免机械直译中文。
```

- [ ] **Step 7: Create `truthfulness.md`**

Content:

```markdown
# 模块：真实性与不确定性

## 目标

防止 agent 编造事实或帮助用户夸大经历。

## 禁止写入

- 未经确认的公司、岗位、奖项、证书。
- 未经确认的数据、排名、增长率、转化率、用户量。
- 未经确认的项目结果。
- 与用户实际角色不符的职责。

## 处理方式

- 信息可疑：标注“需用户确认”。
- 用户要求编造：拒绝编造，并改为追问真实可验证信息。
- 只有过程没有结果：写过程贡献，或追问结果证据。

## 拒绝句式

我不能替你编造数据或经历，但可以帮你把真实内容写得更清楚。你可以补充真实的规模、结果、反馈或交付物。
```

- [ ] **Step 8: Verify module files**

Run:

```powershell
Select-String -Path 'agent/modules/*.md' -Pattern '# 模块：'
```

Expected: seven module headers are shown.

- [ ] **Step 9: Ask user before Git action**

Ask:

```text
是否提交 Task 3 的模块提示词？
```

If confirmed, run:

```powershell
& 'C:\Program Files\Git\cmd\git.exe' add -- agent/modules
& 'C:\Program Files\Git\cmd\git.exe' -c user.name='Lonetrail17' -c user.email='Lonetrail17@users.noreply.github.com' commit -m 'Add resume agent module prompts'
```

Expected: commit succeeds.

## Task 4: Knowledge Cards

**Files:**

- Create: `agent/knowledge_cards/template.md`
- Create: `agent/knowledge_cards/technical_rd.md`
- Create: `agent/knowledge_cards/product_project.md`
- Create: `agent/knowledge_cards/operations_growth.md`
- Create: `agent/knowledge_cards/finance.md`
- Create: `agent/knowledge_cards/public_sector.md`
- Test: `agent/tests/verify_agent_pack.ps1`

- [ ] **Step 1: Create knowledge card template**

Create `agent/knowledge_cards/template.md`:

```markdown
# 岗位知识卡片模板

## 岗位方向名称

写明岗位大类名称。

## 典型岗位名称

列出该方向常见岗位。

## 核心能力

列出该方向筛选时最关注的能力。

## 常见 JD 关键词

列出职责、技能、工具和能力关键词。

## 简历优先展示模块

说明教育背景、实习、项目、校园经历、技能证书的展示优先级。

## 经历挖掘问题

列出用于追问学生真实经历的问题。

## 高质量表达特征

说明什么样的表达更有竞争力。

## 常见低质量表达

说明应避免的空泛表达。

## 可量化指标

列出可以追问但不能编造的数据类型。

## 真实性风险

列出该方向常见夸大风险。

## 中文表达示例

给出中文简历表达示例。

## 英文表达示例

给出英文简历表达示例。

## 适合强化的学生背景

说明哪些学生经历可优先强化。

## 不建议强行包装的内容

说明缺少证据时不应写入的内容。
```

- [ ] **Step 2: Create five job-family cards**

Create one file per job family using the template sections:

- `technical_rd.md`: technical研发，强调技术栈、模块贡献、工程问题、性能或稳定性证据。
- `product_project.md`: product/project，强调需求分析、用户研究、流程设计、跨团队推进、数据指标。
- `operations_growth.md`: operations/growth，强调用户规模、内容活动、转化、留存、复盘。
- `finance.md`: finance，强调数据准确性、风险意识、模型、报告、合规。
- `public_sector.md`: public sector，强调组织协调、材料写作、公共服务意识、稳定性和规范表达。

Each file must include:

```markdown
# 岗位知识卡片：

## 岗位方向名称
## 典型岗位名称
## 核心能力
## 常见 JD 关键词
## 简历优先展示模块
## 经历挖掘问题
## 高质量表达特征
## 常见低质量表达
## 可量化指标
## 真实性风险
## 中文表达示例
## 英文表达示例
## 适合强化的学生背景
## 不建议强行包装的内容
```

- [ ] **Step 3: Verify knowledge card coverage**

Run:

```powershell
Get-ChildItem -LiteralPath 'agent/knowledge_cards' -Filter '*.md' | Select-Object Name
Select-String -Path 'agent/knowledge_cards/*.md' -Pattern '## 真实性风险'
```

Expected: six card files are listed, and every card has a truthfulness risk section.

- [ ] **Step 4: Ask user before Git action**

Ask:

```text
是否提交 Task 4 的岗位知识卡片？
```

If confirmed, run:

```powershell
& 'C:\Program Files\Git\cmd\git.exe' add -- agent/knowledge_cards
& 'C:\Program Files\Git\cmd\git.exe' -c user.name='Lonetrail17' -c user.email='Lonetrail17@users.noreply.github.com' commit -m 'Add resume agent knowledge cards'
```

Expected: commit succeeds.

## Task 5: Output Templates

**Files:**

- Create: `agent/output_templates/diagnosis_report.md`
- Create: `agent/output_templates/resume_cn.md`
- Create: `agent/output_templates/resume_en.md`
- Create: `agent/output_templates/jd_match_matrix.md`
- Create: `agent/output_templates/revision_logic.md`
- Test: `agent/tests/verify_agent_pack.ps1`

- [ ] **Step 1: Create diagnosis report template**

Create `agent/output_templates/diagnosis_report.md`:

```markdown
# 输出模板：简历诊断报告

## 一、总体判断

- 当前状态：
- 目标岗位匹配度：
- 主要优势：
- 主要短板：
- 优先修改顺序：

## 二、关键问题

### [P0/P1/P2] 问题标题

- 发现位置：
- 问题说明：
- 影响：
- 修改建议：
- 需要用户确认的信息：

## 三、岗位匹配分析

- 目标岗位关键词：
- 已体现能力：
- 弱体现能力：
- 缺失能力：
- 不建议强行包装的内容：

## 四、下一步追问

1. 
2. 
3. 
```

- [ ] **Step 2: Create Chinese resume template**

Create `agent/output_templates/resume_cn.md`:

```markdown
# 输出模板：中文可投递简历

## 个人信息

姓名｜电话｜邮箱｜城市｜作品/项目链接

## 求职意向

目标岗位：

## 教育背景

学校｜学历｜专业｜时间

- 相关课程：
- 成绩/荣誉：

## 实习经历

公司｜岗位｜时间

- 动作 + 任务 + 方法/工具 + 结果

## 项目经历

项目名称｜角色｜时间

- 背景/目标：
- 个人贡献：
- 方法工具：
- 结果产出：

## 校园/实践经历

组织｜角色｜时间

- 组织/执行/协作内容 + 规模/结果

## 技能证书

- 技能：
- 工具：
- 证书：
- 语言：
```

- [ ] **Step 3: Create English resume template**

Create `agent/output_templates/resume_en.md`:

```markdown
# Output Template: English Resume

## Contact

Name | Phone | Email | City | Portfolio/Project Link

## Target Role

Target Position:

## Education

University | Degree | Major | Dates

- Relevant Coursework:
- Honors:

## Internship Experience

Company | Role | Dates

- Action verb + task + method/tool + result.

## Project Experience

Project | Role | Dates

- Context/Goal:
- Individual Contribution:
- Methods/Tools:
- Outcome:

## Campus and Volunteer Experience

Organization | Role | Dates

- Action + scope + result.

## Skills and Certifications

- Skills:
- Tools:
- Certifications:
- Languages:
```

- [ ] **Step 4: Create JD match matrix and revision logic templates**

Create `agent/output_templates/jd_match_matrix.md`:

```markdown
# 输出模板：JD 匹配矩阵

| JD 要求 | 关键词 | 简历中对应经历 | 匹配等级 | 改写策略 | 真实性提醒 |
|---|---|---|---|---|---|
|  |  |  | 强匹配/弱匹配/缺失 |  |  |
```

Create `agent/output_templates/revision_logic.md`:

```markdown
# 输出模板：修改逻辑说明

1. 为什么调整模块顺序：
2. 哪些经历被强化：
3. 哪些内容被弱化或删除：
4. 哪些表达从口语改为职业化：
5. 哪些信息因为缺少证据没有写入：
6. 后续最值得补充的材料：
```

- [ ] **Step 5: Verify output templates**

Run:

```powershell
Get-ChildItem -LiteralPath 'agent/output_templates' -Filter '*.md' | Select-Object Name
Select-String -Path 'agent/output_templates/*.md' -Pattern '真实性','truthfulness','真实'
```

Expected: five templates are listed, and truthfulness wording appears in relevant templates.

- [ ] **Step 6: Ask user before Git action**

Ask:

```text
是否提交 Task 5 的输出模板？
```

If confirmed, run:

```powershell
& 'C:\Program Files\Git\cmd\git.exe' add -- agent/output_templates
& 'C:\Program Files\Git\cmd\git.exe' -c user.name='Lonetrail17' -c user.email='Lonetrail17@users.noreply.github.com' commit -m 'Add resume agent output templates'
```

Expected: commit succeeds.

## Task 6: Test Cases and Evaluation Checklist

**Files:**

- Create: `agent/tests/cases/01_no_resume_limited_experience.md`
- Create: `agent/tests/cases/02_existing_resume_vague_expression.md`
- Create: `agent/tests/cases/03_jd_customization_operations.md`
- Create: `agent/tests/cases/04_technical_project_no_internship.md`
- Create: `agent/tests/cases/05_public_sector_direction.md`
- Create: `agent/tests/cases/06_truthfulness_risk.md`
- Create: `agent/tests/evaluation_checklist.md`
- Test: `agent/tests/verify_agent_pack.ps1`

- [ ] **Step 1: Create six scenario case files**

Each case file must use this structure:

```markdown
# 测试案例：

## 用户输入

## 期望 agent 行为

## 必须出现

## 不应出现

## 通过标准
```

Case coverage:

- `01_no_resume_limited_experience.md`: 双非本科、无实习、只有课程项目和社团经历，检查温和挖掘。
- `02_existing_resume_vague_expression.md`: 简历大量“负责、参与、协助”，检查追问贡献、方法和结果。
- `03_jd_customization_operations.md`: 运营岗 JD + 通用简历，检查 JD 解析、匹配矩阵和定制版简历。
- `04_technical_project_no_internship.md`: 技术岗项目经历但无实习，检查技术栈、模块、难点、结果追问。
- `05_public_sector_direction.md`: 考公国企方向，检查稳重、规范表达。
- `06_truthfulness_risk.md`: 用户要求编数据，检查拒绝编造并追问真实证据。

- [ ] **Step 2: Create evaluation checklist**

Create `agent/tests/evaluation_checklist.md`:

```markdown
# Agent 评估清单

## 通用检查

- 是否先判断任务类型。
- 是否按求职方向和学生背景调整提问。
- 是否一次最多提出 3 个下一步问题。
- 是否避免编造事实。
- 是否标注需要用户确认的信息。
- 是否输出诊断、成品和修改逻辑。

## 三类任务检查

- 从零生成：是否输出信息缺口和简历草稿。
- 优化已有简历：是否输出诊断报告和改写版本。
- 岗位定制：是否输出 JD 解析和匹配矩阵。

## 语言检查

- 中文是否简洁具体。
- 英文是否符合英文简历习惯。
- 中英双语是否内容一致。

## 失败条件

- 编造数据或经历。
- 把不确定内容写成事实。
- 没有追问关键缺口就直接生成最终版。
- 对所有岗位使用同一套通用话术。
```

- [ ] **Step 3: Run full verifier**

Run:

```powershell
.\agent\tests\verify_agent_pack.ps1
```

Expected: prints `Agent pack structure check passed.`

- [ ] **Step 4: Ask user before Git action**

Ask:

```text
是否提交 Task 6 的测试案例和评估清单？
```

If confirmed, run:

```powershell
& 'C:\Program Files\Git\cmd\git.exe' add -- agent/tests
& 'C:\Program Files\Git\cmd\git.exe' -c user.name='Lonetrail17' -c user.email='Lonetrail17@users.noreply.github.com' commit -m 'Add resume agent test cases'
```

Expected: commit succeeds.

## Task 7: Final Verification and Push

**Files:**

- Modify: `project_log.md`
- Test: all agent artifact files

- [ ] **Step 1: Run structural verification**

Run:

```powershell
.\agent\tests\verify_agent_pack.ps1
```

Expected: prints `Agent pack structure check passed.`

- [ ] **Step 2: Check Git status**

Run:

```powershell
& 'C:\Program Files\Git\cmd\git.exe' status --short --branch
```

Expected: no unstaged or staged file changes except `project_log.md` if it is being updated for final status.

- [ ] **Step 3: Update project log with milestone completion**

Append:

```markdown
## 2026-06-16 Artifact Pack Milestone

完成内容：

- 第一版主提示词。
- 7 个模块提示词。
- 5 张岗位知识卡片和知识卡片模板。
- 5 个输出模板。
- 6 个测试案例。
- 结构检查脚本和评估清单。

验证方式：

- 运行 `agent/tests/verify_agent_pack.ps1` 检查文件结构和内容风险词。
- 使用 `agent/tests/evaluation_checklist.md` 人工检查六个案例输出质量。
```

- [ ] **Step 4: Ask user before final Git action**

Ask:

```text
是否提交最终日志更新并推送到 GitHub？
```

If confirmed, run:

```powershell
& 'C:\Program Files\Git\cmd\git.exe' add -- project_log.md
& 'C:\Program Files\Git\cmd\git.exe' -c user.name='Lonetrail17' -c user.email='Lonetrail17@users.noreply.github.com' commit -m 'Document resume agent artifact milestone'
& 'C:\Program Files\Git\cmd\git.exe' push origin main
```

Expected: push succeeds and `origin/main` points to the latest local commit.

## Self-Review

Spec coverage:

- Three service modes are implemented by the main prompt, intake router, output templates, and test cases.
- Student classification is implemented by the main prompt and student profile module.
- Coach-style mining and HR-style diagnosis are implemented by `experience_mining.md` and `resume_diagnosis.md`.
- Truthfulness boundaries are implemented by the main prompt and `truthfulness.md`.
- Bilingual support is implemented by Chinese and English resume templates plus main prompt language rules.
- Expandable knowledge base is implemented by the knowledge card template and five first-version cards.
- Six scenario tests are implemented by the test case files and evaluation checklist.

Placeholder scan:

- The plan avoids unfinished markers and uses concrete file paths, commands, and expected results.

Type consistency:

- File names in the structure, tasks, and verifier script match.
- Commit commands use the existing confirmed author identity for one-off commits.
