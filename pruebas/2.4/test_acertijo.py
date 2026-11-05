# =============================================================================
# Taller 1 - Punto 2.4: Suite de Pruebas Automatizadas (Acertijo Logico)
# Programacion por Restricciones - Universidad del Valle
# =============================================================================

from pathlib import Path
import re
import subprocess
import tempfile
import unittest

REPO_ROOT = Path(__file__).resolve().parents[2]
MODELO = REPO_ROOT / "problemas" / "2.4" / "acertijo.mzn"

SOLUCION_ESPERADA = {
    "Juan": ("Lopez", 26, "pop"),
    "Oscar": ("Garcia", 25, "jazz"),
    "Dario": ("Gonzalez", 24, "clasica"),
}


def ejecutar_minizinc(modelo: Path, solver: str, todas: bool = True) -> subprocess.CompletedProcess:
    bandera = "-a" if todas else "-n"
    cmd = ["minizinc", "--solver", solver]
    cmd += ["-a", "-s", str(modelo)] if todas else ["-n", "1", "-s", str(modelo)]
    return subprocess.run(cmd, capture_output=True, text=True, check=False)


def extraer_stat(texto: str, clave: str, defecto: int = 0) -> int:
    match = re.search(rf"%%%mzn-stat:\s*{clave}=(\d+)", texto)
    return int(match.group(1)) if match else defecto


def parsear_bloques_solucion(stdout: str) -> list[dict[str, tuple[str, int, str]]]:
    patron_linea = re.compile(r"^(Juan|Oscar|Dario)\s+(\w+):\s+(\d+)\s+anos,\s+musica\s+(\w+)$")
    soluciones = []
    actual: dict[str, tuple[str, int, str]] = {}
    for linea in stdout.splitlines():
        linea = linea.strip()
        if linea == "----------":
            if actual:
                soluciones.append(actual)
                actual = {}
            continue
        m = patron_linea.match(linea)
        if m:
            nombre, apellido, edad_str, musica = m.groups()
            actual[nombre] = (apellido, int(edad_str), musica)
    return soluciones


class TestAcertijoLogico(unittest.TestCase):
    def test_01_unicidad_exactitud_y_equivalencia_gecode_chuffed(self) -> None:
        self.assertTrue(MODELO.is_file(), f"No existe el modelo en {MODELO}")

        res_g = ejecutar_minizinc(MODELO, "gecode", todas=True)
        res_c = ejecutar_minizinc(MODELO, "chuffed", todas=True)

        self.assertEqual(res_g.returncode, 0, res_g.stderr)
        self.assertEqual(res_c.returncode, 0, res_c.stderr)

        sols_g = parsear_bloques_solucion(res_g.stdout)
        sols_c = parsear_bloques_solucion(res_c.stdout)

        self.assertEqual(len(sols_g), 1, "El acertijo debe tener exactamente 1 solucion en Gecode")
        self.assertEqual(sols_g, sols_c, "Discrepancia entre Gecode y Chuffed")
        self.assertEqual(sols_g[0], SOLUCION_ESPERADA)

        # Resolucion integra por propagacion en nodo raiz sin ramificar (Gecode)
        self.assertEqual(extraer_stat(res_g.stdout, "nodes"), 1)
        self.assertEqual(extraer_stat(res_g.stdout, "failures"), 0)
        self.assertEqual(extraer_stat(res_g.stdout, "peakDepth"), 0)
        self.assertEqual(extraer_stat(res_g.stdout, "propagations"), 9)

    def test_02_verificacion_independiente_de_las_5_pistas(self) -> None:
        res_g = ejecutar_minizinc(MODELO, "gecode", todas=True)
        sol = parsear_bloques_solucion(res_g.stdout)[0]

        apellidos = {sol[p][0] for p in sol}
        edades = {sol[p][1] for p in sol}
        generos = {sol[p][2] for p in sol}
        self.assertEqual(apellidos, {"Gonzalez", "Garcia", "Lopez"})
        self.assertEqual(edades, {24, 25, 26})
        self.assertEqual(generos, {"clasica", "pop", "jazz"})

        edad_gonzalez = next(edad for _, (ap, edad, _) in sol.items() if ap == "Gonzalez")
        musica_gonzalez = next(mus for _, (ap, _, mus) in sol.items() if ap == "Gonzalez")
        ap_pop, edad_pop = next((ap, edad) for _, (ap, edad, mus) in sol.items() if mus == "pop")

        # Pista 1: Juan es mas viejo que Gonzalez, a quien le gusta la musica clasica
        self.assertGreater(sol["Juan"][1], edad_gonzalez)
        self.assertEqual(musica_gonzalez, "clasica")
        # Pista 2: El fan del pop, que no es Garcia, no tiene 24
        self.assertNotEqual(ap_pop, "Garcia")
        self.assertNotEqual(edad_pop, 24)
        # Pista 3: Oscar, quien no es Lopez, tiene 25
        self.assertNotEqual(sol["Oscar"][0], "Lopez")
        self.assertEqual(sol["Oscar"][1], 25)
        # Pista 4: La musica favorita de Dario no es el jazz
        self.assertNotEqual(sol["Dario"][2], "jazz")
        # Pista 5: Edades entre 24 y 26
        self.assertTrue(all(24 <= sol[p][1] <= 26 for p in sol))

    def test_03_minimalidad_de_pistas_y_contradiccion(self) -> None:
        fuente_base = MODELO.read_text(encoding="utf-8")

        mutaciones = [
            ("sin_pista_2b", "var 25..26: Pop;", "var EDADES: Pop;", 2),
            ("sin_pista_4", "constraint Dario != Jazz;", "", 2),
            ("sin_pista_3a", "constraint Oscar != Lopez;", "", 2),
            ("sin_pista_2a", "constraint Pop != Garcia;", "", 2),
            (
                "contradictoria",
                "constraint Pop != Garcia;",
                "constraint Pop != Garcia;\nconstraint Pop = Garcia;",
                0,
            ),
        ]

        for nombre_caso, original, reemplazo, sol_esperadas in mutaciones:
            with self.subTest(caso=nombre_caso):
                self.assertIn(original, fuente_base)
                codigo = fuente_base.replace(original, reemplazo, 1)
                with tempfile.NamedTemporaryFile(
                    "w", suffix=".mzn", delete=False, encoding="utf-8"
                ) as tmp:
                    tmp.write(codigo)
                    ruta_tmp = Path(tmp.name)
                try:
                    res = ejecutar_minizinc(ruta_tmp, "gecode", todas=True)
                    self.assertEqual(res.returncode, 0, res.stderr)
                    if sol_esperadas == 0:
                        self.assertIn("UNSATISFIABLE", res.stdout)
                    else:
                        sols = parsear_bloques_solucion(res.stdout)
                        self.assertEqual(len(sols), sol_esperadas)
                finally:
                    ruta_tmp.unlink(missing_ok=True)


if __name__ == "__main__":
    unittest.main(verbosity=2)
