/**
 * Ionospheric Ray Tracer — Multi-Ray Comparison Engine (WASM)
 *
 * Renders multiple fan traces on a curved Earth cross-section using Canvas 2D.
 * Supports comparing different parameter configurations side-by-side via
 * checkbox model selection and numeric sweep ranges.
 * All computation runs client-side via WebAssembly.
 */

import init, { trace_fan_wasm, solve_target_wasm } from './pkg/ionotrace.js';
import { initGlobe, updateGlobeRays, setGlobeVisible, onGlobeClick, lookAtLocation } from './globe3d.js';

// ============================================================
// State
// ============================================================

let traceGroups = [];   // Array of { label, color, rays[], config }
let hoveredRay = null;  // { groupIdx, rayIdx }
let canvasW, canvasH;
let ctx;
let lastTraceBody = null;
let currentMode = 'fan'; // 'fan' or 'target'
let targetMarkerRange = null; // km — if set, draw a marker on Earth at this ground range
let isTargeting = false; // true while bisection is in progress
let targetSubMode = 'quick'; // kept for legacy, always 'quick' now
let stopTargeting = false; // set to true to cancel bisection

// Camera state (zoom & pan)
const camera = {
  zoom: 1.0,
  panX: 0,     // pan offset in canvas pixels
  panY: 0,
  dragging: false,
  dragStartX: 0,
  dragStartY: 0,
  panStartX: 0,
  panStartY: 0,
};
const ZOOM_MIN = 0.3;
const ZOOM_MAX = 20;

// Zoom-to-rectangle state
let zoomRectMode = false;
let zoomRect = null; // { x1, y1, x2, y2 } in canvas coords

// Ionosphere layers visibility
let showIonoLayers = true;

// 3D globe view
let viewMode = '2d'; // '2d' or '3d'
let globeInitialized = false;

// Distinct colors for up to 16 comparison groups
const GROUP_COLORS = [
  '#6366f1', // indigo
  '#f43f5e', // rose
  '#06b6d4', // cyan
  '#f59e0b', // amber
  '#10b981', // emerald
  '#8b5cf6', // violet
  '#ec4899', // pink
  '#14b8a6', // teal
  '#f97316', // orange
  '#3b82f6', // blue
  '#84cc16', // lime
  '#e879f9', // fuchsia
  '#facc15', // yellow
  '#22d3ee', // sky
  '#a78bfa', // purple
  '#fb923c', // light orange
];

// Visualization parameters
const VIS = {
  earthR: 6370,          // km
  maxAlt: 500,           // km (max displayed altitude)
  padding: { top: 40, bottom: 20, left: 40, right: 20 },
  arcSpan: Math.PI * 2,  // Full 360° circle
};

// Sweepable parameter descriptors
const SWEEP_PARAMS = [
  { id: 'freq', key: 'freq_mhz', label: 'Freq' },
  { id: 'fc', key: 'fc', label: 'foF2' },
  { id: 'hm', key: 'hm', label: 'hmF2' },
  { id: 'sh', key: 'sh', label: 'SH' },
  { id: 'fh', key: 'fh', label: 'fH' },
];

// Checkbox group descriptors
const CHECKBOX_GROUPS = [
  {
    groupId: 'ray-mode-group', name: 'ray-mode', key: 'ray_mode', label: 'Mode', parseFloat: true,
    labels: { '-1': 'X-mode', '1': 'O-mode' }
  },
  {
    groupId: 'ed-model-group', name: 'ed-model', key: 'ed_model', label: 'ED',
    labels: { '0': 'Chapman', '1': 'ELECT1', '2': 'Linear', '3': 'QP', '4': 'VarChap', '5': 'DualChap' }
  },
  {
    groupId: 'mag-model-group', name: 'mag-model', key: 'mag_model', label: 'Mag',
    labels: { '0': 'Dipole', '1': 'Const', '2': 'Cubic', '3': 'IGRF' }
  },
  {
    groupId: 'rindex-model-group', name: 'rindex-model', key: 'rindex_model', label: 'RI',
    labels: { '0': 'FullAH', '1': 'NoF/C', '2': 'NoF', '3': 'NoC' }
  },
  {
    groupId: 'pert-model-group', name: 'pert-model', key: 'pert_model', label: 'Pert',
    labels: { '0': 'None', '1': 'Torus', '2': 'Trough', '3': 'Shock', '4': 'Bulge', '5': 'Exp' }
  },
];

const MAX_COMBOS = 50;

// ============================================================
// TX Location helpers
// ============================================================

function getTxLat() {
  return parseFloat(document.getElementById('tx-lat')?.value || '40');
}

function getTxLon() {
  return parseFloat(document.getElementById('tx-lon')?.value || '-80');
}

function setTxLocation(lat, lon, statusText, statusClass) {
  const latEl = document.getElementById('tx-lat');
  const lonEl = document.getElementById('tx-lon');
  const statusEl = document.getElementById('geo-status');
  if (latEl) latEl.value = lat.toFixed(1);
  if (lonEl) lonEl.value = lon.toFixed(1);
  // Sync IRI fields if they exist
  const iriLat = document.getElementById('iri-lat');
  const iriLon = document.getElementById('iri-lon');
  if (iriLat) iriLat.value = Math.round(lat);
  if (iriLon) iriLon.value = Math.round(lon);
  if (statusEl && statusText) {
    statusEl.textContent = statusText;
    statusEl.className = 'geo-status' + (statusClass ? ' ' + statusClass : '');
  }
  updateTxRxComputed();
}

function requestGeolocation() {
  if (!navigator.geolocation) {
    setTxLocation(40, -80, 'No GPS', 'error');
    return;
  }
  const btn = document.getElementById('geolocate-btn');
  const statusEl = document.getElementById('geo-status');
  if (btn) btn.classList.add('locating');
  if (statusEl) { statusEl.textContent = 'Locating…'; statusEl.className = 'geo-status'; }

  navigator.geolocation.getCurrentPosition(
    (pos) => {
      setTxLocation(pos.coords.latitude, pos.coords.longitude, 'Located ✓', 'located');
      if (btn) btn.classList.remove('locating');
      updateTxRxComputed();
    },
    (err) => {
      console.warn('Geolocation error:', err.message);
      setTxLocation(40, -80, 'Manual', '');
      if (btn) btn.classList.remove('locating');
    },
    { timeout: 10000, maximumAge: 300000 }
  );
}

// ============================================================
// RX Destination helpers
// ============================================================

function getRxLat() {
  const v = document.getElementById('rx-lat')?.value;
  return (v !== '' && v != null) ? parseFloat(v) : null;
}

function getRxLon() {
  const v = document.getElementById('rx-lon')?.value;
  return (v !== '' && v != null) ? parseFloat(v) : null;
}

function setRxLocation(lat, lon) {
  const latEl = document.getElementById('rx-lat');
  const lonEl = document.getElementById('rx-lon');
  if (latEl) latEl.value = lat.toFixed(1);
  if (lonEl) lonEl.value = lon.toFixed(1);
  updateTxRxComputed();
}

function clearRxLocation() {
  const latEl = document.getElementById('rx-lat');
  const lonEl = document.getElementById('rx-lon');
  if (latEl) latEl.value = '';
  if (lonEl) lonEl.value = '';
  const computed = document.getElementById('rx-computed');
  if (computed) computed.style.display = 'none';
}

function requestRxGeolocation() {
  if (!navigator.geolocation) return;
  const btn = document.getElementById('rx-geolocate-btn');
  if (btn) btn.classList.add('locating');

  navigator.geolocation.getCurrentPosition(
    (pos) => {
      setRxLocation(pos.coords.latitude, pos.coords.longitude);
      if (btn) btn.classList.remove('locating');
    },
    (err) => {
      console.warn('RX Geolocation error:', err.message);
      if (btn) btn.classList.remove('locating');
    },
    { timeout: 10000, maximumAge: 300000 }
  );
}

// ============================================================
// Great-circle bearing & distance (Haversine)
// ============================================================

function computeBearingDistance(lat1, lon1, lat2, lon2) {
  const R = 6371; // Earth radius in km
  const toRad = Math.PI / 180;
  const φ1 = lat1 * toRad, φ2 = lat2 * toRad;
  const Δφ = (lat2 - lat1) * toRad;
  const Δλ = (lon2 - lon1) * toRad;

  // Haversine distance
  const a = Math.sin(Δφ / 2) ** 2 + Math.cos(φ1) * Math.cos(φ2) * Math.sin(Δλ / 2) ** 2;
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  const distance_km = R * c;

  // Forward bearing
  const y = Math.sin(Δλ) * Math.cos(φ2);
  const x = Math.cos(φ1) * Math.sin(φ2) - Math.sin(φ1) * Math.cos(φ2) * Math.cos(Δλ);
  const bearing_deg = ((Math.atan2(y, x) * 180 / Math.PI) + 360) % 360;

  return { distance_km, bearing_deg };
}

/**
 * Compute cross-track and along-track error of a landing point relative
 * to the TX→RX great-circle path.
 * 
 * @param {number} txLat - TX latitude (degrees)
 * @param {number} txLon - TX longitude (degrees)
 * @param {number} rxLat - RX target latitude (degrees)
 * @param {number} rxLon - RX target longitude (degrees)
 * @param {number} landLat - Actual landing latitude (degrees)
 * @param {number} landLon - Actual landing longitude (degrees)
 * @returns {{ crossTrack_km: number, alongTrack_km: number, totalError_km: number }}
 *   crossTrack_km > 0 means landing is RIGHT of the TX→RX path
 */
function computeCrossTrackError(txLat, txLon, rxLat, rxLon, landLat, landLon) {
  const R = 6371;
  const toRad = Math.PI / 180;

  // Angular distance TX → landing
  const d13 = computeBearingDistance(txLat, txLon, landLat, landLon).distance_km / R;
  // Bearing TX → RX (intended)
  const θ12 = computeBearingDistance(txLat, txLon, rxLat, rxLon).bearing_deg * toRad;
  // Bearing TX → landing (actual)
  const θ13 = computeBearingDistance(txLat, txLon, landLat, landLon).bearing_deg * toRad;

  // Cross-track distance (signed: positive = right of path)
  const dxt = Math.asin(Math.sin(d13) * Math.sin(θ13 - θ12));
  const crossTrack_km = dxt * R;

  // Along-track distance
  const dat = Math.acos(Math.cos(d13) / Math.max(Math.cos(dxt), 1e-12));
  const targetDist = computeBearingDistance(txLat, txLon, rxLat, rxLon).distance_km;
  const alongTrack_km = dat * R - targetDist; // positive = overshot, negative = undershot

  const totalError_km = Math.sqrt(crossTrack_km ** 2 + alongTrack_km ** 2);

  return { crossTrack_km, alongTrack_km, totalError_km };
}

/** Update computed bearing/distance and auto-fill azimuth + target range */
function updateTxRxComputed() {
  const rxLat = getRxLat();
  const rxLon = getRxLon();
  const computed = document.getElementById('rx-computed');

  if (rxLat === null || rxLon === null || isNaN(rxLat) || isNaN(rxLon)) {
    if (computed) computed.style.display = 'none';
    targetMarkerRange = null;
    exactTargetAzimuth = null;
    if (viewMode === '3d') updateGlobeRays(traceGroups, getTxLat(), getTxLon(), null, null);
    render();
    return;
  }

  const txLat = getTxLat();
  const txLon = getTxLon();
  const { distance_km, bearing_deg } = computeBearingDistance(txLat, txLon, rxLat, rxLon);

  // Display computed values
  if (computed) computed.style.display = 'block';
  const distEl = document.getElementById('rx-distance');
  const bearEl = document.getElementById('rx-bearing');
  if (distEl) distEl.textContent = `${Math.round(distance_km)} km`;
  if (bearEl) bearEl.textContent = `${bearing_deg.toFixed(1)}°`;

  // Auto-fill azimuth
  const azEl = document.getElementById('azimuth');
  const azVal = document.getElementById('azimuth-val');
  exactTargetAzimuth = bearing_deg;
  if (azEl) {
    azEl.value = Math.round(bearing_deg);
    if (azVal) azVal.textContent = Math.round(bearing_deg);
  }

  // Auto-fill target range if in target mode
  const targetRangeEl = document.getElementById('target-range');
  if (targetRangeEl) {
    targetRangeEl.value = Math.round(distance_km);
  }

  // Update target marker
  targetMarkerRange = Math.round(distance_km);

  if (viewMode === '3d') {
    updateGlobeRays(traceGroups, txLat, txLon, rxLat, rxLon);
  }
  render();
}

let exactTargetAzimuth = null;

/** Get azimuth from the slider */
function getAzimuth() {
  if (currentMode === 'target' && exactTargetAzimuth !== null) {
    return exactTargetAzimuth;
  }
  return parseFloat(document.getElementById('azimuth')?.value || '0');
}

// ============================================================
// Parameter collection
// ============================================================

/** Get checked values from a checkbox group */
function getCheckedValues(groupId, asFloat = false) {
  const group = document.getElementById(groupId);
  const checked = group.querySelectorAll('input[type="checkbox"]:checked');
  return Array.from(checked).map(cb => asFloat ? parseFloat(cb.value) : parseInt(cb.value));
}

/** Get values for a sweepable param — single or range */
function getSweepValues(paramId) {
  const sweepDiv = document.getElementById(`${paramId}-sweep`);
  const isSweep = sweepDiv && !sweepDiv.classList.contains('hidden');

  if (isSweep) {
    const min = parseFloat(document.getElementById(`${paramId}-sweep-min`).value);
    const max = parseFloat(document.getElementById(`${paramId}-sweep-max`).value);
    const step = parseFloat(document.getElementById(`${paramId}-sweep-step`).value);
    if (step <= 0 || min > max) return [min];
    const values = [];
    for (let v = min; v <= max + step * 0.01; v += step) {
      values.push(Math.round(v * 1000) / 1000); // avoid float drift
    }
    return values;
  } else {
    return [parseFloat(document.getElementById(paramId).value)];
  }
}

/** Cartesian product of arrays */
function cartesian(...arrays) {
  return arrays.reduce((acc, arr) => {
    const result = [];
    for (const a of acc) {
      for (const v of arr) {
        result.push([...a, v]);
      }
    }
    return result;
  }, [[]]);
}

/** Build all parameter combinations and return { combos, labels, count } */
function buildCombinations() {
  // Collect all multi-valued dimensions
  const dimensions = [];  // { key, values[], label, valueLabels[] }

  // Checkbox groups
  for (const cg of CHECKBOX_GROUPS) {
    const values = getCheckedValues(cg.groupId, !!cg.parseFloat);
    if (values.length === 0) continue;
    dimensions.push({
      key: cg.key,
      values,
      label: cg.label,
      valueLabels: values.map(v => cg.labels[String(v)] || String(v)),
    });
  }

  // Sweepable numeric params
  for (const sp of SWEEP_PARAMS) {
    const values = getSweepValues(sp.id);
    dimensions.push({
      key: sp.key,
      values,
      label: sp.label,
      valueLabels: values.map(v => String(v)),
    });
  }

  // Compute Cartesian product
  const allValues = dimensions.map(d => d.values);
  const combos = cartesian(...allValues);

  // Build labeled configs
  const configs = combos.map(combo => {
    const config = {};
    const labelParts = [];
    let hasMulti = false;

    combo.forEach((val, i) => {
      config[dimensions[i].key] = val;
      if (dimensions[i].values.length > 1) {
        labelParts.push(`${dimensions[i].label}=${dimensions[i].valueLabels[dimensions[i].values.indexOf(val)]}`);
        hasMulti = true;
      }
    });

    return {
      config,
      label: hasMulti ? labelParts.join(' · ') : 'Default',
    };
  });

  return configs;
}

/** Count total combos and update the badge */
function updateComboCount() {
  const configs = buildCombinations();
  const count = configs.length;
  const badge = document.getElementById('combo-count');
  badge.textContent = count;
  badge.className = 'combo-counter';
  if (count > MAX_COMBOS) badge.classList.add('danger');
  else if (count > 10) badge.classList.add('warning');
  return count;
}

// ============================================================
// Color utilities
// ============================================================

function elevToColor(elev, elevMin, elevMax, alpha = 1.0) {
  const t = (elev - elevMin) / (elevMax - elevMin + 0.001);
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

/** Map absorption value (dB) to color: green (low) → yellow → red (high) */
function absorptionToColor(absorption, maxAbsorption, alpha = 1.0) {
  const t = Math.min(1.0, Math.max(0, absorption / (maxAbsorption + 0.001)));
  let r, g, b;
  if (t < 0.5) {
    const s = t / 0.5;
    r = 16 + (245 - 16) * s;
    g = 185 + (158 - 185) * s;
    b = 129 + (11 - 129) * s;
  } else {
    const s = (t - 0.5) / 0.5;
    r = 245 + (244 - 245) * s;
    g = 158 + (63 - 158) * s;
    b = 11 + (94 - 11) * s;
  }
  return `rgba(${Math.round(r)},${Math.round(g)},${Math.round(b)},${alpha})`;
}

/** Parse hex color to rgba string with alpha */
function hexToRgba(hex, alpha = 1.0) {
  const r = parseInt(hex.slice(1, 3), 16);
  const g = parseInt(hex.slice(3, 5), 16);
  const b = parseInt(hex.slice(5, 7), 16);
  return `rgba(${r},${g},${b},${alpha})`;
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

/** Get the Earth center and scale for drawing */
function getEarthTransform() {
  const vp = getViewport();
  const rMax = VIS.earthR + VIS.maxAlt;
  // Scale so the full globe (earthR + maxAlt) fits within viewport
  const scale = Math.min(vp.w, vp.h) / (2 * rMax);
  const cx = vp.x + vp.w / 2;
  const cy = vp.y + vp.h / 2;
  return { cx, cy, scale };
}

function toCanvas(groundRange, height) {
  const { cx, cy, scale } = getEarthTransform();
  // TX is at angle 0 (top of circle). Ground range maps CW around the globe.
  const totalCircum = VIS.earthR * Math.PI * 2;
  const theta = (groundRange / totalCircum) * Math.PI * 2; // positive = CCW (left to right from TX)
  const r = VIS.earthR + height;
  const x = cx + r * Math.sin(theta) * scale;
  const y = cy - r * Math.cos(theta) * scale;
  return { x, y };
}

// ============================================================
// Drawing functions
// ============================================================

function drawBackground() {
  const grad = ctx.createLinearGradient(0, 0, 0, canvasH);
  grad.addColorStop(0, '#050816');
  grad.addColorStop(0.5, '#0a0e1a');
  grad.addColorStop(1, '#0f172a');
  ctx.fillStyle = grad;
  ctx.fillRect(0, 0, canvasW, canvasH);

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
  const { cx, cy, scale } = getEarthTransform();

  // Fill full Earth circle
  ctx.beginPath();
  ctx.arc(cx, cy, VIS.earthR * scale, 0, Math.PI * 2);
  const earthGrad = ctx.createRadialGradient(cx, cy, VIS.earthR * scale * 0.5, cx, cy, VIS.earthR * scale);
  earthGrad.addColorStop(0, '#1a3a2a');
  earthGrad.addColorStop(1, '#0f2318');
  ctx.fillStyle = earthGrad;
  ctx.fill();

  // Earth outline
  ctx.beginPath();
  ctx.arc(cx, cy, VIS.earthR * scale, 0, Math.PI * 2);
  ctx.strokeStyle = '#10b981';
  ctx.lineWidth = 1.5;
  ctx.stroke();

  // TX marker — radio tower icon
  const tx = toCanvas(0, 0);
  const s = 1; // fixed size relative to earth
  const towerH = 12 * s;
  const baseW = 4 * s;

  ctx.save();
  ctx.strokeStyle = 'rgba(244, 63, 94, 0.7)';
  ctx.fillStyle = 'rgba(244, 63, 94, 0.7)';
  ctx.lineWidth = 1.5 * s;

  // Mast (vertical line)
  ctx.beginPath();
  ctx.moveTo(tx.x, tx.y);
  ctx.lineTo(tx.x, tx.y - towerH);
  ctx.stroke();

  // Base legs (small triangle)
  ctx.beginPath();
  ctx.moveTo(tx.x - baseW, tx.y);
  ctx.lineTo(tx.x, tx.y - towerH * 0.35);
  ctx.lineTo(tx.x + baseW, tx.y);
  ctx.strokeStyle = 'rgba(244, 63, 94, 0.5)';
  ctx.lineWidth = 1 * s;
  ctx.stroke();

  // Signal waves (small arcs)
  ctx.strokeStyle = 'rgba(244, 63, 94, 0.35)';
  ctx.lineWidth = 1 * s;
  for (let i = 1; i <= 3; i++) {
    const r = (4 + i * 3.5) * s;
    ctx.beginPath();
    ctx.arc(tx.x, tx.y - towerH, r, -Math.PI * 0.7, -Math.PI * 0.3);
    ctx.stroke();
  }

  // Tiny dot at top of mast
  ctx.beginPath();
  ctx.arc(tx.x, tx.y - towerH, 1.5 * s, 0, Math.PI * 2);
  ctx.fillStyle = 'rgba(244, 63, 94, 0.8)';
  ctx.fill();

  ctx.restore();
}

function drawIonosphereLayers(fc, hm) {
  const { cx, cy, scale } = getEarthTransform();

  drawLayer(cx, cy, scale, 60, 90, 'rgba(245, 158, 11, 0.06)', 'D');
  drawLayer(cx, cy, scale, 90, 150, 'rgba(6, 182, 212, 0.06)', 'E');
  drawLayer(cx, cy, scale, 150, 220, 'rgba(99, 102, 241, 0.06)', 'F1');
  drawLayer(cx, cy, scale, 220, Math.min(400, VIS.maxAlt), 'rgba(99, 102, 241, 0.1)', 'F2');

  if (hm < VIS.maxAlt) {
    ctx.beginPath();
    ctx.arc(cx, cy, (VIS.earthR + hm) * scale, 0, Math.PI * 2);
    ctx.strokeStyle = 'rgba(99, 102, 241, 0.2)';
    ctx.lineWidth = 1;
    ctx.setLineDash([4, 6]);
    ctx.stroke();
    ctx.setLineDash([]);

    const labelPos = toCanvas(-50, hm);
    ctx.font = '9px Inter, sans-serif';
    ctx.fillStyle = 'rgba(99, 102, 241, 0.5)';
    ctx.textAlign = 'right';
    ctx.fillText(`hmF2 ${hm}km`, labelPos.x - 8, labelPos.y + 4);
  }
}

function drawLayer(cx, cy, scale, h1, h2, color, label) {
  ctx.beginPath();
  ctx.arc(cx, cy, (VIS.earthR + h2) * scale, 0, Math.PI * 2);
  ctx.arc(cx, cy, (VIS.earthR + h1) * scale, Math.PI * 2, 0, true);
  ctx.closePath();
  ctx.fillStyle = color;
  ctx.fill();

  // Label at the right side of the layer
  const totalCircum = VIS.earthR * Math.PI * 2;
  const labelPos = toCanvas(totalCircum * 0.25, (h1 + h2) / 2);
  ctx.font = '8px Inter, sans-serif';
  ctx.fillStyle = 'rgba(148, 163, 184, 0.35)';
  ctx.textAlign = 'left';
  ctx.fillText(label, labelPos.x + 4, labelPos.y + 3);
}

function drawAltitudeScale() {
  const { cx, cy, scale } = getEarthTransform();
  const alts = [0, 100, 200, 300, 400, 500];
  const fontSize = 10 / camera.zoom;
  ctx.font = `${fontSize}px JetBrains Mono, monospace`;
  ctx.fillStyle = 'rgba(148, 163, 184, 0.5)';
  ctx.textAlign = 'left';

  const tickLen = 4 / camera.zoom;
  const textOff = 6 / camera.zoom;

  for (const alt of alts) {
    if (alt > VIS.maxAlt) continue;
    const r = (VIS.earthR + alt) * scale;
    const x = cx + r;
    const y = cy;
    ctx.fillText(`${alt}`, x + textOff, y + 3 / camera.zoom);

    ctx.beginPath();
    ctx.moveTo(x, y);
    ctx.lineTo(x + tickLen, y);
    ctx.strokeStyle = 'rgba(148, 163, 184, 0.25)';
    ctx.lineWidth = 1 / camera.zoom;
    ctx.stroke();
  }

  // Altitude label
  const rMid = (VIS.earthR + VIS.maxAlt / 2) * scale;
  ctx.save();
  ctx.translate(cx + rMid + 35 / camera.zoom, cy);
  ctx.rotate(-Math.PI / 2);
  ctx.font = `${fontSize}px Inter, sans-serif`;
  ctx.fillStyle = 'rgba(148, 163, 184, 0.35)';
  ctx.textAlign = 'center';
  ctx.fillText('Altitude (km)', 0, 0);
  ctx.restore();
}

function drawRays() {
  if (!traceGroups.length) return;

  const singleGroup = traceGroups.length === 1;
  // For single group, use elevation-based coloring; for multi-group, use group colors
  let globalElevMin = Infinity, globalElevMax = -Infinity;
  let globalAbsMax = 0;
  for (const group of traceGroups) {
    for (const ray of group.rays) {
      if (ray.elev < globalElevMin) globalElevMin = ray.elev;
      if (ray.elev > globalElevMax) globalElevMax = ray.elev;
      if (ray.absorption > globalAbsMax) globalAbsMax = ray.absorption;
    }
  }

  // Use absorption coloring when single group and absorption data exists
  const useAbsorption = singleGroup && globalAbsMax > 0;

  for (let gi = 0; gi < traceGroups.length; gi++) {
    const group = traceGroups[gi];
    const groupColor = group.color;

    for (let ri = 0; ri < group.rays.length; ri++) {
      const ray = group.rays[ri];
      const isHovered = hoveredRay && hoveredRay.groupIdx === gi && hoveredRay.rayIdx === ri;

      let color, width;
      if (singleGroup) {
        if (useAbsorption) {
          color = absorptionToColor(ray.absorption, globalAbsMax, isHovered ? 1.0 : 0.6);
        } else {
          color = elevToColor(ray.elev, globalElevMin, globalElevMax, isHovered ? 1.0 : 0.6);
        }
        width = isHovered ? 2.5 : 1.2;
      } else {
        // Group-based coloring
        color = hexToRgba(groupColor, isHovered ? 1.0 : 0.55);
        width = isHovered ? 2.5 : 1.0;
      }

      ctx.beginPath();
      ctx.strokeStyle = color;
      ctx.lineWidth = width / camera.zoom;

      for (let j = 0; j < ray.pts.length; j++) {
        const pt = ray.pts[j];
        const pos = toCanvas(pt.range || pt.t, pt.h);
        if (j === 0) ctx.moveTo(pos.x, pos.y);
        else ctx.lineTo(pos.x, pos.y);
      }
      ctx.stroke();

      if (isHovered) {
        ctx.strokeStyle = singleGroup
          ? (useAbsorption ? absorptionToColor(ray.absorption, globalAbsMax, 0.15) : elevToColor(ray.elev, globalElevMin, globalElevMax, 0.15))
          : hexToRgba(groupColor, 0.15);
        ctx.lineWidth = 6 / camera.zoom;
        ctx.beginPath();
        for (let j = 0; j < ray.pts.length; j++) {
          const pt = ray.pts[j];
          const pos = toCanvas(pt.range || pt.t, pt.h);
          j === 0 ? ctx.moveTo(pos.x, pos.y) : ctx.lineTo(pos.x, pos.y);
        }
        ctx.stroke();
      }
    }
  }
}

function drawTitle() {
  if (!traceGroups.length) return;
  const totalRays = traceGroups.reduce((sum, g) => sum + g.rays.length, 0);
  const nGroups = traceGroups.length;

  ctx.font = '12px Inter, sans-serif';
  ctx.fillStyle = 'rgba(148, 163, 184, 0.6)';
  ctx.textAlign = 'left';

  const text = nGroups > 1
    ? `${totalRays} rays · ${nGroups} configurations`
    : `${totalRays} rays`;
  ctx.fillText(text, VIS.padding.left, 30);
}

// ============================================================
// Legend
// ============================================================

function updateLegend() {
  const legend = document.getElementById('legend');

  if (traceGroups.length <= 1) {
    legend.classList.remove('visible');
    return;
  }

  legend.classList.add('visible');
  let html = '<div class="legend-title">Configurations</div>';

  for (const group of traceGroups) {
    html += `<div class="legend-item">
      <div class="legend-swatch" style="background:${group.color}"></div>
      <div class="legend-label">${group.label}</div>
    </div>`;
  }

  legend.innerHTML = html;
}

// ============================================================
// Main render
// ============================================================

function render() {
  if (viewMode !== '2d') return;

  const canvas = document.getElementById('canvas');
  ctx = canvas.getContext('2d');

  const rect = canvas.getBoundingClientRect();
  const dpr = window.devicePixelRatio || 1;
  canvas.width = rect.width * dpr;
  canvas.height = rect.height * dpr;
  ctx.scale(dpr, dpr);
  canvasW = rect.width;
  canvasH = rect.height;

  // Adjust max alt based on data
  if (traceGroups.length) {
    let maxH = 0;
    for (const group of traceGroups) {
      for (const ray of group.rays) {
        if (ray.max_h > maxH) maxH = ray.max_h;
      }
    }
    VIS.maxAlt = Math.max(300, Math.min(800, maxH * 1.3));
  }

  // Use first group's ionosphere params for layer drawing, or read from UI
  const fc = parseFloat(document.getElementById('fc').value);
  const hm = parseFloat(document.getElementById('hm').value);

  // Draw background without transform (fills full canvas)
  drawBackground();

  // Apply camera transform for all scene drawing
  ctx.save();
  ctx.translate(camera.panX, camera.panY);
  // Zoom centered on canvas center
  const cx = canvasW / 2;
  const cy = canvasH / 2;
  ctx.translate(cx, cy);
  ctx.scale(camera.zoom, camera.zoom);
  ctx.translate(-cx, -cy);
  if (showIonoLayers) drawIonosphereLayers(fc, hm);
  drawEarth();
  drawGroundRangeRuler();
  drawAltitudeScale();
  drawRays();
  drawTargetMarker();
  drawRxMarker();
  drawTitle();

  // Restore camera transform
  ctx.restore();

  // Draw zoom rectangle overlay (in screen space, after camera restore)
  if (zoomRect) {
    const rx = Math.min(zoomRect.x1, zoomRect.x2);
    const ry = Math.min(zoomRect.y1, zoomRect.y2);
    const rw = Math.abs(zoomRect.x2 - zoomRect.x1);
    const rh = Math.abs(zoomRect.y2 - zoomRect.y1);
    // Dim outside the rectangle
    ctx.fillStyle = 'rgba(0, 0, 0, 0.4)';
    ctx.fillRect(0, 0, canvasW, ry);
    ctx.fillRect(0, ry + rh, canvasW, canvasH - ry - rh);
    ctx.fillRect(0, ry, rx, rh);
    ctx.fillRect(rx + rw, ry, canvasW - rx - rw, rh);
    // Rectangle border
    ctx.strokeStyle = '#6366f1';
    ctx.lineWidth = 2;
    ctx.setLineDash([6, 3]);
    ctx.strokeRect(rx, ry, rw, rh);
    ctx.setLineDash([]);
  }

  // Update zoom indicator element
  const zoomEl = document.getElementById('zoom-level');
  if (zoomEl) zoomEl.textContent = `${Math.round(camera.zoom * 100)}%`;
}

// ============================================================
// Target marker drawing
// ============================================================

function drawTargetMarker() {
  if (targetMarkerRange === null) return;

  const pos = toCanvas(targetMarkerRange, 0);

  // Draw target crosshair
  ctx.save();
  ctx.strokeStyle = '#f43f5e';
  ctx.lineWidth = 2;
  ctx.setLineDash([4, 4]);

  // Vertical line from ground up
  const posTop = toCanvas(targetMarkerRange, VIS.maxAlt * 0.6);
  ctx.beginPath();
  ctx.moveTo(pos.x, pos.y);
  ctx.lineTo(posTop.x, posTop.y);
  ctx.stroke();
  ctx.setLineDash([]);

  // Target icon
  ctx.beginPath();
  ctx.arc(pos.x, pos.y, 8, 0, Math.PI * 2);
  ctx.strokeStyle = '#f43f5e';
  ctx.lineWidth = 2;
  ctx.stroke();
  ctx.beginPath();
  ctx.arc(pos.x, pos.y, 4, 0, Math.PI * 2);
  ctx.fillStyle = '#f43f5e';
  ctx.fill();

  // Label
  ctx.font = '10px Inter, sans-serif';
  ctx.fillStyle = '#f43f5e';
  ctx.textAlign = 'center';
  ctx.fillText(`🎯 ${targetMarkerRange} km`, pos.x, pos.y + 22);
  ctx.restore();
}

function drawRxMarker() {
  const rxLat = getRxLat();
  const rxLon = getRxLon();
  if (rxLat === null || rxLon === null || isNaN(rxLat) || isNaN(rxLon)) return;

  const txLat = getTxLat();
  const txLon = getTxLon();
  const { distance_km } = computeBearingDistance(txLat, txLon, rxLat, rxLon);

  const pos = toCanvas(distance_km, 0);

  ctx.save();

  // RX antenna icon
  ctx.strokeStyle = 'rgba(6, 182, 212, 0.8)';
  ctx.fillStyle = 'rgba(6, 182, 212, 0.8)';
  ctx.lineWidth = 1.5;

  // Mast
  ctx.beginPath();
  ctx.moveTo(pos.x, pos.y);
  ctx.lineTo(pos.x, pos.y - 10);
  ctx.stroke();

  // Dish (V shape at top)
  ctx.beginPath();
  ctx.moveTo(pos.x - 5, pos.y - 12);
  ctx.lineTo(pos.x, pos.y - 8);
  ctx.lineTo(pos.x + 5, pos.y - 12);
  ctx.strokeStyle = 'rgba(6, 182, 212, 0.6)';
  ctx.stroke();

  // Dot at base
  ctx.beginPath();
  ctx.arc(pos.x, pos.y, 3, 0, Math.PI * 2);
  ctx.fillStyle = 'rgba(6, 182, 212, 0.8)';
  ctx.fill();

  // Label
  ctx.font = '10px Inter, sans-serif';
  ctx.fillStyle = 'rgba(6, 182, 212, 0.9)';
  ctx.textAlign = 'center';
  ctx.fillText(`📡 RX ${Math.round(distance_km)} km`, pos.x, pos.y + 18);
  ctx.restore();
}

// ============================================================
// Ground range ruler
// ============================================================

function drawGroundRangeRuler() {
  const totalCircum = VIS.earthR * Math.PI * 2;
  // Determine a nice interval based on zoom
  const intervals = [100, 250, 500, 1000, 2500, 5000, 10000];
  // At zoom=1, ~800km is good. Scale inversely with zoom.
  const idealInterval = 800 / camera.zoom;
  let interval = intervals[0];
  for (const iv of intervals) {
    if (iv >= idealInterval * 0.5) { interval = iv; break; }
  }

  const maxRange = totalCircum / 2; // half circumference
  ctx.save();
  ctx.font = `${10 / camera.zoom}px JetBrains Mono, monospace`;
  ctx.textAlign = 'center';

  for (let d = interval; d < maxRange; d += interval) {
    const pos = toCanvas(d, 0);
    const posOuter = toCanvas(d, 15 / camera.zoom); // Small tick outward

    // Tick mark
    ctx.beginPath();
    ctx.moveTo(pos.x, pos.y);
    ctx.lineTo(posOuter.x, posOuter.y);
    ctx.strokeStyle = 'rgba(16, 185, 129, 0.3)';
    ctx.lineWidth = 1.5 / camera.zoom;
    ctx.stroke();

    // Label every tick
    const labelPos = toCanvas(d, 30 / camera.zoom);
    ctx.fillStyle = 'rgba(148, 163, 184, 0.5)';
    const label = d >= 1000 ? `${(d / 1000).toFixed(d % 1000 === 0 ? 0 : 1)}k` : `${d}`;
    ctx.fillText(label, labelPos.x, labelPos.y);
  }
  ctx.restore();
}

// ============================================================
// WASM-based ray tracing
// ============================================================

function traceRays() {
  const btn = document.getElementById('trace-btn');
  btn.classList.add('loading');
  btn.querySelector('.btn-icon').textContent = '⟳';

  const configs = buildCombinations();

  if (configs.length > MAX_COMBOS) {
    alert(`Too many combinations (${configs.length}). Max is ${MAX_COMBOS}. Please reduce selections.`);
    btn.classList.remove('loading');
    btn.querySelector('.btn-icon').textContent = '▶';
    return;
  }

  // Static params from fan sweep
  const elevMin = parseFloat(document.getElementById('elev-min').value);
  const elevMax = parseFloat(document.getElementById('elev-max').value);
  const elevStep = parseFloat(document.getElementById('elev-step').value);

  const newGroups = [];
  let totalElapsed = 0;
  let totalRays = 0;

  const maxHops = parseInt(document.getElementById('max-hops')?.value || '1');

  for (const cfg of configs) {
    const body = {
      freq_mhz: cfg.config.freq_mhz,
      ray_mode: cfg.config.ray_mode,
      elev_min: elevMin,
      elev_max: elevMax,
      elev_step: elevStep,
      azimuth_deg: getAzimuth(),
      tx_lat_deg: getTxLat(),
      fc: cfg.config.fc,
      hm: cfg.config.hm,
      sh: cfg.config.sh,
      fh: cfg.config.fh,
      step_size: 5.0,
      max_steps: 500,
      max_hops: maxHops,
      ed_model: cfg.config.ed_model,
      mag_model: cfg.config.mag_model,
      rindex_model: cfg.config.rindex_model,
      pert_model: cfg.config.pert_model,
    };

    // Store first body for export fallback
    if (newGroups.length === 0) lastTraceBody = body;

    try {
      const resultJson = trace_fan_wasm(JSON.stringify(body));
      const data = JSON.parse(resultJson);

      if (data.error) {
        console.error('Trace error:', data.error, cfg.label);
        continue;
      }

      const colorIdx = newGroups.length % GROUP_COLORS.length;
      newGroups.push({
        label: cfg.label,
        color: GROUP_COLORS[colorIdx],
        rays: data.rays,
        config: cfg.config,
      });
      totalElapsed += data.elapsed_ms || 0;
      totalRays += data.n_rays || 0;
    } catch (err) {
      console.error('Trace failed:', err, cfg.label);
    }
  }

  traceGroups = newGroups;

  // Update stats
  document.getElementById('stat-rays').textContent = `${totalRays} rays`;
  document.getElementById('stat-time').textContent = `${Math.round(totalElapsed)} ms`;

  // Enable export buttons
  document.getElementById('export-kml').disabled = false;
  document.getElementById('export-geojson').disabled = false;

  render();
  if (viewMode === '3d') {
    updateGlobeRays(traceGroups, getTxLat(), getTxLon(), getRxLat(), getRxLon());
  }
  updateLegend();
  serializeStateToUrl();

  btn.classList.remove('loading');
  btn.querySelector('.btn-icon').textContent = '▶';
}

// ============================================================
// Mouse interaction
// ============================================================

/** Convert screen coords to scene coords (accounting for camera) */
function screenToScene(sx, sy) {
  const cx = canvasW / 2;
  const cy = canvasH / 2;
  const x = (sx - camera.panX - cx) / camera.zoom + cx;
  const y = (sy - camera.panY - cy) / camera.zoom + cy;
  return { x, y };
}

function handleMouseMove(e) {
  const canvas = document.getElementById('canvas');
  const rect = canvas.getBoundingClientRect();

  // Handle zoom-rect dragging
  if (zoomRectMode && zoomRect) {
    zoomRect.x2 = e.clientX - rect.left;
    zoomRect.y2 = e.clientY - rect.top;
    render();
    return;
  }

  // Handle drag-pan
  if (camera.dragging) {
    camera.panX = camera.panStartX + (e.clientX - camera.dragStartX);
    camera.panY = camera.panStartY + (e.clientY - camera.dragStartY);
    render();
    return;
  }

  if (!traceGroups.length) return;

  const screenX = e.clientX - rect.left;
  const screenY = e.clientY - rect.top;
  // Transform mouse coords into scene space
  const { x: mx, y: my } = screenToScene(screenX, screenY);

  let closest = null;
  let closestDist = 20 / camera.zoom; // Scale hover distance with zoom

  for (let gi = 0; gi < traceGroups.length; gi++) {
    const group = traceGroups[gi];
    for (let ri = 0; ri < group.rays.length; ri++) {
      const ray = group.rays[ri];
      for (let j = 0; j < ray.pts.length; j++) {
        const pt = ray.pts[j];
        const pos = toCanvas(pt.range || pt.t, pt.h);
        const dx = pos.x - mx;
        const dy = pos.y - my;
        const dist = Math.sqrt(dx * dx + dy * dy);
        if (dist < closestDist) {
          closestDist = dist;
          closest = { groupIdx: gi, rayIdx: ri };
        }
      }
    }
  }

  const changed = (closest === null && hoveredRay !== null) ||
    (closest !== null && hoveredRay === null) ||
    (closest && hoveredRay && (closest.groupIdx !== hoveredRay.groupIdx || closest.rayIdx !== hoveredRay.rayIdx));

  if (changed) {
    hoveredRay = closest;
    render();
    updateInfoPanel();
  }
}

function updateInfoPanel() {
  const panel = document.getElementById('info-panel');

  if (!hoveredRay || !traceGroups[hoveredRay.groupIdx]) {
    panel.innerHTML = '<p class="info-hint">Hover over rays for details</p>';
    return;
  }

  const group = traceGroups[hoveredRay.groupIdx];
  const ray = group.rays[hoveredRay.rayIdx];
  const rangeStr = ray.range_km ? `${ray.range_km} km` : '—';

  let configHtml = '';
  if (traceGroups.length > 1) {
    configHtml = `<div class="config-label" style="background:${group.color}">${group.label}</div>`;
  }

  panel.innerHTML = `
    ${configHtml}
    <dl class="ray-detail">
      <dt>Elevation</dt><dd>${ray.elev}°</dd>
      <dt>Max Height</dt><dd>${ray.max_h} km</dd>
      <dt>Ground Range</dt><dd>${rangeStr}</dd>
      <dt>Ground Return</dt><dd>${ray.ground ? '✅ Yes' : '❌ No'}</dd>
      ${ray.absorption !== undefined ? `<dt>Absorption</dt><dd>${ray.absorption.toFixed(4)} dB</dd>` : ''}
      ${ray.hops > 0 ? `<dt>Hops</dt><dd>${ray.hops}</dd>` : ''}
      <dt>Points</dt><dd>${ray.pts.length}</dd>
    </dl>
  `;
}

// ============================================================
// Controls wiring
// ============================================================

// ============================================================
// Zoom / Pan helpers
// ============================================================

function zoomAt(fx, fy, factor) {
  const oldZoom = camera.zoom;
  camera.zoom = Math.max(ZOOM_MIN, Math.min(ZOOM_MAX, camera.zoom * factor));
  const scale = camera.zoom / oldZoom;
  const cx = canvasW / 2;
  const cy = canvasH / 2;
  // The camera transform: translate(panX,panY) → translate(cx,cy) → scale(zoom) → translate(-cx,-cy)
  // Screen coord = (scene - cx)*zoom + cx + panX
  // To keep the point under (fx,fy) fixed after zoom change:
  camera.panX = (fx - cx) * (1 - scale) + scale * camera.panX;
  camera.panY = (fy - cy) * (1 - scale) + scale * camera.panY;
  render();
}

function zoomIn() {
  zoomAt(canvasW / 2, canvasH / 2, 1.3);
}

function zoomOut() {
  zoomAt(canvasW / 2, canvasH / 2, 1 / 1.3);
}

function panDir(dx, dy) {
  const step = 60;
  camera.panX += dx * step;
  camera.panY += dy * step;
  render();
}

function resetView() {
  camera.zoom = 1.0;
  camera.panX = 0;
  camera.panY = 0;
  render();
}

/** Auto-fit the camera to show both TX and a target ground range */
function autoFitTargetView(targetRangeKm) {
  // We need render() first to set canvasW/canvasH
  render();

  // Compute bounding box at identity camera (zoom=1, pan=0)
  camera.zoom = 1; camera.panX = 0; camera.panY = 0;

  // Add a small margin beyond the target so the view isn't cut too tight
  const margin = targetRangeKm * 0.10;
  const txPos = toCanvas(-margin, 0);
  const tgtPos = toCanvas(targetRangeKm + margin, 0);

  // Estimate the arc peak height — use 50% of maxAlt for a tighter frame
  // that still comfortably shows typical ionospheric ray paths
  const arcHeight = Math.min(VIS.maxAlt * 0.5, 350);
  const midRange = targetRangeKm / 2;
  const midPosHigh = toCanvas(midRange, arcHeight);

  const allX = [txPos.x, tgtPos.x, midPosHigh.x];
  const allY = [txPos.y, tgtPos.y, midPosHigh.y];
  const minX = Math.min(...allX);
  const maxX = Math.max(...allX);
  const minY = Math.min(...allY);
  const maxY = Math.max(...allY);

  const bboxW = maxX - minX;
  const bboxH = maxY - minY;
  const bboxCx = (minX + maxX) / 2;
  const bboxCy = (minY + maxY) / 2;

  const padding = 40;
  const scaleX = (canvasW - 2 * padding) / Math.max(bboxW, 1);
  const scaleY = (canvasH - 2 * padding) / Math.max(bboxH, 1);
  const zoom = Math.max(ZOOM_MIN, Math.min(ZOOM_MAX, Math.min(scaleX, scaleY)));

  // Set camera to center on the bbox
  // Camera transform: translate(panX,panY) → translate(cx,cy) → scale(zoom) → translate(-cx,-cy)
  // To map scene point bboxC to screen center canvasC:
  //   canvasCx = panX + canvasCx*(1-zoom) + zoom*bboxCx
  //   panX = zoom * (canvasCx - bboxCx)
  const canvasCx = canvasW / 2;
  const canvasCy = canvasH / 2;
  camera.zoom = zoom;
  camera.panX = zoom * (canvasCx - bboxCx);
  camera.panY = zoom * (canvasCy - bboxCy);
  render();
}

// ============================================================
// Resize handle
// ============================================================

function wireResizeHandle() {
  const handle = document.getElementById('resize-handle');
  const app = document.getElementById('app');
  if (!handle) return;

  let startX = 0;
  let startWidth = 320;

  // Restore saved width
  const saved = localStorage.getItem('panel-width');
  if (saved) {
    const w = parseInt(saved, 10);
    if (w >= 220 && w <= 600) {
      document.documentElement.style.setProperty('--panel-width', w + 'px');
    }
  }

  handle.addEventListener('mousedown', (e) => {
    e.preventDefault();
    startX = e.clientX;
    startWidth = parseInt(getComputedStyle(document.documentElement).getPropertyValue('--panel-width'));
    handle.classList.add('dragging');
    document.body.style.cursor = 'col-resize';
    document.body.style.userSelect = 'none';

    const onMove = (e2) => {
      const delta = startX - e2.clientX;
      const newWidth = Math.max(220, Math.min(600, startWidth + delta));
      document.documentElement.style.setProperty('--panel-width', newWidth + 'px');
    };

    const onUp = () => {
      handle.classList.remove('dragging');
      document.body.style.cursor = '';
      document.body.style.userSelect = '';
      const finalWidth = parseInt(getComputedStyle(document.documentElement).getPropertyValue('--panel-width'));
      localStorage.setItem('panel-width', finalWidth);
      window.removeEventListener('mousemove', onMove);
      window.removeEventListener('mouseup', onUp);
      render();
    };

    window.addEventListener('mousemove', onMove);
    window.addEventListener('mouseup', onUp);
  });
}

// ============================================================
// Fullscreen toggle
// ============================================================

function wireFullscreenToggle() {
  const btn = document.getElementById('fullscreen-toggle');
  const app = document.getElementById('app');
  if (!btn) return;

  btn.addEventListener('click', () => {
    app.classList.toggle('fullscreen-map');
    btn.classList.toggle('active');
    // Re-render after transition
    setTimeout(() => render(), 250);
  });
}

// ============================================================
// Mode switching
// ============================================================

function wireModeSwitching() {
  const fanBtn = document.getElementById('mode-fan');
  const targetBtn = document.getElementById('mode-target');
  const targetControls = document.getElementById('target-controls');
  const fanSections = document.querySelectorAll('#fan-controls-transmitter, #controls .control-section:not(.run-mode-section):not(.target-section)');
  const traceBtn = document.getElementById('trace-btn');
  const exportBtns = document.querySelector('.export-buttons');

  function setMode(mode) {
    currentMode = mode;
    fanBtn.classList.toggle('active', mode === 'fan');
    targetBtn.classList.toggle('active', mode === 'target');
    targetControls.style.display = mode === 'target' ? 'block' : 'none';

    // Show/hide fan-specific controls
    if (traceBtn) traceBtn.style.display = mode === 'fan' ? 'flex' : 'none';
    if (exportBtns) exportBtns.style.display = mode === 'fan' ? 'flex' : 'none';

    // Show/hide RX location section
    const rxSection = document.getElementById('rx-location-container');
    if (rxSection) rxSection.style.display = mode === 'target' ? 'block' : 'none';

    // Clear target marker when switching to fan
    if (mode === 'fan') {
      targetMarkerRange = null;
      render();
    }
  }

  fanBtn.addEventListener('click', () => setMode('fan'));
  targetBtn.addEventListener('click', () => setMode('target'));
}

// ============================================================
// Bisection targeting
// ============================================================


async function targetBisection() {
    if (isTargeting) return;
    isTargeting = true;

    const btn = document.getElementById('target-btn');
    const stopBtn = document.getElementById('target-stop-btn');
    btn.classList.add('loading');
    btn.querySelector('.btn-icon').textContent = '⟳';
    btn.querySelector('.btn-label').textContent = 'Sweeping...';
    stopBtn.style.display = 'flex';
    stopTargeting = false;

    const tolerance = parseFloat(document.getElementById('target-tolerance').value);
    const maxHops = parseInt(document.getElementById('max-hops')?.value || '1');
    const searchLo = parseFloat(document.getElementById('target-search-min').value);
    const searchHi = parseFloat(document.getElementById('target-search-max').value);
    const maxIter = parseInt(document.getElementById('target-max-iter')?.value || '20');

    const logBody = document.getElementById('target-log-body');
    logBody.innerHTML = '<div class="target-log-row header"><span>#</span><span>Elev / Az</span><span>Range</span><span>Error</span><span>Landing</span></div>';

    traceGroups = [];

    // Determine target: use RX lat/lon if set, otherwise compute from target-range
    let targetLat, targetLon;
    const rxLat = getRxLat();
    const rxLon = getRxLon();
    const txLat = getTxLat();
    const txLon = getTxLon();

    if (rxLat !== null && rxLon !== null) {
        targetLat = rxLat;
        targetLon = rxLon - txLon;
    } else {
        const targetRange = parseFloat(document.getElementById('target-range').value);
        const az = getAzimuth();
        const R = 6371;
        const toRad2 = Math.PI / 180;
        const d = targetRange / R;
        const p1 = txLat * toRad2;
        const l1 = 0;
        const t1 = az * toRad2;
        targetLat = Math.asin(Math.sin(p1) * Math.cos(d) + Math.cos(p1) * Math.sin(d) * Math.cos(t1)) / toRad2;
        targetLon = (l1 + Math.atan2(Math.sin(t1) * Math.sin(d) * Math.cos(p1), Math.cos(d) - Math.sin(p1) * Math.sin(targetLat * toRad2))) / toRad2;
        targetMarkerRange = targetRange;
    }

    // Compute target ground range for signed error
    const toRad = Math.PI / 180;
    const targetRangeKm = (() => {
        const dLat = (targetLat - txLat) * toRad;
        const dLon = targetLon * toRad;
        const a = Math.sin(dLat / 2) ** 2 + Math.cos(txLat * toRad) * Math.cos(targetLat * toRad) * Math.sin(dLon / 2) ** 2;
        return 2 * 6371 * Math.asin(Math.sqrt(a));
    })();

    const baseFreq = parseFloat(document.getElementById('target-freq-min').value);
    const baseAz = getAzimuth();
    const rayMode = parseFloat(getCheckedValues('ray-mode-group', true)[0] || -1);

    // Build trace config for trace_fan_wasm (uses integer model IDs)
    const traceBase = {
        freq_mhz: baseFreq,
        ray_mode: rayMode,
        azimuth_deg: baseAz,
        tx_lat_deg: txLat,
        fc: parseFloat(document.getElementById('target-fc-min').value),
        hm: parseFloat(document.getElementById('target-hm-min').value),
        sh: parseFloat(document.getElementById('target-sh-min').value),
        fh: parseFloat(document.getElementById('fh').value),
        step_size: 1.0,
        max_steps: 2000,
        max_hops: maxHops,
        ed_model: parseInt(getCheckedValues('ed-model-group')[0] || 0),
        mag_model: parseInt(getCheckedValues('mag-model-group')[0] || 0),
        rindex_model: parseInt(getCheckedValues('rindex-model-group')[0] || 0),
        pert_model: parseInt(getCheckedValues('pert-model-group')[0] || 0),
    };

    let totalRays = 0;
    let rayIdx = 0;

    // Helper: trace a single ray at given elevation
    function traceSingleRay(elev) {
        const body = Object.assign({}, traceBase, { elev_min: elev, elev_max: elev, elev_step: 1.0 });
        try {
            const data = JSON.parse(trace_fan_wasm(JSON.stringify(body)));
            totalRays++;
            if (data.rays && data.rays.length > 0) return data.rays[0];
        } catch (e) { console.error('trace error:', e); }
        return null;
    }

    // Helper: compute signed range error (positive = overshot)
    function signedError(ray) {
        if (!ray || !ray.ground) return null;
        return ray.range_km - targetRangeKm;
    }

    // Helper: compute great-circle error from target
    function gcError(ray) {
        if (!ray || !ray.ground || ray.landing_lat == null) return Infinity;
        const dLat = (ray.landing_lat - targetLat) * toRad;
        const dLon = ((ray.landing_lon || 0) - targetLon) * toRad;
        const a = Math.sin(dLat / 2) ** 2 + Math.cos(targetLat * toRad) * Math.cos(ray.landing_lat * toRad) * Math.sin(dLon / 2) ** 2;
        return 2 * 6371 * Math.asin(Math.sqrt(a));
    }

    // Helper: add a ray to the display
    function addRayGroup(ray, elev, color, opacity, label) {
        if (!ray || !ray.pts || ray.pts.length < 2) return;
        traceGroups.push({
            label: label || (elev.toFixed(1) + ' deg'),
            color: color,
            opacity: opacity,
            rays: [ray],
            config: traceBase,
        });
    }

    // Helper: fade all existing non-final rays
    function fadeOldRays() {
        for (let i = 0; i < traceGroups.length; i++) {
            if (traceGroups[i].color !== '#10b981') {
                traceGroups[i].opacity = Math.min(traceGroups[i].opacity || 0.6, 0.12);
                traceGroups[i].color = '#475569';
            }
        }
    }

    // Helper: update visuals
    async function refreshDisplay() {
        render();
        if (viewMode === '3d') updateGlobeRays(traceGroups, getTxLat(), getTxLon(), getRxLat(), getRxLon());
        updateLegend();
        await new Promise(function (r) { setTimeout(r, 5); });
    }

    // Helper: log a ray
    function logRay(ray, elev) {
        rayIdx++;
        const err = gcError(ray);
        const rangeStr = (ray && ray.ground) ? (ray.range_km.toFixed(1) + ' km') : 'escape';
        const errStr = err < Infinity ? (err.toFixed(1) + ' km') : '—';
        const landStr = (ray && ray.landing_lat != null) ? (ray.landing_lat.toFixed(2) + ', ' + (ray.landing_lon || 0).toFixed(2) + ' deg') : '—';
        const cls = err <= tolerance ? 'success' : ((ray && ray.ground) ? 'fail' : 'escape');
        logBody.innerHTML += '<div class="target-log-row ' + cls + '"><span>' + rayIdx + '</span><span>' + elev.toFixed(2) + ' / ' + baseAz.toFixed(1) + '</span><span>' + rangeStr + '</span><span>' + errStr + '</span><span>' + landStr + '</span></div>';
        logBody.scrollTop = logBody.scrollHeight;
    }

    // ========== PHASE 1: Coarse sweep ==========
    const coarseStep = 2.0;
    const sweepResults = [];

    for (let e = searchLo; e <= searchHi + 0.01; e += coarseStep) {
        if (stopTargeting) break;
        const ray = traceSingleRay(e);
        const sErr = signedError(ray);
        sweepResults.push({ elev: e, ray: ray, signedErr: sErr });

        if (ray && ray.pts && ray.pts.length >= 2) {
            addRayGroup(ray, e, '#475569', 0.25, 'sweep ' + e.toFixed(1) + ' deg');
            logRay(ray, e);
        }

        btn.querySelector('.btn-label').textContent = 'Sweep ' + e.toFixed(0) + ' deg';
        await refreshDisplay();
    }

    // ========== PHASE 2: Identify brackets ==========
    const brackets = [];
    for (let i = 0; i < sweepResults.length - 1; i++) {
        const a = sweepResults[i], b = sweepResults[i + 1];
        if (a.signedErr != null && b.signedErr != null && a.signedErr * b.signedErr < 0) {
            brackets.push({ lo: a.elev, hi: b.elev, errLo: a.signedErr, errHi: b.signedErr });
        }
    }

    // ========== PHASE 3: Bisection ==========
    let bestRay = null, bestElev = 0, bestErr = Infinity;

    for (const bracket of brackets) {
        if (stopTargeting) break;
        let lo = bracket.lo, hi = bracket.hi, errLo = bracket.errLo;

        btn.querySelector('.btn-label').textContent = 'Bisecting...';

        for (let iter = 0; iter < maxIter; iter++) {
            if (stopTargeting) break;
            const mid = (lo + hi) / 2;
            const ray = traceSingleRay(mid);
            const sErr = signedError(ray);
            const err = gcError(ray);

            if (ray && ray.pts && ray.pts.length >= 2) {
                fadeOldRays();
                const isClose = err <= tolerance;
                addRayGroup(ray, mid,
                    isClose ? '#10b981' : '#f59e0b',
                    isClose ? 1.0 : 0.7,
                    'bisect ' + mid.toFixed(2) + ' deg (err ' + err.toFixed(1) + ' km)'
                );
                logRay(ray, mid);
            }

            if (err < bestErr) {
                bestErr = err;
                bestRay = ray;
                bestElev = mid;
            }

            if (err <= tolerance) break;

            if (sErr != null && sErr * errLo < 0) {
                hi = mid;
            } else {
                lo = mid;
                errLo = sErr;
            }

            if (Math.abs(hi - lo) < 0.001) break;

            btn.querySelector('.btn-label').textContent = 'Bisect ' + (iter + 1) + '/' + maxIter;
            await refreshDisplay();
        }
    }

    // ========== PHASE 4: Final result ==========
    fadeOldRays();

    if (bestRay && bestRay.pts && bestRay.pts.length >= 2) {
        addRayGroup(bestRay, bestElev, '#10b981', 1.0,
            'Best ' + bestElev.toFixed(2) + ' deg -> ' + (bestRay.range_km || 0).toFixed(0) + ' km (err ' + bestErr.toFixed(1) + ')'
        );
    }

    // Show solver stats
    const summary = document.getElementById('target-range-summary');
    summary.style.display = 'block';

    const found = bestErr <= tolerance;
    document.getElementById('fan-range-min').textContent = (bestRay && bestRay.range_km) ? (bestRay.range_km.toFixed(0) + ' km') : '—';
    document.getElementById('fan-range-max').textContent = (bestRay && bestRay.range_km) ? (bestRay.range_km.toFixed(0) + ' km') : '—';
    document.getElementById('fan-returned-count').textContent = found ? '1' : '0';
    document.getElementById('fan-escaped-count').textContent = totalRays.toString();

    const hintEl = document.getElementById('fan-range-hint');
    if (found) {
        hintEl.textContent = 'Best: ' + bestElev.toFixed(2) + ' deg elev -> error ' + bestErr.toFixed(1) + ' km (' + totalRays + ' rays)';
        hintEl.className = 'range-hint good';
        targetMarkerRange = bestRay.range_km;
    } else {
        hintEl.textContent = 'No solution within ' + tolerance + ' km tolerance. ' + totalRays + ' rays traced.';
        hintEl.className = 'range-hint';
    }

    document.getElementById('stat-rays').textContent = totalRays + ' rays';
    document.getElementById('stat-time').textContent = found ? 'found' : 'not found';

    btn.classList.remove('loading');
    btn.querySelector('.btn-icon').textContent = '🎯';
    btn.querySelector('.btn-label').textContent = 'Find Path';
    stopBtn.style.display = 'none';
    isTargeting = false;
    stopTargeting = false;

    await refreshDisplay();
    serializeStateToUrl();
}






// ============================================================
// Controls wiring
// ============================================================




function wireControls() {
  // Slider → output wiring
  const sliders = [
    ['freq', 'freq-val', v => parseFloat(v).toFixed(1)],
    ['elev-min', 'elev-min-val', v => v],
    ['elev-max', 'elev-max-val', v => v],
    ['elev-step', 'elev-step-val', v => parseFloat(v).toFixed(1)],
    ['fc', 'fc-val', v => parseFloat(v).toFixed(1)],
    ['hm', 'hm-val', v => v],
    ['sh', 'sh-val', v => v],
    ['fh', 'fh-val', v => parseFloat(v).toFixed(1)],
    ['max-hops', 'max-hops-val', v => v],
  ];

  for (const [id, outId, fmt] of sliders) {
    const input = document.getElementById(id);
    const output = document.getElementById(outId);
    if (!input || !output) continue;
    input.addEventListener('input', () => {
      output.textContent = fmt(input.value);
      updateComboCount();
    });
  }

  // Sweep toggles
  document.querySelectorAll('.sweep-toggle').forEach(btn => {
    btn.addEventListener('click', () => {
      const target = btn.dataset.target;
      const singleDiv = document.getElementById(`${target}-single`);
      const sweepDiv = document.getElementById(`${target}-sweep`);
      const isActive = btn.classList.toggle('active');

      if (isActive) {
        singleDiv.style.display = 'none';
        sweepDiv.classList.remove('hidden');
      } else {
        singleDiv.style.display = 'flex';
        sweepDiv.classList.add('hidden');
      }
      updateComboCount();
    });
  });

  // Sweep input changes update combo count
  document.querySelectorAll('.sweep-field input').forEach(input => {
    input.addEventListener('input', () => updateComboCount());
  });

  // Checkbox changes update combo count
  document.querySelectorAll('.checkbox-group input[type="checkbox"]').forEach(cb => {
    cb.addEventListener('change', () => {
      // Ensure at least one is checked in each group
      const group = cb.closest('.checkbox-group');
      const checked = group.querySelectorAll('input:checked');
      if (checked.length === 0) {
        cb.checked = true; // prevent unchecking the last one
        return;
      }
      updateComboCount();
    });
  });

  // Trace button
  document.getElementById('trace-btn').addEventListener('click', traceRays);

  // Target button — always runs unified bisection
  document.getElementById('target-btn').addEventListener('click', () => {
    targetBisection();
  });

  // Stop button — cancels bisection
  document.getElementById('target-stop-btn').addEventListener('click', () => {
    stopTargeting = true;
  });

  // Auto-fit camera when target range changes
  const targetRangeInput = document.getElementById('target-range');
  if (targetRangeInput) {
    targetRangeInput.addEventListener('change', () => {
      if (currentMode === 'target') {
        const val = parseFloat(targetRangeInput.value);
        if (!isNaN(val) && val > 0) {
          targetMarkerRange = val;
          autoFitTargetView(val);
        }
      }
    });
  }


  // Canvas mouse — hover
  const canvas = document.getElementById('canvas');
  canvas.addEventListener('mousemove', handleMouseMove);
  canvas.addEventListener('mouseleave', () => {
    if (camera.dragging) {
      camera.dragging = false;
      canvas.style.cursor = 'grab';
    }
    hoveredRay = null;
    render();
    updateInfoPanel();
  });

  // Canvas mouse — pan (any click)
  canvas.style.cursor = 'grab';
  canvas.addEventListener('mousedown', (e) => {
    e.preventDefault();
    camera.dragging = true;
    camera.dragStartX = e.clientX;
    camera.dragStartY = e.clientY;
    camera.panStartX = camera.panX;
    camera.panStartY = camera.panY;
    canvas.style.cursor = 'grabbing';
  });
  window.addEventListener('mouseup', () => {
    if (camera.dragging) {
      camera.dragging = false;
      canvas.style.cursor = 'grab';
    }
  });

  // Prevent context menu on canvas so right-click drag works
  canvas.addEventListener('contextmenu', (e) => e.preventDefault());

  // Canvas mouse — zoom (scroll wheel)
  canvas.addEventListener('wheel', (e) => {
    e.preventDefault();
    const rect = canvas.getBoundingClientRect();
    const mx = e.clientX - rect.left;
    const my = e.clientY - rect.top;
    const zoomFactor = e.deltaY < 0 ? 1.12 : 1 / 1.12;
    zoomAt(mx, my, zoomFactor);
  }, { passive: false });

  // Double-click to reset view
  canvas.addEventListener('dblclick', () => resetView());

  // Reset view button
  const resetBtn = document.getElementById('reset-view');
  if (resetBtn) resetBtn.addEventListener('click', resetView);

  // Zoom in/out buttons
  document.getElementById('zoom-in')?.addEventListener('click', zoomIn);
  document.getElementById('zoom-out')?.addEventListener('click', zoomOut);

  // Pan arrow buttons
  document.querySelectorAll('.pan-btn').forEach(btn => {
    btn.addEventListener('click', () => {
      const dir = btn.dataset.dir;
      switch (dir) {
        case 'up': panDir(0, 1); break;
        case 'down': panDir(0, -1); break;
        case 'left': panDir(1, 0); break;
        case 'right': panDir(-1, 0); break;
      }
    });
  });

  // Resize
  window.addEventListener('resize', () => {
    render();
    updateLegend();
  });

  // Wire resize handle and fullscreen
  wireResizeHandle();
  wireFullscreenToggle();
  wireModeSwitching();

  wireInfoModal();

  // Accordion section toggles
  document.querySelectorAll('.section-toggle').forEach(toggle => {
    toggle.addEventListener('click', () => {
      const sectionId = toggle.dataset.section;
      const body = document.getElementById(`section-${sectionId}`);
      const chevron = toggle.querySelector('.chevron');
      if (body) {
        body.classList.toggle('collapsed');
        chevron.textContent = body.classList.contains('collapsed') ? '▸' : '▾';
      }
    });
  });

  // Zoom-rect button
  document.getElementById('zoom-rect-btn')?.addEventListener('click', () => {
    zoomRectMode = !zoomRectMode;
    const btn = document.getElementById('zoom-rect-btn');
    const canvas = document.getElementById('canvas');
    btn.classList.toggle('zoom-rect-active', zoomRectMode);
    canvas.classList.toggle('zoom-rect-cursor', zoomRectMode);
  });

  // Ionosphere layers toggle
  document.getElementById('iono-layers-btn')?.addEventListener('click', () => {
    showIonoLayers = !showIonoLayers;
    const btn = document.getElementById('iono-layers-btn');
    btn.style.opacity = showIonoLayers ? '1' : '0.4';
    render();
  });

  // Ionosphere key toggle
  document.getElementById('iono-key-btn')?.addEventListener('click', () => {
    const key = document.getElementById('iono-key');
    const btn = document.getElementById('iono-key-btn');
    const visible = key.style.display !== 'none';
    key.style.display = visible ? 'none' : 'block';
    btn.style.opacity = visible ? '0.4' : '1';
  });
  // Geolocation button
  document.getElementById('geolocate-btn')?.addEventListener('click', () => {
    requestGeolocation();
  });

  // Sync TX location inputs → IRI lat/lon + RX computed
  document.getElementById('tx-lat')?.addEventListener('change', () => {
    const iriLat = document.getElementById('iri-lat');
    if (iriLat) iriLat.value = Math.round(getTxLat());
    updateTxRxComputed();
  });
  document.getElementById('tx-lon')?.addEventListener('change', () => {
    const iriLon = document.getElementById('iri-lon');
    if (iriLon) iriLon.value = Math.round(getTxLon());
    updateTxRxComputed();
  });

  // RX Destination controls
  document.getElementById('rx-geolocate-btn')?.addEventListener('click', () => {
    requestRxGeolocation();
  });
  document.getElementById('rx-clear-btn')?.addEventListener('click', () => {
    clearRxLocation();
  });
  document.getElementById('rx-lat')?.addEventListener('change', () => {
    updateTxRxComputed();
  });
  document.getElementById('rx-lon')?.addEventListener('change', () => {
    updateTxRxComputed();
  });

  // Globe select buttons
  let globePickMode = null; // default null, only pick on explicit command

  function resetGlobePick() {
    globePickMode = null;
    document.getElementById('tx-globe-pick-btn')?.classList.remove('active-pick');
    document.getElementById('rx-globe-pick-btn')?.classList.remove('active-pick');

    // Hide and reset globe hints
    const hint = document.getElementById('globe-hint');
    if (hint) {
      hint.style.display = 'none';
      hint.className = 'globe-hint';
    }
  }

  document.getElementById('tx-globe-pick-btn')?.addEventListener('click', () => {
    if (globePickMode === 'tx') {
      resetGlobePick();
      return;
    }

    resetGlobePick(); // clear UI states first
    globePickMode = 'tx';
    document.getElementById('tx-globe-pick-btn')?.classList.add('active-pick');

    const hint = document.getElementById('globe-hint');
    if (hint) {
      hint.textContent = 'Click anywhere on globe to set TX (Start) location';
      hint.className = 'globe-hint tx-mode';
      hint.style.display = 'block';
    }
    if (viewMode === '2d') {
      document.getElementById('view-3d-btn')?.click();
    }
  });

  document.getElementById('rx-globe-pick-btn')?.addEventListener('click', () => {
    if (globePickMode === 'rx') {
      resetGlobePick();
      return;
    }

    resetGlobePick(); // clear UI states first
    globePickMode = 'rx';
    document.getElementById('rx-globe-pick-btn')?.classList.add('active-pick');

    const hint = document.getElementById('globe-hint');
    if (hint) {
      hint.textContent = 'Click anywhere on globe to set Target (RX) location';
      hint.className = 'globe-hint rx-mode';
      hint.style.display = 'block';
    }
    if (viewMode === '2d') {
      document.getElementById('view-3d-btn')?.click();
    }
  });

  // Azimuth slider output sync
  const azSlider = document.getElementById('azimuth');
  const azOutput = document.getElementById('azimuth-val');
  if (azSlider && azOutput) {
    azSlider.addEventListener('input', () => {
      azOutput.textContent = azSlider.value;
    });
  }

  // 3D globe view toggle
  document.getElementById('view-3d-btn')?.addEventListener('click', () => {
    const btn = document.getElementById('view-3d-btn');
    const canvasEl = document.getElementById('canvas');
    const globeEl = document.getElementById('globe-container');

    if (viewMode === '2d') {
      // Switch to 3D
      viewMode = '3d';
      if (!globeInitialized) {
        initGlobe(globeEl);
        // Wire click-to-pick: relies on globePickMode state
        onGlobeClick((lat, lon) => {
          if (!globePickMode) return; // Do nothing if a button isn't toggled!

          if (globePickMode === 'rx') {
            setRxLocation(lat, lon);
          } else if (globePickMode === 'tx') {
            setTxLocation(lat, lon, `${lat.toFixed(1)}°, ${lon.toFixed(1)}°`, 'located');
          }

          // Clear picking mode after 1 successful tap
          resetGlobePick();
        });
        globeInitialized = true;
      }
      canvasEl.style.display = 'none';
      setGlobeVisible(true);
      const hint = document.getElementById('globe-hint');
      if (hint) {
        hint.style.display = 'block';
        if (!hint.textContent || hint.textContent.includes('Click:')) {
          hint.textContent = 'Click anywhere on globe to set TX (Start) location';
          hint.className = 'globe-hint tx-mode';
        }
      }

      // Push current ray data to 3D
      const txLat = getTxLat();
      const txLon = getTxLon();
      const rxLat = getRxLat();
      const rxLon = getRxLon();
      updateGlobeRays(traceGroups, txLat, txLon, rxLat, rxLon);

      btn.textContent = '2D';
      btn.style.opacity = '1';
    } else {
      // Switch to 2D
      viewMode = '2d';
      canvasEl.style.display = 'block';
      setGlobeVisible(false);
      document.getElementById('globe-hint').style.display = 'none';
      btn.textContent = '3D';
      btn.style.opacity = '0.4';
      render();
    }
  });

  // Zoom-rect mousedown
  canvas.addEventListener('mousedown', (e) => {
    if (!zoomRectMode) return;
    const rect = canvas.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const y = e.clientY - rect.top;
    zoomRect = { x1: x, y1: y, x2: x, y2: y };
    e.preventDefault();
    e.stopPropagation();
  }, true);

  // Zoom-rect mouseup — compute zoom to fit
  canvas.addEventListener('mouseup', (e) => {
    if (!zoomRectMode || !zoomRect) return;
    const rect = canvas.getBoundingClientRect();
    zoomRect.x2 = e.clientX - rect.left;
    zoomRect.y2 = e.clientY - rect.top;

    const rx = Math.min(zoomRect.x1, zoomRect.x2);
    const ry = Math.min(zoomRect.y1, zoomRect.y2);
    const rw = Math.abs(zoomRect.x2 - zoomRect.x1);
    const rh = Math.abs(zoomRect.y2 - zoomRect.y1);

    // Only zoom if the rectangle is big enough (not a click)
    if (rw > 10 && rh > 10) {
      // Center of the selection rectangle in screen coords
      const selCenterX = rx + rw / 2;
      const selCenterY = ry + rh / 2;

      // Compute scale factor: fit selection to canvas, maintaining canvas AR
      const scaleX = canvasW / rw;
      const scaleY = canvasH / rh;
      const zoomFactor = Math.min(scaleX, scaleY);

      const newZoom = Math.max(ZOOM_MIN, Math.min(ZOOM_MAX, camera.zoom * zoomFactor));
      const scale = newZoom / camera.zoom;
      const cx = canvasW / 2;
      const cy = canvasH / 2;

      // Use same formula as zoomAt, but zoom toward selection center
      // then also shift so selection center lands at canvas center
      // Step 1: scene point at selection center
      // sceneX = (selCenterX - cx - panX) / zoom + cx
      // Step 2: after zoom, we want sceneX at screen center (cx, cy):
      // cx = (sceneX - cx)*newZoom + cx + newPanX  →  newPanX = -(sceneX - cx)*newZoom
      const sceneX = (selCenterX - cx - camera.panX) / camera.zoom + cx;
      const sceneY = (selCenterY - cy - camera.panY) / camera.zoom + cy;
      camera.panX = -(sceneX - cx) * newZoom;
      camera.panY = -(sceneY - cy) * newZoom;
      camera.zoom = newZoom;
    }

    // Exit zoom-rect mode
    zoomRect = null;
    zoomRectMode = false;
    document.getElementById('zoom-rect-btn').classList.remove('zoom-rect-active');
    canvas.classList.remove('zoom-rect-cursor');
    canvas.style.cursor = 'grab';
    render();
  }, true);

  // Screenshot button
  // Screenshot dropdown
  const screenshotBtn = document.getElementById('screenshot-btn');
  const screenshotDropdown = screenshotBtn?.closest('.screenshot-dropdown');
  screenshotBtn?.addEventListener('click', (e) => {
    e.stopPropagation();
    screenshotDropdown.classList.toggle('open');
  });
  document.getElementById('screenshot-current')?.addEventListener('click', () => {
    screenshotCurrent();
    screenshotDropdown.classList.remove('open');
  });
  document.getElementById('screenshot-full')?.addEventListener('click', () => {
    screenshotFullGlobe();
    screenshotDropdown.classList.remove('open');
  });
  // Close dropdown when clicking outside
  document.addEventListener('click', () => {
    screenshotDropdown?.classList.remove('open');
  });

  // Ionogram toggle
  document.getElementById('ionogram-toggle')?.addEventListener('click', () => {
    const panel = document.getElementById('ionogram-panel');
    panel.style.display = panel.style.display === 'none' ? 'block' : 'none';
    if (panel.style.display === 'block') renderIonogram();
  });
  document.getElementById('ionogram-close')?.addEventListener('click', () => {
    document.getElementById('ionogram-panel').style.display = 'none';
  });

  // MUF/LUF
  document.getElementById('muf-luf-btn')?.addEventListener('click', calculateMufLuf);

  // IRI model
  document.getElementById('iri-toggle')?.addEventListener('click', () => {
    const controls = document.getElementById('iri-controls');
    const btn = document.getElementById('iri-toggle');
    const visible = controls.style.display !== 'none';
    controls.style.display = visible ? 'none' : 'block';
    btn.classList.toggle('active', !visible);
  });
  document.getElementById('iri-ssn')?.addEventListener('input', (e) => {
    document.getElementById('iri-ssn-val').textContent = e.target.value;
  });
  document.getElementById('iri-calculate')?.addEventListener('click', calculateIRI);
}

// ============================================================
// Info Modal
// ============================================================

function wireInfoModal() {
  const modal = document.getElementById('info-modal');
  const openBtn = document.getElementById('info-btn');
  const closeBtn = document.getElementById('info-close');

  function openModal() {
    modal.style.display = 'flex';
  }

  function closeModal() {
    modal.style.display = 'none';
  }

  openBtn.addEventListener('click', openModal);
  closeBtn.addEventListener('click', closeModal);

  // Close on backdrop click
  modal.addEventListener('click', (e) => {
    if (e.target === modal) closeModal();
  });

  // Close on Escape key
  document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape' && modal.style.display !== 'none') closeModal();
  });

  // Tab switching
  const tabs = modal.querySelectorAll('.info-tab');
  const tabContents = modal.querySelectorAll('.info-tab-content');

  tabs.forEach(tab => {
    tab.addEventListener('click', () => {
      tabs.forEach(t => t.classList.remove('active'));
      tabContents.forEach(tc => tc.classList.remove('active'));
      tab.classList.add('active');
      const targetId = `tab-${tab.dataset.tab}`;
      document.getElementById(targetId).classList.add('active');
    });
  });
}

// ============================================================
// Export (client-side)
// ============================================================

function exportFile(format) {
  if (!traceGroups.length) return;

  if (format === 'kml') {
    exportKml();
  } else {
    exportGeoJson();
  }
}

function exportKml() {
  const txLat = 40.0;
  const freqMhz = lastTraceBody ? lastTraceBody.freq_mhz : 10.0;

  const lines = [
    '<?xml version="1.0" encoding="UTF-8"?>',
    '<kml xmlns="http://www.opengis.net/kml/2.2">',
    '<Document>',
    `  <name>Ray Trace ${freqMhz} MHz</name>`,
    '  <Style id="rayReturned"><LineStyle><color>ff00ff00</color><width>2</width></LineStyle></Style>',
    '  <Style id="rayEscaped"><LineStyle><color>ff0000ff</color><width>1</width></LineStyle></Style>',
  ];

  for (const group of traceGroups) {
    for (const ray of group.rays) {
      const style = ray.ground ? 'rayReturned' : 'rayEscaped';
      lines.push('  <Placemark>');
      lines.push(`    <name>Elev ${ray.elev}°</name>`);
      lines.push(`    <description>Max height: ${ray.max_h} km, Range: ${ray.range_km || 0} km</description>`);
      lines.push(`    <styleUrl>#${style}</styleUrl>`);
      lines.push('    <LineString>');
      lines.push('      <altitudeMode>absolute</altitudeMode>');
      const coords = ray.pts.map(pt => {
        const lon = pt.lon || 0;
        const lat = pt.lat || txLat;
        const alt = pt.h * 1000;
        return `${lon},${lat},${alt.toFixed(0)}`;
      });
      lines.push(`      <coordinates>${coords.join(' ')}</coordinates>`);
      lines.push('    </LineString>');
      lines.push('  </Placemark>');
    }
  }

  lines.push('</Document>', '</kml>');

  const blob = new Blob([lines.join('\n')], { type: 'application/vnd.google-earth.kml+xml' });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = 'raytrace.kml';
  a.click();
  URL.revokeObjectURL(url);
}

function exportGeoJson() {
  const txLat = 40.0;
  const features = [];

  for (const group of traceGroups) {
    for (const ray of group.rays) {
      const coords = ray.pts.map(pt => [
        pt.lon || 0,
        pt.lat || txLat,
        pt.h,
      ]);
      features.push({
        type: 'Feature',
        properties: {
          elevation_deg: ray.elev,
          max_height_km: ray.max_h,
          ground_range_km: ray.range_km || 0,
          returned: ray.ground,
          configuration: group.label,
        },
        geometry: {
          type: 'LineString',
          coordinates: coords,
        },
      });
    }
  }

  const geojson = {
    type: 'FeatureCollection',
    features,
    properties: {
      n_rays: features.length,
    },
  };

  const blob = new Blob([JSON.stringify(geojson, null, 2)], { type: 'application/json' });
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url;
  a.download = 'raytrace.geojson';
  a.click();
  URL.revokeObjectURL(url);
}

// ============================================================
// Init
// ============================================================

async function main() {
  // Initialize WASM module
  await init();

  wireControls();
  updateComboCount();

  // Request geolocation on load (non-blocking)
  requestGeolocation();

  document.getElementById('export-kml').addEventListener('click', () => exportFile('kml'));
  document.getElementById('export-geojson').addEventListener('click', () => exportFile('geojson'));

  // Restore state from URL before first trace
  restoreStateFromUrl();

  render();
  // Auto-trace on load
  traceRays();
}

document.addEventListener('DOMContentLoaded', main);

// ============================================================
// URL State Persistence
// ============================================================

/** Serialize current UI state to URL hash */
function serializeStateToUrl() {
  const params = new URLSearchParams();

  // Core sliders
  const sliderIds = ['freq', 'elev-min', 'elev-max', 'elev-step', 'fc', 'hm', 'sh', 'fh', 'max-hops', 'azimuth'];
  for (const id of sliderIds) {
    const el = document.getElementById(id);
    if (el) params.set(id, el.value);
  }

  // Checkbox groups — store checked values as comma-separated
  for (const cg of CHECKBOX_GROUPS) {
    const group = document.getElementById(cg.groupId);
    const checked = group.querySelectorAll('input[type="checkbox"]:checked');
    const vals = Array.from(checked).map(cb => cb.value);
    if (vals.length) params.set(cg.groupId, vals.join(','));
  }

  // Mode
  params.set('mode', currentMode);

  // Target range
  const targetEl = document.getElementById('target-range');
  if (targetEl) params.set('target-range', targetEl.value);

  // TX location
  const txLatEl = document.getElementById('tx-lat');
  const txLonEl = document.getElementById('tx-lon');
  if (txLatEl) params.set('tx-lat', txLatEl.value);
  if (txLonEl) params.set('tx-lon', txLonEl.value);

  // RX destination
  const rxLatEl = document.getElementById('rx-lat');
  const rxLonEl = document.getElementById('rx-lon');
  if (rxLatEl && rxLatEl.value !== '') params.set('rx-lat', rxLatEl.value);
  if (rxLonEl && rxLonEl.value !== '') params.set('rx-lon', rxLonEl.value);

  window.history.replaceState(null, '', '#' + params.toString());
}

/** Restore UI state from URL hash */
function restoreStateFromUrl() {
  const hash = window.location.hash.slice(1);
  if (!hash) return;

  const params = new URLSearchParams(hash);

  // Restore sliders
  const sliderOutputMap = {
    'freq': 'freq-val', 'elev-min': 'elev-min-val', 'elev-max': 'elev-max-val',
    'elev-step': 'elev-step-val', 'fc': 'fc-val', 'hm': 'hm-val',
    'sh': 'sh-val', 'fh': 'fh-val', 'max-hops': 'max-hops-val',
    'azimuth': 'azimuth-val',
  };
  const floatFormat = new Set(['freq', 'elev-step', 'fc', 'fh']);

  for (const [id, outId] of Object.entries(sliderOutputMap)) {
    const val = params.get(id);
    if (val === null) continue;
    const el = document.getElementById(id);
    const out = document.getElementById(outId);
    if (el) {
      el.value = val;
      if (out) out.textContent = floatFormat.has(id) ? parseFloat(val).toFixed(1) : val;
    }
  }

  // Restore TX location
  const txLat = params.get('tx-lat');
  const txLon = params.get('tx-lon');
  if (txLat !== null || txLon !== null) {
    const lat = txLat !== null ? parseFloat(txLat) : 40;
    const lon = txLon !== null ? parseFloat(txLon) : -80;
    setTxLocation(lat, lon, 'From URL', 'located');
  }

  // Restore RX destination
  const rxLat = params.get('rx-lat');
  const rxLon = params.get('rx-lon');
  if (rxLat !== null && rxLon !== null) {
    setRxLocation(parseFloat(rxLat), parseFloat(rxLon));
  }

  // Restore checkbox groups
  for (const cg of CHECKBOX_GROUPS) {
    const valsStr = params.get(cg.groupId);
    if (!valsStr) continue;
    const vals = valsStr.split(',');
    const group = document.getElementById(cg.groupId);
    group.querySelectorAll('input[type="checkbox"]').forEach(cb => {
      cb.checked = vals.includes(cb.value);
    });
  }

  // Restore mode
  const mode = params.get('mode');
  if (mode === 'target') {
    document.getElementById('mode-target')?.click();
  }

  // Restore target range
  const targetRange = params.get('target-range');
  if (targetRange) {
    const el = document.getElementById('target-range');
    if (el) el.value = targetRange;
  }

  updateComboCount();
}

// ============================================================
// Screenshot export
// ============================================================

const EXPORT_SCALE_VIEW = 5;  // 5x for current view exports
const EXPORT_SCALE_FULL = 5;  // 5x for full globe exports

function renderToOffscreen(exportScale, overrideCamera) {
  const sourceCanvas = document.getElementById('canvas');
  const sourceRect = sourceCanvas.getBoundingClientRect();
  const w = sourceRect.width;
  const h = sourceRect.height;

  // Create offscreen canvas at higher resolution
  const offscreen = document.createElement('canvas');
  offscreen.width = w * exportScale;
  offscreen.height = h * exportScale;

  // Save real canvas state
  const realCtx = ctx;
  const realW = canvasW;
  const realH = canvasH;
  const realCamera = { zoom: camera.zoom, panX: camera.panX, panY: camera.panY };

  // Apply override camera if provided
  if (overrideCamera) {
    camera.zoom = overrideCamera.zoom;
    camera.panX = overrideCamera.panX;
    camera.panY = overrideCamera.panY;
  }

  // Temporarily swap globals for render
  ctx = offscreen.getContext('2d');
  ctx.scale(exportScale, exportScale);
  canvasW = w;
  canvasH = h;

  // Read ionosphere params
  const fc = parseFloat(document.getElementById('fc').value);
  const hm = parseFloat(document.getElementById('hm').value);

  // Adjust maxAlt
  if (traceGroups.length) {
    let maxH = 0;
    for (const group of traceGroups) {
      for (const ray of group.rays) {
        if (ray.max_h > maxH) maxH = ray.max_h;
      }
    }
    VIS.maxAlt = Math.max(300, Math.min(800, maxH * 1.3));
  }

  // Full render pipeline
  drawBackground();
  ctx.save();
  ctx.translate(camera.panX, camera.panY);
  const cx = canvasW / 2;
  const cy = canvasH / 2;
  ctx.translate(cx, cy);
  ctx.scale(camera.zoom, camera.zoom);
  ctx.translate(-cx, -cy);
  if (showIonoLayers) drawIonosphereLayers(fc, hm);
  drawEarth();
  drawGroundRangeRuler();
  drawAltitudeScale();
  drawRays();
  drawTargetMarker();
  drawTitle();
  ctx.restore();

  // Restore globals
  ctx = realCtx;
  canvasW = realW;
  canvasH = realH;
  camera.zoom = realCamera.zoom;
  camera.panX = realCamera.panX;
  camera.panY = realCamera.panY;

  return offscreen;
}

function downloadOffscreen(offscreen, suffix) {
  offscreen.toBlob((blob) => {
    if (!blob) return;
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    const timestamp = new Date().toISOString().replace(/[:.]/g, '-').slice(0, 19);
    a.download = `raytrace-${suffix}-${timestamp}.png`;
    a.click();
    URL.revokeObjectURL(url);
  }, 'image/png');
}

function screenshotCurrent() {
  const offscreen = renderToOffscreen(EXPORT_SCALE_VIEW);
  downloadOffscreen(offscreen, 'view');
}

function screenshotFullGlobe() {
  const offscreen = renderToOffscreen(EXPORT_SCALE_FULL, { zoom: 1, panX: 0, panY: 0 });
  downloadOffscreen(offscreen, 'full');
}

// ============================================================
// MUF/LUF Calculator
// ============================================================

function calculateMufLuf() {
  const btn = document.getElementById('muf-luf-btn');
  const resultsDiv = document.getElementById('muf-luf-results');
  const targetRange = parseFloat(document.getElementById('target-range')?.value || '1500');

  if (!targetRange || targetRange <= 0) {
    alert('Please set a valid target range first.');
    return;
  }

  btn.classList.add('loading');
  btn.innerHTML = '<span class="btn-icon">⟳</span><span>Calculating...</span>';

  // Use requestAnimationFrame to let the UI update
  requestAnimationFrame(() => {
    const fc = parseFloat(document.getElementById('fc').value);
    const hm = parseFloat(document.getElementById('hm').value);
    const sh = parseFloat(document.getElementById('sh').value);
    const fh = parseFloat(document.getElementById('fh').value);
    const tolerance = targetRange * 0.05; // 5% tolerance

    let muf = null;
    let luf = null;

    // Sweep frequencies from 1 to 30 MHz in 0.5 steps
    for (let freq = 1.0; freq <= 30.0; freq += 0.5) {
      const body = {
        freq_mhz: freq,
        ray_mode: -1,
        elev_min: 3,
        elev_max: 80,
        elev_step: 1,
        azimuth_deg: getAzimuth(),
        tx_lat_deg: getTxLat(),
        fc, hm, sh, fh,
        step_size: 5.0,
        max_steps: 500,
        max_hops: 1,
        ed_model: 0,
        mag_model: 0,
        rindex_model: 0,
        pert_model: 0,
      };

      const resultJson = trace_fan_wasm(JSON.stringify(body));
      const result = JSON.parse(resultJson);

      if (result.rays) {
        let found = false;
        for (const ray of result.rays) {
          if (ray.ground && Math.abs(ray.range_km - targetRange) <= tolerance) {
            found = true;
            break;
          }
        }

        if (found) {
          muf = freq;
          if (luf === null) luf = freq;
        }
      }
    }

    // Display results
    resultsDiv.style.display = 'block';
    document.getElementById('muf-value').textContent = muf ? `${muf.toFixed(1)} MHz` : 'N/A';
    document.getElementById('luf-value').textContent = luf ? `${luf.toFixed(1)} MHz` : 'N/A';
    const owf = muf ? muf * 0.85 : null;
    document.getElementById('owf-value').textContent = owf ? `${owf.toFixed(1)} MHz` : 'N/A';

    btn.classList.remove('loading');
    btn.innerHTML = '<span class="btn-icon">📡</span><span>Calculate MUF/LUF</span>';
  });
}

// ============================================================
// Ionogram Renderer
// ============================================================

function renderIonogram() {
  const canvas = document.getElementById('ionogram-canvas');
  if (!canvas) return;

  const rect = canvas.parentElement.getBoundingClientRect();
  const dpr = window.devicePixelRatio || 1;
  canvas.width = rect.width * dpr;
  canvas.height = 200 * dpr;
  const ictx = canvas.getContext('2d');
  ictx.scale(dpr, dpr);

  const w = rect.width;
  const h = 200;
  const pad = { left: 50, right: 15, top: 15, bottom: 30 };
  const plotW = w - pad.left - pad.right;
  const plotH = h - pad.top - pad.bottom;

  // Read current ionosphere params
  const fc = parseFloat(document.getElementById('fc').value);
  const hm = parseFloat(document.getElementById('hm').value);
  const sh = parseFloat(document.getElementById('sh').value);
  const fh = parseFloat(document.getElementById('fh').value);

  // Sweep frequencies
  const freqMin = 1.0;
  const freqMax = Math.min(30, fc * 1.5);
  const freqStep = 0.25;

  const data = []; // { freq, virtualHeight }

  for (let freq = freqMin; freq <= freqMax; freq += freqStep) {
    const body = {
      freq_mhz: freq,
      ray_mode: -1,
      elev_min: 90,
      elev_max: 90,
      elev_step: 1,
      azimuth_deg: getAzimuth(),
      tx_lat_deg: getTxLat(),
      fc, hm, sh, fh,
      step_size: 5.0,
      max_steps: 500,
      max_hops: 1,
      ed_model: 0,
      mag_model: 0,
      rindex_model: 0,
      pert_model: 0,
    };

    const resultJson = trace_fan_wasm(JSON.stringify(body));
    const result = JSON.parse(resultJson);

    if (result.rays && result.rays.length > 0) {
      const ray = result.rays[0];
      if (ray.ground && ray.pts.length > 1) {
        // Virtual height ≈ group_path / 2 — approximate as max height for vertical
        const virtualHeight = ray.max_h;
        data.push({ freq, virtualHeight });
      } else if (ray.max_h > 0) {
        // Penetration — mark as very high (off scale)
        data.push({ freq, virtualHeight: ray.max_h > 500 ? null : ray.max_h });
      }
    }
  }

  // Background
  ictx.fillStyle = 'rgba(15, 23, 42, 0.95)';
  ictx.fillRect(0, 0, w, h);

  // Grid
  ictx.strokeStyle = 'rgba(148, 163, 184, 0.1)';
  ictx.lineWidth = 1;

  const maxVH = 600;
  const vhScale = plotH / maxVH;
  const freqScale = plotW / (freqMax - freqMin);

  // Vertical grid (frequency)
  for (let f = Math.ceil(freqMin); f <= freqMax; f += 2) {
    const x = pad.left + (f - freqMin) * freqScale;
    ictx.beginPath();
    ictx.moveTo(x, pad.top);
    ictx.lineTo(x, pad.top + plotH);
    ictx.stroke();
  }

  // Horizontal grid (height)
  for (let vh = 100; vh <= maxVH; vh += 100) {
    const y = pad.top + plotH - vh * vhScale;
    ictx.beginPath();
    ictx.moveTo(pad.left, y);
    ictx.lineTo(pad.left + plotW, y);
    ictx.stroke();
  }

  // Data points
  ictx.fillStyle = '#06b6d4';
  for (const pt of data) {
    if (pt.virtualHeight === null || pt.virtualHeight > maxVH) continue;
    const x = pad.left + (pt.freq - freqMin) * freqScale;
    const y = pad.top + plotH - pt.virtualHeight * vhScale;
    ictx.beginPath();
    ictx.arc(x, y, 2.5, 0, Math.PI * 2);
    ictx.fill();
  }

  // Connect with line
  ictx.strokeStyle = 'rgba(6, 182, 212, 0.4)';
  ictx.lineWidth = 1.5;
  ictx.beginPath();
  let started = false;
  for (const pt of data) {
    if (pt.virtualHeight === null || pt.virtualHeight > maxVH) { started = false; continue; }
    const x = pad.left + (pt.freq - freqMin) * freqScale;
    const y = pad.top + plotH - pt.virtualHeight * vhScale;
    if (!started) { ictx.moveTo(x, y); started = true; }
    else ictx.lineTo(x, y);
  }
  ictx.stroke();

  // foF2 vertical line
  const foF2x = pad.left + (fc - freqMin) * freqScale;
  ictx.strokeStyle = 'rgba(244, 63, 94, 0.5)';
  ictx.lineWidth = 1;
  ictx.setLineDash([4, 3]);
  ictx.beginPath();
  ictx.moveTo(foF2x, pad.top);
  ictx.lineTo(foF2x, pad.top + plotH);
  ictx.stroke();
  ictx.setLineDash([]);

  // foF2 label
  ictx.font = '9px JetBrains Mono, monospace';
  ictx.fillStyle = '#f43f5e';
  ictx.textAlign = 'center';
  ictx.fillText('foF2', foF2x, pad.top - 3);

  // Axes labels
  ictx.font = '9px Inter, sans-serif';
  ictx.fillStyle = 'rgba(148, 163, 184, 0.6)';

  // X axis
  ictx.textAlign = 'center';
  for (let f = Math.ceil(freqMin); f <= freqMax; f += 2) {
    const x = pad.left + (f - freqMin) * freqScale;
    ictx.fillText(`${f}`, x, h - pad.bottom + 15);
  }
  ictx.fillText('Frequency (MHz)', pad.left + plotW / 2, h - 3);

  // Y axis
  ictx.textAlign = 'right';
  for (let vh = 100; vh <= maxVH; vh += 100) {
    const y = pad.top + plotH - vh * vhScale;
    ictx.fillText(`${vh}`, pad.left - 5, y + 3);
  }

  // Y axis title
  ictx.save();
  ictx.translate(10, pad.top + plotH / 2);
  ictx.rotate(-Math.PI / 2);
  ictx.textAlign = 'center';
  ictx.fillText('Virtual Height (km)', 0, 0);
  ictx.restore();

  // Border
  ictx.strokeStyle = 'rgba(148, 163, 184, 0.25)';
  ictx.lineWidth = 1;
  ictx.strokeRect(pad.left, pad.top, plotW, plotH);
}

// ============================================================
// Simplified IRI Model
// ============================================================

function calculateIRI() {
  const lat = parseFloat(document.getElementById('iri-lat').value);
  const lon = parseFloat(document.getElementById('iri-lon').value);
  const dateStr = document.getElementById('iri-date').value;
  const timeStr = document.getElementById('iri-time').value;
  const ssn = parseFloat(document.getElementById('iri-ssn').value);

  const date = new Date(`${dateStr}T${timeStr}:00Z`);
  const doy = getDayOfYear(date);

  // Solar zenith angle calculation
  const declination = 23.45 * Math.sin(2 * Math.PI * (284 + doy) / 365) * Math.PI / 180;
  const hourAngle = ((date.getUTCHours() + date.getUTCMinutes() / 60 + lon / 15) - 12) * 15 * Math.PI / 180;
  const latRad = lat * Math.PI / 180;

  const cosZenith = Math.sin(latRad) * Math.sin(declination) +
    Math.cos(latRad) * Math.cos(declination) * Math.cos(hourAngle);
  const zenith = Math.acos(Math.max(-1, Math.min(1, cosZenith)));
  const chi = zenith * 180 / Math.PI;

  // Simplified foF2 model (based on CCIR empirical relations)
  // foF2 peaks at local noon (chi=0), drops at night
  // SSN relationship: foF2 ≈ sqrt(0.00121 * SSN + 0.0196) * daytime_factor * latitude_factor

  // Solar activity index (proxy for F10.7)
  const ig12 = 0.0113 * ssn * ssn + 0.267 * ssn; // IG12 approximation
  const f107 = 63.75 + 0.728 * ssn + 0.00089 * ssn * ssn;

  // Electron density depends on solar zenith angle
  const cosChi = Math.max(0.01, Math.cos(zenith));
  const chiExp = Math.pow(cosChi, 0.3); // Chapman function approximation

  // Base foF2 (daytime, mid-latitude)
  const foF2day = 3.0 + 0.03 * ssn; // MHz range: ~3 at SSN=0, ~10.5 at SSN=250

  // Latitude factor (equatorial anomaly enhancement at ±15°, reduction at high lats)
  const absLat = Math.abs(lat);
  let latFactor = 1.0;
  if (absLat < 20) {
    latFactor = 1.0 + 0.3 * Math.sin(Math.PI * absLat / 20);
  } else if (absLat > 60) {
    latFactor = 0.7 - 0.3 * ((absLat - 60) / 30);
    latFactor = Math.max(0.3, latFactor);
  }

  // Season factor
  const seasonPhase = lat >= 0 ? 0 : Math.PI; // opposite seasons for hemispheres
  const seasonFactor = 1.0 + 0.15 * Math.cos(2 * Math.PI * (doy - 172) / 365 + seasonPhase);

  // Night factor — foF2 drops significantly at night
  let foF2;
  if (chi < 85) {
    // Daytime
    foF2 = foF2day * chiExp * latFactor * seasonFactor;
  } else if (chi < 100) {
    // Twilight transition
    const t = (chi - 85) / 15;
    const dayVal = foF2day * Math.pow(Math.cos(85 * Math.PI / 180), 0.3) * latFactor * seasonFactor;
    const nightVal = dayVal * 0.35;
    foF2 = dayVal * (1 - t) + nightVal * t;
  } else {
    // Night
    foF2 = foF2day * 0.35 * latFactor * seasonFactor;
  }

  // Clamp foF2 to reasonable range
  foF2 = Math.max(2, Math.min(18, foF2));

  // hmF2 (peak height) — empirical formula
  // hmF2 increases at night, around sunset/sunrise, and at high latitudes
  const hmF2base = 250;
  const hmF2nightBoost = chi > 90 ? 50 * Math.min(1, (chi - 90) / 30) : 0;
  const hmF2latBoost = absLat > 45 ? 30 * ((absLat - 45) / 45) : 0;
  const hmF2 = Math.round(hmF2base + hmF2nightBoost + hmF2latBoost + 0.3 * ssn / 10);

  // Scale height — proportional to hmF2/4.5, typical 50-120 km
  const scaleHeight = Math.round(Math.max(40, Math.min(180, hmF2 / 3.5)));

  // Update sliders
  const fcSlider = document.getElementById('fc');
  const hmSlider = document.getElementById('hm');
  const shSlider = document.getElementById('sh');

  const fcVal = Math.round(foF2 * 2) / 2; // snap to 0.5 steps
  fcSlider.value = Math.min(parseFloat(fcSlider.max), Math.max(parseFloat(fcSlider.min), fcVal));
  document.getElementById('fc-val').textContent = parseFloat(fcSlider.value).toFixed(1);

  hmSlider.value = Math.min(parseFloat(hmSlider.max), Math.max(parseFloat(hmSlider.min), hmF2));
  document.getElementById('hm-val').textContent = hmSlider.value;

  shSlider.value = Math.min(parseFloat(shSlider.max), Math.max(parseFloat(shSlider.min), scaleHeight));
  document.getElementById('sh-val').textContent = shSlider.value;
}

function getDayOfYear(date) {
  const start = new Date(date.getFullYear(), 0, 0);
  const diff = date - start;
  return Math.floor(diff / 86400000);
}

