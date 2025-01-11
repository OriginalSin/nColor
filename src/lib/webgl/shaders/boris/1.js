const m = Array(
    Array(0, 0, 0, 1, 0, 1),
    Array(1, 1, 0, 1, 1, 1),
    Array(0, 0, 1, 0, 1, 0),
    Array(1, 0, 1, 1, 1, 1)
);
const mr = m.length;
const mc = m[0].length;

let m2 = Array(3*mr).fill(new Array(3*mc));
for (let i=0; i<mr; i++){
    for (let j=0; j<mc; j++){
        m2[3*i+1][3*j+1] = m[i][j];
    }
}
