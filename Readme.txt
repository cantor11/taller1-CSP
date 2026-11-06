========================================================================
TALLER 1: PROGRAMACIÓN POR RESTRICCIONES (CSP)
Escuela de Ingeniería de Sistemas y Computación
Universidad del Valle - 2026-II
========================================================================

PROFESOR:
  Robinson Duque

INTEGRANTES:
  - Juan Diego Cárdenas Mejía       - Código: 2416437
  - Junior Orlando Cantor Arevalo    - Código: 2224949
  - Cristian David Cabrera Pantoja   - Código: 2226285

========================================================================
1. DESCRIPCIÓN DE ARCHIVOS ENTREGADOS
========================================================================

A continuación se detalla el contenido y propósito de cada archivo
y carpeta incluidos en esta entrega:

- InformeTaller1.pdf:
    Documento final del informe en formato PDF, elaborado conforme a las
    directrices de la Sección 3.1 del enunciado. Contiene la formulación
    formal como CSP (variables, dominios, restricciones), justificación,
    detalles de implementación (restricciones redundantes, ruptura de
    simetrías, estrategias de búsqueda y anotaciones), análisis de
    árboles de búsqueda, batería de pruebas sistemáticas con tablas
    comparativas entre solvers (Gecode y Chuffed), y conclusiones.

- Readme.txt:
    Este archivo de texto plano, con la descripción de todos los archivos
    entregados y las instrucciones completas para su ejecución.

- problemas/:
    Carpeta con los modelos desarrollados en MiniZinc (.mzn), organizados
    modularmente por numeral:
      * problemas/2.1/sudoku.mzn:
          Modelo CSP parametrizado para la resolución de tableros Sudoku 9x9.
      * problemas/2.2/kakuro.mzn:
          Modelo CSP parametrizado para crucigramas numéricos Kakuro de
          dimensiones arbitrarias, con pistas horizontales y verticales.
      * problemas/2.3/secuencia.mzn:
          Modelo CSP parametrizado para el problema de la Secuencia Mágica,
          con restricciones redundantes de suma y producto escalar.
      * problemas/2.4/acertijo.mzn:
          Modelo CSP orientado a edades para el Acertijo Lógico de 5 personas,
          profesiones, estados civiles y actividades.
      * problemas/2.5/reunion.mzn:
          Modelo CSP para la asignación de posiciones y distanciamiento
          social en una fila para la foto de reunión.
      * problemas/2.6/rectangulo.mzn:
          Modelo CSP parametrizado para el empaquetamiento exacto de
          rectángulos a partir de un conjunto de cuadrados dados, con
          estrategias Largest-Square-First y Bottom-Left.

- datos/:
    Carpeta con las instancias de prueba (.dzn), organizadas por problema:
      * datos/2.1/sudoku.dzn:
          Instancia inicial del Sudoku extremadamente difícil ("Al Escargot").
      * datos/2.2/kakuro1.dzn, kakuro2.dzn, kakuro3.dzn:
          Instancias de prueba para Kakuro (tableros 5x4, 7x7 y 8x8).
      * datos/2.3/secuencia_n1.dzn a secuencia_n100.dzn:
          Batería de 12 instancias de evaluación para Secuencia Mágica:
          n in {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 50, 100}.
      * datos/2.5/reunion.dzn:
          Instancia con 8 personas, adyacencias, separaciones y distancias.
      * datos/2.6/rectangulo1.dzn, rectangulo2.dzn, rectangulo3.dzn:
          Instancias de prueba para Rectángulos (5x4 con 6 cuadrados,
          8x5 con 8 cuadrados y 10x7 con 9 cuadrados).

- pruebas/:
    Suites automatizadas de validación, equivalencia y registros de métricas:
      * pruebas/1-5/Tiempos_Pruebas.xlsx:
          Libro de cálculo con el registro sistemático de tiempos, nodos
          explorados, fallos y propagaciones para Sudoku y Reunión.
      * pruebas/2.3/test_secuencia.py:
          Script de pruebas automatizadas en Python para Secuencia Mágica
          evaluando solvers Gecode y Chuffed en las 12 instancias.
      * pruebas/2.4/test_acertijo.py:
          Script de pruebas automatizadas en Python para verificar la unicidad
          y corrección de la solución del Acertijo Lógico en Gecode y Chuffed.

========================================================================
2. REQUISITOS DEL SISTEMA
========================================================================

- MiniZinc: Versión 2.5.0 o superior (recomendado MiniZinc 2.8.x).
- Solvers: Gecode (incluido por defecto en MiniZinc) y Chuffed.
- Python: Versión 3.8 o superior (opcional, para ejecutar las suites
  de pruebas automatizadas de pruebas/2.3/ y pruebas/2.4/).

========================================================================
3. INSTRUCCIONES DE EJECUCIÓN
========================================================================

Todas las instrucciones se ejecutan desde la carpeta raíz de la entrega
mediante la línea de comandos (Terminal / PowerShell / CMD).

--- PUNTO 2.1: SUDOKU ---
Ejecutar con el solver Gecode e instancia por defecto:
  minizinc --solver gecode problemas/2.1/sudoku.mzn datos/2.1/sudoku.dzn

Para visualizar estadísticas de resolución (tiempo, nodos, fallos):
  minizinc --solver gecode -s problemas/2.1/sudoku.mzn datos/2.1/sudoku.dzn

--- PUNTO 2.2: KAKURO ---
Ejecución sobre las diferentes instancias disponibles:
  minizinc --solver gecode problemas/2.2/kakuro.mzn datos/2.2/kakuro1.dzn
  minizinc --solver gecode problemas/2.2/kakuro.mzn datos/2.2/kakuro2.dzn
  minizinc --solver gecode problemas/2.2/kakuro.mzn datos/2.2/kakuro3.dzn

--- PUNTO 2.3: SECUENCIA MÁGICA ---
Para encontrar una solución (ejemplo n=4):
  minizinc --solver gecode problemas/2.3/secuencia.mzn datos/2.3/secuencia_n4.dzn

Para enumerar todas las soluciones posibles (-a):
  minizinc --solver gecode -a problemas/2.3/secuencia.mzn datos/2.3/secuencia_n4.dzn

Para instancias grandes (ejemplo n=50 o n=100):
  minizinc --solver gecode problemas/2.3/secuencia.mzn datos/2.3/secuencia_n50.dzn
  minizinc --solver gecode problemas/2.3/secuencia.mzn datos/2.3/secuencia_n100.dzn

--- PUNTO 2.4: ACERTIJO LÓGICO ---
Este modelo está completamente autocontenido (no requiere archivo .dzn):
  minizinc --solver gecode problemas/2.4/acertijo.mzn

Para verificar que la solución encontrada es única (-a):
  minizinc --solver gecode -a problemas/2.4/acertijo.mzn

Con solver Chuffed:
  minizinc --solver chuffed -a problemas/2.4/acertijo.mzn

--- PUNTO 2.5: FOTO DE REUNIÓN ---
Ejecutar con la instancia de preferencias y distanciamiento:
  minizinc --solver gecode problemas/2.5/reunion.mzn datos/2.5/reunion.dzn

Con estadísticas de búsqueda:
  minizinc --solver gecode -s problemas/2.5/reunion.mzn datos/2.5/reunion.dzn

--- PUNTO 2.6: CONSTRUCCIÓN DE UN RECTÁNGULO ---
Ejecución sobre las tres instancias de prueba:
  minizinc --solver gecode problemas/2.6/rectangulo.mzn datos/2.6/rectangulo1.dzn
  minizinc --solver gecode problemas/2.6/rectangulo.mzn datos/2.6/rectangulo2.dzn
  minizinc --solver gecode problemas/2.6/rectangulo.mzn datos/2.6/rectangulo3.dzn

Para enumerar todas las orientaciones y soluciones simétricas (-a):
  minizinc --solver gecode -a problemas/2.6/rectangulo.mzn datos/2.6/rectangulo1.dzn

========================================================================
4. EJECUCIÓN DE PRUEBAS AUTOMATIZADAS (PYTHON)
========================================================================

Para ejecutar las baterías de verificación y equivalencia entre solvers:

  python pruebas/2.3/test_secuencia.py
  python pruebas/2.4/test_acertijo.py

========================================================================
