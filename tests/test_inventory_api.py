"""Structural inventory regressions; no mock/native runtime success claims."""
import importlib.util
import json
import os
import shutil
import tempfile
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
spec = importlib.util.spec_from_file_location('inventory_api', ROOT/'scripts/inventory-api.py')
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)


class InventoryTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.data = module.inventory(module.DEFAULT)
        cls.ops = {o['name']: o for o in cls.data['operations']}

    def test_definition_extractor_rejects_call_and_literal_brace_confusion(self):
        from inventory_semantics import body
        source = ('void caller() { helper(x); if (x) { unrelated(); } }\n'
                  '// helper(int x) { decoy }\n'
                  'void helper(int x) { const char* s="}"; /* } */ '
                  'const char* r=R"tag({ } })tag"; if(x) { run(); } }')
        start,text=body(source,'helper(')
        self.assertEqual(start,source.index('helper(int x)',source.index('void helper')))
        self.assertTrue(text.endswith('if(x) { run(); } }'))
        with self.assertRaises(AssertionError):
            body('void caller() { helper(x); if(x) { wrong(); } }','helper(')
        with self.assertRaises(AssertionError):
            body('void helper() {} void helper() {}','helper(')
        with self.assertRaises(AssertionError):
            body('void helper() {','helper(')
        # Nanobind lambda prefixes remain a supported explicit consumer.
        self.assertEqual(body('.def("x", [](int x) { return x; })','.def("x", []')[1],'{ return x; }')

    def test_nested_request_consumption_has_explicit_review_and_gaps(self):
        audit=self.data['request_audit']
        self.assertEqual(audit['nested_field_review_count'],20)
        self.assertEqual(audit['direct_argument_review_missing'],[])
        self.assertTrue(self.data['unresolved'])  # Request closure is not runtime or final grammar qualification.
        fields={f['name']:f for f in self.ops['OpenProgram']['request'][0]['nested_fields']}
        self.assertIn('never read',fields['project_name']['semantics'])
        self.assertIn('project route ignores',fields['base_address']['semantics'])
        self.assertIn('compiler_spec_id then not appended',fields['language_id']['semantics'])
        for name in ['OpenProgram','AddPerfBenchmark','PatchBytesBatch']:
            for a in self.ops[name]['request']:
                for f in a['nested_fields']:
                    self.assertIn('must not be inferred',f['request_field_review']['native_absence'])

    def test_page_argument_domains_are_not_native_unbounded_defaults(self):
        self.assertEqual(len(self.data['request_audit']['direct_arguments_reviewed']),156)
        for op in self.ops.values():
            if 'page_wrapper_review' not in op:continue
            args={a['name']:a for a in op['request']}
            self.assertIn('reject zero/negative',args['limit']['semantics'])
            self.assertIn('offset>=n yields empty',args['offset']['semantics'])
            self.assertIn('offset+limit<=INT_MAX',args['offset']['semantics'])
            self.assertIn('validation-only',args['limit']['semantics'])

    def test_range_consumption_and_constant_empty_exception(self):
        args={a['name']:a for a in self.ops['ListXrefs']['request']}
        self.assertIn('function ENTRY',args['range_end']['semantics'])
        self.assertIn('cannot select only address zero',args['range_end']['semantics'])
        self.assertIn('start>end',args['range_start']['semantics'])
        for a in self.ops['ListDefinedStrings']['request']:
            self.assertTrue(a['ignored'])
            self.assertIn('no discovery iterator',a['semantics'])
        args={a['name']:a for a in self.ops['ListInstructions']['request']}
        self.assertIn('beginning exactly at range_start',args['range_start']['semantics'])

    def test_query_and_ignored_argument_consumption(self):
        for name in ['ListTypes','ListTypeAliases','ListTypeEnums','ListTypeUnions']:
            q=next(a for a in self.ops[name]['request'] if a['name']=='query')
            self.assertIn('case-sensitive byte substring',q['semantics'])
            self.assertIn('not optionality proof',q['semantics'])
        for name,key in [('DeleteSymbol','name_filter'),('CreateTypeEnum','width'),('GetDecompilation','timeout_ms')]:
            a=next(a for a in self.ops[name]['request'] if a['name']==key)
            self.assertTrue(a['ignored'])
            self.assertIn('never read',a['semantics'])

    def test_byte_domains_and_distinct_type_lookup_inputs(self):
        args={a['name']:a for a in self.ops['ReadBytes']['request']}
        self.assertIn('0..INT32_MAX',args['length']['semantics'])
        self.assertIn('request-buffer allocation',args['length']['semantics'])
        self.assertIn('not all-range sentinel',args['address']['semantics'])
        arg=self.ops['GetType']['request'][0]
        self.assertEqual(arg['name'],'path')
        self.assertIn('parameter name',arg['semantics'])
        self.assertIn('NO leading-slash removal',arg['semantics'])
        self.assertIn('ONE leading slash',self.ops['ListTypeMembers']['request'][0]['semantics'])
        self.assertIn('empty input still dispatched',self.ops['WriteBytes']['request'][1]['semantics'])

    def test_factory_fields_have_consumption_and_owner_failure_slots(self):
        fields={f['name']:f for f in self.data['lifecycle']['factory_fields']}
        self.assertEqual(set(fields),{'ghidra_root','state_path','default_arch','pool_size'})
        self.assertIn('exactly 1',fields['pool_size']['semantics'])
        self.assertIn('BEFORE conversion',fields['pool_size']['semantics'])
        self.assertIn('return ignored',fields['state_path']['semantics'])
        self.assertIn('not detected architecture',fields['default_arch']['semantics'])
        for f in fields.values():
            self.assertIn('exceptions may escape',f['factory_review']['lifecycle'])
            self.assertIn('unqualified',f['factory_review']['qualification'])

    def test_member_keys_and_signed_parameter_ordinals(self):
        def arg(op,key):
            return next(a for a in self.ops[op]['request'] if a['name']==key)
        self.assertIn('zero-based current adapter traversal',arg('DeleteTypeMember','ordinal')['semantics'])
        self.assertIn('exact UInt64',arg('RenameTypeEnumMember','ordinal')['semantics'])
        self.assertIn('no existence/kind/range validation',arg('SetTypeMemberComment','ordinal')['semantics'])
        self.assertIn('remove exactly one leading slash',arg('SetTypeEnumMemberComment','type_id_or_path')['semantics'])
        self.assertIn('signed Lua integer',arg('RenameFunctionParameter','ordinal')['semantics'])
        self.assertIn('OUT_OF_RANGE',arg('SetFunctionParameterType','ordinal')['semantics'])
        self.assertIn('count <=INT_MAX',arg('SetFunctionParameterType','ordinal')['semantics'])

    def test_mutation_payloads_distinguish_text_and_signed_values(self):
        def sem(op,key):
            return next(a['semantics'] for a in self.ops[op]['request'] if a['name']==key)
        self.assertIn('INT64_MIN..INT64_MAX',sem('SetTypeEnumMemberValue','value'))
        self.assertIn('modulo 2^64',sem('SetTypeEnumMemberValue','value'))
        self.assertIn('not delete/absence',sem('SetTypeMemberComment','comment'))
        self.assertIn('no escaping/quoting',sem('RenameFunctionParameter','new_name'))
        self.assertIn('LocalClient new_type',sem('SetFunctionParameterType','data_type'))
        self.assertIn('not normalized path/ID',sem('SetTypeMemberType','member_type'))
        self.assertIn('whole struct reconstruction',sem('RenameTypeMember','new_name'))

    def test_alias_inputs_are_not_all_normalized_paths(self):
        def sem(op,key):
            return next(a['semantics'] for a in self.ops[op]['request'] if a['name']==key)
        self.assertIn('LocalClient alias_name',sem('CreateTypeAlias','name'))
        self.assertIn('NO slash stripping',sem('CreateTypeAlias','target_type'))
        self.assertIn('exactly ONE',sem('DeleteTypeAlias','type_id_or_path'))
        self.assertIn('NO target slash stripping',sem('SetTypeAliasTarget','target_type'))
        self.assertIn('may be lost',sem('SetTypeAliasTarget','target_type'))
        self.assertIn('not explicit adapter core guard',sem('DeleteType','type_id_or_path'))
        self.assertIn('NO new-name slash stripping',sem('RenameType','new_name'))

    def test_creation_payloads_and_missing_parent_are_not_assumed(self):
        def sem(op,key):
            return next(a['semantics'] for a in self.ops[op]['request'] if a['name']==key)
        self.assertIn('EXACT case-sensitive',sem('CreateType','kind'))
        self.assertIn('EMPTY entries',sem('CreateTypeEnum','name'))
        self.assertIn('LocalClient parent',sem('AddTypeMember','parent_type_id_or_path'))
        self.assertIn('NOT explicitly rejected',sem('AddTypeEnumMember','type_id_or_path'))
        self.assertIn('modulo 2^64',sem('AddTypeEnumMember','value'))
        self.assertIn('no alignment/padding',sem('AddTypeMember','member_type'))

    def test_local_and_data_payloads_preserve_syntax_and_opaque_ids(self):
        def sem(op,key):
            return next(a['semantics'] for a in self.ops[op]['request'] if a['name']==key)
        self.assertIn('opaque local ID',sem('RenameFunctionLocal','local_id'))
        self.assertIn('LocalClient new_type',sem('SetFunctionLocalType','data_type'))
        self.assertIn('INVALID_TYPE distinguished',sem('SetFunctionLocalType','data_type'))
        self.assertIn('non-function NOT_SUPPORTED',sem('RenameSymbol','new_name'))
        self.assertIn('sets namelock',sem('RenameDataItem','new_name'))
        self.assertIn('complete prototype syntax',sem('SetFunctionSignature','prototype'))
        self.assertIn('DAT_',sem('ApplyDataType','data_type'))

    def test_policy_comment_and_benchmark_keys(self):
        def sem(op,key):
            return next(a['semantics'] for a in self.ops[op]['request'] if a['name']==key)
        self.assertIn('ONLY kSave',sem('CloseProgram','policy'))
        self.assertIn('already unloaded succeeds',sem('Shutdown','policy'))
        self.assertIn('NOT remote host termination',sem('Shutdown','policy'))
        self.assertIn('no implicit eol default',sem('DeleteComment','kind'))
        self.assertIn('NOT deletion/absence',sem('SetComment','text'))
        self.assertIn('successful deleted=false',sem('DeletePerfBenchmark','bench_id'))

    def test_all_literal_address_consumers_close_request_ledger(self):
        self.assertEqual(self.data['request_audit']['direct_argument_review_missing'],[])
        reviewed=self.data['request_audit']['direct_arguments_reviewed']
        self.assertEqual(len({(r['operation'],r['path']) for r in reviewed}),156)
        for name in ['GetFunction','GetInstruction','GetSymbol','GetDecompilation','RenameFunctionLocal','SetComment']:
            arg=next(a for a in self.ops[name]['request'] if a['name']=='address')
            self.assertIn('ZERO IS LITERAL',arg['semantics'])
            self.assertIn('unqualified',arg['semantics'])
            self.assertIn('dispatch_tokens',arg['direct_argument_review'])
        sem=next(a['semantics'] for a in self.ops['GetFunction']['request'] if a['name']=='address')
        self.assertIn('actual entry',sem)

    def test_preserved_red_reproducer(self):
        # Exact acceptance trigger from red; stronger checks below prevent treating
        # mere existence as exhaustive semantic acceptance.
        artifacts = sorted((ROOT/'api').glob('coverage.*'))
        self.assertTrue(artifacts, 'M0 inventory gap: api/coverage.* absent')

    def test_generated_artifact_matches_current_sources(self):
        self.assertEqual(self.data, json.loads((ROOT/'api/coverage.json').read_text()))

    def test_overrides_defaults_and_nested_fields(self):
        self.assertEqual(len(self.ops), 110)
        self.assertEqual(sum(o['implementation'] is not None for o in self.ops.values()), 70)
        self.assertIsNone(self.ops['DeleteTypeEnum']['implementation'])
        self.assertEqual(self.ops['DeleteTypeEnum']['tier'], 'excluded')
        open_fields = self.ops['OpenProgram']['request'][0]['nested_fields']
        self.assertEqual({f['path'] for f in open_fields}, {
            'project_path', 'project_name', 'program_path', 'read_only',
            'language_id', 'compiler_spec_id', 'format', 'base_address'})
        f = next(f for f in self.ops['GetFunction']['response']['fields']
                 if f['path'] == 'function.entry_address')
        self.assertEqual(f['lua'], 'exact UInt64')
        for o in self.ops.values():
            for side in ['positive', 'negative']:
                self.assertEqual(o['evidence'][side]['status'], 'unqualified')

    def test_required_exceptions_remain_explicit(self):
        self.assertIn('INT32_MAX', ' '.join(self.ops['ReadBytes']['limitations']))
        self.assertIn('no discovery iterator', self.ops['ListDefinedStrings']['facade'])
        self.assertEqual(self.ops['ListFunctionSignatures']['pagination']['cursor_domain'], 'candidate functions')
        self.assertEqual(self.ops['DeleteSymbol']['ignored_fields'], ['name_filter'])
        self.assertEqual(self.ops['CreateTypeEnum']['ignored_fields'], ['width', 'is_signed'])
        self.assertTrue(self.ops['ListInstructions']['pagination']['range_zero_end'])
        self.assertEqual(self.ops['CloseProgram']['dispatch'], 'lifecycle')
        self.assertEqual(self.ops['WriteBytes']['dispatch'], 'mutation')
        local = [r for r in self.data['python'] if r['file'].endswith('/local.py') and 'method' in r and not r['method'].startswith('_')]
        self.assertEqual(len(local), 27)
        self.assertTrue(all(r['native_operation'] for r in local))

    def test_reviewed_page_contracts(self):
        types = self.ops['ListTypes']['pagination']
        self.assertEqual(types['identity']['fields'], ['path_name'])
        self.assertIn('dependentOrder', types['order'])
        self.assertEqual(types['post_page_filter'], 'none')
        self.assertIn('synthetic', self.ops['ListMemoryBlocks']['pagination']['order'])
        self.assertIn('limit+offset', self.ops['ListInstructions']['pagination']['scan_bound'])
        self.assertIn('query-dependent', types['pre_page_filter'])
        for name in ['ListFunctions', 'ListSymbols', 'ListInstructions']:
            self.assertTrue(self.ops[name]['pagination']['range_zero_end'])
        python = next(r for r in self.data['python'] if r.get('method')=='list_functions' and r['file'].endswith('/local.py'))
        self.assertTrue(python['calls'])
        self.assertTrue(python['returns'])

    def test_independent_source_mutations_detect_field_and_cursor_drift(self):
        # Disposable copies must not touch native inputs or use root siblings.
        work = Path(os.environ['SAIVAGE_CARD_WORK_ROOT'])/'inventory-drift-tests'
        work.mkdir(parents=True, exist_ok=True)
        with tempfile.TemporaryDirectory(dir=work) as directory:
            root = Path(directory)
            for relative in self.data['sources']:
                destination = root/relative
                destination.parent.mkdir(parents=True, exist_ok=True)
                shutil.copyfile(module.DEFAULT/relative, destination)
            models = root/'cpp/include/libghidra/models.hpp'
            original = models.read_text()
            models.write_text(original.replace('struct FunctionRecord {', 'struct FunctionRecord {\n  std::uint64_t added_probe = 0;'))
            changed = module.inventory(root)
            fields = {f['name'] for f in changed['types']['FunctionRecord']['fields']}
            self.assertIn('added_probe', fields)
            self.assertNotEqual(changed, self.data)
            models.write_text(original)
            local = root/'cpp/src/local_client.cpp'
            local_original = local.read_text()
            local.write_text(local_original.replace('limit + offset', 'limit'))
            with self.assertRaises(AssertionError):
                module.inventory(root)
            local.write_text(local_original)
            local.write_text(local_original.replace('name = name.substr(1)', 'name = name.substr(2)'))
            with self.assertRaises(AssertionError):
                module.inventory(root)
            local.write_text(local_original)
            # Missing-signature filtering must not silently disappear on regeneration.
            local.write_text(local_original.replace('if (sig) sigs.push_back', 'if (true) sigs.push_back'))
            with self.assertRaises(AssertionError):
                module.inventory(root)
            local.write_text(local_original)
            local.write_text(local_original.replace('if (deleted) revision_++', 'revision_++'))
            with self.assertRaises(AssertionError):
                module.inventory(root)
            local.write_text(local_original)
            pool = root/'cpp/src/decompiler_pool.cpp'
            pool_original = pool.read_text()
            pool.write_text(pool_original.replace('slot.adapter.reset();', 'slot.adapter.reset(); slot.decomp.reset();'))
            with self.assertRaises(AssertionError):
                module.inventory(root)
            pool.write_text(pool_original)
            bindings = root/'cpp/bindings/python_bindings.cpp'
            bindings_original = bindings.read_text()
            bindings.write_text(bindings_original.replace('return unwrap(self.SaveProgram()).saved;', 'return unwrap(self.SaveProgram()).discarded;'))
            with self.assertRaises(AssertionError):
                module.inventory(root)
            bindings.write_text(bindings_original)
            local.write_text(local_original.replace('ordinal < 0 || ordinal >=', 'ordinal >= '))
            with self.assertRaises((AssertionError, ValueError)):
                module.inventory(root)
            local.write_text(local_original)
            local.write_text(local_original.replace('total_bytes += static_cast<std::uint32_t>(patch.data.size())', 'total_bytes = static_cast<std::uint32_t>(patch.data.size())'))
            with self.assertRaises(AssertionError):
                module.inventory(root)
            local.write_text(local_original)
            local.write_text(local_original.replace('if (i == ordinal) continue;', 'if (i != ordinal) continue;'))
            with self.assertRaises(AssertionError):
                module.inventory(root)
            local.write_text(local_original)
            adapter = root/'cpp/src/local_arch_adapter.cpp'
            adapter_original = adapter.read_text()
            adapter.write_text(adapter_original.replace('type_member_comments_[{type_name, ordinal}] = comment;', 'type_member_comments_[{type_name, ordinal + 1}] = comment;'))
            with self.assertRaises(AssertionError):
                module.inventory(root)
            adapter.write_text(adapter_original)
            local.write_text(local_original.replace('hs.ok = (pool_ != nullptr)', 'hs.ok = program_loaded_'))
            with self.assertRaises(AssertionError):
                module.inventory(root)
            local.write_text(local_original)
            adapter.write_text(adapter_original.replace('comments_.erase({address, kind}) > 0', 'comments_.erase({address, kind}) >= 0'))
            with self.assertRaises(AssertionError):
                module.inventory(root)
            adapter.write_text(adapter_original)
            local.write_text(local_original.replace('sym->type == "function"', 'sym->type != "function"'))
            with self.assertRaises(AssertionError):
                module.inventory(root)
            local.write_text(local_original)
            adapter.write_text(adapter_original.replace('arch_->types->findByName(name)', 'arch_->types->findByName(name.substr(1))'))
            with self.assertRaises(AssertionError):
                module.inventory(root)
            adapter.write_text(adapter_original)
            local.write_text(local_original.replace('resp.decompilation->error_message = dl.error', 'resp.decompilation->error_message = pool_->getError()'))
            with self.assertRaises(AssertionError):
                module.inventory(root)
            local.write_text(local_original)
            local.write_text(local_original.replace('d.size > 0 ? d.address + d.size - 1 : d.address', 'd.address + d.size'))
            with self.assertRaises(AssertionError):
                module.inventory(root)
            local.write_text(local_original)
            local.write_text(local_original.replace('auto func_xrefs =\n            pool_->primaryAdapter().listXrefsForFunction', 'pool_->primary().decompileAt(func.entry_address);\n        auto func_xrefs =\n            pool_->primaryAdapter().listXrefsForFunction'))
            with self.assertRaises(AssertionError):
                module.inventory(root)
            local.write_text(local_original)
            adapter.write_text(adapter_original.replace('rec.size = rec.end_address + 1', 'rec.size = rec.end_address'))
            with self.assertRaises(AssertionError):
                module.inventory(root)
            adapter.write_text(adapter_original)
            adapter.write_text(adapter_original.replace('rec.symbol_id = id_counter++', 'rec.symbol_id = 0'))
            with self.assertRaises(AssertionError):
                module.inventory(root)
            adapter.write_text(adapter_original)
            adapter.write_text(adapter_original.replace('rec.type_id = id_counter++', 'rec.type_id = 0'))
            with self.assertRaises(AssertionError):
                module.inventory(root)
            adapter.write_text(adapter_original)
            adapter.write_text(adapter_original.replace('rec.declaration = "typedef " + target->getName() + " " + dt->getName()', 'rec.declaration = dt->getName()'))
            with self.assertRaises(AssertionError):
                module.inventory(root)
            adapter.write_text(adapter_original)
            adapter.write_text(adapter_original.replace('prec.formal_data_type = prec.data_type', 'prec.formal_data_type = "formal"'))
            with self.assertRaises(AssertionError):
                module.inventory(root)
            adapter.write_text(adapter_original)
            adapter.write_text(adapter_original.replace('ret_type ? ret_type->getName() : "void"', 'ret_type ? ret_type->getName() : "undefined"'))
            with self.assertRaises(AssertionError):
                module.inventory(root)
            adapter.write_text(adapter_original)
            adapter.write_text(adapter_original.replace('if (rec.name.empty()) rec.name = rec.local_id', 'if (rec.name.empty()) rec.name = "unnamed"'))
            with self.assertRaises(AssertionError):
                module.inventory(root)
            adapter.write_text(adapter_original)
            pool = root/'cpp/src/decompiler_pool.cpp'
            pool_original = pool.read_text()
            pool.write_text(pool_original.replace('results[i].error_message = dl.error', 'results[i].error_message = "failed"'))
            with self.assertRaises(AssertionError):
                module.inventory(root)
            pool.write_text(pool_original)
            adapter.write_text(adapter_original.replace('rec.end_address = stop.isInvalid() ? rec.start_address : stop.getOffset()', 'rec.end_address = stop.getOffset() + 1'))
            with self.assertRaises(AssertionError):
                module.inventory(root)
            adapter.write_text(adapter_original)
            adapter.write_text(adapter_original.replace('rec.is_primary = true', 'rec.is_primary = false'))
            with self.assertRaises(AssertionError):
                module.inventory(root)
            adapter.write_text(adapter_original)
            local.write_text(local_original.replace('perf_benchmarks_.push_back(record)', 'perf_benchmarks_.push_back(PerfBenchmarkRecord{})'))
            with self.assertRaises(AssertionError):
                module.inventory(root)
            local.write_text(local_original)
            local.write_text(local_original.replace('resp.records = perf_benchmarks_', 'resp.records = {}'))
            with self.assertRaises(AssertionError):
                module.inventory(root)
            local.write_text(local_original)
            local.write_text(local_original.replace('resp.local_id = local_id', 'resp.local_id = "canonical"'))
            with self.assertRaises(AssertionError):
                module.inventory(root)
            local.write_text(local_original)
            local.write_text(local_original.replace('resp.deleted_count = ok ? 1 : 0', 'resp.deleted_count = 0'))
            with self.assertRaises(AssertionError):
                module.inventory(root)
            local.write_text(local_original)
            local.write_text(local_original.replace('resp.modification_number = revision_', 'resp.modification_number = 0'))
            with self.assertRaises(AssertionError):
                module.inventory(root)
            local.write_text(local_original)
            local.write_text(local_original.replace('resp.accepted = true', 'resp.accepted = false'))
            with self.assertRaises(AssertionError):
                module.inventory(root)
            local.write_text(local_original)
            adapter.write_text(adapter_original.replace('rec.size = fit->type->getSize()', 'rec.size = 0'))
            with self.assertRaises(AssertionError):
                module.inventory(root)
            adapter.write_text(adapter_original)
            adapter.write_text(adapter_original.replace('rec.value = static_cast<std::int64_t>(eit->first)', 'rec.value = 0'))
            with self.assertRaises(AssertionError):
                module.inventory(root)
            adapter.write_text(adapter_original)
            local.write_text(local_original.replace('resp.deleted = ok', 'resp.deleted = false'))
            with self.assertRaises(AssertionError):
                module.inventory(root)
            local.write_text(local_original)
            local.write_text(local_original.replace('resp.updated = true', 'resp.updated = false'))
            with self.assertRaises(AssertionError):
                module.inventory(root)
            local.write_text(local_original)
            local.write_text(local_original.replace('resp.data = std::move(data)', 'resp.data = {}'))
            with self.assertRaises(AssertionError):
                module.inventory(root)
            local.write_text(local_original)
            local.write_text(local_original.replace('{"xrefs", "partial",', '{"xrefs", "supported",'))
            with self.assertRaises(AssertionError):
                module.inventory(root)
            local.write_text(local_original)
            local.write_text(local_original.replace('resp.function = pool_->primaryAdapter().getFunction(address)', 'resp.function = {}'))
            with self.assertRaises(AssertionError):
                module.inventory(root)
            local.write_text(local_original)
            local.write_text(local_original.replace('arch = opts_.default_arch;', 'arch = request.project_name;'))
            with self.assertRaises(AssertionError):
                module.inventory(root)
            local.write_text(local_original)
            local.write_text(local_original.replace('std::min(offset, n)', 'std::max(offset, n)'))
            with self.assertRaises(AssertionError):
                module.inventory(root)
            local.write_text(local_original)
            adapter.write_text(adapter_original.replace('range_end == 0 ? kAllRangeEnd : range_end', 'range_end == 1 ? kAllRangeEnd : range_end'))
            with self.assertRaises(AssertionError):
                module.inventory(root)
            adapter.write_text(adapter_original)
            adapter.write_text(adapter_original.replace('dt->getName().find(query)', 'dt->getName().find(query + query)'))
            with self.assertRaises(AssertionError):
                module.inventory(root)
            adapter.write_text(adapter_original)
            local.write_text(local_original.replace('return a.deleteSymbol(address);', 'return a.deleteSymbol(address + name_filter.size());'))
            with self.assertRaises(AssertionError):
                module.inventory(root)
            local.write_text(local_original)
            adapter.write_text(adapter_original.replace('static_cast<int4>(length)', 'static_cast<uint4>(length)'))
            with self.assertRaises(AssertionError):
                module.inventory(root)
            adapter.write_text(adapter_original)
            local.write_text(local_original.replace('std::max(opts_.pool_size, 1)', 'std::max(opts_.pool_size, 2)'))
            with self.assertRaises(AssertionError):
                module.inventory(root)
            local.write_text(local_original)
            local.write_text(local_original.replace('a.setTypeMemberComment(name, ordinal, comment)', 'a.setTypeMemberComment(name, ordinal + 1, comment)'))
            with self.assertRaises(AssertionError):
                module.inventory(root)
            local.write_text(local_original)
            local.write_text(local_original.replace('? static_cast<uint64_t>(value)', '? static_cast<uint64_t>(value + 1)'))
            with self.assertRaises(AssertionError):
                module.inventory(root)
            local.write_text(local_original)
            adapter.write_text(adapter_original.replace('tf->findByName(new_target_name)', 'tf->findByName(alias_name)'))
            with self.assertRaises(AssertionError):
                module.inventory(root)
            adapter.write_text(adapter_original)
            local.write_text(local_original.replace('fields.push_back({member_name, member_type, off})', 'fields.push_back({member_name, member_type, 0})'))
            with self.assertRaises(AssertionError):
                module.inventory(root)
            local.write_text(local_original)
            local.write_text(local_original.replace('d.nameGlobal(address, name, data_type)', 'd.nameGlobal(address, name, name)'))
            with self.assertRaises(AssertionError):
                module.inventory(root)
            local.write_text(local_original)
            local.write_text(local_original.replace('r.bench_id == bench_id', 'r.bench_id != bench_id'))
            with self.assertRaises(AssertionError):
                module.inventory(root)
            local.write_text(local_original)
            local.write_text(local_original.replace('a.deleteDataItem(address)', 'a.deleteDataItem(address + 1)'))
            with self.assertRaises(AssertionError):
                module.inventory(root)
            local.write_text(local_original)
            bindings = root/'cpp/bindings/python_bindings.cpp'
            original_bindings=bindings.read_text()
            # Keep key/field sets identical while corrupting value provenance.
            bindings.write_text(original_bindings.replace('d["size"] = r.size;', 'd["size"] = r.start_address;',1))
            with self.assertRaises(AssertionError):
                module.inventory(root)
            bindings.write_text(original_bindings)
            bindings.write_text(original_bindings.replace('locals_list.append(to_dict(l))', 'locals_list.append(to_dict(t))'))
            with self.assertRaises(AssertionError):
                module.inventory(root)
            bindings.write_text(original_bindings)
            header = root/'cpp/src/local_arch_adapter.hpp'
            header.write_text(header.read_text().replace('std::map<std::pair<std::uint64_t, int>, std::string> comments_', 'std::multimap<std::pair<std::uint64_t, int>, std::string> comments_'))
            with self.assertRaises(AssertionError):
                module.inventory(root)

    def test_optional_and_vector_container_population(self):
        for name in ['GetFunction','GetSymbol','GetInstruction','GetType','GetFunctionSignature']:
            self.assertIn('absent remains absent',self.ops[name]['response']['fields'][0]['semantics'])
        self.assertIn('ALWAYS present',self.ops['GetDecompilation']['response']['fields'][0]['semantics'])
        self.assertIn('completed=false',self.ops['GetDecompilation']['response']['fields'][0]['semantics'])
        for name in ['ListFunctions','ListFunctionSignatures','ListXrefs','GetComments']:
            self.assertIn('preserving native sequence and duplicates',self.ops[name]['response']['fields'][0]['semantics'])
        self.assertEqual(len([o for o in self.ops.values() if 'container_result_review' in o]),24)

    def test_special_result_absence_and_schema_are_not_observations(self):
        def sem(op,name):
            return next(f['semantics'] for f in self.ops[op]['response']['fields'] if f['name']==name)
        self.assertIn('binary Lua string',sem('ReadBytes','data'))
        self.assertIn('0..INT32_MAX',sem('ReadBytes','data'))
        self.assertIn('always empty',sem('ListDefinedStrings','strings'))
        self.assertIn('unreachable nested schema',sem('ListDefinedStrings','encoding'))
        self.assertIn('not decoded memory',sem('ListDataItems','value_repr'))
        self.assertIn('coarse native claim',sem('GetCapabilities','status'))
        self.assertIn('size>1',sem('GetCapabilities','note'))

    def test_type_delete_and_side_map_flags_are_distinct(self):
        for name in ['CreateType','AddTypeMember','DeleteComment','DeleteTypeEnumMember']:
            self.assertIn('NOT successful false',self.ops[name]['response']['fields'][0]['semantics'])
        for name in ['SetComment','SetTypeMemberComment','SetTypeEnumMemberComment']:
            self.assertIn('unconditional true lambda',self.ops[name]['response']['fields'][0]['semantics'])
            self.assertIn('no existence',self.ops[name]['response']['fields'][0]['semantics'])
        self.assertEqual(self.ops['SetTypeAliasTarget']['mutation_result_review']['assignments'],{'updated':'ok'})

    def test_member_producer_assignments_and_default_identity(self):
        def sem(op,name):
            return next(f['semantics'] for f in self.ops[op]['response']['fields'] if f['name']==name)
        self.assertIn('not durable member identity',sem('ListTypeMembers','ordinal'))
        self.assertIn('not assigned',sem('ListTypeMembers','parent_type_id'))
        self.assertIn('not assigned',sem('ListTypeEnumMembers','type_id'))
        self.assertIn('implementation-defined',sem('ListTypeEnumMembers','value'))
        self.assertIn('side-map',sem('ListTypeEnumMembers','comment'))
        self.assertIn('signed native',sem('ListTypeMembers','size'))

    def test_status_metadata_defaults_and_logical_acknowledgements(self):
        def sem(op,name):
            return next(f['semantics'] for f in self.ops[op]['response']['fields'] if f['name']==name)
        self.assertEqual(self.ops['GetRevision']['status_field_review']['default_only'],
                         ['file_id','file_last_modified_time','file_version','program_id','program_path'])
        self.assertIn('not binding dispatch generation',sem('GetRevision','modification_number'))
        self.assertIn('not a diagnostic health scan',sem('GetStatus','warnings'))
        self.assertIn('not upstream package',sem('GetStatus','service_version'))
        self.assertIn('false constructed then discarded',sem('SaveProgram','saved'))
        self.assertIn('no rollback',sem('DiscardProgram','discarded'))
        self.assertIn('logical closure',sem('CloseProgram','closed'))
        self.assertIn('already unloaded',sem('Shutdown','accepted'))

    def test_mutation_results_are_acknowledgements_and_echoes(self):
        def sem(op,name):
            return next(f['semantics'] for f in self.ops[op]['response']['fields'] if f['name']==name)
        self.assertIn('NOT successful false',sem('RenameFunction','renamed'))
        self.assertIn('not canonical resolved ID',sem('RenameFunctionLocal','local_id'))
        self.assertIn('request new_type',sem('SetFunctionLocalType','data_type'))
        self.assertIn('never assigned',sem('SetFunctionSignature','function_name'))
        self.assertIn('exactly 1',sem('DeleteSymbol','deleted_count'))
        self.assertIn('input data.size',sem('WriteBytes','bytes_written'))
        self.assertIn('modulo on overflow',sem('PatchBytesBatch','bytes_written'))
        self.assertEqual(len([o for o in self.ops.values() if 'mutation_result_review' in o]),32)

    def test_performance_is_caller_data_and_double_is_number(self):
        op=self.ops['AddPerfBenchmark']
        request={f['name']:f for f in op['request'][0]['nested_fields']}
        self.assertIn('Lua number',request['cold_ms_p50']['lua'])
        self.assertIn('no timing/percentile calculation',request['cold_ms_p50']['semantics'])
        self.assertIn('not a native pass/fail',request['status']['semantics'])
        self.assertIn('sole upsert/delete key',request['bench_id']['semantics'])
        fields=self.ops['ListPerfBenchmarks']['response']['fields']
        self.assertIn('caller-supplied',next(f['semantics'] for f in fields if f['name']=='throughput_qps'))
        clear=self.ops['ClearPerfBenchmarks']['response']['fields']
        self.assertIn('UINT32_MAX',next(f['semantics'] for f in clear if f['name']=='removed_count'))
        self.assertIn('already empty',next(f['semantics'] for f in clear if f['name']=='cleared'))
        self.assertIn('replacement',op['response']['fields'][0]['semantics'])
        self.assertIn('not new-insertion',op['response']['fields'][0]['semantics'])

    def test_graph_reference_branch_fields_and_defaults(self):
        def sem(op,name):
            return next(f['semantics'] for f in self.ops[op]['response']['fields'] if f['name']==name)
        self.assertIn('NOT stop+1',sem('ListBasicBlocks','end_address'))
        self.assertIn('not emitted-edge count',sem('ListBasicBlocks','out_degree'))
        self.assertIn('heuristic priority',sem('ListCFGEdges','edge_kind'))
        self.assertIn('LOAD/STORE model false',sem('ListXrefs','is_primary'))
        self.assertIn('constant LOAD/STORE literal true',sem('ListXrefs','is_memory'))
        self.assertIn('initializer -1',sem('ListXrefs','symbol_id'))
        self.assertIn('initializer 0',sem('ListXrefs','operand_index'))
        self.assertIn('never assigned',sem('ListXrefs','from_function_address'))
        self.assertEqual(set(self.ops['ListXrefs']['record_field_reviews'][-1]['branches']),
                         {'call','constant_LOAD','constant_STORE'})

    def test_decompilation_branch_population_and_unreachable_tokens(self):
        for op in ['GetDecompilation','ListDecompilations']:
            fields=self.ops[op]['response']['fields']
            def sem(model, name):
                return next(f['semantics'] for f in fields if f['model']==model and f['name']==name)
            self.assertIn('PRESENT',sem('DecompilationRecord','completed'))
            self.assertIn('partial adapter output discarded',sem('DecompilationRecord','pseudocode'))
            self.assertIn('success AND failure',sem('DecompilationRecord','tokens'))
            self.assertIn('schema only',sem('DecompileTokenRecord','text'))
            self.assertIn('NOT undefined',sem('DecompileLocalRecord','data_type'))
            self.assertIn('-1 sentinel',sem('DecompileLocalRecord','ordinal'))
            self.assertIn('empty name replaced',sem('DecompileLocalRecord','name'))
            self.assertIn('dynamic traversal',sem('DecompilationRecord','locals'))
        single=self.ops['GetDecompilation']['record_field_reviews'][-1]['branches']
        batch=self.ops['ListDecompilations']['record_field_reviews'][-1]['branches']
        self.assertNotIn('function_name',single['success_assigned'])
        self.assertIn('function_name',batch['failure_assigned'])

    def test_signature_nested_fields_and_default_parameter_flags(self):
        for op in ['GetFunctionSignature', 'ListFunctionSignatures']:
            fields={f['name']:f for f in self.ops[op]['response']['fields']}
            self.assertIn('otherwise literal void',fields['return_type']['semantics'])
            self.assertIn('otherwise literal undefined',fields['data_type']['semantics'])
            self.assertIn('copied from data_type',fields['formal_data_type']['semantics'])
            self.assertIn('false',fields['is_auto_parameter']['semantics'])
            self.assertIn('false',fields['is_forced_indirect']['semantics'])
            self.assertIn('no calling convention',fields['prototype']['semantics'])
            reviews=self.ops[op]['record_field_reviews']
            self.assertEqual({r['model'] for r in reviews},{'FunctionSignatureRecord','ParameterRecord'})
            for review in reviews:
                declared={f['name'] for f in self.data['types'][review['model']]['fields']}
                self.assertEqual(declared,set(review['assigned_fields'])|set(review['default_only_fields']))

    def test_type_record_field_population_and_synthetic_metadata(self):
        def field(op, name):
            return next(f for f in self.ops[op]['response']['fields'] if f['name']==name)
        self.assertIn('literal zero',field('GetType','type_id')['semantics'])
        self.assertIn('restarts',field('ListTypes','type_id')['semantics'])
        self.assertIn('not assigned',field('ListTypes','category_path')['semantics'])
        self.assertIn('false',field('ListTypeEnums','is_signed')['semantics'])
        self.assertIn('without semicolon',field('ListTypeAliases','declaration')['semantics'])
        self.assertIn('modulo',field('ListTypeUnions','size')['semantics'])
        for name in ['GetType','ListTypes','ListTypeEnums','ListTypeAliases','ListTypeUnions']:
            review=self.ops[name]['record_field_reviews'][0]
            declared={f['name'] for f in self.data['types'][review['model']]['fields']}
            self.assertEqual(declared,set(review['assigned_fields'])|set(review['default_only_fields']))

    def test_record_fields_are_producer_specific_and_exhaustive(self):
        def field(op, name):
            return next(f for f in self.ops[op]['response']['fields'] if f['name']==name)
        self.assertIn('gap to next', field('ListFunctions','size')['semantics'])
        self.assertIn('Funcdata getSize', field('GetFunction','size')['semantics'])
        self.assertIn('BEFORE pagination', field('ListSymbols','symbol_id')['semantics'])
        self.assertIn('not assigned', field('GetSymbol','symbol_id')['semantics'])
        self.assertIn('false', field('ListMemoryBlocks','is_write')['semantics'])
        self.assertIn('wraps size', field('ListMemoryBlocks','size')['semantics'])
        for name in ['GetFunction','ListFunctions','ListLeafFunctions','GetSymbol','ListSymbols','GetInstruction','ListInstructions','ListMemoryBlocks']:
            review=self.ops[name]['record_field_reviews'][0]
            declared={f['name'] for f in self.data['types'][review['model']]['fields']}
            self.assertEqual(declared,set(review['assigned_fields'])|set(review['default_only_fields']))
            self.assertFalse(set(review['assigned_fields'])&set(review['default_only_fields']))

    def test_page_wrapper_order_and_field_conversion(self):
        reviewed=[o for o in self.ops.values() if 'page_wrapper_review' in o]
        self.assertEqual(len(reviewed), 18)
        for o in reviewed:
            self.assertIn('NO_PROGRAM', o['page_wrapper_review']['error_policy'])
        self.assertIn('BEFORE', self.ops['GetComments']['state_transitions'])
        self.assertIn('AFTER', self.ops['ListFunctionSignatures']['state_transitions'])
        self.assertIn('no preceding decompileAt', self.ops['ListXrefs']['state_transitions'])
        end=next(f for f in self.ops['ListDataItems']['response']['fields'] if f['name']=='end_address')
        self.assertIn('can wrap', end['semantics'])

    def test_lookup_failure_fidelity_and_semantic_gap_audit(self):
        self.assertIn('literal name unchanged', ' '.join(self.ops['GetType']['limitations']))
        self.assertIn('present completed=false', self.ops['GetDecompilation']['state_transitions'])
        self.assertIn('exception', self.ops['ReadBytes']['state_transitions'])
        self.assertIn('tokens', ' '.join(self.ops['GetDecompilation']['limitations']))
        self.assertIn('prototype', self.ops['GetFunction']['lookup_record_fields']['default_only'])
        audit=self.data['semantic_audit']
        self.assertEqual(audit['included_operations'], 70)
        self.assertEqual(audit['wrapper_transition_review_missing'], [])
        self.assertEqual(audit['response_field_semantics_unreviewed'], [])
        # Empty preservation-only ledger does not qualify request/helper/runtime semantics.
        self.assertTrue(self.data['unresolved'])

    def test_alias_loss_and_symbol_comment_outcomes(self):
        self.assertIn('no rollback', ' '.join(self.ops['SetTypeAliasTarget']['limitations']))
        self.assertIn('no leading-slash', ' '.join(self.ops['CreateTypeAlias']['limitations']))
        self.assertIn('no explicit core-type', ' '.join(self.ops['DeleteType']['limitations']))
        self.assertIn('nonfunction -> NOT_SUPPORTED', self.ops['RenameSymbol']['state_transitions'])
        self.assertIn('deleted_count=1', self.ops['DeleteSymbol']['state_transitions'])
        self.assertIn('empty text stored', self.ops['SetComment']['state_transitions'])
        self.assertIn('rather than deleted=false', self.ops['DeleteComment']['state_transitions'])

    def test_local_status_errors_and_health_scope(self):
        self.assertIn('INVALID_TYPE', self.ops['SetFunctionLocalType']['state_transitions'])
        self.assertTrue(any('unreachable' in text for text in self.ops['RenameFunctionLocal']['limitations']))
        self.assertIn('opaque', ' '.join(self.ops['RenameFunctionLocal']['limitations']))
        self.assertIn('DAT_', self.ops['ApplyDataType']['state_transitions'])
        self.assertIn('pool exists', ' '.join(self.ops['GetStatus']['limitations']))
        self.assertIn('coarse', ' '.join(self.ops['GetCapabilities']['limitations']))

    def test_member_reconstruction_and_unvalidated_comments(self):
        self.assertIn('does not compact', ' '.join(self.ops['DeleteTypeMember']['limitations']))
        self.assertIn('signed int', self.ops['SetTypeMemberType']['effective_domain']['existing_offsets'])
        self.assertIn('uint64', self.ops['SetTypeEnumMemberValue']['effective_domain']['value'])
        for name in ['SetTypeMemberComment', 'SetTypeEnumMemberComment']:
            self.assertIn('without checking', self.ops[name]['state_transitions'])
            self.assertIn('nonexistent', ' '.join(self.ops[name]['limitations']))
        self.assertIn('NOT_FOUND', self.ops['RenameTypeEnumMember']['state_transitions'])

    def test_parameter_reconstruction_and_byte_count_domains(self):
        self.assertIn('calling convention', ' '.join(self.ops['RenameFunctionParameter']['limitations']))
        self.assertIn('OUT_OF_RANGE', self.ops['SetFunctionParameterType']['state_transitions'])
        self.assertIn('INT_MAX', self.ops['RenameFunctionParameter']['effective_domain']['ordinal'])
        self.assertIn('UINT32_MAX', self.ops['WriteBytes']['effective_domain']['data_length'])
        self.assertIn('cumulative', self.ops['PatchBytesBatch']['effective_domain']['total_data_length'])
        self.assertTrue(any('input array order' in text for text in self.ops['PatchBytesBatch']['limitations']))

    def test_open_metadata_defaults_and_member_effective_domain(self):
        fields={f['name']:f for f in self.ops['OpenProgram']['response']['fields']}
        self.assertIn('not assigned', fields['image_base']['semantics'])
        self.assertIn('not authoritative', fields['language_id']['semantics'])
        self.assertIn('INT_MAX', self.ops['AddTypeMember']['effective_domain']['existing_fields'])
        self.assertIn('width/is_signed ignored', self.ops['CreateTypeEnum']['state_transitions'])

    def test_grammar_authority_is_not_inferred_from_tier_or_native_signature(self):
        audit=self.data['surface_audit']
        self.assertEqual((audit['grammar_accounted'],audit['excluded_operations'],audit['approved_first_slice_count']),(70,40,10))
        approved={'GetStatus','GetCapabilities','OpenProgram','CloseProgram','GetFunction','GetInstruction','ReadBytes','GetDecompilation','ListFunctions','ListInstructions'}
        proposed={r['operation'] for r in audit['proposed_grammar']}
        self.assertEqual(proposed,set(self.ops)-approved-{n for n,o in self.ops.items() if not o['implementation']})
        for name,op in self.ops.items():
            if not op['implementation']:continue
            grammar=op['surface_contract']['lowlevel']['grammar']
            self.assertEqual(grammar['native_argument_order'],[a['name'] for a in op['request']])
            self.assertEqual(bool(grammar['approved_call']),name in approved)
        # Core lookup disposition is approved, its spelling/positional grammar is not.
        self.assertEqual(self.ops['GetType']['surface_contract']['facade']['extraction'],'type')
        self.assertIsNone(self.ops['GetType']['surface_contract']['lowlevel']['grammar']['approved_call'])
        from inventory_surfaces import surface_audit
        import copy
        changed=copy.deepcopy(self.data['operations'])
        row=next(o for o in changed if o['name']=='GetType')
        row['surface_contract']['lowlevel']['grammar']['native_argument_order']=[]
        with self.assertRaises(AssertionError):surface_audit(changed)
        changed=copy.deepcopy(self.data['operations'])
        row=next(o for o in changed if not o['implementation'])
        row['surface_contract']['facade']={'name':'invented'}
        with self.assertRaises(AssertionError):surface_audit(changed)

    def test_surface_extraction_and_native_escape_disposition(self):
        for name, key in [('GetFunction', 'function'), ('GetType', 'type'), ('ReadBytes', 'data')]:
            self.assertEqual(self.ops[name]['surface_contract']['facade']['extraction'], key)
        self.assertIsNone(self.ops['DiscardProgram']['surface_contract']['facade']['name'])
        self.assertIsNone(self.ops['DeleteSymbol']['surface_contract']['facade']['name'])
        req = self.ops['DeleteSymbol']['request']
        self.assertTrue(next(r for r in req if r['name']=='name_filter')['ignored'])
        self.assertIn('NO_STATE_PATH', self.ops['CloseProgram']['surface_contract']['facade']['save_policy'])
        self.assertIn('size', self.ops['ReadBytes']['surface_contract']['lowlevel']['argument_alias'])

    def test_python_converter_value_provenance_not_just_keys(self):
        converters=self.data['python_reconciliation']['record_converters']
        for name,row in converters.items():
            self.assertEqual(set(row['field_expressions']),set(row['exported_fields']))
            self.assertFalse(row['unknown_exported_fields'])
        self.assertEqual(converters['FunctionRecord']['field_expressions']['size']['expression'],'r.size')
        self.assertIn('ordered vector',converters['DecompilationRecord']['field_expressions']['locals']['semantics'])

    def test_python_binding_fidelity_exceptions(self):
        audit = self.data['python_reconciliation']
        self.assertEqual(len(audit['methods']), 27)
        opening = self.ops['OpenProgram']['python_reconciliation']
        self.assertEqual(opening['native_response_fields_not_exported'],
                         ['entry_point', 'executable_format', 'has_entry_point', 'md5', 'sha256'])
        self.assertEqual(audit['record_converters']['XrefRecord']['omitted_native_fields'],
                         ['from_function_address', 'from_function_name', 'to_function_address', 'to_function_name'])
        self.assertEqual(self.ops['ListFunctions']['python_reconciliation']['python_defaults']['limit'], '0')
        self.assertEqual(self.ops['SaveProgram']['python_reconciliation']['binding_extraction'], 'saved')
        self.assertIn('bare TypeRecord', self.ops['GetType']['python_reconciliation']['fidelity'])
        self.assertTrue(audit['conversion_helpers'])

    def test_session_and_performance_branches(self):
        self.assertIn('even unloaded', self.ops['DiscardProgram']['state_transitions'])
        self.assertIn('empty state_path skips', self.ops['CloseProgram']['state_transitions'])
        self.assertIn('unloaded accepted=true', self.ops['Shutdown']['program_state'])
        self.assertIn('moves to tail', self.ops['AddPerfBenchmark']['state_transitions'])
        self.assertIn('only when', self.ops['DeletePerfBenchmark']['state_transitions'])
        self.assertIn('UINT32_MAX', ' '.join(self.ops['ClearPerfBenchmarks']['limitations']))
        self.assertEqual(self.ops['ListPerfBenchmarks']['collection_contract']['identity'], ['bench_id'])

    def test_aggregate_cursor_domains_and_failure_retention(self):
        self.assertEqual(self.ops['ListFunctionSignatures']['pagination']['cursor_domain'], 'candidate functions')
        self.assertIn('AFTER', self.ops['ListFunctionSignatures']['pagination']['post_page_filter'])
        self.assertIn('completed=false', self.ops['ListDecompilations']['pagination']['post_page_filter'])
        self.assertIn('FUNCTION ENTRIES', self.ops['ListXrefs']['pagination']['pre_page_filter'])
        self.assertIn('NOT numeric', self.ops['ListXrefs']['pagination']['order'])
        self.assertEqual(self.ops['ListCFGEdges']['pagination']['identity']['fields'],
                         ['function_entry', 'src_block_start', 'dst_block_start', 'edge_kind'])
        for name in ['ListBasicBlocks', 'ListCFGEdges', 'ListXrefs']:
            self.assertTrue(any('pool_size=1' in text for text in self.ops[name]['limitations']))

    def test_member_and_comment_semantics_are_not_generic(self):
        members = self.ops['ListTypeMembers']
        self.assertEqual(members['pagination']['identity']['fields'], ['parent_type_path_name', 'ordinal'])
        fields = {f['name']: f for f in members['response']['fields']}
        self.assertIn('not assigned', fields['parent_type_id']['semantics'])
        self.assertIn('signed int64', fields['offset']['semantics'])
        self.assertIn('TypeStruct', members['pagination']['pre_page_filter'])
        comments = self.ops['GetComments']
        self.assertIn('lexicographic', comments['pagination']['comparator'])
        self.assertFalse(any('catches all exceptions' in x for x in comments['limitations']))
        self.assertIn('dependentOrder', self.ops['ListTypeEnums']['pagination']['order'])
        self.assertIn('duplicate', self.ops['ListDataItems']['pagination']['pre_page_filter'])


if __name__ == '__main__':
    unittest.main()
