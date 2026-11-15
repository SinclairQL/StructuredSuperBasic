# Records in SSB 2.8.0

This implements the procedure-based records plan in the existing QL SSB filter.
The implementation is S*BASIC, built with Turbo. It is independent of the F# SB
project. The executable is `ssb280_exe`; its banner reads "Version 2.8.0" and
its Turbo task name is `ssb 2.8.0`.

The translator's own implementation uses ordinary SSB 2.7.2g syntax and parallel
tables. Its record facility is for translated user programs. The existing
SSB 2.7.2g can preprocess all current compiler sources; no separate record-capable
bootstrap is required. The `ssb280` / `ssbpass1` / `ssbpass2` structure is retained.

## Using records

```basic
TYPE point
  x
  y
END TYPE

TYPE person
  name$(30)
  age%
  home AS point
  scores(5)
END TYPE

DIM origin AS point, destination AS point
makePoint origin, 3, 4
destination = origin
PRINT destination.x; ","; destination.y

DEFine PROCedure makePoint(pointOut AS point, VAL makeX, VAL makeY)
  pointOut.x = makeX
  pointOut.y = makeY
END DEFine
```

Use the existing SSB command line, input/output extensions, prompts and environment
settings. For example, on SMSQ/E with the prerequisites loaded:

```basic
SETENV "SSBWORK=ram1_"
SETENV "SSBWORK2=ram1_"
SETENV "SSBSTART=100"
SETENV "SSBINC=1"
EXECUTE_W "ram1_ssb280_exe";"example"
LRUN "ram1_example_bas"
```

Copy `example.ssb` from Windows to `ram1_example_ssb`, converting CRLF line endings
to QL LF without changing other bytes. PC dots are repository
extensions; the QL filenames use underscores. Programs use SSB labels for branch
destinations, since expansion changes the generated line numbers.

Supported operations are:

- Top-level `TYPE` declarations, forward references and embedded scalar records.
  Recursive embedded layouts are rejected; pool handles support linked structures.
- Floating point and integer fields, bounded strings, numeric/string array fields.
  Bounds inside types are nonnegative decimal integer literals or numeric
  `MANIFEST` constants; string capacities must be positive.
- Global `DIM` and per-invocation `LOCal` records, including record arrays with
  runtime outer bounds. Each declaration clears all resulting fields. Numeric
  arrays include index zero. A string's last dimension is its character capacity.
- Dotted field access and nominally typed, whole-record assignment. Copies include
  embedded records and every logical array-field element. Whole-array assignment
  is rejected; copy the individual records in a loop.
- Writable record reference parameters and whole-record-array parameters such as
  `entries() AS person` and `entries(,) AS person`. Functions can accept records
  and return scalars. **Functions cannot return records.**
- Scalar `VAL` parameters, lowered to parenthesized arguments. `VAL` records are
  rejected. A procedure produces a record through an explicit output parameter;
  it does not clear that parameter on entry or protect against aliases for you.
- Optional one-dimensional global record pools. `DIM nodes(100) AS node POOL`
  generates `nodes_new%` and `nodes_free`. Handle zero is null; allocation returns
  an initialized slot from 1 through the bound. Freeing zero does nothing;
  exhaustion, invalid handles and double frees stop with a message. Redimensioning
  the pool resets it and invalidates all outstanding handles. Handles are copied
  as integers, not recursively cloned.

Record names have one type and rank throughout the active program, including
routine formals and locals. This keeps QL dynamic scope predictable. Use distinct
names for incompatible storage. Ordinary variables cannot share a record name.
Generated names are checked for collisions; `rec_` is reserved in extended input.

## Important Turbo restriction

The proposed design assumed that numeric array elements could be passed by
reference to a compiled procedure. Actual Turbo 5.09 tests reject that form with
`Can't pass expression by reference`. Consequently the default `TURBO509`
profile rejects **all individual record-array elements used as record arguments**.
Standalone records and whole record arrays are supported.

Use an explicit work record when selecting one array entry:

```basic
DIM entries(20) AS point, selectedPoint AS point
selectedPoint = entries(index%)
editPoint selectedPoint
entries(index%) = selectedPoint
```

If `editPoint` can change `index%`, save the selected index before the first copy.
This is explicit copy semantics; SSB does not silently replace reference semantics
with copy-in/copy-out.

`SETENV "SSBRECPROFILE=SBASIC"` permits individual elements whose record contains
only scalar fields for interpreter-only output. It is tested on SMSQ/E 3.43.
Elements containing array fields remain unsupported because they need numeric
subarray references. Do not compile `SBASIC`-profile output with Turbo when it uses
this extra reference form.

## Evaluation and structured statements

Copies capture all nonconstant destination selectors first, then source selectors,
once each, before writing any fields. Outer allocation bounds are captured once.
The planning pass inserts all required selector/loop locals at the beginning of
each routine, so recursion has private storage. Explicit work records are needed
for procedures whose input and output may alias.

Extended programs use a conservative statement parser. Multiline and simple
inline `IF`/`ELSE`, inline `FOR`/`REPeat`, colon-separated statements and `SELect`
arms are expanded without moving generated operations outside their branch.
Nested inline conditionals and explicitly closed inline loops must be written
in multiline form. Use `THEN` in `IF` headers. Routine headers and record
declarations must occupy their own source lines.

Selectors requiring captures cannot be buried in a larger expression or another
field selector. Mixed calls with possibly effectful selectors/other arguments
are rejected conservatively. Split them into ordinary scalar temporaries first,
then perform the record operation. Unknown extension functions are treated as
possibly effectful. An ordinary single field access does not introduce a capture.

The effect checker recognises these ROM built-ins as side-effect-free:
`ABS`, `ACOS`, `ACOT`, `ASIN`, `ATAN`, `CHR$`, `CODE`, `COS`, `COT`, `DEG`,
`DIMN`, `EXP`, `FILL$`, `INT`, `LEN`, `LN`, `LOG10`, `PI`, `RAD`, `SIN`, `SQRT`
and `TAN`. Their arguments are still checked: wrapping `RND` or a user function
inside `SIN`, for example, does not make the selector safe. User-defined functions
with these names remain effectful, and unknown extension calls remain conservative.
The selected-record-element restriction in the Turbo profile is unchanged.

Quoted literals, comments and `DATA` contents are not field-rewritten. Put `DATA`
on its own line; quote any colon inside a DATA string. Supported numeric token
forms include decimals, leading-dot fractions, exponents and QL hex/binary forms.
The extension is not a replacement parser for every historical S*BASIC dialect.

## Configuration and bounds

Existing SSB settings retain their meanings: `SSBINPUT`, `SSBOUTPUT`, `SSBSTART`,
`SSBINC`, `SSBWORK`, `SSBWORK2`, `SSBOVER`, `SSBLANG`, `SSBIGNORE_BLANKS`.
All seven language banners show version 2.8.0; existing translations remain,
and the new record diagnostics are English.

| Setting or limit | Default / supported range |
|---|---|
| `SSBRECPROFILE` | `TURBO509`; alternatively `SBASIC` |
| `SSBRECWORK` | `ram1_`; writable scratch-device/directory prefix |
| `SSBRECITEMS` | 256; integer 32..1024 entries per declaration/layout table |
| `SSBRECLOG` | Unset; optional create-new diagnostic filename for batch failures |
| Source/expanded logical line | 1,000 bytes; at most 256 lexical tokens |
| Type, record and declared field name | 64 bytes |
| Generated identifier / flattened path | 160 bytes |
| Physical array dimensions | 8, including a string's character-capacity axis |
| Expanded routine parameters / locals | 64 each; locals include generated temporaries |
| Simultaneous generated temporaries | 64 |
| Outer bound / pool size | 0..32767 / 1..32767 |
| Generated BASIC line numbers | 1..32767; increment must be positive |
| Active include input channels | 5..23; 19 files including the root |
| Nested `#IFDEF` levels | 32; directives must balance within each file |

The tables have independent counts; flattened leaves are counted across type
layouts. Name and generated-name tables each have four times `SSBRECITEMS`
entries. Capacity checks fail before writes. Raising table sizes consumes QL
memory. SSB 2.8.0 reserves 1 MiB data, reduced from 2 MiB in development,
and uses Turbo's large code model. This reservation is separate from the
emulator's total RAM: compiled regression checks run in 4 MiB SMSQ/E, while
bootstrap and interpreter checks use 8 MiB. A 2 MiB SMSQ/E test environment
reported insufficient memory when launching the filter. Original 128 KiB QLs
are not a supported configuration for SSB 2.8.0. Upper configuration
limits are guardrails, not a claim that every maximum-sized program fits memory.

The default `SSBRECITEMS=256` and syntax limits are unchanged. Tokens retain only
their positions and lengths in the original source line, avoiding about 40 KiB
of duplicated token text at each active parser level. REFERENCE directives are
streamed to the next routine header instead of allocating a 1,000-character slot
for every possible routine. Colon-separated statement tails are processed in a
loop, so long lines do not retain one parser frame for every statement.

`TURBO_objdat 1024` sets the executable's reservation in KiB. Reducing
`SSBRECITEMS` lowers the memory used inside that reservation; it does not change
the executable header. Larger workloads or table settings may need a larger
dataspace and more machine RAM. `TURBO_buffersz 400` is Turbo's compilation
buffer, not an additional reservation made by the running SSB filter.

Channels 24..28 are reserved for spool, expansion, origin map and optional error
logging. Console remains 3 and output 4. Source text lives in work files, rather
than requiring the entire expanded program to fit in memory.

## Output safety and legacy input

The implementation follows the existing SSB source structure:

| Source | Responsibility |
|---|---|
| `Source/ssb280.ssb` | Configuration, command processing, calling both passes, work-file lifecycle, diagnostics and safe output publication. |
| `Source/ssbpass1.ssb` | Selecting active includes/conditionals, record and routine declarations, layout checks, preparing the expanded stream, counting line numbers and recording labels. |
| `Source/ssbpass2.ssb` | Expansion routines for fields, storage, copies, calls and pools; numbering and writing the prepared stream with resolved label references. |
| `Source/functions.ssb` | Existing text helpers plus shared lexical, name, dimension and source-slice routines. |

`commands.ssb` and `ssblang.ssb` retain their existing roles. There are no separate
`ssbrec*.ssb` modules. All runtime translation code is SSB, processed by SSB and
compiled by Turbo; Python and Java are optional Windows build/test tools.

The driver calls `pass_one` and then `pass_two`. Their internal file readers are
`pass_one_file` and `pass_two_file`; recursive includes call the readers so that
they do not restart record preparation or reopen the origin map.

Within pass one, active source is frozen once, declarations and layouts are
checked, local requirements are planned, and the expansion routines produce
unnumbered ordinary S*BASIC. Label counting uses that complete expanded stream.
Pass two numbers precisely the same stream. These are the two public SSB passes,
with internal analysis/planning walks rather than only two physical file reads.
The shared origin map supplies original filenames and source lines in diagnostics.

Ordinary programs without active record/`VAL` syntax continue through the legacy
numbering passes. A lightweight discovery pass adds I/O overhead but does not
apply the record tables or reserved-name rules to those programs.

For authorized replacement (`SSBOVER=Y`, or `S`), the old output is renamed to an
unused `_bakN` filename. Expanded output is written beside the final output as
`_recN` and renamed into place only after successful validation and numbering.
Failure removes owned temporary files and leaves the old backup in place, with
the final output absent. A refused replacement preserves the existing output.
Use a fresh `SSBRECLOG` name per batch invocation; existing diagnostic logs are
never overwritten.

The updated `Utilities/ssbgo.ssb` checks the actual configured output path and
moves an authorized old output to `_goN` before invoking SSB, preventing a failed
invocation from being mistaken for a fresh result. Its optional `SSBFILTER`
setting chooses the filter filename; the default remains `ssb`. Set it to
`ssb280_exe` for this build. `SSBEXEC` still supplies the executable prefix.
`SSBINPUTEXT`/`SSBOUTPUTEXT` are compatibility fallbacks; the filter's existing
`SSBINPUT`/`SSBOUTPUT` settings take precedence.

## Building and tests

Source filenames map `Source/foo.ssb` to `ram1_foo_ssb`. Preserve the QL single-byte
character encoding. The Windows helpers read/write byte strings; do not use a
text editor's automatic UTF-8 conversion on the QL source files. Test fixtures
are UTF-8 and the test runner explicitly converts their literals to QL bytes.

For a QL build, copy the sources to RAM1, set `SSBWORK` and `SSBWORK2` to empty
(the includes already specify `ram1_`), set `SSBSTART=100`, `SSBINC=1`, and run
the existing SSB against `ram1_ssb280`. Load `ram1_ssb280_bas` into S*BASIC and
compile with Turbo. Turbo writes `ram1_ssb280_exe` and `ram1_ssb280_err`;
the package publishes the executable as `ssb280_exe`. Reprocess the same source with the new executable and
compare the two numbered files byte-for-byte, then compile that second output.
The supplied original `Source/ssb272.bas` remains the baseline, not an updated
generated artifact.

Optional Windows verification requires Python 3, a JDK, your own SMSQmulator
3.03 source archive with SMSQ/E 3.43, Turbo parser 5.09, code generator F5.37,
`turbo toolkit14.zip` (`turbo_sms.code`) and `env_bin`. Those dependencies are
not included. From the repository root:

```powershell
python Tools/setup_emulator.py --emulator I:/QL/SMSQmulator303src.zip --turbo I:/QL/Turbo --env I:/QL/env_bin
python Tools/run_tests.py
python Tools/compile_test.py
java -cp 'build/newclasses;build/emulator-lib/*' QlRun build/SMSQE build/compiled-app 110 build/compiled-app/commands
python Tools/self_host.py
python Tools/compile_test.py --self-host
# Run the java build command above again, then verify the rebuilt executable:
python Tools/self_host.py
python Tools/test_output_safety.py
python Tools/test_line_ranges.py
python Tools/validate_native.py
python Tools/execute_compiled.py core --compile-target
python Tools/execute_compiled.py arrays-pools --compile-target
python Tools/execute_compiled.py bounds-labels --compile-target
python Tools/execute_compiled.py limits --compile-target
```

`Tools/bootstrap.py` is only a development numbering/include helper. Record
transformation tests run the actual SSB implementation on the emulator's 68000
CPU and real SMSQ/E. Native tests execute the Turbo-built SSB and compile its
generated programs with Turbo. `self_host.py` compiles the supplied 2.7.2g baseline
and compares old/new preprocessing of the current sources. Test results and logs
are retained under `build/`; no user disks are mounted in the test machine.

Windows NFA rename in this emulator reports files in use, even for a minimal
rename test. Output publication tests therefore use the actual QL RAM filesystem
and copy inspection snapshots to the host afterwards. This does not replace
the production rename with a non-atomic host copy.

See `Validation.json` for the exact checks completed with this build.
Classic QL ROMs, QLiberator and the existing SSBGO editor/grep handoff have not
been certified. The Quill manual, `Docs/ssb280.doc`, now includes records syntax, examples and
limitations in section 8; earlier chapters retain the legacy guide with corrected filenames and configuration names. A QL-readable text supplement is provided
as `records.txt`.

## Correctness fixes on 14 November 2026

The inherited 2.7.2g comment scanner now retains the accumulated text when more
than one quoted invisible-comment marker appears on a line. It also tracks the
active string delimiter, so an apostrophe in a double-quoted string or a double
quote in a single-quoted string cannot start a second string. Comments in the
source explain both inherited fixes. The original ssb272.bas remains unchanged
as the bootstrap baseline.

Record-aware procedure calls now retain later arguments when the first argument
is a parenthesized expression. Inline FOR expansion keeps the complete scalar
record-field counter, including embedded field paths. Numbering validates the
number of an actual statement rather than rejecting an unused next line number;
a final line numbered 32767 is accepted.

Tests/legacy-comments.ssb covers ordinary programs without records.
Tests/review-regressions.ssb covers the comment fixes, parenthesized arguments and
inline record-field counters. Tools/test_line_ranges.py checks final line 32767,
an unused overflowing next number, trailing non-statements, actual overflow and
a zero increment against the compiled filter. Build helpers now use the renamed
ssb280.ssb driver while retaining the original ssb272.bas bootstrap.

The local fork review also fixed sole parenthesized procedure arguments: passing
(number%) retains value semantics; an explicit REFERENCE formal is used for
the writable scalar-reference control in both SBASIC and Turbo. Tests/parenthesized-value.ssb checks numeric and string values, nested
parentheses, explicit VAL and multiple-argument list wrappers.

Ordinary input with SSBIGNORE_BLANKS=N now counts preserved blanks in both passes,
keeping labels aligned. Pass one normalizes tabs as pass two does. The legacy
uppercase helper now returns a copy instead of altering an aliased source slice;
this also fixes interpreted translation of lower-case ordinary statements.
Tests/preserved-blank-labels.ssb exercises labels across preserved blanks using
lower-case source. Inherited changes are explained in source comments, including
the corrected END DEFine Trim$ name.

The Quill manual now lists SSBINPUT, SSBOUTPUT, SSBSTART, SSBWORK and SSBWORK2 as the
supported settings. The underscored variants in older prose are explicitly
identified as unsupported. Current command examples use ssb280_exe. The README,
original-proposal link and validation generator use the current names and manual
status. At that stage the Turbo object names were still ssbrecdev_exe and
ssbgorecdev_exe; release 2.8.0 builds ram1_ssb280_exe and ram1_ssbgo_exe, and
packaging publishes them as ssb280_exe and ssb280go_exe.

## Explicit string capacities and long-line checks

All 21 assumed-capacity warnings have been removed from the active translator.
The 16 inherited configuration strings and the records profile string now have
explicit 100-byte global capacities, preserving their previous limits.
LTrim$ and RTrim$ use 1000-byte result locals; stripComment$ uses 1000-byte input
and output locals. Source comments identify the inherited capacity fixes.
The original Source/ssb272.bas remains the historical bootstrap.

Tests/long-lines-legacy.ssb and Tests/long-lines-records.ssb contain 24
full-string checks across 100-, 101-, 255-, 999- and 1000-byte source lines.
They cover invisible and visible comments, repeated quoted markers, mixed
quotes, indentation and continuations forming a 1000-byte logical line.
Tests/long-lines-trim.ssb exercises the actual compiler trim routines at
0, 1, 99, 100, 101, 255, 999 and 1000 characters, including padded and all-space
strings. The helper source is extracted from Source/functions.ssb at test time.

Tools/generate_long_line_tests.py regenerates the fixtures and their expected
results in Tests/long-lines.json. Both interpreter and Turbo-compiled target
runs check the complete resulting strings. The previous development executable
was confirmed to corrupt a 1000-byte line containing a quoted invisible-comment
marker; the revised executable passes that case. The remaining 62 Turbo
notices concern local-only string names, not assumed capacities.

## Standalone colon fix on 15 November 2026

The interpreted legacy reader inherited an unsafe continuation test from SSB
2.7.2g: a one-character source line made LEN(in$)-1 equal zero. Both numbering
passes now check the length before reading the two-character suffix. Source
comments explain the inheritance. The original Source/ssb272.bas is preserved.

Tests/standalone-colon.ssb starts and ends with a colon line and includes colons
between statements and inside a procedure. Its label skips an assignment and
the program produces 2 in both interpreted and Turbo-compiled tests. This
exercises both numbering passes without enabling records. The complete suite
then had 44 interpreter checks and 16 compiled-filter/compiled-target cases.

## Release 2.8.0 on 15 November 2026

The executable now identifies itself as a release. All seven language banners
read "Version 2.8.0" (restoring the 2.7.2g wording with the new number), the
Turbo task name is `ssb 2.8.0`, and Turbo writes `ram1_ssb280_exe` and
`ram1_ssb280_err`. SSBGO 1.3 is task `ssbgo 1.3` and builds `ram1_ssbgo_exe`;
the package still publishes it as `ssb280go_exe`. The translation itself is
unchanged from the previous build: the generated BASIC for every compiled test
program is byte-identical.
