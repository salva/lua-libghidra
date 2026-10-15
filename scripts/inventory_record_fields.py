"""Operation-specific record field accounting; never infer semantics from a hash."""
import hashlib
import re
from inventory_semantics import ADAPTER, body


def review_record_fields(u, operations, types):
    source=(u/ADAPTER).read_text()
    # Each producer is reviewed independently; identical models need not have
    # identical population (notably function size and symbol ID).
    contracts={
        'listFunctions': ('FunctionRecord', ['ListFunctions','ListLeafFunctions'], {
            'entry_address':'mapped FunctionSymbol entry selected before paging; exact native address',
            'start_address':'same mapped entry as entry_address, not independently computed body minimum',
            'name':'FunctionSymbol name copied unchanged',
            'size':'gap to next strictly greater function entry in unfiltered traversal; last/non-increasing successor uses positive symbol footprint or zero; not measured body extent',
            'end_address':'inclusive start+size-1 if size>0 else start; native uint64 arithmetic may wrap',
        }),
        'getFunction': ('FunctionRecord', ['GetFunction'], {
            'entry_address':'Funcdata address when queryFunction succeeds; otherwise requested address for FunctionSymbol fallback',
            'start_address':'same as returned entry_address (requested address in FunctionSymbol fallback)',
            'name':'Funcdata or fallback FunctionSymbol name',
            'size':'Funcdata getSize when available; fallback positive getBytesConsumed cast uint64 or zero; differs from listFunctions next-entry gap',
            'end_address':'inclusive start+size-1 for size>0 else start; unsigned wrap possible',
        }),
        'listSymbols': ('SymbolRecord', ['ListSymbols'], {
            'symbol_id':'zero-based uint64 counter incremented AFTER address filtering but BEFORE pagination; restarts each request, not durable native ID',
            'address':'mapped symbol address, not dynamic storage hash',
            'name':'symbol name unchanged', 'full_name':'same sym->getName as name; not qualified namespace expansion',
            'is_primary':'literal true for every emitted symbol, not analyzed primary distinction',
            'type':'literal function if FunctionSymbol dynamic cast succeeds, otherwise label',
        }),
        'getSymbol': ('SymbolRecord', ['GetSymbol'], {
            'address':'requested address copied after findAddr lookup; not necessarily symbol map-entry start',
            'name':'found symbol name unchanged', 'full_name':'same name; no namespace qualification',
            'is_primary':'literal true', 'type':'function if FunctionSymbol cast succeeds else label',
        }),
        'getInstruction': ('InstructionRecord', ['GetInstruction','ListInstructions'], {
            'address':'exact requested decode address; list advances by previous decoded length',
            'mnemonic':'StringAssemblyEmit mnemonic from printAssembly',
            'operand_text':'StringAssemblyEmit body, may be empty',
            'disassembly':'mnemonic plus one space and operand_text only when body nonempty',
            'length':'positive signed int4 printAssembly result cast uint32; len<=0 yields absent, not zero-length record',
        }),
        'listMemoryBlocks': ('MemoryBlockRecord', ['ListMemoryBlocks'], {
            'name':'default code address-space name; not native segment label',
            'start_address':'literal zero', 'end_address':'default code-space getHighest inclusive address',
            'size':'end_address+1 in uint64; highest UINT64_MAX wraps size to zero',
            'is_read':'literal true', 'is_execute':'literal true', 'is_initialized':'literal true',
            'source_name':'literal raw; not detected source file name',
        }),
    }
    type_common={
        'name':'native datatype getName unchanged',
        'path_name':'synthetic slash plus native name, not hierarchical database path or proof lookup accepts slash',
    }
    type_details={
        'display_name':'native datatype getDisplayName unchanged',
        'kind':'metatype_to_kind string; not Lua enum or independently detected category',
        'length':'native signed getSize assigned to model integer; preserve signed value, including native unknown-size sentinel',
    }
    counter='filtered zero-based uint64 counter BEFORE pagination; restarts per request, not durable native type identity'
    contracts.update({
        'getType': ('TypeRecord',['GetType'],dict(type_common, **type_details, type_id='literal zero for lookup; not resolved native type ID')),
        'listTypes': ('TypeRecord',['ListTypes'],dict(type_common, **type_details, type_id=counter)),
        'listTypeAliases': ('TypeAliasRecord',['ListTypeAliases'],dict(type_common, type_id=counter,
            target_type='typedef target getName unchanged; only typedef entries emitted',
            declaration='constructed typedef + space + target name + space + alias name, without semicolon or declarator fidelity guarantee')),
        'listTypeEnums': ('TypeEnumRecord',['ListTypeEnums'],dict(type_common, type_id=counter,
            width='TypeEnum getSize in bytes; signed native value converted to uint64 modulo 2^64 if negative; is_signed not inferred')),
        'listTypeUnions': ('TypeUnionRecord',['ListTypeUnions'],dict(type_common, type_id=counter,
            size='native signed union getSize converted to uint64 modulo 2^64 if negative; no member-layout measurement')),
    })
    for method,(model,names,semantics) in contracts.items():
        start,text=body(source,'ArchAdapter::'+method+'(')
        assigned=set(re.findall(r'rec\.(\w+)\s*=',text))
        assert assigned==set(semantics), (method,assigned^set(semantics))
        if method=='listFunctions':
            assert 'size = fns[i + 1].addr - fns[i].addr' in text
        if method=='listSymbols': assert 'rec.symbol_id = id_counter++' in text
        if method=='listMemoryBlocks': assert 'rec.size = rec.end_address + 1' in text
        if method=='listTypeAliases': assert 'rec.declaration = "typedef " + target->getName() + " " + dt->getName()' in text
        if method in ['listTypes','listTypeEnums','listTypeAliases','listTypeUnions']: assert 'rec.type_id = id_counter++' in text
        if method=='getType': assert 'rec.type_id = 0' in text
        if method=='getInstruction': assert 'if (!emit.body.empty())' in text
        declared={f['name']:f for f in types[model]['fields']}
        assert assigned<=set(declared)
        for op in operations:
            if op['name'] not in names:continue
            review={'path':ADAPTER,'line':source.count('\n',0,start)+1,'method':method,
                    'body_sha256':hashlib.sha256(text.encode()).hexdigest(),
                    'model':model,'assigned_fields':sorted(assigned),
                    'default_only_fields':sorted(set(declared)-assigned),
                    'qualification':'all declared record fields accounted against producer; runtime fixtures unqualified'}
            op.setdefault('record_field_reviews',[]).append(review)
            for field in op['response']['fields']:
                if field['model']!=model:continue
                name=field['name']
                field['semantics']=semantics.get(name, 'not assigned by '+method+'; retain model initializer '+declared[name]['native_default']+'; not measured metadata or durable identity')
                field['producer_review']={'path':ADAPTER,'method':method,'line':review['line']}
    review_signature_fields(source, operations, types)
    return operations


def review_signature_fields(source, operations, types):
    method='getFunctionSignature'
    start,text=body(source,'ArchAdapter::'+method+'(')
    contracts={
        'FunctionSignatureRecord': ('rec', {
            'function_entry_address':'requested address copied after queryFunction succeeds; not independently normalized function entry',
            'function_name':'Funcdata getName unchanged',
            'has_var_args':'FuncProto isDotdotdot boolean',
            'return_type':'output datatype name when nonnull, otherwise literal void',
            'calling_convention':'FuncProto getModelName unchanged; separate field, not embedded in prototype string',
            'parameters':'ProtoParameter traversal order, one appended record per native numParams entry; nested ordinal is zero-based not Lua index',
            'prototype':'constructed return type, function name, parenthesized comma-separated datatype/name parameters and conditional varargs; no calling convention or general C declarator fidelity',
        }),
        'ParameterRecord': ('prec', {
            'ordinal':'signed native int4 loop index from zero to numParams-1; model checked integer, not 1-based Lua array index',
            'name':'ProtoParameter getName unchanged',
            'data_type':'parameter datatype name when nonnull, otherwise literal undefined',
            'formal_data_type':'copied from data_type; not an independently extracted formal datatype',
        }),
    }
    assert 'ret_type ? ret_type->getName() : "void"' in text
    assert 'pt ? pt->getName() : "undefined"' in text
    assert 'prec.formal_data_type = prec.data_type' in text
    assert 'if (rec.has_var_args)' in text and 'if (num_params > 0)' in text
    assert 'rec.calling_convention = proto.getModelName()' in text
    for model,(variable,semantics) in contracts.items():
        assigned=set(re.findall(r'\b'+variable+r'\.(\w+)\s*=',text))
        appended=set(re.findall(r'\b'+variable+r'\.(\w+)\.push_back\(',text))
        assert assigned|appended==set(semantics),(model,assigned|appended)
        declared={f['name']:f for f in types[model]['fields']}
        assert set(semantics)<=set(declared)
        for op in operations:
            if op['name'] not in ['GetFunctionSignature','ListFunctionSignatures']:continue
            review={'path':ADAPTER,'line':source.count('\n',0,start)+1,'method':method,
                    'body_sha256':hashlib.sha256(text.encode()).hexdigest(),
                    'model':model,'assigned_fields':sorted(assigned|appended),
                    'default_only_fields':sorted(set(declared)-set(semantics)),
                    'qualification':'all declared signature/parameter fields accounted against producer; runtime unqualified'}
            op.setdefault('record_field_reviews',[]).append(review)
            for field in op['response']['fields']:
                if field['model']!=model:continue
                name=field['name']
                field['semantics']=semantics.get(name,'not assigned by '+method+'; retain model initializer '+declared[name]['native_default']+'; not measured parameter metadata')
                field['producer_review']={'path':ADAPTER,'method':method,'line':review['line']}
