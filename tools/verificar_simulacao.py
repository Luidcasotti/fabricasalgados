"""Compila e executa testes GML em cópia. Python não é dependência do jogo."""
from pathlib import Path
from datetime import datetime
import argparse
import os
import shutil
import subprocess
import sys

root = Path(__file__).resolve().parents[1]
programdata = Path(os.environ.get('PROGRAMDATA', r'C:\ProgramData'))
appdata = Path(os.environ.get('APPDATA', str(Path.home()/'AppData/Roaming')))
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--runtime', type=Path, default=programdata/'GameMakerStudio2-LTS2026/Cache/runtimes/runtime-2026.0.0.23')
parser.add_argument('--usuario-runtime', type=Path, default=appdata/'GameMakerStudio2-LTS2026/unknownUser_unknownUserID')
parser.add_argument('--destino', type=Path, default=root/'.testes'/datetime.now().strftime('%Y%m%d-%H%M%S'))
args = parser.parse_args()
runtime, target = args.runtime.resolve(), args.destino.resolve()
igor, runner = runtime/'bin/igor/windows/x64/Igor.exe', runtime/'windows/x64/Runner.exe'
for required in (igor, runner, args.usuario_runtime):
    if not required.exists(): parser.error(f'Caminho não encontrado: {required}')
if target.exists(): parser.error('Destino já existe; escolha outro para preservar os resultados.')
if target == root or target in root.parents: parser.error('Destino não pode substituir a raiz ou seus ancestrais.')
target.mkdir(parents=True)
for folder in ('objects', 'scripts', 'rooms', 'options', 'datafiles'):
    if (root/folder).exists(): shutil.copytree(root/folder, target/folder)
for pattern in ('*.yyp', '*.resource_order'):
    for file in root.glob(pattern): shutil.copy2(file, target/file.name)
yyp, = target.glob('*.yyp')
with (target/'objects/obj_game/Create_0.gml').open('a', encoding='utf-8') as stream:
    stream.write('''
var _testes = testes_simulacao_executar();
if (!_testes.ok) throw "FDS_SIMULACAO_FALHOU: " + json_stringify(_testes.falhas);
var _interface = testes_interface_simulacao_executar();
if (!_interface.ok) throw "FDS_INTERFACE_FALHOU: " + json_stringify(_interface.falhas);
show_debug_message("FDS_SIMULACAO_APROVADA");
game_end();
''')
build = target/'build'
build.mkdir()
command = [str(igor), f'--project={yyp}', '--runtime=VM', f'--runtimePath={runtime}',
           f'--user={args.usuario_runtime.resolve()}', f'--cache={target/"cache"}',
           f'--temp={target/"temp"}', f'--of={build/"FabricaDeSalgados.win"}',
           f'--tf={build/"FabricaDeSalgados.zip"}', 'windows', 'Compile']
with (target/'compilacao.log').open('w', encoding='utf-8') as log:
    result = subprocess.run(command, stdout=log, stderr=subprocess.STDOUT, timeout=120)
if result.returncode:
    print((target/'compilacao.log').read_text(encoding='utf-8')[-10000:])
    sys.exit(result.returncode)
game, = build.glob('*.win')
with (target/'execucao.log').open('w', encoding='utf-8') as log:
    startup = subprocess.STARTUPINFO()
    startup.dwFlags |= subprocess.STARTF_USESHOWWINDOW
    startup.wShowWindow = 0
    result = subprocess.run([str(runner), '-game', str(game)], stdout=log,
                            stderr=subprocess.STDOUT, timeout=30, startupinfo=startup)
output = (target/'execucao.log').read_text(encoding='utf-8', errors='replace')
for line in output.splitlines():
    if any(marker in line for marker in ('FDS_', 'FALHA:', 'ERROR', 'not set')): print(line)
print(f'Evidências: {target}')
if result.returncode or 'FDS_SIMULACAO_APROVADA' not in output or 'ERROR in action' in output: sys.exit(1)
