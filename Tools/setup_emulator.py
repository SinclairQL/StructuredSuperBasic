"""Prepare the optional QL test environment from the user's external tool copies.

No emulator, ROM, compiler or toolkit is redistributed in this repository.
"""
import argparse
from pathlib import Path
import shutil
import subprocess
import zipfile

from bootstrap import ROOT

p = argparse.ArgumentParser()
p.add_argument('--emulator', type=Path, default=Path('I:/QL/SMSQmulator303src.zip'))
p.add_argument('--turbo', type=Path, default=Path('I:/QL/Turbo'))
p.add_argument('--env', type=Path, default=Path('I:/QL/env_bin'))
a = p.parse_args()
build = ROOT / 'build'
for name in ['emulator-src', 'emulator-lib', 'newclasses', 'ql', 'turbo']:
    (build / name).mkdir(parents=True, exist_ok=True)
with zipfile.ZipFile(a.emulator) as archive:
    for entry in archive.infolist():
        name = entry.filename
        if entry.is_dir():
            continue
        if name.startswith('SMSQmulator/src/'):
            suffix = Path(name.removeprefix('SMSQmulator/src/'))
            target = build / 'emulator-src' / suffix
        elif name.startswith('SMSQmulator/lib/') and name.endswith('.jar'):
            target = build / 'emulator-lib' / Path(name).name
        elif name == 'SMSQmulator/SMSQE':
            target = build / 'SMSQE'
        else:
            continue
        if not target.resolve().is_relative_to(build.resolve()):
            raise ValueError('Archive entry escapes the build directory')
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(archive.read(entry))
with zipfile.ZipFile(a.turbo / 'turbo toolkit14.zip') as archive:
    toolkit = archive.read('turbo_sms.code')
for where in ['ql', 'turbo']:
    (build / where / 'ttk').write_bytes(toolkit)
shutil.copy2(a.env, build / 'ql' / 'env_bin')
for name in ['parser_task', 'codegen_task']:
    shutil.copy2(a.turbo / name, build / 'turbo' / name)
subprocess.run([
    'javac', '-cp', str(build / 'emulator-lib' / '*'),
    '-sourcepath', str(build / 'emulator-src'),
    '-d', str(build / 'newclasses'), str(ROOT / 'Tools' / 'QlRun.java')
], check=True)
print('QL test prerequisites prepared in', build)
