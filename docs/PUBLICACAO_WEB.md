# Exportação e publicação Web

## O que é publicado

A página é um contêiner HTML para a exportação oficial HTML5 do GameMaker. A lógica permanece nos arquivos GML; não foi reescrita no site. A página oferece ajuste de tamanho, instruções e tela cheia por ação do usuário.

O código desse contêiner está em [web/](../web/README.md). O site atual é [Fábrica de Salgados](https://fabrica-salgados-mundo-senai.casottimarinetti.chatgpt.site).

## Gerar o jogo HTML5

Requer GameMaker configurado, módulo HTML5 disponível, perfil local de licença e Node no PATH para a validação de JavaScript. Na raiz:

```powershell
python tools/exportar_web.py
```

O script aceita `--runtime` e `--usuario-runtime` para os caminhos da sua instalação. Ele cria uma pasta nova em `build/html5-AAAAMMDD-HHMMSS/`, com `jogo/`, ZIP, log de exportação e cache. Nada é enviado à internet por esse comando.

Se a compilação ou `node --check` falhar, não publique aquele pacote. Leia os logs; em erro de JavaScript gerado, refaça a exportação e valide novamente no navegador. A verificação sintática não substitui a execução.

## Preparar e testar a página

Troque o exemplo pelo caminho impresso na sua exportação:

```powershell
python web/preparar_exportacao.py '.\build\html5-AAAAMMDD-HHMMSS\jogo'
python -m http.server 8080 --bind 127.0.0.1 --directory web/dist
```

Abra `http://127.0.0.1:8080` no navegador. Use HTTP local; abrir apenas `index.html` pelo sistema de arquivos pode afetar o carregamento dos assets. O preparador copia o jogo para `web/dist/game/`, aplica a página e o ajuste do canvas e remove arquivos auxiliares de exportação que não precisam de hospedagem.

Confira introdução, cinco missões, texto legível, som, decisões, resultados/retorno, cronômetro, bônus, resgates e motoboy. Em testes de reposição, queijo inicial 40 produz faltantes nas missões 3 e 5. Veja [Validação](VALIDACAO.md).

## Hospedar e atualizar

Qualquer hospedagem estática compatível pode servir o conteúdo completo de `web/dist/`, preservando caminhos e arquivos do exportado. Envie a pasta preparada inteira e confira o jogo em HTTP/HTTPS após publicar.

A publicação atual usa Sites e possui repositório de hospedagem próprio. Seu manifesto, credenciais temporárias e arquivo de implantação são administrados naquele ambiente, não neste repositório GitHub. O fluxo operacional é abrir a fonte do site, copiar o exportado validado, empacotar/registrar a versão e publicar preservando o acesso existente.

GitHub é a fonte do projeto e da documentação; **fazer um commit não atualiza automaticamente o site**. Não há pipeline automático de deploy configurado aqui. Depois de alterar a página ou exportação, atualize também o identificador de cache do iframe em `web/index.template.html` e confira a versão carregada.

O salvamento da sessão continua apenas em memória. Recarregar a página para uma versão nova reinicia a partida.
