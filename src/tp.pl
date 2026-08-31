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
    recuerdaHazaniaXmedio(Persona,Hazania,_,AnioConsulta).

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
    findall(Hazania, ciertoAnioHazania(AnioConsulta, Pueblo, Hazania), Hazanias),
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
    ciertoAnioPaginas(AnioConsulta, CantidadFinalMax, Pueblo),
    forall(
    (ciertoAnioPaginas(AnioConsulta, OtraCantidadFinal, OtroPueblo),OtroPueblo\=Pueblo),
    CantidadFinalMax>OtraCantidadFinal).

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
    forall((habitante(Persona,Pueblo,_,_),recuerda(Persona, Hazania, AnioConsulta)),
    not(corroborada(Hazania))).

ciertoAnioImportante(Pueblo,Hazania,AnioConsulta):-
    habitante(_,Pueblo,_,_),
    version_hazania(Hazania,_,_),
    forall((habitante(Persona,Pueblo,_,_), esta_vivo_en(Persona, AnioConsulta)), 
           recuerda(Persona, Hazania, AnioConsulta)).

ciertoAnioSinPrecedentes(Pueblo, AnioConsulta) :-
    ciertoAnioImportante(Pueblo, _, AnioConsulta),
    forall(
        ciertoAnioImportante(Pueblo, Hazania, AnioConsulta),
        (habitante(Persona, Pueblo, _, _), recuerdaHazaniaXmedio(Persona, Hazania, presencio, AnioConsulta))
    ).
% Punto 5)
%version_hazania(Hazania, Heroes, Lugar)

participaEnHazania(Persona,Hazania) :- 
    version_hazania(Hazania, Heroes, _),
    member(Persona,Heroes).

esUnHeroe(Persona) :-
    participaEnHazania(Persona,Hazania),
    once(conoce_hazania(_,Hazania,_,_)).

%conoce_hazania(Persona, Hazania, AnioConocido, Medio)     
insipiroAHeroe(Heroe,Inspirador) :-
    esUnHeroe(Heroe),
    conoce_hazania(Heroe,Hazania,_,_),
    participaEnHazania(Inspirador,Hazania),
    Heroe \= Inspirador.


cadenaDeInspiracion(Heroe,[Heroe,Siguiente|Resto]) :-
    esUnHeroe(Heroe),
    hacedorDeCadena(Heroe,[Heroe],[Siguiente|Resto]).

hacedorDeCadena(_, _, []).

hacedorDeCadena(Actual, Recorridos, [Siguiente|Resto]) :-
    % Usamos distinct directamente en vez de armar la lista y hacer member
    distinct(Siguiente, insipiroAHeroe(Siguiente, Actual)),
    
    not(member(Siguiente, Recorridos)),
    hacedorDeCadena(Siguiente, [Siguiente|Recorridos], Resto).



% Punto 6) Dream Team
subconjunto([], _).
subconjunto([X|Xs], [X|Ys]) :- subconjunto(Xs, Ys).
subconjunto(Xs, [_|Ys]) :- subconjunto(Xs, Ys).

dreamTeam(Equipo, Heroe) :-
    esUnHeroe(Heroe),
    cadenaDeInspiracion(_, Cadena),
    
    append(Antecesores, [Heroe|_], Cadena),
    
    subconjunto(SubAntecesores, Antecesores),
    SubAntecesores \= [],
    
    % Generamos el equipo combinando el héroe con los antecesores en cualquier orden
    mismosElementos([Heroe | SubAntecesores], Equipo).


% sacar(ElementoASacar, ListaOriginal, ListaQueSobra)
% auxiliar para sacar un elemento de la lista

% Caso 1: El elemento que quiero sacar es el primero de la lista
% Me sobra la Cola
sacar(Elemento, [Elemento | Cola], Cola).

% Caso 2: El elemento no es el primero. Lo dejo pasar (me guardo la Cabeza) 
% y lo mando a buscar y sacar en la Cola recursivamente.
sacar(Elemento, [Cabeza | Cola], [Cabeza | RestoCola]) :-
    sacar(Elemento, Cola, RestoCola).

%mismos elementos

% Caso base: Dos listas vacías tienen los mismos elementos.
mismosElementos([], []).

% Caso recursivo: 
mismosElementos(Lista1, [Cabeza2 | Cola2]) :-
    % Saco un elemento cualquiera de la Lista1 y lo pongo como Cabeza de la Lista2
    sacar(Cabeza2, Lista1, RestoLista1),
    % Repito el proceso con lo que sobró de la Lista1 y la Cola2
    mismosElementos(RestoLista1, Cola2).

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
    ciertoAnioPuebloLector(weise, 1400).

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


% Tests PUNTO 5
test("Alguien es considerado heroe si participo en al menos una hazania conocida", nondet):-
    esUnHeroe(frieren).

test("Alguien no es heroe si no participo en ninguna hazania conocida"):-
    not(esUnHeroe(wirbel)).

test("Un heroe inspira a otro si este ultimo conoce una hazania en la que el primero participo", nondet):-
    insipiroAHeroe(fern, frieren).

test("Nadie inspira a un personaje si este no conoce ninguna hazania"):-
    not(insipiroAHeroe(eisen, _)).

test("Una cadena de inspiracion es valida si cada heroe inspiro al siguiente en orden", nondet):-
    cadenaDeInspiracion(himmel, [himmel, fern, frieren, denken]).

test("Una cadena de inspiracion es invalida si algun heroe no inspiro al siguiente"):-
    not(cadenaDeInspiracion(denken, [denken, frieren])).

test("Una cadena de inspiracion es invalida si repite un heroe"):-
    not(cadenaDeInspiracion(frieren, [frieren, fern, frieren])).

% Tests PUNTO 6
test("Un equipo es un dream team valido si incluye al heroe y a alguien que estaba en la cadena antes que el", nondet):-
    dreamTeam([fern, himmel], fern).

test("Un dream team es valido sin importar el orden en el que se listen sus integrantes", nondet):-
    dreamTeam([himmel, fern], fern).

test("Un equipo no es un dream team valido si solo incluye al heroe y a nadie que estuviera antes en la cadena"):-
    not(dreamTeam([fern], fern)).

test("Un equipo no es un dream team valido si no incluye al heroe para el que se arma"):-
    not(dreamTeam([frieren], fern)).

test("Un equipo no es un dream team valido si incluye a alguien que nunca estuvo antes que el heroe en ninguna cadena"):-
    not(dreamTeam([fern, frieren, denken], fern)).

test("El mismo grupo de heroes puede ser un dream team valido para un heroe distinto", nondet):-
    dreamTeam([fern, frieren, denken], denken).

:- end_tests(tpIntegrador).
