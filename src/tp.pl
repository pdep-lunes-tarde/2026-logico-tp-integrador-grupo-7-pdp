% PUNTO 1: LA GENTE

% a) modelar las personas

% habitante(Nombre, Pueblo, AnioNacimiento, Raza)
habitante(denken, auberst, 1290, humano).
habitante(voll, ende, 1200, enano).
habitante(serie, weise, 500, elfo).
habitante(fern, weise, 1370, humano).
habitante(stark, riegel, 1368, humano).
habitante(lawine, auberst, 1372, humano).
habitante(kanne, weise, 1365, humano).
habitante(wirbel, klares, 1350, humano).
habitante(lernen, auberst, 1315, humano).
habitante(frieren, weise, 100, elfo).
habitante(eisen, riegel, 1150, enano).

% esperanza_vida(Raza, AniosMaximos)
esperanza_vida(humano, 80).
esperanza_vida(enano, 350).

% b) Una persona esta viva
esta_vivo_en(Persona, AnioConsulta) :-
    habitante(Persona, _, Nacimiento, _),
    Nacimiento =< AnioConsulta,
    not(murio(Persona, AnioConsulta)).

% Si la raza no tiene esperanza_vida (como el elfo), esto falla (false).
% Y como falla, el not(murio(...)) de arriba da TRUE.
murio(Persona, AnioConsulta) :-
    habitante(Persona, _, Nacimiento, Raza),
    esperanza_vida(Raza, VidaMax),
    AnioConsulta - Nacimiento > VidaMax.


% PUNTO 2 y 3: LOS RECUERDOS Y CONMEMORACIONES
% ( las conmemoraciones estan ligadas con los recuerdos)

% recuerdo_original(Persona, Anio, Hazania, Heroes, Lugar, Medio).
recuerdo_original(wirbel, 1390, rescatar_hermana_wirbel, [stark, fern], klares, presencio).
recuerdo_original(frieren, 1390, rescatar_hermana_wirbel, [stark, fern], klares, presencio).
recuerdo_original(lawine, 1393, destruir_aura, [frieren], weise, escucho_cancion).
recuerdo_original(voll, 1400, destruir_aura, [denken], auberst, leyo_libro(50)).
recuerdo_original(serie, 1335, destruir_rey_demonio, [frieren, himmel, heiter, eisen], ende, leyo_libro(100)).
recuerdo_original(kanne, 1375, recuperar_gato_perdido, [himmel, frieren], weise, presencio).

% estatuas
duracion(marmol,30).
duracion(bronce,15).

% conmemoracion(Pueblo, Hazania, Heroes, Lugar, Medio).
conmemoracion(weise, destruir_rey_demonio, [frieren, himmel, heiter, eisen], ende, dia_festivo(1340)).
conmemoracion(auberst, destruir_rey_demonio, [frieren, himmel, heiter, eisen], ende, estatua(bronce, equipo_de_heroes, 1370, [1400, 1450])).
conmemoracion(auberst, destruir_schlat, [heroe_del_sur], ende, estatua(marmol, heroe_del_sur, 1340, [1410])).

recuerda_segun_medio(presencio, _, _).
recuerda_segun_medio(dia_festivo(_), _, _).

recuerda_segun_medio(escucho_cancion, AnioConocido, AnioConsulta) :- 
    AnioConsulta - AnioConocido =< 15.

recuerda_segun_medio(leyo_libro(Paginas), AnioConocido, AnioConsulta) :- 
    AnioConsulta - AnioConocido =< Paginas.

% Agrega a recuerda_segun_medio los valores para el punto 3b
recuerda_segun_medio(estatua(Material, _, AnioCreado, Mantenimientos), _, AnioConsulta) :-
    duracion(Material, VidaUtil),
    member(Anio, [AnioCreado|Mantenimientos]),
    AnioConsulta >= Anio,
    AnioConsulta - Anio =< VidaUtil.

% Auxiliar usado para obtener el año de comienzo y lo uso para extraer el añ{o} del medio
anio_comienzo_conmemoracion(dia_festivo(AnioComienzo), AnioComienzo).
anio_comienzo_conmemoracion(estatua(_, _, AnioCreado, _), AnioCreado).



% Caso 1: La conoce porque tiene un recuerdo original
conoce_hazania(Persona, Hazania, AnioConocido, Medio) :-
    recuerdo_original(Persona, AnioConocido, Hazania, _, _, Medio).

% Caso 2: La conoce porque su pueblo la conmemora
conoce_hazania(Persona, Hazania, AnioConocido, Medio) :-
    habitante(Persona, Pueblo, AnioNacimiento, _),
    conmemoracion(Pueblo, Hazania, _, _, Medio),
    anio_comienzo_conmemoracion(Medio, AnioComienzo),
    AnioConocido is max(AnioNacimiento, AnioComienzo).


recuerda(Persona, Hazania, AnioConsulta) :-
    esta_vivo_en(Persona, AnioConsulta),
    conoce_hazania(Persona, Hazania, AnioConocido, Medio),
    AnioConsulta >= AnioConocido,
    recuerda_segun_medio(Medio, AnioConocido, AnioConsulta).

paso_al_olvido(Hazania, AnioConsulta) :-
    version_hazania(Hazania, _, _),
    \+ recuerda(_, Hazania, AnioConsulta).


% Hazañas corroboradas 
% Para tener el universo de hazañas (las contadas o las conmemoradas)
version_hazania(Hazania, Heroes, Lugar) :-
    recuerdo_original(_, _, Hazania, Heroes, Lugar, _).
version_hazania(Hazania, Heroes, Lugar) :-
    conmemoracion(_, Hazania, Heroes, Lugar, _).

corroborada(Hazania) :-
    version_hazania(Hazania, _, _), % Ligamos la variable para inversibilidad
    not(multiples_versiones(Hazania)).

multiples_versiones(Hazania) :-
    version_hazania(Hazania, Heroes1, Lugar1),
    version_hazania(Hazania, Heroes2, Lugar2),
    (Heroes1 \= Heroes2 ; Lugar1 \= Lugar2).

% Parte 2

todasLasHazanias(Pueblo,AnioConsulta,HazaniasSinRepe):-
    findall(Hazania,(habitante(Persona,Pueblo,_,_),recuerda(Persona, Hazania, AnioConsulta)),Hazanias),
    list_to_set(Hazanias,HazaniasSinRepe).

recuerdaHazaniaXmedio(Persona,Hazania,Medio,AnioConsulta):-
    conoce_hazania(Persona,Hazania,AnioConocido,Medio),
    esta_vivo_en(Persona,AnioConsulta),
    AnioConsulta>=AnioConocido,
    recuerda_segun_medio(Medio,AnioConocido,AnioConsulta).

% Punto 4)

ciertoAnioHazania(AnioConsulta, Pueblo, Hazania):-
    habitante(Persona,Pueblo,_,_),
    recuerda(Persona, Hazania, AnioConsulta).

ciertoAnioPaginas(AnioConsulta, CantidadFinal, Pueblo):-
    habitante(_,Pueblo,_,_),
    findall(Paginas,(habitante(Persona,Pueblo,_,_),recuerdaHazaniaXmedio(Persona,_,leyo_libro(Paginas),AnioConsulta)), PaginasEnTotal),
    sum_list(PaginasEnTotal, CantidadFinal).

ciertoAnioPuebloLector(Pueblo, AnioConsulta):-
    findall(PaginasTotal,ciertoAnioPaginas(AnioConsulta,PaginasTotal,Pueblo), PaginasXPueblo),
    max_member(Maximo,PaginasXPueblo),
    Maximo>0,
    ciertoAnioPaginas(AnioConsulta,Maximo,Pueblo).

ciertoAnioMusical(Pueblo,AnioConsulta):-
    habitante(_,Pueblo,_,_),
    findall(HazaniaConMusica,(habitante(Persona,Pueblo,_,_),recuerdaHazaniaXmedio(Persona,HazaniaConMusica,escucho_cancion,AnioConsulta)),HazaniasMusicales),
    todasLasHazanias(Pueblo,AnioConsulta,Hazanias),
    list_to_set(HazaniasMusicales,SinRepeHazaniasMusicales),
    length(Hazanias, CantHazanias),
    length(SinRepeHazaniasMusicales, CantHazaniasMusicales),
    CantHazaniasMusicales>CantHazanias/2.

ciertoAnioChismosos(Pueblo,AnioConsulta):-
    habitante(_,Pueblo,_,_),
    todasLasHazanias(Pueblo,AnioConsulta,HazaniasSinRepe),
    forall(member(Hazania,HazaniasSinRepe),not(corroborada(Hazania))).

ciertoAnioImportante(Pueblo,Hazania,AnioConsulta):-
    habitante(_,Pueblo,_,_),
    version_hazania(Hazania,_,_),
    forall((habitante(Persona,Pueblo,_,_), esta_vivo_en(Persona, AnioConsulta)), 
           recuerda(Persona, Hazania, AnioConsulta)).

ciertoAnioSinPrecedentes(Pueblo,AnioConsulta):-
    todasLasHazanias(Pueblo,AnioConsulta,Hazanias),
    findall(HazaniaImportante,(member(HazaniaImportante,Hazanias),ciertoAnioImportante(Pueblo,HazaniaImportante,AnioConsulta)),HazaniasImportantes),
    list_to_set(HazaniasImportantes,SinRepeHazaniasImportantes),
    forall(member(HazaniaImportante1,SinRepeHazaniasImportantes),(habitante(Persona,Pueblo,_,_),recuerdaHazaniaXmedio(Persona,HazaniaImportante1,presencio,AnioConsulta))).


% Punto 5)
%version_hazania(Hazania, Heroes, Lugar)

participaEnHazania(Persona,Hazania) :- 
    version_hazania(Hazania, Heroes, _),
    member(Persona,Heroes).

%Queda a ver si agregar el año o no, esperar respuesta de Neme, debería solo modificar esUnHeroe y el resto de lógica seguir igual.
esUnHeroe(Persona) :-
    conoce_hazania(_,Hazania,_,_),
    participaEnHazania(Persona,Hazania).


%conoce_hazania(Persona, Hazania, AnioConocido, Medio)     
insipiroAHeroe(Heroe,Inspirador) :-
    esUnHeroe(Heroe),
    conoce_hazania(Heroe,Hazania,_,_),
    participaEnHazania(Inspirador,Hazania).

inspiradosPorHeroe(Heroe,InspiradosSinRepe) :-
    findall(Inspirado,insipiroAHeroe(Inspirado,Heroe),Inspirados),
    list_to_set(Inspirados,InspiradosSinRepe).

cadenaDeInspiracion(Heroe,[Heroe|Cadena]) :-
    esUnHeroe(Heroe),
    hacedorDeCadena(Heroe,[Heroe],Cadena).

hacedorDeCadena(_,_,[]).

hacedorDeCadena(Actual,Recorridos,[Siguiente|Resto]) :-
    inspiradosPorHeroe(Actual,Inspirados),
    member(Siguiente,Inspirados),
    not(member(Siguiente,Recorridos)),
    hacedorDeCadena(Siguiente,[Siguiente|Recorridos],Resto).

%Gente este punto lo termino mañana, digo para que no lo hagan al pedo.



%Tengo cadena de inspirados por el primer héroe, necesito descomponer la cadena de inspirados, y tomar eso como base para volver a consultar esto
%Para la parte de no repetir Fern → Frieren y Frieren → Fern quizas usar un not member()

%Quedan pendientes los test también, pero cuando termino el c los dejo.


:- begin_tests(tpIntegrador, []).

% Tests PUNTO 1
test("Una persona esta viva si el anio consultado esta dentro del rango de su esperanza de vida"):-
    esta_vivo_en(kanne, 1370).

test("Una persona no esta viva en un anio anterior a su nacimiento"):-
    not(esta_vivo_en(kanne, 1300)).

test("Una persona no esta viva si el anio consultado supera su esperanza de vida maxima"):-
    not(esta_vivo_en(kanne, 2000)).

test("Una persona sigue viva en el anio exacto en el que alcanza su limite de esperanza de vida"):-
    esta_vivo_en(voll, 1550).

test("Una persona ya no esta viva un anio despues de alcanzar el limite de su esperanza de vida"):-
    not(esta_vivo_en(voll, 1551)).

test("Una persona sin limite de esperanza de vida definido nunca muere de vejez", nondet):-
    esta_vivo_en(serie, 5000).

% Tests PUNTO 2
test("una persona no recuerda una hazania si aun no se entero de ella"):-
    not(recuerda(lawine, destruir_aura, 1380)).

test("una persona recuerda una hazania mientras no venza el plazo segun el medio por el que se entero", nondet):-
    recuerda(lawine, destruir_aura, 1400).

test("una persona deja de recordar una hazania conocida por una cancion pasados mas de 15 anios"):-
    not(recuerda(lawine, destruir_aura, 1410)).

test("una persona recuerda una hazania conocida por un libro mientras no pasen mas anios que paginas tenga", nondet):-
    recuerda(voll, destruir_aura, 1450).

test("una persona deja de recordar una hazania conocida por un libro pasados mas anios que paginas tenga"):-
    not(recuerda(voll, destruir_aura, 1460)).

test("una persona que presencio una hazania la recuerda mientras siga viva", nondet):-
    recuerda(wirbel, rescatar_hermana_wirbel, 1430).

test("una persona deja de recordar una hazania si ya no esta viva en ese anio"):-
    not(recuerda(wirbel, rescatar_hermana_wirbel, 1440)).

test("una hazania esta corroborada si todas sus versiones coinciden en heroes y lugar", nondet):-
    corroborada(rescatar_hermana_wirbel).

test("una hazania no esta corroborada si sus versiones difieren en heroes o en lugar"):-
    not(corroborada(destruir_aura)).

test("una hazania paso al olvido en un anio si nadie la recuerda en ese anio", nondet):-
    paso_al_olvido(destruir_aura, 1460).

test("una hazania no paso al olvido si alguien todavia la recuerda en ese anio"):-
    not(paso_al_olvido(destruir_aura, 1440)).

% Tests PUNTO 3
test("se recuerda una hazania si hay una estatua en buen estado en el pueblo donde alguien vive", nondet):-
    (recuerda(lawine, destruir_rey_demonio, 1400)).

test("no se recuerda una hazania si la estatua que lo conmemora esta en mal estado"):-
    not(recuerda(lawine, destruir_rey_demonio, 1390)).

test("se recuerda una hazania si hay un festival conmemorandolo que ya comenzo", nondet):-
    (recuerda(fern, destruir_rey_demonio, 1400)).

% Tests PUNTO 4
test("Un pueblo recuerda una hazania si al menos uno de sus habitantes la recuerda en ese anio", nondet):-
    ciertoAnioHazania(1400, weise, destruir_rey_demonio).

test("Un pueblo no recuerda una hazania si ninguno de sus habitantes la recuerda en ese anio"):-
    not(ciertoAnioHazania(1395, klares, destruir_rey_demonio)).

test("La cantidad de paginas leidas en un pueblo es la suma de los libros leidos por sus habitantes en ese anio", nondet):-
    ciertoAnioPaginas(1335, 100, weise).

test("Un pueblo es el mas lector si la suma de paginas leidas supera a la de cualquier otro pueblo", nondet):-
    ciertoAnioPuebloLector(ende, 1400).

test("Un pueblo es musical si mas de la mitad de las hazanias que recuerda provienen de canciones", nondet):-
    ciertoAnioMusical(auberst, 1395).

test("Un pueblo no es musical si las hazanias recordadas por canciones no superan la mitad del total"):-
    not(ciertoAnioMusical(weise, 1400)).

test("Un pueblo es chismoso si ninguna de las hazanias que recuerda esta corroborada", nondet):-
    ciertoAnioChismosos(ende, 1420).

test("Un pueblo no es chismoso si al menos una de las hazanias que recuerda esta corroborada"):-
    not(ciertoAnioChismosos(weise, 1400)).

test("Una hazania es importante para un pueblo si todos sus habitantes vivos en ese anio la recuerdan", nondet):-
    ciertoAnioImportante(weise, destruir_rey_demonio, 1400).
    
test("Una hazania no es importante para un pueblo si algun habitante vivo no la recuerda"):-
    not(ciertoAnioImportante(weise, recuperar_gato_perdido, 1400)).

test("Un pueblo vive tiempos sin precedentes si todas sus hazanias importantes fueron presenciadas por alguien de alli", nondet):-
    ciertoAnioSinPrecedentes(klares, 1395).

test("Un pueblo no vive tiempos sin precedentes si tiene hazanias importantes que nadie presencio"):-
    not(ciertoAnioSinPrecedentes(weise, 1400)).



:- end_tests(tpIntegrador).
