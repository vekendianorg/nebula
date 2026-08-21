(function() {
    'use strict';

    var canvas = document.getElementById('particle-canvas');
    if (!canvas) return;
    var ctx = canvas.getContext('2d');
    if (!ctx) return;

    var width, height, dpr;
    var particles = [];
    var mouse = { x: -1000, y: -1000 };
    var time = 0;
    var running = true;
    var rafId = null;
    var lastTime = 0;

    var CHARS = ['.', '\u00B7', '\u2022', ',', '`', '\u00B7', '\u00B7', '.', '\u00B7', '\u00B7'];
    var COLORS = ['#A855F7', '#8B5CF6', '#6366F1', '#3B82F6', '#06B6D4'];

    var SHAPE_DURATION = 7000;
    var shapeNames = ['text', 'nebula', 'wave', 'constellation', 'cube'];
    var shapeIndex = 0;
    var currentShape = shapeNames[0];
    var lastShapeChange = 0;
    var textTargets = [];
    var shapeTargets = {};

    function resize() {
        dpr = Math.min(window.devicePixelRatio || 1, 2);
        width = window.innerWidth;
        height = window.innerHeight;
        canvas.width = Math.floor(width * dpr);
        canvas.height = Math.floor(height * dpr);
        canvas.style.width = width + 'px';
        canvas.style.height = height + 'px';
        ctx.setTransform(1, 0, 0, 1, 0, 0);
        ctx.scale(dpr, dpr);
        generateTargets();
    }

    function sampleText() {
        var off = document.createElement('canvas');
        var octx = off.getContext('2d');
        var fontSize = Math.min(width * 0.11, 72);
        off.width = Math.floor(width * dpr);
        off.height = Math.floor(height * dpr);
        octx.scale(dpr, dpr);
        octx.fillStyle = '#fff';
        octx.font = '700 ' + fontSize + 'px "JetBrains Mono", monospace';
        octx.textAlign = 'center';
        octx.textBaseline = 'middle';
        var cy = height / 2;
        octx.fillText('Nebula', width / 2, cy - fontSize * 0.55);
        octx.fillText('SDK', width / 2, cy + fontSize * 0.55);
        var imgData = octx.getImageData(0, 0, off.width, off.height).data;
        var points = [];
        var step = 3;
        for (var y = 0; y < off.height; y += step) {
            for (var x = 0; x < off.width; x += step) {
                var idx = (y * off.width + x) * 4;
                if (imgData[idx + 3] > 128) {
                    points.push({ x: x / dpr, y: y / dpr });
                }
            }
        }
        return points;
    }

    function generateTargets() {
        var cx = width / 2;
        var cy = height / 2;
        var scale = Math.min(width, height) / 800;

        textTargets = sampleText();

        shapeTargets.nebula = [];
        for (var i = 0; i < 300; i++) {
            var angle = Math.random() * Math.PI * 2;
            var dist = Math.random() * 350 * scale;
            shapeTargets.nebula.push({ x: cx + Math.cos(angle) * dist, y: cy + Math.sin(angle) * dist * 0.6 });
        }

        shapeTargets.wave = [];
        for (var i = 0; i < 300; i++) {
            var t = i / 300;
            shapeTargets.wave.push({ x: cx + (t - 0.5) * 600 * scale, y: cy + Math.sin(t * Math.PI * 4) * 60 * scale });
        }

        shapeTargets.constellation = [];
        var starPts = [
            {x:-200,y:-100}, {x:-100,y:-150}, {x:0,y:-80},
            {x:100,y:-140}, {x:200,y:-90}, {x:-150,y:0},
            {x:-50,y:50}, {x:50,y:-20}, {x:150,y:40},
            {x:-100,y:120}, {x:0,y:100}, {x:100,y:130}
        ];
        starPts.forEach(function(p) {
            shapeTargets.constellation.push({ x: cx + p.x * scale, y: cy + p.y * scale });
        });
        for (var i = 0; i < 100; i++) {
            var a = starPts[Math.floor(Math.random() * starPts.length)];
            var b = starPts[Math.floor(Math.random() * starPts.length)];
            var t = Math.random();
            shapeTargets.constellation.push({ x: cx + (a.x + (b.x - a.x) * t) * scale, y: cy + (a.y + (b.y - a.y) * t) * scale });
        }

        shapeTargets.cube = [];
        var cSize = 80 * scale;
        var cVerts = [
            {x:-1,y:-1,z:-1}, {x:1,y:-1,z:-1}, {x:1,y:1,z:-1}, {x:-1,y:1,z:-1},
            {x:-1,y:-1,z:1}, {x:1,y:-1,z:1}, {x:1,y:1,z:1}, {x:-1,y:1,z:1}
        ];
        var edges = [[0,1],[1,2],[2,3],[3,0],[4,5],[5,6],[6,7],[7,4],[0,4],[1,5],[2,6],[3,7]];
        edges.forEach(function(edge) {
            var a = cVerts[edge[0]], b = cVerts[edge[1]];
            for (var t = 0; t <= 1; t += 0.04) {
                var x = a.x + (b.x-a.x)*t, y = a.y + (b.y-a.y)*t, z = a.z + (b.z-a.z)*t;
                var proj = 300 / (300 + z * cSize * 0.5);
                shapeTargets.cube.push({ x: cx + x*cSize*proj, y: cy + y*cSize*proj });
            }
        });
    }

    function initParticles() {
        particles = [];
        var count = Math.min(Math.floor((width * height) / 5000), 1200);
        for (var i = 0; i < count; i++) {
            particles.push({
                x: Math.random() * width,
                y: Math.random() * height,
                vx: 0, vy: 0,
                size: Math.random() * 1.8 + 0.8,
                char: CHARS[Math.floor(Math.random() * CHARS.length)],
                color: COLORS[Math.floor(Math.random() * COLORS.length)],
                alpha: Math.random() * 0.4 + 0.15,
                phase: Math.random() * Math.PI * 2,
                targetIndex: i
            });
        }
    }

    function getTarget(p, shape) {
        var targets = (shape === 'text') ? textTargets : (shapeTargets[shape] || shapeTargets.nebula);
        if (!targets || targets.length === 0) return null;
        return targets[p.targetIndex % targets.length];
    }

    function updateParticles(dt) {
        time += dt * 0.001;
        var now = Date.now();

        if (now - lastShapeChange > SHAPE_DURATION) {
            shapeIndex = (shapeIndex + 1) % shapeNames.length;
            currentShape = shapeNames[shapeIndex];
            lastShapeChange = now;
        }

        var isText = currentShape === 'text';
        var attractStrength = isText ? 0.025 : 0.008;
        var noiseStrength = isText ? 0.02 : 0.08;

        for (var i = 0; i < particles.length; i++) {
            var p = particles[i];
            var target = getTarget(p, currentShape);

            p.x += Math.sin(time * 0.5 + p.phase) * noiseStrength;
            p.y += Math.cos(time * 0.3 + p.phase * 0.7) * noiseStrength;

            if (target) {
                var dx = target.x - p.x;
                var dy = target.y - p.y;
                p.vx += dx * attractStrength;
                p.vy += dy * attractStrength;
            }

            var mdx = p.x - mouse.x;
            var mdy = p.y - mouse.y;
            var mdist = Math.sqrt(mdx*mdx + mdy*mdy);
            if (mdist < 120 && mdist > 0) {
                var mf = (120 - mdist) / 120 * 0.8;
                p.vx += (mdx / mdist) * mf;
                p.vy += (mdy / mdist) * mf;
            }

            p.vx *= 0.92;
            p.vy *= 0.92;
            p.x += p.vx;
            p.y += p.vy;

            if (!isText) {
                if (p.x < -30) p.x = width + 30;
                if (p.x > width + 30) p.x = -30;
                if (p.y < -30) p.y = height + 30;
                if (p.y > height + 30) p.y = -30;
            }

            p.alpha = 0.2 + Math.sin(time * 0.5 + p.phase) * 0.12 + 0.1;
        }
    }

    function drawParticles() {
        ctx.clearRect(0, 0, width, height);

        if (currentShape === 'constellation') {
            ctx.strokeStyle = 'rgba(139, 92, 246, 0.06)';
            ctx.lineWidth = 0.5;
            for (var i = 0; i < particles.length; i++) {
                for (var j = i + 1; j < particles.length; j++) {
                    var dx = particles[i].x - particles[j].x;
                    var dy = particles[i].y - particles[j].y;
                    var dist = Math.sqrt(dx*dx + dy*dy);
                    if (dist < 80) {
                        ctx.beginPath();
                        ctx.moveTo(particles[i].x, particles[i].y);
                        ctx.lineTo(particles[j].x, particles[j].y);
                        ctx.stroke();
                    }
                }
            }
        }

        for (var i = 0; i < particles.length; i++) {
            var p = particles[i];
            ctx.font = (p.size * 8) + 'px "JetBrains Mono", monospace';
            ctx.fillStyle = p.color;
            ctx.globalAlpha = Math.max(0, Math.min(1, p.alpha));
            ctx.fillText(p.char, p.x, p.y);
        }
        ctx.globalAlpha = 1;
    }

    document.addEventListener('mousemove', function(e) {
        mouse.x = e.clientX;
        mouse.y = e.clientY;
    });

    function animate() {
        rafId = requestAnimationFrame(animate);
        if (!running) return;
        var now = Date.now();
        var dt = now - lastTime;
        lastTime = now;
        if (dt > 200) dt = 16;
        if (dt < 0) dt = 16;
        try {
            updateParticles(dt);
            drawParticles();
        } catch (e) {
            console.error('Particle error:', e);
        }
    }

    function start() {
        running = true;
        lastTime = Date.now();
        if (!rafId) animate();
    }

    function stop() { running = false; }

    document.addEventListener('visibilitychange', function() {
        document.hidden ? stop() : start();
    });
    window.addEventListener('pageshow', start);
    window.addEventListener('focus', start);
    window.addEventListener('blur', stop);

    setInterval(function() {
        if (!document.hidden && Date.now() - lastTime > 1000) start();
    }, 1000);

    window.addEventListener('resize', function() {
        resize();
        initParticles();
    });

    resize();
    initParticles();
    lastShapeChange = Date.now();
    start();

    // Lock zoom on pages that lock scroll (home hero)
    document.addEventListener('gesturestart', function(e) { e.preventDefault(); });
    document.addEventListener('touchmove', function(e) {
        if (e.touches.length > 1 && document.body.classList.contains('locked')) e.preventDefault();
    }, { passive: false });
    var lastTouchEnd = 0;
    document.addEventListener('touchend', function(e) {
        var now = Date.now();
        if (now - lastTouchEnd <= 300) e.preventDefault();
        lastTouchEnd = now;
    }, { passive: false });
})();
