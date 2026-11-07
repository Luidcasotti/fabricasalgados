"""Gera os atlas de texto legíveis usados pelo GameMaker, sem fonte dinâmica no navegador."""
from pathlib import Path
import json
import math
from PIL import Image, ImageDraw, ImageFont

root = Path(__file__).resolve().parents[1]
chars = sorted(set(range(32, 127)) | set(range(160, 256)) | {8211, 8212, 8216, 8217, 8220, 8221, 8226, 8230, 8592, 8593, 8594, 8595, 9647, 10003})
for index, pixels in enumerate((16, 22, 30, 40), 1):
    name = f'fnt_interface_{index}'
    directory = root/'fonts'/name
    directory.mkdir(parents=True, exist_ok=True)
    font = ImageFont.truetype('C:/Windows/Fonts/segoeui.ttf', pixels)
    ascent, descent = font.getmetrics()
    height = ascent+descent
    image = Image.new('RGBA', (1024, 1024))
    draw = ImageDraw.Draw(image)
    glyphs = {}
    x = y = 2
    for code in chars:
        char = chr(code)
        left, top, right, bottom = font.getbbox(char)
        width = max(1, right-left)
        if x+width+2 > image.width:
            x, y = 2, y+height+2
        draw.text((x-left, y), char, font=font, fill='white')
        glyphs[str(code)] = dict(x=x, y=y, w=width, h=height, character=code, shift=round(font.getlength(char)), offset=left)
        x += width+2
    image.crop((0, 0, 1024, 2**math.ceil(math.log2(y+height+2)))).save(directory/(name+'.png'))
    resource = {'$GMFont':'', '%Name':name, 'name':name, 'resourceType':'GMFont', 'resourceVersion':'2.0',
        'fontName':'Segoe UI', 'styleName':'Regular', 'size':pixels*.75, 'bold':False, 'italic':False,
        'applyKerning':0, 'hinting':0, 'glyphOperations':0, 'interpreter':0, 'pointRounding':0,
        'sdfSpread':8, 'usesSDF':False,
        'AntiAlias':1, 'charset':0, 'first':0, 'last':0, 'includeTTF':False, 'TTFName':'',
        'ascender':ascent, 'ascenderOffset':0, 'lineHeight':height, 'glyphs':glyphs, 'kerningPairs':[],
        'ranges':[{'lower':c,'upper':c} for c in chars], 'regenerateBitmap':False, 'canGenerateBitmap':True,
        'maintainGms1Font':False, 'textureGroupId':{'name':'Default','path':'texturegroups/Default'},
        'parent':{'name':'BLANK GAMEFabricaDeSalgados','path':'BLANK GAMEFabricaDeSalgados.yyp'},
        'sampleText':'Pedido #1: 20 bolinhas de queijo. Estoque, mochila e cozinha.'}
    (directory/(name+'.yy')).write_text(json.dumps(resource,ensure_ascii=False,indent=2), encoding='utf-8')
    project = next(root.glob('*.yyp'))
    source = project.read_text(encoding='utf-8')
    if f'"name":"{name}"' not in source:
        entry = f'    {{"id":{{"name":"{name}","path":"fonts/{name}/{name}.yy",}},}},\n'
        source = source.replace('"resources":[', '"resources":[\n'+entry)
        project.write_text(source,encoding='utf-8')
print('Quatro atlas de fonte gerados e registrados.')
