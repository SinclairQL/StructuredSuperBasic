"""Run SSB itself on a real SMSQ/E image using the local emulator CPU.

External prerequisites are deliberately not redistributed. See development docs.
"""
from pathlib import Path
import concurrent.futures as cf
import json, subprocess, shutil, sys, time, hashlib
from bootstrap import ROOT,test_driver,trim_test_helpers

BUILD=ROOT/'build'
CP=str(BUILD/'newclasses')+';'+str(BUILD/'emulator-lib'/'*')
def run_case(case):
    folder=BUILD/'tests'/case['name'];folder.mkdir(parents=True,exist_ok=True)
    # Use a fresh directory on each test invocation, preserving previous results.
    folder=folder/str(time.time_ns());folder.mkdir()
    for name in ['env_bin','ttk']:shutil.copy2(BUILD/'ql'/name,folder/name)
    (folder/'types_ssb').write_bytes((ROOT/'Tests'/'types.ssb').read_bytes())
    (folder/'trim_helpers_ssb').write_bytes(trim_test_helpers())
    (folder/'input_ssb').write_bytes(case['source'].replace('win1_','nfa1_').encode('latin1'))
    driver=test_driver().replace(b'win1_',b'nfa1_')
    (folder/'driver_bas').write_bytes(b'1 SAVE_O "nfa1_loaded"\n'+driver)
    (folder/'boot').write_bytes(b'100 LRESPR "nfa1_env_bin"\n110 LRESPR "nfa1_ttk"\n120 SETENV "SSBRECWORK=nfa1_"\n130 LRUN "nfa1_driver_bas"\n')
    if case.get('profile'):
        boot=(folder/'boot').read_bytes().replace(b'130 LRUN',('125 SETENV "SSBRECPROFILE='+case['profile']+'"\n130 LRUN').encode('ascii'))
        (folder/'boot').write_bytes(boot)
    if case.get('preserve_blanks'):
        boot=(folder/'boot').read_bytes().replace(b'130 LRUN',b'126 SETENV "SSBIGNORE_BLANKS=N"\n130 LRUN')
        (folder/'boot').write_bytes(boot)
        driver=(folder/'driver_bas').read_bytes().replace(b'd_ignore$="Y"',b'd_ignore$="N"')
        (folder/'driver_bas').write_bytes(driver)
    started=time.monotonic()
    p=subprocess.run(['java','-cp',CP,'QlRun',str(BUILD/'SMSQE'),str(folder),'110'],capture_output=True,timeout=120)
    (folder/'emulator.log').write_bytes(p.stdout+p.stderr)
    read=lambda n:(folder/n).read_text('latin1') if (folder/n).exists() else ''
    log=read('log');done=read('done').strip();result=read('result').strip()
    syntax=[s for s in read('loaded').splitlines() if 'MISTake ' in s]
    ok=p.returncode==0 and not syntax
    if 'error' in case:
        ok=ok and done=='ERROR' and case['error'].lower() in log.lower() and not (folder/'output_bas').exists()
    else:
        ok=ok and done=='OK' and result==case['expected'].strip()
    return dict(name=case['name'],passed=ok,seconds=round(time.monotonic()-started,1),done=done,result=result,error=log.replace(chr(1),''),syntax=syntax,folder=str(folder))

cases=json.loads((ROOT/'Tests'/'rejections.json').read_text(encoding='utf-8'))
for name,expected in [('core','4,3\n4,3\n5'),('arrays-pools','Lau,22\n91,clinical\n3,4\n2,11,12\n1,2,1,0\n6\n5,6'),('bounds-labels','0,0,0\n3,0\n7\n1,1,0\nmail@example: TYPE AS VAL ## untouched\n132\n11,42,1,0'),('value-only','9'),('limits','1,64'),('strings','180,z\n137.5')]:
    cases.append(dict(name=name,source=(ROOT/'Tests'/(name+'.ssb')).read_text(encoding='utf-8'),expected=expected))
cases.append(dict(name='pure-builtins',source=(ROOT/'Tests'/'pure-builtins.ssb').read_text(encoding='ascii'),expected='506'))
cases.append(dict(name='pure-element-selectors',source=(ROOT/'Tests'/'pure-element-selectors.ssb').read_text(encoding='ascii'),expected='11,11,11',profile='SBASIC'))
element=(ROOT/'Tests'/'element-reference.ssb').read_text(encoding='utf-8')
cases.append(dict(name='legacy-comments',source=(ROOT/'Tests'/'legacy-comments.ssb').read_text(encoding='ascii'),expected='## one|## two|## three\nHe said " ## here\nIt\'s ## here\nHe said " ** here\nIt\'s ** here'))
cases.append(dict(name='review-regressions',source=(ROOT/'Tests'/'review-regressions.ssb').read_text(encoding='ascii'),expected='## one|## two|## three\nHe said " ## here\nIt\'s ## here\nHe said " ** here\nIt\'s ** here\n3,9'))
cases.append(dict(name='reference-stream',source=(ROOT/'Tests'/'reference-stream.ssb').read_text(encoding='utf-8'),expected='9,hello,16,18'))
cases.append(dict(name='element-reference',source=element,expected='2,11,0',profile='SBASIC'))
cases.append(dict(name='turbo-element-rejected',source=element,error='Turbo cannot pass record array elements'))
cases.append(dict(name='parenthesized-value',source=(ROOT/'Tests'/'parenthesized-value.ssb').read_text(encoding='ascii'),expected='3,3,9,5,keep,3'))
cases.append(dict(name='preserved-blank-labels',source=(ROOT/'Tests'/'preserved-blank-labels.ssb').read_text(encoding='ascii'),expected='0,7',preserve_blanks=True))
for case in json.loads((ROOT/'Tests'/'long-lines.json').read_text(encoding='utf-8')):
    cases.append(dict(name=case['name'],source=(ROOT/'Tests'/(case['name']+'.ssb')).read_text(encoding='ascii'),expected=case['expected']))
cases.append(dict(name='standalone-colon',source=(ROOT/'Tests'/'standalone-colon.ssb').read_text(encoding='ascii'),expected='2'))
if len(sys.argv)>1:cases=[c for c in cases if c['name'] in sys.argv[1:]]
results=[]
with cf.ThreadPoolExecutor(max_workers=3) as pool:
    for future in cf.as_completed([pool.submit(run_case,c) for c in cases]):
        r=future.result();results.append(r);print(('PASS' if r['passed'] else 'FAIL'),r['name'],r['seconds'],flush=True)
output=dict(target='SMSQ/E 3.43; SMSQmulator 3.03 CPU; 8 MiB',tests=results,sources={p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in (ROOT/'Source').glob('*.ssb')})
(BUILD/('results-selected.json' if len(sys.argv)>1 else 'results.json')).write_text(json.dumps(output,indent=2))
sys.exit(0 if all(r['passed'] for r in results) else 1)
