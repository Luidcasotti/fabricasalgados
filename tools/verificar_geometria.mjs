// Executa as funções geométricas GML que também são JavaScript válido, sem transpilar.
// Valida a matemática dos mapas; não simula o GameMaker, as salas ou as entradas reais.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import vm from 'node:vm';
import { fileURLToPath } from 'node:url';
const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
function source(file, name) {
  const text = fs.readFileSync(path.join(root, file), 'utf8');
  const start = text.indexOf(`function ${name}(`);
  assert(start >= 0, name);
  const end = text.indexOf('\nfunction ', start + 1);
  return text.slice(start, end < 0 ? text.length : end);
}
const world = 'scripts/scr_mundo/scr_mundo.gml';
const ctx = {
  global: { jogo: { guiado: true, catalogo: {} } },
  // Pintura do piso não participa da geometria; o teste não renderiza a cena.
  mundo_mosaico_piso: () => undefined,
  variable_global_exists: () => true,
  missoes_ativa: j => j.guiado,
  ingrediente_obter: (_catalogo, id) => ({ nome: id }),
  string_upper: s => s.toUpperCase(), array_push: (a, v) => a.push(v), array_length: a => a.length,
  max: Math.max, abs: Math.abs, ceil: Math.ceil,
  clamp: (v, min, max) => Math.max(min, Math.min(max, v)),
};
vm.createContext(ctx);
for (const name of ['mundo_projetar', 'mundo_criar', 'mundo_livre', 'mundo_mover']) {
  vm.runInContext(source(world, name), ctx);
}
let checks = 0;
function check(value, title) { assert(value, title); checks++; }
function reachable(m, target) {
  const start = { u: m.entrada.u, v: m.entrada.v };
  const queue = [start], seen = new Set([`${start.u},${start.v}`]);
  for (let head = 0; head < queue.length; head++) {
    const p = queue[head];
    if (Math.hypot(p.u - target.u, p.v - target.v) <= target.raio) return true;
    for (const [du, dv] of [[.5, 0], [-.5, 0], [0, .5], [0, -.5]]) {
      const u = p.u + du, v = p.v + dv, id = `${u},${v}`;
      if (!seen.has(id) && ctx.mundo_livre(m, u, v)) { seen.add(id); queue.push({ u, v }); }
    }
  }
  return false;
}
for (const guiado of [false, true]) {
  ctx.global.jogo.guiado = guiado;
  for (const setor of ['corredor', 'comercial', 'producao', 'estoque']) {
    const m = ctx.mundo_criar(setor);
    check(ctx.mundo_livre(m, m.entrada.u, m.entrada.v), `Entrada livre: ${setor}`);
    check(!ctx.mundo_livre(m, -1, 2) && !ctx.mundo_livre(m, m.w, m.h), `Bordas: ${setor}`);
    for (const alvo of m.alvos) check(reachable(m, alvo), `Alvo alcançável: ${setor}/${alvo.id}`);
    if (setor !== 'corredor') check(reachable(m, { u: 3, v: 10, raio: .01 }), `Entrada de porta livre: ${setor}`);
  }
}
const m = ctx.mundo_criar('producao');
const ator = { u: 9, v: 5.8 };
ctx.mundo_mover(ator, m, 6, 0);
check(ator.u < 9.76 && ctx.mundo_livre(m, ator.u, ator.v), 'Subpassos bloqueiam a bancada');
const borda = { u: 1, v: 8 };
ctx.mundo_mover(borda, m, -10, 0);
check(borda.u >= .6, 'Subpassos bloqueiam a parede');
console.log(JSON.stringify({ verificacoes_geometricas: checks, resultado: 'OK', ambiente: 'JavaScript; não é execução no motor' }));
