"""Valida o contrato visual da aula e a preservação da lógica de jogo (stdlib)."""
from pathlib import Path
from collections import Counter
import hashlib
import json
import math
import re
import struct
import zlib

root = Path(__file__).resolve().parents[1]

def read(path):
    return json.loads(re.sub(r',\s*([}\]])', r'\1', path.read_text(encoding='utf-8-sig')))

def png_alpha(path, size):
    """Confere dimensões e pixels transparentes/visíveis dos PNGs RGBA próprios."""
    data = path.read_bytes()
    assert data[:8] == b'\x89PNG\r\n\x1a\n', path
    offset, packed = 8, bytearray()
    while offset < len(data):
        length, = struct.unpack_from('>I', data, offset)
        kind = data[offset+4:offset+8]
        chunk = data[offset+8:offset+8+length]
        if kind == b'IHDR':
            width, height, bits, color, compression, filters, interlace = struct.unpack('>IIBBBBB', chunk)
            assert (width, height) == size, path
            assert (bits, color, compression, filters, interlace) == (8, 6, 0, 0, 0), path
        if kind == b'IDAT': packed.extend(chunk)
        offset += 12 + length
    raw, stride = zlib.decompress(packed), size[0]*4
    previous, alpha = bytearray(stride), []
    for y in range(size[1]):
        start = y*(stride+1)
        method, row = raw[start], bytearray(raw[start+1:start+1+stride])
        for x in range(stride):
            a, b, c = (row[x-4] if x >= 4 else 0), previous[x], (previous[x-4] if x >= 4 else 0)
            if method == 1: prediction = a
            elif method == 2: prediction = b
            elif method == 3: prediction = (a+b)//2
            elif method == 4:
                p = a+b-c
                distances = (abs(p-a), abs(p-b), abs(p-c))
                prediction = (a, b, c)[distances.index(min(distances))]
            else:
                assert method == 0, path
                prediction = 0
            row[x] = (row[x]+prediction) & 255
        alpha.extend(row[3::4])
        previous = row
    assert min(alpha) == 0 and max(alpha) > 0, f'Imagem vazia ou sem transparência: {path}'

manifest = read(root/'tools/recursos_visuais_alunos.json')
yyp, = root.glob('*.yyp')
registered = {r['id']['name']: r['id']['path'] for r in read(yyp)['resources']}
expected_instances, actual_instances = Counter(), Counter()
frames = 0
for item in manifest['sprites'] + [manifest['cozinheiro_existente']]:
    sprite, obj = item['sprite'], item['objeto']
    resource = read(root/registered[sprite])
    assert (resource['width'], resource['height']) == (item['largura'], item['altura']), sprite
    assert (resource['sequence']['xorigin'], resource['sequence']['yorigin']) == (item['origem_x'], item['origem_y']), sprite
    if 'quadros' in item: assert len(resource['frames']) == item['quadros'], sprite
    assert len(resource['frames']) >= 1, sprite
    for frame in resource['frames']:
        png_alpha(root/'sprites'/sprite/(frame['name']+'.png'), (item['largura'], item['altura']))
        frames += 1
    obj_data = read(root/registered[obj])
    assert obj_data['spriteId']['name'] == sprite, obj
    assert obj_data['spriteId']['path'] == registered[sprite], obj
    assert not any(obj_data.get(k) for k in ('solid', 'physicsObject', 'persistent')), obj
    if obj.startswith('obj_aula_'):
        assert obj_data['parentObjectId'] is None and obj_data['spriteMaskId'] is None, obj
        assert [(e['eventType'], e['eventNum']) for e in obj_data['eventList']] == [(8, 0)], obj
        draw = (root/'objects'/obj/'Draw_0.gml').read_text(encoding='utf-8-sig')
        assert re.sub(r'//[^\n]*|\s+', '', draw) == 'exit;', obj
        for placement in item['instancias']:
            x = math.floor(600+(placement['u']-placement['v'])*18+.5)
            y = math.floor(140+(placement['u']+placement['v'])*9-placement['z']+.5)
            expected_instances[(placement['sala'], obj, x, y)] += 1
for name, path in registered.items():
    if not path.startswith('rooms/'): continue
    room = read(root/path)
    for layer in room['layers']:
        for inst in layer.get('instances', []):
            obj = inst['objectId']['name']
            if obj.startswith('obj_aula_'):
                actual_instances[(name, obj, inst['x'], inst['y'])] += 1
                assert not inst.get('creationCodeFile') and not inst.get('properties'), obj
assert actual_instances == expected_instances, (actual_instances-expected_instances, expected_instances-actual_instances)
for relative, expected in manifest['hashes_logica_protegida_lf'].items():
    data = (root/relative).read_bytes().replace(b'\r\n', b'\n')
    if relative.endswith('/scr_mundo.gml'): data = data.split(b'function mundo_desenhar(')[0]
    if relative.endswith('/scr_historia.gml'): data = data.split(b'function historia_retrato(')[0]
    assert hashlib.sha256(data).hexdigest() == expected, f'Lógica alterada: {relative}'
print(json.dumps({'sprites':len(manifest['sprites'])+1, 'quadros_png':frames,
                  'objetos_visuais_novos':len(manifest['sprites']),
                  'instancias_visuais':sum(actual_instances.values()),
                  'modulos_de_logica_preservados':len(manifest['hashes_logica_protegida_lf']),
                  'dimensoes_origens_transparencia_associacoes':'OK'}, ensure_ascii=False, indent=2))
