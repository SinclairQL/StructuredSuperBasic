from bootstrap import ROOT,number,expand
from pathlib import Path
import shutil,sys,json,hashlib

folder=ROOT/'build'/'compiled-app';folder.mkdir(parents=True,exist_ok=True)
for n in ['parser_task','codegen_task','ttk']:
    shutil.copy2(ROOT/'build'/'turbo'/n,folder/n)
shutil.copy2(ROOT/'build'/'ql'/'env_bin',folder/'env_bin')
if '--self-host' in sys.argv:
    import json
    proof=json.loads((ROOT/'build'/'self-host-result.json').read_text(encoding='utf-8'))
    assert proof['passed']
    assert all((Path(proof['folder'])/(p.stem+'_ssb')).read_bytes()==p.read_bytes().replace(b'\r\n',b'\n') for p in (ROOT/'Source').glob('*.ssb')), 'Repeat self_host.py after changing sources'
    # The comparison proves old/new output identical. Build from 2.7.2g's file.
    source=(Path(proof['folder'])/'old_output_bas').read_bytes()
else:
    source=number(expand(ROOT/'Source'/'ssb272.ssb'),start=100)
source=source.replace(b'ram1_ssbrecdev_err',b'nfa1_report')
(folder/'compile_bas').write_bytes(source)
(folder/'build.json').write_text(json.dumps(dict(self_host='--self-host' in sys.argv, numbered_sha256=hashlib.sha256(source).hexdigest(), sources={p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in (ROOT/'Source').glob('*.ssb')}),indent=2),encoding='utf-8')
(folder/'input_ssb').write_bytes((ROOT/'Tests'/'core.ssb').read_bytes().replace(b'win1_',b'nfa1_'))
for n in ['report','done','output_bas','ssbrecdev_exe','result','errorlog','listing']:
    if (folder/n).exists():(folder/n).unlink()
(folder/'boot').write_text('''100 LRESPR "nfa1_env_bin"
110 LRESPR "nfa1_ttk"
120 SETENV "SSBWORK=nfa1_"
130 SETENV "SSBWORK2=ram1_"
140 SETENV "SSBSTART=1"
150 SETENV "SSBINC=1"
160 SETENV "SSBRECWORK=ram1_"
170 SETENV "SSBOVER=Y"
175 SETENV "SSBRECLOG=nfa1_errorlog"
180 DEFAULT_DEVICE "sfa1_"
190 LOAD "nfa1_compile_bas"
''',encoding='ascii')
finish=[
 'COPY "ram1_ssbrecdev_exe" TO "sfa1_ssbrecdev_exe"',
 'EXECUTE_W "ram1_ssbrecdev_exe";"input"',
 'COPY "ram1_input_bas" TO "nfa1_output_bas"','LRUN "ram1_input_bas"']
(folder/'finish').write_text(''.join(f'{100+i*10} {s}\n' for i,s in enumerate(finish)),encoding='ascii')
commands=['','','LRUN nfa1_boot','CHARGE '+chr(92),chr(2),'LRUN nfa1_finish']
(folder/'commands').write_text('\n'.join(commands)+'\n',encoding='ascii')
print('Prepared full SSB Turbo build:',len(source),'bytes')
