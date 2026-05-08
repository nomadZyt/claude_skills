// evals/skills/zacc-requirement-spec/zacc-requirement-spec.assert.js
const fs = require('fs');
const path = require('path');

// __dirname = evals/skills/zacc-requirement-spec/
// 仓库根 = ../../../ → .test-workspace 在仓库根下
const WORKSPACE = path.resolve(__dirname, '../../../.test-workspace');
const FEATURE_NAME = 'bottom-sheet-voice-revamp';
const REQ_FILE = `${WORKSPACE}/docs/requirements/${FEATURE_NAME}.md`;

console.log('=== 正在执行 zacc-requirement-spec 客观断言检查 ===');

try {
  checkUpstreamArtifacts();
  checkRequirementDoc();
  checkNoSpillover();
  checkVerifyScriptEquivalent();

  console.log('✅ 客观断言全部通过！');
  process.exit(0);
} catch (err) {
  console.error(`\n❌ 断言失败: ${err.message}`);
  process.exit(1);
}

function checkUpstreamArtifacts() {
  console.log('-> 检查上游产物骨架...');

  const required = [
    `${WORKSPACE}/CLAUDE.md`,
    `${WORKSPACE}/.claude/AI_RULES.md`,
    `${WORKSPACE}/wiki/index.md`,
    `${WORKSPACE}/wiki/index.json`,
    `${WORKSPACE}/wiki/glossary.md`,
    `${WORKSPACE}/wiki/nodes/component.bottom-sheet.md`,
  ];
  for (const f of required) {
    if (!fs.existsSync(f)) throw new Error(`上游产物缺失: ${f}`);
  }

  const claudeMd = readFile(`${WORKSPACE}/CLAUDE.md`);
  if (!/React|TypeScript|Taro/i.test(claudeMd)) {
    throw new Error('CLAUDE.md 缺少技术栈关键词（React / TypeScript / Taro）');
  }
  if (!/纠错记录/.test(claudeMd)) {
    throw new Error('CLAUDE.md 缺少「纠错记录」章节');
  }

  const aiRules = readFile(`${WORKSPACE}/.claude/AI_RULES.md`);
  if (aiRules.length < 100) throw new Error('.claude/AI_RULES.md 内容过于单薄（<100 字符）');

  const wikiIndexJson = readFile(`${WORKSPACE}/wiki/index.json`);
  let parsed;
  try {
    parsed = JSON.parse(wikiIndexJson);
  } catch (_) {
    throw new Error('wiki/index.json 不是合法 JSON');
  }
  if (!Array.isArray(parsed.nodes) || parsed.nodes.length < 2) {
    throw new Error('wiki/index.json nodes[] 至少应有 2 个节点');
  }

  const bottomSheetNode = readFile(`${WORKSPACE}/wiki/nodes/component.bottom-sheet.md`);
  if (!/##\s+历史包袱|Legacy Constraints/.test(bottomSheetNode)) {
    throw new Error('wiki/nodes/component.bottom-sheet.md 缺少「历史包袱 (Legacy Constraints)」章节');
  }

  console.log('   ✅ 上游产物骨架完整');
}

function checkRequirementDoc() {
  console.log('-> 检查需求文档产物...');

  if (!fs.existsSync(REQ_FILE)) {
    throw new Error(`需求文档未生成: ${REQ_FILE}`);
  }
  const doc = readFile(REQ_FILE);

  assertContains(doc, /^#\s+需求[:：]/m, '一级标题「# 需求：...」缺失');

  assertContains(doc, /^##\s+元数据/m, '`## 元数据 (Meta)` 章节缺失');
  assertContains(doc, /^\|\s*feature-name\s*\|\s*`[a-z0-9-]+`/m, 'Meta: feature-name 字段缺失或非反引号 kebab-case');
  assertContains(doc, /^\|\s*需求类型\s*\|/m, 'Meta: 需求类型 字段缺失');
  assertContains(doc, /^\|\s*估计粒度\s*\|/m, 'Meta: 估计粒度 字段缺失');
  assertContains(doc, /^\|\s*主模块路径\s*\|/m, 'Meta: 主模块路径 字段缺失');
  assertContains(doc, /^\|\s*关联 Wiki 节点\s*\|/m, 'Meta: 关联 Wiki 节点 字段缺失');
  assertContains(doc, /^\|\s*涉及新接口\s*\|/m, 'Meta: 涉及新接口 字段缺失');
  assertContains(doc, /^\|\s*涉及路由变更\s*\|/m, 'Meta: 涉及路由变更 字段缺失');
  assertContains(doc, /^\|\s*涉及全局状态变更\s*\|/m, 'Meta: 涉及全局状态变更 字段缺失');

  const metaMatch = doc.match(/\|\s*feature-name\s*\|\s*`([a-z0-9-]+)`/);
  if (!metaMatch) throw new Error('无法从 Meta 表提取 feature-name 值');
  if (metaMatch[1] !== FEATURE_NAME) {
    throw new Error(`Meta.feature-name (${metaMatch[1]}) 与文件名 (${FEATURE_NAME}) 不一致`);
  }

  assertContains(doc, /^##\s+上游产物摘要/m, '`## 上游产物摘要` 章节缺失');
  ['CLAUDE\\.md', 'AI_RULES\\.md', 'wiki/index\\.json', 'wiki/glossary\\.md'].forEach((n) => {
    assertContains(doc, new RegExp(n), `上游产物摘要缺少 ${n} 行`);
  });
  if (!/(已加载|未找到)/.test(doc)) {
    throw new Error('上游产物摘要缺少状态标注（已加载 / 未找到）');
  }

  const sixSections = ['背景', '现状问题', '改造方案', '验收标准', '受影响文件', '参考代码'];
  sixSections.forEach((s) => {
    assertContains(doc, new RegExp(`^###?\\s+${s}`, 'm'), `子需求六段缺失: ${s}`);
  });

  assertContains(doc, /^##\s+全局约束/m, '`## 全局约束` 章节缺失');
  assertContains(doc, /AI_RULES/, '「全局约束」未引用 AI_RULES.md 红线');

  assertContains(doc, /^##\s+交付说明/m, '`## 交付说明` 章节缺失');
  assertContains(doc, /commit/i, '「交付说明」缺少 commit 相关描述');

  assertContains(doc, /^##\s+待补充信息/m, '`## 待补充信息 (TODO)` 章节缺失');

  const unreplaced = doc.match(/\{[a-z][a-z0-9_-]*\}/g);
  if (unreplaced && unreplaced.length > 0) {
    const sample = [...new Set(unreplaced)].slice(0, 5).join(' ');
    throw new Error(`文档含未替换占位符: ${sample}`);
  }

  console.log('   ✅ 需求文档结构合规');
}

function checkNoSpillover() {
  console.log('-> 检查溢出产物...');

  const tasksDir = `${WORKSPACE}/docs/tasks`;
  if (fs.existsSync(tasksDir)) {
    const entries = fs.readdirSync(tasksDir).filter((f) => !f.startsWith('.'));
    if (entries.length > 0) {
      throw new Error(`docs/tasks/ 非空 (${entries.join(', ')})，本 Skill 不应产出下游文件`);
    }
  }

  const srcDir = `${WORKSPACE}/src`;
  if (fs.existsSync(srcDir)) {
    throw new Error('src/ 被创建，本 Skill 不得改代码');
  }

  console.log('   ✅ 无溢出产物');
}

function checkVerifyScriptEquivalent() {
  console.log('-> 检查关键 grep 契约（与 verify-requirement.sh 对齐）...');
  const doc = readFile(REQ_FILE);

  const mustPatterns = [
    { name: 'Meta feature-name kebab-case', re: /^\|\s*feature-name\s*\|\s*`[a-z0-9-]+`/m },
    { name: 'Meta 主模块路径', re: /^\|\s*主模块路径\s*\|/m },
    { name: 'Meta 关联 Wiki 节点', re: /^\|\s*关联 Wiki 节点\s*\|/m },
    { name: '章节: 背景', re: /^###?\s+背景/m },
    { name: '章节: 现状问题', re: /^###?\s+现状问题/m },
    { name: '章节: 改造方案', re: /^###?\s+改造方案/m },
    { name: '章节: 验收标准', re: /^###?\s+验收标准/m },
    { name: '章节: 受影响文件', re: /^###?\s+受影响文件/m },
  ];
  for (const { name, re } of mustPatterns) {
    if (!re.test(doc)) {
      throw new Error(`verify 等价检查失败: ${name}`);
    }
  }

  console.log('   ✅ verify 等价检查通过');
}

function assertContains(text, re, msg) {
  if (!re.test(text)) {
    throw new Error(msg);
  }
}

function readFile(p) {
  return fs.readFileSync(p, 'utf-8');
}
