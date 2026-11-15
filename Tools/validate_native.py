"""Run all positive fixtures through the compiled filter and Turbo compiler."""
import concurrent.futures
import json
import subprocess
import sys
from bootstrap import ROOT

def run(name):
    p = subprocess.run([sys.executable, str(ROOT / 'Tools' / 'execute_compiled.py'), name, '--compile-target', '--ram-mib', '4'],
                       capture_output=True, text=True, timeout=140)
    try:
        result = json.loads(p.stdout)
    except ValueError:
        result = dict(name=name, output=p.stdout, error=p.stderr)
    result['passed'] = p.returncode == 0
    return result

with concurrent.futures.ThreadPoolExecutor(max_workers=3) as pool:
    results = list(pool.map(run, ['core', 'arrays-pools', 'bounds-labels', 'value-only', 'limits', 'strings', 'reference-stream', 'pure-builtins', 'legacy-comments', 'review-regressions', 'parenthesized-value', 'preserved-blank-labels', 'long-lines-legacy', 'long-lines-records', 'long-lines-trim', 'standalone-colon']))
(ROOT / 'build' / 'native-validation.json').write_text(json.dumps(results, indent=2), encoding='utf-8')
for result in results:
    print('PASS' if result['passed'] else 'FAIL', result['name'])
sys.exit(0 if all(result['passed'] for result in results) else 1)
