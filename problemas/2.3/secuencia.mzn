% =============================================================================
% Taller 1 - Problema 2.3: Secuencia Mágica
% Juan Diego Cárdenas - 2416437
% Junior Cantor Arevalo - 2224949
% Cristian David Cabrera Pantoja - 2226285
% =============================================================================

include "globals.mzn";

% Lectura de Datos
int: n;
constraint assert(n >= 1, "Dato invalido: la longitud n debe ser mayor o igual a 1.");

% Conjunto de indices y valores posibles
set of int: INDICES = 0..n-1;

% Variables
array[INDICES] of var INDICES: x;

% Restricciones
% El entero i ocurre exactamente x[i] veces en x
constraint forall (i in INDICES) (
    count(x, i, x[i])
);

% Restricciones redundantes
% 1. La suma de frecuencias de aparicion iguala la longitud total de la secuencia
constraint sum (i in INDICES) (x[i]) = n;

% 2. Doble conteo de la suma de elementos: sum(i * x[i]) - sum(x[i]) = 0
constraint sum (i in INDICES) ((i - 1) * x[i]) = 0;

% Estrategia de búsqueda
% Alternativas evaluadas experimentalmente:
% solve satisfy;
% solve :: int_search(x, input_order, indomain_min, complete) satisfy;
% solve :: int_search(x, input_order, indomain_max, complete) satisfy;
% solve :: int_search(x, first_fail, indomain_max, complete) satisfy;
% solve :: int_search(x, first_fail, indomain_split, complete) satisfy;
% solve :: int_search(x, dom_w_deg, indomain_min, complete) satisfy;
solve :: int_search(x, first_fail, indomain_min, complete) satisfy;

% Salida
output [
    "x = \([x[i] | i in INDICES])\n"
];
