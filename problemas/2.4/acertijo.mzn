% =============================================================================
% Taller 1 - Punto 2.4: Acertijo Logico
% Programacion por Restricciones - Universidad del Valle
% =============================================================================

include "alldifferent.mzn";

% Universo finito de edades posibles (Pista 5)
set of int: EDADES = 24..26;

% Variables de decision: cada variable representa la edad (24..26) del amigo
% asociado al atributo correspondiente. Los dominios iniciales excluyen a priori
% los valores imposibles deducibles de las pistas unarias y de orden estricto.

% Nombres de pila
var 25..26: Juan;      % Pista 1: mayor que Gonzalez (edad minima posible: 24)
var 25..25: Oscar;     % Pista 3: tiene exactamente 25 anos (C_3b en dominio)
var EDADES: Dario;

% Apellidos
var 24..25: Gonzalez;  % Pista 1: menor que Juan (edad maxima posible: 26)
var EDADES: Garcia;
var EDADES: Lopez;

% Generos musicales
var EDADES: Clasica;
var 25..26: Pop;       % Pista 2: el fan del pop no tiene 24 anos (C_2b en dominio)
var EDADES: Jazz;

% Agrupacion en tres arreglos unidimensionales por categoria y etiquetas de salida
array[1..3] of var EDADES: nombres   = [Juan, Oscar, Dario];
array[1..3] of var EDADES: apellidos = [Gonzalez, Garcia, Lopez];
array[1..3] of var EDADES: generos   = [Clasica, Pop, Jazz];

array[1..3] of string: etq_nombres   = ["Juan", "Oscar", "Dario"];
array[1..3] of string: etq_apellidos = ["Gonzalez", "Garcia", "Lopez"];
array[1..3] of string: etq_generos   = ["clasica", "pop", "jazz"];

% Vector consolidado de variables para la anotacion de busqueda
array[1..9] of var EDADES: vars = nombres ++ apellidos ++ generos;

% 1. Restricciones estructurales de biyeccion por categoria
constraint alldifferent(nombres);
constraint alldifferent(apellidos);
constraint alldifferent(generos);

% 2. Restricciones relacionales binarias activas derivadas de las pistas
% Pista 1: Juan es mas viejo que Gonzalez, a quien le gusta la musica clasica
constraint Juan > Gonzalez;
constraint Gonzalez = Clasica;

% Pista 2: El fan de la musica pop no es Garcia (Pop != 24 absorbida en dominio)
constraint Pop != Garcia;

% Pista 3: Oscar no se apellida Lopez (Oscar = 25 absorbida en dominio)
constraint Oscar != Lopez;

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

% Reconstruccion declarativa por comprension asociando cada nombre con su edad
output [
    etq_nombres[i] ++ " " ++
    concat([etq_apellidos[j] | j in 1..3 where fix(apellidos[j]) == fix(nombres[i])]) ++
    ": \(nombres[i]) anos, musica " ++
    concat([etq_generos[k] | k in 1..3 where fix(generos[k]) == fix(nombres[i])]) ++ "\n"
    | i in 1..3
];
