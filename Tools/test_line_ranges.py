"""Check exact line-number boundaries using the compiled filter on SMSQ/E."""
from pathlib import Path
from bootstrap import ROOT
import concurrent.futures
import json
import shutil
import subprocess
import time

base = 'TYPE point\n x\nEND TYPE\nDIM p AS point\nSTOP\n'
cases = [
    dict(name='final_32767', source=base, start=32766, step=1, numbers=[32766, 32767]),
    dict(name='unused_next_overflow', source=base, start=32760, step=5, numbers=[32760, 32765]),
    dict(name='trailing_nonstatements', source=base+'\n## trailing comment\n@finish\n', start=32766, step=1, numbers=[32766, 32767]),
    dict(name='actual_overflow', source=base+'PRINT 0\n', start=32766, step=1, error=True),
    dict(name='zero_increment', source=base, start=1, step=0, error=True),
]

def run(case):
    folder = ROOT/'build'/'line-ranges'/case['name']/str(time.time_ns())
    folder.mkdir(parents=True)
    for name in ['env_bin', 'ttk', 'ssb280_exe']:
        shutil.copy2(ROOT/'build'/'compiled-app'/name, folder/name)
    (folder/'input_ssb').write_bytes(case['source'].encode('ascii'))
    lines = [
        'LRESPR "nfa1_env_bin"', 'LRESPR "nfa1_ttk"',
        'SETENV "SSBWORK=nfa1_"', 'SETENV "SSBWORK2=ram1_"',
        f'SETENV "SSBSTART={case["start"]}"', f'SETENV "SSBINC={case["step"]}"',
        'SETENV "SSBRECWORK=ram1_"', 'SETENV "SSBRECLOG=nfa1_errorlog"',
        'DEFAULT_DEVICE "sfa1_"', 'EXECUTE_W "sfa1_ssb280_exe";"input"',
        'IF FTEST("ram1_input_bas")=0 THEN COPY "ram1_input_bas" TO "nfa1_output_bas"',
        'OPEN_NEW #9,"nfa1_done":PRINT #9,"OK":CLOSE #9',
    ]
    (folder/'boot').write_text(''.join(f'{100+i*10} {s}\n' for i,s in enumerate(lines)), encoding='ascii')
    cp = str(ROOT/'build'/'newclasses')+';'+str(ROOT/'build'/'emulator-lib'/'*')
    p = subprocess.run(['java', '-cp', cp, 'QlRun', str(ROOT/'build'/'SMSQE'), str(folder), '45'], capture_output=True, timeout=65)
    (folder/'emulator.log').write_bytes(p.stdout+p.stderr)
    read = lambda name: (folder/name).read_text('latin1') if (folder/name).exists() else ''
    output, error = read('output_bas'), read('errorlog')
    ok = p.returncode == 0 and read('done').strip() == 'OK'
    if case.get('error'):
        ok = ok and not output and 'Expanded BASIC line range' in error
    else:
        numbers = [int(line.split()[0]) for line in output.splitlines() if line.strip()]
        ok = ok and not error and numbers == case['numbers']
        ok = ok and output.splitlines()[-1].endswith(' STOP')
    result = dict(name=case['name'], passed=bool(ok), output=output, error=error, folder=str(folder))
    (folder/'result.json').write_text(json.dumps(result, indent=2))
    return result

if __name__ == '__main__':
    with concurrent.futures.ThreadPoolExecutor(max_workers=3) as pool:
        results = list(pool.map(run, cases))
    (ROOT/'build'/'line-range-result.json').write_text(json.dumps(results, indent=2))
    for result in results:
        print('PASS' if result['passed'] else 'FAIL', result['name'])
    raise SystemExit(0 if all(r['passed'] for r in results) else 1)
