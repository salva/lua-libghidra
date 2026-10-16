// Host-side Saivage compiler regression, not binding runtime/tooling.
// node workflows/check-guidance.mjs <release-root> <instance-root> <scratch-root>
import assert from 'node:assert/strict';
import { cpSync, existsSync, mkdirSync, readFileSync, readdirSync, writeFileSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';

const [release, instance, scratch] = process.argv.slice(2).map(p => resolve(p));
assert(release && instance && scratch, 'Pass release, instance and fresh scratch roots');
assert(!existsSync(scratch), 'Scratch root must be fresh; never overwrite an existing candidate');
const source = dirname(fileURLToPath(import.meta.url));
const files = [
  'fragments/_shared/project-guidance-common.md',
  'fragments/_shared/project-guidance-planner.md',
  'process/test/test-add-coverage.md',
  'process/test/test-verify.md',
];
const load = p => import(pathToFileURL(join(release, 'dist/src', `${p}.js`)));
const { createResolvedConfigAuthority } = await load('config/resolved-config-authority');
const { describeNodeResultContract } = await load('runtime/card-process/card-process-config');
const { renderCompiledPrompt } = await load('utils/prompt-api');
mkdirSync(join(scratch, '.saivage'), { recursive: true });
cpSync(join(instance, '.saivage/config'), join(scratch, '.saivage/config'), { recursive: true });
cpSync(join(instance, '.saivage/saivage.yaml'), join(scratch, '.saivage/saivage.yaml'));
for (const file of files) cpSync(join(source, 'prompts', file), join(scratch, '.saivage/config/prompts', file));

const compile = root => createResolvedConfigAuthority({
  path: join(root, '.saivage/saivage.yaml'), projectRoot: root,
  interpolationEnvironment: process.env,
}).loadEffective();
const before = compile(instance), after = compile(scratch);
assert.deepEqual(after.config, before.config, 'No model, tool, graph, credential or contract changes');
const common = readFileSync(join(source, 'prompts', files[0]), 'utf8');
const planner = readFileSync(join(source, 'prompts', files[1]), 'utf8');
const exactlyOnce = (text, fragment) => assert.equal(text.split(fragment).length - 1, 1);
let roles = 0, nodes = 0;
for (const [type, workflow] of after.workflows.cardTypes) {
  const previous = before.workflows.cardTypes.get(type);
  assert(previous);
  for (const [id, state] of workflow.states) {
    if (state.kind !== 'node') continue;
    const contract = describeNodeResultContract(workflow, id);
    assert.equal(contract, describeNodeResultContract(previous, id));
    const text = renderCompiledPrompt({ kind: 'workflow-agent', cardType: type },
      state.agent.name, state.selectedAgentPrompt.compiled, { contractDescription: contract });
    exactlyOnce(text, common);
    exactlyOnce(text, contract);
    assert(!text.includes('{{'), 'No unresolved template syntax');
    if (state.selectedAgentPrompt.reference === 'planner') exactlyOnce(text, planner);
    else assert(!text.includes(planner), 'Planner policy must not leak as role-specific authority');
    roles++;
  }
  for (const [key, prompt] of workflow.processPrompts) {
    assert(!prompt.text.includes('{{'));
    const previousPrompt = previous.processPrompts.get(key);
    assert(previousPrompt);
    if (!['test-add-coverage', 'test-verify'].includes(prompt.reference)) {
      assert.equal(prompt.text, previousPrompt.text, `Unrelated process prompt ${type}/${key} changed`);
    }
    nodes++;
  }
}
for (const role of ['analyst', 'oversight']) {
  const selected = after.workflows[`${role}Prompt`];
  const text = renderCompiledPrompt({ kind: 'global-agent' }, after.workflows[role].name,
    selected.compiled, { vocabularySnippet: 'validation vocabulary' });
  exactlyOnce(text, common);
  assert(!text.includes(planner));
  assert(!text.includes('{{'));
  roles++;
}
const testText = [...after.workflows.cardTypes.get('test').processPrompts.values()].map(p => p.text).join('\n');
for (const required of ['coherent related batches', 'all currently known remaining required',
  'repair_needed', 'coverage_gap', 'Final suite acceptance belongs to verify']) assert(testText.includes(required), required);
for (const required of ['no fixed', 'existing graph', 'related causes', 'unchanged code',
  'required safety gates', 'status.md', 'No HTTP', 'upstream Python-binding']) assert(common.includes(required), required);

const skillRoot = join(source, '../.github/skills');
const skills = [];
for (const name of readdirSync(skillRoot)) {
  const text = readFileSync(join(skillRoot, name, 'SKILL.md'), 'utf8');
  assert(text.startsWith('---\n'));
  assert(text.includes(`\nname: ${name}\n`));
  assert(/^description: .+/m.test(text));
  assert(/^[a-z0-9]+(-[a-z0-9]+)*$/.test(name) && name.length <= 64);
  skills.push(name);
}
assert.deepEqual(JSON.parse(readFileSync(join(source, '../opencode.json'))).skills, ['./.github/skills']);
const report = { status: 'PASS', renderedRoleBindings: roles, processPrompts: nodes,
  overlay: files, skills, settingsAndContractsUnchanged: true };
writeFileSync(join(scratch, 'guidance-validation.json'), `${JSON.stringify(report, null, 2)}\n`);
console.log(JSON.stringify(report));
