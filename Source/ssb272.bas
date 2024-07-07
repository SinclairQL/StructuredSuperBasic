1000 TURBO_taskn "ssb 2.7.2c"
1010 TURBO_objfil "ram1_ssb272c_exe"
1020 TURBO_windo 0
1030 TURBO_repfil "ram1_ssb272c_err"
1040 TURBO_objdat 400
1050 TURBO_buffersz 400
1060 TURBO_optim 0
1070 TURBO_diags 2
1080 TURBO_locstr 1
1090 TURBO_struct 0
1100 IMPLICIT% d_labels, d_length, d_start, d_delta, label_var, define_var
1110 IMPLICIT% num_count, file_num, count, x, y, temp, line_num_d, line_delta
1120 IMPLICIT% line_num
1130 IMPLICIT% lf, ld
1140 d_labels = 30
1150 d_length = 16
1160 d_in$    = "_ssb"
1170 d_out$   = "_bas"
1180 d_start  = 100
1190 d_delta  = 10
1200 d_working$ = ""
1210 d_work2$ = ""
1220 d_over$  = ""
1230 d_lang$  = "E"
1240 d_ignore$ = "Y"
1250 DIM out_file$(100), command$(100), file$(100), in_file$(100), temp$(100)
1260 DIM line_num$(10), line_delta$(10), argfile$(100), in$(1000), in2$(1000)
1270 DIM label$(d_labels,d_length)
1280 DIM label(d_labels)
1290 DIM defn$(d_labels,d_length)
1300 label_var = 1
1310 define_var = 1
1320 num_count = 0
1330 file_num = 5
1340 out_file$ = ""
1350 t_in$ = GETENV$("SSBINPUT")
1360 IF t_in$ <> "" THEN d_in$ = t_in$
1370 t_out$ = GETENV$("SSBOUTPUT")
1380 IF t_out$ <> "" THEN d_out$ = t_out$
1390 t_start$ = GETENV$("SSBSTART")
1400 IF t_start$ <> "" THEN d_start = t_start$
1410 t_delta$ = GETENV$("SSBINC")
1420 IF t_delta$ <> "" THEN d_delta = t_delta$
1430 t_working$ = GETENV$("SSBWORK")
1440 IF t_working$ <> "" THEN d_working$ = t_working$
1450 t_work2$ = GETENV$("SSBWORK2")
1460 IF t_work2$ <> "" THEN d_work2$ = t_work2$
1470 t_over$ = GETENV$("SSBOVER")
1480 IF t_over$ <> "" THEN d_over$ = t_over$
1490 t_lang$ = GETENV$("SSBLANG")
1500 IF t_lang$ <> "" THEN d_lang$ = t_lang$
1510 t_ignore$ = GETENV$("SSBIGNORE_BLANKS")
1520 IF t_ignore$ <> "" THEN d_ignore$ = t_ignore$
1530 DIM lngarray$(36,42)
1540 IF d_lang$ = "E"
1550    lngarray$(1) = "STRUCTURED SUPERBASIC FILTER"
1560    lngarray$(2) = "      Version 2.7.2c"
1570    lngarray$(3) = " By Timothy Swenson"
1580    lngarray$(4) = "Enter Input File: ("
1590    lngarray$(5) = "ERROR - File In Use"
1600    lngarray$(6) = "ERROR - File Does Not Exist"
1610    lngarray$(7) = "ERROR - Bad File Name"
1620    lngarray$(8) = "Enter Output File: (Default "
1630    lngarray$(9) = "ERROR - File Exists"
1640    lngarray$(10) = "OK to Delete (Y/N)"
1650    lngarray$(11) = "Enter Starting Line Number: (Default "
1660    lngarray$(12) = "ERROR - Must Enter A Number"
1670    lngarray$(13) = "ERROR - 2nd Arg is Not A Valid Number"
1680    lngarray$(14) = "ERROR - Output File Exists"
1690    lngarray$(15) = "ERROR - Bad File Name - Output File"
1700    lngarray$(16) = "ERROR - Output File In Use"
1710    lngarray$(17) = "Pass 1"
1720    lngarray$(18) = "Pass 2"
1730    lngarray$(19) = "Program Done"
1740    lngarray$(20) = "Hit Any Key"
1750    lngarray$(21) = "FATAL ERROR - Bad Name "
1760    lngarray$(22) = "FATAL ERROR - File Not Found "
1770    lngarray$(23) = "FATAL ERROR - File In Use "
1780    lngarray$(24) = "FATAL ERROR - End of File Found While Looking for \"
1790    lngarray$(25) = "FILE : "
1800    lngarray$(26) = "FATAL ERROR - Label"
1810    lngarray$(27) = " Too Long"
1820    lngarray$(28) = "LINE NUMBER: "
1830    lngarray$(29) = " IN FILE: "
1840    lngarray$(30) = "FATAL ERROR - Too Many Labels"
1850    lngarray$(31) = "FATAL ERROR - DEFINE "
1860    lngarray$(32) = " Not Found"
1870    lngarray$(33) = "FATAL ERROR - Too Many DEFINE's"
1880    lngarray$(34) = "FATAL ERROR - End of File Found Before #ENDIF"
1890    lngarray$(35) = "FATAL ERROR - Label "
1900    lngarray$(36) = "Enter Increment for Line Numbers: (Default "
1910 END IF
1920 IF d_lang$="I"
1930    lngarray$(1) = "STRUCTURED SUPERBASIC FILTER"
1940    lngarray$(2) = "       Versione 2.7.2c"
1950    lngarray$(3) = " di Timothy Swenson"
1960    lngarray$(4) = "File di input: ("
1970    lngarray$(5) = "ERRORE - Il file � in uso"
1980    lngarray$(6) = "ERRORE - Il file non esiste"
1990    lngarray$(7) = "ERRORE - Nome di file errato"
2000    lngarray$(8) = "File di output: (Default "
2010    lngarray$(9) = "ERRORE - File gia' esistente"
2020    lngarray$(10) = "Cancellarlo (S/N)"
2030    lngarray$(11) = "Inserisci il numero iniziale della numerazione: (Default "
2040    lngarray$(12) = "ERRORE - Devi inserire un numero"
2050    lngarray$(13) = "ERRORE - Il Secondo Argomento non e' Un numero valido"
2060    lngarray$(14) = "ERRORE - File di output gi� esistente"
2070    lngarray$(15) = "ERRORE - Nome Errato - Output File"
2080    lngarray$(16) = "ERRORE - File di output In Uso"
2090    lngarray$(17) = "Fase 1"
2100    lngarray$(18) = "Fase 2"
2110    lngarray$(19) = "Creato Programma"
2120    lngarray$(20) = "Premi Un Tasto"
2130    lngarray$(21) = "ERRORE BLOCCANTE - Nome errato "
2140    lngarray$(22) = "ERRORE BLOCCANTE - File on trovato "
2150    lngarray$(23) = "ERRORE BLOCCANTE - File in uso "
2160    lngarray$(24) = "ERRORE BLOCCANTE - Fine del file trovata cercando \"
2170    lngarray$(25) = "FILE : "
2180    lngarray$(26) = "ERRORE BLOCCANTE - Etichetta"
2190    lngarray$(27) = " Troppo Lunga"
2200    lngarray$(28) = "NUMERO INIZIALE: "
2210    lngarray$(29) = " IN FILE: "
2220    lngarray$(30) = "ERRORE BLOCCANTE - Troppe Etichette"
2230    lngarray$(31) = "ERRORE BLOCCANTE - DEFINE "
2240    lngarray$(32) = " Non Trovata"
2250    lngarray$(33) = "ERRORE BLOCCANTE - Troppe DEFINE's"
2260    lngarray$(34) = "ERRORE BLOCCANTE - Fine del file trovata prima di  #ENDIF"
2270    lngarray$(35) = "ERRORE BLOCCANTE - Etichette "
2280    lngarray$(36) = "Incremento del numero di linea: (Default "
2290 END IF
2300 IF d_lang$="F"
2310    lngarray$(1) = "STRUCTURED SUPERBASIC FILTER"
2320    lngarray$(2) = "       Version 2.7.2c"
2330    lngarray$(3) = " par Timothy Swenson"
2340    lngarray$(4) = "Fichied d'entr�e: ("
2350    lngarray$(5) = "ERREUR - Le fichier est en cours d'utilisation"
2360    lngarray$(6) = "ERREUR - Le fichier ne existe pas"
2370    lngarray$(7) = "ERREUR - nom de fichier incorrect"
2380    lngarray$(8) = "Fichier Sortie: (Default "
2390    lngarray$(9) = "ERREUR - Fichier dej� existantes"
2400    lngarray$(10) = "Supprimer (O/N)"
2410    lngarray$(11) = "Entrez le num�ro de d�part de la num�rotation: (Default "
2420    lngarray$(12) = "ERREUR - Vous devez entrer un nombre "
2430    lngarray$(13) = "ERREUR - Le deuxi�me argument n'est pas un nombre valide"
2440    lngarray$(14) = "ERREUR - Fichier de sortie existe d�j�"
2450    lngarray$(15) = "ERREUR - nom incorrect - fichier de sortie"
2460    lngarray$(16) = "ERREUR - fichier de sortie en cours d'utilisation"
2470    lngarray$(17) = "Phase 1"
2480    lngarray$(18) = "Phase 2"
2490    lngarray$(19) = "Cr�e Programme"
2500    lngarray$(20) = "Appuyez sur une touche"
2510    lngarray$(21) = "ERREUR BLOCAGE - Nom incorrect "
2520    lngarray$(22) = "ERREUR BLOCAGE - Fichier ne pas trouv�e "
2530    lngarray$(23) = "ERREUR BLOCAGE - Fichier en cors d'utilisation"
2540    lngarray$(24) = "ERREUR BLOCAGE - Fin de fichier trouv� essayer \"
2550    lngarray$(25) = "FICHIER : "
2560    lngarray$(26) = "ERREUR BLOCAGE- �tiquette"
2570    lngarray$(27) = " Trop LONG"
2580    lngarray$(28) = "PREMIERE NUMERO: "
2590    lngarray$(29) = " EN FICHIER: "
2600    lngarray$(30) = "ERREUR BLOCAGE - Trop d'etiquettes"
2610    lngarray$(31) = "ERREUR BLOCAGE - DEFINE "
2620    lngarray$(32) = " Non Trovata"
2630    lngarray$(33) = "ERREUR BLOCAGE - Trop DEFINE's"
2640    lngarray$(34) = "ERREUR BLOCAGE - Fin de fichier trouv� avant #ENDIF"
2650    lngarray$(35) = "ERREUR BLOCAGE - Etiquettes "
2660    lngarray$(36) = "Augmentation du nombre de ligne: (Default "
2670 END IF
2680 IF d_lang$ = "D"
2690    lngarray$(1) = "STRUCTURED SUPERBASIC FILTER"
2700    lngarray$(2) = "      Version 2.7.2c"
2710    lngarray$(3) = " By Timothy Swenson"
2720    lngarray$(4) = "Eingansdatei Angeben: ("
2730    lngarray$(5) = "Fehler - Datei ist Offen"
2740    lngarray$(6) = "Fehler - Datei Existiert Nicht"
2750    lngarray$(7) = "Fehler - Falscher Dateien Name"
2760    lngarray$(8) = "Ausgansdatei Angeben: (Vorgabewert "
2770    lngarray$(9) = "Fehler - Datei Existiert"
2780    lngarray$(10) = "OK zu L�schen (Y/N)"
2790    lngarray$(11) = "Anf�nginge Linien Number Eingeben: (Vorgabewert "
2800    lngarray$(12) = "Fehler - Eine Nummer muss eihgegeben werden"
2810    lngarray$(13) = "Fehler - Das Zweite Argument ist eine Invalide Nummer"
2820    lngarray$(14) = "Fehler - Ausgansdatei Existiert"
2830    lngarray$(15) = "Fehler - Falscher Dateien Name - Ausgansdatei"
2840    lngarray$(16) = "Fehler - Ausgangsdatei ist Offen"
2850    lngarray$(17) = "Pass 1"
2860    lngarray$(18) = "Pass 2"
2870    lngarray$(19) = "Program Fertig"
2880    lngarray$(20) = "Irgend eine Taste Dr�cken"
2890    lngarray$(21) = "Fataler Fehler - Falscher Name"
2900    lngarray$(22) = "Fataler Fehler - Datei Nicht Gefunden"
2910    lngarray$(23) = "Fataler Fehler - Datei ist Offen"
2920    lngarray$(24) = "Fataler Fehler - Ende der Datei Gefunden Beim Gesuch Nach \"
2930    lngarray$(25) = "Datei : "
2940    lngarray$(26) = "Fataler Fehler - Kennsatz"
2950    lngarray$(27) = " Zu Lange"
2960    lngarray$(28) = "Linien Nummer: "
2970    lngarray$(29) = " In Datei: "
2980    lngarray$(30) = "Fataler Fehler - Zu Viele Kenns�tze"
2990    lngarray$(31) = "Fataler Fehler - Definieren "
3000    lngarray$(32) = " Nicht Gefunden"
3010    lngarray$(33) = "Fataler Fehler - Zu Viele Definierungen "
3020    lngarray$(34) = "Fataler Fehler - Ende der Datei Gefunden Bevor #ENDIF"
3030    lngarray$(35) = "Fataler Fehler - Kennsatz"
3040    lngarray$(36) = "Erh�hung der Linien Nummern Eintragen: (Vorgabewert "
3050 END IF
3060 IF d_lang$ = "K"
3070    lngarray$ (1) = "tlham SUPERBASIC FILTER"
3080    lngarray$ (2) = "2.7.2c Version"
3090    lngarray$ (3) = "pong Timothy Swenson"
3100    lngarray$ (4) = "teywI' input:"
3110    lngarray$ (5) = "Qagh-teywI' neH lo'" 
3120    lngarray$ (6) = "wej nIv'e' Qagh-teywI'" 
3130    lngarray$ (7) = "Qagh-vo' ruv nge' teywI' pong"
3140    lngarray$ (8) = "teywI' output: (Default"
3150    lngarray$ (9) = "chonayta' nIv'e' Qagh-teywI'"
3160    lngarray$ (10) = "qIl (s ghap n)"
3170    lngarray$ (11) = "So'meH mI' pImchugh chuqmey poHmey 'el: (Default"
3180    lngarray$ (12) = "Qagh-mI' ghob'e' 'el SoH"
3190    lngarray$ (13) = "Qagh-2nd arg wej mach Valid mI'"
3200    lngarray$ (14) = "Qagh-Output teywI' nIv'e'"
3210    lngarray$ (15) = "Qagh-qab teywI' pong-teywI' Output"
3220    lngarray$ (16) = "Qagh-Output teywI' neH lo'" 
3230    lngarray$ (17) = "1" 
3240    lngarray$ (18) = "2" 
3250    lngarray$ (19) = "HIja'" 
3260    lngarray$ (20) = "qIp vay' ngaQHa'moHwI'mey" 
3270    lngarray$ (21) = "HeghmoH Qagh-qab pong" 
3280    lngarray$ (22) = "HeghmoH Qagh-teywI' wej tu'"
3290    lngarray$ (23) = "HeghmoH Qagh-teywI' neH lo'"
3300    lngarray$ (24) = "HeghmoH Qagh-bertlham teywI' found poStaHvIS looking"
3310    lngarray$ (25) = "teywI':"
3320    lngarray$ (26) = "HeghmoH Qagh-per"
3330    lngarray$ (27) = "tIqqu' "
3340    lngarray$ (28) = "tlhegh mI':"
3350    lngarray$ (29) = "teywI':"
3360    lngarray$ (30) = "HeghmoH Qagh-tlhoy law' per"
3370    lngarray$ (31) = "HeghmoH Qagh-DEFINE"
3380    lngarray$ (32) = "wej tu'"
3390    lngarray$ (33) = "HeghmoH Qagh-tlhoy law' define"
3400    lngarray$ (34) = "HeghmoH Qagh-bertlham teywI' tu' pa' #endif"
3410    lngarray$ (35) = "HeghmoH Qagh-per"
3420    lngarray$ (36) = "'el Increment tlhegh numbers: (Default "
3430 END IF
3440 IF d_lang$ = "W"
3450    lngarray$(1) = "STRUCTURED SUPERBASIC FILTER"
3460    lngarray$(2) = "      Fersiwn 2.7.2c"
3470    lngarray$(3) = " Gan Timothy Swenson"
3480    lngarray$(4) = "Ffeil fewnbwn: ("
3490    lngarray$(5) = "GWALL - Ffeil Mewn Defnydd"
3500    lngarray$(6) = "GWALL - Ffeil Ddim Yn Bod"
3510    lngarray$(7) = "GWALL - Enw Ffeil Anaddas"
3520    lngarray$(8) = "Ffeil allbwn: (Rhagosodiad "
3530    lngarray$(9) = "GWALL - Ffeil Yn Bod Eisoes"
3540    lngarray$(10) = "Iawn Dileu (Y/N)"
3550    lngarray$(11) = "Rhif Llinell Gyntaf: (Rhagosodiad "
3560    lngarray$(12) = "GWALL - Rhaid Mewnbynnu Rhif"
3570    lngarray$(13) = "GWALL - Ail Baramedr Ddim Yn Rif Addas"
3580    lngarray$(14) = "GWALL - Ffeil Allbwn Yn Bod Eisoes"
3590    lngarray$(15) = "GWALL - Enw Ffeil - Ffeil Allbwn"
3600    lngarray$(16) = "ERROR - Ffeil Allbwn Mewn Defnydd"
3610    lngarray$(17) = "Pasiad 1"
3620    lngarray$(18) = "Pasiad 2"
3630    lngarray$(19) = "Rhaglen Ar Ben"
3640    lngarray$(20) = "Pwyswch Unrhyw Fysell"
3650    lngarray$(21) = "GWALL ANGHEUOL - Enw Drwg "
3660    lngarray$(22) = "GWALL ANGHEUOL - File Heb Ei Chanfod "
3670    lngarray$(23) = "GWALL ANGHEUOL - FfeilMewn Defnydd "
3680    lngarray$(24) = "GWALL ANGHEUOL - Diwedd Y Ffeil Tra'n Chwilio Am \"
3690    lngarray$(25) = "FFEIL : "
3700    lngarray$(26) = "GWALL ANGHEUOL - Label"
3710    lngarray$(27) = " Rhy Hir"
3720    lngarray$(28) = "HIF LLINELL: "
3730    lngarray$(29) = " MEWN FFEIL: "
3740    lngarray$(30) = "GWALL ANGHEUOL - Gormod O Labeli"
3750    lngarray$(31) = "GWALL ANGHEUOL - DEFINE "
3760    lngarray$(32) = " Heb Ei Ganfod"
3770    lngarray$(33) = "GWALL ANGHEUOL - Gormod O DEFINE'au"
3780    lngarray$(34) = "GWALL ANGHEUOL - Diwedd Ffeil Cyn #ENDIF"
3790    lngarray$(35) = "GWALL ANGHEUOL - Label "
3800    lngarray$(36) = "Cynyddiad Rhifau Llinellau: (Rhagddodiad "
3810 END IF
3820 OPEN #3,"con_300x160a75x10_32"
3830 BORDER #3,2,4
3840 PAPER #3,0 : INK #3,7 :  CLS #3
3850 PRINT #3,"     ";lngarray$(1)
3860 INK #3,2
3870 PRINT #3,"            ";lngarray$(2)
3880 PRINT #3,"         ";lngarray$(3)
3890 PRINT #3
3900 INK #3,4
3910 IF d_work2$ = "" THEN d_work2$ = d_working$
3920 command$ = OPTION_CMD$
3930 count = 0
3940 y = LEN(command$)
3950 IF y > 0 THEN
3960   FOR x = 1 TO y
3970     IF command$(x) = " " THEN count=count+1
3980   NEXT x
3990   IF count = y THEN command$=""
4000 END IF
4010 IF command$ = "" THEN
4020   REPEAT input_loop
4030     PRINT #3,lngarray$(4);d_in$;") "
4040     INK #3,7
4050     INPUT #3,file$
4060     IF file$ = "" THEN abort_out
4070     INK #3,2
4080     lf = LEN(file$): ld = LEN(d_in$)
4090     IF lf > ld THEN
4100       IF file$(lf - ld + 1 TO) == d_in$ THEN
4110         file$ = file$(1 TO lf - ld)
4120       END IF
4130     END IF
4140     in_file$ = d_working$&file$&d_in$
4150     temp = FTEST(in_file$)
4160     IF temp = 0 THEN EXIT input_loop
4170     IF temp = -9 THEN
4180       BEEP 1000,10
4190         PRINT #3,"      ";lngarray$(5)
4200     END IF
4210     IF temp = -7 THEN
4220       BEEP 1000,10
4230       PRINT #3,"      ";lngarray$(6)
4240     END IF
4250     IF temp = -11 THEN
4260       BEEP 1000,10
4270       PRINT #3,"      ";lngarray$(7)
4280     END IF
4290   END REPEAT input_loop
4300   REPEAT output_loop
4310     INK #3,4
4320     PRINT #3,lngarray$(8);d_work2$&file$&d_out$;") "
4330     INK #3,7
4340     INPUT #3,out_file$
4350     IF out_file$ = "" THEN
4360       out_file$ = d_work2$&file$&d_out$
4370     END IF
4380     lf = LEN(out_file$): ld = LEN(d_out$)
4390     IF lf > ld THEN
4400       IF out_file$(lf - ld + 1 TO) == d_out$ THEN
4410         out_file$ = out_file$(1 TO lf - ld)
4420       END IF
4430     END IF
4440     out_file$ = out_file$ & d_out$
4450       INK #3,2
4460     temp = FTEST(out_file$)
4470     IF temp = -7 THEN EXIT output_loop
4480     IF temp = -9 THEN
4490       BEEP 1000,10
4500       PRINT #3,"       ";lngarray$(5)
4510     END IF
4520     IF temp = -11 THEN
4530       BEEP 1000,10
4540       PRINT #3,"       ";lngarray$(7)
4550     END IF
4560     IF temp = 0 THEN
4570       BEEP 1000,10
4580       PRINT #3,"       ";lngarray$(9)
4590       PRINT #3,"        ";lngarray$(10)
4600       temp$ = INKEY$(#3,-1)
4610       IF temp$ = "y" OR temp$="Y" or temp$="S" or temp$="s" THEN
4620         DELETE out_file$
4630         EXIT output_loop
4640         ELSE
4650           abort_out
4660       END IF
4670     END IF
4680   END REPEAT output_loop
4690   REPEAT start_loop
4700     IF t_start$ <> "" THEN
4710        line_num_d = t_start$
4720        EXIT start_loop
4730     END IF
4740     INK #3,4
4750     PRINT #3,lngarray$(11);d_start;")"
4760     INK #3,7
4770     INPUT #3,line_num$
4780     INK #3,2
4790     IF line_num$ = "" THEN
4800       line_num_d = d_start
4810       EXIT start_loop
4820     ELSE
4830       IF isnum(line_num$) THEN
4840         line_num_d = line_num$
4850         EXIT start_loop
4860       END IF
4870       BEEP 1000,10
4880       PRINT #3,lngarray$(12)
4890     END IF
4900     INK #3,4
4910   END REPEAT start_loop
4920   REPEAT delta_loop
4930     IF t_delta$ <> "" THEN
4940        line_delta = t_delta$
4950        EXIT delta_loop
4960     END IF
4970     INK #3,4
4980     PRINT #3,lngarray$(36);d_delta;")"
4990     INK #3,7
5000     INPUT #3,line_delta$
5010     INK #3,2
5020     IF line_delta$ = "" THEN
5030       line_delta = d_delta
5040       EXIT delta_loop
5050     ELSE
5060       IF isnum(line_delta$) THEN
5070         line_delta = line_delta$
5080         EXIT delta_loop
5090       END IF
5100       BEEP 1000,10
5110       PRINT #3,lngarray$(12)
5120     END IF
5130     INK #3,4
5140   END REPEAT delta_loop
5150 ELSE
5160   REPEAT loop_lb
5170     IF command$(1) = " " THEN
5180       command$=command$(2 TO )
5190     ELSE
5200       EXIT loop_lb
5210     END IF
5220   END REPEAT loop_lb
5230   REPEAT loop_tb
5240     x = LEN(command$)
5250     IF command$(x)=" " THEN
5260       command$=command$(1 TO x-1)
5270     ELSE
5280       EXIT loop_tb
5290     END IF
5300   END REPEAT loop_tb
5310   x = " " INSTR command$
5320   IF x THEN
5330     argfile$ = command$(1 TO x-1)
5340     command$ = command$( x+1 TO )
5350     REPEAT loop_lb
5360       IF command$(1) = " " THEN
5370         command$ = command$(2 TO )
5380       ELSE
5390         EXIT loop_lb
5400       END IF
5410     END REPEAT loop_lb
5420     IF isnum(command$) = 0 THEN
5430       INK #3,2
5440       BEEP 1000,10
5450       PRINT #3,"      ";lngarray$(13)
5460       abort_out
5470     END IF
5480     d_start = command$
5490   ELSE
5500     argfile$ = command$
5510   END IF
5520   in_file$ = d_working$&argfile$&d_in$
5530   out_file$ = d_work2$&argfile$&d_out$
5540   temp = FTEST(out_file$)
5550   IF temp = 0 THEN
5560     IF d_over$=="Y" or d_over$=="S" THEN
5570       DELETE out_file$
5580     ELSE
5590       BEEP 1000,10
5600       INK #3,2
5610       PRINT #3,"       ";lngarray$(14)
5620       abort_out
5630     END IF
5640   END IF
5650   IF temp = -11 THEN
5660     BEEP 1000,10
5670     INK #3,2
5680     PRINT #3,"       ";lngarray$(15)
5690     abort_out
5700   END IF
5710   IF temp = -9 THEN
5720     BEEP 1000,10
5730     INK #3,2
5740     PRINT #3,"       ";lngarray$(16)
5750     abort_out
5760   END IF
5770   line_delta = d_delta
5780   line_num_d = d_start
5790 END IF
5800 line_num = line_num_d
5810 INK #3,4
5820 PRINT #3,"    ";lngarray$(17)
5830 pass_one in_file$, file_num
5840 line_num = line_num_d
5850 PRINT #3
5860 PRINT #3,"    ";lngarray$(18)
5870 num_count = 0
5880 file_num = 5
5890 OPEN_NEW #4,out_file$
5900 pass_two in_file$, file_num
5910 CLOSE #4
5920 PRINT #3
5930 PRINT #3,"           ";lngarray$(19)
5940 PRINT #3,""
5950 IF OPTION_CMD$="" THEN
5960   INK #3,7
5970   PRINT #3,"           ";lngarray$(20)
5980   temp$ = INKEY$(#3,-1)
5990 END IF
6000 CLOSE #3
6010 STOP
6020 DEFine PROCedure pass_one (in_file$, file_num)
6030   errorx = FOP_IN(#file_num,in_file$)
6040   INK #3,2
6050   IF errorx = -12 THEN
6060     BEEP 1000,10
6070     PRINT #3,lngarray$(21);in_file$
6080     abort_out
6090   END IF
6100   IF errorx = -7 THEN
6110     BEEP 1000,10
6120     PRINT #3,lngarray$(22);in_file$
6130     abort_out
6140   END IF
6150   IF errorx = -9 THEN
6160     BEEP 1000,10
6170     PRINT #3,lngarray$(23);in_file$
6180     abort_out
6190   END IF
6200   INK #3,4
6210   REPeat pass_1
6220     num_count = num_count + 1
6230     IF (num_count MOD 10) = 0 THEN PRINT #3,CHR$(1);
6240     IF EOF(#file_num) THEN EXIT pass_1
6250     INPUT #file_num,in$
6260     temp=first_char(in$)
6270     IF temp=0 THEN NEXT pass_1
6280     IF in$(temp TO temp+1)=CHR$(35)&CHR$(35) THEN NEXT pass_1
6290     IF in$(temp)="." THEN NEXT pass_1
6300     IF LEN(in$) >= 6 THEN
6310       IF in$(1 TO 6) = "#ENDIF" THEN NEXT pass_1
6320     END IF
6330     REPeat loop
6340       IF in$(LEN(in$))="\" THEN
6350         IF EOF(#file_num) THEN
6360           BEEP 1000,10
6370           INK #3,2
6380           PRINT #3,lngarray$(24)
6390           PRINT #3,lngarray$(25);in_file$
6400           abort_out
6410         END IF
6420         INPUT #file_num,in2$
6430         temp = first_char(in2$)
6440         in$ = in$( TO LEN(in$))&" "&in2$(temp TO)
6450       ELSE
6460         EXIT loop
6470       END IF
6480     END REPeat loop
6490     IF in$(1)=CHR$(64) THEN
6500       IF LEN(in$) > d_length+1 THEN
6510         BEEP 1000,10
6520         INK #3,2
6530         PRINT #3,lngarray$(26);in$;lngarray$(27)
6540         PRINT #3,lngarray$(28);num_count;lngarray$(29);in_file$
6550         abort_out
6560       END IF
6570       IF label_var = d_labels THEN
6580         BEEP 1000,10
6590         INK #3,2
6600         PRINT #3,lngarray$(30)
6610         PRINT #3,lngarray$(28);num_count;lngarray$(29);in_file$
6620         abort_out
6630       END IF
6640       label$(label_var) = in$
6650       label(label_var) = line_num
6660       label_var = label_var + 1
6670     ELSE
6680       IF upper$(in$(1 TO 8))="#INCLUDE" THEN
6690         pass_one d_working$&in$(10 to ), file_num+1
6700       ELSE
6710         IF upper$(in$(1 TO 7))="#DEFINE" THEN
6720           IF LEN(in$(9 TO)) > d_length THEN
6730             BEEP 1000,10
6740             INK #3,2
6750             PRINT #3,lngarray$(31);in$(9 TO);lngarray$(27)
6760             PRINT #3,lngarray$(28);num_count;lngarray$(29);in_file$
6770             abort_out
6780           END IF
6790           IF define_var = d_labels THEN
6800             BEEP 1000,10
6810             INK #3,2
6820             PRINT #3,lngarray$(33)
6830             PRINT #3,lngarray$(28);num_count;lngarray$(29);in_file$
6840             abort_out
6850           END IF
6860           defn$(define_var) = upper$(in$( 9 TO))
6870           define_var = define_var+1
6880         ELSE
6890           IF upper$(in$(1 TO 6))="#IFDEF" THEN
6900             temp = 0
6910             temp$ = upper$(in$(8 TO))
6920             FOR x = 1 TO define_var
6930               IF temp$ = defn$(x) THEN temp = 1
6940             NEXT X
6950             IF temp = 0 THEN
6960               REPEAT loop
6970                 IF EOF(#file_num) THEN
6980                   BEEP 1000,10
6990                   INK #3,2
7000                   PRINT #3,lngarray$(34)
7010                   PRINT #3,lngarray$(25);in_file$
7020                   abort_out
7030                 END IF
7040                 INPUT #file_num,in2$
7050                 IF LEN(in2$) < 6 THEN NEXT loop
7060                 IF upper$(in2$(1 TO 6))="#ENDIF" THEN EXIT loop
7070               END REPeat loop
7080             END IF
7090           ELSE
7100             line_num = line_num + line_delta
7110           END IF
7120         END IF
7130       END IF
7140     END IF
7150   END REPeat pass_1
7160   CLOSE #file_num
7170 END DEFine pass_one
7180 DEFine PROCedure pass_two (in_file$, file_num)
7190   LOCal in3$(100), a$(100)
7200   OPEN_IN #file_num,in_file$
7210   REPeat pass_2
7220     num_count = num_count + 1
7230     IF (num_count MOD 10) = 0 THEN PRINT #3,CHR$(1);
7240     IF EOF(#file_num) THEN EXIT pass_2
7250     INPUT #file_num,in$
7260     temp=first_char(in$)
7270     IF temp=0 THEN
7280       IF d_ignore$ == "Y" THEN
7290         NEXT pass_2
7300       ELSE
7310         in$ = ":"
7320       END IF
7330     END IF
7340     IF in$(1)=CHR$(64) THEN NEXT pass_2
7350     IF in$(temp TO temp+1)=CHR$(35) & CHR$(35) THEN NEXT pass_2
7360     IF in$(temp)="." THEN NEXT pass_2
7370     temp2 = CHR$(35) & CHR$(35) INSTR in$
7380     IF temp2 <> 0 THEN in$ = in$( 1 to temp2-1)
7390     temp2 = CHR$(42) & CHR$(42) INSTR in$
7400     IF temp2 <> 0 then in$ = in$(1 to temp2 - 1) & "REMark" & in$(temp2 + 2 to)
7410     IF upper$(in$(1 TO 7))="#DEFINE" THEN NEXT pass_2
7420     IF LEN(in$) >= 6 THEN
7430       IF in$(1 TO 6) = "#ENDIF" THEN NEXT pass_2
7440     END IF
7450     REPeat loop
7460       IF in$(LEN(in$))="\" THEN
7470         INPUT #file_num,in2$
7480         temp = first_char(in2$)
7490         in$ = in$(1 TO (LEN(in$)-1))&in2$(temp TO)
7500       ELSE
7510         EXIT loop
7520       END IF
7530     END REPeat loop
7540     IF in$(temp TO temp+1)= CHR$(42) & CHR$(42) THEN
7550       IF temp = 1 THEN
7560         in3$=" "
7570       ELSE
7580         in3$=in$(1 to temp-1)
7590       END IF
7600       PRINT #4,line_num;in3$;"REMark";in$(temp+2 TO )
7610       line_num = line_num + line_delta
7620     ELSE
7630       temp = CHR$(64) INSTR in$
7640       IF temp<>0 THEN
7650         a$ = in$(temp TO )
7660         temp2 = 0
7670         REPEAT loop2
7680           temp2 = temp2 + 1
7690           IF temp2 > d_labels THEN
7700             BEEP 1000,10
7710             INK #3,2
7720             PRINT #3,lngarray$(35);a$;lngarray$(32)
7730             PRINT #3,lngarray$(28);num_count;lngarray$(29);in_file$
7740             abort_out
7750           END IF
7760           IF label$(temp2) == a$ THEN EXIT loop2
7770         END REPEAT loop2
7780         PRINT #4,line_num;" ";in$(1 TO temp-1);label(temp2)
7790         line_num = line_num + line_delta
7800       ELSE
7810         IF upper$(in$(1 to 8))="#INCLUDE" THEN
7820           pass_two d_working$&in$(10 to), file_num+1
7830         ELSE
7840           IF upper$(in$(1 TO 6))="#IFDEF" THEN
7850             temp = 0
7860             temp$ = upper$(in$(8 TO))
7870             FOR x = 1 TO define_var
7880               IF temp$ = defn$((x),1 TO LEN(temp$)) THEN temp = x
7890             NEXT X
7900             IF temp = 0 THEN
7910               REPEAT loop
7920                 INPUT #file_num,in2$
7930                 IF LEN(in2$) < 6 THEN NEXT loop
7940                 IF upper$(in2$(1 TO 6))="#ENDIF" THEN EXIT loop
7950               END REPeat loop
7960             END IF
7970           ELSE
7980             PRINT #4,line_num;" ";in$
7990             line_num = line_num + line_delta
8000           END IF
8010         END IF
8020       END IF
8030     END IF
8040   END REPeat pass_2
8050   CLOSE #file_num
8060 END DEFine pass_two
8070 DEFine FuNction first_char (a$)
8080    LOCal count
8090    count=0
8100    count=count+1
8110    IF count > LEN(a$) THEN RETurn 0
8120    IF a$(count)=" " THEN GO TO 8100
8130    RETurn count
8140 END DEFine first_char
8150 DEF FuNction upper$(up$)
8160     LOCal x, temp
8170     FOR x = 1 TO LEN(up$)
8180        temp = CODE(up$(x))
8190        IF temp > 96 AND temp < 123 THEN up$(x)=CHR$(temp-32)
8200     NEXT x
8210     RETURN up$
8220 END DEFine
8230 DEFine FuNCtion isnum (var$)
8240    LOCal x,y
8250    FOR x = 1 TO LEN(var$)
8260       y = CODE(var$(x))
8270       IF y < 48 OR y > 57 THEN RETURN 0
8280    NEXT x
8290    RETURN 1
8300 END DEFine isnum
8310 DEF PROCedure abort_out
8320 CLOSE #4
8330 IF OPTION_CMD$<>"" AND out_file$<>"" THEN DELETE out_file$
8340 IF file_num = 5 THEN
8350     CLOSE #5
8360 ELSE
8370     FOR x = 5 TO file_num
8380        CLOSE #x
8390     NEXT X
8400 END IF
8410 IF OPTION_CMD$<>"" THEN
8420     PRINT #3,""
8430     INK #3,7
8440     PRINT #3,"         ";lngarray$(20)
8450     temp$ = INKEY$(#3,-1)
8460 END IF
8470     CLOSE #3
8480     STOP
8490 END DEFine abort_out
