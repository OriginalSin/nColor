/*
Trace
*/
function tracePath(opt={}) {
    const {buf, cx=0, cy=0, width:cw, height:ch,
        startXY={x:0, y:0},
        padding=0,
        alignWeight=0.95
    } = opt;
    if (!buf) return;
    const alpha = Math.max(0, Math.min(254, opt.alpha || 0));
    const tolerance = Math.max(0, opt.tolerance || 0);
    const doAlign = !!opt.align;
    // const padding = opt.padding || 0;
    // const alignWeight = opt.alignWeight || 0.95;

    let lastPos = opt.lastPos || 0;
    if (startXY) {   // откуда ищем
        lastPos = cw * startXY.y + startXY.x;
    }
    var path = [],
        // data, l,
        i, x, y, sx, sy,
        start = -1,
        step, pStep = 9,
        steps = [9, 0, 3, 3, 2, 0, 9, 3, 1, 9, 1, 1, 2, 0, 2, 9];

    // let	buf = ctx.getImageData(cx, cy, cw, ch).data.buffer;
    // let data1 = new Uint8Array(buf);

    // data = new Uint32Array(buf);
    const data = new Uint32Array(buf);
    const l = data.length;

    // start position
    for(i = lastPos; i < l; i++) {
        if (data[i] > alpha) {
            start = lastPos = i;
            break;
        }
    }
    // march from start point until start point
    if (start >= 0) {
        // calculate start position
        x = sx = (start % cw) | 0;
        y = sy = (start / cw) | 0;

        do {
            step = getNextStep(x, y);

            if (step === 0) y--;
            else if (step === 1) y++;
            else if (step === 2) x--;
            else if (step === 3) x++;

            if (step !== pStep) {
                path.push({x: x + cx, y: y + cy});
                pStep = step;
            }
        } while(x !== sx || y !== sy);

        // point reduction?
        if (tolerance)
            path = reduce(path, tolerance);

        // align? (only if no padding)
        if (doAlign && !padding)
            path = align(path, alignWeight);
    }

    // lookup pixel
    function getState(x, y) {
        return (x >= 0 && y >= 0 && x < cw && y < ch) ? (data[y * cw + x]>>>24) > alpha : false;
    }

    // Parse 2x2 pixels to determine next step direction.
    // See https://en.wikipedia.org/wiki/Marching_squares for details.
    // Note: does not do clockwise cycle as in the original specs, but line by line.
    function getNextStep(x, y) {
        var v = 0;
        if (getState(x - 1, y - 1)) v |= 1;
        if (getState(x, y - 1)) v |= 2;
        if (getState(x - 1, y)) v |= 4;
        if (getState(x, y)) v |= 8;

        if (v === 6)
            return pStep === 0 ? 2 : 3;
        else if (v === 9)
            return pStep === 3 ? 0 : 1;
        else
            return steps[v];
    }

    // Ramer Douglas Peucker with correct distance point-to-line
    function reduce(points, epsilon) {
        var len1 = points.length - 1;
        if (len1 < 2) return points;

        var fPoint = points[0],
            lPoint = points[len1],
            epsilon2 = epsilon * epsilon,
            i, index = -1,
            cDist, dist = 0,
            l1, l2, r1, r2;

        for (i = 1; i < len1; i++) {
            cDist = distPointToLine(points[i], fPoint, lPoint);
            if (cDist > dist) {
                dist = cDist;
                index = i
            }
        }

        if (dist > epsilon2) {
            l1 = points.slice(0, index + 1);
            l2 = points.slice(index);
            r1 = reduce(l1, epsilon);
            r2 = reduce(l2, epsilon);
            return r1.slice(0, r1.length - 1).concat(r2)
        }
        else
            return [fPoint, lPoint]
    }

    function distPointToLine(p, l1, l2) {

        var lLen = dist(l1, l2), t;

        if (!lLen)
            return 0;

        t = ((p.x - l1.x) * (l2.x - l1.x) + (p.y - l1.y) * (l2.y - l1.y)) / lLen;

        if (t < 0)
            return dist(p, l1);
        else if (t > 1)
            return dist(p, l2);
        else
            return dist(p, { x: l1.x + t * (l2.x - l1.x), y: l1.y + t * (l2.y - l1.y)});
    }

    function dist(p1, p2) {
        var dx = p1.x - p2.x,
            dy = p1.y - p2.y;
        return dx * dx + dy * dy
    }

    // Align by K3N
    function align(points, w) {

        var ox = [1, -1, -1, 1],
            oy = [1, 1, -1, -1],
            p, t = 0;

        while(p = points[t++]) {

            p.x = Math.round(p.x);
            p.y = Math.round(p.y);

            for(var i = 0, tx, ty, dx, dy; i < 4; i++) {
                dx = ox[i];
                dy = oy[i];
                tx = p.x + (dx<<1);
                ty = p.y + (dy<<1);
                if (tx > cx && ty > cy && tx < cw - 1 && ty < ch - 1) {
                    if (!getState(tx, ty)) {
                        tx -= dx;
                        ty -= dy;
                        if (getState(tx, ty)) {
                            p.x += dx * w;
                            p.y += dy * w;
                        }
                    }
                }
            }
        }

        return points
    }

    return path
}
export default tracePath;