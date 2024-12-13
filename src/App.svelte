<script>
  	import { onMount } from 'svelte';


  import svetof from './assets/svetof.png'
  import viteLogo from '/vite.svg'
  import Counter from './lib/Counter.svelte'

  import { gamutMapOKLCH, DisplayP3Gamut, sRGBGamut, OKLCH, serialize } from "@texel/color";

  let mCanvas;

  // Some value that may or may not be in sRGB gamut
  const oklch = [ 0.15, 0.425, 30 ];

  // decide what gamut you want to map to
  const isDisplayP3Supported = true; /* check env */;
  const gamut = isDisplayP3Supported ? DisplayP3Gamut : sRGBGamut;

  // map the input OKLCH to the R,G,B space (sRGB or DisplayP3)
  const rgb = gamutMapOKLCH(oklch, gamut);

  // get a CSS color string for your output space
  const color = serialize(rgb, gamut.space);

onMount(() => {
  const t = serialize([1, 0, 0], OKLCH); // "oklch(1 0 0)"
  console.log('serialize:', t);
  // draw color to a Canvas2D context
  // const canvas = document.createElement('canvas');
  const context = mCanvas.getContext('2d', {
    colorSpace: gamut.id
  });
  context.fillStyle = color;
  context.fillRect(0,0, mCanvas.width, mCanvas.height);
});

</script>

<main>
  <details class="svetof">
    <summary>svetof</summary>
    <div>
      <img src={svetof} class="svetof" alt="svetof" />
    </div>
  </details>

  <h1>++++</h1>

  <div class="card">
    <canvas bind:this={mCanvas}></canvas>
  </div>

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
  main canvas {
    width: 600px;
    height: 600px;
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
