"""Regenerate boundary fixtures; expected values compare complete strings, not prefixes."""
from pathlib import Path
import json
import re
from bootstrap import ROOT

def quoted(value):
    delimiter = '"' if '"' not in value else "'"
    assert delimiter not in value
    return delimiter + value + delimiter

def expected_expression(value):
    pieces = []
    start = 0
    for match in re.finditer(r'x{4,}', value):
        if match.start() > start:
            pieces.append(quoted(value[start:match.start()]))
        pieces.append('FILL$("x",' + str(len(match[0])) + ')')
        start = match.end()
    if start < len(value):
        pieces.append(quoted(value[start:]))
    return ' & '.join(pieces) if pieces else '""'

def fixture(record):
    name = 'long-lines-records' if record else 'long-lines-legacy'
    target = 'lineRecord.text$' if record else 'lineText$'
    lines = ['## Physical/logical lines reach 1000 bytes; compare every resulting character.']
    if record:
        lines += ['TYPE longRecord', ' text$(1000)', 'END TYPE',
                  'DIM lineRecord AS longRecord', 'DIM expected$(1000)']
    else:
        lines += ['DIM lineText$(1000),expected$(1000)']
    lines += ['OPEN_NEW #9,"win1_result"', 'WHEN ERRor', ' REPORT #9',
              ' PRINT #9,"TARGET RUNTIME ERROR"', ' CLOSE #9',
              ' OPEN_NEW #8,"win1_done":PRINT #8,"ERROR":CLOSE #8',
              ' STOP', 'END WHEN']
    cases = []
    output = []
    def add(label, length, prefix='', quote='"', comment='', continuation=False, indent=''):
        lead = indent + target + ' = ' + quote
        tail = quote + comment
        padding = length-len(lead)-len(tail)-len(prefix)-1
        assert padding > 0
        value = prefix + 'x'*padding + 'Z'
        logical = lead + value + tail
        assert len(logical.encode('ascii')) == length
        physical = [logical]
        if continuation:
            split_at = 600
            offset = split_at-len(lead)
            assert value[offset] == 'x'
            value = value[:offset]+' '+value[offset+1:]
            logical = lead+value+tail
            physical = [logical[:split_at]+'\\+',logical[split_at+1:]]
            assert physical[0][:-2]+' '+physical[1] == logical
        lines.append('expected$ = '+expected_expression(value))
        first = len(lines)+1
        lines.extend(physical)
        lines.append('PRINT #9,"'+label+':";LEN('+target+');",";('+target+'=expected$)')
        output.append(label+':'+str(len(value))+',1')
        cases.append(dict(label=label,source_line=first,logical_bytes=length,
                          physical_bytes=[len(p.encode('ascii')) for p in physical],
                          string_bytes=len(value),full_string_equality=True))
    for length in [100,101,255,999,1000]:
        add('plain-'+str(length),length)
    add('hidden-1000',1000,comment=' ## ignored at the end')
    add('quoted-markers-1000',1000,prefix='## first ** literal ## last ')
    add('mixed-double-1000',1000,prefix="It's ## literal ** text ",comment=' ## invisible')
    add('mixed-single-1000',1000,prefix='He said " ## literal ** text ',quote="'",comment=' ## invisible')
    add('visible-996',996,comment=' : ** a visible remark')
    add('indented-1000',1000,indent=' '*120,comment=' ## invisible')
    add('continuation-1000',1000,continuation=True)
    lines += ['CLOSE #9','OPEN_NEW #9,"win1_done":PRINT #9,"OK":CLOSE #9','STOP']
    data=('\n'.join(lines)+'\n').encode('ascii')
    assert max(len(line) for line in data.splitlines())==1000
    (ROOT/'Tests'/(name+'.ssb')).write_bytes(data)
    return dict(name=name,expected='\n'.join(output),cases=cases)

def main():
    tests=[fixture(False),fixture(True)]
    trim='''## Exercise the actual compiler trim helpers at and across the old 100-byte limit.
DIM sample$(1000),expected$(1000)
OPEN_NEW #9,"win1_result"
WHEN ERRor
 REPORT #9
 PRINT #9,"TARGET RUNTIME ERROR"
 CLOSE #9
 OPEN_NEW #8,"win1_done":PRINT #8,"ERROR":CLOSE #8
 STOP
END WHEN
DATA 0,1,99,100,101,255,999,1000
FOR caseIndex=1 TO 8
 READ sampleLength
 sample$=""
 IF sampleLength THEN sample$=FILL$("x",sampleLength)
 PRINT #9,sampleLength;":";LEN(LTrim$(sample$));",";LEN(RTrim$(sample$));",";LEN(Trim$(sample$));",";(Trim$(sample$)=sample$)
END FOR caseIndex
sample$=" "&FILL$("x",998)&" "
expected$=FILL$("x",998)
PRINT #9,"padding:";LEN(Trim$(sample$));",";(Trim$(sample$)=expected$)
sample$=FILL$(" ",1000)
PRINT #9,"spaces:";LEN(LTrim$(sample$));",";LEN(RTrim$(sample$));",";LEN(Trim$(sample$))
CLOSE #9
OPEN_NEW #9,"win1_done":PRINT #9,"OK":CLOSE #9
STOP
#INCLUDE trim_helpers_ssb
'''
    (ROOT/'Tests'/'long-lines-trim.ssb').write_bytes(trim.encode('ascii'))
    expected='\n'.join(str(n)+':'+','.join([str(n)]*3)+',1' for n in [0,1,99,100,101,255,999,1000])
    expected+='\npadding:998,1\nspaces:0,0,0'
    tests.append(dict(name='long-lines-trim',expected=expected,helper_input_lengths=[0,1,99,100,101,255,999,1000]))
    (ROOT/'Tests'/'long-lines.json').write_text(json.dumps(tests,indent=2)+'\n',encoding='utf-8',newline='\n')
    print('Created',len(tests),'fixtures, including',sum(len(t.get('cases',[])) for t in tests),'full-string long-line checks.')

if __name__=='__main__':
    main()

