// Análise sintática independente; não substitui a compilação oficial.
// npm install --prefix .testes/gml-parser --ignore-scripts @bscotch/gml-parser@1.17.2
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';
const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const source = path.join(root, '.testes/gml-parser/node_modules/@bscotch/gml-parser/dist/parser.js');
if (!fs.existsSync(source)) throw new Error('Instale o parser com o comando no início deste arquivo.');
const { GmlParser } = await import(pathToFileURL(source));
const parser = new GmlParser();
let files = 0, errors = 0;
function scan(folder) {
  for (const file of fs.readdirSync(folder, { withFileTypes: true })) {
    const full = path.join(folder, file.name);
    if (file.isDirectory()) scan(full);
    else if (file.name.endsWith('.gml')) {
      files++;
      const result = parser.parse(fs.readFileSync(full, 'utf8'));
      for (const error of [...result.lexed.errors, ...result.errors]) {
        errors++;
        console.error(path.relative(root, full), error.message);
      }
    }
  }
}
scan(path.join(root, 'scripts'));scan(path.join(root, 'objects'));
console.log(JSON.stringify({ arquivos_gml: files, erros_sintaticos: errors, execucao_no_motor: false }));
process.exitCode = errors ? 1 : 0;
