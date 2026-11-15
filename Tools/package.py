"""Package the development binaries with QDOS metadata and a readable supplement."""
from pathlib import Path
import json
import shutil
import struct
import textwrap
import zipfile

from bootstrap import ROOT

out = ROOT / 'Distribution'
out.mkdir(exist_ok=True)
guide = '''SSB RECORDS DEVELOPMENT
Based on Structured SuperBASIC 2.7.2g. Development build, not a release.

Copy the included executable to ram1_ssb280_exe with a QDOS-aware unzip.
Keep your released SSB. This build reserves 1 MiB data, reduced from 2 MiB.
Compiled regression checks pass with 4 MiB total SMSQ/E 3.43 RAM, using
Turbo 5.09 / F5.37 and the SMS Turbo toolkit. Bootstrap/interpreter tests
use 8 MiB; that is machine RAM, not a per-program reservation. A 2 MiB
SMSQ/E setup could not launch this filter; original 128 KiB QLs are not
supported by this development build.
The Windows files alongside this ZIP use Qemu file headers. The ZIP uses
raw executable data with QDOS file-type and dataspace metadata.

  SETENV "SSBWORK=ram1_"
  SETENV "SSBWORK2=ram1_"
  SETENV "SSBSTART=100"
  SETENV "SSBINC=1"
  EXECUTE_W "ram1_ssb280_exe";"example"

Input example_ssb produces numbered example_bas. Existing SSB settings
and label syntax still apply. Use a positive increment and line numbers
within 1..32767. Repository .ssb, .bas and _bas text files use LF endings
through .gitattributes. Preserve their QL character bytes when editing or
copying them. The expanded ssb280_bas in this ZIP is already QL text.

EXAMPLE
  TYPE point
    x
    y
  END TYPE
  DIM origin AS point, otherPoint AS point
  makePoint origin, 3, 4
  otherPoint = origin
  PRINT otherPoint.x;",";otherPoint.y
  STOP
  DEFine PROCedure makePoint(result AS point, VAL xIn, VAL yIn)
    result.x=xIn
    result.y=yIn
  END DEFine

Records support embedded records, bounded strings, numeric/string array
fields, record arrays, whole-record copies and recursive LOCal storage.
Every declaration clears its fields. All record parameters are writable
references. Output records are explicit parameters, not function results.
Output parameters are not automatically cleared or protected from aliases.

IMPORTANT: Turbo 5.09 cannot pass individual numeric array elements by
reference. The default TURBO509 profile therefore rejects a selected
record-array element used as a record argument. Copy it into a standalone
work record, call the procedure, then explicitly copy back. Save the index
first if the called procedure could change it. Whole record arrays can be
passed by reference. Interpreter-only SSBRECPROFILE=SBASIC permits selected
elements with scalar fields; elements containing array fields are rejected.

TYPE fields have fixed literal or numeric MANIFEST bounds. Record names
have one type and rank throughout the active program. rec_ is reserved in
extended programs. Known ROM functions, including SIN, FILL$ and DIMN,
are safe in selectors; their arguments are still checked for effects.
VAL supports scalar arguments only. Mixed effectful
selectors may need explicit temporaries. Use multiline forms for nested
inline IF and explicitly closed inline loops. Put DATA on its own line.

Optional pools: DIM nodes(100) AS node POOL creates nodes_new% and
nodes_free. Zero is null. Allocation initializes a free slot. Exhaustion,
invalid handles and double frees stop with a message. Pool reinitialization
invalidates outstanding handles. A copied handle does not clone its record.

SSBRECWORK chooses scratch prefix (default ram1_). SSBRECITEMS chooses
table capacity (256, range 32..1024). SSBRECPROFILE is TURBO509 or SBASIC.
SSBRECLOG is an optional new filename for persistent batch diagnostics.
The tested profile limits physical array rank to 8 and expanded routine
parameters and locals to 64 each. Default table capacity remains 256.
Token text is read from source spans, REFERENCE text is streamed, and
colon statement tails are processed iteratively to reduce memory use.

Authorized replacements preserve the old output as _bakN. On a failed
translation the final output is absent; the backup is retained. Refused
replacements leave the old output intact. SSBGO preserves an old output
as _goN, then checks for fresh output before invoking the compiler. Set
SSBFILTER=ssb280_exe and SSBEXEC to the executable device prefix to use
the separate ssb280go_exe wrapper. Successful editor/grep handoff still
requires the original SSBGO tools; its full UI workflow is not certified.

To rebuild, copy all Source modules as ram1_name_ssb. Set SSBWORK and
SSBWORK2 empty because includes already name ram1_. Use existing SSB to
preprocess ram1_ssb280, load the output and CHARGE it with Turbo. Compare
output against preprocessing with the new executable. The development
object name is ram1_ssbrecdev_exe; packaging publishes it as
ssb280_exe.

Implementation follows the existing SSB modules: ssb280 coordinates both
passes and owns file cleanup/publication; ssbpass1 prepares record layouts
and expanded source before counting labels; ssbpass2 contains expansion
and numbered-output routines. functions holds shared text/lexical helpers.
There are no separate ssbrec source modules or host-language translator.
Preparation uses internal analysis/planning walks, not just two file reads.
The comment scanner retains repeated quoted markers and respects mixed quotes.
Parenthesized first arguments, inline field loop counters and final line 32767
are covered by the 14 November 2026 correctness fixes.
Sole parenthesized procedure arguments retain value semantics. Preserved
blank lines count consistently for labels in ordinary programs. The legacy
uppercase helper preserves aliased source text; Trim$ closes with its own name.
String capacities are explicit: configuration strings retain 100-byte
limits; trim results and invisible-comment working strings allow 1000 bytes.
Regression fixtures compare complete values from ordinary and records source
lines up to 1000 bytes, including comments, quotes and continuations. The
Turbo build has no assumed-capacity warnings; 62 local-only notices remain.
Standalone colon lines now pass both numbering readers. Length guards fix
an index-zero continuation slice inherited from 2.7.2g; regression tests cover
colons at file boundaries, labels and routine bodies.
The compiler itself uses ordinary SSB 2.7.2g syntax, with parallel tables.
Records are supported in user programs; the compiler does not use them
internally and needs no separate record-capable bootstrap.

See Docs/Records-Development.md and Docs/Validation.json in the source
repository for full syntax, limits, implementation and validation details.
The included ssb280_doc is the native Quill manual, with records syntax,
examples and limitations in section 8.
Copy it to a filename ending _doc and open it in Quill, not Microsoft Word.
'''
(ROOT / 'Docs' / 'records.txt').write_bytes(guide.encode('ascii'))
proof = json.loads((ROOT / 'build' / 'self-host-result.json').read_text(encoding='utf-8'))
assert proof['passed'], 'A successful self-bootstrap is required'
shutil.copy2(Path(proof['folder']) / 'new_output_bas', out / 'ssb280_bas')
for name, published, directory in [('ssbrecdev_exe', 'ssb280_exe', 'compiled-app'), ('ssbgorecdev_exe', 'ssb280go_exe', 'compiled-wrapper')]:
    shutil.copy2(ROOT / 'build' / directory / name, out / published)

def qdos_extra(name, data, attributes=b'\0' * 10):
    header = bytearray(64)
    struct.pack_into('>I', header, 0, len(data))
    header[4:14] = attributes
    encoded = name.encode('ascii')
    struct.pack_into('>H', header, 14, len(encoded))
    header[16:16 + len(encoded)] = encoded
    return struct.pack('<HH', 0xFB4A, 72) + b'QDOS02\0\0' + header

with zipfile.ZipFile(out / 'ssb280.zip', 'w', zipfile.ZIP_DEFLATED) as archive:
    for name in ['ssb280_exe', 'ssb280go_exe', 'ssb280_bas', 'records_txt', 'ssb280_doc']:
        source = {'records_txt': ROOT/'Docs'/'records.txt', 'ssb280_doc': ROOT/'Docs'/'ssb280.doc'}.get(name, out/name)
        data = source.read_bytes()
        attributes = b'\0' * 10
        if name.endswith('_exe'):
            assert data.startswith(b']!QDOS File Header'), 'Expected a Qemu executable header'
            offset = struct.unpack_from('>H', data, 18)[0] * 2
            attributes = data[20:30]
            data = data[offset:]
        info = zipfile.ZipInfo(name, (2026, 11, 15, 0, 0, 0))
        info.compress_type = zipfile.ZIP_DEFLATED
        info.extra = qdos_extra(name, data, attributes)
        archive.writestr(info, data)
with zipfile.ZipFile(out / 'ssb280.zip') as archive:
    assert archive.testzip() is None
    for item in archive.infolist():
        assert struct.unpack_from('>I', item.extra, 12)[0] == item.file_size
print('Created', out / 'ssb280.zip')


# Publish current source bytes; keep ssb272.bas as the legacy bootstrap.
with zipfile.ZipFile(out / 'Source.zip', 'w', zipfile.ZIP_DEFLATED) as archive:
    for source in sorted((ROOT/'Source').iterdir()):
        if source.is_file() and source.suffix.lower() in {'.ssb', '.bas', '.md'}:
            data = source.read_bytes()
            info = zipfile.ZipInfo(source.name, (2026, 11, 15, 0, 0, 0))
            info.compress_type = zipfile.ZIP_DEFLATED
            info.extra = qdos_extra(source.name, data)
            archive.writestr(info, data)
with zipfile.ZipFile(out / 'Source.zip') as archive:
    assert archive.testzip() is None
    for source in (ROOT/'Source').glob('*.ssb'):
        assert archive.read(source.name) == source.read_bytes()
print('Created', out / 'Source.zip')
