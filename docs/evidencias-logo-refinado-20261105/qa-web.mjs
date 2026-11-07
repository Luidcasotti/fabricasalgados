import {chromium} from './node_modules/playwright/index.mjs';
import assert from 'node:assert/strict';
import {writeFile} from 'node:fs/promises';
const browser=await chromium.launch({channel:'msedge',headless:true,args:['--use-angle=swiftshader']});
const page=await browser.newPage({viewport:{width:1440,height:1000}}),errors=[];
page.on('pageerror',e=>errors.push(e.message));
try {
  await page.goto('http://127.0.0.1:4193/');
  await page.getByRole('button',{name:'Como jogar'}).click();
  assert.match(await page.locator('#instrucoes').innerText(),/5 minutos/);
  assert.match(await page.locator('#instrucoes').innerText(),/canhoto/);
  assert.match(await page.locator('#instrucoes').innerText(),/até 10 vezes/);
  await page.getByRole('button',{name:'Entendi, vamos jogar'}).click();
  await page.waitForTimeout(2500);
  const frame=page.frames().find(f=>f.url().includes('/game/index.html'));
  await frame.waitForFunction(()=>Object.getOwnPropertyNames(window).some(k=>{try{const v=window[k];return v&&typeof v==='object'&&v.instance_find&&v.variable_instance_get&&v.jogo}catch{return false}}));
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
    return {compras:j[m.compras]?.map(c=>({id:c.id,ingrediente:c[m.ingrediente_id],quantidade:c[m.quantidade],status:c[m.status],restante:c[m.entrega_restante],motoboy:c[m.via_motoboy]})),almoxarifado:inv(j[m.estoque]?.[m.materias_primas]),comprasPagas:j[m.financas][m.compras_centavos],entregasMoto:j[m.exploracao]?.[m.entregas_motoboy],avisoMoto:j[m.exploracao]?.[m.aviso_entrega],saidaMoto:j[m.exploracao]?.[m.saida_motoboy_segundos],fase:j[m.fase],naPartida:has,encerrado:j[m.encerrado],dia:j[m.dia],historia:!!ms,entregues:ms?.[m.entregues]?.length,meta:ms?.[m.meta],zerou:ms?.[m.concluida]&&ms?.[m.entregues]?.length>=ms?.[m.meta],oferta:j[m.pedidos]?.find(p=>p.id===ms?.[m.atual_id])?{id:ms[m.atual_id],status:j[m.pedidos].find(p=>p.id===ms[m.atual_id])[m.status],quantidade:j[m.pedidos].find(p=>p.id===ms[m.atual_id])[m.quantidade]}:null,decisaoEstoque:ms?.[m.fila]?.[ms[m.indice_fala]]?.[m.tipo]==='decisao',ativa:!!f,tempo:f?.[m.segundos],limite:f?.[m.limite_segundos],avisou:f?.[m.lembrete_exibido],lembrete:f?.[m.lembrete_segundos],venceu:f?.[m.venceu],concluida:f?.[m.concluida],pausado:j[m.pausado],setor:j[m.exploracao]?.[m.setor],cozinha:inv(j[m.cozinha]),mochila:inv(j[m.carregados]),painel:has?get(id,'painel')?.id:null,painelTipo:has?get(id,'painel')?.[m.tipo]:null,conferido:ms?.[m.estoque_consultado],decisoes:ms?.[m.decisoes]?.length,maquina:j[m.maquinas]?.[m.decisao],produzidos:j[m.producao][m.unidades_produzidas],vendas:j[m.financas][m.receitas_centavos],saldo:j[m.financas][m.saldo_centavos],bonusCaixa:j[m.financas][m.bonus_centavos],bonusTempo:f?.[m.bonus_tempo],resgates:f?.[m.resgates_usados],acertos:f?.[m.resgates_acertos],resgate:f?.[m.resgate]?{correta:f[m.resgate][m.correta],pergunta:f[m.resgate][m.pergunta]}:null,lote:has?get(id,'lote_em_curso'):null,progresso:has?get(id,'lote_frames'):null,quiz:ms?.[m.fila]?.[ms[m.indice_fala]]?.[m.tipo]==='pergunta'?{correta:ms[m.fila][ms[m.indice_fala]][m.correta],resposta:ms[m.resposta_atual]}:null};
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
  const shot=name=>frame.locator('#canvas').screenshot({path:'.testes/browser/logo-refinado-'+name+'.png'});
  const until=async(predicate,ms=20000)=>{const limit=Date.now()+ms;while(Date.now()<limit){if(await predicate())return;await page.waitForTimeout(200)}throw Error('Tempo excedido: '+JSON.stringify(await state()));};
  const acknowledgement=()=>frame.evaluate(()=>{const m=qaMap,j=global[m.jogo],c=j[m.confirmacao];return c?{acao:c[m.acao],titulo:c[m.titulo]}:null});
  const ack=async(action,enter=false)=>{
    assert.equal((await acknowledgement())?.acao,action);
    const paused=(await state()).tempo;await page.waitForTimeout(450);assert.equal((await state()).tempo,paused);
    await shot('confirmacao-'+action);
    if(enter)await key('Enter');else await click(790,500);
    assert.equal(await acknowledgement(),null);
  };
  await start();await shot('piso-final');await interact('porta_estoque',29,2);assert.equal((await state()).setor,'estoque');await shot('area-recebimento-final');assert.deepEqual(errors,[]);console.log(JSON.stringify({ok:true,mosaico_final:true,sala_estoque:true,errors}));
} finally {await browser.close()}
