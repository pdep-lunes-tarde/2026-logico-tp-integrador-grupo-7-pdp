% ==========================================
% PUNTO 1: LA GENTE
% ==========================================


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
    habitante(Persona, _, Nacimiento, Raza),
    Nacimiento =< AnioConsulta,
    aun_no_murio(Nacimiento, Raza, AnioConsulta).

% pattern matching por raza
aun_no_murio(_, elfo, _). % Los elfos viven indefinidamente como dice en el enunciado
aun_no_murio(Nacimiento, Raza, AnioConsulta) :-
    Raza \= elfo, 
    esperanza_vida(Raza, VidaMax),
    AnioConsulta - Nacimiento =< VidaMax.


% ==========================================
% PUNTO 2 y 3: LOS RECUERDOS Y CONMEMORACIONES
% (Agrupados porque las conmemoraciones estan ligadas con los recuerdos)
% ==========================================

% recuerdo_original(Persona, Anio, Hazania, Heroes, Lugar, Medio).
recuerdo_original(wirbel, 1390, rescatar_hermana_wirbel, [stark, fern], klares, presencio).
recuerdo_original(frieren, 1390, rescatar_hermana_wirbel, [stark, fern], klares, presencio).
recuerdo_original(lawine, 1393, destruir_aura, [frieren], weise, escucho_cancion).
recuerdo_original(voll, 1400, destruir_aura, [denken], auberst, leyo_libro(50)).
recuerdo_original(serie, 1335, destruir_rey_demonio, [frieren, himmel, heiter, eisen], ende, leyo_libro(100)).
recuerdo_original(kanne, 1375, recuperar_gato_perdido, [himmel, frieren], weise, presencio).

% conmemoracion(Pueblo, Hazania, Heroes, Lugar, Medio).
conmemoracion(weise, destruir_rey_demonio, [frieren, himmel, heiter, eisen], ende, dia_festivo(1340)).
conmemoracion(auberst, destruir_rey_demonio, [frieren, himmel, heiter, eisen], ende, estatua(bronce, equipo_de_heroes, 1370, [1400, 1450])).
conmemoracion(auberst, destruir_schlat, [heroe_del_sur], ende, estatua(marmol, heroe_del_sur, 1340, [1410])).

recuerda_segun_medio(presencio, AnioConocido, AnioConsulta) :- AnioConsulta >= AnioConocido.
recuerda_segun_medio(escucho_cancion, AnioConocido, AnioConsulta) :- AnioConsulta >= AnioConocido, AnioConsulta - AnioConocido =< 15.
recuerda_segun_medio(leyo_libro(Paginas), AnioConocido, AnioConsulta) :- AnioConsulta >= AnioConocido, AnioConsulta - AnioConocido =< Paginas.

% Agrega a recuerda_segun_medio los valores para el punto 3b
recuerda_segun_medio(estatua(marmol,_,AnioCreado,Mantenimientos), AnioConocido, AnioConsulta) :- 
    AnioConsulta >= AnioConocido,
    member(Anio, [AnioCreado|Mantenimientos]),
    AnioConsulta >= Anio,
    AnioConsulta - Anio =< 30.
recuerda_segun_medio(estatua(bronce, _, AnioCreado, Mantenimientos), AnioConocido, AnioConsulta) :-
    AnioConsulta >= AnioConocido,
    member(Anio, [AnioCreado|Mantenimientos]),
    AnioConsulta >= Anio,
    AnioConsulta - Anio =< 15.
recuerda_segun_medio(dia_festivo(AnioFestejo), AnioConocido, AnioConsulta) :-
    AnioConsulta >= AnioConocido,
    AnioConsulta >= AnioFestejo.

% Auxiliar usado para obtener el año de comienzo y lo uso para extraer el añ{o} del medio
anio_comienzo_conmemoracion(dia_festivo(AnioComienzo), AnioComienzo).
anio_comienzo_conmemoracion(estatua(_, _, AnioCreado, _), AnioCreado).

recuerda(Persona, Hazania, AnioConsulta) :-
    habitante(Persona, Pueblo, AnioNacimiento, _),
    conmemoracion(Pueblo, Hazania, _, _, Medio),
    esta_vivo_en(Persona, AnioConsulta),
    anio_comienzo_conmemoracion(Medio, AnioComienzo),
    AnioConocido is max(AnioNacimiento, AnioComienzo), %Consulta si es ok esto o preferible usar la lógica de la aritmética y hacer un mayor a mano
    recuerda_segun_medio(Medio, AnioConocido, AnioConsulta).

recuerda(Persona, Hazania, AnioConsulta) :-
    recuerdo_original(Persona, AnioConocido, Hazania, _, _, Medio),
    esta_vivo_en(Persona, AnioConsulta),
    recuerda_segun_medio(Medio, AnioConocido, AnioConsulta).

paso_al_olvido(Hazania, AnioConsulta) :-
    version_hazania(Hazania, _, _),
    \+ recuerda(_, Hazania, AnioConsulta).

% ------------------------------------------
% Hazañas corroboradas 
% ------------------------------------------

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


















:- begin_tests(tpIntegrador, []).

test("Kanne es una humana nacida en 1365 y deberia estar viva en 1370"):-
    esta_vivo_en(kanne, 1370).

test("Kanne no esta viva en 1300, ya que todavia no habia nacido"):-
    not(esta_vivo_en(kanne, 1300)).

test("Kanne no esta vova en 2000, porque ya habria muerto"):-
    not(esta_vivo_en(kanne, 2000)).

test("Voll esta vivoen 1550 ya que nacio en 1200 y por ser enano vive 350 años"):-
    esta_vivo_en(voll, 1550).

test("Voll ya no esta vivo en 1551, debido a que los enanos no viven mas de 350 años"):-
    not(esta_vivo_en(voll, 1551)).

test("Serie esta viva en el año 5000 porque los elfos no mueren de viejos", nondet):-
    esta_vivo_en(serie, 5000).

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

test("se recuerda una hazania si hay una estatua en buen estado en el pueblo donde alguien vive", nondet):-
    (recuerda(lawine, destruir_rey_demonio, 1400)).
test("no se recuerda una hazania si la estatua que lo conmemora esta en mal estado"):-
    (\+ recuerda(lawine, destruir_rey_demonio, 1390)).
test("se recuerda una hazania si hay un festival conmemorandolo que ya comenzo", nondet):-
    (recuerda(fern, destruir_rey_demonio, 1400)).


:- end_tests(tpIntegrador).
