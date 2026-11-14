"""Prepare an isolated Turbo build of the SSBGO development wrapper."""
from bootstrap import ROOT, expand, number
import shutil
from pathlib import Path

folder = ROOT / 'build' / 'compiled-wrapper'
folder.mkdir(parents=True, exist_ok=True)
for name in ['parser_task', 'codegen_task', 'ttk', 'env_bin', 'ssbrecdev_exe']:
    shutil.copy2(ROOT / 'build' / 'compiled-app' / name, folder / name)
for name in ['report', 'done', 'ssbgorecdev_exe', 'failed_status', 'backup_bas']:
    if (folder / name).exists():
        (folder / name).unlink()
source = number(expand(ROOT / 'Utilities' / 'ssbgo.ssb'), start=100)
source = source.replace(b'ram1_err', b'nfa1_report')
(folder / 'compile_bas').write_bytes(source)
(folder / 'old_bas').write_bytes(b'100 REMark previous output\n')
(folder / 'bad_ssb').write_bytes(b'DIM item AS absentType\n')
(folder / 'boot').write_text('100 LRESPR "nfa1_env_bin"\n110 LRESPR "nfa1_ttk"\n120 DEFAULT_DEVICE "sfa1_"\n130 LOAD "nfa1_compile_bas"\n', encoding='ascii')
lines = [
    'COPY "ram1_ssbgorecdev_exe" TO "sfa1_ssbgorecdev_exe"',
    'COPY "nfa1_old_bas" TO "ram1_input_bas"',
    'COPY "nfa1_bad_ssb" TO "ram1_input_ssb"',
    'SETENV "SSBWORK=ram1_"', 'SETENV "SSBWORK2=ram1_"',
    'SETENV "SSBOVER=Y"', 'SETENV "SSBEXEC=sfa1_"',
    'SETENV "SSBFILTER=ssbrecdev_exe"',
    'EXECUTE_W "sfa1_ssbgorecdev_exe";"input"',
    'OPEN_NEW #9,"nfa1_failed_status":PRINT #9,FTEST("ram1_input_bas"):CLOSE #9',
    'COPY "ram1_input_bas_go1" TO "nfa1_backup_bas"',
    'OPEN_NEW #9,"nfa1_done":PRINT #9,"OK":CLOSE #9'
]
(folder / 'finish').write_text(''.join(f'{100+i*10} {s}\n' for i, s in enumerate(lines)), encoding='ascii')
(folder / 'commands').write_text('\n\nLRUN nfa1_boot\nCHARGE ' + chr(92) + '\n' + chr(2) + '\nLRUN nfa1_finish\n', encoding='ascii')
print('Prepared SSBGO build and stale-output failure test in', folder)
