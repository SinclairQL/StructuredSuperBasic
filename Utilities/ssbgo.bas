100 TURBO_taskn "ssbgo 1.3"
110 TURBO_objfil "ram1_ssbgo_exe"
120 TURBO_windo 1
130 TURBO_repfil "ram1_err"
140 TURBO_objdat 400
150 TURBO_buffersz 400
160 TURBO_optim 0
170 TURBO_diags 2
180 TURBO_locstr 1
190 TURBO_struct 0
200 DIM compiler$(1), qlib_arg$(20), inputext$(4)
210 DIM outputext$(100), execdir$(100), filter$(100)
220 DIM work$(100),work2$(100),basfile$(100),backup$(100),candidate$(1024)
230 filename$ = OPTION_CMD$
240 IF ( " " INSTR filename$ ) THEN
250    BEEP 1000,10
260    STOP
270 END IF
280 compiler$ = "T"
290 qlib_arg$ = ""
300 inputext$ = "_ssb"
310 outputext$ = "_bas"
320 execdir$ = ""
330 temp$ = GETENV$("SSBCOMPILER")
340 IF temp$ <> "" THEN compiler$ = temp$
350 temp$ = GETENV$("SSBQLIBARG")
360 IF temp$ <> "" THEN qlib_arg$ = temp$
370 temp$ = GETENV$("SSBINPUTEXT")
380 IF temp$ <> "" THEN inputext$ = temp$
390 IF GETENV$("SSBINPUT")="" THEN SETENV "SSBINPUT=" & inputext$
400 temp$ = GETENV$("SSBOUTPUTEXT")
410 IF temp$ <> "" THEN outputext$ = temp$
420 temp$=GETENV$("SSBOUTPUT")
430 IF temp$<>"" THEN outputext$=temp$
440 IF GETENV$("SSBOUTPUT")="" THEN SETENV "SSBOUTPUT=" & outputext$
450 temp$ = GETENV$("SSBEXEC")
460 IF temp$ <> "" THEN execdir$ = temp$
470 filter$=GETENV$("SSBFILTER"): IF filter$="" THEN filter$="ssb"
480 work$=GETENV$("SSBWORK"): work2$=GETENV$("SSBWORK2")
490 IF work2$="" THEN work2$=work$
500 candidate$=work2$ & filename$ & outputext$
510 IF LEN(candidate$)>100 THEN PRINT "SSBGO: output path exceeds 100 bytes": STOP
520 basfile$=candidate$
530 status=FTEST(basfile$)
540 IF status<>0 AND status<>-7 THEN PRINT "SSBGO: cannot access output ";status: STOP
550 IF status=0 THEN
560   temp$=GETENV$("SSBOVER")
570   IF NOT (temp$=="Y" OR temp$=="S") THEN
580     PRINT "SSBGO: existing output; set SSBOVER=Y to authorize replacement"
590     STOP
600   END IF
610   backup$=""
620   FOR backupnum=1 TO 999
630     candidate$=basfile$ & "_go" & backupnum
640     IF LEN(candidate$)>100 THEN PRINT "SSBGO: backup name too long": STOP
650     IF FTEST(candidate$)=-7 THEN backup$=candidate$: EXIT backupnum
660   END FOR backupnum
670   IF backup$="" THEN PRINT "SSBGO: no unused backup name": STOP
680   RENAME basfile$,backup$
690   IF FTEST(basfile$)<>-7 OR FTEST(backup$)<>0 THEN PRINT "SSBGO: cannot preserve output": STOP
700   PRINT "SSBGO: previous output retained as ";backup$
710 END IF
720 EXEC_W execdir$ & filter$;filename$
730 IF FTEST(basfile$) <> 0 THEN
740    BEEP 1000,10
750    STOP
760 ENDIF
770 COMMAND_LINE
780 cmd$ = "LOAD "&basfile$&CHR$(10)
790 TYPE_IN cmd$
800 cmd$="SAVE_O "&basfile$&CHR$(10)
810 TYPE_IN cmd$
820 DELETE "ram1_ssbgo_out"
830 EW execdir$&"grep";"MISTake "&basfile$&" > ram1_ssbgo_out"
840 IF FLEN(\"ram1_ssbgo_out") <> 0 THEN
850    BEEP 1000,10
860    VIEW "ram1_ssbgo_out"
870    STOP
880 END IF
890 DELETE ram1_ssbgo_out
900 IF compiler$ = "Q" THEN
910    cmd$ = "liberate "&basfile$&",'-OBJ" &filename$&" "&qlib_arg$&"'"&CHR$(10)
920    TYPE_IN cmd$
930 END IF
940 IF compiler$ = "T" THEN
950    cmd$="CHARGE \"&CHR$(10)
960    TYPE_IN cmd$
970 END IF
980 END_CMD
