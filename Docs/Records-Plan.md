<!-- Design reference supplied before implementation. For implemented profiles and validation, see Records-Development.md. -->

# Records in SSB: procedures with output record parameters

Status: alternative design proposal, not implemented. This document extends the existing QL
Structured SuperBASIC filter, SSB 2.7. It replaces the separate `ssbrec` program and record-returning
functions proposed in [the original records proposal](../Source/records%20proposal.md). The earlier document is retained for comparison.

The implementation is a modification of the QL SSB sources, written in SSB and compiled with
Turbo. Its input remains `_ssb` and its output remains numbered `_bas`. There is one user command
and one delivered SSB executable. Development and execution tests use a QL or emulator; this is
not an integration into the F# SB compiler.

## 1. Main decisions

- Add `TYPE`, record declarations using `AS`, field selection with `.`, whole-record assignment,
  record reference parameters, optional integer-handle pools, and scalar `VAL` parameters.
- Functions continue to return ordinary numbers, integers or strings. A function cannot return a
  record, and a function result cannot be followed by record field selection.
- A procedure produces a record by writing to an explicit record parameter. The caller supplies
  the destination. There is no new `OUT` keyword: output is the documented role of an ordinary
  writable record parameter.
- No hidden result record, function-to-procedure conversion or automatic result copy is generated.
  Selector and copy-loop temporaries are still needed for other record operations.
- Preserve existing SSB invocation, configuration and ordinary-program behaviour. Expand records
  before final label addresses or BASIC line numbers are calculated.
- Establish supported ROM, SMSQ/E, Turbo and toolkit combinations through the experiments in
  section 12. This proposal claims no completed target tests.

## 2. Types, storage and scope

### Types

```
TYPE point
  x
  y
END TYPE

TYPE person
  name$(30)
  age%
  scores(5)
  home AS point
END TYPE
```

Types are declared at top level, including in active `#INCLUDE` files. Forward type references
are allowed because declarations are collected before rewriting. An inactive conditional block
contributes no declarations or names.

Names are case-insensitive. Field suffixes give their kinds: no suffix means floating point,
`%` means integer and `$` means string. Bounded strings specify their maximum length. Numeric
and string array fields are allowed; `scores(5)` contains elements 0 through 5, while
`lines$(10,80)` has eleven strings of capacity 80.

Field bounds must be non-negative integer literals or numeric `MANIFEST` constants resolved during
declaration collection; string capacities must be positive. Generated field bounds are literals.
An instance's outer array dimensions may instead be runtime expressions. Field shapes are fixed
by the type and cannot be changed by a separate `DIM` or by redimensioning an array-field parameter.
Runtime outer bounds must evaluate to non-negative integers within the selected target's limits;
validate and retain each accepted bound once for both allocation and clearing loops.

An embedded record field is a single record, such as `home AS point`; arrays of embedded records
are outside this first version. The graph of embedded records must be acyclic. Recursive data
structures use integer handles into record pools, as described in section 6.

### Variables and arrays

```
DIM origin AS point
DIM points(100) AS point
DIM people(20) AS person

DEFine PROCedure example
  LOCal scratchPoint AS point
  ...
END DEFine
```

`DIM` declares global records and record arrays; `LOCal` declares storage belonging to one routine
invocation. Every declaration initializes all fields to zero or the empty string. Re-executing
`DIM`, including with different outer bounds, clears all elements of the resulting record array.
Allocation and clearing are separate generated operations; Turbo's array resizing behaviour must
not preserve values contrary to this rule.

Record variables follow SuperBASIC's dynamic scope. To make their layout predictable, each record
name has one type and rank throughout the active program. A name cannot denote both a scalar
record and an array, or records of different types, in different routines. Bounds may differ.
A helper may use a caller's local record if that name's type and rank are known. Use distinctive
names for parameters and locals of different types. An ordinary variable cannot share a record
variable's name.

Record-array parameters use empty dimensions: `entries() AS person` is one-dimensional and
`entries(,) AS person` is two-dimensional. The caller passes the whole array, and its rank must
match. The generated physical shape combines the outer record dimensions, any field dimensions,
and, for strings, their capacity entry. Reject shapes exceeding the measured target limits.

## 3. Fields and whole-record operations

```
origin.x = 3 : origin.y = 4
points(i).x = origin.x
people(i).home.y = points(j).y
people(i).scores(2) = 87
PRINT people(i).name$(1 TO 3)
INPUT "Age: "; people(i).age%
```

Fields behave like ordinary variables of their declared kind in expressions, assignments,
`INPUT`, `READ` and ordinary routine arguments. Only a scalar field backed by a simple variable
may be a `FOR` counter; a field selected from a record array is not a simple loop variable.

```
otherPoint = origin
points(i) = points(j)
people(i) = people(j)
```

A whole-record assignment copies every field of the same type, including embedded records and
all logical elements of array fields. Integer handles are copied as integers; their referenced
pool records are not cloned. Whole records cannot otherwise be compared, printed, read or input.
Assigning one whole record array to another is outside this version; copy its records explicitly.

Every non-constant selector of an expanded record reference is captured once. A plain variable
or pure expression is not exempt: an earlier field write can change its inputs through an alias.
For an assignment, capture destination selectors first, then source selectors, each list left to
right, before writing any field. Only literal and resolved compile-time constants may be reused.
Outer dimension expressions are likewise captured once before allocating the backing arrays.

A single-field reference that is emitted as a single array access retains its normal evaluation
point; it does not need a preceding capture merely because it contains a dot.

## 4. Procedures producing records

### Construction

```
DEFine PROCedure makePoint(pointOut AS point, VAL makeX, VAL makeY)
  pointOut.x = makeX
  pointOut.y = makeY
END DEFine

makePoint origin, 3, 4
PRINT origin.x; ","; origin.y
```

The caller must supply an already declared record of the required type. Output-first ordering is
a convention, not a new parameter mode. All record parameters are references and may be read or
written. `VAL` snapshots the scalar inputs so output writes cannot change them through aliases.

An output record is not cleared automatically on entry to a procedure. Fields the procedure does
not assign retain their incoming values. A constructor promising a complete new value must set
every field or build a fully initialized local record and copy it to the output. An ordinary
procedure `RETurn` or reaching `END DEFine` ends the procedure; neither returns a record value.

### Input/output aliasing is explicit

```
DEFine PROCedure flipPoint(flipOut AS point, flipIn AS point)
  LOCal flipWork AS point
  flipWork.x = flipIn.y
  flipWork.y = flipIn.x
  flipOut = flipWork
END DEFine

flipPoint origin, origin
```

The private work record makes this procedure safe when input and output are the same record.
Writing `flipOut.x = flipIn.y` followed by `flipOut.y = flipIn.x` without that work record would
not provide that guarantee. SSB neither invents an independent result nor silently changes the
aliasing of explicit reference parameters. Each procedure documents whether its inputs and outputs
may overlap. Programmer-declared work records are ordinary locals and are private to recursion.

### Reference arguments with array fields

The initial portable representation supports:

- Standalone records, including those with array fields, by passing scalar fields and complete
  field arrays.
- Whole arrays of records, by passing their complete backing arrays.
- Individual record-array elements whose selected record type has no array fields, including in
  embedded records. A single bounded string is a scalar field; a string-array field is not.

Passing a record-array element with an array field is refused. It would require a numeric subarray
such as `people_scores(i)`, which the Turbo manual describes as unsupported. Indexed access and
whole-record copies of those elements remain valid because they can use explicit indexed loops.
The same restriction applies to an embedded record view selected through a record array.

This restriction applies equally to explicit output parameters: a procedure cannot receive such
a destination by reference in the first version. It may instead fill a standalone work record,
after which the caller copies that record to the desired array element. A future representation
using whole backing arrays and indices would also need consistent callee layouts or specialization;
it is a separate design, not implicit copy-in/copy-out.

## 5. Ordinary functions and evaluation order

Functions may accept valid record reference arguments while returning a scalar:

```
DEFine FuNction magnitude(measurePoint AS point)
  RETurn SQRT(measurePoint.x^2 + measurePoint.y^2)
END DEFine

PRINT magnitude(origin)
```

Such calls require argument flattening but no result record. Functions with record return
annotations, record-valued `RETurn` expressions, `destination = constructor(...)` as a record
assignment, and field selection from a function result are errors. Diagnostics suggest an
explicit procedure call followed by use of its output record. There is no automatic conversion
of the rejected forms into procedure calls.

Ordinary functions with indexed record arguments still need care:

```
selectedIndex% = next%()
PRINT magnitude(points(selectedIndex%))
```

The selector is captured once before its fields are supplied. Dropping record returns does not
remove this requirement. In the first version a potentially effectful selector call inside a
scalar expression, such as `PRINT magnitude(points(next%()))`, must be split explicitly as above.
This avoids hoisting a hidden effect past another expression operand or output item.

For every transformation that introduces captures or multiple statements:

1. Keep each evaluation in its original routine and branch. An `IF` condition and each `THEN` or
   `ELSE` body are separate regions; an unselected body performs no captures or calls.
2. Preserve the dependencies of argument evaluation before invoking the containing routine.
   The containing `magnitude` or output procedure is not an unrelated competing call.
3. Refuse a region when an introduced capture would cross another potentially effectful call or
   an observable operation whose order cannot be preserved. In particular,
   `consume first%(), points(second%())` and `consume advance%(), points(i)` require explicit
   source temporaries: the former can reverse calls, and the latter can capture `i` too early.
4. Apply the same check to procedure arguments, copy selectors, dimensions, conditions and loop
   bounds. A standalone procedure call with one effectful selector may capture it when no other
   evaluation is crossed; that does not make the same rewrite safe inside a larger expression.
5. Treat user, toolkit and unknown extension functions as potentially effectful, including known
   no-argument functions written without parentheses. Use an explicit tested whitelist for pure
   built-ins, initially `ABS`, `CHR$`, `CODE`, `INT`, `LEN` and `SQRT`; extend it deliberately.
   Purity does not justify repeating a selector or moving its reads past a mutating call.

Where the small expression/statement parser cannot establish a safe transformation, diagnose the
construct and show how to split it. It does not need to rewrite arbitrary expressions into a
general sequence of hidden function calls.

## 6. Scalar value parameters and optional pools

`VAL` is allowed on simple numeric and string parameters. Remove it from the generated definition
and parenthesize its actual arguments to force value passing under the interpreter. Leave those
formals out of Turbo `REFERENCE` directives, and reject a conflicting user directive. Ordinary
non-record parameters otherwise retain their existing SSB/SuperBASIC/Turbo conventions. `VAL`
does not introduce record value parameters; an explicit local copy serves that purpose.

Optional pools remain useful for linked data:

```
TYPE node
  value
  next%
END TYPE
MANIFEST : MaxNodes = 200
DIM nodes(MaxNodes) AS node POOL

head% = nodes_new%
nodes(head%).value = 42
nodes_free head%
```

`nodes_new%` returns an integer handle, not a record. Index zero means no record and is not
allocated. Pool size is evaluated once, checked to be an integer from 1 to 32767 before narrowing,
and used to dimension and clear the backing arrays. Literal or ordinary numeric sizes are also
allowed; `MANIFEST` is a convenient optional constant definition.

Generate a free-list array and a free-head variable. A free-list entry of -1 marks an allocated
slot; other entries chain free slots, with zero terminating the chain. Allocation removes a free
slot, marks it allocated and clears all its fields. Freeing zero is a no-op; exhausted pools,
invalid indices and double frees report the pool name and stop the program.

Handles are untyped integers. Access after free or through the wrong pool is not detected. A pool
reinitialization clears data and allocation state and invalidates all outstanding handles. Pool
globals outlive local pointer variables; recursion does not make an invalid handle valid.

Pools should follow the core record implementation, so they do not delay proving output parameters
and copying. Their helpers are generated inside the same SSB output, not supplied by a second
translator or a new external runtime.

## 7. Generated representation

### Names and declarations

Join record and embedded-field paths with underscores, retaining the final leaf's suffix:

| Source | Generated access |
|---|---|
| `origin.x` | `origin_x` |
| `personOne.name$` | `personOne_name$` |
| `personOne.home.x` | `personOne_home_x` |
| `points(i).x` | `points_x(i)` |
| `people(i).scores(j)` | `people_scores(i,j)` |

Names beginning `rec_` are reserved in programs using the extension. Register every generated
name, including pool metadata and helper routines, and check user/generated and generated/generated
collisions case-insensitively. `p.home_x` and `p.home.x` cannot both generate `p_home_x`. Compatible
redeclarations of the same logical record and field intentionally share generated names for
dynamic scope and are not collisions.

```
DIM points_x(100), points_y(100)
FOR rec_i1 = 0 TO 100
  points_x(rec_i1) = 0 : points_y(rec_i1) = 0
END FOR rec_i1
```

Numeric fields are explicitly zeroed and string elements assigned `""` after allocation, including
after redimensioning. Iterate logical record/field axes, not a string's capacity coordinate.
Local records and programmer-declared work records use equivalent allocation and clearing.

Record field kinds override ambient implicit-typing conventions. The translator must preserve
those kinds with supported declarations or reject the conflicting input; it must not silently
turn a floating field into an integer because its generated name matches an `IMPLICIT%` prefix.

### Output procedure lowering

For `makePoint` from section 4, emit:

```
REFERENCE pointOut_x, pointOut_y
DEFine PROCedure makePoint(pointOut_x, pointOut_y, makeX, makeY)
  pointOut_x = makeX
  pointOut_y = makeY
END DEFine

makePoint origin_x, origin_y, (3), (4)
```

Turbo defaults scalar parameters to value passing. Every flattened record parameter, whether
documented as input or output, therefore requires `REFERENCE`. Complete array parameters also
need dummy subscripts expressing their generated rank. Verify the exact declaration and writable
argument form for bounded strings and selected string elements on the target versions.

Merge generated entries with existing `REFERENCE` entries immediately before the routine's
`DEFine`; expand entries naming record parameters and preserve unrelated scalar entries. Generated
local declarations follow the definition. No hidden output argument is added and no procedure
output is automatically cleared. The caller's record storage is allocated before the call.

### Selection and copying

```
rec_s1 = i
rec_s2 = j
points_x(rec_s1) = points_x(rec_s2)
points_y(rec_s1) = points_y(rec_s2)
```

This implements `points(i) = points(j)`. Even simple selectors are saved because writing fields
can change variables used by later selectors through aliases.

Array fields are copied with separate-line loops, one for each logical dimension. For copies or
initialization inside inline control structures, expand the enclosing structure into an equivalent
multiline form. Preserve complete `THEN`/`ELSE` membership and named loop behaviour; do not rely on
nested inline loops on the original ROM. Reject structures the parser cannot preserve.

Selector and loop temporaries are local to the enclosing routine, or global at top level. They
are distinct while simultaneously live and private to recursive invocations. Reuse slots between
independent statements only when their lifetimes do not overlap. Count their declarations and
expanded parameters against the selected target's measured limits.

## 8. Changes to existing SSB processing

The reference source is the SSB 2.7 distribution in `ssb27.zip`:

- `ssb27_ssb`: configuration, command handling, main orchestration and shared helpers.
- `ssbpass1_ssb`: `pass_one`, which counts output lines and assigns label addresses.
- `ssbpass2_ssb`: `pass_two`, which substitutes label references and emits numbered lines.
- `ssblang_ssb`: user-visible messages.

SSB 2.62 is an older combined-source alternative; select and test 2.7 as the implementation base
instead of mixing procedures from both distributions. Preserve the existing build's QL source
encoding and its include-device conventions when making source edits.

### One command, expansion before numbering

```text
program_ssb
   |
   | modified SSB
   |   A. Select active source and collect record declarations/signatures
   |   B. Lower record operations into an unnumbered expanded work file
   |   C. Existing pass_one: count that expanded file and resolve labels
   |   D. Existing pass_two: number and emit the same expanded file
   v
program_bas
```

These are internal phases of SSB, not separate user programs. An extra read or work file is a
reasonable QL tradeoff for bounded memory and stable label accounting. Do not count original
lines in phase A and then add record expansion only in phase D: every following label would be
wrong whenever a declaration, capture, loop or reference directive changed the line count.

**Legacy path.** Detect extension syntax in active source, including includes, while ignoring
strings, comments and `DATA`. If no record syntax or `VAL` declaration is present, retain the
original two-pass path and output. Discovery adds some reading; it is not a claim of zero
preprocessing overhead. Ordinary programs must not fail new record-table limits or reserved-name
checks merely because the enhanced SSB executable is being used.

**A: active source and declarations.** Reuse the existing include resolution, continuation,
conditional-symbol and comment conventions to create an active-source work stream with original
file/line information. Collect all active names, types, bounds, routine signatures, local/global
record declarations, ordinary array shapes and `REFERENCE`/`VAL` information. Resolve forward
types, check containment cycles and finish layout tables after reading the active program.

Apply conditional selection once for the extended path, then freeze that selection in the work
stream. Inactive branches contribute neither declarations nor includes. Reuse supported SSB
directive placement and nesting rules. Characterize existing define-order and continuation
edge cases before refactoring; do not let later passes choose a different active program from
the one whose types were analyzed. Unrelated legacy SSB fixes remain separate changes.

**B: lowering.** Rewrite declarations, fields, copies and calls using the completed tables; remove
type blocks and consumed conditional/include directives. Preserve symbolic labels and comments
needed by the existing final passes. Add routine `REFERENCE` and local declarations, explicit
clearing, safe captures and any required multiline structures. Append pool helpers when used.
The final expanded stream contains ordinary SSB, with no record syntax or `VAL` markers.

Generated local requirements may be discovered later in a routine than its header. Use a planning
walk followed by an emission walk, or a lowered-body spool with recorded routine boundaries, to
insert those declarations before the body. Do not retain an unbounded routine or whole program in
RAM, append locals after their first use, or assign BASIC numbers before this stitching is done.

**C and D: numbering.** Reset legacy label/line state and run both existing passes over exactly
the same finalized expanded file. Do not re-expand original includes or reselect conditionals.
Validate the complete line range before publication, using an intermediate wide enough not to
overflow a QL integer during the calculation. Apply `SSBSTART` and `SSBINC` only here. Labels
following large expansions must resolve correctly. Source programs should use SSB labels for
branch destinations; expansion cannot preserve assumed numeric positions in unnumbered input.
The enhanced path must also adapt or check the legacy line counter before it can wrap; detecting
an out-of-range value only after a 16-bit increment is too late. Include trailing label addresses
and the end-of-stream counter in the checked range.

## 9. Modules, scanning and working storage

Modify `ssb27_ssb` to coordinate the enhanced path and include new source modules. Proposed module
names are illustrative, not existing files or a second executable:

| Module | Responsibility |
|---|---|
| `ssbrecscan_ssb` | Tokens, quotes/comments, balanced parentheses and statement boundaries |
| `ssbrectype_ssb` | Type graph, fixed field layouts, declarations, signatures and collision checks |
| `ssbreclower_ssb` | Field/call expansion, copies, captures and structured control rewriting |
| `ssbrecwork_ssb` | Work-file traversal, origin mapping, routine declaration insertion and cleanup |
| `ssbrecpool_ssb` | Optional pool metadata, allocation/free helper generation |

Retain `ssbpass1_ssb` and `ssbpass2_ssb` as the final numbering modules, adapting their input and
diagnostic hooks rather than duplicating numbering logic. Extend `ssblang_ssb` for diagnostics.

Use a tokenizer plus a small representation of the statements and expressions being transformed.
No general compiler framework is needed. Never rewrite inside quoted strings, comments or `DATA`
items, and distinguish `.5`, decimal/exponent numbers, hexadecimal/binary constants and field dots.
Track ordinary arrays and array parameters so `name(...)` is not automatically mistaken for a
function call. Recognize known no-argument functions without parentheses. Diagnose unsupported
record use rather than guessing whether it is a value, a reference or a declaration.

Use fixed-capacity QL arrays for types, flattened fields, names, routine metadata and per-line
tokens. Check capacities before storing entries, and validate memory/string/array requirements
against a tested configuration. Runtime work files hold program-sized text and origin mappings.
An optional candidate filter can skip rewriting ordinary lines without record names or field
dots; declarations and structural bookkeeping are always processed. It must have no false
negatives, and disabling it must produce identical output. Do not require unusual user variable
names to obtain correct processing.

Keep original source positions through selection and expansion. Every diagnostic should identify
the original file, line and offending record, field or routine. A generated-line map lets errors
from label counting and final emission be traced back through inserted code.

## 10. Configuration, output and bootstrap

Preserve SSB's input/output prompts, command arguments, `_ssb`/`_bas` defaults and the meanings of
`SSBINPUT`, `SSBOUTPUT`, `SSBSTART`, `SSBINC`, `SSBWORK`, `SSBWORK2`, `SSBOVER` and `SSBLANG`.
Record-specific settings may add a scratch prefix, compatibility profile and table capacities;
their names, defaults and bounds must be documented before implementation. Read capacities before
dimensioning their new tables. Do not repurpose existing working-directory or label-length
settings for unrelated record limits.

Work files must use collision-checked names under a writable QL device/directory prefix. Reserve
channels centrally so they cannot collide with SSB's console, output or recursive include inputs.
Track every channel and temporary file for cleanup on success and failure. Preserve source bytes
outside intentional textual rewrites, and preserve QL characters inside literals and comments.

Generate final output into a work file and publish it only after validation and successful
numbering. Retain the user's overwrite policy. SSBGO uses the absence of the output file to detect
failure, so its enhanced-path integration must preflight an existing output before launching:
refuse the run if replacement is not authorized. Never delete an existing file to signal failure
after its replacement has been refused. A small companion SSBGO change may be required for this
preflight; it is not a second translation stage.

For an authorized replacement, preserve any old output under a collision-checked backup name and
leave the requested final path absent until successful publication. Failure must not leave a
stale or partial `_bas` that SSBGO could compile as the new result. Do not automatically restore
the backup to that apparent-success path after a failed batch run; report its retained location.

Write the modified SSB implementation in the old supported SSB language, without depending on its
own new record syntax. Bootstrap it with the existing SSB 2.7 executable, then compile with Turbo.
During development use a distinct executable name. Confirm the enhanced SSB preprocesses its own
source identically on the legacy path before replacing the delivered `ssb` program.

The source distribution already lists environment-variable support, Turbo Toolkit and Toolkit II
as requirements. The generated record program's requirements must be documented separately:
in particular, the interpreted target must recognize emitted `REFERENCE` directives, and source
`MANIFEST` statements require the appropriate toolkit. Do not assume the translator's installed
extensions will also be present when someone runs its output elsewhere.

## 11. Implementation sequence

1. Preserve the SSB 2.7 sources and build a baseline executable. Capture ordinary-program outputs
   and check configuration, includes, conditionals, continuations, comments, labels and SSBGO.
2. Run the target experiments in section 12. Establish numeric/string/array reference forms,
   local allocation, array clearing and practical limits before fixing generated layouts.
3. Add feature discovery, active-source work files, source mapping and bounded declaration tables.
   Prove the no-extension path still uses the legacy passes and produces the baseline outputs.
4. Add scalar and embedded records, global/local allocation, field access, scalar-field copies and
   explicit-output procedures. Generate and merge Turbo reference directives.
5. Add record arrays, stable selector capture, array fields, multiline copying and redimension
   clearing. Enforce the restricted array-element argument form explicitly.
6. Add scalar functions with record parameters, `VAL` rewriting and the limited expression-order
   checks. Diagnose record-return syntax and unsafe mixtures with clear alternatives.
7. Add optional pools and their error checks after the record core is working.
8. Run the full compiled/interpreted and integration matrix, update user documentation and build
   instructions, and only then release the enhanced SSB executable.

Every stage produces reviewable examples through the same SSB command. Source declarations and
planned tests in this document do not imply that any implementation or runtime validation exists.

## 12. Target experiments and regression tests

### Establish the target contracts first

Use hand-written lowered SuperBASIC programs before generating their equivalents:

- Reference updates to numeric fields and explicit output parameters under the interpreter and
  Turbo. Verify that omitted `REFERENCE` changes compiled behaviour, demonstrating why emission
  is necessary. Check merging with user directives and `VAL` exclusions.
- Bounded string references, selected string elements, complete numeric/string array fields and
  complete record backing arrays: verify exact writable argument forms, suffixes, capacities
  and dummy ranks. If a form fails, revise or restrict the advertised profile before release.
- `LOCal` records with arrays/strings and generated selector/loop locals across repeated and
  recursive calls. Verify the dynamic visibility used by a helper accessing its caller's record.
- Grow/shrink and same-size `DIM` operations with explicit clearing; compare numeric and string
  fields under Turbo and interpreted execution.
- Multiline loops and inline-structure expansion, line/name/array limits and expanded parameter
  and local counts. The Turbo manuals warn of old interpreter failures beyond nine locals or
  parameters; test the chosen ROM rather than assuming that limit applies to all QLs.
- Generated field kinds in the presence of `IMPLICIT` declarations; an unpreservable conflict is
  a diagnostic, never a silent representation change.
- Toolkit startup requirements for generated `REFERENCE` and optional source `MANIFEST`, including
  documented string constants. Record exact versions, settings and results in the target profile.

### Core execution cases

- Construct `origin` as `(3,4)` through `makePoint`; check that only the procedure's assigned
  fields change. Partially updating a prepopulated record must preserve its other fields.
- `flipPoint origin, origin` gives `(4,3)` using its explicit local work record. The translator
  must not create hidden result storage or clear the output parameter on entry.
- `magnitude(origin)` returns the expected scalar. Record-return annotations, record-valued
  returns and selecting a field from a function result are rejected.
- Each non-constant selector of a record copy or expanded reference argument is captured once.
  Include a reference index aliasing the first destination field so that the copy must remain
  attached to one source element even after that field is written.
- Conflicting effectful arguments are refused. Explicitly split versions produce the expected
  call order. Unselected branches perform no captures or output-procedure calls.
- Copy all elements of multidimensional numeric/string fields inside inline `IF`, `FOR` and
  `REPeat` constructs. Verify resulting branch membership and loop exits.
- Passing an array-field record-array element as input or output is refused; copying it through
  a standalone record still works. Whole record arrays retain reference updates and rank checks.
- Compatible dynamic-scope redeclarations work; incompatible type/rank reuse, containment cycles,
  unknown fields, generated-name collisions and exhausted tables report original locations.
- Optional pools cover allocation clearing, exhaustion, invalid size/index, double free, free of
  zero, recursive handle use and invalidation of outstanding handles on pool reinitialization.

### SSB integration cases

- Compare ordinary programs byte-for-byte with the baseline SSB output. Include new-keyword text
  in strings, comments and `DATA` so it cannot accidentally activate record processing.
- Records declared in active includes and forward declarations work; inactive types/includes
  contribute nothing. All analysis and numbering phases use the same selected source.
- Place forward/backward labels after expanded declarations and long array copies. With several
  `SSBSTART`/`SSBINC` settings, verify that both numbering passes see identical expanded lines and
  branches reach the intended statements. Diagnose an overflowing final line range.
- Test early declarations of generated locals, mutually recursive routines, low table capacities,
  long input/generated lines, full scratch storage and include-channel depth. Fail without
  publishing partial output or leaving SSBGO a stale apparent-success file.
- The executable built through the legacy bootstrap path and the enhanced legacy path produces
  matching output for its own SSB sources. Existing source archives remain preserved.

Translation fixtures are useful for inspecting the generated form; execution and integration
checks establish its semantics. Compare the same programs under the named interpreted and compiled
targets rather than treating a successful Turbo compilation as proof of correct behaviour.

## 13. What is simpler than the earlier proposal

| Earlier design | This design |
|---|---|
| Separate `ssbrec` executable and `_ssr` stage | Record support is integrated into SSB; `_ssb` goes directly to `_bas` |
| A function declares a record return type | A procedure declares an ordinary writable record parameter |
| Compiler-created result storage and hidden output arguments | Caller-selected destination and ordinary reference arguments |
| Automatic result initialization and alias-protecting final copy | Procedure explicitly assigns fields or uses a declared local work record |
| Calls returning records inside expressions and conditions | Scalar functions and explicit output-procedure statements |
| Extensive record-result hoisting and nested-result rules | Remaining checks concern record argument/copy selectors and expansion order |

The selector, array-layout, reference-calling and label-accounting requirements remain. The feature
is smaller because implicit record results are absent, not because those remaining obligations
can be ignored. This plan keeps the existing SSB program as the user's single translation tool.

## 14. Reference material checked

- SSB 2.7 source distribution `ssb27.zip`: `ssb27_ssb`, `ssbpass1_ssb`, `ssbpass2_ssb`,
  `ssblang_ssb` and the supplied documentation. The examined local archive is
  `I:\QL\zips\ssb27.zip`.
- Turbo manual pack `manuals.zip`: `turbos3.txt`, chapters K and P (arrays, initialization and
  parameter passing); `turbos4.txt` (`MANIFEST`, including strings); `turboref.txt`
  (`ARRAY OPERATION NOT ALLOWED`). The examined local archive is `I:\QL\Turbo\manuals.zip`.
- Supplied Turbo `parser502_bas`, routine `By_Reference%`, for the distinction between reference
  bindings and ordinary value parameters.

These sources inform the proposed implementation. Target-specific observations still need the
experiments above; no source archive or QL executable is modified by creating this document.
