"""Test the actual Turbo-built SSB executable, optionally compiling its output."""
from pathlib import Path
from bootstrap import ROOT,trim_test_helpers
import shutil,sys,subprocess,time,json

name=sys.argv[1] if len(sys.argv)>1 else 'core'
compile_target='--compile-target' in sys.argv
ram_mib=int(sys.argv[sys.argv.index('--ram-mib')+1]) if '--ram-mib' in sys.argv else 8
filter_path=Path(sys.argv[sys.argv.index('--filter')+1]) if '--filter' in sys.argv else ROOT/'build'/'compiled-app'/'ssb280_exe'
folder=ROOT/'build'/'native-tests'/name/str(time.time_ns());folder.mkdir(parents=True)
for n in ['parser_task','codegen_task','ttk','env_bin','ssb280_exe']:
    shutil.copy2(ROOT/'build'/'compiled-app'/n,folder/n)
shutil.copy2(filter_path,folder/'ssb280_exe')
source=(ROOT/'Tests'/(name+'.ssb')).read_text(encoding='utf-8').replace('win1_','nfa1_')
if compile_target:
    source='''TURBO_objfil "ram1_target_exe"
TURBO_repfil "nfa1_report"
TURBO_windo 0
TURBO_objdat 128
TURBO_buffersz 2
TURBO_list 0
TURBO_model ">"
'''+source
(folder/'input_ssb').write_bytes(source.encode('latin1'))
(folder/'types_ssb').write_bytes((ROOT/'Tests'/'types.ssb').read_bytes())
(folder/'trim_helpers_ssb').write_bytes(trim_test_helpers())
boot='''100 LRESPR "nfa1_env_bin"
110 LRESPR "nfa1_ttk"
120 SETENV "SSBWORK=nfa1_"
130 SETENV "SSBWORK2=ram1_"
140 SETENV "SSBSTART=1"
150 SETENV "SSBINC=1"
160 SETENV "SSBRECWORK=ram1_"
170 SETENV "SSBOVER=Y"
175 SETENV "SSBRECLOG=nfa1_errorlog"
180 DEFAULT_DEVICE "sfa1_"
190 EXECUTE_W "sfa1_ssb280_exe";"input"
200 IF FTEST("ram1_input_bas")<>0 THEN OPEN_NEW #9,"nfa1_done":PRINT #9,"ERROR":CLOSE #9:STOP
210 COPY "ram1_input_bas" TO "nfa1_output_bas"
'''
if name=='preserved-blank-labels':
    boot=boot.replace('180 DEFAULT_DEVICE','176 SETENV "SSBIGNORE_BLANKS=N"\n180 DEFAULT_DEVICE')
boot+='220 LOAD "ram1_input_bas"\n' if compile_target else '220 LRUN "ram1_input_bas"\n'
(folder/'boot').write_text(boot,encoding='ascii')
commands=['','','LRUN nfa1_boot']
if compile_target:commands+=[chr(3),'CHARGE '+chr(92),chr(2),'EXECUTE_W "ram1_target_exe"']
(folder/'commands').write_text('\n'.join(commands)+'\n',encoding='ascii')
cp=str(ROOT/'build'/'newclasses')+';'+str(ROOT/'build'/'emulator-lib'/'*')
p=subprocess.run(['java','-Dql.ramMiB='+str(ram_mib),'-cp',cp,'QlRun',str(ROOT/'build'/'SMSQE'),str(folder),'110',str(folder/'commands')],capture_output=True,timeout=125)
(folder/'emulator.log').write_bytes(p.stdout+p.stderr)
read=lambda n:(folder/n).read_text('latin1') if (folder/n).exists() else ''
r=dict(name=name,compiled_target=compile_target,ram_mib=ram_mib,exit=p.returncode,done=read('done').strip(),result=read('result'),error=read('errorlog'),folder=str(folder))
(folder/'result.json').write_text(json.dumps(r,indent=2));print(json.dumps(r,indent=2))
expected={'core':'4,3\n4,3\n5','arrays-pools':'Lau,22\n91,clinical\n3,4\n2,11,12\n1,2,1,0\n6\n5,6','bounds-labels':'0,0,0\n3,0\n7\n1,1,0\nmail@example: TYPE AS VAL ## untouched\n132\n11,42,1,0','value-only':'9','limits':'1,64','strings':'180,z\n137.5'}
expected['reference-stream']='9,hello,16,18'
expected['pure-builtins']='506'
expected['legacy-comments']='## one|## two|## three\nHe said " ## here\nIt\'s ## here\nHe said " ** here\nIt\'s ** here'
expected['review-regressions']='## one|## two|## three\nHe said " ## here\nIt\'s ## here\nHe said " ** here\nIt\'s ** here\n3,9'
expected['parenthesized-value']='3,3,9,5,keep,3'
expected['preserved-blank-labels']='0,7'
expected.update({case['name']:case['expected'] for case in json.loads((ROOT/'Tests'/'long-lines.json').read_text(encoding='utf-8'))})
expected['standalone-colon']='2'
sys.exit(0 if p.returncode==0 and r['done']=='OK' and not r['error'] and r['result'].strip()==expected[name] else 1)
