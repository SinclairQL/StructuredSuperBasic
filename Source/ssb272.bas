1000 TURBO_taskn "ssb 2.7.2d"
1010 TURBO_objfil "ram1_ssb272d_exe"
1020 TURBO_windo 0
1030 TURBO_repfil "ram1_ssb272d_err"
1040 TURBO_objdat 400
1050 TURBO_buffersz 400
1060 TURBO_optim 0
1070 TURBO_diags 2
1080 TURBO_locstr 1
1090 TURBO_struct 0
1100 IMPLICIT% d_labels, d_length, d_start, d_delta, label_var, define_var
1110 IMPLICIT% num_count, file_num, count, x, y, temp, line_num_d, line_delta
1120 IMPLICIT% line_num
1130 d_labels = 30
1140 d_length = 16
1150 d_in$    = "_ssb"
1160 d_out$   = "_bas"
1170 d_start  = 100
1180 d_delta  = 10
1190 d_working$ = ""
1200 d_work2$ = ""
1210 d_over$  = ""
1220 d_lang$  = "E"
1230 d_ignore$ = "Y"
1240 DIM out_file$(100), command$(100), file$(100), in_file$(100), temp$(100)
1250 DIM line_num$(10), line_delta$(10), argfile$(100), in$(1000), in2$(1000)
1260 DIM label$(d_labels,d_length)
1270 DIM label(d_labels)
1280 DIM defn$(d_labels,d_length)
1290 label_var = 1
1300 define_var = 1
1310 num_count = 0
1320 file_num = 5
1330 out_file$ = ""
1340 t_in$ = GETENV$("SSBINPUT")
1350 IF t_in$ <> "" THEN d_in$ = t_in$
1360 t_out$ = GETENV$("SSBOUTPUT")
1370 IF t_out$ <> "" THEN d_out$ = t_out$
1380 t_start$ = GETENV$("SSBSTART")
1390 IF t_start$ <> "" THEN d_start = t_start$
1400 t_delta$ = GETENV$("SSBINC")
1410 IF t_delta$ <> "" THEN d_delta = t_delta$
1420 t_working$ = GETENV$("SSBWORK")
1430 IF t_working$ <> "" THEN d_working$ = t_working$
1440 t_work2$ = GETENV$("SSBWORK2")
1450 IF t_work2$ <> "" THEN d_work2$ = t_work2$
1460 t_over$ = GETENV$("SSBOVER")
1470 IF t_over$ <> "" THEN d_over$ = t_over$
1480 t_lang$ = GETENV$("SSBLANG")
1490 IF t_lang$ <> "" THEN d_lang$ = t_lang$
1500 t_ignore$ = GETENV$("SSBIGNORE_BLANKS")
1510 IF t_ignore$ <> "" THEN d_ignore$ = t_ignore$
1520 DIM lngarray$(36,42)
1530 IF d_lang$ = "E"
1540    lngarray$(1) = "STRUCTURED SUPERBASIC FILTER"
1550    lngarray$(2) = "      Version 2.7.2d"
1560    lngarray$(3) = " By Timothy Swenson"
1570    lngarray$(4) = "Enter Input File: ("
1580    lngarray$(5) = "ERROR - File In Use"
1590    lngarray$(6) = "ERROR - File Does Not Exist"
1600    lngarray$(7) = "ERROR - Bad File Name"
1610    lngarray$(8) = "Enter Output File: (Default "
1620    lngarray$(9) = "ERROR - File Exists"
1630    lngarray$(10) = "OK to Delete (Y/N)"
1640    lngarray$(11) = "Enter Starting Line Number: (Default "
1650    lngarray$(12) = "ERROR - Must Enter A Number"
1660    lngarray$(13) = "ERROR - 2nd Arg is Not A Valid Number"
1670    lngarray$(14) = "ERROR - Output File Exists"
1680    lngarray$(15) = "ERROR - Bad File Name - Output File"
1690    lngarray$(16) = "ERROR - Output File In Use"
1700    lngarray$(17) = "Pass 1"
1710    lngarray$(18) = "Pass 2"
1720    lngarray$(19) = "Program Done"
1730    lngarray$(20) = "Hit Any Key"
1740    lngarray$(21) = "FATAL ERROR - Bad Name "
1750    lngarray$(22) = "FATAL ERROR - File Not Found "
1760    lngarray$(23) = "FATAL ERROR - File In Use "
1770    lngarray$(24) = "FATAL ERROR - End of File Found While Looking for \"
1780    lngarray$(25) = "FILE : "
1790    lngarray$(26) = "FATAL ERROR - Label"
1800    lngarray$(27) = " Too Long"
1810    lngarray$(28) = "LINE NUMBER: "
1820    lngarray$(29) = " IN FILE: "
1830    lngarray$(30) = "FATAL ERROR - Too Many Labels"
1840    lngarray$(31) = "FATAL ERROR - DEFINE "
1850    lngarray$(32) = " Not Found"
1860    lngarray$(33) = "FATAL ERROR - Too Many DEFINE's"
1870    lngarray$(34) = "FATAL ERROR - End of File Found Before #ENDIF"
1880    lngarray$(35) = "FATAL ERROR - Label "
1890    lngarray$(36) = "Enter Increment for Line Numbers: (Default "
1900 END IF
1910 IF d_lang$ = "S"
1920    lngarray$(1) = "FILTRO SUPERBASIC ESTRUCTURADO"
1930    lngarray$(2) = "       Versi–n 2.7.2d"
1940    lngarray$(3) = " Por: Timothy Swenson"
1950    lngarray$(4) = "Introduzca el archivo de entrada: ("
1960    lngarray$(5) = "ERROR - Archivo en uso"
1970    lngarray$(6) = "ERROR - El archivo no existe"
1980    lngarray$(7) = "ERROR - nombre de archivo incorrecto"
1990    lngarray$(8) = "Introduzca el archivo de salida: (Por defecto "
2000    lngarray$(9) = "ERROR - El archivo existe"
2010    lngarray$(10) = "Confirme para borrar (Y/N)"
2020    lngarray$(11) = "Introduzca el n™mero de l“nea inicial: (Por defecto "
2030    lngarray$(12) = "ERROR - Debe introducir un n™mero"
2040    lngarray$(13) = "ERROR - El 2º argumento no es un n™mero vŒlido"
2050    lngarray$(14) = "ERROR - El archivo de salida existe"
2060    lngarray$(15) = "ERROR - Nombre de archivo incorrecto: Archivo de salida"
2070    lngarray$(16) = "ERROR - Archivo de salida en uso"
2080    lngarray$(17) = "Paso 1"
2090    lngarray$(18) = "Paso 2"
2100    lngarray$(19) = "Programa listo"
2110    lngarray$(20) = "Pulse una tecla"
2120    lngarray$(21) = "ERROR FATAL - Nombre incorrecto "
2130    lngarray$(22) = "ERROR FATAL - Archivo no encontrado "
2140    lngarray$(23) = "ERROR FATAL - Archivo en uso "
2150    lngarray$(24) = "ERROR FATAL - Fin del archivo encontrado mientras se buscaba \"
2160    lngarray$(25) = "Archivo : "
2170    lngarray$(26) = "ERROR FATAL - Etiqueta"
2180    lngarray$(27) = " Demasiado largo"
2190    lngarray$(28) = "NUMERO DE LINEA: "
2200    lngarray$(29) = " EN EL ARCHIVO: "
2210    lngarray$(30) = "ERROR FATAL - Demasiadas etiquetas"
2220    lngarray$(31) = "ERROR FATAL - DEFINE "
2230    lngarray$(32) = " No encontrado"
2240    lngarray$(33) = "ERROR FATAL - Demasiados DEFINEs"
2250    lngarray$(34) = "ERROR FATAL - Fin del archivo encontrado antes de #ENDIF"
2260    lngarray$(35) = "ERROR FATAL - Etiqueta "
2270    lngarray$(36) = "Introduzca el incremento para los n™meros de l“nea: (Por defecto "
2280 END IF
2290 IF d_lang$="I"
2300    lngarray$(1) = "STRUCTURED SUPERBASIC FILTER"
2310    lngarray$(2) = "       Versione 2.7.2d"
2320    lngarray$(3) = " di Timothy Swenson"
2330    lngarray$(4) = "File di input: ("
2340    lngarray$(5) = "ERRORE - Il file  in uso"
2350    lngarray$(6) = "ERRORE - Il file non esiste"
2360    lngarray$(7) = "ERRORE - Nome di file errato"
2370    lngarray$(8) = "File di output: (Default "
2380    lngarray$(9) = "ERRORE - File gia' esistente"
2390    lngarray$(10) = "Cancellarlo (S/N)"
2400    lngarray$(11) = "Inserisci il numero iniziale della numerazione: (Default "
2410    lngarray$(12) = "ERRORE - Devi inserire un numero"
2420    lngarray$(13) = "ERRORE - Il Secondo Argomento non e' Un numero valido"
2430    lngarray$(14) = "ERRORE - File di output gi esistente"
2440    lngarray$(15) = "ERRORE - Nome Errato - Output File"
2450    lngarray$(16) = "ERRORE - File di output In Uso"
2460    lngarray$(17) = "Fase 1"
2470    lngarray$(18) = "Fase 2"
2480    lngarray$(19) = "Creato Programma"
2490    lngarray$(20) = "Premi Un Tasto"
2500    lngarray$(21) = "ERRORE BLOCCANTE - Nome errato "
2510    lngarray$(22) = "ERRORE BLOCCANTE - File on trovato "
2520    lngarray$(23) = "ERRORE BLOCCANTE - File in uso "
2530    lngarray$(24) = "ERRORE BLOCCANTE - Fine del file trovata cercando \"
2540    lngarray$(25) = "FILE : "
2550    lngarray$(26) = "ERRORE BLOCCANTE - Etichetta"
2560    lngarray$(27) = " Troppo Lunga"
2570    lngarray$(28) = "NUMERO INIZIALE: "
2580    lngarray$(29) = " IN FILE: "
2590    lngarray$(30) = "ERRORE BLOCCANTE - Troppe Etichette"
2600    lngarray$(31) = "ERRORE BLOCCANTE - DEFINE "
2610    lngarray$(32) = " Non Trovata"
2620    lngarray$(33) = "ERRORE BLOCCANTE - Troppe DEFINE's"
2630    lngarray$(34) = "ERRORE BLOCCANTE - Fine del file trovata prima di  #ENDIF"
2640    lngarray$(35) = "ERRORE BLOCCANTE - Etichette "
2650    lngarray$(36) = "Incremento del numero di linea: (Default "
2660 END IF
2670 IF d_lang$="F"
2680    lngarray$(1) = "STRUCTURED SUPERBASIC FILTER"
2690    lngarray$(2) = "       Version 2.7.2d"
2700    lngarray$(3) = " par Timothy Swenson"
2710    lngarray$(4) = "Fichied d'entrƒe: ("
2720    lngarray$(5) = "ERREUR - Le fichier est en cours d'utilisation"
2730    lngarray$(6) = "ERREUR - Le fichier ne existe pas"
2740    lngarray$(7) = "ERREUR - nom de fichier incorrect"
2750    lngarray$(8) = "Fichier Sortie: (Default "
2760    lngarray$(9) = "ERREUR - Fichier dej existantes"
2770    lngarray$(10) = "Supprimer (O/N)"
2780    lngarray$(11) = "Entrez le numƒro de dƒpart de la numƒrotation: (Default "
2790    lngarray$(12) = "ERREUR - Vous devez entrer un nombre "
2800    lngarray$(13) = "ERREUR - Le deuxime argument n'est pas un nombre valide"
2810    lngarray$(14) = "ERREUR - Fichier de sortie existe dƒj"
2820    lngarray$(15) = "ERREUR - nom incorrect - fichier de sortie"
2830    lngarray$(16) = "ERREUR - fichier de sortie en cours d'utilisation"
2840    lngarray$(17) = "Phase 1"
2850    lngarray$(18) = "Phase 2"
2860    lngarray$(19) = "Crƒe Programme"
2870    lngarray$(20) = "Appuyez sur une touche"
2880    lngarray$(21) = "ERREUR BLOCAGE - Nom incorrect "
2890    lngarray$(22) = "ERREUR BLOCAGE - Fichier ne pas trouvƒe "
2900    lngarray$(23) = "ERREUR BLOCAGE - Fichier en cors d'utilisation"
2910    lngarray$(24) = "ERREUR BLOCAGE - Fin de fichier trouvƒ essayer \"
2920    lngarray$(25) = "FICHIER : "
2930    lngarray$(26) = "ERREUR BLOCAGE- ƒtiquette"
2940    lngarray$(27) = " Trop LONG"
2950    lngarray$(28) = "PREMIERE NUMERO: "
2960    lngarray$(29) = " EN FICHIER: "
2970    lngarray$(30) = "ERREUR BLOCAGE - Trop d'etiquettes"
2980    lngarray$(31) = "ERREUR BLOCAGE - DEFINE "
2990    lngarray$(32) = " Non Trovata"
3000    lngarray$(33) = "ERREUR BLOCAGE - Trop DEFINE's"
3010    lngarray$(34) = "ERREUR BLOCAGE - Fin de fichier trouvƒ avant #ENDIF"
3020    lngarray$(35) = "ERREUR BLOCAGE - Etiquettes "
3030    lngarray$(36) = "Augmentation du nombre de ligne: (Default "
3040 END IF
3050 IF d_lang$ = "D"
3060    lngarray$(1) = "STRUCTURED SUPERBASIC FILTER"
3070    lngarray$(2) = "      Version 2.7.2d"
3080    lngarray$(3) = " By Timothy Swenson"
3090    lngarray$(4) = "Eingansdatei Angeben: ("
3100    lngarray$(5) = "Fehler - Datei ist Offen"
3110    lngarray$(6) = "Fehler - Datei Existiert Nicht"
3120    lngarray$(7) = "Fehler - Falscher Dateien Name"
3130    lngarray$(8) = "Ausgansdatei Angeben: (Vorgabewert "
3140    lngarray$(9) = "Fehler - Datei Existiert"
3150    lngarray$(10) = "OK zu Löschen (Y/N)"
3160    lngarray$(11) = "Anfänginge Linien Number Eingeben: (Vorgabewert "
3170    lngarray$(12) = "Fehler - Eine Nummer muss eihgegeben werden"
3180    lngarray$(13) = "Fehler - Das Zweite Argument ist eine Invalide Nummer"
3190    lngarray$(14) = "Fehler - Ausgansdatei Existiert"
3200    lngarray$(15) = "Fehler - Falscher Dateien Name - Ausgansdatei"
3210    lngarray$(16) = "Fehler - Ausgangsdatei ist Offen"
3220    lngarray$(17) = "Pass 1"
3230    lngarray$(18) = "Pass 2"
3240    lngarray$(19) = "Program Fertig"
3250    lngarray$(20) = "Irgend eine Taste Drücken"
3260    lngarray$(21) = "Fataler Fehler - Falscher Name"
3270    lngarray$(22) = "Fataler Fehler - Datei Nicht Gefunden"
3280    lngarray$(23) = "Fataler Fehler - Datei ist Offen"
3290    lngarray$(24) = "Fataler Fehler - Ende der Datei Gefunden Beim Gesuch Nach \"
3300    lngarray$(25) = "Datei : "
3310    lngarray$(26) = "Fataler Fehler - Kennsatz"
3320    lngarray$(27) = " Zu Lange"
3330    lngarray$(28) = "Linien Nummer: "
3340    lngarray$(29) = " In Datei: "
3350    lngarray$(30) = "Fataler Fehler - Zu Viele Kennsätze"
3360    lngarray$(31) = "Fataler Fehler - Definieren "
3370    lngarray$(32) = " Nicht Gefunden"
3380    lngarray$(33) = "Fataler Fehler - Zu Viele Definierungen "
3390    lngarray$(34) = "Fataler Fehler - Ende der Datei Gefunden Bevor #ENDIF"
3400    lngarray$(35) = "Fataler Fehler - Kennsatz"
3410    lngarray$(36) = "Erhöhung der Linien Nummern Eintragen: (Vorgabewert "
3420 END IF
3430 IF d_lang$ = "K"
3440    lngarray$ (1) = "tlham SUPERBASIC FILTER"
3450    lngarray$ (2) = "2.7.2d Version"
3460    lngarray$ (3) = "pong Timothy Swenson"
3470    lngarray$ (4) = "teywI' input:"
3480    lngarray$ (5) = "Qagh-teywI' neH lo'" 
3490    lngarray$ (6) = "wej nIv'e' Qagh-teywI'" 
3500    lngarray$ (7) = "Qagh-vo' ruv nge' teywI' pong"
3510    lngarray$ (8) = "teywI' output: (Default"
3520    lngarray$ (9) = "chonayta' nIv'e' Qagh-teywI'"
3530    lngarray$ (10) = "qIl (s ghap n)"
3540    lngarray$ (11) = "So'meH mI' pImchugh chuqmey poHmey 'el: (Default"
3550    lngarray$ (12) = "Qagh-mI' ghob'e' 'el SoH"
3560    lngarray$ (13) = "Qagh-2nd arg wej mach Valid mI'"
3570    lngarray$ (14) = "Qagh-Output teywI' nIv'e'"
3580    lngarray$ (15) = "Qagh-qab teywI' pong-teywI' Output"
3590    lngarray$ (16) = "Qagh-Output teywI' neH lo'" 
3600    lngarray$ (17) = "1" 
3610    lngarray$ (18) = "2" 
3620    lngarray$ (19) = "HIja'" 
3630    lngarray$ (20) = "qIp vay' ngaQHa'moHwI'mey" 
3640    lngarray$ (21) = "HeghmoH Qagh-qab pong" 
3650    lngarray$ (22) = "HeghmoH Qagh-teywI' wej tu'"
3660    lngarray$ (23) = "HeghmoH Qagh-teywI' neH lo'"
3670    lngarray$ (24) = "HeghmoH Qagh-bertlham teywI' found poStaHvIS looking"
3680    lngarray$ (25) = "teywI':"
3690    lngarray$ (26) = "HeghmoH Qagh-per"
3700    lngarray$ (27) = "tIqqu' "
3710    lngarray$ (28) = "tlhegh mI':"
3720    lngarray$ (29) = "teywI':"
3730    lngarray$ (30) = "HeghmoH Qagh-tlhoy law' per"
3740    lngarray$ (31) = "HeghmoH Qagh-DEFINE"
3750    lngarray$ (32) = "wej tu'"
3760    lngarray$ (33) = "HeghmoH Qagh-tlhoy law' define"
3770    lngarray$ (34) = "HeghmoH Qagh-bertlham teywI' tu' pa' #endif"
3780    lngarray$ (35) = "HeghmoH Qagh-per"
3790    lngarray$ (36) = "'el Increment tlhegh numbers: (Default "
3800 END IF
3810 IF d_lang$ = "W"
3820    lngarray$(1) = "STRUCTURED SUPERBASIC FILTER"
3830    lngarray$(2) = "      Fersiwn 2.7.2d"
3840    lngarray$(3) = " Gan Timothy Swenson"
3850    lngarray$(4) = "Ffeil fewnbwn: ("
3860    lngarray$(5) = "GWALL - Ffeil Mewn Defnydd"
3870    lngarray$(6) = "GWALL - Ffeil Ddim Yn Bod"
3880    lngarray$(7) = "GWALL - Enw Ffeil Anaddas"
3890    lngarray$(8) = "Ffeil allbwn: (Rhagosodiad "
3900    lngarray$(9) = "GWALL - Ffeil Yn Bod Eisoes"
3910    lngarray$(10) = "Iawn Dileu (Y/N)"
3920    lngarray$(11) = "Rhif Llinell Gyntaf: (Rhagosodiad "
3930    lngarray$(12) = "GWALL - Rhaid Mewnbynnu Rhif"
3940    lngarray$(13) = "GWALL - Ail Baramedr Ddim Yn Rif Addas"
3950    lngarray$(14) = "GWALL - Ffeil Allbwn Yn Bod Eisoes"
3960    lngarray$(15) = "GWALL - Enw Ffeil - Ffeil Allbwn"
3970    lngarray$(16) = "ERROR - Ffeil Allbwn Mewn Defnydd"
3980    lngarray$(17) = "Pasiad 1"
3990    lngarray$(18) = "Pasiad 2"
4000    lngarray$(19) = "Rhaglen Ar Ben"
4010    lngarray$(20) = "Pwyswch Unrhyw Fysell"
4020    lngarray$(21) = "GWALL ANGHEUOL - Enw Drwg "
4030    lngarray$(22) = "GWALL ANGHEUOL - File Heb Ei Chanfod "
4040    lngarray$(23) = "GWALL ANGHEUOL - FfeilMewn Defnydd "
4050    lngarray$(24) = "GWALL ANGHEUOL - Diwedd Y Ffeil Tra'n Chwilio Am \"
4060    lngarray$(25) = "FFEIL : "
4070    lngarray$(26) = "GWALL ANGHEUOL - Label"
4080    lngarray$(27) = " Rhy Hir"
4090    lngarray$(28) = "HIF LLINELL: "
4100    lngarray$(29) = " MEWN FFEIL: "
4110    lngarray$(30) = "GWALL ANGHEUOL - Gormod O Labeli"
4120    lngarray$(31) = "GWALL ANGHEUOL - DEFINE "
4130    lngarray$(32) = " Heb Ei Ganfod"
4140    lngarray$(33) = "GWALL ANGHEUOL - Gormod O DEFINE'au"
4150    lngarray$(34) = "GWALL ANGHEUOL - Diwedd Ffeil Cyn #ENDIF"
4160    lngarray$(35) = "GWALL ANGHEUOL - Label "
4170    lngarray$(36) = "Cynyddiad Rhifau Llinellau: (Rhagddodiad "
4180 END IF
4190 OPEN #3,"con_300x160a75x10_32"
4200 BORDER #3,2,4
4210 PAPER #3,0 : INK #3,7 :  CLS #3
4220 PRINT #3,"     ";lngarray$(1)
4230 INK #3,2
4240 PRINT #3,"            ";lngarray$(2)
4250 PRINT #3,"         ";lngarray$(3)
4260 PRINT #3
4270 INK #3,4
4280 IF d_work2$ = "" THEN d_work2$ = d_working$
4290 command$ = OPTION_CMD$
4300 count = 0
4310 y = LEN(command$)
4320 IF y > 0 THEN
4330   FOR x = 1 TO y
4340     IF command$(x) = " " THEN count=count+1
4350   NEXT x
4360   IF count = y THEN command$=""
4370 END IF
4380 IF command$ = "" THEN
4390   REPEAT input_loop
4400     PRINT #3,lngarray$(4);d_in$;") "
4410     INK #3,7
4420     INPUT #3,file$
4430     IF file$ = "" THEN abort_out
4440     INK #3,2
4450     in_file$ = d_working$&file$&d_in$
4460     temp = FTEST(in_file$)
4470     IF temp = 0 THEN EXIT input_loop
4480     IF temp = -9 THEN
4490       BEEP 1000,10
4500         PRINT #3,"      ";lngarray$(5)
4510     END IF
4520     IF temp = -7 THEN
4530       BEEP 1000,10
4540       PRINT #3,"      ";lngarray$(6)
4550     END IF
4560     IF temp = -11 THEN
4570       BEEP 1000,10
4580       PRINT #3,"      ";lngarray$(7)
4590     END IF
4600   END REPEAT input_loop
4610   REPEAT output_loop
4620     INK #3,4
4630     PRINT #3,lngarray$(8);d_work2$&file$&d_out$;") "
4640     INK #3,7
4650     INPUT #3,out_file$
4660     IF out_file$ = "" THEN
4670       out_file$ = d_work2$&file$&d_out$
4680     ELSE
4690       out_file$ = d_work2$&out_file$&d_out$
4700     END IF
4710       INK #3,2
4720     temp = FTEST(out_file$)
4730     IF temp = -7 THEN EXIT output_loop
4740     IF temp = -9 THEN
4750       BEEP 1000,10
4760       PRINT #3,"       ";lngarray$(5)
4770     END IF
4780     IF temp = -11 THEN
4790       BEEP 1000,10
4800       PRINT #3,"       ";lngarray$(7)
4810     END IF
4820     IF temp = 0 THEN
4830       BEEP 1000,10
4840       PRINT #3,"       ";lngarray$(9)
4850       PRINT #3,"        ";lngarray$(10)
4860       temp$ = INKEY$(#3,-1)
4870       IF temp$ = "y" OR temp$="Y" or temp$="S" or temp$="s" THEN
4880         DELETE out_file$
4890         EXIT output_loop
4900         ELSE
4910           abort_out
4920       END IF
4930     END IF
4940   END REPEAT output_loop
4950   REPEAT start_loop
4960     IF t_start$ <> "" THEN
4970        line_num_d = t_start$
4980        EXIT start_loop
4990     END IF
5000     INK #3,4
5010     PRINT #3,lngarray$(11);d_start;")"
5020     INK #3,7
5030     INPUT #3,line_num$
5040     INK #3,2
5050     IF line_num$ = "" THEN
5060       line_num_d = d_start
5070       EXIT start_loop
5080     ELSE
5090       IF isnum(line_num$) THEN
5100         line_num_d = line_num$
5110         EXIT start_loop
5120       END IF
5130       BEEP 1000,10
5140       PRINT #3,lngarray$(12)
5150     END IF
5160     INK #3,4
5170   END REPEAT start_loop
5180   REPEAT delta_loop
5190     IF t_delta$ <> "" THEN
5200        line_delta = t_delta$
5210        EXIT delta_loop
5220     END IF
5230     INK #3,4
5240     PRINT #3,lngarray$(36);d_delta;")"
5250     INK #3,7
5260     INPUT #3,line_delta$
5270     INK #3,2
5280     IF line_delta$ = "" THEN
5290       line_delta = d_delta
5300       EXIT delta_loop
5310     ELSE
5320       IF isnum(line_delta$) THEN
5330         line_delta = line_delta$
5340         EXIT delta_loop
5350       END IF
5360       BEEP 1000,10
5370       PRINT #3,lngarray$(12)
5380     END IF
5390     INK #3,4
5400   END REPEAT delta_loop
5410 ELSE
5420   REPEAT loop_lb
5430     IF command$(1) = " " THEN
5440       command$=command$(2 TO )
5450     ELSE
5460       EXIT loop_lb
5470     END IF
5480   END REPEAT loop_lb
5490   REPEAT loop_tb
5500     x = LEN(command$)
5510     IF command$(x)=" " THEN
5520       command$=command$(1 TO x-1)
5530     ELSE
5540       EXIT loop_tb
5550     END IF
5560   END REPEAT loop_tb
5570   x = " " INSTR command$
5580   IF x THEN
5590     argfile$ = command$(1 TO x-1)
5600     command$ = command$( x+1 TO )
5610     REPEAT loop_lb
5620       IF command$(1) = " " THEN
5630         command$ = command$(2 TO )
5640       ELSE
5650         EXIT loop_lb
5660       END IF
5670     END REPEAT loop_lb
5680     IF isnum(command$) = 0 THEN
5690       INK #3,2
5700       BEEP 1000,10
5710       PRINT #3,"      ";lngarray$(13)
5720       abort_out
5730     END IF
5740     d_start = command$
5750   ELSE
5760     argfile$ = command$
5770   END IF
5780   in_file$ = d_working$&argfile$&d_in$
5790   out_file$ = d_work2$&argfile$&d_out$
5800   temp = FTEST(out_file$)
5810   IF temp = 0 THEN
5820     IF d_over$=="Y" or d_over$=="S" THEN
5830       DELETE out_file$
5840     ELSE
5850       BEEP 1000,10
5860       INK #3,2
5870       PRINT #3,"       ";lngarray$(14)
5880       abort_out
5890     END IF
5900   END IF
5910   IF temp = -11 THEN
5920     BEEP 1000,10
5930     INK #3,2
5940     PRINT #3,"       ";lngarray$(15)
5950     abort_out
5960   END IF
5970   IF temp = -9 THEN
5980     BEEP 1000,10
5990     INK #3,2
6000     PRINT #3,"       ";lngarray$(16)
6010     abort_out
6020   END IF
6030   line_delta = d_delta
6040   line_num_d = d_start
6050 END IF
6060 line_num = line_num_d
6070 INK #3,4
6080 PRINT #3,"    ";lngarray$(17)
6090 pass_one in_file$, file_num
6100 line_num = line_num_d
6110 PRINT #3
6120 PRINT #3,"    ";lngarray$(18)
6130 num_count = 0
6140 file_num = 5
6150 OPEN_NEW #4,out_file$
6160 pass_two in_file$, file_num
6170 CLOSE #4
6180 PRINT #3
6190 PRINT #3,"           ";lngarray$(19)
6200 PRINT #3,""
6210 IF OPTION_CMD$="" THEN
6220   INK #3,7
6230   PRINT #3,"           ";lngarray$(20)
6240   temp$ = INKEY$(#3,-1)
6250 END IF
6260 CLOSE #3
6270 STOP
6280 DEFine PROCedure pass_one (in_file$, file_num)
6290   errorx = FOP_IN(#file_num,in_file$)
6300   INK #3,2
6310   IF errorx = -12 THEN
6320     BEEP 1000,10
6330     PRINT #3,lngarray$(21);in_file$
6340     abort_out
6350   END IF
6360   IF errorx = -7 THEN
6370     BEEP 1000,10
6380     PRINT #3,lngarray$(22);in_file$
6390     abort_out
6400   END IF
6410   IF errorx = -9 THEN
6420     BEEP 1000,10
6430     PRINT #3,lngarray$(23);in_file$
6440     abort_out
6450   END IF
6460   INK #3,4
6470   REPeat pass_1
6480     num_count = num_count + 1
6490     IF (num_count MOD 10) = 0 THEN PRINT #3,CHR$(1);
6500     IF EOF(#file_num) THEN EXIT pass_1
6510     INPUT #file_num,in$
6520     temp=first_char(in$)
6530     IF temp=0 THEN NEXT pass_1
6540     IF in$(temp TO temp+1)=CHR$(35)&CHR$(35) THEN NEXT pass_1
6550     IF in$(temp)="." THEN NEXT pass_1
6560     IF LEN(in$) >= 6 THEN
6570       IF in$(1 TO 6) = "#ENDIF" THEN NEXT pass_1
6580     END IF
6590     REPeat loop
6600       IF in$(LEN(in$))="\" THEN
6610         IF EOF(#file_num) THEN
6620           BEEP 1000,10
6630           INK #3,2
6640           PRINT #3,lngarray$(24)
6650           PRINT #3,lngarray$(25);in_file$
6660           abort_out
6670         END IF
6680         INPUT #file_num,in2$
6690         temp = first_char(in2$)
6700         in$ = in$( TO LEN(in$))&" "&in2$(temp TO)
6710       ELSE
6720         EXIT loop
6730       END IF
6740     END REPeat loop
6750     IF in$(1)=CHR$(64) THEN
6760       IF LEN(in$) > d_length+1 THEN
6770         BEEP 1000,10
6780         INK #3,2
6790         PRINT #3,lngarray$(26);in$;lngarray$(27)
6800         PRINT #3,lngarray$(28);num_count;lngarray$(29);in_file$
6810         abort_out
6820       END IF
6830       IF label_var = d_labels THEN
6840         BEEP 1000,10
6850         INK #3,2
6860         PRINT #3,lngarray$(30)
6870         PRINT #3,lngarray$(28);num_count;lngarray$(29);in_file$
6880         abort_out
6890       END IF
6900       label$(label_var) = in$
6910       label(label_var) = line_num
6920       label_var = label_var + 1
6930     ELSE
6940       IF upper$(in$(1 TO 8))="#INCLUDE" THEN
6950         pass_one d_working$&in$(10 to ), file_num+1
6960       ELSE
6970         IF upper$(in$(1 TO 7))="#DEFINE" THEN
6980           IF LEN(in$(9 TO)) > d_length THEN
6990             BEEP 1000,10
7000             INK #3,2
7010             PRINT #3,lngarray$(31);in$(9 TO);lngarray$(27)
7020             PRINT #3,lngarray$(28);num_count;lngarray$(29);in_file$
7030             abort_out
7040           END IF
7050           IF define_var = d_labels THEN
7060             BEEP 1000,10
7070             INK #3,2
7080             PRINT #3,lngarray$(33)
7090             PRINT #3,lngarray$(28);num_count;lngarray$(29);in_file$
7100             abort_out
7110           END IF
7120           defn$(define_var) = upper$(in$( 9 TO))
7130           define_var = define_var+1
7140         ELSE
7150           IF upper$(in$(1 TO 6))="#IFDEF" THEN
7160             temp = 0
7170             temp$ = upper$(in$(8 TO))
7180             FOR x = 1 TO define_var
7190               IF temp$ = defn$(x) THEN temp = 1
7200             NEXT X
7210             IF temp = 0 THEN
7220               REPEAT loop
7230                 IF EOF(#file_num) THEN
7240                   BEEP 1000,10
7250                   INK #3,2
7260                   PRINT #3,lngarray$(34)
7270                   PRINT #3,lngarray$(25);in_file$
7280                   abort_out
7290                 END IF
7300                 INPUT #file_num,in2$
7310                 IF LEN(in2$) < 6 THEN NEXT loop
7320                 IF upper$(in2$(1 TO 6))="#ENDIF" THEN EXIT loop
7330               END REPeat loop
7340             END IF
7350           ELSE
7360             line_num = line_num + line_delta
7370           END IF
7380         END IF
7390       END IF
7400     END IF
7410   END REPeat pass_1
7420   CLOSE #file_num
7430 END DEFine pass_one
7440 DEFine PROCedure pass_two (in_file$, file_num)
7450   LOCal in3$(100), a$(100)
7460   OPEN_IN #file_num,in_file$
7470   REPeat pass_2
7480     num_count = num_count + 1
7490     IF (num_count MOD 10) = 0 THEN PRINT #3,CHR$(1);
7500     IF EOF(#file_num) THEN EXIT pass_2
7510     INPUT #file_num,in$
7520     temp=first_char(in$)
7530     IF temp=0 THEN
7540       IF d_ignore$ == "Y" THEN
7550         NEXT pass_2
7560       ELSE
7570         print #4, line_num; " :"           
7580         line_num = line_num + line_delta
7590         next pass_2
7600       END IF
7610     END IF
7620     IF in$(1)=CHR$(64) THEN NEXT pass_2
7630     IF in$(temp TO temp+1)=CHR$(35)&CHR$(35) THEN NEXT pass_2
7640     IF in$(temp)="." THEN NEXT pass_2
7650     temp2 = CHR$(35)&CHR$(35) INSTR in$
7660     IF temp2 <> 0 THEN
7670       if not inString%(in$, temp2) then
7680         in$ = in$( 1 to temp2-1)
7690       end if
7700     END IF
7710     temp2 = CHR$(42) & CHR$(42) INSTR in$
7720     IF temp2 > temp then
7730       if not inString%(in$, temp2) then
7740         in$ = in$(1 to temp2 - 1) & "REMark" & in$(temp2 + 2 to)
7750       end if
7760     END IF
7770     IF upper$(in$(1 TO 7))="#DEFINE" THEN NEXT pass_2
7780     IF LEN(in$) >= 6 THEN
7790       IF in$(1 TO 6) = "#ENDIF" THEN NEXT pass_2
7800     END IF
7810     REPeat loop
7820       IF in$(LEN(in$))="\" THEN
7830         INPUT #file_num,in2$
7840         temp = first_char(in2$)
7850         in$ = in$(1 TO (LEN(in$)-1))&in2$(temp TO)
7860       ELSE
7870         EXIT loop
7880       END IF
7890     END REPeat loop
7900     IF in$(temp TO temp+1)= CHR$(42) & CHR$(42) THEN
7910       IF temp = 1 THEN
7920         in3$=" "
7930       ELSE
7940         in3$=in$(1 to temp-1)
7950       END IF
7960       PRINT #4,line_num;in3$;"REMark";in$(temp+2 TO )
7970       line_num = line_num + line_delta
7980     ELSE
7990       temp = CHR$(64) INSTR in$
8000       IF temp<>0 THEN
8010         a$ = in$(temp TO )
8020         temp2 = 0
8030         REPEAT loop2
8040           temp2 = temp2 + 1
8050           IF temp2 > d_labels THEN
8060             BEEP 1000,10
8070             INK #3,2
8080             PRINT #3,lngarray$(35);a$;lngarray$(32)
8090             PRINT #3,lngarray$(28);num_count;lngarray$(29);in_file$
8100             abort_out
8110           END IF
8120           IF label$(temp2) == a$ THEN EXIT loop2
8130         END REPEAT loop2
8140         PRINT #4,line_num;" ";in$(1 TO temp-1);label(temp2)
8150         line_num = line_num + line_delta
8160       ELSE
8170         IF upper$(in$(1 to 8))="#INCLUDE" THEN
8180           pass_two d_working$&in$(10 to), file_num+1
8190         ELSE
8200           IF upper$(in$(1 TO 6))="#IFDEF" THEN
8210             temp = 0
8220             temp$ = upper$(in$(8 TO))
8230             FOR x = 1 TO define_var
8240               IF temp$ = defn$((x),1 TO LEN(temp$)) THEN temp = x
8250             NEXT X
8260             IF temp = 0 THEN
8270               REPEAT loop
8280                 INPUT #file_num,in2$
8290                 IF LEN(in2$) < 6 THEN NEXT loop
8300                 IF upper$(in2$(1 TO 6))="#ENDIF" THEN EXIT loop
8310               END REPeat loop
8320             END IF
8330           ELSE
8340             PRINT #4,line_num;" ";in$
8350             line_num = line_num + line_delta
8360           END IF
8370         END IF
8380       END IF
8390     END IF
8400   END REPeat pass_2
8410   CLOSE #file_num
8420 END DEFine pass_two
8430 DEFine FuNction inString% (in$, stopHere)
8440   local x, Double%, Single%
8450   Double% = 0: Single% = 0
8460   FOR x = 1 to stopHere
8470    REMark Check for double quotes.
8480     if in$(x) = '"' THEN
8490       if Double% = 1 then
8500         Double% = 0
8510       else
8520         Double% = 1
8530       end if
8540     else
8550      REMark Try single quotes.
8560       if in$(x) = "'" then
8570         if Single% = 1 then
8580           Single% = 0
8590         else
8600           Single% = 1
8610         end if
8620       end if
8630     end if
8640   END FOR x
8650  REMark If Double% or Single% = 1 then
8660  REMark we opened a string before the
8670  REMark marker characters for REMark or
8680  REMark invisible REMark, so we return
8690  REMark true, else false.
8700   return Double% or single%
8710 END DEFine inString%
8720 DEFine FuNction first_char (a$)
8730    LOCal count
8740    count=0
8750    count=count+1
8760    IF count > LEN(a$) THEN RETurn 0
8770    IF a$(count)=" " THEN GO TO 8750
8780    RETurn count
8790 END DEFine first_char
8800 DEF FuNction upper$(up$)
8810     LOCal x, temp
8820     FOR x = 1 TO LEN(up$)
8830        temp = CODE(up$(x))
8840        IF temp > 96 AND temp < 123 THEN up$(x)=CHR$(temp-32)
8850     NEXT x
8860     RETURN up$
8870 END DEFine
8880 DEFine FuNCtion isnum (var$)
8890    LOCal x,y
8900    FOR x = 1 TO LEN(var$)
8910       y = CODE(var$(x))
8920       IF y < 48 OR y > 57 THEN RETURN 0
8930    NEXT x
8940    RETURN 1
8950 END DEFine isnum
8960 DEF PROCedure abort_out
8970 CLOSE #4
8980 IF OPTION_CMD$<>"" AND out_file$<>"" THEN DELETE out_file$
8990 IF file_num = 5 THEN
9000     CLOSE #5
9010 ELSE
9020     FOR x = 5 TO file_num
9030        CLOSE #x
9040     NEXT X
9050 END IF
9060 IF OPTION_CMD$<>"" THEN
9070     PRINT #3,""
9080     INK #3,7
9090     PRINT #3,"         ";lngarray$(20)
9100     temp$ = INKEY$(#3,-1)
9110 END IF
9120     CLOSE #3
9130     STOP
9140 END DEFine abort_out
