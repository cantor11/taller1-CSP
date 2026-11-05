% =============================================================================
% Taller 1 - Problema 2.6: Construccion de un Rectangulo
% Asignatura: Programacion por Restricciones
% Universidad del Valle
% =============================================================================

include "cumulative.mzn";

% -----------------------------------------------------------------------------
% 1. Lectura de Parametros (Datos de Entrada)
% -----------------------------------------------------------------------------
int: n;                    % Numero de cuadrados a ensamblar
array[1..n] of int: lado;  % Lado de cada cuadrado (ordenados de mayor a menor)
int: W;                    % Anchura total del rectangulo contenedor
int: H;                    % Altura total del rectangulo contenedor

% Banderas de configuracion del modelo (para pruebas de ablacion)
bool: usar_redundantes;    % true: activa restricciones globales cumulative en X e Y
bool: romper_simetrias;    % true: activa rompimiento de simetrias geometricas y de permutacion

% Validaciones de consistencia del archivo de datos (estilo 6.BakingCakes.mzn)
constraint assert(n > 0 /\ W > 0 /\ H > 0,
    "Archivo de datos invalido: n, W y H deben ser enteros positivos");
constraint assert(forall(i in 1..n)(lado[i] > 0 /\ lado[i] <= W /\ lado[i] <= H),
    "Archivo de datos invalido: algun cuadrado excede las dimensiones del rectangulo");
constraint assert(forall(i in 1..n-1)(lado[i] >= lado[i+1]),
    "Archivo de datos invalido: el arreglo 'lado' debe estar ordenado de mayor a menor");
constraint assert(sum(i in 1..n)(lado[i] * lado[i]) == W * H,
    "Archivo de datos invalido: la suma de areas de los cuadrados no coincide con W * H");

% -----------------------------------------------------------------------------
% 2. Variables de Decision y Dominios
% -----------------------------------------------------------------------------
int: max_x = W - min(lado);
int: max_y = H - min(lado);

% Coordenadas de la esquina inferior izquierda (x[i], y[i]) de cada cuadrado i
array[1..n] of var 0..max_x: x;
array[1..n] of var 0..max_y: y;

% -----------------------------------------------------------------------------
% 3. Predicados Auxiliares
% -----------------------------------------------------------------------------
% Predicado disyuntivo de no solapamiento 2D (basado en no_overlap de 7.jobshop2.mzn)
predicate no_solapar(var int: x1, int: l1, var int: y1,
                     var int: x2, int: l2, var int: y2) =
    x1 + l1 <= x2 \/ x2 + l2 <= x1 \/
    y1 + l1 <= y2 \/ y2 + l2 <= y1;

% -----------------------------------------------------------------------------
% 4. Restricciones Principales del Modelo
% -----------------------------------------------------------------------------

% 4.1. Contencion dentro de las fronteras del rectangulo W x H (dominio exacto)
constraint forall(i in 1..n)(
    x[i] <= W - lado[i] /\
    y[i] <= H - lado[i]
);

% 4.2. No solapamiento por pares entre cuadrados distintos
constraint forall(i, j in 1..n where i < j)(
    no_solapar(x[i], lado[i], y[i], x[j], lado[j], y[j])
);

% -----------------------------------------------------------------------------
% 5. Restricciones Redundantes
% -----------------------------------------------------------------------------
% Proyeccion de recursos acumulados sobre los ejes X e Y (estilo 6.moving.mzn):
% - En cualquier corte vertical x, la suma de alturas de los cuadrados activos no supera H.
% - En cualquier corte horizontal y, la suma de anchuras de los cuadrados activos no supera W.
constraint if usar_redundantes then
    cumulative(x, lado, lado, H) /\
    cumulative(y, lado, lado, W)
else
    true
endif;

% -----------------------------------------------------------------------------
% 6. Rompimiento de Simetrias
% -----------------------------------------------------------------------------
constraint if romper_simetrias then
    % 6.1. Simetria de permutacion entre cuadrados de igual tamano:
    % Se impone orden lexicografico estricto sobre (x[i], y[i]) cuando lado[i] == lado[i+1]
    forall(i in 1..n-1 where lado[i] == lado[i+1])(
        x[i] < x[i+1] \/ (x[i] == x[i+1] /\ y[i] < y[i+1])
    ) /\
    % 6.2. Simetrias geometricas del contenedor (reflexion horizontal, vertical y 180 grados):
    % Se restringe el centro del cuadrado mas grande (i = 1) al cuadrante inferior izquierdo
    2 * x[1] <= W - lado[1] /\
    2 * y[1] <= H - lado[1] /\
    % Si el contenedor es cuadrado (W == H), se rompe ademas la reflexion diagonal
    if W == H then x[1] <= y[1] else true endif
else
    true
endif;

% -----------------------------------------------------------------------------
% 7. Estrategia de Busqueda y Distribucion
% -----------------------------------------------------------------------------
% Arreglo intercalado [x[1], y[1], x[2], y[2], ..., x[n], y[n]] que aprovecha
% el orden decreciente de 'lado' para ubicar primero los cuadrados mas grandes
array[1..2*n] of var int: vars_xy = [
    if k mod 2 == 1 then x[(k + 1) div 2] else y[k div 2] endif
    | k in 1..2*n
];

% Estrategia seleccionada: input_order + indomain_min sobre vars_xy (Largest-Square-First, Bottom-Left)
% solve satisfy;
solve :: int_search(vars_xy, input_order, indomain_min, complete) satisfy;
% solve :: int_search(vars_xy, input_order, indomain_max, complete) satisfy;
% solve :: int_search(vars_xy, first_fail, indomain_min, complete) satisfy;
% solve :: seq_search([ int_search(x, first_fail, indomain_min, complete), int_search(y, first_fail, indomain_min, complete) ]) satisfy;
% solve :: int_search(vars_xy, dom_w_deg, indomain_split, complete) satisfy;

% -----------------------------------------------------------------------------
% 8. Impresion de la Solucion
% -----------------------------------------------------------------------------
output [
    "Dimensiones del rectangulo: W = \(W), H = \(H) (Area = \(W * H))\n"
] ++ [
    "Cuadrado " ++ show_int(2, i) ++ " (lado " ++ show(lado[i]) ++ "): " ++
    "x = " ++ show(x[i]) ++ ", y = " ++ show(y[i]) ++ "\n"
    | i in 1..n
] ++ [
    "\nMapa del rectangulo (indice del cuadrado en cada celda):\n"
] ++ [
    show_int(3, sum(i in 1..n)(
        if fix(x[i]) <= c /\ c < fix(x[i]) + lado[i] /\
           fix(y[i]) <= (H - 1 - r) /\ (H - 1 - r) < fix(y[i]) + lado[i]
        then i else 0 endif
    )) ++
    if c == W - 1 then "\n" else "" endif
    | r in 0..H-1, c in 0..W-1
];
