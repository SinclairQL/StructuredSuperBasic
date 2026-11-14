# SSB records implementation bug report

Date: 14 November 2026

Five correctness issues were reproduced during review of the `.ssb` files in `C:\Source\Structured Super Basic\Source`. All are priority P2: normal-priority defects that should be corrected. This report records the existing behaviour; it does not apply fixes.

The reviewed implementation is now included in local commit `475ecb80a3e3e879c7987c7634946a69fddf56b0`, **Add records support to SSB and rename driver to ssb280**. The main source was subsequently renamed from `ssb272.ssb` to `ssb280.ssb`; the affected functions below remain in `functions.ssb`, `ssbpass1.ssb` and `ssbpass2.ssb`.

## Reproduction environment

The checks used the actual Turbo-built `Distribution/ssbrecdev_exe` under SMSQ/E 3.43 in SMSQmulator 3.03, with an emulated 68000 and 8 MiB total RAM. The executable's SHA256 is:

```text
1e227c6148877ae104c01ffb3f5201d13c6c2fdb739d83ec5a68a93f8fb611de
```

The host harness mounted only isolated fixture directories. It invoked the filter, captured generated BASIC and recorded the optional diagnostic log. It used these settings, with input and output prefixes adapted to each isolated directory:

```basic
SETENV "SSBSTART=1"
SETENV "SSBINC=1"
SETENV "SSBRECPROFILE=SBASIC"
SETENV "SSBRECWORK=ram1_"
```

Bug 5 overrides `SSBSTART`. None of these examples uses the SBASIC-only selected-record-element parameter extension.

For each example, save the source as an SSB input file and invoke `ssbrecdev_exe` with its basename using the normal SSB configuration. The examples are unnumbered input, not BASIC to enter directly into an unmodified interpreter.

## 1. Multiple quoted comment markers discard the start of a statement

**Location:** `Source/functions.ssb:195–196`, in `stripComment$`.

### Example source

```basic
PRINT "## one", "## two"
STOP
```

This record-free example was reproduced directly. The same defect also occurs when the statement is part of a records program.

### Expected behaviour

Both `##` markers are inside quoted strings. Neither is an invisible comment, so the complete statement should survive:

```basic
1 PRINT "## one", "## two"
2 STOP
```

### Actual behaviour

The filter reports no translation error but emits:

```basic
1 , "## two"
2 STOP
```

The generated first line is invalid BASIC.

### Cause

When `stripComment$` finds a quoted marker, it copies the portion through the closing quote into `out$`, then scans the remainder. On a second quoted marker, it assigns to `out$` again instead of appending. That discards the previously accumulated `PRINT` and first literal.

The problematic assignment is:

```basic
out$ = in$(1 to whereQuote)
```

### Correction and regression check

Append the newly consumed text to the accumulated output. Check two and three quoted markers, with and without a genuine trailing invisible comment. The text preceding each quoted marker must remain intact.

## 2. Mixed quote characters cause a string literal to be truncated

**Location:** `Source/functions.ssb:78–90`, in `inString%`; called by `stripComment$` and `doRemark$`.

### Example source

```basic
TYPE point
  x
  y
END TYPE
DIM p AS point
PRINT 'He said " ## here'
STOP
```

The string is delimited by single quotes. The double quote is part of its contents.

### Expected behaviour

The complete `PRINT` statement should remain unchanged apart from numbering:

```basic
3 PRINT 'He said " ## here'
```

### Actual behaviour

The filter reports no translation error but emits this unterminated literal:

```basic
3 PRINT 'He said " 
```

The `##` and the rest of the literal, including its closing single quote, have been removed.

### Cause

`inString%` toggles its double-quote and single-quote flags independently. It therefore treats the double quote inside the single-quoted string as another opening delimiter. It then searches for the wrong closing quote and allows the marker to be interpreted as an invisible comment.

### Correction and regression check

Track one active quote delimiter. While inside a string, only that same delimiter should close it; the other quote character is ordinary content. Check single-quoted strings containing double quotes and double-quoted strings containing apostrophes, with both `##` and `**` inside the literals.

The shared scanner also serves remark conversion, so that path needs regression coverage even though the captured failure above uses `##`.

## 3. A parenthesized first argument hides later procedure arguments

**Location:** `Source/ssbpass2.ssb:724–726`, in `rec_statement`.

### Example source

```basic
TYPE point
  x
  y
END TYPE
DIM p AS point
consume (1+2),p
STOP

DEFine PROCedure consume(VAL n,out AS point)
  out.x=n
END DEFine
```

### Expected behaviour

The call supplies two arguments: the scalar expression `(1+2)` and record `p`. The procedure should receive 3 for `n` and update `p.x` to 3.

As a control, an ordinary record-free procedure call with a parenthesized first expression and a second output argument was translated and executed successfully in the same interpreter, producing 3.

### Actual behaviour

Translation fails at the call with:

```text
RECORD ERROR: Wrong argument count: CONSUME
nfa1_input_ssb:6
```

No generated BASIC is published.

### Cause

The procedure-call handler sees the opening parenthesis after `consume` and assumes it encloses the entire argument list. It takes the matching close after `1+2` as the end of the arguments and omits `,p` before calling `rec_arguments$`.

### Correction and regression check

Only strip an enclosing pair when the matching closing parenthesis ends the complete argument list. Otherwise, retain the parentheses as part of the first argument and split all arguments at top-level commas.

Check calls whose first argument is a parenthesized expression, followed by scalar and record arguments. Also retain coverage for any intentionally supported whole-list parenthesized call form.

## 4. An inline FOR loop loses the field part of its record counter

**Location:** `Source/ssbpass2.ssb:688–690`, in `rec_statement`.

### Example source

```basic
TYPE point
  x
  y
END TYPE
DIM p AS point
FOR p.x=1 TO 3 : PRINT p.x
STOP
```

### Expected behaviour

`p.x` is a numeric scalar field of a standalone record and is an allowed loop counter. Expansion should retain that complete counter, producing the equivalent of:

```basic
FOR P_X=1 TO 3
  PRINT P_X
END FOR P_X
```

Executing it should print 1, 2 and 3 on successive lines.

### Actual behaviour

Translation fails with:

```text
RECORD ERROR: Whole records are only valid in copies and record parameters
nfa1_input_ssb:6
```

No generated BASIC is published.

### Cause

The inline loop is expanded into a header, body and closing statement. The closing statement is built using only token 2 of the original header. In this example, that token is `p`; the remaining `.x` tokens are omitted. Rewriting the resulting bare record as a scalar expression triggers the diagnostic.

### Workaround

The equivalent multiline form was confirmed to translate correctly:

```basic
TYPE point
  x
  y
END TYPE
DIM p AS point
FOR p.x=1 TO 3
  PRINT p.x
END FOR p.x
STOP
```

### Correction and regression check

Retain the complete counter expression when constructing the generated `END FOR`. Test both a direct field and an embedded numeric scalar field, alongside ordinary scalar loop counters.

## 5. A valid final BASIC line numbered 32767 is rejected

**Location:** `Source/ssbpass1.ssb:182–183`; the corresponding increment-and-check sequence also occurs in pass two. The range helper is `rec_range` in the renamed `Source/ssb280.ssb`.

### Configuration

```basic
SETENV "SSBSTART=32766"
SETENV "SSBINC=1"
```

### Example source

```basic
TYPE point
  x
END TYPE
DIM p AS point
STOP
```

### Expected behaviour

The type declaration produces no BASIC lines. The scalar declaration produces one initialization, followed by `STOP`. Both output line numbers are valid:

```basic
32766 P_X = 0
32767 STOP
```

### Actual behaviour

Translation fails with:

```text
RECORD ERROR: Expanded BASIC line range exceeds 1..32767; reduce SSBSTART/SSBINC
nfa1_input_ssb:5
```

No generated BASIC is published.

### Cause

The filter increments the line counter after counting the last statement, then checks the incremented value immediately. It rejects the unused next number, 32768, even though no statement needs that number. Pass two contains the same pattern and must be corrected as well.

### Correction and regression check

Check the number assigned to an actual numbered statement. Do not reject an out-of-range next counter unless another numbered statement needs it. Labels, comments and other non-numbered input following the final statement must not require an extra BASIC line number.

Test a final line at 32767, a following statement that genuinely exceeds the limit, and a larger increment whose last emitted number is valid but whose unused next number exceeds 32767.

## Reproduction evidence

The fixture source, generated output, diagnostic logs and JSON results are retained under:

```text
C:\Users\hcump\Documents\Codex\2026-11-13\this-chat-is-called-ssb-the\work\ssb-review
```

| Bug | Evidence folders |
|---|---|
| 1 | `quoted-comments`, `record-free-quoted-comments` |
| 2 | `mixed-quotes` |
| 3 | `parenthesized-argument`, `runtime-parenthesized-control` |
| 4 | `inline-record-counter`, `multiline-record-counter` |
| 5 | `last-line-limit` |

An `OK` marker in the host translation harness means that the harness finished collecting the result. It does not mean translation succeeded: the `error` and `output` fields record the actual filter outcome.

The review did not modify the implementation or rebuild its executable. The fixes and suggested regression tests above remain to be implemented.
