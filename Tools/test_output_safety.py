"""Exercise refused overwrite, failed replacement and recovery on the QL RAM disk."""
import json
import shutil
import subprocess
import sys
import time
from bootstrap import ROOT

folder = ROOT / 'build' / 'output-safety' / str(time.time_ns())
folder.mkdir(parents=True)
for name in ['env_bin', 'ttk', 'ssbrecdev_exe']:
    shutil.copy2(ROOT / 'build' / 'compiled-app' / name, folder / name)
(folder / 'bad_ssb').write_bytes(b'DIM item AS absentType\n')
(folder / 'good_ssb').write_bytes(b'TYPE point\n x\nEND TYPE\nDIM p AS point\np.x=42\n')
(folder / 'old_bas').write_bytes(b'100 REMark previously generated program\n')
lines = [
    'LRESPR "nfa1_env_bin"', 'LRESPR "nfa1_ttk"',
    'SETENV "SSBWORK=ram1_"', 'SETENV "SSBWORK2=ram1_"',
    'SETENV "SSBSTART=100"', 'SETENV "SSBINC=1"',
    'SETENV "SSBRECWORK=ram1_"', 'SETENV "SSBOVER=N"',
    'COPY "nfa1_bad_ssb" TO "ram1_input_ssb"',
    'COPY "nfa1_old_bas" TO "ram1_input_bas"',
    'EXECUTE_W "sfa1_ssbrecdev_exe";"input"',
    'COPY "ram1_input_bas" TO "nfa1_refused_bas"',
    'SETENV "SSBOVER=Y"', 'SETENV "SSBRECLOG=nfa1_errorlog"',
    'EXECUTE_W "sfa1_ssbrecdev_exe";"input"',
    'OPEN_NEW #9,"nfa1_failed_status":PRINT #9,FTEST("ram1_input_bas"):CLOSE #9',
    'COPY "ram1_input_bas_bak1" TO "nfa1_backup_bas"',
    'DELETE "ram1_input_ssb"', 'COPY "nfa1_good_ssb" TO "ram1_input_ssb"',
    'SETENV "SSBRECLOG=nfa1_recovery_error"',
    'EXECUTE_W "sfa1_ssbrecdev_exe";"input"',
    'COPY "ram1_input_bas" TO "nfa1_recovered_bas"',
    'OPEN_NEW #9,"nfa1_ram_listing":DIR #9,"ram1_":CLOSE #9',
    'OPEN_NEW #9,"nfa1_done":PRINT #9,"OK":CLOSE #9'
]
(folder / 'boot').write_text(''.join(f'{100+i*10} {s}\n' for i, s in enumerate(lines)), encoding='ascii')
cp = str(ROOT / 'build' / 'newclasses') + ';' + str(ROOT / 'build' / 'emulator-lib' / '*')
p = subprocess.run(['java', '-cp', cp, 'QlRun', str(ROOT / 'build' / 'SMSQE'), str(folder), '60'],
                   capture_output=True, timeout=75)
(folder / 'emulator.log').write_bytes(p.stdout + p.stderr)
read = lambda name: (folder / name).read_bytes() if (folder / name).exists() else b''
old = read('old_bas')
checks = dict(refused_preserved=read('refused_bas') == old,
              failed_output_absent=read('failed_status').strip() == b'-7',
              backup_preserved=read('backup_bas') == old,
              diagnostic=b'Unknown TYPE' in read('errorlog'),
              recovered=b'P_X' in read('recovered_bas') and b'42' in read('recovered_bas'),
              no_recovery_error=not read('recovery_error'),
              cleaned_scratch=b'rec_' not in read('ram_listing').lower())
r = dict(passed=p.returncode == 0 and all(checks.values()), checks=checks, folder=str(folder))
(ROOT / 'build' / 'output-safety-result.json').write_text(json.dumps(r, indent=2), encoding='utf-8')
print(json.dumps(r, indent=2))
sys.exit(0 if r['passed'] else 1)
