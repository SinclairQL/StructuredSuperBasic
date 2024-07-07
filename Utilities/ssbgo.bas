100 TURBO_taskn "ssbgo"
110 TURBO_objfil "ram1_ssbgo_exe"
120 TURBO_windo 0
130 TURBO_repfil "ram1_err"
140 TURBO_objdat 400
150 TURBO_buffersz 400
160 TURBO_optim 0
170 TURBO_diags 2
180 TURBO_locstr 1
190 TURBO_struct 0
200 DIM compiler$(1), qlib_arg$(20), inputext$(4)
210 DIM output$(4), execdir$(20)
220 filename$ = OPTION_CMD$
230 IF ( " " INSTR filename$ ) THEN
240    BEEP 1000,10
250    STOP
260 END IF
270 compiler$ = "T"
280 qlib_arg$ = ""
290 inputext$ = "_ssb"
300 outputext$ = "_bas"
310 execdir$ = ""
320 temp$ = GETENV$("SSBCOMPILER")
330 IF temp$ <> "" THEN compiler$ = temp$
340 temp$ = GETENV$("SSBQLIBARG")
350 IF temp$ <> "" THEN qlib_arg$ = temp$
360 temp$ = GETENV$("SSBINPUTEXT")
370 IF temp$ <> "" THEN inputext$ = temp$
380 temp$ = GETENV$("SSBOUTPUTEXT")
390 IF temp$ <> "" THEN outputext$ = temp$
400 temp$ = GETENV$("SSBEXEC")
410 IF temp$ <> "" THEN execdir$ = temp$
420 DELETE filename$&outputext$
430 EXEC_W execdir$&"ssb";filename$
440 IF FTEST(filename$&outputext$) = -7 THEN
450    BEEP 1000,10
460    STOP
470 ENDIF
480 COMMAND_LINE
490 cmd$ = "LOAD "&filename$&outputext$&CHR$(10)
500 TYPE_IN cmd$
510 cmd$="SAVE_O "&filename$&outputext$&CHR$(10)
520 TYPE_IN cmd$
530 DELETE "ram1_ssbgo_out"
540 EW execdir$&"grep";"MISTake "&filename$&outputext$&" > ram1_ssbgo_out"
550 IF FLEN(\"ram1_ssbgo_out") <> 0 THEN
560    BEEP 1000,10
570    VIEW "ram1_ssbgo_out"
580    STOP
590 END IF
600 DELETE ram1_ssbgo_out
610 IF compiler$ = "Q" THEN
620    cmd$ = "liberate "&filename$&"_bas,'-OBJ" &filename$&" "&qlib_arg$&"'"&CHR$(10)
630    TYPE_IN cmd$
640 END IF
650 IF compiler$ = "T" THEN
660    cmd$="CHARGE \"&CHR$(10)
670    TYPE_IN cmd$
680 END IF
690 END_CMD
