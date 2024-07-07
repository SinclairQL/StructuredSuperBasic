100 TURBO_taskn "ssb 2.7.2"
110 TURBO_objfil "ram1_ssb_exe"
120 TURBO_windo 0
130 TURBO_repfil "ram1_ssb_err"
140 TURBO_objdat 400
150 TURBO_buffersz 400
160 TURBO_optim 0
170 TURBO_diags 2
180 TURBO_locstr 1
190 TURBO_struct 0
200 IMPLICIT% d_labels, d_length, d_start, d_delta, label_var, define_var
210 IMPLICIT% num_count, file_num, count, x, y, temp, line_num_d, line_delta
220 IMPLICIT% line_num
230 d_labels = 30
240 d_length = 16
250 d_in$    = "_ssb"
260 d_out$   = "_bas"
270 d_start  = 100
280 d_delta  = 10
290 d_working$ = ""
300 d_work2$ = ""
310 d_over$  = ""
320 d_lang$  = "E"
330 DIM out_file$(100), command$(100), file$(100), in_file$(100), temp$(100)
340 DIM line_num$(10), line_delta$(10), argfile$(100), in$(1000), in2$(1000)
350 DIM label$(d_labels,d_length)
360 DIM label(d_labels)
370 DIM defn$(d_labels,d_length)
380 label_var = 1
390 define_var = 1
400 num_count = 0
410 file_num = 5
420 out_file$ = ""
430 t_in$ = GETENV$("SSBINPUT")
440 IF t_in$ <> "" THEN d_in$ = t_in$
450 t_out$ = GETENV$("SSBOUTPUT")
460 IF t_out$ <> "" THEN d_out$ = t_out$
470 t_start$ = GETENV$("SSBSTART")
480 IF t_start$ <> "" THEN d_start = t_start$
490 t_delta$ = GETENV$("SSBINC")
500 IF t_delta$ <> "" THEN d_delta = t_delta$
510 t_working$ = GETENV$("SSBWORK")
520 IF t_working$ <> "" THEN d_working$ = t_working$
530 t_work2$ = GETENV$("SSBWORK2")
540 IF t_work2$ <> "" THEN d_work2$ = t_work2$
550 t_over$ = GETENV$("SSBOVER")
560 IF t_over$ <> "" THEN d_over$ = t_over$
570 t_lang$ = GETENV$("SSBLANG")
580 IF t_lang$ <> "" THEN d_lang$ = t_lang$
590 DIM lngarray$(36,42)
600 IF d_lang$ = "E"
610    lngarray$(1) = "STRUCTURED SUPERBASIC FILTER"
620    lngarray$(2) = "      Version 2.7.2"
630    lngarray$(3) = " By Timothy Swenson"
640    lngarray$(4) = "Enter Input File: ("
650    lngarray$(5) = "ERROR - File In Use"
660    lngarray$(6) = "ERROR - File Does Not Exist"
670    lngarray$(7) = "ERROR - Bad File Name"
680    lngarray$(8) = "Enter Output File: (Default "
690    lngarray$(9) = "ERROR - File Exists"
700    lngarray$(10) = "OK to Delete (Y/N)"
710    lngarray$(11) = "Enter Starting Line Number: (Default "
720    lngarray$(12) = "ERROR - Must Enter A Number"
730    lngarray$(13) = "ERROR - 2nd Arg is Not A Valid Number"
740    lngarray$(14) = "ERROR - Output File Exists"
750    lngarray$(15) = "ERROR - Bad File Name - Output File"
760    lngarray$(16) = "ERROR - Output File In Use"
770    lngarray$(17) = "Pass 1"
780    lngarray$(18) = "Pass 2"
790    lngarray$(19) = "Program Done"
800    lngarray$(20) = "Hit Any Key"
810    lngarray$(21) = "FATAL ERROR - Bad Name "
820    lngarray$(22) = "FATAL ERROR - File Not Found "
830    lngarray$(23) = "FATAL ERROR - File In Use "
840    lngarray$(24) = "FATAL ERROR - End of File Found While Looking for \"
850    lngarray$(25) = "FILE : "
860    lngarray$(26) = "FATAL ERROR - Label"
870    lngarray$(27) = " Too Long"
880    lngarray$(28) = "LINE NUMBER: "
890    lngarray$(29) = " IN FILE: "
900    lngarray$(30) = "FATAL ERROR - Too Many Labels"
910    lngarray$(31) = "FATAL ERROR - DEFINE "
920    lngarray$(32) = " Not Found"
930    lngarray$(33) = "FATAL ERROR - Too Many DEFINE's"
940    lngarray$(34) = "FATAL ERROR - End of File Found Before #ENDIF"
950    lngarray$(35) = "FATAL ERROR - Label "
960    lngarray$(36) = "Enter Increment for Line Numbers: (Default "
970 END IF
980 IF d_lang$="I"
990    lngarray$(1) = "STRUCTURED SUPERBASIC FILTER"
1000    lngarray$(2) = "       Versione 2.7.2"
1010    lngarray$(3) = " di Timothy Swenson"
1020    lngarray$(4) = "File di input: ("
1030    lngarray$(5) = "ERRORE - Il file  in uso"
1040    lngarray$(6) = "ERRORE - Il file non esiste"
1050    lngarray$(7) = "ERRORE - Nome di file errato"
1060    lngarray$(8) = "File di output: (Default "
1070    lngarray$(9) = "ERRORE - File gia' esistente"
1080    lngarray$(10) = "Cancellarlo (S/N)"
1090    lngarray$(11) = "Inserisci il numero iniziale della numerazione: (Default "
1100    lngarray$(12) = "ERRORE - Devi inserire un numero"
1110    lngarray$(13) = "ERRORE - Il Secondo Argomento non e' Un numero valido"
1120    lngarray$(14) = "ERRORE - File di output gi esistente"
1130    lngarray$(15) = "ERRORE - Nome Errato - Output File"
1140    lngarray$(16) = "ERRORE - File di output In Uso"
1150    lngarray$(17) = "Fase 1"
1160    lngarray$(18) = "Fase 2"
1170    lngarray$(19) = "Creato Programma"
1180    lngarray$(20) = "Premi Un Tasto"
1190    lngarray$(21) = "ERRORE BLOCCANTE - Nome errato "
1200    lngarray$(22) = "ERRORE BLOCCANTE - File on trovato "
1210    lngarray$(23) = "ERRORE BLOCCANTE - File in uso "
1220    lngarray$(24) = "ERRORE BLOCCANTE - Fine del file trovata cercando \"
1230    lngarray$(25) = "FILE : "
1240    lngarray$(26) = "ERRORE BLOCCANTE - Etichetta"
1250    lngarray$(27) = " Troppo Lunga"
1260    lngarray$(28) = "NUMERO INIZIALE: "
1270    lngarray$(29) = " IN FILE: "
1280    lngarray$(30) = "ERRORE BLOCCANTE - Troppe Etichette"
1290    lngarray$(31) = "ERRORE BLOCCANTE - DEFINE "
1300    lngarray$(32) = " Non Trovata"
1310    lngarray$(33) = "ERRORE BLOCCANTE - Troppe DEFINE's"
1320    lngarray$(34) = "ERRORE BLOCCANTE - Fine del file trovata prima di  #ENDIF"
1330    lngarray$(35) = "ERRORE BLOCCANTE - Etichette "
1340    lngarray$(36) = "Incremento del numero di linea: (Default "
1350 END IF
1360 IF d_lang$="F"
1370    lngarray$(1) = "STRUCTURED SUPERBASIC FILTER"
1380    lngarray$(2) = "       Version 2.7.2"
1390    lngarray$(3) = " par Timothy Swenson"
1400    lngarray$(4) = "Fichied d'entrƒe: ("
1410    lngarray$(5) = "ERREUR - Le fichier est en cours d'utilisation"
1420    lngarray$(6) = "ERREUR - Le fichier ne existe pas"
1430    lngarray$(7) = "ERREUR - nom de fichier incorrect"
1440    lngarray$(8) = "Fichier Sortie: (Default "
1450    lngarray$(9) = "ERREUR - Fichier dej existantes"
1460    lngarray$(10) = "Supprimer (O/N)"
1470    lngarray$(11) = "Entrez le numƒro de dƒpart de la numƒrotation: (Default "
1480    lngarray$(12) = "ERREUR - Vous devez entrer un nombre "
1490    lngarray$(13) = "ERREUR - Le deuxime argument n'est pas un nombre valide"
1500    lngarray$(14) = "ERREUR - Fichier de sortie existe dƒj"
1510    lngarray$(15) = "ERREUR - nom incorrect - fichier de sortie"
1520    lngarray$(16) = "ERREUR - fichier de sortie en cours d'utilisation"
1530    lngarray$(17) = "Phase 1"
1540    lngarray$(18) = "Phase 2"
1550    lngarray$(19) = "Crƒe Programme"
1560    lngarray$(20) = "Appuyez sur une touche"
1570    lngarray$(21) = "ERREUR BLOCAGE - Nom incorrect "
1580    lngarray$(22) = "ERREUR BLOCAGE - Fichier ne pas trouvƒe "
1590    lngarray$(23) = "ERREUR BLOCAGE - Fichier en cors d'utilisation"
1600    lngarray$(24) = "ERREUR BLOCAGE - Fin de fichier trouvƒ essayer \"
1610    lngarray$(25) = "FICHIER : "
1620    lngarray$(26) = "ERREUR BLOCAGE- ƒtiquette"
1630    lngarray$(27) = " Trop LONG"
1640    lngarray$(28) = "PREMIERE NUMERO: "
1650    lngarray$(29) = " EN FICHIER: "
1660    lngarray$(30) = "ERREUR BLOCAGE - Trop d'etiquettes"
1670    lngarray$(31) = "ERREUR BLOCAGE - DEFINE "
1680    lngarray$(32) = " Non Trovata"
1690    lngarray$(33) = "ERREUR BLOCAGE - Trop DEFINE's"
1700    lngarray$(34) = "ERREUR BLOCAGE - Fin de fichier trouvƒ avant #ENDIF"
1710    lngarray$(35) = "ERREUR BLOCAGE - Etiquettes "
1720    lngarray$(36) = "Augmentation du nombre de ligne: (Default "
1730 END IF
1740 IF d_lang$ = "D"
1750    lngarray$(1) = "STRUCTURED SUPERBASIC FILTER"
1760    lngarray$(2) = "      Version 2.7.2"
1770    lngarray$(3) = " By Timothy Swenson"
1780    lngarray$(4) = "Eingansdatei Angeben: ("
1790    lngarray$(5) = "Fehler - Datei ist Offen"
1800    lngarray$(6) = "Fehler - Datei Existiert Nicht"
1810    lngarray$(7) = "Fehler - Falscher Dateien Name"
1820    lngarray$(8) = "Ausgansdatei Angeben: (Vorgabewert "
1830    lngarray$(9) = "Fehler - Datei Existiert"
1840    lngarray$(10) = "OK zu Löschen (Y/N)"
1850    lngarray$(11) = "Anfänginge Linien Number Eingeben: (Vorgabewert "
1860    lngarray$(12) = "Fehler - Eine Nummer muss eihgegeben werden"
1870    lngarray$(13) = "Fehler - Das Zweite Argument ist eine Invalide Nummer"
1880    lngarray$(14) = "Fehler - Ausgansdatei Existiert"
1890    lngarray$(15) = "Fehler - Falscher Dateien Name - Ausgansdatei"
1900    lngarray$(16) = "Fehler - Ausgangsdatei ist Offen"
1910    lngarray$(17) = "Pass 1"
1920    lngarray$(18) = "Pass 2"
1930    lngarray$(19) = "Program Fertig"
1940    lngarray$(20) = "Irgend eine Taste Drücken"
1950    lngarray$(21) = "Fataler Fehler - Falscher Name"
1960    lngarray$(22) = "Fataler Fehler - Datei Nicht Gefunden"
1970    lngarray$(23) = "Fataler Fehler - Datei ist Offen"
1980    lngarray$(24) = "Fataler Fehler - Ende der Datei Gefunden Beim Gesuch Nach \"
1990    lngarray$(25) = "Datei : "
2000    lngarray$(26) = "Fataler Fehler - Kennsatz"
2010    lngarray$(27) = " Zu Lange"
2020    lngarray$(28) = "Linien Nummer: "
2030    lngarray$(29) = " In Datei: "
2040    lngarray$(30) = "Fataler Fehler - Zu Viele Kennsätze"
2050    lngarray$(31) = "Fataler Fehler - Definieren "
2060    lngarray$(32) = " Nicht Gefunden"
2070    lngarray$(33) = "Fataler Fehler - Zu Viele Definierungen "
2080    lngarray$(34) = "Fataler Fehler - Ende der Datei Gefunden Bevor #ENDIF"
2090    lngarray$(35) = "Fataler Fehler - Kennsatz"
2100    lngarray$(36) = "Erhöhung der Linien Nummern Eintragen: (Vorgabewert "
2110 END IF
2120 IF d_lang$ = "K"
2130    lngarray$ (1) = "tlham SUPERBASIC FILTER"
2140    lngarray$ (2) = "2.7.2 Version"
2150    lngarray$ (3) = "pong Timothy Swenson"
2160    lngarray$ (4) = "teywI' input:"
2170    lngarray$ (5) = "Qagh-teywI' neH lo'" 
2180    lngarray$ (6) = "wej nIv'e' Qagh-teywI'" 
2190    lngarray$ (7) = "Qagh-vo' ruv nge' teywI' pong"
2200    lngarray$ (8) = "teywI' output: (Default"
2210    lngarray$ (9) = "chonayta' nIv'e' Qagh-teywI'"
2220    lngarray$ (10) = "qIl (s ghap n)"
2230    lngarray$ (11) = "So'meH mI' pImchugh chuqmey poHmey 'el: (Default"
2240    lngarray$ (12) = "Qagh-mI' ghob'e' 'el SoH"
2250    lngarray$ (13) = "Qagh-2nd arg wej mach Valid mI'"
2260    lngarray$ (14) = "Qagh-Output teywI' nIv'e'"
2270    lngarray$ (15) = "Qagh-qab teywI' pong-teywI' Output"
2280    lngarray$ (16) = "Qagh-Output teywI' neH lo'" 
2290    lngarray$ (17) = "1" 
2300    lngarray$ (18) = "2" 
2310    lngarray$ (19) = "HIja'" 
2320    lngarray$ (20) = "qIp vay' ngaQHa'moHwI'mey" 
2330    lngarray$ (21) = "HeghmoH Qagh-qab pong" 
2340    lngarray$ (22) = "HeghmoH Qagh-teywI' wej tu'"
2350    lngarray$ (23) = "HeghmoH Qagh-teywI' neH lo'"
2360    lngarray$ (24) = "HeghmoH Qagh-bertlham teywI' found poStaHvIS looking"
2370    lngarray$ (25) = "teywI':"
2380    lngarray$ (26) = "HeghmoH Qagh-per"
2390    lngarray$ (27) = "tIqqu' "
2400    lngarray$ (28) = "tlhegh mI':"
2410    lngarray$ (29) = "teywI':"
2420    lngarray$ (30) = "HeghmoH Qagh-tlhoy law' per"
2430    lngarray$ (31) = "HeghmoH Qagh-DEFINE"
2440    lngarray$ (32) = "wej tu'"
2450    lngarray$ (33) = "HeghmoH Qagh-tlhoy law' define"
2460    lngarray$ (34) = "HeghmoH Qagh-bertlham teywI' tu' pa' #endif"
2470    lngarray$ (35) = "HeghmoH Qagh-per"
2480    lngarray$ (36) = "'el Increment tlhegh numbers: (Default "
2490 END IF
2500 IF d_lang$ = "W"
2510    lngarray$(1) = "STRUCTURED SUPERBASIC FILTER"
2520    lngarray$(2) = "      Fersiwn 2.7"
2530    lngarray$(3) = " Gan Timothy Swenson"
2540    lngarray$(4) = "Ffeil fewnbwn: ("
2550    lngarray$(5) = "GWALL - Ffeil Mewn Defnydd"
2560    lngarray$(6) = "GWALL - Ffeil Ddim Yn Bod"
2570    lngarray$(7) = "GWALL - Enw Ffeil Anaddas"
2580    lngarray$(8) = "Ffeil allbwn: (Rhagosodiad "
2590    lngarray$(9) = "GWALL - Ffeil Yn Bod Eisoes"
2600    lngarray$(10) = "Iawn Dileu (Y/N)"
2610    lngarray$(11) = "Rhif Llinell Gyntaf: (Rhagosodiad "
2620    lngarray$(12) = "GWALL - Rhaid Mewnbynnu Rhif"
2630    lngarray$(13) = "GWALL - Ail Baramedr Ddim Yn Rif Addas"
2640    lngarray$(14) = "GWALL - Ffeil Allbwn Yn Bod Eisoes"
2650    lngarray$(15) = "GWALL - Enw Ffeil - Ffeil Allbwn"
2660    lngarray$(16) = "ERROR - Ffeil Allbwn Mewn Defnydd"
2670    lngarray$(17) = "Pasiad 1"
2680    lngarray$(18) = "Pasiad 2"
2690    lngarray$(19) = "Rhaglen Ar Ben"
2700    lngarray$(20) = "Pwyswch Unrhyw Fysell"
2710    lngarray$(21) = "GWALL ANGHEUOL - Enw Drwg "
2720    lngarray$(22) = "GWALL ANGHEUOL - File Heb Ei Chanfod "
2730    lngarray$(23) = "GWALL ANGHEUOL - FfeilMewn Defnydd "
2740    lngarray$(24) = "GWALL ANGHEUOL - Diwedd Y Ffeil Tra'n Chwilio Am \"
2750    lngarray$(25) = "FFEIL : "
2760    lngarray$(26) = "GWALL ANGHEUOL - Label"
2770    lngarray$(27) = " Rhy Hir"
2780    lngarray$(28) = "HIF LLINELL: "
2790    lngarray$(29) = " MEWN FFEIL: "
2800    lngarray$(30) = "GWALL ANGHEUOL - Gormod O Labeli"
2810    lngarray$(31) = "GWALL ANGHEUOL - DEFINE "
2820    lngarray$(32) = " Heb Ei Ganfod"
2830    lngarray$(33) = "GWALL ANGHEUOL - Gormod O DEFINE'au"
2840    lngarray$(34) = "GWALL ANGHEUOL - Diwedd Ffeil Cyn #ENDIF"
2850    lngarray$(35) = "GWALL ANGHEUOL - Label "
2860    lngarray$(36) = "Cynyddiad Rhifau Llinellau: (Rhagddodiad "
2870 END IF
2880 OPEN #3,"con_300x160a75x10_32"
2890 BORDER #3,2,4
2900 PAPER #3,0 : INK #3,7 :  CLS #3
2910 PRINT #3,"     ";lngarray$(1)
2920 INK #3,2
2930 PRINT #3,"            ";lngarray$(2)
2940 PRINT #3,"         ";lngarray$(3)
2950 PRINT #3
2960 INK #3,4
2970 IF d_work2$ = "" THEN d_work2$ = d_working$
2980 command$ = OPTION_CMD$
2990 count = 0
3000 y = LEN(command$)
3010 IF y > 0 THEN
3020   FOR x = 1 TO y
3030     IF command$(x) = " " THEN count=count+1
3040   NEXT x
3050   IF count = y THEN command$=""
3060 END IF
3070 IF command$ = "" THEN
3080   REPEAT input_loop
3090     PRINT #3,lngarray$(4);d_in$;") "
3100     INK #3,7
3110     INPUT #3,file$
3120     IF file$ = "" THEN abort_out
3130     INK #3,2
3140     in_file$ = d_working$&file$&d_in$
3150     temp = FTEST(in_file$)
3160     IF temp = 0 THEN EXIT input_loop
3170     IF temp = -9 THEN
3180       BEEP 1000,10
3190         PRINT #3,"      ";lngarray$(5)
3200     END IF
3210     IF temp = -7 THEN
3220       BEEP 1000,10
3230       PRINT #3,"      ";lngarray$(6)
3240     END IF
3250     IF temp = -11 THEN
3260       BEEP 1000,10
3270       PRINT #3,"      ";lngarray$(7)
3280     END IF
3290   END REPEAT input_loop
3300   REPEAT output_loop
3310     INK #3,4
3320     PRINT #3,lngarray$(8);d_work2$&file$&d_out$;") "
3330     INK #3,7
3340     INPUT #3,out_file$
3350     IF out_file$ = "" THEN
3360       out_file$ = d_work2$&file$&d_out$
3370     ELSE
3380       out_file$ = d_work2$&out_file$&d_out$
3390     END IF
3400       INK #3,2
3410     temp = FTEST(out_file$)
3420     IF temp = -7 THEN EXIT output_loop
3430     IF temp = -9 THEN
3440       BEEP 1000,10
3450       PRINT #3,"       ";lngarray$(5)
3460     END IF
3470     IF temp = -11 THEN
3480       BEEP 1000,10
3490       PRINT #3,"       ";lngarray$(7)
3500     END IF
3510     IF temp = 0 THEN
3520       BEEP 1000,10
3530       PRINT #3,"       ";lngarray$(9)
3540       PRINT #3,"        ";lngarray$(10)
3550       temp$ = INKEY$(#3,-1)
3560       IF temp$ = "y" OR temp$="Y" or temp$="S" or temp$="s" THEN
3570         DELETE out_file$
3580         EXIT output_loop
3590         ELSE
3600           abort_out
3610       END IF
3620     END IF
3630   END REPEAT output_loop
3640   REPEAT start_loop
3650     IF t_start$ <> "" THEN
3660        line_num_d = t_start$
3670        EXIT start_loop
3680     END IF
3690     INK #3,4
3700     PRINT #3,lngarray$(11);d_start;")"
3710     INK #3,7
3720     INPUT #3,line_num$
3730     INK #3,2
3740     IF line_num$ = "" THEN
3750       line_num_d = d_start
3760       EXIT start_loop
3770     ELSE
3780       IF isnum(line_num$) THEN
3790         line_num_d = line_num$
3800         EXIT start_loop
3810       END IF
3820       BEEP 1000,10
3830       PRINT #3,lngarray$(12)
3840     END IF
3850     INK #3,4
3860   END REPEAT start_loop
3870   REPEAT delta_loop
3880     IF t_delta$ <> "" THEN
3890        line_delta = t_delta$
3900        EXIT delta_loop
3910     END IF
3920     INK #3,4
3930     PRINT #3,lngarray$(36);d_delta;")"
3940     INK #3,7
3950     INPUT #3,line_delta$
3960     INK #3,2
3970     IF line_delta$ = "" THEN
3980       line_delta = d_delta
3990       EXIT delta_loop
4000     ELSE
4010       IF isnum(line_delta$) THEN
4020         line_delta = line_delta$
4030         EXIT delta_loop
4040       END IF
4050       BEEP 1000,10
4060       PRINT #3,lngarray$(12)
4070     END IF
4080     INK #3,4
4090   END REPEAT delta_loop
4100 ELSE
4110   REPEAT loop_lb
4120     IF command$(1) = " " THEN
4130       command$=command$(2 TO )
4140     ELSE
4150       EXIT loop_lb
4160     END IF
4170   END REPEAT loop_lb
4180   REPEAT loop_tb
4190     x = LEN(command$)
4200     IF command$(x)=" " THEN
4210       command$=command$(1 TO x-1)
4220     ELSE
4230       EXIT loop_tb
4240     END IF
4250   END REPEAT loop_tb
4260   x = " " INSTR command$
4270   IF x THEN
4280     argfile$ = command$(1 TO x-1)
4290     command$ = command$( x+1 TO )
4300     REPEAT loop_lb
4310       IF command$(1) = " " THEN
4320         command$ = command$(2 TO )
4330       ELSE
4340         EXIT loop_lb
4350       END IF
4360     END REPEAT loop_lb
4370     IF isnum(command$) = 0 THEN
4380       INK #3,2
4390       BEEP 1000,10
4400       PRINT #3,"      ";lngarray$(13)
4410       abort_out
4420     END IF
4430     d_start = command$
4440   ELSE
4450     argfile$ = command$
4460   END IF
4470   in_file$ = d_working$&argfile$&d_in$
4480   out_file$ = d_work2$&argfile$&d_out$
4490   temp = FTEST(out_file$)
4500   IF temp = 0 THEN
4510     IF d_over$="Y" or d_over$="y" or d_over$="S" or d_over$="s" THEN
4520       DELETE out_file$
4530     ELSE
4540       BEEP 1000,10
4550       INK #3,2
4560       PRINT #3,"       ";lngarray$(14)
4570       abort_out
4580     END IF
4590   END IF
4600   IF temp = -11 THEN
4610     BEEP 1000,10
4620     INK #3,2
4630     PRINT #3,"       ";lngarray$(15)
4640     abort_out
4650   END IF
4660   IF temp = -9 THEN
4670     BEEP 1000,10
4680     INK #3,2
4690     PRINT #3,"       ";lngarray$(16)
4700     abort_out
4710   END IF
4720   line_delta = d_delta
4730   line_num_d = d_start
4740 END IF
4750 line_num = line_num_d
4760 INK #3,4
4770 PRINT #3,"    ";lngarray$(17)
4780 pass_one in_file$, file_num
4790 line_num = line_num_d
4800 PRINT #3
4810 PRINT #3,"    ";lngarray$(18)
4820 num_count = 0
4830 file_num = 5
4840 OPEN_NEW #4,out_file$
4850 pass_two in_file$, file_num
4860 CLOSE #4
4870 PRINT #3
4880 PRINT #3,"           ";lngarray$(19)
4890 PRINT #3,""
4900 IF OPTION_CMD$="" THEN
4910   INK #3,7
4920   PRINT #3,"           ";lngarray$(20)
4930   temp$ = INKEY$(#3,-1)
4940 END IF
4950 CLOSE #3
4960 STOP
4970 DEFine PROCedure pass_one (in_file$, file_num)
4980   errorx = FOP_IN(#file_num,in_file$)
4990   INK #3,2
5000   IF errorx = -12 THEN
5010     BEEP 1000,10
5020     PRINT #3,lngarray$(21);in_file$
5030     abort_out
5040   END IF
5050   IF errorx = -7 THEN
5060     BEEP 1000,10
5070     PRINT #3,lngarray$(22);in_file$
5080     abort_out
5090   END IF
5100   IF errorx = -9 THEN
5110     BEEP 1000,10
5120     PRINT #3,lngarray$(23);in_file$
5130     abort_out
5140   END IF
5150   INK #3,4
5160   REPeat pass_1
5170     num_count = num_count + 1
5180     IF (num_count MOD 10) = 0 THEN PRINT #3,CHR$(1);
5190     IF EOF(#file_num) THEN EXIT pass_1
5200     INPUT #file_num,in$
5210     temp=first_char(in$)
5220     IF temp=0 THEN NEXT pass_1
5230     IF in$(temp TO temp+1)=CHR$(35)&CHR$(35) THEN NEXT pass_1
5240     IF in$(temp)="." THEN NEXT pass_1
5250     IF LEN(in$) >= 6 THEN
5260       IF in$(1 TO 6) = "#ENDIF" THEN NEXT pass_1
5270     END IF
5280     REPeat loop
5290       IF in$(LEN(in$))="\" THEN
5300         IF EOF(#file_num) THEN
5310           BEEP 1000,10
5320           INK #3,2
5330           PRINT #3,lngarray$(24)
5340           PRINT #3,lngarray$(25);in_file$
5350           abort_out
5360         END IF
5370         INPUT #file_num,in2$
5380         temp = first_char(in2$)
5390         in$ = in$( TO LEN(in$))&" "&in2$(temp TO)
5400       ELSE
5410         EXIT loop
5420       END IF
5430     END REPeat loop
5440     IF in$(1)=CHR$(64) THEN
5450       IF LEN(in$) > d_length+1 THEN
5460         BEEP 1000,10
5470         INK #3,2
5480         PRINT #3,lngarray$(26);in$;lngarray$(27)
5490         PRINT #3,lngarray$(28);num_count;lngarray$(29);in_file$
5500         abort_out
5510       END IF
5520       IF label_var = d_labels THEN
5530         BEEP 1000,10
5540         INK #3,2
5550         PRINT #3,lngarray$(30)
5560         PRINT #3,lngarray$(28);num_count;lngarray$(29);in_file$
5570         abort_out
5580       END IF
5590       label$(label_var) = in$
5600       label(label_var) = line_num
5610       label_var = label_var + 1
5620     ELSE
5630       IF upper$(in$(1 TO 8))="#INCLUDE" THEN
5640         pass_one d_working$&in$(10 to ), file_num+1
5650       ELSE
5660         IF upper$(in$(1 TO 7))="#DEFINE" THEN
5670           IF LEN(in$(9 TO)) > d_length THEN
5680             BEEP 1000,10
5690             INK #3,2
5700             PRINT #3,lngarray$(31);in$(9 TO);lngarray$(27)
5710             PRINT #3,lngarray$(28);num_count;lngarray$(29);in_file$
5720             abort_out
5730           END IF
5740           IF define_var = d_labels THEN
5750             BEEP 1000,10
5760             INK #3,2
5770             PRINT #3,lngarray$(33)
5780             PRINT #3,lngarray$(28);num_count;lngarray$(29);in_file$
5790             abort_out
5800           END IF
5810           defn$(define_var) = upper$(in$( 9 TO))
5820           define_var = define_var+1
5830         ELSE
5840           IF upper$(in$(1 TO 6))="#IFDEF" THEN
5850             temp = 0
5860             temp$ = upper$(in$(8 TO))
5870             FOR x = 1 TO define_var
5880               IF temp$ = defn$(x) THEN temp = 1
5890             NEXT X
5900             IF temp = 0 THEN
5910               REPEAT loop
5920                 IF EOF(#file_num) THEN
5930                   BEEP 1000,10
5940                   INK #3,2
5950                   PRINT #3,lngarray$(34)
5960                   PRINT #3,lngarray$(25);in_file$
5970                   abort_out
5980                 END IF
5990                 INPUT #file_num,in2$
6000                 IF LEN(in2$) < 6 THEN NEXT loop
6010                 IF upper$(in2$(1 TO 6))="#ENDIF" THEN EXIT loop
6020               END REPeat loop
6030             END IF
6040           ELSE
6050             line_num = line_num + line_delta
6060           END IF
6070         END IF
6080       END IF
6090     END IF
6100   END REPeat pass_1
6110   CLOSE #file_num
6120 END DEFine pass_one
6130 DEFine PROCedure pass_two (in_file$, file_num)
6140   LOCal in3$(100), a$(100)
6150   OPEN_IN #file_num,in_file$
6160   REPeat pass_2
6170     num_count = num_count + 1
6180     IF (num_count MOD 10) = 0 THEN PRINT #3,CHR$(1);
6190     IF EOF(#file_num) THEN EXIT pass_2
6200     INPUT #file_num,in$
6210     temp=first_char(in$)
6220     IF temp=0 THEN NEXT pass_2
6230     IF in$(1)=CHR$(64) THEN NEXT pass_2
6240     IF in$(temp TO temp+1)=CHR$(35)&CHR$(35) THEN NEXT pass_2
6250     IF in$(temp)="." THEN NEXT pass_2
6260     temp2 = CHR$(35)&CHR$(35) INSTR in$
6270     IF temp2 <> 0 THEN in$ = in$( 1 to temp2-1)
6280     IF upper$(in$(1 TO 7))="#DEFINE" THEN NEXT pass_2
6290     IF LEN(in$) >= 6 THEN
6300       IF in$(1 TO 6) = "#ENDIF" THEN NEXT pass_2
6310     END IF
6320     REPeat loop
6330       IF in$(LEN(in$))="\" THEN
6340         INPUT #file_num,in2$
6350         temp = first_char(in2$)
6360         in$ = in$(1 TO (LEN(in$)-1))&in2$(temp TO)
6370       ELSE
6380         EXIT loop
6390       END IF
6400     END REPeat loop
6410     IF in$(temp TO temp+1)="**" THEN
6420       IF temp = 1 THEN
6430         in3$=""
6440       ELSE
6450         in3$=in$(1 to temp-1)
6460       END IF
6470       PRINT #4,line_num;" REMark ";in3$;in$(temp+2 TO )
6480       line_num = line_num + line_delta
6490     ELSE
6500       temp = CHR$(64) INSTR in$
6510       IF temp<>0 THEN
6520         a$ = in$(temp TO )
6530         temp2 = 0
6540         REPEAT loop2
6550           temp2 = temp2 + 1
6560           IF temp2 > d_labels THEN
6570             BEEP 1000,10
6580             INK #3,2
6590             PRINT #3,lngarray$(35);a$;lngarray$(32)
6600             PRINT #3,lngarray$(28);num_count;lngarray$(29);in_file$
6610             abort_out
6620           END IF
6630           IF label$(temp2) == a$ THEN EXIT loop2
6640         END REPEAT loop2
6650         PRINT #4,line_num;" ";in$(1 TO temp-1);label(temp2)
6660         line_num = line_num + line_delta
6670       ELSE
6680         IF upper$(in$(1 to 8))="#INCLUDE" THEN
6690           pass_two d_working$&in$(10 to), file_num+1
6700         ELSE
6710           IF upper$(in$(1 TO 6))="#IFDEF" THEN
6720             temp = 0
6730             temp$ = upper$(in$(8 TO))
6740             FOR x = 1 TO define_var
6750               IF temp$ = defn$((x),1 TO LEN(temp$)) THEN temp = x
6760             NEXT X
6770             IF temp = 0 THEN
6780               REPEAT loop
6790                 INPUT #file_num,in2$
6800                 IF LEN(in2$) < 6 THEN NEXT loop
6810                 IF upper$(in2$(1 TO 6))="#ENDIF" THEN EXIT loop
6820               END REPeat loop
6830             END IF
6840           ELSE
6850             PRINT #4,line_num;" ";in$
6860             line_num = line_num + line_delta
6870           END IF
6880         END IF
6890       END IF
6900     END IF
6910   END REPeat pass_2
6920   CLOSE #file_num
6930 END DEFine pass_two
6940 DEFine FuNction first_char (a$)
6950    LOCal count
6960    count=0
6970    count=count+1
6980    IF count > LEN(a$) THEN RETurn 0
6990    IF a$(count)=" " THEN GO TO 6970
7000    RETurn count
7010 END DEFine first_char
7020 DEF FuNction upper$(up$)
7030     LOCal x, temp
7040     FOR x = 1 TO LEN(up$)
7050        temp = CODE(up$(x))
7060        IF temp > 96 AND temp < 123 THEN up$(x)=CHR$(temp-32)
7070     NEXT x
7080     RETURN up$
7090 END DEFine
7100 DEFine FuNCtion isnum (var$)
7110    LOCal x,y
7120    FOR x = 1 TO LEN(var$)
7130       y = CODE(var$(x))
7140       IF y < 48 OR y > 57 THEN RETURN 0
7150    NEXT x
7160    RETURN 1
7170 END DEFine isnum
7180 DEF PROCedure abort_out
7190 CLOSE #4
7200 IF OPTION_CMD$<>"" AND out_file$<>"" THEN DELETE out_file$
7210 IF file_num = 5 THEN
7220     CLOSE #5
7230 ELSE
7240     FOR x = 5 TO file_num
7250        CLOSE #x
7260     NEXT X
7270 END IF
7280 IF OPTION_CMD$<>"" THEN
7290     PRINT #3,""
7300     INK #3,7
7310     PRINT #3,"         ";lngarray$(20)
7320     temp$ = INKEY$(#3,-1)
7330 END IF
7340     CLOSE #3
7350     STOP
7360 END DEFine abort_out
