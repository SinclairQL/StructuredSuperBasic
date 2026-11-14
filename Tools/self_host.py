"""Compile the supplied 2.7.2g baseline, preprocess current sources with both versions.
The numbered outputs must agree byte-for-byte before accepting a self bootstrap.
"""
from pathlib import Path
from bootstrap import ROOT
import shutil,subprocess,time,json,hashlib,sys
folder=ROOT/'build'/'self-host'/str(time.time_ns());folder.mkdir(parents=True)
for n in ['parser_task','codegen_task','ttk','env_bin','ssbrecdev_exe']:
 shutil.copy2(ROOT/'build'/'compiled-app'/n,folder/n)
for p in (ROOT/'Source').glob('*.ssb'):(folder/(p.stem+'_ssb')).write_bytes(p.read_bytes().replace(b'\r\n',b'\n'))
source=(ROOT/'Source'/'ssb272.bas').read_bytes().replace(b'dev7_ssb272_exe',b'ram1_baseline_exe').replace(b'dev7_ssb272_err',b'nfa1_report')
(folder/'compile_bas').write_bytes(source)
(folder/'boot').write_text('100 LRESPR "nfa1_env_bin"\n110 LRESPR "nfa1_ttk"\n120 DEFAULT_DEVICE "sfa1_"\n130 LOAD "nfa1_compile_bas"\n',encoding='ascii')
lines=['SETENV "SSBWORK="','SETENV "SSBWORK2="','SETENV "SSBSTART=100"','SETENV "SSBINC=1"','SETENV "SSBOVER=Y"','SETENV "SSBRECWORK=ram1_"','SETENV "SSBRECLOG=nfa1_errorlog"']
for p in (ROOT/'Source').glob('*.ssb'):lines.append('COPY "nfa1_'+p.stem+'_ssb" TO "ram1_'+p.stem+'_ssb"')
lines += ['EXECUTE_W "ram1_baseline_exe";"ram1_ssb280"','COPY "ram1_ssb280_bas" TO "nfa1_old_output_bas"','DELETE "ram1_ssb280_bas"','EXECUTE_W "sfa1_ssbrecdev_exe";"ram1_ssb280"','COPY "ram1_ssb280_bas" TO "nfa1_new_output_bas"','OPEN_NEW #9,"nfa1_done":PRINT #9,"OK":CLOSE #9']
(folder/'finish').write_text(''.join(str(100+i*10)+' '+s+'\n' for i,s in enumerate(lines)),encoding='ascii')
(folder/'commands').write_text('\n\nLRUN nfa1_boot\nCHARGE '+chr(92)+'\n'+chr(2)+'\nLRUN nfa1_finish\n',encoding='ascii')
cp=str(ROOT/'build'/'newclasses')+';'+str(ROOT/'build'/'emulator-lib'/'*')
p=subprocess.run(['java','-cp',cp,'QlRun',str(ROOT/'build'/'SMSQE'),str(folder),'110',str(folder/'commands')],capture_output=True,timeout=125)
(folder/'emulator.log').write_bytes(p.stdout+p.stderr)
read=lambda n:(folder/n).read_bytes() if (folder/n).exists() else b''
a=read('old_output_bas');b=read('new_output_bas')
r=dict(passed=p.returncode==0 and a and a==b and not read('errorlog'),old_bytes=len(a),new_bytes=len(b),sha256=hashlib.sha256(a).hexdigest(),error=read('errorlog').decode('latin1'),folder=str(folder))
r['passed']=bool(r['passed'])
r['sources']={p.name:hashlib.sha256(p.read_bytes()).hexdigest() for p in (ROOT/'Source').glob('*.ssb')}
(folder/'result.json').write_text(json.dumps(r,indent=2),encoding='utf-8');(ROOT/'build'/'self-host-result.json').write_text(json.dumps(r,indent=2),encoding='utf-8');print(json.dumps(r,indent=2))
sys.exit(0 if r['passed'] else 1)
