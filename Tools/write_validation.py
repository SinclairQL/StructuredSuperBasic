"""Save a compact validation record after the QL tests and package build."""
import hashlib
import json
import re
import struct
from pathlib import Path
from bootstrap import ROOT

build = ROOT / 'build'
read = lambda name: json.loads((build / name).read_text(encoding='utf-8'))
interpreted = read('results.json')
native = read('native-validation.json')
bootstrap = read('self-host-result.json')
safety = read('output-safety-result.json')
compiled = read('compiled-app/build.json')
compatibility = read('output-compatibility.json')
line_ranges = read('line-range-result.json')
sources = {p.name: hashlib.sha256(p.read_bytes()).hexdigest() for p in (ROOT / 'Source').glob('*.ssb')}
assert interpreted['sources'] == bootstrap['sources'] == compiled['sources'] == sources
assert all(test['passed'] for test in interpreted['tests'])
assert len(native) == 10 and all(test['passed'] and test['ram_mib']==4 for test in native)
assert bootstrap['passed'] and safety['passed'] and compiled['self_host']
legacy_basic=(Path(bootstrap['folder'])/'old_output_bas').read_bytes().replace(b'ram1_ssbrecdev_err',b'nfa1_report')
assert hashlib.sha256(legacy_basic).hexdigest()==compiled['numbered_sha256'], 'The final executable must be built from 2.7.2g output'
assert compatibility['passed']
assert len(line_ranges) == 5 and all(t['passed'] for t in line_ranges)
assert all(hashlib.sha256((Path(t['folder'])/'ssbrecdev_exe').read_bytes()).hexdigest()==hashlib.sha256((build/'compiled-app'/'ssbrecdev_exe').read_bytes()).hexdigest() for t in line_ranges)
executable_hash=hashlib.sha256((build/'compiled-app'/'ssbrecdev_exe').read_bytes()).hexdigest()
executable=(build/'compiled-app'/'ssbrecdev_exe').read_bytes()
assert executable.startswith(b']!QDOS File Header')
assert struct.unpack_from('>I',executable,22)[0]==1024*1024
assert struct.unpack_from('>I',(build/'baseline-exe').read_bytes(),22)[0]==2*1024*1024
assert all(hashlib.sha256((Path(test['folder'])/'ssbrecdev_exe').read_bytes()).hexdigest()==executable_hash for test in native)
assert hashlib.sha256((Path(safety['folder'])/'ssbrecdev_exe').read_bytes()).hexdigest()==executable_hash
wrapper = build / 'compiled-wrapper'
assert (wrapper / 'failed_status').read_text().strip() == '-7'
assert (wrapper / 'backup_bas').read_bytes() == (wrapper / 'old_bas').read_bytes()
report = (build / 'compiled-app' / 'report').read_text(encoding='latin1')
summary = re.search(r'(\d+) errors and (\d+) warnings', report)
assert summary and summary[1] == '0'
result = dict(
    date='2026-11-14',
    target='SMSQ/E 3.43, SMSQmulator 3.03 68000 CPU; native checks 4 MiB RAM, bootstrap/interpreter checks 8 MiB RAM',
    compiler='Turbo parser 5.09, code generator F5.37, SMS Turbo toolkit',
    interpreter_tests=[dict(name=t['name'], passed=t['passed']) for t in sorted(interpreted['tests'], key=lambda t: t['name'])],
    compiled_filter_and_compiled_program_tests=[dict(name=t['name'], passed=t['passed'], ram_mib=t['ram_mib'], actual=t['result'].strip()) for t in native],
    line_number_boundary_tests=[dict(name=t['name'], passed=t['passed']) for t in line_ranges],
    memory=dict(previous_dataspace_bytes=2*1024*1024, dataspace_bytes=1024*1024, reduction_percent=50,
        default_table_capacity=256, token_text_matrices_removed=True, reference_directives_streamed=True,
        colon_statement_tail_processed=True, tested_runtime_ram_mib=4,
        limitation='The 2 MiB SMSQ/E test environment reported insufficient memory while launching the filter; 2 MiB runtime support is not claimed.'),
    bootstrap=dict(passed=True, old_output_bytes=bootstrap['old_bytes'], new_output_bytes=bootstrap['new_bytes'], numbered_sha256=bootstrap['sha256'], built_from_ssb_output=True, preprocessor='SSB 2.7.2g'),
    legacy_bootstrap_compatibility=dict(version='2.7.2g', compiler_source_uses_records=False, old_and_new_output_identical=True, user_program_output_identical=True, fixtures=compatibility['checks']),
    compiler_result=dict(errors=int(summary[1]), warnings=int(summary[2]), note='Legacy assumed string dimensions and dynamic LOCAL declarations; this is not a warning-free build.'),
    output_safety=safety['checks'],
    ssbgo_failure_test=dict(compiled=True, failed_final_absent=True, previous_output_preserved=True),
    source_sha256=sources,
    validated_executable_sha256=executable_hash,
    distribution_sha256={p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in (ROOT/'Distribution').iterdir() if p.is_file()},
    limitations=[
        'Turbo rejects individual record-array-element reference arguments; standalone work records and whole-array references are supported.',
        'SBASIC-only reference forms were tested in the interpreter, not compiled.',
        'Classic QL ROMs, a 128 KiB machine, QLiberator and the full editor/grep SSBGO workflow were not certified.',
        'New record diagnostics use English. The existing Quill release manual was preserved.',
        'Publication/backup tests ran on the QL RAM filesystem because Windows NFA rename in this emulator reports files in use.'
    ])
(ROOT / 'Docs' / 'Validation.json').write_text(json.dumps(result, indent=2) + '\n', encoding='utf-8')
print('Recorded', len(interpreted['tests']), 'interpreter checks and', len(native), 'compiled-program checks')
