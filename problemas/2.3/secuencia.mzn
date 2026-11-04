% =============================================================================
% Taller 1 - Punto 2.3: Secuencia Magica
% Programacion por Restricciones - Universidad del Valle
% =============================================================================

include "globals.mzn";

% Lectura de datos
int: n;
constraint assert(n >= 1, "Dato invalido: la longitud n debe ser mayor o igual a 1.");

% Conjunto de indices y valores posibles
set of int: INDICES = 0..n-1;

% Variables de decision
array[INDICES] of var INDICES: x;

% Restricciones primarias: el entero i ocurre exactamente x[i] veces en x
constraint forall (i in INDICES) (
    count(x, i, x[i])
);

% Restricciones redundantes para poda del arbol de busqueda
% 1. La suma de frecuencias de aparicion iguala la longitud total de la secuencia
constraint sum (i in INDICES) (x[i]) = n;

% 2. Doble conteo de la suma de elementos: sum(i * x[i]) - sum(x[i]) = 0
constraint sum (i in INDICES) ((i - 1) * x[i]) = 0;

% Estrategia de busqueda y distribucion
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
