import {chromium} from './node_modules/playwright/index.mjs';
import assert from 'node:assert/strict';
import {writeFile} from 'node:fs/promises';
const browser=await chromium.launch({channel:'msedge',headless:true,args:['--use-angle=swiftshader']});
const page=await browser.newPage({viewport:{width:1440,height:1000}}),errors=[];
page.on('pageerror',e=>errors.push(e.message));
try {
  await page.goto('http://127.0.0.1:4190/');
  await page.getByRole('button',{name:'Como jogar'}).click();
  assert.match(await page.locator('#instrucoes').innerText(),/5 minutos/);
  assert.match(await page.locator('#instrucoes').innerText(),/canhoto/);
  assert.match(await page.locator('#instrucoes').innerText(),/até 10 vezes/);
  await page.getByRole('button',{name:'Entendi, vamos jogar'}).click();
  await page.waitForTimeout(2500);
  const frame=page.frames().find(f=>f.url().includes('/game/index.html'));
  await frame.waitForFunction(()=>Object.getOwnPropertyNames(window).some(k=>{try{const v=window[k];return v&&typeof v==='object'&&v.instance_find&&v.variable_instance_get&&v.jogo}catch{return false}}),{timeout:20000});
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
    const id=window[m.instance_find](window[m.asset_get_index]('obj_exploracao'),0),has=window[m.instance_exists](id),get=window[m.variable_instance_get];
    const inv=a=>a?.map(i=>({id:i.id,q:i[m.quantidade]}));
    return {naPartida:has,encerrado:j[m.encerrado],dia:j[m.dia],historia:!!ms,entregues:ms?.[m.entregues]?.length,meta:ms?.[m.meta],zerou:ms?.[m.concluida]&&ms?.[m.entregues]?.length>=ms?.[m.meta],oferta:j[m.pedidos]?.find(p=>p.id===ms?.[m.atual_id])?{id:ms[m.atual_id],status:j[m.pedidos].find(p=>p.id===ms[m.atual_id])[m.status],quantidade:j[m.pedidos].find(p=>p.id===ms[m.atual_id])[m.quantidade]}:null,decisaoEstoque:ms?.[m.fila]?.[ms[m.indice_fala]]?.[m.tipo]==='decisao',ativa:!!f,tempo:f?.[m.segundos],limite:f?.[m.limite_segundos],avisou:f?.[m.lembrete_exibido],lembrete:f?.[m.lembrete_segundos],venceu:f?.[m.venceu],concluida:f?.[m.concluida],pausado:j[m.pausado],setor:j[m.exploracao]?.[m.setor],cozinha:inv(j[m.cozinha]),mochila:inv(j[m.carregados]),painel:has?get(id,'painel')?.id:null,painelTipo:has?get(id,'painel')?.[m.tipo]:null,conferido:ms?.[m.estoque_consultado],decisoes:ms?.[m.decisoes]?.length,maquina:j[m.maquinas]?.[m.decisao],produzidos:j[m.producao][m.unidades_produzidas],vendas:j[m.financas][m.receitas_centavos],saldo:j[m.financas][m.saldo_centavos],bonusCaixa:j[m.financas][m.bonus_centavos],bonusTempo:f?.[m.bonus_tempo],resgates:f?.[m.resgates_usados],acertos:f?.[m.resgates_acertos],resgate:f?.[m.resgate]?{correta:f[m.resgate][m.correta],pergunta:f[m.resgate][m.pergunta]}:null,lote:has?get(id,'lote_em_curso'):null,progresso:has?get(id,'lote_frames'):null,quiz:ms?.[m.fila]?.[ms[m.indice_fala]]?.[m.tipo]==='pergunta'?{correta:ms[m.fila][ms[m.indice_fala]][m.correta],resposta:ms[m.resposta_atual]}:null};
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
  const shot=name=>frame.locator('#canvas').screenshot({path:'.testes/browser/campanha-'+name+'.png'});
  const until=async(predicate,ms=20000)=>{const limit=Date.now()+ms;while(Date.now()<limit){if(await predicate())return;await page.waitForTimeout(200)}throw Error('Tempo excedido: '+JSON.stringify(await state()));};
  const acknowledgement=()=>frame.evaluate(()=>{const m=qaMap,j=global[m.jogo],c=j[m.confirmacao];return c?{acao:c[m.acao],titulo:c[m.titulo]}:null});
  const ack=async(action,enter=false)=>{
    assert.equal((await acknowledgement())?.acao,action);
    const paused=(await state()).tempo;await page.waitForTimeout(450);assert.equal((await state()).tempo,paused);
    await shot('confirmacao-'+action);
    if(enter)await key('Enter');else await click(790,500);
    assert.equal(await acknowledgement(),null);
  };
  // Os botões que pareciam não responder são testados por cliques reais.
  await shot('menu');await click(220,446);await shot('parametros');
  await click(1090,125);await until(async()=>(await state()).naPartida);
  assert((await state()).historia);assert.equal((await state()).ativa,false);assert.equal((await state()).meta,5);await key('Escape');
  await click(750,674);assert.equal((await acknowledgement()).acao,'saida');await shot('confirmar-saida');
  await click(570,500);assert.equal(await acknowledgement(),null);assert((await state()).naPartida);
  await click(750,674);await click(995,500);await until(async()=>!(await state()).naPartida);
  await shot('saiu-para-menu');await click(220,519);await until(async()=>(await state()).naPartida);assert.equal((await state()).meta,5);
  // Encerrar dia também precisa confirmar e manter as missões em andamento.
  const beforeDay=await state();await click(550,674);assert.equal((await state()).painelTipo,'relogio');await shot('encerrar-dia');await click(900,494);await ack('encerrar dia');
  assert.equal((await state()).dia,beforeDay.dia+1);assert.equal((await state()).entregues,0);assert.equal((await state()).encerrado,false);
  await click(750,674);await key('Enter');await until(async()=>!(await state()).naPartida);
  // Campanha cronometrada completa, sem modificar estoques nem pagamentos.
  await start();assert.equal((await state()).meta,5);
  const go=async(setor)=>{
    let current=(await state()).setor;if(current===setor)return;
    if(current!=='corredor')await interact('saida',3,11);
    await interact('porta_'+setor,...({comercial:[7,2],estoque:[29,2],producao:[18,2]}[setor]));
  };
  const entregas=[];
  for(let n=1;n<=2;n++){
    await go('comercial');await interact('vendas',10,5.2);const offered=(await state()).oferta;assert.equal(offered.status,'ofertado');await click(740,510);await ack('aceitar',true);
    await go('estoque');await interact('compras',15.8,11.5);
    if((await state()).decisaoEstoque){await click(770,338);await key('e');}
    await click(900,510);assert((await state()).mochila.reduce((a,i)=>a+i.q,0)>0);await ack('separar_pedido',true);
    await go('producao');await interact('deposito',6.5,6.3);await click(900,510);await ack('depositar',true);
    const beforeCook=(await state()).produzidos;await interact('bancada',11.4,7.2);await click(900,510);await ack('produzir',true);
    await until(async()=>{const s=await state();return s.maquina||s.produzidos===beforeCook+offered.quantidade},45000);
    if((await state()).maquina){await click(780,404);await key('e');}
    await until(async()=>(await state()).produzidos===beforeCook+offered.quantidade,45000);await ack('cozinhar',true);
    await go('comercial');await interact('entrega',15,8.2);await click(900,510);
    const delivered=await state();assert.equal(delivered.entregues,n);entregas.push({numero:n,oferta:offered,vendas:delivered.vendas,produzidos:delivered.produzidos});
    if(n<5){assert(!delivered.encerrado&&!delivered.concluida);assert.equal(delivered.oferta.status,'ofertado');assert.equal(delivered.oferta.id,n+1);}
    else {assert(delivered.zerou&&delivered.venceu&&delivered.encerrado);assert.equal((await acknowledgement()).titulo,'Você zerou o jogo!');await shot('zerou-confirmacao');}
    await ack('entregar',true);assert.equal((await state()).painel,undefined);await shot('painel-fechado-entrega-'+n);console.log('Entrega '+n+'/5 concluída');
  }
  assert.equal((await state()).entregues,2);assert.equal((await state()).oferta.id,3);assert(!(await state()).concluida);assert.deepEqual(errors,[]);
  const result={ok:true,exportacao:'html5-20261105-102414',botoes_iniciar_sair_cancelar_continuar:true,encerrar_dia:true,paineis_fecham_apos_entrega:true,segunda_missao_aceita:true,terceira_oferta_liberada:true,entregas,estado:await state(),errors};
  await writeFile('.testes/browser/campanha-complementar-qa.json',JSON.stringify(result,null,2));console.log(JSON.stringify(result));
} catch(error){console.log('Erros JS:',JSON.stringify(errors));await page.screenshot({path:'.testes/browser/campanha-falha.png'});throw error} finally {await browser.close()}
