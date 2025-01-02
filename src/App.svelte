<script>
// @ts-nocheck

  	import { onMount } from 'svelte';
  	import ImageTransform from './lib/webgl/ImageTransform.js';

    
    // import src from './assets/example.jpg'
    import src from './assets/334_256.jpg'
    // import src from './assets/334.jpg'
    
    // import src from './assets/cleanColor.png'
    // import src from './assets/svetof.png'
    import './assets/anticon.css'
  // import Counter from './lib/Counter.svelte'

  // import { gamutMapOKLCH, DisplayP3Gamut, sRGBGamut, OKLCH, serialize } from "@texel/color";
  import * as colors from "@texel/color";

  let imt, mainNode, canva, image, timer, ctx, data, imageData, data1, startXY;
  let cwidth = $state(1);
  let cheight = $state(1);
  let min = $state(0);
  let max = $state(100);
  let delta = $state(0.6);
  let ugol = $state(Math.PI/4);
  let matrixKind = $state([0, 1, 2]);
  let povKind = $state(0);
    
  let points = $state([]);
	let fillings = $state([]);
  // let points = [];

  const ARR = [
    'canny',
    // 'cy',
    // 'c2',

    // 'perestanovka',
    // 'povorot',
    // 'perestanovka',
    // 'grayscale',
    // 'cannyEdgeDetection',
    // 'intensityGradient',
    // 'detectEdges',
    // 'nonMaximumSuppress',
    // 'main'
  ];

  const init = async (src) => {
    let bitmap = await fetch(src).then(r=>r.blob()).then(createImageBitmap);
    const {width, height} = bitmap;
    // debugger
    const canvas = new OffscreenCanvas(width, height);
    const ctx = canvas.getContext('2d');
    ctx.drawImage(bitmap, 0, 0);
    cwidth = width;
    cheight = height;
    max = cheight / 2;
    console.log('cheight1:', cheight);

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
startXY = {x, y};
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
  //  console.log('cheight:', cheight);
  //  debugger

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
  // imt.start([...ar, 'main'], {min: min * 5, max: max * 30, delta, ugol, matrixKind, povKind, points});
  imt.start([...ar, 'main'], {min, max, delta, startXY, matrixKind, povKind, points});

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
  
  <!-- <details>
    <summary>SVG</summary>
    <div class="svg">
      <svg width="500" height="335" viewBox="0 0 500 335">
        <filter id="posterize">
            <feComponentTransfer>
              <feFuncR type="discrete" tableValues="0 .5 1" />
              <feFuncG type="discrete" tableValues="0 .5 1" />
              <feFuncB type="discrete" tableValues="0 1" />
            </feComponentTransfer>
        </filter>
    
        <image xlink:href={src} width="100%" height="100%" x="0" y="0" 
           filter="url(#posterize)"></image>
    </svg>
    </div>
  </details>

  <details>
    <summary>SVG1</summary>
    <div class="svg">
      <svg width="300" height="300">
        <defs>
        <pattern id='puntos' x='0' y='0' width='40' height='40' overflow='visible' patternUnits="userSpaceOnUse">
        <circle cx='10' cy='10' r='10' style='stroke:black;stroke-width:1;fill:red'/>
        <circle cx='30' cy='30' r='10' height='20' style='stroke:black;stroke-width:1;fill:red'/>
        </pattern>
        <g id='img1'>
        <rect x="0" y="0" width="300" height="300" fill="white"/>  
        <rect x="0" y="0" width="300" height="300" fill="url(#puntos)"/>
        </g>
          
        
        <g id='img2'>
        <circle cx="50%" cy="50%" r="50%" style="stroke:none;fill:red"/>
        <circle cx="50%" cy="50%" r="45%" style="stroke:none;fill:white"/>
        <circle cx="50%" cy="50%" r="40%" style="stroke:none;fill:red"/>
        <circle cx="50%" cy="50%" r="35%" style="stroke:none;fill:white"/>
        <circle cx="50%" cy="50%" r="30%" style="stroke:none;fill:red"/>
        <circle cx="50%" cy="50%" r="25%" style="stroke:none;fill:white"/>
        <circle cx="50%" cy="50%" r="20%" style="stroke:none;fill:red"/>
        <circle cx="50%" cy="50%" r="15%" style="stroke:none;fill:white"/>
        <circle cx="50%" cy="50%" r="10%" style="stroke:none;fill:red"/>
        <circle cx="50%" cy="50%" r="5%" style="stroke:none;fill:white"/>
        </g>
        
          
        <radialGradient id="radialGradient" r=".7">  
            <stop offset="0%" stop-color="#f00"></stop>
            <stop offset="5%" stop-color="#fff"></stop>
            <stop offset="10%" stop-color="#f00"></stop>
            <stop offset="15%" stop-color="#fff"></stop>
            <stop offset="20%" stop-color="#f00"></stop>
            <stop offset="25%" stop-color="#fff"></stop>
            <stop offset="30%" stop-color="#f00"></stop>
            <stop offset="35%" stop-color="#fff"></stop>
            <stop offset="40%" stop-color="#f00"></stop>
            <stop offset="45%" stop-color="#fff"></stop> 
            <stop offset="50%" stop-color="#f00"></stop>
            <stop offset="55%" stop-color="#fff"></stop>
            <stop offset="60%" stop-color="#f00"></stop>
            <stop offset="65%" stop-color="#fff"></stop>
            <stop offset="70%" stop-color="#f00"></stop>
            <stop offset="75%" stop-color="#fff"></stop>
            <stop offset="80%" stop-color="#f00"></stop>
            <stop offset="85%" stop-color="#fff"></stop>
            <stop offset="90%" stop-color="#f00"></stop>
            <stop offset="95%" stop-color="#fff"></stop>
            <stop offset="100%" stop-color="#f00"></stop>     
        </radialGradient> 
        
        <rect id='img3' fill="url(#radialGradient)" width="300" height="300"></rect>
          
        <pattern id='deCuadros' x='0' y='0' width='40' height='40' overflow='visible' patternUnits="userSpaceOnUse">
        <rect x='0' y='0' width='20' height='20' style='stroke:black;stroke-width:1;fill:red'/>
        <rect x='20' y='20' width='20' height='20' style='stroke:black;stroke-width:1;fill:red'/>
        </pattern>
        <g id="img4">  
        <rect x="0" y="0" width="300" height="300" fill="white"/>
        <rect x="0" y="0" width="300" height="300" fill="url(#deCuadros)"/>
        </g>  
          
          
        <filter id="filter1" filterUnits="userSpaceOnUse" x="0" y="0" width="300" height="300">
          <feImage xlink:href="data:image/svg+xml;utf8,%3Csvg width='300' height='300' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Cdefs%3E%3Cpattern id='Fpuntos' x='0' y='0' width='40' height='40' overflow='visible' patternUnits='userSpaceOnUse'%3E%3Ccircle cx='10' cy='10' r='10' style='stroke:black;stroke%2Dwidth:1;fill:red'/%3E%3Ccircle cx='30' cy='30' r='10' height='20' style='stroke:black;stroke%2Dwidth:1;fill:red'/%3E%3C/pattern%3E%3C/defs%3E%3Cg id='img1'%3E%3Crect x='0' y='0' width='300' height='300' fill='white'/%3E %3Crect x='0' y='0' width='300' height='300' fill='url(%23Fpuntos)'/%3E%3C/g%3E%3C/svg%3E" result='img1'/>
          <feDisplacementMap scale="15" xChannelSelector="R" yChannelSelector="G" in2="img1" in="SourceGraphic"/>
        </filter>
        
        <filter id="filter2" filterUnits="userSpaceOnUse" x="0" y="0" width="300" height="300">
            <feImage xlink:href="data:image/svg+xml;utf8,%3Csvg width='300' height='300' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Cg %3E%3Ccircle cx='50%25' cy='50%25' r='50%25' style='stroke:none;fill:red'/%3E%3Ccircle cx='50%25' cy='50%25' r='45%25' style='stroke:none;fill:white'/%3E%3Ccircle cx='50%25' cy='50%25' r='40%25' style='stroke:none;fill:red'/%3E%3Ccircle cx='50%25' cy='50%25' r='35%25' style='stroke:none;fill:white'/%3E%3Ccircle cx='50%25' cy='50%25' r='30%25' style='stroke:none;fill:red'/%3E%3Ccircle cx='50%25' cy='50%25' r='25%25' style='stroke:none;fill:white'/%3E%3Ccircle cx='50%25' cy='50%25' r='20%25' style='stroke:none;fill:red'/%3E%3Ccircle cx='50%25' cy='50%25' r='15%25' style='stroke:none;fill:white'/%3E%3Ccircle cx='50%25' cy='50%25' r='10%25' style='stroke:none;fill:red'/%3E%3Ccircle cx='50%25' cy='50%25' r='5%25' style='stroke:none;fill:white'/%3E%3C/g%3E%3C/svg%3E" result='img2'/>
            <feDisplacementMap scale="15" xChannelSelector="R" yChannelSelector="G" in2="img2" in="SourceGraphic"/>
        </filter>
      
        <filter id="filter3" filterUnits="userSpaceOnUse" x="0" y="0" width="300" height="300">
          <feImage xlink:href="data:image/svg+xml;utf8,%3Csvg width='300' height='300' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Cdefs%3E %3CradialGradient id='FradialGradient' r='.7'%3E %3Cstop offset='0%25' stop%2Dcolor='%23f00'%3E%3C/stop%3E%3Cstop offset='5%25' stop%2Dcolor='%23fff'%3E%3C/stop%3E%3Cstop offset='10%25' stop%2Dcolor='%23f00'%3E%3C/stop%3E%3Cstop offset='15%25' stop%2Dcolor='%23fff'%3E%3C/stop%3E%3Cstop offset='20%25' stop%2Dcolor='%23f00'%3E%3C/stop%3E%3Cstop offset='25%25' stop%2Dcolor='%23fff'%3E%3C/stop%3E%3Cstop offset='30%25' stop%2Dcolor='%23f00'%3E%3C/stop%3E%3Cstop offset='35%25' stop%2Dcolor='%23fff'%3E%3C/stop%3E%3Cstop offset='40%25' stop%2Dcolor='%23f00'%3E%3C/stop%3E%3Cstop offset='45%25' stop%2Dcolor='%23fff'%3E%3C/stop%3E%3Cstop offset='50%25' stop%2Dcolor='%23f00'%3E%3C/stop%3E%3Cstop offset='55%25' stop%2Dcolor='%23fff'%3E%3C/stop%3E%3Cstop offset='60%25' stop%2Dcolor='%23f00'%3E%3C/stop%3E%3Cstop offset='65%25' stop%2Dcolor='%23fff'%3E%3C/stop%3E%3Cstop offset='70%25' stop%2Dcolor='%23f00'%3E%3C/stop%3E%3Cstop offset='75%25' stop%2Dcolor='%23fff'%3E%3C/stop%3E%3Cstop offset='80%25' stop%2Dcolor='%23f00'%3E%3C/stop%3E%3Cstop offset='85%25' stop%2Dcolor='%23fff'%3E%3C/stop%3E%3Cstop offset='90%25' stop%2Dcolor='%23f00'%3E%3C/stop%3E%3Cstop offset='95%25' stop%2Dcolor='%23fff'%3E%3C/stop%3E%3Cstop offset='100%25' stop%2Dcolor='%23f00'%3E%3C/stop%3E %3C/radialGradient%3E%3C/defs%3E%3Crect fill='url(%23FradialGradient)' width='300' height='300'%3E%3C/rect%3E%3C/svg%3E" result='img3'/>
          <feDisplacementMap scale="15" xChannelSelector="R" yChannelSelector="G" in2="img3" in="SourceGraphic"/>
        </filter>
      
        <filter id="filter4" filterUnits="userSpaceOnUse" x="0" y="0" width="300" height="300">
          <feImage xlink:href="data:image/svg+xml;utf8,%3Csvg width='300' height='300' xmlns='http://www.w3.org/2000/svg' xmlns:xlink='http://www.w3.org/1999/xlink'%3E%3Cpattern id='FdeCuadros' x='0' y='0' width='40' height='40' overflow='visible' patternUnits='userSpaceOnUse'%3E%3Crect x='0' y='0' width='20' height='20' style='stroke:black;stroke%2Dwidth:1;fill:red'/%3E%3Crect x='20' y='20' width='20' height='20' style='stroke:black;stroke%2Dwidth:1;fill:red'/%3E%3C/pattern%3E%3Cg id='img4'%3E %3Crect x='0' y='0' width='300' height='300' fill='white'/%3E%3Crect x='0' y='0' width='300' height='300' fill='url(%23FdeCuadros)'/%3E%3C/g%3E%3C/svg%3E" result='img4'/>
          <feDisplacementMap scale="15" xChannelSelector="R" yChannelSelector="G" in2="img4" in="SourceGraphic"/>
        </filter>  
          
        </defs>
          
        <image xmlns:xlink={src} height="300" width="300" filter="url(#filter1)" />
        <use xlink:href ="#img1" transform="scale(.25)" />
      </svg>
        
          <svg width="300" height="300">
           <image xmlns:xlink={src} height="300" width="300" filter="url(#filter2)" />
          <use xlink:href ="#img2" transform="scale(.25)" />
        </svg>
          <svg width="300" height="300">
           <image xmlns:xlink="{src}" height="300" width="300" filter="url(#filter3)" />
          <use xlink:href ="#img3" transform="scale(.25)" />
        </svg>
          <svg width="300" height="300">
           <image xmlns:xlink="{src}" height="300" width="300" filter="url(#filter4)" />
          <use xlink:href ="#img4" transform="scale(.25)" />
        </svg>
    </div>
  </details> -->


  <div class="buttons">
    min: <input oninput={update} bind:value={min} class="min" type="range" min="0" max={cwidth} />
    max: <input oninput={update} bind:value={max} class="max" type="range" min="0" max={cheight} />

    <!-- <input oninput={update} bind:value={ugol} class="ugol" type="range" step="0.1" min="0" max={2*Math.PI} /> - предел
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
    <input onchange={update} bind:value={povKind} class="povKind" type="number" step="1" min="0" max="2" /> - вариант поворота -->

    <fieldset>Включать фильтры
      {#each ARR as k}
        {#if k !== 'main'}
          <input onchange={update} type="checkbox" bind:group={fillings} value={k} /> - {k}
        {/if}
    {/each}
    </fieldset>

    <!-- <button class="anticon anticon-info" aria-label="info"></button>
    <button class="anticon anticon-down-circle-o" aria-label="down"></button> -->
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


  <!-- <ul>
    <li>
      <a href="https://github.com/texel-org/color#readme" target="_blank" rel="noreferrer">color</a> Минимальная и современная библиотека цветов для JavaScript.
    </li>
    <li>
      <a href="https://github.com/claytongulick/quickhull#readme" target="_blank" rel="noreferrer">quickhull</a> Реализация алгоритма QuickHull на чистом JavaScript для поиска наименьшего многоугольника, охватывающего набор точек.
    </li>
  </ul> -->

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
