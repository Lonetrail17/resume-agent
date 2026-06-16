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

$banned = @(
  'T' + 'ODO',
  'T' + 'BD',
  ([string][char]0x5F85 + [string][char]0x5B9A),
  ([string][char]0x5360 + [string][char]0x4F4D)
)
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
