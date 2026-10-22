"""Compila e executa testes GML em cópia. Python não é dependência do jogo."""
from pathlib import Path
from datetime import datetime
import argparse
import os
import shutil
import subprocess
import sys
import time

root = Path(__file__).resolve().parents[1]
programdata = Path(os.environ.get('PROGRAMDATA', r'C:\ProgramData'))
appdata = Path(os.environ.get('APPDATA', str(Path.home()/'AppData/Roaming')))
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--runtime', type=Path, default=programdata/'GameMakerStudio2-LTS2026/Cache/runtimes/runtime-2026.0.0.23')
parser.add_argument('--usuario-runtime', type=Path, default=appdata/'GameMakerStudio2-LTS2026/unknownUser_unknownUserID')
parser.add_argument('--destino', type=Path, default=root/'.testes'/datetime.now().strftime('%Y%m%d-%H%M%S'))
parser.add_argument('--partida', action='store_true', help='Percorre as salas reais, termina, revê o dashboard e reinicia.')
parser.add_argument('--historia', choices=('negociar','comprar','recusar'), help='Percorre a história guiada com a decisão escolhida.')
args = parser.parse_args()
if args.partida and args.historia: parser.error('Escolha --partida OU --historia.')
runtime, target = args.runtime.resolve(), args.destino.resolve()
igor, runner = runtime/'bin/igor/windows/x64/Igor.exe', runtime/'windows/x64/Runner.exe'
for required in (igor, runner, args.usuario_runtime):
    if not required.exists(): parser.error(f'Caminho não encontrado: {required}')
if target.exists(): parser.error('Destino já existe; escolha outro para preservar os resultados.')
if target == root or target in root.parents: parser.error('Destino não pode substituir a raiz ou seus ancestrais.')
target.mkdir(parents=True)
for folder in ('objects', 'scripts', 'rooms', 'options', 'datafiles', 'sprites'):
    if (root/folder).exists(): shutil.copytree(root/folder, target/folder)
for pattern in ('*.yyp', '*.resource_order'):
    for file in root.glob(pattern): shutil.copy2(file, target/file.name)
yyp, = target.glob('*.yyp')
with (target/'objects/obj_game/Create_0.gml').open('a', encoding='utf-8') as stream:
    if args.partida or args.historia:
        stream.write('\nglobal.teste_etapa=0;global.teste_ticks=0;global.teste_checks=0;\n')
    else:
        stream.write('''
var _testes = testes_simulacao_executar();
if (!_testes.ok) throw "FDS_SIMULACAO_FALHOU: " + json_stringify(_testes.falhas);
var _interface = testes_interface_simulacao_executar();
if (!_interface.ok) throw "FDS_INTERFACE_FALHOU: " + json_stringify(_interface.falhas);
var _v01 = testes_v01_executar();
if (!_v01.ok) throw "FDS_V01_FALHOU: " + json_stringify(_v01.falhas);
var _exploracao = testes_exploracao_executar();
if (!_exploracao.ok) throw "FDS_EXPLORACAO_FALHOU: " + json_stringify(_exploracao.falhas);
var _missoes = testes_missoes_executar();
if (!_missoes.ok) throw "FDS_MISSOES_FALHOU: " + json_stringify(_missoes.falhas);
show_debug_message("FDS_SIMULACAO_APROVADA");
game_end();
''')
if args.partida or args.historia:
    if args.historia:
        with (target/'objects/obj_game/Create_0.gml').open('a', encoding='utf-8') as stream:
            stream.write('\nglobal.teste_ramo="' + args.historia + '";\n')
    else:
        with (target/'objects/obj_parametros/Create_0.gml').open('a', encoding='utf-8') as stream:
            stream.write('\nmodo_guiado=false;if(!exploracao_ativa(global.jogo))configuracao=parametros_padrao();campos=parametros_campos(configuracao);\n')
    for obj in ('obj_menu','obj_parametros','obj_exploracao','obj_resultados'):
        driver = 'teste_historia_partida();\n' if args.historia else 'teste_exploracao_partida();\n'
        (target/f'objects/{obj}/Step_0.gml').write_text(('exploracao_controle_passo(id);\n' if obj=='obj_exploracao' else '') + driver, encoding='utf-8')

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
    started = time.time()
    startup = subprocess.STARTUPINFO()
    startup.dwFlags |= subprocess.STARTF_USESHOWWINDOW
    startup.wShowWindow = 0
    try:
        result = subprocess.run([str(runner), '-game', str(game)], stdout=log,
                                stderr=subprocess.STDOUT, timeout=30, startupinfo=startup)
    except subprocess.TimeoutExpired:
        print(f'FALHA: execução não concluiu em 30s. Confira {target/"execucao.log"}')
        sys.exit(1)
output = (target/'execucao.log').read_text(encoding='utf-8', errors='replace')
for line in output.splitlines():
    if any(marker in line for marker in ('FDS_', 'FALHA:', 'ERROR', 'not set')): print(line)
print(f'Evidências: {target}')
marker = 'FDS_PARTIDA_APROVADA' if args.partida or args.historia else 'FDS_SIMULACAO_APROVADA'
if result.returncode or marker not in output or 'ERROR in action' in output: sys.exit(1)
if args.partida or args.historia:
    folder_line = next((line for line in output.splitlines() if line.startswith('FDS_CAPTURAS_DIR: ')), '')
    if folder_line:
        captures = Path(folder_line.removeprefix('FDS_CAPTURAS_DIR: ').strip())
        pattern = f'fds-historia-{args.historia}-*.png' if args.historia else 'fds-exploracao-*.png'
        candidates = list(captures.glob(pattern))
        # screen_save respeita o sandbox do GameMaker, que pode diferir de working_directory.
        localdata = Path(os.environ.get('LOCALAPPDATA', str(Path.home()/'AppData/Local')))
        candidates.extend(localdata.glob('*/'+pattern))
        for file in candidates:
            if file.stat().st_mtime >= started - 1 and file.resolve().parent != target:
                shutil.copy2(file, target/file.name)
    expected = [f'fds-historia-{args.historia}-dashboard-{i}.png' for i in range(7)] if args.historia else [f'fds-exploracao-dashboard-{i}.png' for i in range(6)]
    if not all((target/name).is_file() for name in expected):
        print('FALHA: partida passou, mas faltam capturas das seis abas para inspeção.')
        sys.exit(1)
