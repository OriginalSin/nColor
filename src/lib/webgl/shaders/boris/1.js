const m = [
    [0, 0, 0, 1, 0, 1],
    [1, 1, 0, 1, 1, 1],
    [0, 0, 1, 0, 1, 0],
    [1, 0, 1, 1, 1, 1]
];
const mr = m.length;
const mc = m[0].length;
console.log('init', mr, mc, m);


const getD_for = (m) => {
    const d = [];
    const dc = 3 * m[0].length;

    let pr;
    for (let r = 0; r < m.length; r++) {
        pr = 2 * r;
        d[pr] = new Array(dc).fill('_');
        const d1 = new Array(dc).fill('_');
        const m1 = m[r];
        for (let c = 0; c < m1.length; c++) {
            let pc = 2 * c;
            const v = m1[c];

            d1[1 + pc] = v;
            // console.log('___', pr, pc, v, d1[pc]);
        }
        d[1 + pr] = d1;
        // console.log('___', pr, d1);

    }
    d[2 + pr] = new Array(dc).fill('_');

    return d;
}

const getD = (m, fill='') => {
    const d = [];
    const dc = 3 * m[0].length;

    m.forEach((m1, r)=>{
        let pr = 3 * r;
        const d1 = new Array(dc).fill(fill);
        m1.forEach((v, c)=>{
            let pc = 3 * c;
            d1[0 + pc] = d1[2 + pc] = fill;
            d1[1 + pc] = v;
        });
        d[1 + pr] = d1;
        d[2 + pr] = new Array(dc).fill(fill);
        d[pr] = new Array(dc).fill(fill);

    })
    return d;
}

// console.log('res', getD_for(m));
const d = getD(m, '_');
console.log('res', d.length, d[0].length);
d.forEach((k, i)=>console.log(i, k.join()))

// node F:\gitGlobe\nColor\src\lib\webgl\shaders\boris\1.js