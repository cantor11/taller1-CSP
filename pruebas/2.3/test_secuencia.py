# =============================================================================
# Taller 1 - Punto 2.3: Suite de Pruebas Automatizadas (Secuencia Magica)
# Programacion por Restricciones - Universidad del Valle
# =============================================================================

from pathlib import Path
import re
import subprocess
import tempfile
import unittest

REPO_ROOT = Path(__file__).resolve().parents[2]
MODELO = REPO_ROOT / "problemas" / "2.3" / "secuencia.mzn"
DATOS_DIR = REPO_ROOT / "datos" / "2.3"

# Casos esperados: (n, num_soluciones, nodos_gecode, fallos_gecode)
# En n=1 y n=2 la inconsistencia se detecta en aplanamiento (0 nodos solver).
CASOS_DZN = [
    (1, 0, 0, 0),
    (2, 0, 0, 0),
    (3, 0, 0, 1),
    (4, 2, 5, 1),
    (5, 1, 5, 2),
    (6, 0, 7, 4),
    (7, 1, 7, 3),
    (10, 1, 11, 5),
    (15, 1, 17, 8),
    (20, 1, 21, 10),
    (50, 1, 51, 25),
    (100, 1, 101, 50),
]


def ejecutar_minizinc(modelo: Path, solver: str, extra_args: list[str]) -> subprocess.CompletedProcess:
    cmd = ["minizinc", "--solver", solver, "-a", "-s", str(modelo), *extra_args]
    return subprocess.run(cmd, capture_output=True, text=True, check=False)


def extraer_secuencias(stdout: str) -> list[list[int]]:
    secuencias = []
    for match in re.finditer(r"x\s*=\s*\[([0-9,\s]+)\]", stdout):
        valores = [int(v.strip()) for v in match.group(1).split(",") if v.strip()]
        secuencias.append(valores)
    return secuencias


def extraer_stat(texto: str, clave: str, defecto: int = 0) -> int:
    match = re.search(rf"%%%mzn-stat:\s*{clave}=(\d+)", texto)
    return int(match.group(1)) if match else defecto


def es_secuencia_magica_valida(sec: list[int], n: int) -> bool:
    if len(sec) != n:
        return False
    if any(v < 0 or v >= n for v in sec):
        return False
    for i in range(n):
        if sec.count(i) != sec[i]:
            return False
    return sum(sec) == n and sum((i - 1) * sec[i] for i in range(n)) == 0


class TestSecuenciaMagica(unittest.TestCase):
    def test_01_existencia_modelo_y_12_instancias_dzn(self) -> None:
        self.assertTrue(MODELO.is_file(), f"No existe el modelo en {MODELO}")
        for n, _, _, _ in CASOS_DZN:
            dzn = DATOS_DIR / f"secuencia_n{n}.dzn"
            self.assertTrue(dzn.is_file(), f"Falta archivo de prueba {dzn}")

    def test_02_asercion_parametro_invalido_n_menor_1(self) -> None:
        proc = ejecutar_minizinc(MODELO, "gecode", ["-D", "n=0;"])
        salida = (proc.stdout + proc.stderr).lower()
        self.assertNotEqual(proc.returncode, 0, "n=0 debe fallar por assert(n >= 1)")
        self.assertIn("assertion failed", salida)

    def test_03_bateria_completa_12_instancias_gecode_y_chuffed(self) -> None:
        for n, esp_sol, esp_nodos, esp_fallos in CASOS_DZN:
            with self.subTest(n=n):
                dzn = str(DATOS_DIR / f"secuencia_n{n}.dzn")
                res_g = ejecutar_minizinc(MODELO, "gecode", [dzn])
                res_c = ejecutar_minizinc(MODELO, "chuffed", [dzn])

                self.assertEqual(res_g.returncode, 0, res_g.stderr)
                self.assertEqual(res_c.returncode, 0, res_c.stderr)

                secs_g = sorted(extraer_secuencias(res_g.stdout))
                secs_c = sorted(extraer_secuencias(res_c.stdout))

                self.assertEqual(len(secs_g), esp_sol, f"Conteo erroneo en Gecode para n={n}")
                self.assertEqual(secs_g, secs_c, f"Discrepancia Gecode vs Chuffed en n={n}")

                if esp_sol == 0:
                    self.assertIn("UNSATISFIABLE", res_g.stdout)
                    self.assertIn("UNSATISFIABLE", res_c.stdout)

                for sec in secs_g:
                    self.assertTrue(
                        es_secuencia_magica_valida(sec, n),
                        f"Secuencia invalida en n={n}: {sec}",
                    )

                if n == 4:
                    self.assertEqual(secs_g, [[1, 2, 1, 0], [2, 0, 2, 0]])
                elif n == 5:
                    self.assertEqual(secs_g, [[2, 1, 2, 0, 0]])
                elif n >= 7:
                    esperada = [0] * n
                    esperada[0] = n - 4
                    esperada[1] = 2
                    esperada[2] = 1
                    esperada[n - 4] = 1
                    self.assertEqual(secs_g, [esperada])

                self.assertEqual(extraer_stat(res_g.stdout, "nodes"), esp_nodos)
                self.assertEqual(extraer_stat(res_g.stdout, "failures"), esp_fallos)

    def test_04_ablacion_restricciones_redundantes_y_poda(self) -> None:
        modelo_sin_redundantes = """
        include "globals.mzn";
        int: n;
        set of int: INDICES = 0..n-1;
        array[INDICES] of var INDICES: x;
        constraint forall (i in INDICES) (count(x, i, x[i]));
        solve :: int_search(x, first_fail, indomain_min, complete) satisfy;
        output ["x = \\([x[i] | i in INDICES])\\n"];
        """
        with tempfile.NamedTemporaryFile("w", suffix=".mzn", delete=False, encoding="utf-8") as tmp:
            tmp.write(modelo_sin_redundantes)
            ruta_m0 = Path(tmp.name)

        try:
            for n in (3, 4, 6, 10, 20):
                dzn = str(DATOS_DIR / f"secuencia_n{n}.dzn")
                r_m0 = ejecutar_minizinc(ruta_m0, "gecode", [dzn])
                r_m3 = ejecutar_minizinc(MODELO, "gecode", [dzn])

                self.assertEqual(
                    sorted(extraer_secuencias(r_m0.stdout)),
                    sorted(extraer_secuencias(r_m3.stdout)),
                    f"Las restricciones redundantes alteraron soluciones en n={n}",
                )
                nodos_m0 = extraer_stat(r_m0.stdout, "nodes")
                nodos_m3 = extraer_stat(r_m3.stdout, "nodes")
                self.assertLess(
                    nodos_m3,
                    nodos_m0,
                    f"Se esperaba poda estricta de nodos en n={n}: M3={nodos_m3} vs M0={nodos_m0}",
                )
        finally:
            ruta_m0.unlink(missing_ok=True)


if __name__ == "__main__":
    unittest.main(verbosity=2)
