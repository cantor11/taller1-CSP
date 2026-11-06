% =============================================================================
% Taller 1 - Problema 2.5: Ubicación de personas en una reunión
% Juan Diego Cárdenas - 2416437
% Junior Cantor Arevalo - 2224949
% Cristian David Cabrera Pantoja - 2226285
% =============================================================================

include "globals.mzn";
include "circuit.mzn";
% Lectura de Datos
array[int] of string: personas; %Arreglo de personas de tamaño desconocido
array[int, 1..2] of 1..length(personas): next; %Arreglo 2D de condiciones Next
array[int, 1..2] of 1..length(personas): separate; %Arreglo 2D de condiciones Separate
array[int, 1..3] of 1..length(personas): distance; %Arreglo 2D de condiciones Distance
int: N = length(personas);

%/*
% ============ Instancia Base  ============
% Variables
array[index_set(personas)] of var 1..length(personas): posiciones; % Arreglo para representar posiciones de personas

% Restricciones

%Todas las posiciones diferentes
constraint all_different(posiciones);

%Next to:
constraint forall(i in index_set_1of2(next)) (
  abs(posiciones[next[i,1]] - posiciones[next[i,2]]) = 1
);

%Separate:
constraint forall(i in index_set_1of2(separate)) (
  abs(posiciones[separate[i,1]] - posiciones[separate[i,2]]) != 1
);

%Distances:
constraint forall(i in index_set_1of2(distance)) (
  abs(posiciones[distance[i,1]] - posiciones[distance[i,2]]) <= distance[i,3] + 1
);

  
% Restricciones redundantes

% Distancia mínima de separate
constraint forall(i in index_set_1of2(separate)) (
  abs(posiciones[separate[i,1]] - posiciones[separate[i,2]]) >= 2
);

% Preserva la suma constante de las posiciones
constraint sum(posiciones) = (N * (N + 1)) div 2;

% Rompimiento de simetrías
% La persona 1 siempre se ubica en la primera mitad de la fila.
constraint posiciones[1] < (N + 1) / 2;

% Estrategia de búsqueda
%Búsqueda sencilla
/*
solve :: int_search(
        posiciones,         
        first_fail, 
        indomain_min, 
        complete) 
        satisfy;
*/
        
%Búsqueda compleja

solve :: int_search(
        posiciones,         
        dom_w_deg, 
        indomain_split, 
        complete) 
        satisfy;

% Salida
output [
  "Posición en foto:\n"
] ++ [
  show(i) ++ ": " ++ [personas[p] | p in index_set(personas) where fix(posiciones[p]) == i][1] ++ "\n"
  | i in 1..length(personas)
];
%*/


/*
% =============== Implementación alternativa ===============
% Variables

% sig[A] es la persona que está inmediatamente a la derecha de A (0 si es el final de la fila)
array[0..N] of var 0..N: sig;

%Restricciones
%Circuito
constraint circuit(sig);
% Next to (A está inmediatamente antes que B OR B inmediatamente antes que A)
constraint forall(i in index_set_1of2(next)) (
  sig[next[i,1]] == next[i,2] \/ sig[next[i,2]] == next[i,1]
);

% Separate (A no puede ser sucesor directo de B ni viceversa)
constraint forall(i in index_set_1of2(separate)) (
  sig[separate[i,1]] != separate[i,2] /\ sig[separate[i,2]] != separate[i,1]
);

% Función recursiva/desplegada para verificar alcance en K pasos
predicate alcanzable(array[int] of var int: s, var int: actual, int: destino, int: pasos_restantes) =
  if pasos_restantes <= 0 \/ actual == 0 then
    false
  else
    s[actual] == destino \/ (s[actual] != 0 /\ alcanzable(s, s[actual], destino, pasos_restantes - 1))
  endif;
  
  % A y B están a distancia <= M + 1 si B es alcanzable desde A en <= (M+1) saltos (o al revés)
constraint forall(i in index_set_1of2(distance)) (
    alcanzable(sig, distance[i,1], distance[i,2], distance[i,3] + 1) \/ alcanzable(sig, distance[i,2], distance[i,1], distance[i,3] + 1)
  );
  
  % Ruptura de simetría universal en 'sig':
  % La persona que empieza la fila debe tener un ID menor que la persona que la termina.
  constraint sig[0] < sum(p in 1..N where sig[p] == 0) (p);
  
  
% Estrategia de búsqueda
%Búsqueda sencilla
/*
solve :: int_search(
        sig,         
        first_fail, 
        indomain_min, 
        complete) 
        satisfy;

        
%Búsqueda compleja

solve :: int_search(
        sig,         
        dom_w_deg, 
        indomain_split, 
        complete) 
        satisfy;


%Output

% Función recursiva: avanza por los sucesores hasta encontrar el nodo 0 (fin)
function array[int] of string: obtener_fila(array[int] of int: s, int: actual) =
  if s[actual] == 0 then
    []
  else
    [personas[s[actual]]] ++ obtener_fila(s, s[actual])
  endif;
 

output [
  "Vector sig crudo: ", show(sig), "\n",
  "Primera persona:  ", show(personas[fix(sig[0])]), "\n",
  "Fila ordenada:    ", show(obtener_fila(fix(sig), 0)), "\n"
];
*/
