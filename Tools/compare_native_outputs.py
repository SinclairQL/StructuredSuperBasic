"""Compare generated BASIC from two validate_native.py runs, byte for byte.

Usage: python Tools/compare_native_outputs.py BEFORE.json AFTER.json
Both JSON files retain the folders containing their generated output_bas files.
"""
import hashlib
import json
from pathlib import Path
import sys
from bootstrap import ROOT

before, after = [json.loads(Path(name).read_text(encoding='utf-8')) for name in sys.argv[1:]]
old = {test['name']: test for test in before}
new = {test['name']: test for test in after}
assert old.keys() == new.keys(), 'The two runs must cover the same fixtures'
checks = []
for name in sorted(old):
    a = (Path(old[name]['folder']) / 'output_bas').read_bytes()
    b = (Path(new[name]['folder']) / 'output_bas').read_bytes()
    checks.append(dict(name=name, passed=old[name]['passed'] and new[name]['passed'] and a == b,
                       before_bytes=len(a), after_bytes=len(b), sha256=hashlib.sha256(b).hexdigest()))
result = dict(passed=all(check['passed'] for check in checks), checks=checks)
(ROOT / 'build' / 'output-compatibility.json').write_text(json.dumps(result, indent=2), encoding='utf-8')
for check in checks:
    print('PASS' if check['passed'] else 'FAIL', check['name'], check['after_bytes'], 'bytes')
sys.exit(0 if result['passed'] else 1)
