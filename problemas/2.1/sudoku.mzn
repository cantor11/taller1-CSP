%Modelado de problema de Sudoku
% Juan Diego Cárdenas - 2416437
% Junior Cantor Arevalo
% Cristian David Cabrera Pantoja

% Importaciones
include "globals.mzn";

% Párametros
array[1..9, 1..9] of 0..9: puzzle; % Arreglo de valores iniciales

%Variables
array[1..9, 1..9] of var 1..9: solution; % Arreglo 2D de valores de solución

% Restricciones
%Igualdad con puzzle base
constraint forall (i in 1..9, j in 1..9) (
  if puzzle[i, j] != 0 then
    solution[i, j ] = puzzle[i, j]
  else
    true
  endif
  ); 

%Diferencia con misma fila

constraint forall (i in 1..9) (
  all_different([solution[i, j] | j in 1..9])
);


% Implementación alternativa
/*
constraint forall(i in 1..9, j1, j2 in 1..9 where j1 < j2) (
  solution[i, j1] != solution[i, j2]
);
*/

%Diferencia con misma columna

constraint forall (j in 1..9) (
  all_different([solution[i, j] | i in 1..9])
);


% Implementación alternativa
/*
constraint forall(j in 1..9, i1, i2 in 1..9 where i1 < i2) (
  solution[i1, j] != solution[i2, j]
);
*/

%Diferencia en el mismo bloque

constraint forall (k in 0..2, l in 0..2) (
  all_different([solution [i + 3*k, j+ 3*l] | i in 1..3, j in 1..3])
);


%Implementación alternativa
/*
%Con restricciones redundantes
constraint forall (k, l in 0..2, i1,i2,j1,j2 in 1..3 where i1 < i2 \/ j1 < j2) (
  solution[i1 + 3*k,j1 + 3*l] != solution[i2 + 3*k,j2 + 3*l]
);
*/

/*
%Sin restricciones redundantes
constraint forall (k, l in 0..2, i1,i2,j1,j2 in 1..3 where (3*(i1 - 1) + j1) < (3*(i2 - 1) + j2)) (
  solution[i1 + 3*k,j1 + 3*l] != solution[i2 + 3*k,j2 + 3*l]
);
%*/

%Restricciones redundantes
% Sumas redundantes por Fila y Columna
constraint forall(i in 1..9) (
    sum(j in 1..9)(solution[i, j]) == 45 /\
    sum(j in 1..9)(solution[j, i]) == 45
);

% Suma redundante por Bloque 3x3
constraint forall(k, l in 0..2) (
    sum(i, j in 1..3)(solution[i + 3*k, j + 3*l]) == 45
);


%Estrategias de Búsqueda

%Búsqueda principiante
/*
solve :: int_search(
        solution,         
        input_order, 
        indomain_min, 
        complete) 
        satisfy;
*/
        
%Búsqueda intermedia
%/*
solve :: int_search(
        solution,         
        first_fail, 
        indomain_min, 
        complete) 
        satisfy;
%*/

%Búsqueda avanzada
/*
solve :: int_search(
        solution,         
        dom_w_deg, 
        indomain_random, 
        complete) 
        satisfy;
*/


%Output
output [
    show(solution[r, c]) ++ 
    (if c mod 3 == 0 /\ c < 9 then " | " else " " endif) ++
    (if c == 9 then "\n" else "" endif) ++
    (if c == 9 /\ r mod 3 == 0 /\ r < 9 then "------+-------+------\n" else "" endif)
    | r in 1..9, c in 1..9
];
  