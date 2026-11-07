from pathlib import Path
import argparse,shutil
p=argparse.ArgumentParser();p.add_argument('exportacao',type=Path);a=p.parse_args()
root=Path(__file__).resolve().parent;dest=root/'dist/game'
assert (a.exportacao/'index.html').is_file()
assert dest.resolve()==(root/'dist/game').resolve()
dest.mkdir(parents=True,exist_ok=True)
shutil.copytree(a.exportacao,dest,dirs_exist_ok=True)
for name in ('igor.output.manifest','options.ini'):
    (dest/name).unlink(missing_ok=True)
html=(dest/'index.html').read_text(encoding='utf-8')
html=html.replace('<html>','<html lang="pt-BR">').replace('</head>','<style>html,body{width:100%;height:100%;overflow:hidden}#gm4html5_div_id{display:flex;align-items:center;justify-content:center;width:100%;height:100%}canvas{max-width:100%;max-height:100%;object-fit:contain;image-rendering:auto}</style></head>')
(dest/'index.html').write_text(html,encoding='utf-8')
shutil.copy2(root/'index.template.html',root/'dist/index.html')
print('Exportação preparada:',dest)
