# Records for Structured SuperBASIC

Status: design proposal for a QL program, not implemented. Revised after review (section 16).

S*BASIC has numbers, integers, strings and arrays of them, but no way to group values into one
named thing. Programs fake it with parallel arrays (`name$(n)`, `age(n)`, `score(n)`) kept in step
by hand. This document defines **record types** for Structured SuperBASIC (SSB) and a QL program,
`ssbrec`, that turns them into plain S*BASIC before SSB runs. Programs that use records therefore
run wherever SSB output runs: interpreted on a QL, under SMSQ/E, and compiled with Turbo.

Part 1 is the language: what a programmer may write. Part 2 is how `ssbrec` implements it.

---

## Part 1: Rules for using records

### 1. Declaring a record type

A record type is declared in a `TYPE` block, one field per line:

```
TYPE point
  x
  y
END TYPE

TYPE person
  name$(30)          ## a string field needs a maximum length
  age%
  scores(5)          ## an array field: scores(0) to scores(5)
  home AS point      ## a field that is itself a record
END TYPE
```

1. `TYPE` blocks appear at the top level, never inside a procedure or function. They may be
   anywhere in the program or in an `#INCLUDE`d file, and a type can be used before its block.
   A `TYPE` block inside an inactive `#IFDEF` block does not exist.
2. Type and field names follow the S*BASIC rules for names (a letter, then letters, digits and
   underscores) and, like all S*BASIC names, ignore case.
3. A field's suffix gives its kind as usual: none for floating point, `%` for integer, `$` for
   string. A string field must give a maximum length: `name$(30)`.
4. A field may be an array: `scores(5)`, `grid(3,3)`. A string array field gives its dimensions and
   then the length: `lines$(10,80)`. How many dimensions are allowed in total is set by rule 10.
5. A field may be a record of another type (`home AS point`). A type may not contain itself, directly
   or through other types; use a pointer field for that (rule 31).
6. A `TYPE` block produces no code of its own.

### 2. Declaring record variables

```
DIM p AS point                ## one record
DIM people(100) AS person     ## an array of records: people(0) to people(100)
DIM grid(8,8) AS point        ## an array of records with two dimensions

DEFine PROCedure plot(c AS point)
  LOCal t AS point            ## a record local to this call
  ...
END DEFine
```

7. Every record variable is declared with `AS type`: by `DIM` for global records, by `LOCal` inside
   a procedure or function, or in the parameter list of a `DEFine`.
8. `DIM` and `LOCal` of a record set every field to 0 or the empty string.
9. An array of records may have as many dimensions as rule 10 allows.
10. Each field of an array of records becomes one S*BASIC array whose subscripts are, in order:
    the record array's subscripts, then the field's own, then (for a string field) its maximum
    length. `DIM people(100) AS person` with a field `lines$(10,80)` becomes
    `DIM people_lines$(100,10,80)`: three. The total must fit the S*BASIC the program will run on.
    The Sinclair manual states no limit, so the limit of the QL ROM, SMSQ/E and Turbo is to be
    measured (section 15); `ssbrec` rejects any declaration whose generated shape exceeds the
    measured maximum, naming the field.
11. **Scope.** Record variables follow S*BASIC's scope rules, which are dynamic: a routine sees the
    `LOCal` variables of the routines that called it, unless it declares its own. So that every
    use of a record name means the same fields wherever it is reached from, **a record name has one
    type throughout the program**: every `DIM`, `LOCal` and parameter of that name must use the same
    type. A routine may use a record it does not declare itself (a global, or a caller's `LOCal`),
    as long as the name is declared somewhere with that type.
12. A record variable's name may not also be used for an ordinary variable.

### 3. Using fields

```
p.x = 3 : p.y = p.x * 2
people(i).name$ = "Ada"
people(i).scores(2) = 87
people(i).home.x = p.x
PRINT people(i).name$; " is "; people(i).age%
INPUT "Age: "; people(i).age%
```

13. A field is reached with a dot: `p.x`, `people(i).name$`, `people(i).home.x`. Subscripts of an
    array of records come before the dot, subscripts of an array field after it:
    `people(i).scores(j)`.
14. A field is an ordinary variable of its kind. It may be used wherever S*BASIC allows a variable of
    that kind: in expressions, on the left of `=`, in `INPUT`, `READ`, as a procedure argument,
    and in string slicing (`people(i).name$(1 TO 3)`).
15. Only a field of a single record (not of an array of records) may be the control variable of a
    `FOR` loop, because S*BASIC requires a simple variable there.

### 4. Whole records

```
q = p                       ## copy every field
people(i) = people(j)
swap people(i), people(j)   ## pass records to a procedure
```

16. A record may be assigned to another record of the same type as a whole statement:
    `q = p` or `LET q = p`. It copies every field, including array fields.
17. A record (or a single element of an array of records, or a whole array of records) may be passed
    to a procedure or function whose parameter is declared with the same type. As with all
    S*BASIC variables, it is passed by reference: the procedure changes the caller's record.
18. Whole records may not be compared, printed, input or read. Use their fields.
19. **Each record reference is evaluated once.** A subscript that selects a record, as in
    `plot points(next%())`, is evaluated once, even though the record stands for several fields.
    The same holds for whole-record copies (`q = people(pick%())`) and for the sizes in a `DIM` of
    an array of records (`DIM people(count%()) AS person`).

### 5. Procedures and functions with record parameters

```
DEFine PROCedure swap(a AS person, b AS person)
  LOCal t AS person
  t = a : a = b : b = t
END DEFine

DEFine FuNction dist(a AS point, b AS point)
  RETurn SQRT((a.x - b.x)^2 + (a.y - b.y)^2)
END DEFine
```

20. A parameter is declared a record with `AS type`. Inside the routine it is used like any record.
21. An argument for a record parameter must be a record of that type: a record variable, an element
    of an array of records, or a record field of another record.
22. A parameter may be an array of records: `DEFine PROCedure sortby(list() AS person, n)`. The
    argument is the whole array: `sortby people, count`.

### 6. Functions that return a record

```
DEFine FuNction flip AS point (a AS point)
  flip.x = a.y : flip.y = a.x
END DEFine

p = flip(p)
PRINT flip(q).x
```

23. A function returns a record when its `DEFine FuNction` line names a type with `AS` before the
    parameter list. Inside the function, the result is the function's own name used as a record
    (`flip.x`). Its fields start at 0 or the empty string on every call; the function sets the ones
    it needs and returns by reaching `END DEFine` or a plain `RETurn`.
24. The result is built in storage of its own and copied to its destination only after the function
    returns. So `p = flip(p)` gives `(2,1)` from `(1,2)`: the function never sees its result
    overwrite its argument.
25. Such a function may be called as a whole statement assigning a record (`p = flip(p)`), or inside
    an expression followed by a field (`flip(q).x`).
26. **Evaluation order.** Calls of record-returning functions inside a statement are made first,
    left to right, before the rest of the statement is evaluated. Where that would change the
    order relative to other calls in the same statement, the statement is refused and must be
    split: a statement that calls a record-returning function inside an expression may not also
    call a user-defined function, a toolkit or extension function, or a built-in with side effects
    (`RND`, `INKEY$`, `KEYROW`). Built-ins without side effects (`LEN`, `ABS`, `INT`, `SQRT`,
    `CHR$`, `CODE` and so on; section 13 lists them) are allowed. Conditions of `IF` and limits of
    `FOR` follow the same rule; the call is made once, before the statement. In a one-line `IF`, a
    call in the `THEN` or `ELSE` part is made at the start of that part, so it still happens only
    when that part runs.
27. A record-returning function may be recursive.

### 7. Record pointers and pools

A pointer is the index of a record in an array of records. It is how lists, trees and other linked
structures are built, and how a function returns "a reference to" a record.

```
TYPE node
  val
  left%
  right%
END TYPE
MANIFEST : MaxNodes = 500
DIM nodes(MaxNodes) AS node POOL

DEFine FuNction insert%(VAL n%, v)
  IF n% = 0 THEN n% = nodes_new% : nodes(n%).val = v : RETurn n%
  IF v < nodes(n%).val THEN
    nodes(n%).left% = insert%(nodes(n%).left%, v)
  ELSE
    nodes(n%).right% = insert%(nodes(n%).right%, v)
  END IF
  RETurn n%
END DEFine
```

28. A pointer is an integer (`%`) variable, field or array element holding an index into an array of
    records. Index 0 means "no record"; element 0 of a pooled array is never used. Pointers are
    plain integers, not typed references: nothing records which array a pointer belongs to.
29. `DIM name(size) AS type POOL` (at the top level only) declares an array of records managed as a
    pool of `size` records, numbered 1 to `size`, where `size` is 1 to 32767 (the largest S*BASIC
    integer). It creates two routines:
    - `name_new%` returns the index of a free record with all its fields cleared;
    - `name_free n%` gives record `n%` back to the pool.

    Give the size as a Turbo `MANIFEST` constant (`MANIFEST : MaxNodes = 500`, then
    `DIM nodes(MaxNodes) AS node POOL`) rather than a literal, so it appears in one place.
    Compiled, `MANIFEST` names cost no variable space; interpreted, the line runs as ordinary
    assignments, which needs the Turbo Toolkit loaded (section 15).
30. **Pool safety.** These cases are checked and stop the program with a message naming the pool:
    - `name_new%` when every record is in use ("pool nodes full");
    - `name_free` with an index outside 1 to `size`;
    - `name_free` of a record that is already free.

    `name_free 0` does nothing, so a "no record" pointer can be freed safely. Using a pointer after
    its record has been freed is **not** detected: the record may have been handed out again, and
    reading through the old pointer gives whatever is there now. Nor is using a pointer with the
    wrong array (rule 28).
31. A type may refer to itself, or to another type, only through pointer fields (`left%`).
32. A parameter marked `VAL` is passed by value. Use it for pointers: S*BASIC passes variables and
    array elements by reference, so a routine that moves its pointer parameter along a list
    (`n% = nodes(n%).next%`) would otherwise rewrite the caller's links. `VAL` may be used with any
    simple numeric or string parameter.
33. Pointer variables follow normal S*BASIC scope: a pointer in a `LOCal` or a parameter belongs to
    one call, so recursive routines each have their own. That says nothing about the records they
    point to: pooled records are global, outlive the call that created them, and stay valid only
    until they are freed. Keeping pointers valid is the program's job.

### 8. Names

34. A field `x` of record `p` becomes the S*BASIC name `p_x` (section 11 gives the full scheme).
    `ssbrec` reports an error, naming both sources, whenever two names collide: a generated name
    and one the program already uses, **or two generated names**. For example a record `p` with a
    field `home_x` and a field `home AS point` would both produce `p_home_x`; one must be renamed.
35. Names beginning `rec_` are reserved for `ssbrec`'s own variables and routines.
36. Give record variables, record-returning functions and pools distinctive names (`player`,
    `nodes`) rather than short or common ones (`p`, `r`). Any name works, but `ssbrec` runs faster
    with distinctive names (section 13), and it warns when a name is short or common enough to slow
    it down.

### 9. A complete example

```
TYPE node
  val
  left%
  right%
END TYPE
MANIFEST : MaxNodes = 200
DIM nodes(MaxNodes) AS node POOL

root% = 0
FOR i = 1 TO 10 : v = RND(1 TO 100) : root% = insert%(root%, v) : END FOR i
walk root%
STOP

DEFine FuNction insert%(VAL n%, v)
  IF n% = 0 THEN
    n% = nodes_new%
    nodes(n%).val = v
    RETurn n%
  END IF
  IF v < nodes(n%).val THEN
    nodes(n%).left% = insert%(nodes(n%).left%, v)
  ELSE
    nodes(n%).right% = insert%(nodes(n%).right%, v)
  END IF
  RETurn n%
END DEFine

DEFine PROCedure walk(VAL n%)
  IF n% = 0 THEN RETurn
  walk nodes(n%).left%
  PRINT nodes(n%).val
  walk nodes(n%).right%
END DEFine
```

---

## Part 2: Implementation on the QL

### 10. Where it lives

`ssbrec` is a separate QL program that runs before SSB:

```
prog_ssr  --(ssbrec)-->  prog_ssb  --(SSB)-->  prog_bas  --> interpreter / Turbo
```

- SSB is not changed. Records need a statement scanner, declarations, scopes and signatures; SSB
  stays the small line filter it is, and programs without records never meet `ssbrec`.
- `ssbrec` runs before line numbering, so it can add lines freely; SSB numbers everything
  afterwards.
- `ssbrec` resolves `#INCLUDE`, `#DEFINE`, `#IFDEF` and `#ENDIF` itself, with exactly SSB's rules
  (its procedures are copied from SSB's passes), and writes only the active code with includes
  expanded. Records are therefore analysed on the same program SSB will number, and inactive
  blocks contribute no types, declarations, includes or clashes. SSB then has labels, `##`
  comments and ordinary lines left to handle.
- Input files use the extension `_ssr`; output is the `_ssb` SSB reads.
- Like SSB, `ssbrec` is written in SSB (without records), compiled with Turbo, and developed on a QL
  or emulator: SSB's README warns that its sources use the QL character set and must not be edited
  on a PC.
- Its tables are fixed-size, with defaults that environment variables can raise, as SSB does for
  labels (`SSBRECTYPES`, `SSBRECFIELDS`, `SSBRECVARS`, `SSBRECNAMES`).

### 11. Naming scheme

A field path is joined with underscores and keeps the kind suffix of the final field at the end.
Subscripts of the array of records come first, then those of the field:

| Source | S*BASIC |
|---|---|
| `p.x` | `p_x` |
| `p.name$` | `p_name$` |
| `p.home.x` | `p_home_x` |
| `people(i).age%` | `people_age%(i)` |
| `people(i).scores(j)` | `people_scores(i,j)` |
| `people(i).home.x` | `people_home_x(i)` |

Because `_` may also appear inside names, two paths can produce the same name; pass one checks every
generated name against all others and against the program's own names (rule 34).

### 12. Lowering rules

**Declarations**

| Source | S*BASIC |
|---|---|
| `TYPE ... END TYPE` | nothing (recorded in the type table) |
| `DIM p AS person` | `p_age% = 0 : DIM p_name$(30), p_scores(5) : p_home_x = 0 : p_home_y = 0` |
| `DIM people(100) AS person` | `DIM people_name$(100,30), people_age%(100), people_scores(100,5), people_home_x(100), people_home_y(100)` |
| `LOCal t AS point` | `LOCal t_x, t_y` then `t_x = 0 : t_y = 0` |
| `DEFine PROCedure plot(c AS point)` | `DEFine PROCedure plot(c_x, c_y)` |

Simple numeric and string fields of a single record are set to 0 or `""` because S*BASIC reports an
error when an unset variable is read. Array fields are cleared by `DIM`.

**Fields**: every field reference becomes its S*BASIC name (section 11).

**Evaluating a record reference once (rule 19).** A subscript that selects a record is used as
written when it is *simple*: constants, variables, array elements with simple subscripts, operators,
and calls of the side-effect-free built-ins listed in section 13. Anything else is evaluated once
into a temporary `rec_sN`, just before the statement, and the temporary is used in every field:

| Source | S*BASIC |
|---|---|
| `plot points(next%())` | `rec_s1 = next%() : plot points_x(rec_s1), points_y(rec_s1)` |
| `q = people(pick%())` | `rec_s1 = pick%() : q_name$ = people_name$(rec_s1) : ...` |
| `DIM people(count%()) AS person` | `rec_s1 = count%() : DIM people_name$(rec_s1,30), people_age%(rec_s1), ...` |

**Whole records**

| Source | S*BASIC |
|---|---|
| `q = p` (type `point`) | `q_x = p_x : q_y = p_y` |
| `q = p` (type with `scores(5)`) | `... : FOR rec_i = 0 TO 5 : q_scores(rec_i) = p_scores(rec_i) : END FOR rec_i` |
| `plot p` | `plot p_x, p_y` |
| `plot grid(i,j)` | `plot grid_x(i,j), grid_y(i,j)` |
| `sortby people, count` | `sortby people_name$, people_age%, ..., count` |

An assignment stays on one line (statements joined with `:`), so a one-line `IF ... THEN q = p` still
makes the whole copy conditional.

**Functions returning records (rules 23 to 26)**

| Source | S*BASIC |
|---|---|
| `DEFine FuNction flip AS point (a AS point)` | `DEFine PROCedure flip(flip_x, flip_y, a_x, a_y)` followed by `flip_x = 0 : flip_y = 0` |
| `flip.x = a.y` (inside it) | `flip_x = a_y` |
| `p = flip(p)` | `flip rec_t1_x, rec_t1_y, p_x, p_y : p_x = rec_t1_x : p_y = rec_t1_y` |
| `PRINT flip(q).x` | `flip rec_t1_x, rec_t1_y, q_x, q_y : PRINT rec_t1_x` |

- The result always goes into a temporary record `rec_tN` and is copied afterwards (rule 24). Writing
  straight into the destination would let the function's writes reach its own arguments, as in
  `p = flip(p)`; S*BASIC's dynamic scope means the function could also read the destination as a
  global, so the copy is kept even when the destination is not an argument.
- The function clears its result fields on entry (rule 23), so a field it does not set is 0 or
  `""`, never left over from an earlier call.
- Calls are moved to just before their statement, left to right (rule 26); in a one-line `IF`, to
  the start of the `THEN` or `ELSE` part that contains them. Before moving them, `ssbrec` scans the
  statement for other calls that could have side effects (user-defined, toolkit or extension
  functions, `RND`, `INKEY$`, `KEYROW`) and refuses the statement if it finds one.
- Temporaries `rec_tN` and `rec_sN` are declared `LOCal` in the enclosing routine, on a line inserted
  after its `DEFine` line, so each recursive call has its own; at the top level they are global.

**Pointers and pools (rules 28 to 33)**

`DIM nodes(MaxNodes) AS node POOL` becomes:

```
nodes_siz% = MaxNodes
DIM nodes_val(nodes_siz%), nodes_left%(nodes_siz%), nodes_right%(nodes_siz%), nodes_nxt%(nodes_siz%)
FOR rec_i = 1 TO nodes_siz% - 1 : nodes_nxt%(rec_i) = rec_i + 1 : END FOR rec_i
nodes_nxt%(nodes_siz%) = 0 : nodes_fre% = 1
```

The size is evaluated once into `nodes_siz%` (rule 19). `nodes_nxt%` links free records into a list
starting at `nodes_fre%`; a record in use holds -1 there, which is how a double free is detected.
These routines are written at the end of the output:

```
DEFine FuNction nodes_new%
  LOCal rec_n%
  IF nodes_fre% = 0 THEN rec_fail "pool nodes full"
  rec_n% = nodes_fre% : nodes_fre% = nodes_nxt%(rec_n%) : nodes_nxt%(rec_n%) = -1
  nodes_val(rec_n%) = 0 : nodes_left%(rec_n%) = 0 : nodes_right%(rec_n%) = 0
  RETurn rec_n%
END DEFine

DEFine PROCedure nodes_free(rec_n%)
  IF rec_n% = 0 THEN RETurn
  IF rec_n% < 1 OR rec_n% > nodes_siz% THEN rec_fail "bad record number for pool nodes"
  IF nodes_nxt%(rec_n%) = -1 THEN
    nodes_nxt%(rec_n%) = nodes_fre% : nodes_fre% = rec_n%
  ELSE
    rec_fail "record freed twice in pool nodes"
  END IF
END DEFine

DEFine PROCedure rec_fail(rec_m$)
  PRINT "Records: "; rec_m$
  STOP
END DEFine
```

A `VAL` parameter loses its marker in the `DEFine` line, and every argument passed to it is wrapped
in parentheses, which the Sinclair manual documents as making S*BASIC pass a value:

| Source | S*BASIC |
|---|---|
| `DEFine FuNction insert%(VAL n%, v)` | `DEFine FuNction insert%(n%, v)` |
| `insert%(nodes(n%).left%, v)` | `insert%((nodes_left%(n%)), v)` |

### 13. Processing

`ssbrec` works in two passes, like SSB.

**Pass one** reads the program, applying `#INCLUDE`, `#DEFINE` and `#IFDEF` as SSB does and skipping
inactive blocks entirely, and builds:

- the **type table**: each type's fields with kind, string length, array dimensions and record type,
  and the generated shape of each field in an array of records (rule 10);
- the **signature table**: each procedure and function with its record, record-array and `VAL`
  parameters, and the type a function returns;
- the **record table**: each record name with its one type (rule 11), whether it is an array, and
  pools with their sizes;
- the **name table**: every name the program uses and every name `ssbrec` will generate, to find
  collisions of either kind (rule 34).

It reports undefined types, recursive types, duplicate fields, a record name declared with two types,
shapes over the dimension limit and name collisions, with file and line.

**Pass two** rewrites the active code a statement at a time and writes the `_ssb` file: includes
expanded, conditional directives removed, labels, `##` comment lines and directives SSB still needs
copied unchanged.

**The scanner** splits a line into tokens and never rewrites inside:

- strings in `"` or `'`;
- the rest of a line after `REMark`, `**` or `##`;
- `DATA` statements (their items are constants);
- numbers, including `.5`, `1.5E3`, and `$` hexadecimal and `%` binary constants.

A line ending in `\+` is joined with the next before scanning, as SSB does. A field reference is a
name, an optional subscript list, then `.name` repeated; subscripts are matched by counting
parentheses, so `people(f(i)+1).home.x` resolves correctly. A name followed by `(` is an array if
pass one saw it dimensioned, and otherwise a function call.

**Built-ins without side effects** (rules 19 and 26): `ABS`, `ACOS`, `ACOT`, `ASIN`, `ATAN`, `CHR$`,
`CODE`, `COS`, `COT`, `DEG`, `DIMN`, `EXP`, `FILL$`, `INT`, `LEN`, `LN`, `LOG10`, `PI`, `RAD`, `SIN`,
`SQRT`, `TAN`. Any other call, including toolkit functions such as `VAL`, counts as possibly having
side effects.

**Skipping lines that can't involve records.** Scanning a line character by character is slow in
S*BASIC, and most lines of a typical program never touch a record. Before scanning, a quick test
with the built-in `INSTR` (fast even on a QL; SSB's pass two finds labels the same way) decides
whether the line needs it:

```
needs = "." INSTR in$                     ## a field reference always has a dot
IF NOT needs THEN
  FOR k = 1 TO rec_count                  ## record and generated routine names from pass one
    IF rec_name$(k) INSTR in$ THEN needs = 1 : EXIT k
  END FOR k
END IF
IF needs THEN in$ = doRecords$(in$)
```

- The test may report a line that has no record in it, but must never miss one that has.
  A false alarm only costs a scan that changes nothing: the dot in `1.5` or in a sentence inside a
  string triggers the scan, which then finds no field reference.
- Field references always contain a dot. Uses of a whole record (`q = p`, `plot p`) don't, which
  is why the record names are tested too. Record-returning functions, `VAL`-parameter routines and
  pool routines are added to the same list.
- `INSTR` finds substrings and ignores case, so a short or common record name (`p`, `rec`) matches
  most lines (`PRINT`, `PAPER`, `STOP`...) and the test stops saving time. `ssbrec` warns about
  such names (rule 36); the program is still converted correctly.
- Pass one uses the same idea for declarations: a line is examined for `TYPE`, `AS` or `POOL` only
  if `INSTR` finds the word in it.

**Errors** name the source file and line, and the record, field or routine involved: unknown field,
wrong type for a record argument, whole-record use where only fields are allowed (rule 18), `FOR`
over a field of an array of records (rule 15), a statement whose evaluation order would change
(rule 26), name collisions (rule 34), and table limits.

### 14. Testing

All testing is on a QL or Q-emuLator, with `ssbrec`, SSB and Turbo:

- **Translation tests**: for each rule, a small `_ssr` file and the exact `_ssb` expected; a test
  program runs `ssbrec` on each and compares the output.
- **Program tests**: whole programs run interpreted and compiled with Turbo, with their output
  compared: records of each field kind, arrays of records, nested records, whole-record copy,
  record parameters, record-returning functions including recursion, a linked list and the tree
  above.
- **Tests for the review findings** (section 16): `p = flip(p)` gives `(2,1)`; `plot
  points(next%())` calls `next%()` once; `p.home_x` beside `home AS point` is refused; a `TYPE` in
  an inactive `#IFDEF` block is ignored; a helper routine using its caller's `LOCal` record; a
  statement mixing a record-returning call with `RND` is refused; pool full, bad index, double
  free and `name_free 0`.

### 15. To check on a real QL before building

- The largest number of array subscripts allowed by the QL ROM's SuperBASIC, SMSQ/E and Turbo. This
  sets the limit in rule 10.
- That parentheses make an argument pass by value under Turbo, as the Sinclair manual documents for
  the interpreter (rule 32).
- Passing one row of a two-dimensional array (`people_scores(i)`) as an array argument (needed for
  an array field of one element of an array of records). If S*BASIC can't, such arguments are
  refused.
- `LOCal` arrays and `LOCal` strings with a length (`LOCal t_name$(30)`), recursion with `LOCal`,
  and dynamic visibility of a caller's `LOCal`s, under Turbo as well as interpreted.
- One-line `FOR ... : ... : END FOR` under the QL ROM's SuperBASIC as well as SMSQ/E.
- How long generated names may be before they trouble the QL's name table or Turbo.
- That an interpreted program with `MANIFEST` runs its assignments when the Turbo Toolkit is loaded,
  and what happens without it (the keyword is then unknown, so programs that are also run
  interpreted may need the toolkit, or plain assignments instead of `MANIFEST`).
- Whether `MANIFEST` also accepts string constants (the Turbo manuals only show numbers).
- That `INSTR` ignores case on the QL ROM as well as SMSQ/E (section 13 relies on it only for speed).

### 16. Changes after review

| Finding | Resolution |
|---|---|
| Returning a record straight into its destination aliases the arguments (`p = flip(p)` gave `(2,2)`) | Results go into a temporary and are copied afterwards; result fields start at zero (rules 23, 24; section 12) |
| Subscripts could be evaluated once per field (`plot points(next%())`); moving calls changes evaluation order | Record references and `DIM` sizes are evaluated once (rule 19); an explicit order policy refuses statements whose order would change (rule 26) |
| Wrapping a `VAL` argument in parentheses relies on S*BASIC passing parenthesised arguments by value | Documented S*BASIC behaviour, kept; to confirm under Turbo (section 15). (The SB toolchain does not honour it yet; a separate fix is proposed there.) |
| `p.home_x` and `p.home.x` both generate `p_home_x` | All collisions are refused, between generated names as well (rule 34) |
| Inactive `#IFDEF` blocks could introduce types and declarations | `ssbrec` applies SSB's conditional and include rules before collecting anything (rule 1; section 10) |
| S*BASIC locals are dynamically visible; a table of textual locals can't fix a record's type | Records follow dynamic scope, and a record name has one type everywhere (rule 11) |
| The array limit was argued wrongly and not grounded in the manual | The generated shape is computed in full, and the limit is measured on each target (rule 10; section 15) |
| Pools need safety rules | Full, bad index and double free are checked; `name_free 0` is allowed; use after free is stated as undetected; capacity is 1 to 32767 (rules 29, 30, 33) |
