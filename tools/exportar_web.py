"""Verifica o módulo instalado e tenta compilar HTML5. Nunca publica o jogo."""
from pathlib import Path
from datetime import datetime
import argparse
import os
import subprocess
import sys
import zipfile
import shutil

root = Path(__file__).resolve().parents[1]
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--runtime', type=Path, default=Path(os.environ.get('PROGRAMDATA', r'C:\ProgramData'))/'GameMakerStudio2-LTS2026/Cache/runtimes/runtime-2026.0.0.23')
parser.add_argument('--usuario-runtime', type=Path, default=None)
args = parser.parse_args()
if args.usuario_runtime is None:
    profiles = Path(os.environ['APPDATA'])/'GameMakerStudio2-LTS2026'
    licenses = sorted(profiles.glob('*/licence.plist'), key=lambda p: p.stat().st_mtime, reverse=True)
    args.usuario_runtime = licenses[0].parent if licenses else profiles/'unknownUser_unknownUserID'
runtime = args.runtime.resolve()
igor = runtime/'bin/igor/windows/x64/Igor.exe'
out = root/'build'/('html5-'+datetime.now().strftime('%Y%m%d-%H%M%S'))
out.mkdir(parents=True)
payload = out/'jogo'
payload.mkdir()
module = runtime/'html5/scripts.html5.zip'
print('Módulo HTML5:', 'disponível' if module.is_file() else 'ausente')
if not igor.is_file(): sys.exit('Igor não encontrado no runtime informado.')
command = [str(igor), f'--project={next(root.glob("*.yyp"))}', '--runtime=VM',
           f'--runtimePath={runtime}', f'--user={args.usuario_runtime.resolve()}',
           f'--cache={out/"cache"}', f'--temp={out/"temp"}',
           f'--of={payload/"FabricaDeSalgados"}', f'--tf={out/"FabricaDeSalgados-Web.zip"}', 'html5', 'zip']
with (out/'exportacao.log').open('w', encoding='utf-8') as log:
    try:
        result = subprocess.run(command, stdout=log, stderr=subprocess.STDOUT, timeout=120)
    except subprocess.TimeoutExpired:
        sys.exit(f'Compilação excedeu 120 segundos. Evidência: {out}')
archives = list(out.glob('*.zip'))
valid = False
for archive in archives:
    if zipfile.is_zipfile(archive):
        with zipfile.ZipFile(archive) as z:
            valid |= 'index.html' in z.namelist()
if result.returncode or not valid:
    print((out/'exportacao.log').read_text(encoding='utf-8', errors='replace')[-5000:])
    sys.exit(f'HTML5 não gerado. Evidência: {out}')
node=shutil.which('node')
if not node:sys.exit('Node é necessário para validar o JavaScript exportado.')
for script in (payload/'html5game').rglob('*.js'):
    checked=subprocess.run([node,'--check',str(script)],capture_output=True,text=True)
    if checked.returncode:
        (out/'javascript-invalido.log').write_text(checked.stderr,encoding='utf-8')
        sys.exit(f'JavaScript inválido; exportação bloqueada. Evidência: {out}')
print(f'Pacote gerado em {out}. Ainda precisa ser testado no navegador antes da publicação.')
