import {chromium} from './node_modules/playwright/index.mjs';
import assert from 'node:assert/strict';
import {writeFile} from 'node:fs/promises';
const browser=await chromium.launch({channel:'msedge',headless:true,args:['--use-angle=swiftshader']});
const page=await browser.newPage({viewport:{width:1440,height:1000}}),errors=[];
page.on('pageerror',e=>errors.push(e.message));
try {
  await page.goto('http://127.0.0.1:4188/');
  await page.getByRole('button',{name:'Como jogar'}).click();
  assert.match(await page.locator('#instrucoes').innerText(),/5 minutos/);
  assert.match(await page.locator('#instrucoes').innerText(),/canhoto/);
  assert.match(await page.locator('#instrucoes').innerText(),/até 10 vezes/);
  await page.getByRole('button',{name:'Entendi, vamos jogar'}).click();
  await page.waitForTimeout(2500);
  const frame=page.frames().find(f=>f.url().includes('/game/index.html'));
  await frame.evaluate(()=>{
    for(const k of Object.getOwnPropertyNames(window)){
      try {const v=window[k];if(v&&typeof v==='object'&&v.instance_find&&v.variable_instance_get&&v.jogo){window.qaMap=v;return}}catch{}
    }
    throw Error('Mapa de símbolos do GameMaker não encontrado');
  });
  const click=async(x,y)=>{const b=await frame.locator('#canvas').boundingBox();await page.mouse.click(b.x+x*b.width/1280,b.y+y*b.height/720,{delay:180});await page.waitForTimeout(250)};
  const key=async(k)=>{await page.keyboard.press(k,{delay:80});await page.waitForTimeout(180)};
  const state=()=>frame.evaluate(()=>{
    const m=qaMap,j=global[m.jogo],f=j[m.feira],ms=j[m.missoes];
    const id=f?window[m.instance_find](window[m.asset_get_index]('obj_exploracao'),0):null,get=window[m.variable_instance_get];
    const inv=a=>a?.map(i=>({id:i.id,q:i[m.quantidade]}));
    return {ativa:!!f,tempo:f?.[m.segundos],limite:f?.[m.limite_segundos],avisou:f?.[m.lembrete_exibido],lembrete:f?.[m.lembrete_segundos],venceu:f?.[m.venceu],concluida:f?.[m.concluida],pausado:j[m.pausado],setor:j[m.exploracao]?.[m.setor],cozinha:inv(j[m.cozinha]),mochila:inv(j[m.carregados]),painel:f?get(id,'painel')?.id:null,conferido:ms?.[m.estoque_consultado],decisoes:ms?.[m.decisoes]?.length,maquina:j[m.maquinas]?.[m.decisao],produzidos:j[m.producao][m.unidades_produzidas],vendas:j[m.financas][m.receitas_centavos],saldo:j[m.financas][m.saldo_centavos],bonusCaixa:j[m.financas][m.bonus_centavos],bonusTempo:f?.[m.bonus_tempo],resgates:f?.[m.resgates_usados],acertos:f?.[m.resgates_acertos],resgate:f?.[m.resgate]?{correta:f[m.resgate][m.correta],pergunta:f[m.resgate][m.pergunta]}:null,lote:f?get(id,'lote_em_curso'):null,progresso:f?get(id,'lote_frames'):null,quiz:ms?.[m.fila]?.[ms[m.indice_fala]]?.[m.tipo]==='pergunta'?{correta:ms[m.fila][ms[m.indice_fala]][m.correta],resposta:ms[m.resposta_atual]}:null};
  });
  const time=s=>frame.evaluate(s=>{const m=qaMap;global[m.jogo][m.feira][m.segundos]=s},s);
  const interact=async(id,u,v)=>{
    if((await state()).painel)await key('e');
    await frame.evaluate(({u,v})=>{
      const m=qaMap,a=window[m.instance_find](window[m.asset_get_index]('obj_cozinheiro'),0),set=window[m.variable_instance_set];
      for(const [k,value] of Object.entries({u,v,x:600+(u-v)*18,y:140+(u+v)*9}))set(a,k,value);
    },{u,v});
    await page.waitForTimeout(80);await key('e');
    const s=await state();if(!id.startsWith('porta')&&id!=='saida')assert.equal(s.painel,id);
  };
  const start=async(natural=false)=>{
    await click(220,355);
    if(!(await state()).ativa){
      console.log('Diagnóstico de entrada:',JSON.stringify({state:await state(),errors,mouse:await frame.evaluate(()=>{const m=qaMap;return {x:window[m.device_mouse_x_to_gui](0),y:window[m.device_mouse_y_to_gui](0),w:document.querySelector('canvas').width,h:document.querySelector('canvas').height}})}));
      await key('Enter');
    }
    assert.equal((await state()).limite,300);assert.equal((await state()).tempo,0);
    await page.waitForTimeout(1500);assert.equal((await state()).tempo,0);
    await key('Space');await page.waitForTimeout(350);assert.equal((await state()).tempo,0);await shot('introducao-sem-tempo');
    if(natural){for(let i=0;i<4;i++)await key('Space');}else await key('Escape');
  };
  const shot=name=>frame.locator('#canvas').screenshot({path:'.testes/browser/atos-'+name+'.png'});
  const until=async(predicate,ms=20000)=>{const limit=Date.now()+ms;while(Date.now()<limit){if(await predicate())return;await page.waitForTimeout(200)}throw Error('Tempo excedido: '+JSON.stringify(await state()));};
  const acknowledgement=()=>frame.evaluate(()=>{const m=qaMap,j=global[m.jogo],c=j[m.confirmacao];return c?{acao:c[m.acao],titulo:c[m.titulo]}:null});
  const ack=async(action,enter=false)=>{
    assert.equal((await acknowledgement())?.acao,action);
    const paused=(await state()).tempo;await page.waitForTimeout(450);assert.equal((await state()).tempo,paused);
    await shot('confirmacao-'+action);
    if(enter)await key('Enter');else await click(790,500);
    assert.equal(await acknowledgement(),null);
  };
  await shot('menu');await start();await shot('inicio');
  const t=(await state()).tempo;await page.waitForTimeout(1100);assert((await state()).tempo-t>.8);
  await key('Escape');assert((await state()).pausado);const paused=(await state()).tempo;
  await page.waitForTimeout(450);assert.equal((await state()).tempo,paused);await key('Escape');
  await time(149.9);await page.waitForTimeout(350);assert((await state()).avisou);assert((await state()).lembrete>0);await shot('lembrete');
  await interact('porta_comercial',7,2);await interact('vendas',10,5.2);await click(740,510);
  await ack('aceitar');
  assert.equal((await state()).painel,undefined);await shot('aceito');
  await interact('saida',3,11);await interact('porta_estoque',29,2);await interact('compras',15.8,11.5);
  const stopped=(await state()).tempo;await page.waitForTimeout(400);assert.equal((await state()).tempo,stopped);
  await shot('decisao-ingredientes');await click(770,338);assert((await state()).conferido);assert.equal((await state()).decisoes,1);await key('e');
  await shot('estoque-lista');await click(900,510);
  assert.equal((await state()).mochila.reduce((a,i)=>a+i.q,0),100);assert.equal((await state()).painel,undefined);
  await ack('separar_pedido',true);
  await shot('mochila-completa');
  await interact('saida',3,11);await interact('porta_producao',18,2);await interact('deposito',6.5,6.3);await click(900,510);
  assert.equal((await state()).cozinha.find(i=>i.id==='queijo').q,40);
  await ack('depositar');
  assert.equal((await state()).mochila.reduce((a,i)=>a+i.q,0),0);await shot('depositado');
  // Quiz opcional: botão real e prêmio de tempo sem crédito financeiro.
  const beforeQuiz=await state();await click(650,49);assert((await state()).quiz);
  const quizTime=(await state()).tempo;await page.waitForTimeout(500);assert.equal((await state()).tempo,quizTime);
  await shot('quiz-tempo');await click(770,337+(await state()).quiz.correta*70);
  const afterQuiz=await state();assert.equal(afterQuiz.limite,beforeQuiz.limite+120);assert.equal(afterQuiz.bonusTempo,120);assert.equal(afterQuiz.saldo,beforeQuiz.saldo);assert.equal(afterQuiz.bonusCaixa,0);
  await shot('quiz-acerto');await key('e');
  await interact('bancada',11.4,7.2);await click(900,510);await ack('produzir');await until(async()=>(await state()).maquina);
  await shot('decisao-defeito');await click(780,404);await shot('consequencia-defeito');assert.equal((await state()).decisoes,2);await key('e');
  // Zerar durante um preparo: nem lote nem insumos desaparecem.
  await time((await state()).limite-.05);await until(async()=>(await state()).resgate);
  const pendingWork=await state();assert(pendingWork.lote);await shot('resgate-preparo');
  await page.waitForTimeout(650);const frozenWork=await state();assert.deepEqual(frozenWork.lote,pendingWork.lote);assert.equal(frozenWork.progresso,pendingWork.progresso);assert.deepEqual(frozenWork.cozinha,pendingWork.cozinha);assert.equal(frozenWork.saldo,pendingWork.saldo);
  await key('Escape');assert((await state()).resgate);await key('e');assert((await state()).resgate);
  await click(770,334+pendingWork.resgate.correta*66);assert.equal((await state()).limite,pendingWork.limite+120);assert.equal((await state()).resgates,1);await ack('resgate');
  await until(async()=>(await state()).produzidos===20);
  await ack('cozinhar');
  await shot('pronto');
  await interact('saida',3,11);await interact('porta_comercial',7,2);await interact('entrega',15,8.2);await click(900,510);
  const win=await state();assert(win.venceu&&win.concluida);assert.equal(win.vendas,8000);await shot('vitoria');
  await ack('entregar');
  await click(350,608);assert(!(await state()).ativa);await start(true);
  const tenQuestions=[];
  for(let n=1;n<=10;n++){
    const before=await state();await time(before.limite-.05);await until(async()=>(await state()).resgate);
    const pending=await state();assert(!pending.concluida);assert.equal(pending.resgates,n);assert.equal(pending.tempo,pending.limite);tenQuestions.push(pending.resgate.pergunta);
    if(n===10)await shot('decimo-resgate');
    if(n%2===0)await key(String(pending.resgate.correta+1));else await click(770,334+pending.resgate.correta*66);
    const earned=await state();assert.equal(earned.limite,pending.limite+120);assert.equal(earned.limite-earned.tempo,120);assert.equal(earned.acertos,n);assert.equal(earned.bonusTempo,n*120);assert.equal(earned.bonusCaixa,0);
    await ack('resgate',n%2===0);
  }
  assert.equal(new Set(tenQuestions).size,10);
  await time((await state()).limite-.05);await until(async()=>(await state()).concluida);
  const exhausted=await state();assert(!exhausted.venceu);assert.equal(exhausted.resgates,10);assert.equal(exhausted.resgate,null);assert.equal(exhausted.limite,1500);assert.equal(exhausted.vendas,0);await shot('resgates-esgotados');
  await click(350,608);await start();await time(299.95);await until(async()=>(await state()).resgate);
  const wrong=((await state()).resgate.correta+1)%3;await click(770,334+wrong*66);
  const loss=await state();assert(loss.concluida&&!loss.venceu);assert.equal(loss.bonusTempo,0);assert.equal(loss.resgates,1);assert.equal(loss.vendas,0);await shot('resgate-erro');await ack('resgate',true);await shot('resultado-erro');
  await click(350,608);await start();await time(299.95);await until(async()=>(await state()).resgate);await click(770,546);const voluntary=await state();assert(voluntary.concluida&&!voluntary.venceu);await ack('resgate_encerrar');
  assert.deepEqual(errors,[]);
  const result={ok:true,limite_inicial:300,quizzes_por_acerto:120,max_resgates:10,dez_perguntas_diferentes:tenQuestions,teclado_e_mouse:true,introducao_congela_relogio:true,confirmacoes_congelam:true,preparo_preservado_no_resgate:true,quiz_sem_bonus_financeiro:true,sem_decimo_primeiro_resgate:true,errors,win,exhausted,loss,voluntary,qa:'Edge real, cliques e teclas; só posicionamento do ator e saltos do relógio são instrumentados.'};
  await writeFile('.testes/browser/extra-qa.json',JSON.stringify(result,null,2));console.log(JSON.stringify(result));
} finally {await browser.close()}
