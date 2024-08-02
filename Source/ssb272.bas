1000 TURBO_taskn "ssb 2.7.2f"
1010 TURBO_objfil "dev7_ssb272_exe"
1020 TURBO_windo 0
1030 TURBO_repfil "dev7_ssb272_err"
1040 TURBO_objdat 400
1050 TURBO_buffersz 400
1060 TURBO_optim 0
1070 TURBO_diags 2
1080 TURBO_locstr 1
1090 TURBO_struct 0
1100 IMPLICIT% d_labels, d_length, d_start, d_delta, label_var, define_var
1110 IMPLICIT% num_count, file_num, x, y, temp, line_num_d, line_delta
1120 IMPLICIT% line_num
1130 d_labels = 30
1140 d_length = 16
1150 d_in$    = "_ssb"
1160 d_out$   = "_bas"
1170 d_start  = 1000
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
1550    lngarray$(2) = "Version 2.7.2f"
1560    lngarray$(3) = "By Timothy Swenson"
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
1930    lngarray$(2) = "Versiñn 2.7.2f"
1940    lngarray$(3) = "Por: Timothy Swenson"
1950    lngarray$(4) = "Introduzca el archivo de entrada: ("
1960    lngarray$(5) = "ERROR - Archivo en uso"
1970    lngarray$(6) = "ERROR - El archivo no existe"
1980    lngarray$(7) = "ERROR - nombre de archivo incorrecto"
1990    lngarray$(8) = "Introduzca el archivo de salida: (Por defecto "
2000    lngarray$(9) = "ERROR - El archivo existe"
2010    lngarray$(10) = "Confirme para borrar (Y/N)"
2020    lngarray$(11) = "Introduzca el nômero de lìnea inicial: (Por defecto "
2030    lngarray$(12) = "ERROR - Debe introducir un nômero"
2040    lngarray$(13) = "ERROR - El 2∫ argumento no es un nômero vålido"
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
2270    lngarray$(36) = "Introduzca el incremento para los nômeros de lìnea: (Por defecto "
2280 END IF
2290 IF d_lang$="I"
2300    lngarray$(1) = "STRUCTURED SUPERBASIC FILTER"
2310    lngarray$(2) = "Versione 2.7.2f"
2320    lngarray$(3) = "di Timothy Swenson"
2330    lngarray$(4) = "File di input: ("
2340    lngarray$(5) = "ERRORE - Il file ê in uso"
2350    lngarray$(6) = "ERRORE - Il file non esiste"
2360    lngarray$(7) = "ERRORE - Nome di file errato"
2370    lngarray$(8) = "File di output: (Default "
2380    lngarray$(9) = "ERRORE - File gia' esistente"
2390    lngarray$(10) = "Cancellarlo (S/N)"
2400    lngarray$(11) = "Inserisci il numero iniziale della numerazione: (Default "
2410    lngarray$(12) = "ERRORE - Devi inserire un numero"
2420    lngarray$(13) = "ERRORE - Il Secondo Argomento non e' Un numero valido"
2430    lngarray$(14) = "ERRORE - File di output giç esistente"
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
2690    lngarray$(2) = "Version 2.7.2f"
2700    lngarray$(3) = "par Timothy Swenson"
2710    lngarray$(4) = "Fichied d'entrÉe: ("
2720    lngarray$(5) = "ERREUR - Le fichier est en cours d'utilisation"
2730    lngarray$(6) = "ERREUR - Le fichier ne existe pas"
2740    lngarray$(7) = "ERREUR - nom de fichier incorrect"
2750    lngarray$(8) = "Fichier Sortie: (Default "
2760    lngarray$(9) = "ERREUR - Fichier dejç existantes"
2770    lngarray$(10) = "Supprimer (O/N)"
2780    lngarray$(11) = "Entrez le numÉro de dÉpart de la numÉrotation: (Default "
2790    lngarray$(12) = "ERREUR - Vous devez entrer un nombre "
2800    lngarray$(13) = "ERREUR - Le deuxiême argument n'est pas un nombre valide"
2810    lngarray$(14) = "ERREUR - Fichier de sortie existe dÉjç"
2820    lngarray$(15) = "ERREUR - nom incorrect - fichier de sortie"
2830    lngarray$(16) = "ERREUR - fichier de sortie en cours d'utilisation"
2840    lngarray$(17) = "Phase 1"
2850    lngarray$(18) = "Phase 2"
2860    lngarray$(19) = "CrÉe Programme"
2870    lngarray$(20) = "Appuyez sur une touche"
2880    lngarray$(21) = "ERREUR BLOCAGE - Nom incorrect "
2890    lngarray$(22) = "ERREUR BLOCAGE - Fichier ne pas trouvÉe "
2900    lngarray$(23) = "ERREUR BLOCAGE - Fichier en cors d'utilisation"
2910    lngarray$(24) = "ERREUR BLOCAGE - Fin de fichier trouvÉ essayer \"
2920    lngarray$(25) = "FICHIER : "
2930    lngarray$(26) = "ERREUR BLOCAGE- Étiquette"
2940    lngarray$(27) = " Trop LONG"
2950    lngarray$(28) = "PREMIERE NUMERO: "
2960    lngarray$(29) = " EN FICHIER: "
2970    lngarray$(30) = "ERREUR BLOCAGE - Trop d'etiquettes"
2980    lngarray$(31) = "ERREUR BLOCAGE - DEFINE "
2990    lngarray$(32) = " Non Trovata"
3000    lngarray$(33) = "ERREUR BLOCAGE - Trop DEFINE's"
3010    lngarray$(34) = "ERREUR BLOCAGE - Fin de fichier trouvÉ avant #ENDIF"
3020    lngarray$(35) = "ERREUR BLOCAGE - Etiquettes "
3030    lngarray$(36) = "Augmentation du nombre de ligne: (Default "
3040 END IF
3050 IF d_lang$ = "D"
3060    lngarray$(1) = "STRUCTURED SUPERBASIC FILTER"
3070    lngarray$(2) = "Version 2.7.2f"
3080    lngarray$(3) = "By Timothy Swenson"
3090    lngarray$(4) = "Eingansdatei Angeben: ("
3100    lngarray$(5) = "Fehler - Datei ist Offen"
3110    lngarray$(6) = "Fehler - Datei Existiert Nicht"
3120    lngarray$(7) = "Fehler - Falscher Dateien Name"
3130    lngarray$(8) = "Ausgansdatei Angeben: (Vorgabewert "
3140    lngarray$(9) = "Fehler - Datei Existiert"
3150    lngarray$(10) = "OK zu Lˆschen (Y/N)"
3160    lngarray$(11) = "Anf‰nginge Linien Number Eingeben: (Vorgabewert "
3170    lngarray$(12) = "Fehler - Eine Nummer muss eihgegeben werden"
3180    lngarray$(13) = "Fehler - Das Zweite Argument ist eine Invalide Nummer"
3190    lngarray$(14) = "Fehler - Ausgansdatei Existiert"
3200    lngarray$(15) = "Fehler - Falscher Dateien Name - Ausgansdatei"
3210    lngarray$(16) = "Fehler - Ausgangsdatei ist Offen"
3220    lngarray$(17) = "Pass 1"
3230    lngarray$(18) = "Pass 2"
3240    lngarray$(19) = "Program Fertig"
3250    lngarray$(20) = "Irgend eine Taste Dr¸cken"
3260    lngarray$(21) = "Fataler Fehler - Falscher Name"
3270    lngarray$(22) = "Fataler Fehler - Datei Nicht Gefunden"
3280    lngarray$(23) = "Fataler Fehler - Datei ist Offen"
3290    lngarray$(24) = "Fataler Fehler - Ende der Datei Gefunden Beim Gesuch Nach \"
3300    lngarray$(25) = "Datei : "
3310    lngarray$(26) = "Fataler Fehler - Kennsatz"
3320    lngarray$(27) = " Zu Lange"
3330    lngarray$(28) = "Linien Nummer: "
3340    lngarray$(29) = " In Datei: "
3350    lngarray$(30) = "Fataler Fehler - Zu Viele Kenns‰tze"
3360    lngarray$(31) = "Fataler Fehler - Definieren "
3370    lngarray$(32) = " Nicht Gefunden"
3380    lngarray$(33) = "Fataler Fehler - Zu Viele Definierungen "
3390    lngarray$(34) = "Fataler Fehler - Ende der Datei Gefunden Bevor #ENDIF"
3400    lngarray$(35) = "Fataler Fehler - Kennsatz"
3410    lngarray$(36) = "Erhˆhung der Linien Nummern Eintragen: (Vorgabewert "
3420 END IF
3430 IF d_lang$ = "K"
3440    lngarray$ (1) = "tlham SUPERBASIC FILTER"
3450    lngarray$ (2) = "2.7.2f Version"
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
3830    lngarray$(2) = "Fersiwn 2.7.2f"
3840    lngarray$(3) = "Gan Timothy Swenson"
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
4220 centre 3, lngarray$(1)
4230 INK #3,2
4240 centre 3, lngarray$(2)
4250 centre 3, lngarray$(3)
4260 PRINT #3
4270 INK #3,4
4280 IF d_work2$ = "" THEN d_work2$ = d_working$
4290 command$ = OPTION_CMD$
4300 command$ = trim$(command$)
4310 IF command$ = "" THEN
4320   REPEAT input_loop
4330     PRINT #3,lngarray$(4);d_in$;") "
4340     INK #3,7
4350     INPUT #3,file$
4360     IF file$ = "" THEN abort_out
4370     INK #3,2
4380     in_file$ = d_working$&file$&d_in$
4390     temp = FTEST(in_file$)
4400     IF temp = 0 THEN EXIT input_loop
4410     IF temp = -9 THEN
4420       BEEP 1000,10
4430         centre 3, lngarray$(5)
4440     END IF
4450     IF temp = -7 THEN
4460       BEEP 1000,10
4470       centre 3, lngarray$(6)
4480     END IF
4490     IF temp = -11 THEN
4500       BEEP 1000,10
4510       centre 3, lngarray$(7)
4520     END IF
4530   END REPEAT input_loop
4540   REPEAT output_loop
4550     INK #3,4
4560     PRINT #3,lngarray$(8); d_work2$ & file$ & d_out$; ") "
4570     INK #3,7
4580     INPUT #3,out_file$
4590     IF out_file$ = "" THEN
4600       out_file$ = d_work2$ & file$ & d_out$
4610     ELSE
4620       out_file$ = d_work2$ & out_file$ & d_out$
4630     END IF
4640       INK #3,2
4650     temp = FTEST(out_file$)
4660     IF temp = -7 THEN EXIT output_loop
4670     IF temp = -9 THEN
4680       BEEP 1000,10
4690       centre 3, lngarray$(5)
4700     END IF
4710     IF temp = -11 THEN
4720       BEEP 1000,10
4730       centre 3, lngarray$(7)
4740     END IF
4750     IF temp = 0 THEN
4760       BEEP 1000,10
4770       centre 3, lngarray$(9)
4780       centre 3, lngarray$(10)
4790       temp$ = INKEY$(#3,-1)
4800       IF temp$ == "Y" or temp$ == "S" THEN
4810         DELETE out_file$
4820         EXIT output_loop
4830         ELSE
4840           abort_out
4850       END IF
4860     END IF
4870   END REPEAT output_loop
4880   REPEAT start_loop
4890     IF t_start$ <> "" THEN
4900        line_num_d = t_start$
4910        EXIT start_loop
4920     END IF
4930     INK #3,4
4940     PRINT #3, lngarray$(11); d_start; ")"
4950     INK #3,7
4960     INPUT #3,line_num$
4970     INK #3,2
4980     IF line_num$ = "" THEN
4990       line_num_d = d_start
5000       EXIT start_loop
5010     ELSE
5020       IF isnum(line_num$) THEN
5030         line_num_d = line_num$
5040         EXIT start_loop
5050       END IF
5060       BEEP 1000,10
5070       PRINT #3,lngarray$(12)
5080     END IF
5090     INK #3,4
5100   END REPEAT start_loop
5110   REPEAT delta_loop
5120     IF t_delta$ <> "" THEN
5130        line_delta = t_delta$
5140        EXIT delta_loop
5150     END IF
5160     INK #3,4
5170     PRINT #3,lngarray$(36); " "; d_delta; ")"
5180     INK #3,7
5190     INPUT #3,line_delta$
5200     INK #3,2
5210     IF line_delta$ = "" THEN
5220       line_delta = d_delta
5230       EXIT delta_loop
5240     ELSE
5250       IF isnum(line_delta$) THEN
5260         line_delta = line_delta$
5270         EXIT delta_loop
5280       END IF
5290       BEEP 1000,10
5300       PRINT #3,lngarray$(12)
5310     END IF
5320     INK #3,4
5330   END REPEAT delta_loop
5340 ELSE
5350   command$ = Trim$(command$)
5360   x = " " INSTR command$
5370   IF x THEN
5380     argfile$ = command$(1 TO x-1)
5390     command$ = command$( x+1 TO )
5400     command$ = trim$(command$)
5410     IF isnum(command$) = 0 THEN
5420       INK #3,2
5430       BEEP 1000,10
5440       centre 3, lngarray$(13)
5450       abort_out
5460     END IF
5470     d_start = command$
5480   ELSE
5490     argfile$ = command$
5500   END IF
5510   in_file$ = d_working$ & argfile$ & d_in$
5520   out_file$ = d_work2$ & argfile$ & d_out$
5530   temp = FTEST(out_file$)
5540   IF temp = 0 THEN
5550     IF d_over$ == "Y" or d_over$ == "S" THEN
5560       DELETE out_file$
5570     ELSE
5580       BEEP 1000,10
5590       INK #3,2
5600       centre 3, lngarray$(14)
5610       abort_out
5620     END IF
5630   END IF
5640   IF temp = -11 THEN
5650     BEEP 1000,10
5660     INK #3,2
5670     centre 3, lngarray$(15)
5680     abort_out
5690   END IF
5700   IF temp = -9 THEN
5710     BEEP 1000,10
5720     INK #3,2
5730     centre 3, lngarray$(16)
5740     abort_out
5750   END IF
5760   line_delta = d_delta
5770   line_num_d = d_start
5780 END IF
5790 line_num = line_num_d
5800 INK #3,4
5810 centre 3, lngarray$(17)
5820 pass_one in_file$, file_num
5830 line_num = line_num_d
5840 PRINT #3
5850 centre 3, lngarray$(18)
5860 num_count = 0
5870 file_num = 5
5880 OPEN_NEW #4,out_file$
5890 pass_two in_file$, file_num
5900 CLOSE #4
5910 PRINT #3
5920 centre 3, lngarray$(19)
5930 PRINT #3,""
5940 IF OPTION_CMD$="" THEN
5950   INK #3,7
5960   centre 3, lngarray$(20)
5970   temp$ = INKEY$(#3,-1)
5980 END IF
5990 CLOSE #3
6000 STOP
6010 DEFine PROCedure pass_one (in_file$, file_num)
6020   errorx = FOP_IN(#file_num,in_file$)
6030   INK #3,2
6040   IF errorx = -12 THEN
6050     BEEP 1000,10
6060     PRINT #3,lngarray$(21);in_file$
6070     abort_out
6080   END IF
6090   IF errorx = -7 THEN
6100     BEEP 1000,10
6110     PRINT #3,lngarray$(22);in_file$
6120     abort_out
6130   END IF
6140   IF errorx = -9 THEN
6150     BEEP 1000,10
6160     PRINT #3,lngarray$(23);in_file$
6170     abort_out
6180   END IF
6190   INK #3,4
6200   REPeat pass_1
6210     num_count = num_count + 1
6220     IF (num_count MOD 10) = 0 THEN PRINT #3,CHR$(1);
6230     IF EOF(#file_num) THEN EXIT pass_1
6240     INPUT #file_num,in$
6250     temp=first_char(in$)
6260     IF temp=0 THEN NEXT pass_1
6270     IF in$(temp TO temp+1)=CHR$(35)&CHR$(35) THEN NEXT pass_1
6280     IF in$(temp)="." THEN NEXT pass_1
6290     IF LEN(in$) >= 6 THEN
6300       IF in$(1 TO 6) = "#ENDIF" THEN NEXT pass_1
6310     END IF
6320     REPeat loop
6330       IF in$(LEN(in$)-1 TO)="\+" THEN
6340         IF EOF(#file_num) THEN
6350           BEEP 1000,10
6360           INK #3,2
6370           PRINT #3,lngarray$(24)
6380           PRINT #3,lngarray$(25);in_file$
6390           abort_out
6400         END IF
6410         INPUT #file_num,in2$
6420         temp = first_char(in2$)
6430         in$ = in$( TO LEN(in$)-2) & " " & in2$(temp TO)
6440       ELSE
6450         EXIT loop
6460       END IF
6470     END REPeat loop
6480     IF in$(1)=CHR$(64) THEN
6490       IF LEN(in$) > d_length+1 THEN
6500         BEEP 1000,10
6510         INK #3,2
6520         PRINT #3,lngarray$(26);in$;lngarray$(27)
6530         PRINT #3,lngarray$(28);num_count;lngarray$(29);in_file$
6540         abort_out
6550       END IF
6560       IF label_var = d_labels THEN
6570         BEEP 1000,10
6580         INK #3,2
6590         PRINT #3,lngarray$(30)
6600         PRINT #3,lngarray$(28);num_count;lngarray$(29);in_file$
6610         abort_out
6620       END IF
6630       label$(label_var) = in$
6640       label(label_var) = line_num
6650       label_var = label_var + 1
6660     ELSE
6670       IF upper$(in$(1 TO 8))="#INCLUDE" THEN
6680         pass_one d_working$&in$(10 to ), file_num+1
6690       ELSE
6700         IF upper$(in$(1 TO 7))="#DEFINE" THEN
6710           IF LEN(in$(9 TO)) > d_length THEN
6720             BEEP 1000,10
6730             INK #3,2
6740             PRINT #3,lngarray$(31);in$(9 TO);lngarray$(27)
6750             PRINT #3,lngarray$(28);num_count;lngarray$(29);in_file$
6760             abort_out
6770           END IF
6780           IF define_var = d_labels THEN
6790             BEEP 1000,10
6800             INK #3,2
6810             PRINT #3,lngarray$(33)
6820             PRINT #3,lngarray$(28);num_count;lngarray$(29);in_file$
6830             abort_out
6840           END IF
6850           defn$(define_var) = upper$(in$( 9 TO))
6860           define_var = define_var+1
6870         ELSE
6880           IF upper$(in$(1 TO 6))="#IFDEF" THEN
6890             temp = 0
6900             temp$ = upper$(in$(8 TO))
6910             FOR x = 1 TO define_var
6920               IF temp$ = defn$(x) THEN temp = 1
6930             END FOR X
6940             IF temp = 0 THEN
6950               REPEAT loop
6960                 IF EOF(#file_num) THEN
6970                   BEEP 1000,10
6980                   INK #3,2
6990                   PRINT #3,lngarray$(34)
7000                   PRINT #3,lngarray$(25);in_file$
7010                   abort_out
7020                 END IF
7030                 INPUT #file_num,in2$
7040                 IF LEN(in2$) < 6 THEN NEXT loop
7050                 IF upper$(in2$(1 TO 6))="#ENDIF" THEN EXIT loop
7060               END REPeat loop
7070             END IF
7080           ELSE
7090             line_num = line_num + line_delta
7100           END IF
7110         END IF
7120       END IF
7130     END IF
7140   END REPeat pass_1
7150   CLOSE #file_num
7160 END DEFine pass_one
7170 DEFine PROCedure pass_two (in_file$, file_num)
7180   LOCal in3$(100), a$(100), space$(1), rem$(2)
7190   LOCal comm$(2), at$(1), lab$(1), cont$(2)
7200   rem$ = CHR$(42) & CHR$(42): REMark REMark flag.
7210   comm$ = CHR$(35) & CHR$(35): REMark Comment flag, ignore these lines.
7220   lab$ = CHR$(64): REMark Label flag. 
7230   cont$ = "\+": REMark Continuation flag, join this to the next line(s).
7240   OPEN_IN #file_num,in_file$
7250   REPeat pass_2
7260     num_count = num_count + 1
7270     IF (num_count MOD 10) = 0 THEN PRINT #3,CHR$(1);
7280     IF EOF(#file_num) THEN EXIT pass_2
7290     INPUT #file_num,in$
7300     in$ = stripTab$(in$)  
7310     temp=first_char(in$)
7320     IF temp=0 THEN
7330       IF d_ignore$ == "Y" THEN
7340         NEXT pass_2
7350       ELSE
7360         print #4, line_num; " :"           
7370         line_num = line_num + line_delta
7380         next pass_2
7390       END IF
7400     END IF
7410     IF in$(1) = lab$ THEN NEXT pass_2: END IF
7420     IF in$(temp TO temp + 1) = comm$ THEN NEXT pass_2: END IF
7430     IF in$(temp) = "." THEN NEXT pass_2: END IF
7440     IF in$(LEN(in$)-1 TO) = "\+" THEN
7450       REMark Join lines until we have the complete line.
7460       REMark ready for further processing.
7470       in$ = joinLine$(in$)
7480     END IF
7490     IF comm$ INSTR in$ THEN
7500       in$ = stripComment$(in$)
7510     END IF
7520     IF rem$ INSTR in$ THEN
7530       in$ = doRemark$(in$)
7540     END IF
7550     IF upper$(in$(1 TO 7))="#DEFINE" THEN NEXT pass_2: END IF
7560     IF LEN(in$) >= 6 THEN
7570       IF in$(1 TO 6) = "#ENDIF" THEN NEXT pass_2: END IF
7580     END IF
7590     temp = lab$ INSTR in$
7600     IF temp<>0 THEN
7610       a$ = in$(temp TO )
7620       temp2 = 0
7630       REPEAT loop2
7640         temp2 = temp2 + 1
7650         IF temp2 > d_labels THEN
7660           BEEP 1000,10
7670           INK #3,2
7680           PRINT #3,lngarray$(35);a$;lngarray$(32)
7690           PRINT #3,lngarray$(28);num_count;lngarray$(29);in_file$
7700           abort_out
7710         END IF
7720         IF label$(temp2) == a$ THEN EXIT loop2
7730       END REPEAT loop2
7740       PRINT #4,line_num;" ";in$(1 TO temp-1);label(temp2)
7750       line_num = line_num + line_delta
7760     ELSE
7770       IF upper$(in$(1 to 8))="#INCLUDE" THEN
7780         pass_two d_working$&in$(10 to), file_num+1
7790       ELSE
7800         IF upper$(in$(1 TO 6))="#IFDEF" THEN
7810           temp = 0
7820           temp$ = upper$(in$(8 TO))
7830           FOR x = 1 TO define_var
7840             IF temp$ = defn$((x),1 TO LEN(temp$)) THEN temp = x
7850           END FOR X
7860           IF temp = 0 THEN
7870             REPEAT loop
7880               INPUT #file_num,in2$
7890               IF LEN(in2$) < 6 THEN NEXT loop
7900               IF upper$(in2$(1 TO 6))="#ENDIF" THEN EXIT loop
7910             END REPeat loop
7920           END IF
7930         ELSE
7940           PRINT #4,line_num;" ";in$
7950           line_num = line_num + line_delta
7960         END IF
7970       END IF
7980     END IF
7990   END REPeat pass_2
8000   CLOSE #file_num
8010 END DEFine pass_two
8020 DEFine FuNction Trim$(text$)
8030     IF text$ <> "" THEN
8040         RETurn RTrim$(LTrim$(text$))
8050     ELSE
8060         RETurn ""
8070     END IF
8080 END DEFine LTrim$
8090 :
8100 :
8110 DEFine FuNction LTrim$(text$)
8120     LOCal x, ret$
8130     :
8140     IF text$ = "" THEN RETurn "": END IF
8150     :
8160     FOR x = 1 to LEN(text$)
8170         if text$(x) <> " " THEN EXIT x: END IF
8180     END FOR x
8190     ret$ = text$(x TO)
8200     if ret$ = " " then ret$ = "": end if
8210     return ret$
8220 END DEFine LTrim$
8230 :
8240 :
8250 DEFine FuNction RTrim$(text$)
8260     LOCal x, ret$
8270     :
8280     IF text$ = "" THEN RETurn "": END IF
8290     :
8300     FOR x = LEN(text$) TO 1 STEP -1
8310         if text$(x) <> " " THEN EXIT x: END IF
8320     END FOR x
8330     ret$ = text$(TO x)
8340     if ret$ = " " then ret$ = "": end if
8350     return ret$
8360 END DEFine RTrim$
8370 DEFine PROCedure centre(ch, text$)
8380     LOCal size, winSize
8390     :
8400     winSize = (300-2-2)/6
8410     size = len(text$)
8420     print #ch, to (winSize-size)/2; text$
8430 END DEF centre
8440 :
8450 :
8460 DEFine FuNction inString% (in$, stopHere)
8470   local x, Double%, Single%,quote$(1)
8480   Double% = 0: Single% = 0
8490   FOR x = 1 to stopHere
8500     REMark Check for double quotes.
8510     if in$(x) = '"' THEN
8520       if Double% = 1 then
8530         Double% = 0
8540       else
8550         Double% = 1
8560       end if
8570     else
8580       REMark Try single quotes.
8590       if in$(x) = "'" then
8600         if Single% = 1 then
8610           Single% = 0
8620         else
8630           Single% = 1
8640         end if
8650       end if
8660     end if
8670   END FOR x
8680 :
8690   REMark If Double% or Single% = 1 then
8700   REMark we opened a string before the
8710   REMark marker characters for REMark or
8720   REMark invisible REMark, so we return
8730   REMark true, else false.
8740   IF Double% + Single% = 0 THEN RETurn 0: END IF
8750   REMark Now look for the terminating quote
8760   IF Double% THEN 
8770     quote$ = '"'
8780   ELSE 
8790     quote$ = "'"
8800   END IF
8810   FOR x = stopHere TO LEN(in$)
8820     IF in$(x) = quote$ THEN RETurn x: END IF
8830   END FOR x
8840 END DEFine inString%
8850 DEFine FuNction stripTab$ (a$)
8860   LOCal x, loop
8870   IF a$ = "" THEN return a$: END IF
8880   REPeat loop
8890     x = CHR$(9) INSTR a$
8900     IF x = 0 THEN EXIT loop: END IF
8910     IF x = 1 THEN
8920        REMark SMSQ Bug workaround. See ssbpass2_ssb for details.
8930        a$ = " " & a$(2 TO)
8940        NEXT loop
8950     END IF
8960     a$ = a$(TO x-1) & " " & a$(x + 1 TO)
8970   END REPeat loop
8980   RETurn a$
8990 END DEFine stripTab$
9000 DEFine FuNction joinLine$(a$)
9010   LOCal in$(2048),out$(2048), joinLoop, temp
9020   :
9030   out$ = a$ 
9040   REPeat joinloop
9050     IF NOT out$(LEN(out$)-1 TO) = "\+" THEN EXIT joinLoop: END IF
9060     INPUT #file_num,in$
9070     temp = first_char(in$)
9080     out$ = rtrim$(out$(TO (LEN(out$)-2))) & " " & in$(temp TO)
9090   END REPeat joinloop
9100   RETurn out$
9110 END DEFine joinLine$
9120 DEFine FuNction stripComment$(a$)
9130   LOCal in$, out$, stripLoop, temp, whereQuote
9140   :
9150   in$ = a$
9160   out$ = ""  
9170   REMark Quick test for start of line.
9180   IF comm$ INSTR in$ = 1 THEN 
9190     RETURN out$
9200   END IF
9210   REPeat stripLoop
9220     temp = comm$ INSTR in$
9230     IF temp = 0 THEN
9240       out$ = out$ & in$
9250       EXIT stripLoop
9260     END IF
9270     REMark If not in a string, strip to the end.
9280     whereQuote = inString%(in$, temp)
9290     IF NOT whereQuote THEN
9300       out$ = out$ & in$(1 TO temp - 1)
9310       EXIT stripLoop
9320     END IF
9330     REMark Must be in a string, so extend out$ and try again.
9340     out$ = in$(1 to whereQuote)
9350     in$ = in$(whereQuote + 1 TO)
9360   END REPeat stripLoop
9370   RETurn out$
9380 END DEFine stripComment$
9390 DEFine FuNction doRemark$(a$)
9400   LOCal in$(2048), out$(2048), remarkLoop, temp
9410   :
9420   in$ = a$
9430   out$ = ""
9440   REMark Quick test for start of line.
9450   IF rem$ INSTR in$ = 1 THEN 
9460     RETURN "REMark" & in$(3 TO)
9470   END IF
9480   REPeat remarkLoop
9490     temp = rem$ INSTR in$
9500     IF temp = 0 THEN
9510       out$ = out$ & in$
9520       EXIT remarkLoop
9530     END IF
9540     REMark If not in a string, replace it & exit as 
9550     REMark anything after it is part of the REMark.
9560     whereQuote = inString%(in$, temp)
9570     IF NOT whereQuote THEN
9580       out$ = out$ & in$(TO temp - 1) & "REMark" & in$(temp + 2 TO)
9590       EXIT remarkLoop
9600     END IF
9610     REMark Must be in a string, so extend out$ and try again.
9620     out$ = out$ & in$(1 to whereQuote)
9630     in$ = in$(whereQuote + 1 TO)
9640   END REPeat remarkLoop
9650   RETurn out$
9660 END DEFine doRemark$
9670 DEFine FuNction first_char (a$)
9680    LOCal count
9690    count=0
9700    count=count+1
9710    IF count > LEN(a$) THEN RETurn 0
9720    IF a$(count)=" " THEN GO TO 9700
9730    RETurn count
9740 END DEFine first_char
9750 DEF FuNction upper$(up$)
9760     LOCal x, temp
9770     FOR x = 1 TO LEN(up$)
9780        temp = CODE(up$(x))
9790        IF temp > 96 AND temp < 123 THEN up$(x)=CHR$(temp-32)
9800     END FOR x
9810     RETURN up$
9820 END DEFine
9830 DEFine FuNCtion isnum (var$)
9840    LOCal x,y
9850    FOR x = 1 TO LEN(var$)
9860       y = CODE(var$(x))
9870       IF y < 48 OR y > 57 THEN RETURN 0
9880    END FOR x
9890    RETURN 1
9900 END DEFine isnum
9910 DEF PROCedure abort_out
9920 CLOSE #4
9930 IF OPTION_CMD$<>"" AND out_file$<>"" THEN DELETE out_file$
9940 IF file_num = 5 THEN
9950     CLOSE #5
9960 ELSE
9970     FOR x = 5 TO file_num
9980        CLOSE #x
9990     END FOR X
10000 END IF
10010 IF OPTION_CMD$<>"" THEN
10020     PRINT #3,""
10030     INK #3,7
10040     centre 3, lngarray$(20)
10050     temp$ = INKEY$(#3,-1)
10060 END IF
10070     CLOSE #3
10080     STOP
10090 END DEFine abort_out
