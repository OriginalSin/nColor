<script>
// @ts-nocheck

  	import { onMount } from 'svelte';
  	import ImageTransform from './lib/webgl/ImageTransform.js';

    
    // import src from './assets/334_256.jpg'
    // import src from './assets/334.jpg'
    
    // import src from './assets/cleanColor.png'
    import src from './assets/svetof.png'
    import './assets/anticon.css'
  // import Counter from './lib/Counter.svelte'

  // import { gamutMapOKLCH, DisplayP3Gamut, sRGBGamut, OKLCH, serialize } from "@texel/color";
  import * as colors from "@texel/color";

  let imt, mainNode, canva, image, timer, ctx, data, imageData, data1;
  let delta = $state(0.6);
  let ugol = $state(Math.PI/4);
  let matrixKind = $state([0, 1, 2]);
  let povKind = $state(0);
    
  let points = $state([]);
	let fillings = $state([]);
  // let points = [];

  const ARR = [
    // 'perestanovka',
    // 'perestanovka',
    // 'perestanovka',
    // 'povorot',
    // 'perestanovka',
    // 'povorot',

    'detectEdges',
    // 'main'
  ];

  const init = async (src) => {
    let bitmap = await fetch(src).then(r=>r.blob()).then(createImageBitmap);
    const {width, height} = bitmap;
    // debugger
    const canvas = new OffscreenCanvas(width, height);
    const ctx = canvas.getContext('2d');
    ctx.drawImage(bitmap, 0, 0);

/*
    // const canvas = new OffscreenCanvas(width, height);
    const canvas = document.createElement('canvas');
    canvas.width = width;
    canvas.height = height;


    const ctx = canvas.getContext('2d');
    ctx.clearRect(0, 0, width, height);
    // ctx.drawImage(bitmap, 0, 0);
    ctx.beginPath();
    ctx.fillStyle="#ff0000";
    ctx.fillRect(10, 10, 100, 100);
    ctx.arc(180, 60, 50, 0, 2 * Math.PI);
    ctx.fill();

    ctx.beginPath();
    ctx.fillStyle="#00ff00";
    ctx.fillRect(10, 120, 100, 100);
    ctx.arc(180, 170, 50, 0, 2 * Math.PI);
    ctx.fill();

    ctx.beginPath();
    ctx.fillStyle="#0000ff";
    ctx.fillRect(10, 250, 100, 100);
    ctx.arc(180, 300, 50, 0, 2 * Math.PI);
    ctx.fill();


canvas.toBlob(function(blob) {
  // после того, как Blob создан, загружаем его
  let link = document.createElement('a');
  link.download = 'example.png';

  link.href = URL.createObjectURL(blob);
  link.click();

  // удаляем внутреннюю ссылку на Blob, что позволит браузеру очистить память
  URL.revokeObjectURL(link.href);
}, 'image/png');
*/
    // bitmap = canvas.transferToImageBitmap()
    // canva.width = width; canva.height = height;
    // debugger
    // ctx.setTransform(1, 0, 0, 1, canva.width * 0.5, canva.height * 0.5);
    // ctx.rotate(options.rotation / 180 * Math.PI);
    // ctx.scale(1.3, 1.3);
    // ctx.drawImage(image, 0, 0);
    // ctx.drawImage(img, -img.width * 0.5, -img.height * 0.5);
    // ctx.setTransform(1, 0, 0, 1, 0, 0);
    
    const imageData = ctx.getImageData(0, 0, width, height);
    data = new Uint8Array(imageData.data.buffer);

    imt = new ImageTransform({
      bitmap,
      canvas: canva,
      data: {ugol},
      arr: ARR
    }); 
    // debugger

    update();
    // debugger
  }
  const imageOnLoad = (ev) => {
    image = ev.target;
    // update();
    // debugger
  }
  const onClick = (ev) => {
    const {offsetX:x, offsetY:y} = ev;
    const {width, height} = canva;

    // const imageData1 = ctx.getImageData(0, 0, width, height);
    // let data = new Uint8Array(imageData1.data.buffer);

    // const {width:w, height:h} = imageData1;

    let pos = width * y + x;
    let p = 4 * pos;
    let rgb = [data[p]/256, data[p+1]/256, data[p+2]/256];
    const lch = colors.convert(rgb, colors.sRGB, colors.OKLab);
    points.push({lch, x, y, pos});
    // console.log('points:', points, fillings)

    update();

// debugger

  }
onMount(() => {
  init(src);
  canva.addEventListener('mousedown', onClick);

  // glUtils.createGL({src, canvas: canva.transferControlToOffscreen()});

  // ctx = canva.getContext('2d');
  // canva.addEventListener('mousedown', onClick);
  // // debugger
  // const lch = colors.convert([1, 0, 0], colors.sRGB, colors.OKLab);

  // // const t = serialize([1, 0, 0], OKLCH); // "oklch(1 0 0)"
  // console.log('lch:', lch);
});

function update() {
  const ar = ARR.filter(k => {
    return fillings.indexOf(k) === -1 ? false : true;
  })
  console.log('ar', ar);
  // const matrixKind = 1;
  // debugger
  imt.start([...ar, 'main'], {delta, ugol, matrixKind, povKind, points});

}

window.reDraw = update;

function update1() {  // чисто без WebGL
    cancelAnimationFrame(timer);
    timer = requestAnimationFrame(function() {
        render();
        trace();
    });
}

function render() {
  if (!image) return;
    // options = dash.getBound();
    const {width, height} = image;
    canva.width = width; canva.height = height;
    // debugger
    ctx.clearRect(0, 0, width, height);
    // ctx.setTransform(1, 0, 0, 1, canva.width * 0.5, canva.height * 0.5);
    // ctx.rotate(options.rotation / 180 * Math.PI);
    // ctx.scale(1.3, 1.3);
    ctx.drawImage(image, 0, 0);
    // ctx.drawImage(img, -img.width * 0.5, -img.height * 0.5);
    // ctx.setTransform(1, 0, 0, 1, 0, 0);
    
    imageData = ctx.getImageData(0, 0, width, height);
    data = new Uint8Array(imageData.data.buffer);
  if (!data1) {
    let imageData1 = ctx.getImageData(0, 0, width, height);
    data1 = new Uint8Array(imageData1.data.buffer);

    // data1 = data.slice();
  }
}

function trace() {
  if (!image || !points.length) return;
  const d = delta;
  let tt = {};

  for(let i = 0; i < data.length; i+=4) {
    if (data[i+3] === 0) continue;
    const rgb = [data[i]/256, data[i+1]/256, data[i+2]/256];
    const lch = colors.convert(rgb, colors.sRGB, colors.OKLab);
    let out = 100;
    for(let j = 0; j < points.length; j++) {
      if (points[j].disable) continue;
      let r = colors.deltaEOK(lch, points[j].lch);
      if (r < d) {
         out = 255;
         tt[r.toPrecision(3)] = {j, lch}
         break;
      }
    }
    data[i+3] = out;
  }
  // console.log('lch:', tt);
  ctx.putImageData(imageData, 0, 0);        // synchronous

}
const changeImg = (ev) => {
  const cls = mainNode.classList;
  if (ev.target.checked) cls.add('imgOn');
  else cls.remove('imgOn');
}
const changeCanv = (ev) => {
  const cls = mainNode.classList;
  if (ev.target.checked) cls.add('canvOn');
  else cls.remove('canvOn');
}

</script>

<main bind:this={mainNode} class="imgOn canvOn">

  <div class="card">
    <img onload={imageOnLoad} src={src} class="fromImg" alt="svetof" />
    <canvas bind:this={canva} class="resCanvas"></canvas>
  </div>
  <div class="buttons">
    <input oninput={update} bind:value={ugol} class="ugol" type="range" step="0.1" min="0" max={2*Math.PI} /> - предел
    <input list="ice-cream-flavors" onchange={update} bind:value={matrixKind} class="matrixKind" type="text"  /> - matrixKind
    <datalist id="ice-cream-flavors">
      <option>[0, 1, 2]</option>
      <option>[0, 2, 1]</option>
      <option>[1, 0, 2]</option>
      <option>[1, 2, 0]</option>
      <option>[2, 0, 1]</option>
      <option>[2, 1, 0]</option>

    </datalist>

    <input onchange={update} bind:value={delta} class="delta" type="number" step="0.01" min="0" /> - предел
    <fieldset>показать
      <input type="checkbox" checked onchange={changeImg} /> - Image
      <input type="checkbox" checked onchange={changeCanv} /> - Canvas
    </fieldset>
    <input onchange={update} bind:value={povKind} class="povKind" type="number" step="1" min="0" max="2" /> - вариант поворота

    <fieldset>Включать фильтры
      {#each ARR as k}
        {#if k !== 'main'}
          <input onchange={update} type="checkbox" bind:group={fillings} value={k} /> - {k}
        {/if}
    {/each}
    </fieldset>

    <button class="anticon anticon-info" aria-label="info"></button>
    <button class="anticon anticon-down-circle-o" aria-label="down"></button>
  </div>

  <details class="svetof" open>
    <summary>Точки</summary>
    <div class="card">
    </div>
    <ul>
      {#each points as item, i}
        {@const chk = item.disable ? false : true}

        <li><input onchange={(ev)=>{item.disable = !ev.checked; update();}} value="{i}" type="checkbox" checked={chk} /> {JSON.stringify(item)}</li>
      {/each}
    </ul>

  </details>


  <ul>
    <li>
      <a href="https://github.com/texel-org/color#readme" target="_blank" rel="noreferrer">color</a> Минимальная и современная библиотека цветов для JavaScript.
    </li>
    <li>
      <a href="https://github.com/claytongulick/quickhull#readme" target="_blank" rel="noreferrer">quickhull</a> Реализация алгоритма QuickHull на чистом JavaScript для поиска наименьшего многоугольника, охватывающего набор точек.
    </li>
  </ul>

  <p class="read-the-docs">
  </p>
</main>

<style>
  main.canvOn canvas.resCanvas {
    opacity: 0.7;
    /* opacity: 1; */

  }
  main.imgOn img.fromImg {
    opacity: 1;
  }
  main canvas.resCanvas ,
  main img.fromImg {
    opacity: 0;
  }
  .card canvas.resCanvas {
    left: 0;
    position: absolute;
  }
  
  .card {
    position: relative;
    border: 1px solid;
    background-color: gray;
    width: fit-content;
  }
  .delta {
    width: 4rem;
  }
  main ul {
    text-align: left;
    width: 22rem;
  }
  .buttons button {
    /* font-family: "ant"; */
  }
  /* .logo {
    height: 6em;
    padding: 1.5em;
    will-change: filter;
    transition: filter 300ms;
  }
  .logo:hover {
    filter: drop-shadow(0 0 2em #646cffaa);
  }
  .logo.svelte:hover {
    filter: drop-shadow(0 0 2em #ff3e00aa);
  } */
  .read-the-docs {
    color: #888;
  }
</style>
