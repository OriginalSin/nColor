const data = Array(
    Array(0, 0, 0, 1, 0, 1),
    Array(1, 1, 0, 1, 1, 1),
    Array(0, 0, 1, 0, 1, 0),
    Array(1, 0, 1, 1, 1, 1)
);
const data2control = Array(
    Array(4, 4, 4, 4, 4, 4, 4, 4, 4, 3, 3, 3, 4, 4, 4, 3, 3, 3),
    Array(4, 0, 2, 2, 0, 2, 2, ),
    Array(1, 1, 0, 1, 1, 1),
    Array(0, 0, 1, 0, 1, 0),
    Array(1, 0, 1, 1, 1, 1)
);
const h = data.length;
const w = data[0].length;
const b = Array(0.2,0.4);
let data2 = Array(3*h).fill(new Array(3*w));
for(let i=0; i<h; i++){
    for(let j=0; j<w; j++){
        data2[3*i + 1][3*j + 1] = data[i][j];
    	bc = data[i][j] < 0.5 ? b[0] : b[1];
        bcf = data[i][j] < 0.5 ? b[1] : b[0];
        u = i == 0 || 0.5 < Math.abs(data[i - 1][j] - data[i][j]);
        ul = i == 0 || j == 0 || Math.abs(data[i - 1][j - 1] - data[i][j]) > 0.5;
        ur = i == 0 || j == w-1 || Math.abs(data[i - 1][j + 1] - data[i][j]) > 0.5;
        d = i == h-1 || Math.abs(data[i + 1, j] - data[i][j]) > 0.5;
        dl = i == h-1 || j == 0 || Math.abs(data[i + 1][j - 1] - data[i][j]) > 0.5;
        dr = i == h-1 || j == w-1 || Math.abs(data[i + 1][j + 1] - data[i][j]) > 0.5;
        l = j == 0 || Math.abs(data[i][j - 1] - data[i][j]) > 0.5;
        r = j == w-1 || Math.abs(data[i][j + 1] - data[i][j]) > 0.5;
        if (l) data2[3*i + 1][3*j] = bc;
        if (r) data2[3*i][3*j+2] = bc;
        if (u) data2[3*i][3*j + 1] = bc;
        if (d) data2[3*i+2][3*j + 1] = bc;
        if (u && l) data2[3*i][3*j] = bc;
        if (u && r) data2[3*i][3*j+2] = bc;
        if (d && r) data2[3*i+2][3*j+2] = bc;
        if (d && l) data2[3*i+2][3*j] = bc;
        if (u && ur && !r) data2[3*i][3*j+2] = bc;
        if (j < w-1) data2[3*i][3*j + 3] = bc;
        if (d && dr && !r) data2[3*i+2][3*j+2] = bc;
        if (j < w-1) data2[3*i+2][3*j + 3] = bc;
        if (l && dl && !d) data2[3*i+2][3*j] = bc;
        if (i < h-1) data2[3*i + 3][3*j] = bc;
        if (r && dr && !d) data2[3*i+2][3*j+2] = bc;
        if (i < h-1) data2[3*i + 3][3*j+2] = bc;
        if (0 < i && 0 < j && l && ul && u) {
            data2[3*i + 1][3*j+2] = bcf;
            data2[3*i][3*j - 1] = bcf;
            data2[3*i - 1][3*j - 1] = bcf;
        }
        if (i < h-1 && 0 < j && l && dl && d){
            data2[3*i+2][3*j - 1] = bcf;
            data2[3*i + 3][3*j - 1] = bcf;
            data2[3*i + +3][3*j] = bcf;
        }
        if (0 < i && j < w-1 && r && ur && u){
            data2[3*i - 1][3*j+2] = bcf;
            data2[3*i - 1][3*j + 3] = bcf;
            data2[3*i][3*j + 3] = bcf;
        }
        if (i < h-1 && j < w-1 && r && dr && d){
            data2[3*i + 3][3*j+2] = bcf;
            data2[3*i + 3][3*j + 3] = bcf;
            data2[3*i+2][3*j + 3] = bcf;
        }
    }
}
console.log(data2)
