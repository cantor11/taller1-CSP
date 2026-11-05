% =============================================================================
% Taller 1 - Problema 2.2: Kakuro
% Asignatura: Programacion por Restricciones
% Universidad del Valle
% =============================================================================

include "alldifferent.mzn";

% -----------------------------------------------------------------------------
% 1. Lectura de Parametros (Datos de Entrada)
% -----------------------------------------------------------------------------
int: F; % Numero de filas del area jugable
int: C; % Numero de columnas del area jugable
int: num_h; % Numero de series (tramos) horizontales
int: num_v; % Numero de series (tramos) verticales

% Cada fila k de pistas_h: | fila, col_inicio, col_fin, suma_objetivo |
array[1..num_h, 1..4] of int: pistas_h;

% Cada fila m de pistas_v: | columna, fila_inicio, fila_fin, suma_objetivo |
array[1..num_v, 1..4] of int: pistas_v;

% Banderas de configuracion del modelo (para pruebas comparativas)
bool: usar_alldifferent; % true: usa alldifferent, false: usa desigualdades !=
bool: usar_redundantes;  % true: activa cotas combinatorias y suma total

% Validaciones de consistencia del archivo de datos (estilo 6.BakingCakes.mzn)
constraint assert(F > 0 /\ C > 0,
    "Archivo de datos invalido: las dimensiones F y C deben ser positivas");
constraint assert(num_h > 0 /\ num_v > 0,
    "Archivo de datos invalido: debe existir al menos una pista horizontal y vertical");
constraint assert(
    sum(k in 1..num_h)(pistas_h[k,4]) == sum(m in 1..num_v)(pistas_v[m,4]),
    "Archivo de datos invalido: la suma de pistas horizontales no coincide con las verticales"
);

% -----------------------------------------------------------------------------
% 2. Variables de Decision y Dominios
% -----------------------------------------------------------------------------
% Matriz del tablero: las casillas blancas toman valores en 1..9 y las negras se fijan en 0
array[1..F, 1..C] of var 0..9: tablero;

% Funcion auxiliar: determina si la celda (i, j) pertenece a algun tramo jugable
function bool: es_blanca(int: i, int: j) =
    exists(k in 1..num_h)(
        pistas_h[k,1] == i /\ j >= pistas_h[k,2] /\ j <= pistas_h[k,3]
    );

% Restriccion de dominio exacto: 1..9 para casillas blancas, 0 para casillas negras
constraint forall(i in 1..F, j in 1..C)(
    if es_blanca(i, j) then
        tablero[i,j] >= 1
    else
        tablero[i,j] = 0
    endif
);

% -----------------------------------------------------------------------------
% 3. Restricciones Principales del Modelo
% -----------------------------------------------------------------------------

% 3.1. Suma de cada serie horizontal igual a la pista indicada
constraint forall(k in 1..num_h)(
    sum(j in pistas_h[k,2]..pistas_h[k,3])(tablero[pistas_h[k,1], j]) = pistas_h[k,4]
);

% 3.2. Suma de cada serie vertical igual a la pista indicada
constraint forall(m in 1..num_v)(
    sum(i in pistas_v[m,2]..pistas_v[m,3])(tablero[i, pistas_v[m,1]]) = pistas_v[m,4]
);

% 3.3. No repeticion de digitos en cada serie horizontal y vertical
% Se implementan dos variantes comparables: global alldifferent vs desigualdades !=
constraint if usar_alldifferent then
    forall(k in 1..num_h)(
        alldifferent([ tablero[pistas_h[k,1], j] | j in pistas_h[k,2]..pistas_h[k,3] ])
    ) /\
    forall(m in 1..num_v)(
        alldifferent([ tablero[i, pistas_v[m,1]] | i in pistas_v[m,2]..pistas_v[m,3] ])
    )
else
    forall(k in 1..num_h)(
        forall(j1, j2 in pistas_h[k,2]..pistas_h[k,3] where j1 < j2)(
            tablero[pistas_h[k,1], j1] != tablero[pistas_h[k,1], j2]
        )
    ) /\
    forall(m in 1..num_v)(
        forall(i1, i2 in pistas_v[m,2]..pistas_v[m,3] where i1 < i2)(
            tablero[i1, pistas_v[m,1]] != tablero[i2, pistas_v[m,1]]
        )
    )
endif;

% -----------------------------------------------------------------------------
% 4. Restricciones Redundantes
% -----------------------------------------------------------------------------
% Cotas combinatorias de valor minimo y maximo en funcion de la longitud L del tramo
% y conservacion de la suma global de todas las celdas jugables.
constraint if usar_redundantes then
    forall(k in 1..num_h)(
        let {
            int: L = pistas_h[k,3] - pistas_h[k,2] + 1;
            int: S = pistas_h[k,4];
            int: min_otros = ((L - 1) * L) div 2;
            int: max_otros = ((L - 1) * (20 - L)) div 2;
        } in
        forall(j in pistas_h[k,2]..pistas_h[k,3])(
            tablero[pistas_h[k,1], j] <= S - min_otros /\
            tablero[pistas_h[k,1], j] >= S - max_otros
        )
    ) /\
    forall(m in 1..num_v)(
        let {
            int: L = pistas_v[m,3] - pistas_v[m,2] + 1;
            int: S = pistas_v[m,4];
            int: min_otros = ((L - 1) * L) div 2;
            int: max_otros = ((L - 1) * (20 - L)) div 2;
        } in
        forall(i in pistas_v[m,2]..pistas_v[m,3])(
            tablero[i, pistas_v[m,1]] <= S - min_otros /\
            tablero[i, pistas_v[m,1]] >= S - max_otros
        )
    ) /\
    sum(i in 1..F, j in 1..C)(tablero[i,j]) = sum(k in 1..num_h)(pistas_h[k,4])
else
    true
endif;

% -----------------------------------------------------------------------------
% 5. Estrategia de Busqueda y Distribucion
% -----------------------------------------------------------------------------
% Arreglo 1D unicamente con las variables de decision de casillas blancas
array[int] of var 1..9: vars_blancas = [
    tablero[i,j] | i in 1..F, j in 1..C where es_blanca(i, j)
];

% Estrategia seleccionada: first_fail + indomain_min (otras estrategias comentadas para pruebas)
% solve satisfy;
% solve :: int_search(vars_blancas, input_order, indomain_min, complete) satisfy;
solve :: int_search(vars_blancas, first_fail, indomain_min, complete) satisfy;
% solve :: int_search(vars_blancas, first_fail, indomain_split, complete) satisfy;
% solve :: int_search(vars_blancas, dom_w_deg, indomain_min, complete) satisfy;

% -----------------------------------------------------------------------------
% 6. Impresion de la Solucion
% -----------------------------------------------------------------------------
output [
    if fix(tablero[i,j]) == 0 then " . " else " " ++ show(tablero[i,j]) ++ " " endif ++
    if j == C then "\n" else "" endif
    | i in 1..F, j in 1..C
];
