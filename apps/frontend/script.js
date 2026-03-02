/**
 * Ionospheric Ray Tracer — Visualization Engine
 *
 * Renders ray paths on a curved Earth cross-section using Canvas 2D.
 * Communicates with the FastAPI backend for ray tracing calculations.
 */

const API_BASE = window.location.origin;

// ============================================================
// State
// ============================================================

let rays = [];
let hoveredRay = null;
let canvasW, canvasH;
let ctx;

// Visualization parameters
const VIS = {
  earthR: 6370,          // km
  maxAlt: 500,           // km (max displayed altitude)
  padding: { top: 60, bottom: 40, left: 60, right: 40 },
  arcSpan: Math.PI * 0.35, // Angular span of Earth arc to show
};

// ============================================================
// Color utilities
// ============================================================

function elevToColor(elev, elevMin, elevMax, alpha = 1.0) {
  const t = (elev - elevMin) / (elevMax - elevMin + 0.001);
  // Gradient: rose → amber → cyan → indigo
  let r, g, b;
  if (t < 0.33) {
    const s = t / 0.33;
    r = 244 + (245 - 244) * s;
    g = 63 + (158 - 63) * s;
    b = 94 + (11 - 94) * s;
  } else if (t < 0.66) {
    const s = (t - 0.33) / 0.33;
    r = 245 + (6 - 245) * s;
    g = 158 + (182 - 158) * s;
    b = 11 + (212 - 11) * s;
  } else {
    const s = (t - 0.66) / 0.34;
    r = 6 + (99 - 6) * s;
    g = 182 + (102 - 182) * s;
    b = 212 + (241 - 212) * s;
  }
  return `rgba(${Math.round(r)},${Math.round(g)},${Math.round(b)},${alpha})`;
}

// ============================================================
// Coordinate transforms
// ============================================================

function getViewport() {
  const p = VIS.padding;
  return {
    x: p.left,
    y: p.top,
    w: canvasW - p.left - p.right,
    h: canvasH - p.top - p.bottom,
  };
}

// Map (ground_range_km, height_km) to canvas (x, y)
// Uses curved Earth projection for realism
function toCanvas(groundRange, height) {
  const vp = getViewport();
  const totalRange = VIS.earthR * VIS.arcSpan; // Total ground range displayed

  // Angular position along the arc
  const theta0 = -VIS.arcSpan / 2;
  const theta = theta0 + (groundRange / totalRange) * VIS.arcSpan;

  // Radius from Earth center
  const r = VIS.earthR + height;

  // Scale: fit Earth arc + maxAlt into viewport
  const rMax = VIS.earthR + VIS.maxAlt;
  const scale = vp.h / (rMax - VIS.earthR * Math.cos(VIS.arcSpan / 2));

  // Center of Earth in canvas coords
  const cx = vp.x + vp.w / 2;
  const cy = vp.y + vp.h + VIS.earthR * Math.cos(VIS.arcSpan / 2) * scale;

  // Canvas coordinates
  const x = cx + r * Math.sin(theta) * scale;
  const y = cy - r * Math.cos(theta) * scale;

  return { x, y };
}

// ============================================================
// Drawing functions
// ============================================================

function drawBackground() {
  // Deep space gradient
  const grad = ctx.createLinearGradient(0, 0, 0, canvasH);
  grad.addColorStop(0, '#050816');
  grad.addColorStop(0.5, '#0a0e1a');
  grad.addColorStop(1, '#0f172a');
  ctx.fillStyle = grad;
  ctx.fillRect(0, 0, canvasW, canvasH);

  // Subtle stars
  ctx.fillStyle = 'rgba(255,255,255,0.15)';
  for (let i = 0; i < 60; i++) {
    const sx = (Math.sin(i * 127.1 + 311.7) * 0.5 + 0.5) * canvasW;
    const sy = (Math.sin(i * 269.5 + 183.3) * 0.5 + 0.5) * canvasH * 0.6;
    const size = (Math.sin(i * 43.1) * 0.5 + 0.5) * 1.5 + 0.5;
    ctx.beginPath();
    ctx.arc(sx, sy, size, 0, Math.PI * 2);
    ctx.fill();
  }
}

function drawEarth() {
  const vp = getViewport();
  const totalRange = VIS.earthR * VIS.arcSpan;
  const scale = vp.h / (VIS.earthR + VIS.maxAlt - VIS.earthR * Math.cos(VIS.arcSpan / 2));
  const cx = vp.x + vp.w / 2;
  const cy = vp.y + vp.h + VIS.earthR * Math.cos(VIS.arcSpan / 2) * scale;

  // Earth body (filled arc)
  ctx.beginPath();
  const startAngle = -Math.PI / 2 - VIS.arcSpan / 2;
  const endAngle = -Math.PI / 2 + VIS.arcSpan / 2;
  ctx.arc(cx, cy, VIS.earthR * scale, startAngle, endAngle);
  ctx.lineTo(cx + (VIS.earthR + 50) * Math.sin(VIS.arcSpan / 2) * scale, canvasH + 50);
  ctx.lineTo(cx - (VIS.earthR + 50) * Math.sin(VIS.arcSpan / 2) * scale, canvasH + 50);
  ctx.closePath();

  const earthGrad = ctx.createRadialGradient(cx, cy, VIS.earthR * scale * 0.7, cx, cy, VIS.earthR * scale);
  earthGrad.addColorStop(0, '#1a3a2a');
  earthGrad.addColorStop(1, '#0f2318');
  ctx.fillStyle = earthGrad;
  ctx.fill();

  // Earth surface line
  ctx.beginPath();
  ctx.arc(cx, cy, VIS.earthR * scale, startAngle, endAngle);
  ctx.strokeStyle = '#10b981';
  ctx.lineWidth = 2;
  ctx.stroke();

  // Transmitter marker
  const tx = toCanvas(0, 0);
  ctx.beginPath();
  ctx.arc(tx.x, tx.y, 6, 0, Math.PI * 2);
  ctx.fillStyle = '#f43f5e';
  ctx.fill();
  ctx.strokeStyle = '#f43f5e';
  ctx.lineWidth = 1;
  ctx.beginPath();
  ctx.arc(tx.x, tx.y, 10, 0, Math.PI * 2);
  ctx.stroke();

  ctx.font = '11px Inter, sans-serif';
  ctx.fillStyle = '#f43f5e';
  ctx.textAlign = 'center';
  ctx.fillText('TX', tx.x, tx.y + 22);
}

function drawIonosphereLayers(fc, hm, sh) {
  const vp = getViewport();
  const scale = vp.h / (VIS.earthR + VIS.maxAlt - VIS.earthR * Math.cos(VIS.arcSpan / 2));
  const cx = vp.x + vp.w / 2;
  const cy = vp.y + vp.h + VIS.earthR * Math.cos(VIS.arcSpan / 2) * scale;
  const startAngle = -Math.PI / 2 - VIS.arcSpan / 2;
  const endAngle = -Math.PI / 2 + VIS.arcSpan / 2;

  // D region (60-90 km)
  drawLayer(cx, cy, scale, startAngle, endAngle, 60, 90, 'rgba(245, 158, 11, 0.06)', 'D');
  // E region (90-150 km)
  drawLayer(cx, cy, scale, startAngle, endAngle, 90, 150, 'rgba(6, 182, 212, 0.06)', 'E');
  // F1 region (150-220 km)
  drawLayer(cx, cy, scale, startAngle, endAngle, 150, 220, 'rgba(99, 102, 241, 0.06)', 'F1');
  // F2 region (220-400 km)
  drawLayer(cx, cy, scale, startAngle, endAngle, 220, Math.min(400, VIS.maxAlt), 'rgba(99, 102, 241, 0.1)', 'F2');

  // Peak density line (at hmF2)
  if (hm < VIS.maxAlt) {
    ctx.beginPath();
    ctx.arc(cx, cy, (VIS.earthR + hm) * scale, startAngle, endAngle);
    ctx.strokeStyle = 'rgba(99, 102, 241, 0.3)';
    ctx.lineWidth = 1;
    ctx.setLineDash([4, 6]);
    ctx.stroke();
    ctx.setLineDash([]);

    // Label
    const labelPos = toCanvas(-50, hm);
    ctx.font = '10px Inter, sans-serif';
    ctx.fillStyle = 'rgba(99, 102, 241, 0.6)';
    ctx.textAlign = 'right';
    ctx.fillText(`hmF2 ${hm}km`, labelPos.x - 8, labelPos.y + 4);
  }
}

function drawLayer(cx, cy, scale, startAngle, endAngle, h1, h2, color, label) {
  ctx.beginPath();
  ctx.arc(cx, cy, (VIS.earthR + h2) * scale, startAngle, endAngle, false);
  ctx.arc(cx, cy, (VIS.earthR + h1) * scale, endAngle, startAngle, true);
  ctx.closePath();
  ctx.fillStyle = color;
  ctx.fill();

  // Layer label on the right edge
  const labelPos = toCanvas(VIS.earthR * VIS.arcSpan * 0.48, (h1 + h2) / 2);
  ctx.font = '9px Inter, sans-serif';
  ctx.fillStyle = 'rgba(148, 163, 184, 0.4)';
  ctx.textAlign = 'left';
  ctx.fillText(label, labelPos.x + 4, labelPos.y + 3);
}

function drawAltitudeScale() {
  const alts = [0, 100, 200, 300, 400, 500];
  ctx.font = '10px JetBrains Mono, monospace';
  ctx.fillStyle = 'rgba(148, 163, 184, 0.5)';
  ctx.textAlign = 'right';

  for (const alt of alts) {
    if (alt > VIS.maxAlt) continue;
    const pos = toCanvas(-VIS.earthR * VIS.arcSpan * 0.5, alt);
    ctx.fillText(`${alt}`, pos.x - 8, pos.y + 4);

    // Tick
    ctx.beginPath();
    ctx.moveTo(pos.x - 4, pos.y);
    ctx.lineTo(pos.x, pos.y);
    ctx.strokeStyle = 'rgba(148, 163, 184, 0.2)';
    ctx.lineWidth = 1;
    ctx.stroke();
  }

  // Label
  const labelPos = toCanvas(-VIS.earthR * VIS.arcSpan * 0.5, VIS.maxAlt / 2);
  ctx.save();
  ctx.translate(labelPos.x - 35, labelPos.y);
  ctx.rotate(-Math.PI / 2);
  ctx.font = '10px Inter, sans-serif';
  ctx.fillStyle = 'rgba(148, 163, 184, 0.4)';
  ctx.textAlign = 'center';
  ctx.fillText('Altitude (km)', 0, 0);
  ctx.restore();
}

function drawRays(elevMin, elevMax) {
  if (!rays.length) return;

  for (let i = 0; i < rays.length; i++) {
    const ray = rays[i];
    const isHovered = hoveredRay === i;
    const color = elevToColor(ray.elev, elevMin, elevMax, isHovered ? 1.0 : 0.6);
    const width = isHovered ? 2.5 : 1.2;

    ctx.beginPath();
    ctx.strokeStyle = color;
    ctx.lineWidth = width;

    for (let j = 0; j < ray.pts.length; j++) {
      const pt = ray.pts[j];
      const pos = toCanvas(pt.t, pt.h);

      if (j === 0) {
        ctx.moveTo(pos.x, pos.y);
      } else {
        ctx.lineTo(pos.x, pos.y);
      }
    }
    ctx.stroke();

    // Glow for hovered ray
    if (isHovered) {
      ctx.strokeStyle = elevToColor(ray.elev, elevMin, elevMax, 0.15);
      ctx.lineWidth = 6;
      ctx.beginPath();
      for (let j = 0; j < ray.pts.length; j++) {
        const pt = ray.pts[j];
        const pos = toCanvas(pt.t, pt.h);
        j === 0 ? ctx.moveTo(pos.x, pos.y) : ctx.lineTo(pos.x, pos.y);
      }
      ctx.stroke();
    }
  }
}

function drawTitle(nRays, elapsed, freq, fc) {
  ctx.font = '12px Inter, sans-serif';
  ctx.fillStyle = 'rgba(148, 163, 184, 0.6)';
  ctx.textAlign = 'left';
  ctx.fillText(
    `${nRays} rays · f=${freq} MHz · foF2=${fc} MHz`,
    VIS.padding.left, 30
  );
}

// ============================================================
// Main render
// ============================================================

function render() {
  const canvas = document.getElementById('canvas');
  ctx = canvas.getContext('2d');

  // Set canvas size to CSS size
  const rect = canvas.getBoundingClientRect();
  const dpr = window.devicePixelRatio || 1;
  canvas.width = rect.width * dpr;
  canvas.height = rect.height * dpr;
  ctx.scale(dpr, dpr);
  canvasW = rect.width;
  canvasH = rect.height;

  // Adjust max alt based on data
  if (rays.length) {
    const maxH = Math.max(...rays.map(r => r.max_h));
    VIS.maxAlt = Math.max(300, Math.min(800, maxH * 1.3));
  }

  const fc = parseFloat(document.getElementById('fc').value);
  const hm = parseFloat(document.getElementById('hm').value);
  const sh = parseFloat(document.getElementById('sh').value);
  const freq = parseFloat(document.getElementById('freq').value);
  const elevMin = parseFloat(document.getElementById('elev-min').value);
  const elevMax = parseFloat(document.getElementById('elev-max').value);

  drawBackground();
  drawIonosphereLayers(fc, hm, sh);
  drawEarth();
  drawAltitudeScale();
  drawRays(elevMin, elevMax);

  if (rays.length) {
    drawTitle(rays.length, 0, freq, fc);
  }
}

// ============================================================
// API communication
// ============================================================

async function traceRays() {
  const btn = document.getElementById('trace-btn');
  btn.classList.add('loading');
  btn.querySelector('.btn-icon').textContent = '⟳';

  const body = {
    freq_mhz: parseFloat(document.getElementById('freq').value),
    ray_mode: parseFloat(document.getElementById('ray-mode').value),
    elev_min: parseFloat(document.getElementById('elev-min').value),
    elev_max: parseFloat(document.getElementById('elev-max').value),
    elev_step: parseFloat(document.getElementById('elev-step').value),
    azimuth_deg: 0.0,
    tx_lat_deg: 40.0,
    fc: parseFloat(document.getElementById('fc').value),
    hm: parseFloat(document.getElementById('hm').value),
    sh: parseFloat(document.getElementById('sh').value),
    fh: parseFloat(document.getElementById('fh').value),
    step_size: 5.0,
    max_steps: 500,
  };

  try {
    const res = await fetch(`${API_BASE}/api/trace/fan`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(body),
    });

    const data = await res.json();

    if (data.error) {
      console.error(data.error);
      return;
    }

    rays = data.rays;

    // Update stats
    document.getElementById('stat-rays').textContent = `${data.n_rays} rays`;
    document.getElementById('stat-time').textContent = `${data.elapsed_ms} ms`;

    render();
  } catch (err) {
    console.error('Trace failed:', err);
    document.getElementById('stat-rays').textContent = 'Error';
  } finally {
    btn.classList.remove('loading');
    btn.querySelector('.btn-icon').textContent = '▶';
  }
}

// ============================================================
// Mouse interaction
// ============================================================

function handleMouseMove(e) {
  if (!rays.length) return;

  const canvas = document.getElementById('canvas');
  const rect = canvas.getBoundingClientRect();
  const mx = e.clientX - rect.left;
  const my = e.clientY - rect.top;

  let closestRay = null;
  let closestDist = 20; // Max hover distance in pixels

  for (let i = 0; i < rays.length; i++) {
    const ray = rays[i];
    for (let j = 0; j < ray.pts.length; j++) {
      const pt = ray.pts[j];
      const pos = toCanvas(pt.t, pt.h);
      const dx = pos.x - mx;
      const dy = pos.y - my;
      const dist = Math.sqrt(dx * dx + dy * dy);
      if (dist < closestDist) {
        closestDist = dist;
        closestRay = i;
      }
    }
  }

  if (closestRay !== hoveredRay) {
    hoveredRay = closestRay;
    render();
    updateInfoPanel();
  }
}

function updateInfoPanel() {
  const panel = document.getElementById('info-panel');

  if (hoveredRay === null || !rays[hoveredRay]) {
    panel.innerHTML = '<p class="info-hint">Hover over rays for details</p>';
    return;
  }

  const ray = rays[hoveredRay];
  panel.innerHTML = `
        <dl class="ray-detail">
            <dt>Elevation</dt><dd>${ray.elev}°</dd>
            <dt>Max Height</dt><dd>${ray.max_h} km</dd>
            <dt>Ground Return</dt><dd>${ray.ground ? '✅ Yes' : '❌ No'}</dd>
            <dt>Points</dt><dd>${ray.pts.length}</dd>
        </dl>
    `;
}

// ============================================================
// Controls wiring
// ============================================================

function wireControls() {
  const sliders = [
    ['freq', 'freq-val', v => parseFloat(v).toFixed(1)],
    ['elev-min', 'elev-min-val', v => v],
    ['elev-max', 'elev-max-val', v => v],
    ['elev-step', 'elev-step-val', v => parseFloat(v).toFixed(1)],
    ['fc', 'fc-val', v => parseFloat(v).toFixed(1)],
    ['hm', 'hm-val', v => v],
    ['sh', 'sh-val', v => v],
    ['fh', 'fh-val', v => parseFloat(v).toFixed(1)],
  ];

  for (const [id, outId, fmt] of sliders) {
    const input = document.getElementById(id);
    const output = document.getElementById(outId);
    input.addEventListener('input', () => {
      output.textContent = fmt(input.value);
    });
  }

  document.getElementById('trace-btn').addEventListener('click', traceRays);

  // Canvas mouse
  document.getElementById('canvas').addEventListener('mousemove', handleMouseMove);
  document.getElementById('canvas').addEventListener('mouseleave', () => {
    hoveredRay = null;
    render();
    updateInfoPanel();
  });

  // Resize
  window.addEventListener('resize', render);
}

// ============================================================
// Init
// ============================================================

document.addEventListener('DOMContentLoaded', () => {
  wireControls();
  render();
  // Auto-trace on load
  traceRays();
});
