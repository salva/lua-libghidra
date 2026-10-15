"""Session/status producer fields; default metadata is not detected identity."""
import hashlib
import re
from inventory_semantics import LOCAL, body


def review_status_fields(u, operations, types):
    source=(u/LOCAL).read_text()
    contracts={
        'GetRevision':('RevisionResponse','resp',{'modification_number':'revision_'},{
            'modification_number':'native revision_ snapshot under request lock, usable unloaded; not binding dispatch generation or durable project modification version',
        }),
        'GetStatus':('HealthStatus','hs',{'ok':'(pool_ != nullptr)','service_name':'"local-decompiler"','service_version':'"1.0.0"','host_mode':'"local"','modification_number':'revision_'},{
            'ok':'pool pointer existence only; not program loaded, loader readiness, healthy analysis or per-operation runtime qualification',
            'service_name':'literal local-decompiler; not detected executable/program name',
            'service_version':'literal 1.0.0; not upstream package 0.0.9 or source pin/version detection',
            'host_mode':'literal local; no remote host discovery',
            'modification_number':'native revision_ snapshot under request lock; not binding dispatch generation; no loaded-program guard',
        }),
        'SaveProgram':('SaveProgramResponse','resp',{'saved':'ok'},{
            'saved':'true in successful response after saveState returns true; false constructed then discarded in SAVE_FAILED error, not successful false; requires loaded program and nonempty state_path; no native revision increment',
        }),
        'DiscardProgram':('DiscardProgramResponse','resp',{'discarded':'true'},{
            'discarded':'literal true including unloaded; override performs no rollback, reload, state deletion or revision increment; acknowledgement is not undo proof',
        }),
        'CloseProgram':('CloseProgramResponse','resp',{'closed':'true'},{
            'closed':'literal true only after helper resetAdapters, loaded=false and benchmark clear; save failure returns error beforehand; logical closure not engine/owner release and not CLOSED; native revision unchanged',
        }),
        'Shutdown':('ShutdownResponse','resp',{'accepted':'true'},{
            'accepted':'literal true after successful logical close or when already unloaded; helper save failure propagated before acknowledgement; engines/owner retained, not binding CLOSED',
        }),
    }
    for op in operations:
        name=op['name']
        if name not in contracts:continue
        model,var,assigned,semantics=contracts[name]
        method='closeProgramLocked' if name=='CloseProgram' else name
        signature='StatusOr<CloseProgramResponse> closeProgramLocked(' if name=='CloseProgram' else ' '+method+'('
        start,text=body(source,signature)
        actual={m[1]:m[2].strip() for m in re.finditer(r'\b'+var+r'\.(\w+)\s*=\s*([^;]+);',text)}
        assert actual==assigned,(name,actual)
        declared={f['name']:f for f in types[model]['fields']}
        defaults=set(declared)-set(assigned)
        expected_defaults={'program_id','program_path','file_id','file_version','file_last_modified_time'} if name=='GetRevision' else {'warnings'} if name=='GetStatus' else set()
        assert defaults==expected_defaults,(name,defaults)
        if name=='CloseProgram':
            assert 'return closeProgramLocked(policy)' in body(source,' CloseProgram(')[1]
            assert text.index('"SAVE_FAILED"')<text.index('pool_->resetAdapters()')<text.index('resp.closed = true')
        if name=='Shutdown':
            assert 'if (program_loaded_)' in text and 'if (!closed.ok())' in text
            assert text.index('closed.status.code, closed.status.message')<text.index('resp.accepted = true')
        if name=='SaveProgram':
            assert 'if (!ok)' in text and text.index('"SAVE_FAILED"')<text.index('::FromValue(')
        for field in op['response']['fields']:
            key=field['name']
            field['semantics']=semantics[key] if key in assigned else 'never assigned by '+name+'; retain model initializer '+declared[key]['native_default']+'; '+('empty warnings is not a diagnostic health scan' if key=='warnings' else 'not detected project/file identity, version, path or filesystem timestamp; cannot be a pagination identity')
        op['status_field_review']={'path':LOCAL,'line':source.count('\n',0,start)+1,'method':method,'body_sha256':hashlib.sha256(text.encode()).hexdigest(),'assigned':sorted(assigned),'default_only':sorted(defaults),'qualification':'source-only; runtime evidence remains unqualified'}
    return operations
