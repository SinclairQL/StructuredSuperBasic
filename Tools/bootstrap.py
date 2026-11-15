"""Development bootstrap for QL testing; preserves single-byte source encoding.

This numbers/includes ordinary SSB only. Record translation runs in SSB on SMSQ/E.
Release bootstrap and Turbo self-host checks must also use the existing SSB.
"""
from pathlib import Path
import re
import argparse

ROOT=Path(__file__).resolve().parents[1]

def strip_hidden(s):
    quote=None
    for i,c in enumerate(s):
        if quote:
            if c==quote: quote=None
        elif c in "\"'": quote=c
        elif s[i:i+2]=='##': return s[:i]
    return s

def expand(path):
    pending=''
    for raw in path.read_bytes().decode('latin1').splitlines():
        if raw.startswith('#INCLUDE '):
            name=raw.split('_',1)[1].rsplit('_',1)[0]+'.ssb'
            yield from expand(ROOT/'Source'/name)
            continue
        if not raw.strip() or raw.lstrip().startswith(('##','.')): continue
        line=strip_hidden(raw)
        if line.endswith('\\+'):
            pending+=line[:-2]+' ';continue
        line=pending+line;pending=''
        if line.strip(): yield line
    if pending: raise ValueError(f'Unfinished continuation: {path}')

def number(lines,start=1,step=1):
    labels={};body=[];n=start
    for s in lines:
        if s.startswith('@'): labels[s.strip().lower()]=n
        else: body.append((n,s));n+=step
    out=[]
    for n,s in body:
        quote=None;i=0;rewritten=''
        while i<len(s):
            c=s[i]
            if quote:
                rewritten+=c
                if c==quote:quote=None
            elif c in "\"'":quote=c;rewritten+=c
            elif s[i:i+2]=='**':rewritten+='REMark'+s[i+2:];break
            elif c=='@':
                m=re.match(r'@[A-Za-z0-9_]+',s[i:]);key=m.group().lower()
                rewritten+=str(labels[key]);i+=len(m.group())-1
            else:rewritten+=c
            i+=1
        out.append(f'{n} {rewritten}\n')
    if n>32767: raise ValueError('Bootstrap exceeds BASIC line range')
    return ''.join(out).encode('latin1')

def trim_test_helpers():
    """Use the actual trim routines, without duplicating their implementation."""
    source=(ROOT/'Source'/'functions.ssb').read_bytes().split(b'## ND-272e',1)[0]
    # Standalone colons are cosmetic padding in the original module.
    return b'\n'.join(line for line in source.splitlines() if line.strip()!=b':')+b'\n'

def test_driver():
    body='''OPEN_NEW #3,"win1_log"
WHEN ERRor
  REPORT #3
  PRINT #3,"TARGET RUNTIME ERROR"
  abort_out
END WHEN
d_labels=100: d_length=64: d_ignore$="Y": d_working$="win1_": d_work2$="win1_"
DIM label$(100,64),label(100),defn$(100,64),in$(1000),in2$(1000)
DIM temp$(100),lngarray$(100,100)
label_var=1: define_var=1: num_count=0: file_num=5
line_num_d=1: line_delta=1: out_file$="ram1_output_bas"
rec_setup
line_num=1: pass_one "win1_input_ssb",5
line_num=1: OPEN_NEW #4,out_file$: rc_owned=1
pass_two "win1_input_ssb",5: CLOSE #4
rec_publish: CLOSE #3
COPY "ram1_output_bas" TO "win1_output_bas"
LRUN "ram1_output_bas"
STOP
DEFine PROCedure abort_out
  rec_cleanup
  OPEN_NEW #9,"win1_done": PRINT #9,"ERROR": CLOSE #9
  CLOSE #3: STOP
END DEFine
'''
    main=(ROOT/'Source'/'ssb280.ssb').read_bytes().decode('latin1')
    helpers=main[main.index('DEFine FuNction first_char'):main.index('## Procedure abort_out')]
    helpers+='\n'+main.split('## Main runtime helpers begin',1)[1].split('## Main runtime helpers end',1)[0]
    lines=body.splitlines()+helpers.splitlines()
    for module in ['functions','ssbpass1','ssbpass2']:
        lines.extend(expand(ROOT/'Source'/(module+'.ssb')))
    lines=[strip_hidden(s) for s in lines if not s.lstrip().upper().startswith(('INK #3','BEEP '))]
    return number([s for s in lines if s.strip()],start=10)

if __name__=='__main__':
    p=argparse.ArgumentParser();p.add_argument('--test-driver',action='store_true');a=p.parse_args()
    folder=ROOT/'build'/'ql';folder.mkdir(parents=True,exist_ok=True)
    if a.test_driver: (folder/'driver_bas').write_bytes(test_driver())
    else: (ROOT/'build'/'ssbrecdev_bas').write_bytes(number(expand(ROOT/'Source'/'ssb280.ssb')))
