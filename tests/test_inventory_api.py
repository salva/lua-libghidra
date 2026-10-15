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
        self.assertEqual(self.ops['DeleteSymbol']['ignored_fields'], ['name'])
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
            local.write_text(local.read_text().replace('limit + offset', 'limit'))
            with self.assertRaises(AssertionError):
                module.inventory(root)


if __name__ == '__main__':
    unittest.main()
