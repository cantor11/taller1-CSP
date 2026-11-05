# Taller 1: Programación por Restricciones (CSP)

Proyecto del Taller 1 para la asignatura **Programación por Restricciones**, Escuela de Ingeniería de Sistemas y Computación, **Universidad del Valle**.

## Integrantes
- Cristian David Cabrera Pantoja
- Junior Orlando Cantor Arevalo
- Juan Diego Cárdenas Mejía

**Profesor:** Juan Francisco Díaz Frías

---

## Estructura del Repositorio

- `problemas/`: Modelos en MiniZinc organizados en subcarpetas por numeral del taller.
  - `2.3/secuencia.mzn`: Modelo CSP parametrizado para el problema de la Secuencia Mágica.
  - `2.4/acertijo.mzn`: Modelo CSP orientado a edades para el problema del Acertijo Lógico.
- `datos/`: Instancias de prueba `.dzn` organizadas por numeral de problema.
  - `2.3/secuencia_n*.dzn`: Batería de 12 instancias de evaluación para Secuencia Mágica ($n \in \{1, \dots, 100\}$).
- `pruebas/`: Suites automatizadas de validación, equivalencia entre solvers y pruebas de ablación.
  - `2.3/test_secuencia.py`: Pruebas automatizadas para Secuencia Mágica (`Gecode` y `Chuffed`).
  - `2.4/test_acertijo.py`: Pruebas automatizadas para Acertijo Lógico (`Gecode` y `Chuffed`).
- `Informe/`: Documento LaTeX del informe modularizado por problemas.
  - `main.tex`: Documento raíz con la portada, integrantes e índice.
  - `secciones/`: Archivos `.tex` independientes para cada uno de los 6 problemas y conclusiones.
  - `Imagenes/`: Carpeta para recursos gráficos, árboles de búsqueda, curvas experimentales y logo institucional.
- `Taller 1.pdf`: Enunciado oficial del taller.
- `GUIA_LATEX.md`: **Guía paso a paso de instalación, configuración y uso de LaTeX en Visual Studio Code.**
- `.vscode/settings.json`: Configuración para compilar con `pdflatex` y sincronización en vivo.

## Ejecución de Modelos y Pruebas

Desde la raíz del repositorio (`taller1-CSP/`):

```bash
# Punto 2.3: Secuencia Mágica (enumeración completa con instancia .dzn)
minizinc --solver gecode -a problemas/2.3/secuencia.mzn datos/2.3/secuencia_n4.dzn

# Punto 2.4: Acertijo Lógico (enumeración completa sin parámetros externos)
minizinc --solver gecode -a problemas/2.4/acertijo.mzn

# Ejecución de las suites de pruebas automatizadas (Gecode + Chuffed)
python pruebas/2.3/test_secuencia.py
python pruebas/2.4/test_acertijo.py
```

Para ver las instrucciones completas sobre cómo instalar MiKTeX, abrir la vista previa en vivo y compilar el documento, consulta [GUIA_LATEX.md](GUIA_LATEX.md).
