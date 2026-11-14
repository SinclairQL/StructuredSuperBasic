# Structured SuperBASIC 2.7.2 bug report

Date: 14 November 2026

## Source and verification

Both defects are present in the original `Source/functions.ssb`, as checked directly from Git:

```powershell
git show 88c35ff:Source/functions.ssb
```

They are also present in the preserved original `Source/ssb272.bas`, whose language banner identifies version 2.7.2g. Its relevant BASIC line numbers are included below.

For runtime verification, the original `inString%` and `stripComment$` routines were extracted unchanged from that BASIC baseline and run with a small test driver under SMSQ/E 3.43 in SMSQmulator 3.03. The driver set `comm$="##"`, as SSB's normal second pass does. No records implementation or records executable was used in this verification.

This was a focused test of the original routines, rather than a rebuild and full end-to-end test of the original SSB executable.

## 1. Multiple quoted comment markers discard the start of a statement

**Location:** `Source/functions.ssb:195`, inside `stripComment$`.

**Original numbered BASIC:** line 9340 of `Source/ssb272.bas`.

### Example SSB input

```basic
PRINT "## one", "## two"
STOP
```

### Expected behaviour

Both `##` markers are inside quoted strings. Neither starts an invisible comment, so the complete statement should survive. With starting line 1 and increment 1, the output should be:

```basic
1 PRINT "## one", "## two"
2 STOP
```

### Actual behaviour

Calling the original `stripComment$` routine with the first source line returns:

```basic
, "## two"
```

The `PRINT` keyword and first literal have been discarded. Numbering that returned text produces invalid BASIC.

### Cause

When `stripComment$` finds a marker inside a string, it consumes the text through the closing quote, saves that text and then scans the remainder. On finding the next quoted marker, it replaces the saved output instead of appending to it:

```basic
out$ = in$(1 to whereQuote)
in$ = in$(whereQuote + 1 TO)
```

Consequently, only the text accumulated from the last quoted marker remains.

### Suggested correction

Append the newly consumed text to the accumulated output:

```basic
out$ = out$ & in$(1 to whereQuote)
in$ = in$(whereQuote + 1 TO)
```

### Regression examples

All quoted contents and the preceding statement text must remain intact:

```basic
PRINT "## one", "## two"
PRINT "## one", "## two", "## three"
PRINT "## one", "## two" ## genuine trailing comment
```

Only the genuine trailing comment in the final example should be removed.

## 2. Mixed quote characters confuse string detection

**Location:** `Source/functions.ssb:73–113`, inside `inString%`, particularly its quote-state handling at lines 78–90.

**Original numbered BASIC:** routine beginning at line 8460 of `Source/ssb272.bas`; quote-state handling begins at line 8510.

### Example SSB input

```basic
PRINT 'He said " ## here'
STOP
```

The string is delimited by single quotes. The double quote is literal content and should not affect recognition of the closing single quote.

### Expected behaviour

The complete statement should survive unchanged apart from numbering:

```basic
1 PRINT 'He said " ## here'
2 STOP
```

### Actual behaviour

In the focused interpreted test of the original routines, processing the first statement stops with:

```text
RETurn not in procedure or function
```

The error occurs at the end of `inString%`. The routine has searched for a closing double quote instead of the closing single quote and reaches `END DEFine` without returning a result.

### Cause

The routine maintains independent `Double%` and `Single%` flags. It toggles the double-quote flag even while inside a single-quoted literal, and vice versa.

For the example above:

1. The opening single quote sets `Single%`.
2. The literal double quote also sets `Double%`.
3. When the `##` marker is reached, both flags are set.
4. The routine chooses a double quote as the closing delimiter.
5. There is no subsequent double quote, so the routine falls through without returning.

Other combinations of embedded quotes can also make the routine misclassify a marker's position relative to a string.

### Suggested correction

Track one active delimiter rather than two independent quote flags:

- Outside a string, either quote character opens a string.
- Inside a string, only the matching delimiter closes it.
- The other quote character is ordinary literal content.
- Handle the absence of a closing delimiter explicitly rather than falling through without a return value.

The same helper is used by `doRemark$` for `**` conversion. That path should be checked when correcting the scanner as well.

### Regression examples

These markers are all inside literals and must remain literal text:

```basic
PRINT 'He said " ## here'
PRINT "It's ## here"
PRINT 'He said " ** here'
PRINT "It's ** here"
```

Also check mixed-quote literals followed by real trailing comments, so recognizing a literal does not prevent processing of a later genuine comment.
