10 rem ******************************
20 rem Program 
30 rem autor:   
40 rem ******************************
1 ' Inicilizamos el juego'
50 cls:defint a-z: open"grp:"as#1
1 ' Cuando se pulse el disparo ir a la subrutina de la línea 1530'
60 'ON STRIG GOSUB 1530
1 ' Cuando haya colisión de sprites ir a la subrutina de la linea 1750'
70 'ON SPRITE GOSUB 1760



1 ' Cargamos el mapa en el array'
80 gosub 8000
1 ' cargamos mapa en array'
90 gosub 8210
1 ' mostramos el mapa'
100 gosub 8100
1 ' inicilizamos el personaje'
120 gosub 5000




1 ' <<<<<< Main loop >>>>>'
    1 ' Actualizamos el sistema de input'
    400 gosub 1260
    1 ' Esto es para mostrar datos para depurar'
    410 'gosub 1900
     1 ' Actualizamos el sistema de colisiones'
    420 gosub 1760
    1 ' Actualizamos sistema del render
    430 gosub 1400
500 goto 400 


1 ' <<<<<< Final del Main loop >>>>>'



1260 '' <<<< INPUT SYSTEM >>>>
    1270 ST=STICK(0) OR STICK(1) OR STICK(2)
    1280 TG=STRIG(0) OR STRIG(1) OR STRIG(2)
    1290 I$=INKEY$
    1 ' xp= posicion x previa player, yp=posición y previaplayer'
    1 ' Conservamos la posición previa para las colisiones'
    1300 xp=x:yp=y
    1 ' cp=columna previa y fp= fila previa para las colisiones'
    1310 'cp=x/8: fp=y/8
    1 ' actualizamos la información del cartel despues de presionar las teclas '
    1 ' pv=player velocidad, pp=plano player, pc= layer columna y pf=player fila'
    1320 IF ST=7 THEN x=x-pv:pp=1
    1330 IF ST=3 THEN x=x+pv:pp=2
    1340 IF ST=1 THEN y=y-pv:pp=0
    1350 IF ST=5 THEN y=y+pv:pp=3
    1 ' Colisones con los extremos de la pantalla'
    1370 if x<=0 then x=xp
    1380 if y<=0 then y=yp
    1385 if y+ph>176 then y=yp
    1390 if x+pw>252 then x=xp
1395 RETURN


1400 '' <<< RENDER SYSTEM >>>>
    1 ' Pintamos de nuevo el player con la posición, el color y el plano(dibujitos de izquierda, derecha..)'
    1420 PUT SPRITE 0,(x,y),2,pp
    1 ' Si el mapa cambia volvemos a pintar el mapa 8100 y ponemos al player en su posición inicial'
    1430 if mc then locate 0,19:gosub 8100:px=8:py=16
1440 return


1' '' <<< COLLISION SYSTEM >>>>
    1 ' Para detectar la colisión vemos el valor que hay en la tabla de nombres de la VRAM
    1 ' En la posición x e y de nuestro player con la formula: '
    1 ' Si hay una colision le dejamos la posicion que guardamos antes de cambiarla por pulsar una tecla'
    1760 hl=base(5)+(y/8)*32+(x/8):a=vpeek(hl)
    1 ' Si el valor es igual a 244 (nuestro ladrillo) ponemos los valores que tenía antes de pulsar el cursor'
    1810 if a=224 then x=xp: y=yp
    1 ' Si el valor es un 204 nuestro punto de fuga lo mandamos a otro sitio '
    1820 if a=204 then x=8*16: y=8*18:beep
    1 ' Si el valor el 215 (el tiled de la meta) cambiamos de mapa'
    1830 if a=215 then mc=1:ms=ms+1
1840 return


1 ' Debug'
1 'ponemos los valores que den -1 a 0 para que no de el array un error
    1900 'pc=x/8:pf=y/8
    1910 'if pc <0 then pc=0:if pf <0 then pf=0:if cp <0 then cp=0:if fp <0 then fp=0
    1920 hl=base(5)+(y/8)*32+(x/8):a=vpeek(hl)
    1930 locate 0,20: print "letra: "a
    1940 'locate 0,20: print "fp:"fp", cp:"cp",ar:"m(fp,cp,ms)"                  "
    1950 'locate 0,21: print "pf:"pf", pc:"pc",ar:"m(pf,pc,ms)"                  "
1960 return



1 '---------------------------------------------------------'
1 '------------------------PLAYER---------------------------'
1 '---------------------------------------------------------'

1 ' Inicializando el personaje'
    1 ' xp=pisicon x previa, utilizada en el sistema de input'
    1 ' yp= posicion y previa, utilizada en el sistema de input'
    1 ' pc=columna player identifica que columna está en el array el player para las colisiones (en este ejemplo no se utiliza)'
    1 ' pf= fila player identifica en que columna está el player para comprobar colisioens (en este ejemplo no se utiliza)'
    5000 x=8:y=16:xp=0:yp=0:pw=8:ph=8:pc=0:pf=0:pv=8
    5010 gosub 1400
5020 return







1 '---------------------------------------------------------'
1 '------------------------MAPA---------------------------'
1 '---------------------------------------------------------'


1 ' inicializar_mapa
    1 '## ms=mapa seleccioando, lo hiremos cambiando    
    1 ' mm= maximo de mapas, como hemos creado 2 levels ponemos mm=mapa maximo 2
    1 'mc= mapa cambia, lo utilizaremos para cambiar los copys y así cambiar la pantalla
    8000 ms=0:mm=3:mc=0:tn=-1
    1 ' 22 serán la filas y 32 las columnas menos uno, porque así son los arrays'
    8010 dim m(23,31,mm-1)
8020 return



1 ' Render map, pintar mapa
1 ' la pantalla en screen 1 con width son:
1 '      256px de ancho qu e/8=32 tiles de 8px 
1 '      176px de alto que /8= 22 tiles de 8px
    8100 cls:mc=0
    8110 if ms>=mm then ms=0
    8115 _TURBO ON (tn,m(),ms,mm)
    8120 for i=0 to mm-1
        8130 for f=0 to 21
        1 ' ahora leemos las columnas c
            8140 for c=0 to 31
                8150 tn= m(f,c,ms)
                1 ' Si el tile obtenido en el array es un cero ponemos un espacio'
                1 ' Es un lugar para pasar al siguiente nivel,el 215 es un tiled prediseñado'
                8160 if tn=0 then locate c, f:print chr$(215)
                1 ' Si lo que hay en el mapa es un ladrillo (un 1) pintamos el tiled 244'
                8165 if tn=1 then locate c, f:print chr$(224)
                1 ' Si el tile es un 2 es un punto de fuga'
                8170 if tn=2 then locate c, f:print chr$(204)
            8175 next c
        8180 next f
    8185 next i
    8190  _TURBO off
    8195 locate 0,0: print "Level "ms", espacio: "fre(0)
8200 return


1 'guardar_mapa_en_array
    1 ' 1 leemos los levels
    8210 for i=0 to mm-1
        1 ' ahora leemos las filas o la posición x
        8215 for f=0 to 21
        1 ' ahora leemos las columnas c o la posicion y
            8220 for c=0 to 31
                8230 read a$ 
                8240 m(f,c,i)=VAL(a$)
            8250 next c
        8260 next f
    8270 next i
8280 return




1 'Level 1'

10010 data -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,0,0,1
10020 data -1,-1,-1,-1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,1
10030 data 1,-1,-1,-1,1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,0,0,1
10040 data 1,-1,-1,1,1,1,1,-1,-1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
10050 data 1,-1,-1,1,-1,-1,1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,1
10060 data 1,-1,-1,1,-1,-1,1,-1,-1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,-1,-1,-1,-1,-1,1
10070 data 1,-1,-1,1,-1,-1,1,-1,-1,1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,1,-1,-1,1,-1,-1,1
10080 data 1,-1,-1,1,-1,-1,1,-1,-1,1,1,1,1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,1,-1,-1,1,-1,-1,1
10090 data 1,-1,-1,1,-1,-1,1,-1,-1,-1,-1,-1,1,-1,-1,1,1,1,1,1,1,1,1,-1,-1,1,-1,-1,1,-1,-1,1
10100 data 1,-1,-1,1,-1,-1,1,-1,-1,-1,-1,-1,1,-1,-1,-1,-1,-1,-1,-1,2,2,1,-1,-1,1,-1,-1,1,-1,-1,1
10110 data 1,-1,-1,1,-1,-1,1,1,1,1,-1,-1,1,-1,-1,-1,-1,-1,-1,-1,2,2,1,-1,-1,1,-1,-1,1,-1,-1,1
10120 data 1,-1,-1,-1,-1,-1,-1,-1,-1,1,-1,-1,1,1,1,1,1,1,1,1,1,1,1,-1,-1,1,-1,-1,1,-1,-1,1
10130 data 1,-1,-1,-1,-1,-1,-1,-1,-1,1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,1,-1,-1,1,-1,-1,1,-1,-1,1
10140 data 1,-1,-1,1,1,1,1,-1,-1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,-1,-1,1,-1,-1,1,-1,-1,1
10150 data 1,-1,-1,1,-1,-1,1,-1,-1,1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,1,-1,-1,1,-1,-1,1
10160 data 1,-1,-1,1,-1,-1,1,-1,-1,1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,1,-1,-1,1,-1,-1,1
10170 data 1,1,1,1,-1,-1,1,-1,-1,1,1,1,-1,-1,1,1,1,1,1,1,1,1,1,1,1,1,-1,-1,1,-1,-1,1
10180 data 1,-1,-1,-1,-1,-1,-1,-1,-1,1,-1,-1,-1,-1,1,2,2,-1,-1,1,-1,-1,-1,-1,-1,-1,-1,-1,1,-1,-1,1
10190 data 1,-1,-1,-1,-1,-1,-1,-1,-1,1,-1,-1,-1,-1,1,2,2,-1,-1,1,-1,-1,-1,-1,-1,-1,-1,-1,1,-1,-1,1
10200 data 1,-1,-1,1,1,1,1,1,1,1,-1,-1,1,1,1,1,1,-1,-1,1,1,1,1,1,1,1,1,1,1,-1,-1,1
10210 data 1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,1
10220 data 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1



1 ' Level 2'


10310 data -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
10320 data -1,-1,1,1,-1,-1,-1,-1,-1,-1,-1,1,-1,-1,-1,-1,-1,1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
10330 data -1,-1,-1,1,1,-1,-1,-1,-1,-1,-1,1,1,1,1,1,1,1,-1,1,1,1,1,-1,-1,-1,-1,-1,-1,-1,-1,-1
10340 data -1,-1,-1,-1,1,1,1,-1,-1,-1,1,1,1,-1,-1,-1,-1,-1,-1,-1,1,1,1,-1,-1,-1,-1,-1,-1,1,-1,-1
10350 data -1,-1,-1,-1,-1,-1,1,1,-1,1,1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,1,1,-1,-1,-1,1,1,-1,-1,-1
10360 data -1,-1,-1,-1,-1,-1,-1,-1,1,1,1,1,1,1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,1,1,1,-1,-1,-1,-1,-1
10370 data -1,-1,-1,-1,-1,-1,-1,1,1,-1,-1,-1,-1,1,1,1,1,1,1,1,1,1,1,-1,-1,1,1,-1,-1,-1,-1,-1
10380 data -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,1,-1,-1,-1,-1,-1,-1,-1,-1,-1,1,-1,-1,-1,-1,-1
10390 data -1,-1,-1,1,1,-1,1,1,-1,-1,-1,-1,2,2,-1,-1,1,-1,-1,2,2,-1,-1,-1,-1,-1,-1,1,1,1,1,-1
10400 data -1,-1,1,1,1,1,1,-1,-1,-1,-1,-1,-1,-1,-1,-1,1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,1,1,-1,1,-1
10410 data -1,-1,1,-1,1,1,-1,-1,1,1,1,1,1,1,-1,-1,1,-1,-1,1,1,1,1,1,1,1,1,-1,1,-1,1,-1
10420 data -1,-1,1,-1,1,-1,-1,-1,-1,-1,-1,-1,1,-1,-1,-1,1,-1,-1,-1,-1,1,-1,-1,-1,-1,-1,-1,1,-1,1,-1
10430 data -1,-1,1,1,1,-1,-1,-1,-1,-1,-1,-1,1,-1,-1,1,1,1,-1,-1,-1,1,-1,-1,-1,-1,-1,-1,1,1,1,-1
10440 data -1,-1,-1,1,-1,-1,-1,-1,-1,-1,-1,-1,1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,1,1,-1,-1
10450 data -1,-1,-1,1,-1,-1,-1,-1,-1,-1,-1,1,1,-1,-1,-1,-1,-1,-1,-1,-1,1,-1,-1,-1,-1,-1,-1,1,-1,-1,-1
10460 data -1,-1,-1,1,1,-1,-1,-1,-1,-1,-1,-1,1,1,-1,-1,-1,-1,-1,-1,1,1,-1,-1,-1,-1,-1,-1,1,-1,-1,-1
10470 data -1,-1,-1,-1,1,-1,-1,-1,-1,-1,-1,-1,-1,1,1,1,1,1,1,1,1,-1,-1,-1,-1,-1,-1,1,1,-1,-1,-1
10480 data -1,-1,-1,-1,1,1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,1,-1,-1,-1,-1
10490 data -1,-1,-1,-1,-1,1,1,1,-1,-1,-1,-1,-1,-1,-1,1,1,1,1,-1,-1,-1,-1,-1,-1,-1,1,1,-1,-1,-1,-1
10500 data -1,-1,-1,-1,-1,-1,-1,1,1,1,1,-1,-1,-1,-1,-1,-1,-1,1,-1,-1,-1,-1,-1,1,1,1,-1,-1,-1,-1,-1
10510 data -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,-1,-1,-1,-1,-1,-1,-1
10520 data -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,0,0,0


1 ' Level 3'
10610 data -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
10620 data -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
10630 data -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
10640 data -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
10650 data -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
10660 data -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
10670 data -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,1,1,1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
10680 data -1,-1,-1,-1,-1,-1,-1,-1,1,1,-1,-1,-1,-1,-1,-1,-1,1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
10690 data -1,-1,-1,-1,-1,-1,-1,-1,1,1,1,-1,-1,-1,-1,-1,-1,1,1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
10700 data -1,-1,-1,-1,-1,-1,-1,-1,1,-1,-1,1,1,1,1,1,1,1,1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
10710 data -1,-1,-1,-1,-1,-1,-1,-1,1,1,1,1,1,1,-1,-1,-1,-1,-1,1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
10720 data -1,-1,-1,-1,-1,1,1,1,1,-1,-1,-1,-1,1,1,1,1,-1,-1,1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
10730 data -1,-1,-1,-1,1,1,1,1,-1,-1,-1,-1,-1,-1,-1,-1,1,1,1,1,1,1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
10740 data -1,-1,-1,1,1,-1,-1,1,-1,-1,-1,-1,-1,-1,-1,-1,1,-1,-1,-1,1,1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
10750 data -1,-1,-1,1,1,-1,1,1,-1,-1,-1,-1,-1,-1,-1,-1,1,1,1,1,1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
10760 data -1,-1,-1,-1,1,1,1,-1,-1,-1,-1,-1,1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,1,-1,-1,-1
10770 data -1,-1,-1,-1,-1,1,1,1,-1,-1,-1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
10780 data -1,-1,1,1,1,1,-1,1,1,1,1,1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
10790 data -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
10800 data -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,0,0
10810 data -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0
10820 data -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0


1 'Level 4'
10920 data -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
10930 data -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
10940 data -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
10950 data -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
10960 data -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
10970 data -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
10980 data -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
10990 data -1,-1,-1,1,-1,-1,-1,-1,1,-1,-1,-1,1,-1,-1,-1,1,-1,-1,-1,-1,-1,1,1,1,1,1,1,-1,-1,-1,-1
11000 data -1,-1,-1,1,-1,-1,1,1,1,-1,-1,-1,1,-1,-1,-1,1,-1,1,1,1,-1,-1,1,1,-1,-1,-1,-1,-1,-1,-1
11010 data -1,-1,-1,1,-1,1,1,-1,-1,-1,-1,-1,1,-1,-1,-1,1,1,1,-1,-1,-1,-1,1,1,-1,-1,-1,-1,-1,-1,-1
11020 data -1,-1,-1,1,1,1,-1,-1,-1,-1,-1,-1,1,-1,-1,-1,1,1,1,-1,-1,-1,-1,1,1,1,1,1,-1,-1,-1,-1
11030 data -1,-1,-1,1,-1,1,1,-1,-1,-1,-1,-1,1,-1,-1,-1,1,-1,1,1,-1,-1,-1,1,1,-1,-1,-1,-1,-1,-1,-1
11040 data -1,-1,-1,1,-1,-1,1,1,-1,-1,-1,-1,1,-1,-1,-1,1,-1,-1,1,1,-1,-1,1,1,-1,-1,-1,-1,-1,-1,-1
11050 data -1,-1,-1,1,-1,-1,-1,1,1,-1,-1,-1,1,-1,-1,-1,1,-1,-1,-1,1,1,-1,1,1,-1,-1,-1,-1,-1,-1,-1
11060 data -1,-1,-1,1,-1,-1,-1,-1,1,-1,-1,-1,1,-1,-1,-1,1,-1,-1,-1,-1,1,-1,1,1,1,1,1,-1,-1,-1,-1
11070 data -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
11080 data -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
11090 data -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1
11100 data -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,-1,-1,-1,-1
11110 data -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,-1,-1,-1
11120 data -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,0,0,0,0,-1,-1,-1
11130 data -1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,0,0,0,0,0,-1,-1,-1,-1,-1