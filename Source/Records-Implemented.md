# Records for Structured SuperBASIC

Status: implemented development version, documented 14 November 2026. This describes the local build validated on 14 November 2026, including the five correctness fixes recorded below.

Structured SuperBASIC (SSB) now accepts record declarations, dotted field access, whole-record copying, record parameters and optional record pools. It translates them into ordinary S*BASIC variables, arrays and routines before assigning BASIC line numbers. The generated program can be interpreted or compiled with Turbo within the restrictions below.

The implementation is part of the existing SSB filter. The development executable is `ssbrecdev_exe`; its banner is `SSB records development`. It has not been assigned a new numbered release but 2.8.0 is anticipated.

Part 1 describes the implemented language. Part 2 explains how it is translated. Part 3 records the build, validation and remaining limits.

## Part 1: The implemented language

### 1. Declaring a record type

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
  lines$(2,80)
END TYPE
```

1. `TYPE` blocks occur at the top level, outside procedures and functions. Types can be declared after their uses and can refer to types declared later.
2. Includes and conditional compilation are resolved before declarations are collected. A type in inactive source contributes nothing to the program.
3. Names are case insensitive. Field suffixes follow S*BASIC conventions: no suffix means floating point, `%` means integer and `$` means string.
4. A string field specifies a positive maximum length: `name$(30)`.
5. Numeric fields may be arrays. `scores(5)` has elements zero through five. For string arrays, the last dimension is the character capacity: `lines$(2,80)` contains strings indexed zero through two, each with capacity 80.
6. Type-field bounds are nonnegative decimal integer literals or numeric `MANIFEST` constants. String capacities must be positive.
7. An embedded field such as `home AS point` contains another record by value. Recursive embedded layouts, including indirect cycles, are rejected. Integer pool handles provide links for recursive data structures.
8. A type declaration describes a layout and produces no runtime storage by itself.

### 2. Declaring record variables

```basic
DIM origin AS point, destination AS point
DIM people(100) AS person
DIM grid(8,8) AS point

DEFine PROCedure example
  LOCal working AS point
  LOCal saved(2) AS point
END DEFine
```

9. Global records use `DIM`; local records use `LOCal` inside a routine. Record parameters use `AS type` in the routine header.
10. Executing a declaration resets all its fields to numeric zero or empty strings. A local record has independent storage for each invocation, including recursive calls.
11. Record arrays include index zero. Their outer bounds may be runtime expressions; those bounds are evaluated once for allocation.
12. A record name has one type and one outer rank throughout the active program, including its declarations as a global, local or formal parameter. An ordinary variable cannot share that name.
13. This rule accommodates S*BASIC's dynamic scope: routines may see records local to their callers, but the translator must know what each record name means.
14. Declarations and routine headers occupy their own source lines.

### 3. Using fields

```basic
origin.x = 3 : origin.y = 4
people(i%).name$ = "Ada"
people(i%).scores(2) = 87
people(i%).home.x = origin.x
PRINT people(i%).name$; ","; people(i%).age%
INPUT "Age: "; origin.x
PRINT people(i%).name$(1 TO 3)
```

15. A dot selects a field. Record-array subscripts precede the dot; field-array subscripts follow the field name.
16. Embedded fields form paths such as `people(i%).home.x`.
17. A selected scalar field becomes an ordinary S*BASIC variable or array element. It can be read in expressions or written by assignment and ordinary variable-taking statements. String slicing is supported through the generated string storage.
18. A record field used as a `FOR` counter must lower to a simple numeric scalar variable. An array element or an array field cannot be used as that counter. Target-interpreter restrictions still apply, including Sinclair JS restrictions on integer loop variables.
19. Quotes, comments and `DATA` contents are not rewritten as field references. Put `DATA` on a separate line and quote colons that belong to DATA strings.

### 4. Whole-record value assignment

```basic
destination = origin
people(2) = people(1)
origin = people(1).home
```

20. Whole-record assignment requires the same declared type. Matching field shapes alone do not make distinct types interchangeable.
21. A copy includes all scalar fields, embedded fields and every logical element of array fields. Subsequent changes to the destination do not change the source.
22. Whole record arrays cannot be assigned in one operation. Copy their individual records in a loop.
23. Whole records are not general scalar expressions: they cannot be directly printed, compared, read or input. Select fields instead.
24. In a whole-record copy, nonconstant destination selectors are captured first, followed by source selectors. Each is evaluated once, before any field is written. This prevents an earlier copied field from changing a selector used by later fields.

### 5. Procedures, output records and scalar functions

```basic
DEFine PROCedure makePoint(pointOut AS point, VAL makeX, VAL makeY)
  pointOut.x = makeX
  pointOut.y = makeY
END DEFine

DEFine PROCedure flipPoint(flipOut AS point, flipIn AS point)
  LOCal flipWork AS point
  flipWork.x = flipIn.y
  flipWork.y = flipIn.x
  flipOut = flipWork
END DEFine

DEFine FuNction magnitude(measurePoint AS point)
  RETurn SQRT(measurePoint.x^2 + measurePoint.y^2)
END DEFine
```

25. Record parameters are writable references. A routine can change the caller's record.
26. There is no separate `OUT` keyword: an output record is an ordinary record parameter used for that purpose.
27. Output parameters are not cleared on entry. The routine must assign every field for which it promises a result.
28. Input and output arguments may alias. The translator does not insert a hidden result record. Use an explicit local work record when writes could overwrite input still needed; `flipPoint origin, origin` is safe with the implementation above.
29. Scalar-returning functions may accept record parameters. Functions returning records are not implemented; result type annotations are rejected.
30. Whole record arrays can be parameters. `items() AS person` declares a one-dimensional record-array parameter; `items(,) AS person` declares rank two. Call the routine with the whole array name.
31. `VAL` is supported for scalar numeric and string parameters. It is lowered to parenthesized actual arguments. `VAL` records and conflicting `REFERENCE` declarations are rejected.

### 6. The target profile and selected record elements

Turbo 5.09 cannot pass individual numeric array elements by reference. A selected record-array element expands into such elements, so this is an independent target limitation rather than a field-name or selector problem.

32. The default `TURBO509` profile rejects individual record-array elements used as record arguments. Standalone records and whole-array parameters are supported.
33. Use a standalone work record when editing one selected entry:

```basic
DIM positions(20) AS point, selectedPoint AS point
savedIndex% = index%
selectedPoint = positions(savedIndex%)
editPoint selectedPoint
positions(savedIndex%) = selectedPoint
```

34. Saving the index preserves the selected destination if the routine changes the original index variable. These are explicit copies, not automatic copy-in/copy-out reference semantics.
35. `SSBRECPROFILE=SBASIC` permits selected-element record arguments containing scalar fields only. Selected records containing array fields remain unsupported because they require numeric subarray references.
36. That additional reference form is tested in SMSQ/E's interpreter. Do not compile programs relying on it with Turbo.

### 7. Integer links and optional record pools

```basic
TYPE node
  value
  next%
END TYPE

DIM nodes(100) AS node POOL
first% = nodes_new%
nodes(first%).value = 42
nodes(first%).next% = 0
nodes_free first%
```

37. A pool is a one-dimensional global record array with capacity 1 through 32767. Zero is the null handle; allocated slots run from one to the specified capacity.
38. `nodes_new%` allocates a slot and resets all its fields to their defaults.
39. `nodes_free n%` returns a slot. Freeing zero does nothing. Exhaustion, an invalid free and a double free stop with a diagnostic.
40. Executing the pool declaration again resets the pool and invalidates outstanding handles.
41. Handles are plain integer indices, not typed or generation-checked pointers. Copying a handle does not clone a record. Use after free, or using a handle with the wrong array, is not generally detected.
42. Pool storage is global and survives routine returns. `VAL` pointer parameters prevent routines from accidentally changing the caller's integer link while traversing a structure.

### 8. Names, evaluation and statement restrictions

43. Field paths are flattened with underscores. A generated name must not collide with an ordinary program name or another generated path. Such collisions are rejected.
44. The `rec_` prefix is reserved in programs using the extension.
45. Generated selector captures and loops remain in the branch or loop where the original operation occurred. Supported forms include multiline and simple inline `IF`/`ELSE`, inline `FOR`/`REPeat`, colon-separated statements and `SELect` arms.
46. Use multiline form for nested inline conditionals and explicitly closed inline loops. Use `THEN` in `IF` headers.
47. Selectors requiring capture cannot be buried in surrounding expressions or another field selector. Mixed effectful selectors and arguments may be rejected. Split the calculation into scalar temporaries before the record operation.
48. Unknown extension functions and user-defined calls are conservatively treated as potentially effectful. The recognised pure built-ins are:

```text
ABS ACOS ACOT ASIN ATAN CHR$ CODE COS COT DEG DIMN EXP FILL$
INT LEN LN LOG10 PI RAD SIN SQRT TAN
```

49. Arguments of those functions are still examined. `SIN(RND)` does not become safe because `SIN` is pure. User-defined functions shadowing these names remain effectful; an unknown name such as `FILLMORE$` does not match `FILL$`.
50. A normal single-field access does not itself require the multiple-field capture machinery. Expanding the pure-function list does not remove Turbo's selected-element reference restriction.

### 9. A complete example

This example uses the default Turbo-compatible subset and requires no record runtime toolkit.

```basic
TYPE point
  x
  y
END TYPE

DIM origin AS point, destination AS point
makePoint origin, 3, 4
flipPoint origin, origin
destination = origin
PRINT destination.x; ","; destination.y
STOP

DEFine PROCedure makePoint(pointOut AS point, VAL makeX, VAL makeY)
  pointOut.x = makeX
  pointOut.y = makeY
END DEFine

DEFine PROCedure flipPoint(flipOut AS point, flipIn AS point)
  LOCal flipWork AS point
  flipWork.x = flipIn.y
  flipWork.y = flipIn.x
  flipOut = flipWork
END DEFine
```

It prints the coordinates 4 and 3. The output procedure uses a work record so that its input and output can be the same record.

## Part 2: How the QL implementation works

### 10. Integration into SSB

The processing path is:

```text
program_ssb -> record-aware SSB -> numbered program_bas -> interpreter or Turbo
```

The original source structure is retained:

| Source file | Responsibility |
|---|---|
| `Source/ssb280.ssb` | Driver, configuration, work files, diagnostics and safe output publication |
| `Source/ssbpass1.ssb` | Active-source collection, declarations, layouts, planning and labels |
| `Source/ssbpass2.ssb` | Record expansion, selector checks and numbered output |
| `Source/functions.ssb` | Shared lexical and text helpers |
| `Source/commands.ssb` | Existing command processing |
| `Source/ssblang.ssb` | Existing language strings and development banners |

The translator is written in ordinary SSB 2.7.2g syntax. It uses parallel tables internally, not its own records extension. Unmodified SSB 2.7.2g can therefore preprocess the current sources.

Python and Java tools support host-side preparation and actual 68000 emulator testing. They are not the implementation of record translation.

### 11. Active source, planning and numbering

The public driver still calls pass one and pass two. Internally, record processing requires several walks over work files:

1. Freeze active input after includes, continuations and conditional compilation.
2. Collect types, records, signatures and names.
3. Resolve embedded layouts and check ranks, collisions and capacities.
4. Plan generated local variables and selector captures.
5. Expand to unnumbered ordinary S*BASIC.
6. Count expanded lines and resolve labels.
7. Number and publish precisely that expanded stream.

An origin map retains original filenames and source lines for diagnostics. Labels are resolved after expansion because a single record operation may generate several BASIC lines.

Programs without active record or `VAL` syntax retain the legacy numbering path. Discovery adds input scanning, but record-table allocation and record-specific reserved-name rules are not applied to those programs.

### 12. Flattening records into ordinary variables

| Source expression | Generated storage expression |
|---|---|
| `origin.x` | `origin_x` |
| `p.name$` | `p_name$` |
| `p.home.x` | `p_home_x` |
| `people(i%).age%` | `people_age%(i%)` |
| `people(i%).scores(j%)` | `people_scores(i%,j%)` |
| `people(i%).home.x` | `people_home_x(i%)` |

These show the storage mapping; generated output also contains initialization, captures and other supporting statements where needed.

A standalone record becomes separate scalar variables and arrays. A record array becomes parallel field arrays. Outer record dimensions precede field dimensions, and string capacity is the final physical axis.

Whole-record copying becomes assignments for scalar leaves and loops for array leaves. Parameters expand into their constituent storage parameters. Local declarations and initialization provide per-call storage, including generated temporaries for recursion.

The representation supplies record value semantics without adding a native record datatype to QDOS or SMSQ/E. It does not provide a contiguous binary record layout or a general binary serialization format.

### 13. Pools and scalar value parameters

Pools add a free-list array and generated allocation/free routines. Each occupied slot is marked in the bookkeeping so invalid and repeated frees can be checked. Allocation clears record fields before returning the index.

`VAL` disappears from the generated routine header. Its actual argument is parenthesized to request scalar value passing. Existing `REFERENCE` directives are validated and emitted with the appropriate expanded header; they are not stored as a large string for every routine.

### 14. Memory and fixed limits

| Item | Implemented value |
|---|---|
| Declaration/layout table capacity | 256 by default; configurable 32..1024 |
| Source or expanded logical line | 1,000 bytes |
| Lexical tokens per line | 256 |
| Type, record and declared field name | 64 bytes |
| Generated identifier or flattened path | 160 bytes |
| Physical array rank | At most 8, including string capacity |
| Expanded routine parameters | At most 64 |
| Routine locals | At most 64, including generated temporaries |
| Simultaneous generated temporaries | At most 64 |
| Record-array outer bound | 0..32767 |
| Pool capacity | 1..32767 |
| Generated BASIC line numbers | 1..32767 |
| Active include channels | 5..23, including the root input |
| Conditional nesting | At most 32; balanced within each input file |

Table counts are independent; flattened leaves count across layouts. Name and generated-name tables each have four times the configured table capacity. Capacity checks precede writes. These are implementation guardrails, not promises that maximum-size workloads fit every machine.

The development executable requests 1,048,576 bytes of task dataspace through `TURBO_objdat 1024`, reduced from 2 MiB. `TURBO_buffersz 400` controls Turbo's compilation buffer; it is not an additional runtime I/O allocation by SSB.

Memory reductions include storing token spans rather than a duplicated token-text matrix at each parser level, streaming `REFERENCE` text to the next header, and iterating over colon-separated statement tails rather than retaining recursive frames for each tail.

Task dataspace and total machine RAM are different quantities. The latest compiled regression suite ran with 4 MiB total SMSQ/E RAM; bootstrap and interpreter checks used 8 MiB. A 2 MiB SMSQ/E environment lacked sufficient free memory to launch this filter. The development build is not intended for an original 128 KiB QL.

### 15. Configuration and output safety

Existing SSB input/output, numbering, work-file, overwrite and language settings retain their roles. Records add:

| Setting | Meaning |
|---|---|
| `SSBRECPROFILE` | `TURBO509` by default; `SBASIC` for the additional interpreted reference form |
| `SSBRECWORK` | Scratch prefix, default `ram1_` |
| `SSBRECITEMS` | Table capacity, default 256, range 32..1024 |
| `SSBRECLOG` | Optional create-new diagnostic filename |

For an authorized replacement, SSB preserves the previous output under an unused `_bakN` name. It writes staged output beside the final destination and publishes it only after successful expansion, validation and numbering. A failed translation leaves the old backup available and no misleading final output. A refused replacement preserves the existing output. Existing diagnostic logs are not overwritten.

The updated SSBGO wrapper likewise preserves authorized old output under `_goN` before invoking the filter, so stale BASIC cannot be mistaken for a successful new translation. Its `SSBFILTER` setting selects the development filter when required.

QL source files retain their single-byte character encoding. Repository attributes enforce LF for `.ssb`, `.bas` and `*_bas`, and mark `*_exe` as binary. LF normalization does not authorize conversion of QL character bytes to UTF-8.

## Part 3: What has been built and validated

### 16. Development artifacts

The local distribution contains:

| Artifact | Description |
|---|---|
| `Distribution/ssbrecdev_bas` | Numbered translator source, 93,599 bytes |
| `Distribution/ssbrecdev_exe` | Turbo-built translator, 81,886 bytes including its Qemu header |
| `Distribution/ssb-records-dev.zip` | Development package with QDOS executable metadata |
| `Docs/Records-Development.md` | Operational development documentation |
| `Docs/records.txt` | QL-readable supplement |
| `Docs/Validation.json` | Machine-readable validation evidence |

The original `Source/ssb272.bas` remains the 2.7.2g bootstrap baseline. Original release artifacts and the Quill manual were preserved. All seven language blocks use the development banner; new record diagnostics are English.

The executable checked when writing this document matches the validation manifest:

```text
SHA256 df80aad995c83f766ba1b3cd19c7f78758c7c7ecfab5beb3f9fa75a116d38f22
```

The records implementation was committed locally as 475ecb8, including the driver rename to ssb280.ssb. The correctness fixes and rebuilt artifacts described here are subsequent local changes; they have not been committed or pushed.

### 17. Latest SMSQ/E validation

The 14 November validation used SMSQ/E 3.43, SMSQmulator 3.03 emulating a 68000, Turbo parser 5.09 and code generator F5.37.

| Check | Result and scope |
|---|---|
| Interpreter suite | 38/38 checks passed, including expected rejection cases |
| Compiled filter and Turbo-compiled generated programs | 10/10 cases passed at 4 MiB total RAM |
| Legacy bootstrap | Old 2.7.2g and new SSB generated identical 93,599-byte translator BASIC |
| Previous generated-program compatibility | Eight earlier outputs remained byte identical |
| Translator compilation | 0 errors, 83 warnings; not a warning-free build |
| Output safety | Seven checks passed, covering replacement refusal, failure, backups, diagnostics, recovery and cleanup |
| SSBGO stale-output protection | Unchanged wrapper retains its previously recorded passing failure test |
| Package | Executable and QDOS metadata checked |

The ten compiled cases are `core`, `arrays-pools`, `bounds-labels`, `value-only`, `limits`, `strings`, `reference-stream`, `pure-builtins`, `legacy-comments` and `review-regressions`. The pure-builtins case exercises the 22 accepted functions and produces the expected sum 506.

The suite also checks that a pure outer function does not hide an effectful nested call, that shadowing a built-in remains conservative, and that built-in-name prefixes are not accepted accidentally. Selected-element reference extensions are interpreter-only tests.

The final executable was compiled from BASIC generated by the original SSB 2.7.2g, rather than relying solely on a host numbering helper. Both bootstrap outputs have SHA256:

```text
67bf8811d8e6875c50a6c539ad18cb98c423da93f217f83d598e46314a49914e
```

### 18. Earlier classic QDOS validation

A preceding build was tested using Q-emuLator 3.5.1 with Minerva 1.97 and Sinclair JS ROMs, 2 MiB total emulated RAM, Toolkit II and QDOS Turbo Toolkit 3.44.

Seven individual cases passed on each ROM: `core`, `arrays-pools`, `bounds-labels`, `value-only`, `limits`, `strings` and `reference-stream`. The compiled translator generated BASIC, which was then interpreted. Generated targets were not Turbo-compiled during this run.

Fixture adjustments initialized a counter before its first read, replaced SMSQ/E-specific numeric literal forms with equivalent decimal expressions, and used a real-valued loop counter on Sinclair JS. They did not change the translator.


### 19. Correctness fixes on 14 November 2026

The two inherited 2.7.2g comment-handling bugs are fixed: repeated quoted
invisible-comment markers no longer discard earlier statement text, and mixed
quote characters no longer confuse the active string delimiter. Source comments
explain both changes. The original ssb272.bas remains the bootstrap baseline.

The record-aware parser now accepts parenthesized first arguments followed by
other arguments and retains the full record-field counter when expanding an
inline FOR. Numbering accepts a final line at 32767 without validating an unused
next number. Five compiled-filter boundary checks cover valid terminal numbers,
trailing non-statements, real overflow and an invalid zero increment.
