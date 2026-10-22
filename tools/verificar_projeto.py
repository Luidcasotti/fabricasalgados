"""Confere registro, referências e eventos GameMaker sem dependências externas."""
from pathlib import Path
import json
import re

root = Path(__file__).resolve().parents[1]
yyp, = root.glob('*.yyp')
def read(path):
    return json.loads(re.sub(r',\s*([}\]])', r'\1', path.read_text(encoding='utf-8-sig')))
def references(node):
    if isinstance(node, dict):
        relative = node.get('path')
        if isinstance(relative, str) and relative.endswith(('.yy', '.yyp')) and not relative.startswith('folders/'):
            target = (root/relative).resolve()
            assert target.is_relative_to(root) and target.is_file(), relative
        for value in node.values(): references(value)
    elif isinstance(node, list):
        for value in node: references(value)
project = read(yyp)
resources = {entry['id']['name']: entry['id']['path'] for entry in project['resources']}
assert len(resources) == len(project['resources']), 'Nomes duplicados'
order = [entry['roomId']['name'] for entry in project['RoomOrderNodes']]
assert order[:7] == ['rm_menu','rm_parametros','rm_corredor','rm_comercial','rm_producao','rm_estoque','rm_dashboard'], order
assert 'Room1' in order and project['defaultScriptType'] == 0
references(project)
for name, relative in resources.items():
    path = root/relative
    resource = read(path)
    assert resource['name'] == name
    references(resource)
    if relative.startswith('scripts/'):
        assert resource['isDnD'] is False and path.with_suffix('.gml').is_file()
    if relative.startswith('objects/'):
        for event in resource['eventList']:
            prefix = {0:'Create', 3:'Step', 8:'Draw', 12:'CleanUp'}[event['eventType']]
            assert path.with_name(f"{prefix}_{event['eventNum']}.gml").is_file()
    if relative.startswith('sprites/'):
        assert resource['width'] > 0 and resource['height'] > 0
        frames = resource['frames']
        assert len(frames) == resource['sequence']['length']
        keys = resource['sequence']['tracks'][0]['keyframes']['Keyframes']
        assert len(keys) == len(frames)
        for index, frame in enumerate(frames):
            assert path.with_name(frame['name']+'.png').is_file()
            assert keys[index]['Channels']['0']['Id']['name'] == frame['name']
            for layer in resource['layers']:
                assert (path.parent/'layers'/frame['name']/(layer['name']+'.png')).is_file()
    if name.startswith('rm_'):
        instances = [i for layer in resource['layers'] for i in layer.get('instances', [])]
        assert len(instances) == (3 if name in ('rm_corredor','rm_comercial','rm_producao','rm_estoque') else 2) and instances[0]['objectId']['name'] == 'obj_game'
        assert [i['name'] for i in instances] == [i['name'] for i in resource['instanceCreationOrder']]
assert read(root/resources['obj_game'])['persistent'] is True
for obj in ('obj_exploracao','obj_cozinheiro'):
    assert read(root/resources[obj])['persistent'] is False
for required in ('scr_compras','scr_tempo','scr_parametros','scr_testes_simulacao'):
    assert required in resources, required
print(json.dumps({'recursos':len(resources), 'ordem_salas':order,
                  'referencias':'OK','eventos':'OK','frames_sprite':'OK','GML_Code':True},ensure_ascii=False,indent=2))
