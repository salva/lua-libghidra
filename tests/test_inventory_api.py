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
            header = root/'cpp/src/local_arch_adapter.hpp'
            header.write_text(header.read_text().replace('std::map<std::pair<std::uint64_t, int>, std::string> comments_', 'std::multimap<std::pair<std::uint64_t, int>, std::string> comments_'))
            with self.assertRaises(AssertionError):
                module.inventory(root)

    def test_lookup_failure_fidelity_and_semantic_gap_audit(self):
        self.assertIn('literal name unchanged', ' '.join(self.ops['GetType']['limitations']))
        self.assertIn('present completed=false', self.ops['GetDecompilation']['state_transitions'])
        self.assertIn('exception', self.ops['ReadBytes']['state_transitions'])
        self.assertIn('tokens', ' '.join(self.ops['GetDecompilation']['limitations']))
        self.assertIn('prototype', self.ops['GetFunction']['lookup_record_fields']['default_only'])
        audit=self.data['semantic_audit']
        self.assertEqual(audit['included_operations'], 70)
        self.assertIn('ListFunctions', audit['wrapper_transition_review_missing'])
        self.assertTrue(audit['response_field_semantics_unreviewed'])
        self.assertTrue(all(row['path'] for row in audit['response_field_semantics_unreviewed']))

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

    def test_surface_extraction_and_native_escape_disposition(self):
        for name, key in [('GetFunction', 'function'), ('GetType', 'type'), ('ReadBytes', 'data')]:
            self.assertEqual(self.ops[name]['surface_contract']['facade']['extraction'], key)
        self.assertIsNone(self.ops['DiscardProgram']['surface_contract']['facade']['name'])
        self.assertIsNone(self.ops['DeleteSymbol']['surface_contract']['facade']['name'])
        req = self.ops['DeleteSymbol']['request']
        self.assertTrue(next(r for r in req if r['name']=='name_filter')['ignored'])
        self.assertIn('NO_STATE_PATH', self.ops['CloseProgram']['surface_contract']['facade']['save_policy'])
        self.assertIn('size', self.ops['ReadBytes']['surface_contract']['lowlevel']['argument_alias'])

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
