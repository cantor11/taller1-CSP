% =============================================================================
% Taller 1 - Punto 2.4: Acertijo Logico
% Programacion por Restricciones - Universidad del Valle
% =============================================================================

include "alldifferent.mzn";

% Variables de decision: cada variable representa la edad (24..26) del amigo
% asociado al atributo correspondiente. Los dominios iniciales excluyen valores
% imposibles de entrada segun las pistas unarias y de orden estricto.

% Nombres
var 25..26: Juan;      % Pista 1: mayor que Gonzalez (edad minima posible: 24)
var 25..25: Oscar;     % Pista 3: tiene exactamente 25 anos
var 24..26: Dario;

% Apellidos
var 24..25: Gonzalez;  % Pista 1: menor que Juan (edad maxima posible: 26)
var 24..26: Garcia;
var 24..26: Lopez;

% Generos musicales
var 24..26: Clasica;
var 25..26: Pop;       % Pista 2: el fan del pop no tiene 24 anos
var 24..26: Jazz;

% Arreglo consolidado de variables para la anotacion de busqueda
array[1..9] of var 24..26: vars = [
    Juan, Oscar, Dario,
    Gonzalez, Garcia, Lopez,
    Clasica, Pop, Jazz
];

% Restricciones de biyeccion por categoria (edades, apellidos y gustos distintos)
constraint alldifferent([Juan, Oscar, Dario]);
constraint alldifferent([Gonzalez, Garcia, Lopez]);
constraint alldifferent([Clasica, Pop, Jazz]);

% Pista 1: Juan es mas viejo que Gonzalez, a quien le gusta la musica clasica
constraint Juan > Gonzalez;
constraint Gonzalez = Clasica;

% Pista 2: El fan de la musica pop, que no es Garcia, no tiene 24
constraint Pop != Garcia;
constraint Pop != 24;

% Pista 3: Oscar, quien no es Lopez, tiene 25
constraint Oscar != Lopez;
constraint Oscar = 25;

% Pista 4: La musica favorita de Dario no es el jazz
constraint Dario != Jazz;

% Estrategia de busqueda y distribucion
% Alternativas evaluadas experimentalmente:
% solve satisfy;
% solve :: int_search(vars, input_order, indomain_min, complete) satisfy;
% solve :: int_search(vars, input_order, indomain_max, complete) satisfy;
% solve :: int_search(vars, first_fail, indomain_max, complete) satisfy;
% solve :: int_search(vars, first_fail, indomain_split, complete) satisfy;
% solve :: int_search(vars, dom_w_deg, indomain_min, complete) satisfy;
solve :: int_search(vars, first_fail, indomain_min, complete) satisfy;

% Salida estructurada: nombre completo, edad y genero musical de cada amigo
output [
    "Juan " ++
    if fix(Juan) == fix(Gonzalez) then "Gonzalez"
    elseif fix(Juan) == fix(Garcia) then "Garcia"
    else "Lopez" endif ++
    ": \(Juan) anos, musica " ++
    if fix(Juan) == fix(Clasica) then "clasica"
    elseif fix(Juan) == fix(Pop) then "pop"
    else "jazz" endif ++ "\n",

    "Oscar " ++
    if fix(Oscar) == fix(Gonzalez) then "Gonzalez"
    elseif fix(Oscar) == fix(Garcia) then "Garcia"
    else "Lopez" endif ++
    ": \(Oscar) anos, musica " ++
    if fix(Oscar) == fix(Clasica) then "clasica"
    elseif fix(Oscar) == fix(Pop) then "pop"
    else "jazz" endif ++ "\n",

    "Dario " ++
    if fix(Dario) == fix(Gonzalez) then "Gonzalez"
    elseif fix(Dario) == fix(Garcia) then "Garcia"
    else "Lopez" endif ++
    ": \(Dario) anos, musica " ++
    if fix(Dario) == fix(Clasica) then "clasica"
    elseif fix(Dario) == fix(Pop) then "pop"
    else "jazz" endif ++ "\n"
];
