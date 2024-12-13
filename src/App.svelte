<script>
  	import { onMount } from 'svelte';

    
    import svetof from './assets/334.jpg'
    // import svetof from './assets/svetof.png'
    import './assets/anticon.css'
  // import Counter from './lib/Counter.svelte'

  // import { gamutMapOKLCH, DisplayP3Gamut, sRGBGamut, OKLCH, serialize } from "@texel/color";
  import * as colors from "@texel/color";

  let canva, image, timer, ctx, data, imageData, data1;
  let delta = $state(0.012);
  let points = $state([]);
	let fillings = $state([]);

  const imageOnLoad = (ev) => {
    image = ev.target;
    update();
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
    let rgb = [data1[p]/256, data1[p+1]/256, data1[p+2]/256];
    const lch = colors.convert(rgb, colors.sRGB, colors.OKLab);
    points.push({lch, x, y, pos});
    // console.log('points:', points, fillings)

    update();

// debugger

  }
onMount(() => {
  ctx = canva.getContext('2d');
  canva.addEventListener('mousedown', onClick);
  // debugger
  const lch = colors.convert([1, 0, 0], colors.sRGB, colors.OKLab);

  // const t = serialize([1, 0, 0], OKLCH); // "oklch(1 0 0)"
  console.log('lch:', lch);
  update();
});

function update() {
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
</script>

<main>

  <div class="card">
    <canvas bind:this={canva}></canvas>
  </div>
  <div class="buttons">
    <input on:change={update} bind:value={delta} class="delta" type="number" step="0.001" min="0" /> - предел
    <button class="anticon anticon-info" aria-label="info"></button>
    <button class="anticon anticon-down-circle-o" aria-label="down"></button>
  </div>

  <details class="svetof" open>
    <summary>Точки</summary>
    <div class="card">
      <img on:load={imageOnLoad} src={svetof} class="svetof" alt="svetof" />
    </div>
    <ul>
      {#each points as item, i}
        {@const chk = item.disable ? false : true}

        <li><input on:change={(ev)=>{item.disable = !ev.checked; update();}} value="{i}" type="checkbox" checked={chk} /> {JSON.stringify(item)}</li>
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
  /* main canvas {
    width: 600px;
    height: 600px;
  } */
  .card img {
    display: none;
  }
  .card {
    border: 1px solid;
    background-color: blue;
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
