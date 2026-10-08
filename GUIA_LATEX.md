# Guía de Instalación y Uso de LaTeX — Taller 1 (CSP)

Esta guía explica los requisitos, la instalación y el flujo de trabajo para colaborar en el informe del **Taller 1: Programación por Restricciones (CSP)** utilizando **LaTeX Workshop** en **Antigravity IDE** o **VS Code**.

---

## 1. Requisitos Previos

Para trabajar en el informe localmente se requieren tres componentes:

1. **Editor de Código:** [Antigravity IDE](https://antigravity.google) o [Visual Studio Code](https://code.visualstudio.com/).
2. **Extensión:** **LaTeX Workshop** (desarrollada por *James-Yu*), disponible en el Marketplace de extensiones (`Ctrl + Shift + X`).
3. **Distribución de LaTeX (Compilador):**
   - **Windows:** [MiKTeX](https://miktex.org/download) *(Recomendado)*.
   - **Linux / macOS:** TeX Live / MacTeX.

---

## 2. Instalación y Configuración de MiKTeX (Windows)

Si aún no tienes MiKTeX instalado:

1. Descarga el instalador desde [miktex.org/download](https://miktex.org/download).
2. Durante la instalación, en la opción **"Install missing packages on-the-fly"**, selecciona **Yes** (para que descargue automáticamente librerías faltantes sin detenerse a preguntar).
3. Una vez finalizada la instalación:
   - Abre **MiKTeX Console** desde el menú de inicio de Windows.
   - Ve a **Settings** y asegúrate de que *You can configure whether missing packages are installed on-the-fly* esté en **"Always"**.
   - Haz clic en **Updates** -> **Check for updates** para tener los paquetes actualizados.
4. **Importante:** Cierra por completo y vuelve a abrir tu editor (Antigravity IDE o VS Code) para que reconozca las variables de entorno del sistema (`PATH`).

---

## 3. Estructura del Proyecto

El informe está organizado de forma modular para que varios integrantes puedan trabajar al mismo tiempo sin generar conflictos de Git:

```text
taller1-CSP/
├── .vscode/
│   └── settings.json          # Configuración de compilación con pdflatex y rutas
├── Informe/
│   ├── main.tex               # Archivo raíz principal (portada, índice e imports)
│   ├── main.pdf               # PDF compilado resultante
│   ├── Imagenes/
│   │   └── logoUV.jpg         # Imágenes, diagramas y logos
│   └── secciones/             # Subarchivos modulares por problema
│       ├── 01_sudoku.tex
│       ├── 02_kakuro.tex
│       ├── 03_secuencia_magica.tex
│       ├── 04_acertijo_logico.tex
│       ├── 05_reunion.tex
│       ├── 06_rectangulo.tex
│       └── 07_conclusiones.tex
├── Taller 1.pdf               # Enunciado oficial del taller
├── GUIA_LATEX.md              # Esta guía
└── .gitignore                 # Ignora archivos temporales (.aux, .log, .synctex.gz)
```

---

## 4. Cómo Visualizar y Compilar el Documento

### 4.1. Abrir la Vista Previa en Vivo (Side-by-Side)
1. Abre el archivo `Informe/main.tex` o cualquiera de los archivos en `Informe/secciones/`.
2. Presiona:
   - **Atajo:** <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>V</kbd>
   - O haz clic en el icono de **"View LaTeX PDF"** (la lupa/icono de PDF en la esquina superior derecha del editor) y selecciona **"View in VSCode tab"**.
3. Se abrirá una pestaña a la derecha con el PDF.

### 4.2. Compilar Cambios
- **Al guardar:** Cada vez que pulses <kbd>Ctrl</kbd> + <kbd>S</kbd> en cualquier archivo `.tex`, LaTeX Workshop recompilará automáticamente el proyecto en 1 o 2 segundos y el visor de PDF se actualizará solo.
- **Compilación manual:** Puedes forzar la compilación en cualquier momento con el atajo <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>B</kbd>.

### 4.3. Navegación Rápida (SyncTeX)
- **Del código al PDF:** Ubica el cursor en un párrafo de tu archivo `.tex` y presiona <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>J</kbd>. El visor resaltará esa posición exacta en el PDF.
- **Del PDF al código:** En el visor de la derecha, presiona <kbd>Ctrl</kbd> + **Clic izquierdo** sobre cualquier texto del PDF para saltar a su línea de código correspondiente en el editor.

---

## 5. Guía de Trabajo para los Integrantes

### 5.1. ¿Cómo editar tu sección asignada?
1. **No toques `main.tex`** salvo que vayas a cambiar datos generales de la portada.
2. Abre únicamente tu archivo correspondiente dentro de `Informe/secciones/` (ej. `01_sudoku.tex`).
3. En la primera línea de cada archivo encontrarás la directiva mágica:
   ```latex
   % !TEX root = ../main.tex
   ```
   *No borres esta línea.* Le indica a la extensión que al guardar ese archivo hijo debe compilar el documento completo `main.tex`.

### 5.2. ¿Cómo agregar imágenes?
1. Guarda la imagen en la carpeta `Informe/Imagenes/` (ej: `grafo.png`).
2. En tu archivo de sección, insértala así:
   ```latex
   \begin{figure}[htbp]
       \centering
       \includegraphics[width=0.7\textwidth]{grafo.png}
       \caption{Árbol de búsqueda para la instancia 1.}
       \label{fig:arbol_instancia1}
   \end{figure}
   ```
   *(Nota: Gracias al comando `\graphicspath{{Imagenes/}}` en el preámbulo, no es necesario escribir toda la ruta).*

### 5.3. ¿Cómo agregar tablas de resultados?
En cada sección ya tienes una plantilla con `booktabs`. Puedes replicarla así:
```latex
\begin{table}[htbp]
    \centering
    \begin{tabular}{lcccc}
        \toprule
        Instancia & Estrategia & Tiempo (s) & Nodos explorados & Fallos \\
        \midrule
        Instancia 1 & Default & 0.04 & 120 & 15 \\
        Instancia 1 & first\_fail & 0.01 & 45 & 2 \\
        \bottomrule
    \end{tabular}
    \caption{Comparación experimental de heurísticas.}
    \label{tab:mi_tabla}
\end{table}
```

---

## 6. Solución de Problemas Comunes (Troubleshooting)

### Error 1: `"latexmk" no se reconoce como un comando...`
- **Causa:** LaTeX Workshop intenta usar por defecto `latexmk`, que requiere Perl.
- **Solución:** Ya está corregido en `.vscode/settings.json`, el cual fuerza el uso de `pdflatex` directamente. Si trabajas en otra computadora, asegúrate de tener la carpeta `.vscode/` en el proyecto.

### Error 2: `Cannot find LaTeX root file`
- **Causa:** Ocurre si intentas compilar mientras la pestaña enfocada en el editor es la terminal, un archivo no `.tex`, o la pestaña de registros (*LaTeX Workshop Output*).
- **Solución:** Haz clic sobre tu archivo `.tex` antes de presionar <kbd>Ctrl</kbd> + <kbd>S</kbd> o <kbd>Ctrl</kbd> + <kbd>Alt</kbd> + <kbd>B</kbd>.

### Error 3: Paquetes faltantes al compilar por primera vez
- **Causa:** MiKTeX no tiene instalados algunos paquetes que agregaste.
- **Solución:** Abre **MiKTeX Console** -> **Settings** -> fija **"Always install missing packages on-the-fly"**.

### Error 4: Error de codificación en bloques de código (`listings`)
- **Causa:** Al colocar tildes directas (`á, é, í...`) dentro de bloques `\begin{lstlisting}`, LaTeX puede arrojar `Invalid UTF-8 byte sequence`.
- **Solución:** En comentarios dentro del bloque de código evita tildes o caracteres especiales directos si notas fallos, o define el soporte en el `literate` de `lstset`.
