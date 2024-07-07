100 TURBO_taskn "ssb 2.7.2b"
110 TURBO_objfil "ram1_ssb272b_exe"
120 TURBO_windo 0
130 TURBO_repfil "ram1_ssb272b_err"
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
330 d_ignore$ = "Y"
340 DIM out_file$(100), command$(100), file$(100), in_file$(100), temp$(100)
350 DIM line_num$(10), line_delta$(10), argfile$(100), in$(1000), in2$(1000)
360 DIM label$(d_labels,d_length)
370 DIM label(d_labels)
380 DIM defn$(d_labels,d_length)
390 label_var = 1
400 define_var = 1
410 num_count = 0
420 file_num = 5
430 out_file$ = ""
440 t_in$ = GETENV$("SSBINPUT")
450 IF t_in$ <> "" THEN d_in$ = t_in$
460 t_out$ = GETENV$("SSBOUTPUT")
470 IF t_out$ <> "" THEN d_out$ = t_out$
480 t_start$ = GETENV$("SSBSTART")
490 IF t_start$ <> "" THEN d_start = t_start$
500 t_delta$ = GETENV$("SSBINC")
510 IF t_delta$ <> "" THEN d_delta = t_delta$
520 t_working$ = GETENV$("SSBWORK")
530 IF t_working$ <> "" THEN d_working$ = t_working$
540 t_work2$ = GETENV$("SSBWORK2")
550 IF t_work2$ <> "" THEN d_work2$ = t_work2$
560 t_over$ = GETENV$("SSBOVER")
570 IF t_over$ <> "" THEN d_over$ = t_over$
580 t_lang$ = GETENV$("SSBLANG")
590 IF t_lang$ <> "" THEN d_lang$ = t_lang$
600 t_ignore$ = GETENV$("IGNORE_BLANKS")
610 IF t_ignore$ <> "" THEN d_ignore$ = t_ignore$
620 DIM lngarray$(36,42)
630 IF d_lang$ = "E"
640    lngarray$(1) = "STRUCTURED SUPERBASIC FILTER"
650    lngarray$(2) = "      Version 2.7.2b"
660    lngarray$(3) = " By Timothy Swenson"
670    lngarray$(4) = "Enter Input File: ("
680    lngarray$(5) = "ERROR - File In Use"
690    lngarray$(6) = "ERROR - File Does Not Exist"
700    lngarray$(7) = "ERROR - Bad File Name"
710    lngarray$(8) = "Enter Output File: (Default "
720    lngarray$(9) = "ERROR - File Exists"
730    lngarray$(10) = "OK to Delete (Y/N)"
740    lngarray$(11) = "Enter Starting Line Number: (Default "
750    lngarray$(12) = "ERROR - Must Enter A Number"
760    lngarray$(13) = "ERROR - 2nd Arg is Not A Valid Number"
770    lngarray$(14) = "ERROR - Output File Exists"
780    lngarray$(15) = "ERROR - Bad File Name - Output File"
790    lngarray$(16) = "ERROR - Output File In Use"
800    lngarray$(17) = "Pass 1"
810    lngarray$(18) = "Pass 2"
820    lngarray$(19) = "Program Done"
830    lngarray$(20) = "Hit Any Key"
840    lngarray$(21) = "FATAL ERROR - Bad Name "
850    lngarray$(22) = "FATAL ERROR - File Not Found "
860    lngarray$(23) = "FATAL ERROR - File In Use "
870    lngarray$(24) = "FATAL ERROR - End of File Found While Looking for \"
880    lngarray$(25) = "FILE : "
890    lngarray$(26) = "FATAL ERROR - Label"
900    lngarray$(27) = " Too Long"
910    lngarray$(28) = "LINE NUMBER: "
920    lngarray$(29) = " IN FILE: "
930    lngarray$(30) = "FATAL ERROR - Too Many Labels"
940    lngarray$(31) = "FATAL ERROR - DEFINE "
950    lngarray$(32) = " Not Found"
960    lngarray$(33) = "FATAL ERROR - Too Many DEFINE's"
970    lngarray$(34) = "FATAL ERROR - End of File Found Before #ENDIF"
980    lngarray$(35) = "FATAL ERROR - Label "
990    lngarray$(36) = "Enter Increment for Line Numbers: (Default "
1000 END IF
1010 IF d_lang$="I"
1020    lngarray$(1) = "STRUCTURED SUPERBASIC FILTER"
1030    lngarray$(2) = "       Versione 2.7.2b"
1040    lngarray$(3) = " di Timothy Swenson"
1050    lngarray$(4) = "File di input: ("
1060    lngarray$(5) = "ERRORE - Il file  in uso"
1070    lngarray$(6) = "ERRORE - Il file non esiste"
1080    lngarray$(7) = "ERRORE - Nome di file errato"
1090    lngarray$(8) = "File di output: (Default "
1100    lngarray$(9) = "ERRORE - File gia' esistente"
1110    lngarray$(10) = "Cancellarlo (S/N)"
1120    lngarray$(11) = "Inserisci il numero iniziale della numerazione: (Default "
1130    lngarray$(12) = "ERRORE - Devi inserire un numero"
1140    lngarray$(13) = "ERRORE - Il Secondo Argomento non e' Un numero valido"
1150    lngarray$(14) = "ERRORE - File di output gi esistente"
1160    lngarray$(15) = "ERRORE - Nome Errato - Output File"
1170    lngarray$(16) = "ERRORE - File di output In Uso"
1180    lngarray$(17) = "Fase 1"
1190    lngarray$(18) = "Fase 2"
1200    lngarray$(19) = "Creato Programma"
1210    lngarray$(20) = "Premi Un Tasto"
1220    lngarray$(21) = "ERRORE BLOCCANTE - Nome errato "
1230    lngarray$(22) = "ERRORE BLOCCANTE - File on trovato "
1240    lngarray$(23) = "ERRORE BLOCCANTE - File in uso "
1250    lngarray$(24) = "ERRORE BLOCCANTE - Fine del file trovata cercando \"
1260    lngarray$(25) = "FILE : "
1270    lngarray$(26) = "ERRORE BLOCCANTE - Etichetta"
1280    lngarray$(27) = " Troppo Lunga"
1290    lngarray$(28) = "NUMERO INIZIALE: "
1300    lngarray$(29) = " IN FILE: "
1310    lngarray$(30) = "ERRORE BLOCCANTE - Troppe Etichette"
1320    lngarray$(31) = "ERRORE BLOCCANTE - DEFINE "
1330    lngarray$(32) = " Non Trovata"
1340    lngarray$(33) = "ERRORE BLOCCANTE - Troppe DEFINE's"
1350    lngarray$(34) = "ERRORE BLOCCANTE - Fine del file trovata prima di  #ENDIF"
1360    lngarray$(35) = "ERRORE BLOCCANTE - Etichette "
1370    lngarray$(36) = "Incremento del numero di linea: (Default "
1380 END IF
1390 IF d_lang$="F"
1400    lngarray$(1) = "STRUCTURED SUPERBASIC FILTER"
1410    lngarray$(2) = "       Version 2.7.2b"
1420    lngarray$(3) = " par Timothy Swenson"
1430    lngarray$(4) = "Fichied d'entrƒe: ("
1440    lngarray$(5) = "ERREUR - Le fichier est en cours d'utilisation"
1450    lngarray$(6) = "ERREUR - Le fichier ne existe pas"
1460    lngarray$(7) = "ERREUR - nom de fichier incorrect"
1470    lngarray$(8) = "Fichier Sortie: (Default "
1480    lngarray$(9) = "ERREUR - Fichier dej existantes"
1490    lngarray$(10) = "Supprimer (O/N)"
1500    lngarray$(11) = "Entrez le numƒro de dƒpart de la numƒrotation: (Default "
1510    lngarray$(12) = "ERREUR - Vous devez entrer un nombre "
1520    lngarray$(13) = "ERREUR - Le deuxime argument n'est pas un nombre valide"
1530    lngarray$(14) = "ERREUR - Fichier de sortie existe dƒj"
1540    lngarray$(15) = "ERREUR - nom incorrect - fichier de sortie"
1550    lngarray$(16) = "ERREUR - fichier de sortie en cours d'utilisation"
1560    lngarray$(17) = "Phase 1"
1570    lngarray$(18) = "Phase 2"
1580    lngarray$(19) = "Crƒe Programme"
1590    lngarray$(20) = "Appuyez sur une touche"
1600    lngarray$(21) = "ERREUR BLOCAGE - Nom incorrect "
1610    lngarray$(22) = "ERREUR BLOCAGE - Fichier ne pas trouvƒe "
1620    lngarray$(23) = "ERREUR BLOCAGE - Fichier en cors d'utilisation"
1630    lngarray$(24) = "ERREUR BLOCAGE - Fin de fichier trouvƒ essayer \"
1640    lngarray$(25) = "FICHIER : "
1650    lngarray$(26) = "ERREUR BLOCAGE- ƒtiquette"
1660    lngarray$(27) = " Trop LONG"
1670    lngarray$(28) = "PREMIERE NUMERO: "
1680    lngarray$(29) = " EN FICHIER: "
1690    lngarray$(30) = "ERREUR BLOCAGE - Trop d'etiquettes"
1700    lngarray$(31) = "ERREUR BLOCAGE - DEFINE "
1710    lngarray$(32) = " Non Trovata"
1720    lngarray$(33) = "ERREUR BLOCAGE - Trop DEFINE's"
1730    lngarray$(34) = "ERREUR BLOCAGE - Fin de fichier trouvƒ avant #ENDIF"
1740    lngarray$(35) = "ERREUR BLOCAGE - Etiquettes "
1750    lngarray$(36) = "Augmentation du nombre de ligne: (Default "
1760 END IF
1770 IF d_lang$ = "D"
1780    lngarray$(1) = "STRUCTURED SUPERBASIC FILTER"
1790    lngarray$(2) = "      Version 2.7.2b"
1800    lngarray$(3) = " By Timothy Swenson"
1810    lngarray$(4) = "Eingansdatei Angeben: ("
1820    lngarray$(5) = "Fehler - Datei ist Offen"
1830    lngarray$(6) = "Fehler - Datei Existiert Nicht"
1840    lngarray$(7) = "Fehler - Falscher Dateien Name"
1850    lngarray$(8) = "Ausgansdatei Angeben: (Vorgabewert "
1860    lngarray$(9) = "Fehler - Datei Existiert"
1870    lngarray$(10) = "OK zu Löschen (Y/N)"
1880    lngarray$(11) = "Anfänginge Linien Number Eingeben: (Vorgabewert "
1890    lngarray$(12) = "Fehler - Eine Nummer muss eihgegeben werden"
1900    lngarray$(13) = "Fehler - Das Zweite Argument ist eine Invalide Nummer"
1910    lngarray$(14) = "Fehler - Ausgansdatei Existiert"
1920    lngarray$(15) = "Fehler - Falscher Dateien Name - Ausgansdatei"
1930    lngarray$(16) = "Fehler - Ausgangsdatei ist Offen"
1940    lngarray$(17) = "Pass 1"
1950    lngarray$(18) = "Pass 2"
1960    lngarray$(19) = "Program Fertig"
1970    lngarray$(20) = "Irgend eine Taste Drücken"
1980    lngarray$(21) = "Fataler Fehler - Falscher Name"
1990    lngarray$(22) = "Fataler Fehler - Datei Nicht Gefunden"
2000    lngarray$(23) = "Fataler Fehler - Datei ist Offen"
2010    lngarray$(24) = "Fataler Fehler - Ende der Datei Gefunden Beim Gesuch Nach \"
2020    lngarray$(25) = "Datei : "
2030    lngarray$(26) = "Fataler Fehler - Kennsatz"
2040    lngarray$(27) = " Zu Lange"
2050    lngarray$(28) = "Linien Nummer: "
2060    lngarray$(29) = " In Datei: "
2070    lngarray$(30) = "Fataler Fehler - Zu Viele Kennsätze"
2080    lngarray$(31) = "Fataler Fehler - Definieren "
2090    lngarray$(32) = " Nicht Gefunden"
2100    lngarray$(33) = "Fataler Fehler - Zu Viele Definierungen "
2110    lngarray$(34) = "Fataler Fehler - Ende der Datei Gefunden Bevor #ENDIF"
2120    lngarray$(35) = "Fataler Fehler - Kennsatz"
2130    lngarray$(36) = "Erhöhung der Linien Nummern Eintragen: (Vorgabewert "
2140 END IF
2150 IF d_lang$ = "K"
2160    lngarray$ (1) = "tlham SUPERBASIC FILTER"
2170    lngarray$ (2) = "2.7.2b Version"
2180    lngarray$ (3) = "pong Timothy Swenson"
2190    lngarray$ (4) = "teywI' input:"
2200    lngarray$ (5) = "Qagh-teywI' neH lo'" 
2210    lngarray$ (6) = "wej nIv'e' Qagh-teywI'" 
2220    lngarray$ (7) = "Qagh-vo' ruv nge' teywI' pong"
2230    lngarray$ (8) = "teywI' output: (Default"
2240    lngarray$ (9) = "chonayta' nIv'e' Qagh-teywI'"
2250    lngarray$ (10) = "qIl (s ghap n)"
2260    lngarray$ (11) = "So'meH mI' pImchugh chuqmey poHmey 'el: (Default"
2270    lngarray$ (12) = "Qagh-mI' ghob'e' 'el SoH"
2280    lngarray$ (13) = "Qagh-2nd arg wej mach Valid mI'"
2290    lngarray$ (14) = "Qagh-Output teywI' nIv'e'"
2300    lngarray$ (15) = "Qagh-qab teywI' pong-teywI' Output"
2310    lngarray$ (16) = "Qagh-Output teywI' neH lo'" 
2320    lngarray$ (17) = "1" 
2330    lngarray$ (18) = "2" 
2340    lngarray$ (19) = "HIja'" 
2350    lngarray$ (20) = "qIp vay' ngaQHa'moHwI'mey" 
2360    lngarray$ (21) = "HeghmoH Qagh-qab pong" 
2370    lngarray$ (22) = "HeghmoH Qagh-teywI' wej tu'"
2380    lngarray$ (23) = "HeghmoH Qagh-teywI' neH lo'"
2390    lngarray$ (24) = "HeghmoH Qagh-bertlham teywI' found poStaHvIS looking"
2400    lngarray$ (25) = "teywI':"
2410    lngarray$ (26) = "HeghmoH Qagh-per"
2420    lngarray$ (27) = "tIqqu' "
2430    lngarray$ (28) = "tlhegh mI':"
2440    lngarray$ (29) = "teywI':"
2450    lngarray$ (30) = "HeghmoH Qagh-tlhoy law' per"
2460    lngarray$ (31) = "HeghmoH Qagh-DEFINE"
2470    lngarray$ (32) = "wej tu'"
2480    lngarray$ (33) = "HeghmoH Qagh-tlhoy law' define"
2490    lngarray$ (34) = "HeghmoH Qagh-bertlham teywI' tu' pa' #endif"
2500    lngarray$ (35) = "HeghmoH Qagh-per"
2510    lngarray$ (36) = "'el Increment tlhegh numbers: (Default "
2520 END IF
2530 IF d_lang$ = "W"
2540    lngarray$(1) = "STRUCTURED SUPERBASIC FILTER"
2550    lngarray$(2) = "      Fersiwn 2.7.2b"
2560    lngarray$(3) = " Gan Timothy Swenson"
2570    lngarray$(4) = "Ffeil fewnbwn: ("
2580    lngarray$(5) = "GWALL - Ffeil Mewn Defnydd"
2590    lngarray$(6) = "GWALL - Ffeil Ddim Yn Bod"
2600    lngarray$(7) = "GWALL - Enw Ffeil Anaddas"
2610    lngarray$(8) = "Ffeil allbwn: (Rhagosodiad "
2620    lngarray$(9) = "GWALL - Ffeil Yn Bod Eisoes"
2630    lngarray$(10) = "Iawn Dileu (Y/N)"
2640    lngarray$(11) = "Rhif Llinell Gyntaf: (Rhagosodiad "
2650    lngarray$(12) = "GWALL - Rhaid Mewnbynnu Rhif"
2660    lngarray$(13) = "GWALL - Ail Baramedr Ddim Yn Rif Addas"
2670    lngarray$(14) = "GWALL - Ffeil Allbwn Yn Bod Eisoes"
2680    lngarray$(15) = "GWALL - Enw Ffeil - Ffeil Allbwn"
2690    lngarray$(16) = "ERROR - Ffeil Allbwn Mewn Defnydd"
2700    lngarray$(17) = "Pasiad 1"
2710    lngarray$(18) = "Pasiad 2"
2720    lngarray$(19) = "Rhaglen Ar Ben"
2730    lngarray$(20) = "Pwyswch Unrhyw Fysell"
2740    lngarray$(21) = "GWALL ANGHEUOL - Enw Drwg "
2750    lngarray$(22) = "GWALL ANGHEUOL - File Heb Ei Chanfod "
2760    lngarray$(23) = "GWALL ANGHEUOL - FfeilMewn Defnydd "
2770    lngarray$(24) = "GWALL ANGHEUOL - Diwedd Y Ffeil Tra'n Chwilio Am \"
2780    lngarray$(25) = "FFEIL : "
2790    lngarray$(26) = "GWALL ANGHEUOL - Label"
2800    lngarray$(27) = " Rhy Hir"
2810    lngarray$(28) = "HIF LLINELL: "
2820    lngarray$(29) = " MEWN FFEIL: "
2830    lngarray$(30) = "GWALL ANGHEUOL - Gormod O Labeli"
2840    lngarray$(31) = "GWALL ANGHEUOL - DEFINE "
2850    lngarray$(32) = " Heb Ei Ganfod"
2860    lngarray$(33) = "GWALL ANGHEUOL - Gormod O DEFINE'au"
2870    lngarray$(34) = "GWALL ANGHEUOL - Diwedd Ffeil Cyn #ENDIF"
2880    lngarray$(35) = "GWALL ANGHEUOL - Label "
2890    lngarray$(36) = "Cynyddiad Rhifau Llinellau: (Rhagddodiad "
2900 END IF
2910 OPEN #3,"con_300x160a75x10_32"
2920 BORDER #3,2,4
2930 PAPER #3,0 : INK #3,7 :  CLS #3
2940 PRINT #3,"     ";lngarray$(1)
2950 INK #3,2
2960 PRINT #3,"            ";lngarray$(2)
2970 PRINT #3,"         ";lngarray$(3)
2980 PRINT #3
2990 INK #3,4
3000 IF d_work2$ = "" THEN d_work2$ = d_working$
3010 command$ = OPTION_CMD$
3020 count = 0
3030 y = LEN(command$)
3040 IF y > 0 THEN
3050   FOR x = 1 TO y
3060     IF command$(x) = " " THEN count=count+1
3070   NEXT x
3080   IF count = y THEN command$=""
3090 END IF
3100 IF command$ = "" THEN
3110   REPEAT input_loop
3120     PRINT #3,lngarray$(4);d_in$;") "
3130     INK #3,7
3140     INPUT #3,file$
3150     IF file$ = "" THEN abort_out
3160     INK #3,2
3170     in_file$ = d_working$&file$&d_in$
3180     temp = FTEST(in_file$)
3190     IF temp = 0 THEN EXIT input_loop
3200     IF temp = -9 THEN
3210       BEEP 1000,10
3220         PRINT #3,"      ";lngarray$(5)
3230     END IF
3240     IF temp = -7 THEN
3250       BEEP 1000,10
3260       PRINT #3,"      ";lngarray$(6)
3270     END IF
3280     IF temp = -11 THEN
3290       BEEP 1000,10
3300       PRINT #3,"      ";lngarray$(7)
3310     END IF
3320   END REPEAT input_loop
3330   REPEAT output_loop
3340     INK #3,4
3350     PRINT #3,lngarray$(8);d_work2$&file$&d_out$;") "
3360     INK #3,7
3370     INPUT #3,out_file$
3380     IF out_file$ = "" THEN
3390       out_file$ = d_work2$&file$&d_out$
3400     ELSE
3410       out_file$ = d_work2$&out_file$&d_out$
3420     END IF
3430       INK #3,2
3440     temp = FTEST(out_file$)
3450     IF temp = -7 THEN EXIT output_loop
3460     IF temp = -9 THEN
3470       BEEP 1000,10
3480       PRINT #3,"       ";lngarray$(5)
3490     END IF
3500     IF temp = -11 THEN
3510       BEEP 1000,10
3520       PRINT #3,"       ";lngarray$(7)
3530     END IF
3540     IF temp = 0 THEN
3550       BEEP 1000,10
3560       PRINT #3,"       ";lngarray$(9)
3570       PRINT #3,"        ";lngarray$(10)
3580       temp$ = INKEY$(#3,-1)
3590       IF temp$ = "y" OR temp$="Y" or temp$="S" or temp$="s" THEN
3600         DELETE out_file$
3610         EXIT output_loop
3620         ELSE
3630           abort_out
3640       END IF
3650     END IF
3660   END REPEAT output_loop
3670   REPEAT start_loop
3680     IF t_start$ <> "" THEN
3690        line_num_d = t_start$
3700        EXIT start_loop
3710     END IF
3720     INK #3,4
3730     PRINT #3,lngarray$(11);d_start;")"
3740     INK #3,7
3750     INPUT #3,line_num$
3760     INK #3,2
3770     IF line_num$ = "" THEN
3780       line_num_d = d_start
3790       EXIT start_loop
3800     ELSE
3810       IF isnum(line_num$) THEN
3820         line_num_d = line_num$
3830         EXIT start_loop
3840       END IF
3850       BEEP 1000,10
3860       PRINT #3,lngarray$(12)
3870     END IF
3880     INK #3,4
3890   END REPEAT start_loop
3900   REPEAT delta_loop
3910     IF t_delta$ <> "" THEN
3920        line_delta = t_delta$
3930        EXIT delta_loop
3940     END IF
3950     INK #3,4
3960     PRINT #3,lngarray$(36);d_delta;")"
3970     INK #3,7
3980     INPUT #3,line_delta$
3990     INK #3,2
4000     IF line_delta$ = "" THEN
4010       line_delta = d_delta
4020       EXIT delta_loop
4030     ELSE
4040       IF isnum(line_delta$) THEN
4050         line_delta = line_delta$
4060         EXIT delta_loop
4070       END IF
4080       BEEP 1000,10
4090       PRINT #3,lngarray$(12)
4100     END IF
4110     INK #3,4
4120   END REPEAT delta_loop
4130 ELSE
4140   REPEAT loop_lb
4150     IF command$(1) = " " THEN
4160       command$=command$(2 TO )
4170     ELSE
4180       EXIT loop_lb
4190     END IF
4200   END REPEAT loop_lb
4210   REPEAT loop_tb
4220     x = LEN(command$)
4230     IF command$(x)=" " THEN
4240       command$=command$(1 TO x-1)
4250     ELSE
4260       EXIT loop_tb
4270     END IF
4280   END REPEAT loop_tb
4290   x = " " INSTR command$
4300   IF x THEN
4310     argfile$ = command$(1 TO x-1)
4320     command$ = command$( x+1 TO )
4330     REPEAT loop_lb
4340       IF command$(1) = " " THEN
4350         command$ = command$(2 TO )
4360       ELSE
4370         EXIT loop_lb
4380       END IF
4390     END REPEAT loop_lb
4400     IF isnum(command$) = 0 THEN
4410       INK #3,2
4420       BEEP 1000,10
4430       PRINT #3,"      ";lngarray$(13)
4440       abort_out
4450     END IF
4460     d_start = command$
4470   ELSE
4480     argfile$ = command$
4490   END IF
4500   in_file$ = d_working$&argfile$&d_in$
4510   out_file$ = d_work2$&argfile$&d_out$
4520   temp = FTEST(out_file$)
4530   IF temp = 0 THEN
4540     IF d_over$="Y" or d_over$="y" or d_over$="S" or d_over$="s" THEN
4550       DELETE out_file$
4560     ELSE
4570       BEEP 1000,10
4580       INK #3,2
4590       PRINT #3,"       ";lngarray$(14)
4600       abort_out
4610     END IF
4620   END IF
4630   IF temp = -11 THEN
4640     BEEP 1000,10
4650     INK #3,2
4660     PRINT #3,"       ";lngarray$(15)
4670     abort_out
4680   END IF
4690   IF temp = -9 THEN
4700     BEEP 1000,10
4710     INK #3,2
4720     PRINT #3,"       ";lngarray$(16)
4730     abort_out
4740   END IF
4750   line_delta = d_delta
4760   line_num_d = d_start
4770 END IF
4780 line_num = line_num_d
4790 INK #3,4
4800 PRINT #3,"    ";lngarray$(17)
4810 pass_one in_file$, file_num
4820 line_num = line_num_d
4830 PRINT #3
4840 PRINT #3,"    ";lngarray$(18)
4850 num_count = 0
4860 file_num = 5
4870 OPEN_NEW #4,out_file$
4880 pass_two in_file$, file_num
4890 CLOSE #4
4900 PRINT #3
4910 PRINT #3,"           ";lngarray$(19)
4920 PRINT #3,""
4930 IF OPTION_CMD$="" THEN
4940   INK #3,7
4950   PRINT #3,"           ";lngarray$(20)
4960   temp$ = INKEY$(#3,-1)
4970 END IF
4980 CLOSE #3
4990 STOP
5000 DEFine PROCedure pass_one (in_file$, file_num)
5010   errorx = FOP_IN(#file_num,in_file$)
5020   INK #3,2
5030   IF errorx = -12 THEN
5040     BEEP 1000,10
5050     PRINT #3,lngarray$(21);in_file$
5060     abort_out
5070   END IF
5080   IF errorx = -7 THEN
5090     BEEP 1000,10
5100     PRINT #3,lngarray$(22);in_file$
5110     abort_out
5120   END IF
5130   IF errorx = -9 THEN
5140     BEEP 1000,10
5150     PRINT #3,lngarray$(23);in_file$
5160     abort_out
5170   END IF
5180   INK #3,4
5190   REPeat pass_1
5200     num_count = num_count + 1
5210     IF (num_count MOD 10) = 0 THEN PRINT #3,CHR$(1);
5220     IF EOF(#file_num) THEN EXIT pass_1
5230     INPUT #file_num,in$
5240     temp=first_char(in$)
5250     IF temp=0 THEN NEXT pass_1
5260     IF in$(temp TO temp+1)=CHR$(35)&CHR$(35) THEN NEXT pass_1
5270     IF in$(temp)="." THEN NEXT pass_1
5280     IF LEN(in$) >= 6 THEN
5290       IF in$(1 TO 6) = "#ENDIF" THEN NEXT pass_1
5300     END IF
5310     REPeat loop
5320       IF in$(LEN(in$))="\" THEN
5330         IF EOF(#file_num) THEN
5340           BEEP 1000,10
5350           INK #3,2
5360           PRINT #3,lngarray$(24)
5370           PRINT #3,lngarray$(25);in_file$
5380           abort_out
5390         END IF
5400         INPUT #file_num,in2$
5410         temp = first_char(in2$)
5420         in$ = in$( TO LEN(in$))&" "&in2$(temp TO)
5430       ELSE
5440         EXIT loop
5450       END IF
5460     END REPeat loop
5470     IF in$(1)=CHR$(64) THEN
5480       IF LEN(in$) > d_length+1 THEN
5490         BEEP 1000,10
5500         INK #3,2
5510         PRINT #3,lngarray$(26);in$;lngarray$(27)
5520         PRINT #3,lngarray$(28);num_count;lngarray$(29);in_file$
5530         abort_out
5540       END IF
5550       IF label_var = d_labels THEN
5560         BEEP 1000,10
5570         INK #3,2
5580         PRINT #3,lngarray$(30)
5590         PRINT #3,lngarray$(28);num_count;lngarray$(29);in_file$
5600         abort_out
5610       END IF
5620       label$(label_var) = in$
5630       label(label_var) = line_num
5640       label_var = label_var + 1
5650     ELSE
5660       IF upper$(in$(1 TO 8))="#INCLUDE" THEN
5670         pass_one d_working$&in$(10 to ), file_num+1
5680       ELSE
5690         IF upper$(in$(1 TO 7))="#DEFINE" THEN
5700           IF LEN(in$(9 TO)) > d_length THEN
5710             BEEP 1000,10
5720             INK #3,2
5730             PRINT #3,lngarray$(31);in$(9 TO);lngarray$(27)
5740             PRINT #3,lngarray$(28);num_count;lngarray$(29);in_file$
5750             abort_out
5760           END IF
5770           IF define_var = d_labels THEN
5780             BEEP 1000,10
5790             INK #3,2
5800             PRINT #3,lngarray$(33)
5810             PRINT #3,lngarray$(28);num_count;lngarray$(29);in_file$
5820             abort_out
5830           END IF
5840           defn$(define_var) = upper$(in$( 9 TO))
5850           define_var = define_var+1
5860         ELSE
5870           IF upper$(in$(1 TO 6))="#IFDEF" THEN
5880             temp = 0
5890             temp$ = upper$(in$(8 TO))
5900             FOR x = 1 TO define_var
5910               IF temp$ = defn$(x) THEN temp = 1
5920             NEXT X
5930             IF temp = 0 THEN
5940               REPEAT loop
5950                 IF EOF(#file_num) THEN
5960                   BEEP 1000,10
5970                   INK #3,2
5980                   PRINT #3,lngarray$(34)
5990                   PRINT #3,lngarray$(25);in_file$
6000                   abort_out
6010                 END IF
6020                 INPUT #file_num,in2$
6030                 IF LEN(in2$) < 6 THEN NEXT loop
6040                 IF upper$(in2$(1 TO 6))="#ENDIF" THEN EXIT loop
6050               END REPeat loop
6060             END IF
6070           ELSE
6080             line_num = line_num + line_delta
6090           END IF
6100         END IF
6110       END IF
6120     END IF
6130   END REPeat pass_1
6140   CLOSE #file_num
6150 END DEFine pass_one
6160 DEFine PROCedure pass_two (in_file$, file_num)
6170   LOCal in3$(100), a$(100)
6180   OPEN_IN #file_num,in_file$
6190   REPeat pass_2
6200     num_count = num_count + 1
6210     IF (num_count MOD 10) = 0 THEN PRINT #3,CHR$(1);
6220     IF EOF(#file_num) THEN EXIT pass_2
6230     INPUT #file_num,in$
6240     temp=first_char(in$)
6250     IF temp=0 THEN
6260       IF d_ignore$ == "Y" THEN
6270         NEXT pass_2
6280       ELSE
6290         in$ = ":"
6300       END IF
6310     END IF
6320     IF in$(1)=CHR$(64) THEN NEXT pass_2
6330     IF in$(temp TO temp+1)=CHR$(35)&CHR$(35) THEN NEXT pass_2
6340     IF in$(temp)="." THEN NEXT pass_2
6350     temp2 = CHR$(35)&CHR$(35) INSTR in$
6360     IF temp2 <> 0 THEN in$ = in$( 1 to temp2-1)
6370     temp2 = CHR$(42) & CHR$(42) INSTR in$
6380     IF temp2 <> 0 then in$ = in$(1 to temp2 - 1) & "REMark" & in$(temp2 + 2 to)
6390     IF upper$(in$(1 TO 7))="#DEFINE" THEN NEXT pass_2
6400     IF LEN(in$) >= 6 THEN
6410       IF in$(1 TO 6) = "#ENDIF" THEN NEXT pass_2
6420     END IF
6430     REPeat loop
6440       IF in$(LEN(in$))="\" THEN
6450         INPUT #file_num,in2$
6460         temp = first_char(in2$)
6470         in$ = in$(1 TO (LEN(in$)-1))&in2$(temp TO)
6480       ELSE
6490         EXIT loop
6500       END IF
6510     END REPeat loop
6520     IF in$(temp TO temp+1)= CHR$(42) & CHR$(42) THEN
6530       IF temp = 1 THEN
6540         in3$=" "
6550       ELSE
6560         in3$=in$(1 to temp-1)
6570       END IF
6580       PRINT #4,line_num;in3$;"REMark";in$(temp+2 TO )
6590       line_num = line_num + line_delta
6600     ELSE
6610       temp = CHR$(64) INSTR in$
6620       IF temp<>0 THEN
6630         a$ = in$(temp TO )
6640         temp2 = 0
6650         REPEAT loop2
6660           temp2 = temp2 + 1
6670           IF temp2 > d_labels THEN
6680             BEEP 1000,10
6690             INK #3,2
6700             PRINT #3,lngarray$(35);a$;lngarray$(32)
6710             PRINT #3,lngarray$(28);num_count;lngarray$(29);in_file$
6720             abort_out
6730           END IF
6740           IF label$(temp2) == a$ THEN EXIT loop2
6750         END REPEAT loop2
6760         PRINT #4,line_num;" ";in$(1 TO temp-1);label(temp2)
6770         line_num = line_num + line_delta
6780       ELSE
6790         IF upper$(in$(1 to 8))="#INCLUDE" THEN
6800           pass_two d_working$&in$(10 to), file_num+1
6810         ELSE
6820           IF upper$(in$(1 TO 6))="#IFDEF" THEN
6830             temp = 0
6840             temp$ = upper$(in$(8 TO))
6850             FOR x = 1 TO define_var
6860               IF temp$ = defn$((x),1 TO LEN(temp$)) THEN temp = x
6870             NEXT X
6880             IF temp = 0 THEN
6890               REPEAT loop
6900                 INPUT #file_num,in2$
6910                 IF LEN(in2$) < 6 THEN NEXT loop
6920                 IF upper$(in2$(1 TO 6))="#ENDIF" THEN EXIT loop
6930               END REPeat loop
6940             END IF
6950           ELSE
6960             PRINT #4,line_num;" ";in$
6970             line_num = line_num + line_delta
6980           END IF
6990         END IF
7000       END IF
7010     END IF
7020   END REPeat pass_2
7030   CLOSE #file_num
7040 END DEFine pass_two
7050 DEFine FuNction first_char (a$)
7060    LOCal count
7070    count=0
7080    count=count+1
7090    IF count > LEN(a$) THEN RETurn 0
7100    IF a$(count)=" " THEN GO TO 7080
7110    RETurn count
7120 END DEFine first_char
7130 DEF FuNction upper$(up$)
7140     LOCal x, temp
7150     FOR x = 1 TO LEN(up$)
7160        temp = CODE(up$(x))
7170        IF temp > 96 AND temp < 123 THEN up$(x)=CHR$(temp-32)
7180     NEXT x
7190     RETURN up$
7200 END DEFine
7210 DEFine FuNCtion isnum (var$)
7220    LOCal x,y
7230    FOR x = 1 TO LEN(var$)
7240       y = CODE(var$(x))
7250       IF y < 48 OR y > 57 THEN RETURN 0
7260    NEXT x
7270    RETURN 1
7280 END DEFine isnum
7290 DEF PROCedure abort_out
7300 CLOSE #4
7310 IF OPTION_CMD$<>"" AND out_file$<>"" THEN DELETE out_file$
7320 IF file_num = 5 THEN
7330     CLOSE #5
7340 ELSE
7350     FOR x = 5 TO file_num
7360        CLOSE #x
7370     NEXT X
7380 END IF
7390 IF OPTION_CMD$<>"" THEN
7400     PRINT #3,""
7410     INK #3,7
7420     PRINT #3,"         ";lngarray$(20)
7430     temp$ = INKEY$(#3,-1)
7440 END IF
7450     CLOSE #3
7460     STOP
7470 END DEFine abort_out
