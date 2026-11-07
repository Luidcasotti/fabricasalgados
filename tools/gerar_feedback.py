"""Gera efeitos originais discretos. Somente ferramenta de desenvolvimento (stdlib)."""
from pathlib import Path
import json
import math
import struct
import wave

ROOT = Path(__file__).resolve().parents[1]
TONS = {'porta': (160, 210), 'pedido': (440, 660), 'coleta': (620, 820),
        'producao': (523, 659, 784), 'objetivo': (660, 880), 'alerta': (330, 294)}

def gerar():
    for tipo, notas in TONS.items():
        nome = 'snd_feira_' + tipo
        pasta = ROOT/'sounds'/nome
        pasta.mkdir(parents=True, exist_ok=True)
        amostras = []
        for hz in notas:
            n = int(44100*.075)
            for i in range(n):
                env = min(1, i/180)*(1-i/n)**2
                amostras.append(int(5000*env*math.sin(2*math.pi*hz*i/44100)))
        with wave.open(str(pasta/(nome+'.wav')), 'wb') as wav:
            wav.setparams((1, 2, 44100, 0, 'NONE', 'not compressed'))
            wav.writeframes(struct.pack('<'+'h'*len(amostras), *amostras))
        recurso = {'$GMSound': 'v2', '%Name': nome,
                   'audioGroupId': {'name': 'audiogroup_default', 'path': 'audiogroups/audiogroup_default'},
                   'bitDepth': 1, 'channelFormat': 0, 'compression': 0, 'compressionQuality': 4, 'conversionMode': 0,
                   'duration': len(amostras)/44100, 'exportDir': '', 'name': nome,
                   'parent': {'name': 'BLANK GAMEFabricaDeSalgados', 'path': 'BLANK GAMEFabricaDeSalgados.yyp'},
                   'preload': True, 'resourceType': 'GMSound', 'resourceVersion': '2.0',
                   'sampleRate': 44100, 'soundFile': nome+'.wav', 'volume': 1.0}
        (pasta/(nome+'.yy')).write_text(json.dumps(recurso, indent=2)+'\n', encoding='utf-8')

if __name__ == '__main__':
    gerar()
