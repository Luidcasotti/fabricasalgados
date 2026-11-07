# Página Web do jogo

- `index.template.html`: página com iframe, instruções, tela cheia e redimensionamento.
- `preparar_exportacao.py`: prepara uma exportação oficial em `dist/`.
- `dist/`: saída local, ignorada pelo Git.

Na raiz do repositório:

```powershell
python tools/exportar_web.py
python web/preparar_exportacao.py '.\build\html5-AAAAMMDD-HHMMSS\jogo'
python -m http.server 8080 --bind 127.0.0.1 --directory web/dist
```

Substitua o caminho pela exportação gerada. Abra `http://127.0.0.1:8080`.
A preparação não compila GML nem publica o site. Veja o [guia completo](../docs/PUBLICACAO_WEB.md).
