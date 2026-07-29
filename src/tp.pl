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

:- end_tests(tpIntegrador).
