// globe3d.js — Three.js 3D globe renderer for ionospheric ray tracing
// Self-contained module with clean API for integration with the existing 2D view.

import * as THREE from 'three';
import { OrbitControls } from 'three/addons/controls/OrbitControls.js';

const EARTH_R = 6371; // km
const SCALE = 1 / EARTH_R; // normalize so Earth radius = 1

let scene, camera, renderer, controls;
let container;
let earthMesh, atmosphereMesh, cloudMesh;
let gridGroup;
let rayGroup; // Group holding all ray line objects
let txMarker;
let rxMarker;
let landingMarker;
let arcGroup;
let animFrameId;
let raycaster, mouse;
let clickCallback = null; // callback for click-to-pick
let hasAutoOriented = false; // track if we've auto-oriented camera to TX

// ---- Public API ----

export function initGlobe(containerEl) {
    container = containerEl;
    const w = container.clientWidth;
    const h = container.clientHeight;

    // Scene
    scene = new THREE.Scene();
    scene.background = new THREE.Color(0x020510);

    // Camera
    camera = new THREE.PerspectiveCamera(45, w / h, 0.01, 100);
    camera.position.set(0, 0, 3.2);

    // Renderer
    renderer = new THREE.WebGLRenderer({ antialias: true, alpha: false });
    renderer.setSize(w, h);
    renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    renderer.toneMapping = THREE.ACESFilmicToneMapping;
    renderer.toneMappingExposure = 1.2;
    container.appendChild(renderer.domElement);

    // Controls
    controls = new OrbitControls(camera, renderer.domElement);
    controls.enableDamping = true;
    controls.dampingFactor = 0.08;
    controls.minDistance = 1.2;
    controls.maxDistance = 10;
    controls.rotateSpeed = 0.8;
    controls.zoomSpeed = 1.0;

    // Lighting — realistic sun setup (modified to light up the whole globe)
    const hemiLight = new THREE.HemisphereLight(0xffffff, 0xffffff, 0.6);
    scene.add(hemiLight);

    // Instead of a single directional sun, we use multiple directional lights to light all sides
    const light1 = new THREE.DirectionalLight(0xfff5e6, 1.0);
    light1.position.set(5, 3, 5);
    scene.add(light1);

    const light2 = new THREE.DirectionalLight(0xfff5e6, 1.0);
    light2.position.set(-5, 3, -5);
    scene.add(light2);

    const light3 = new THREE.DirectionalLight(0xfff5e6, 1.0);
    light3.position.set(5, -3, -5);
    scene.add(light3);

    const light4 = new THREE.DirectionalLight(0xfff5e6, 1.0);
    light4.position.set(-5, -3, 5);
    scene.add(light4);

    const ambient = new THREE.AmbientLight(0x404040, 1.5);
    scene.add(ambient);

    // Starfield background
    createStarfield();

    // Earth
    createEarth();

    // Ray group
    rayGroup = new THREE.Group();
    scene.add(rayGroup);

    // Raycaster for click-to-pick
    raycaster = new THREE.Raycaster();
    mouse = new THREE.Vector2();

    // Drag-vs-click discrimination: only fire click if mouse barely moved
    let mouseDownPos = { x: 0, y: 0 };
    renderer.domElement.addEventListener('mousedown', (e) => {
        mouseDownPos.x = e.clientX;
        mouseDownPos.y = e.clientY;
    });
    renderer.domElement.addEventListener('click', (e) => {
        const dx = e.clientX - mouseDownPos.x;
        const dy = e.clientY - mouseDownPos.y;
        if (Math.sqrt(dx * dx + dy * dy) < 5) {
            onGlobeClickInternal(e);
        }
    });

    // Handle resize
    const ro = new ResizeObserver(() => onResize());
    ro.observe(container);

    // Start render loop
    animate();
}

/** Orient the globe camera to look at a given lat/lon. */
export function lookAtLocation(lat, lon) {
    if (!camera || !controls) return;
    const latR = THREE.MathUtils.degToRad(lat);
    const lonR = THREE.MathUtils.degToRad(lon);
    const dist = camera.position.length() || 3.2;
    camera.position.set(
        dist * Math.cos(latR) * Math.sin(lonR),
        dist * Math.sin(latR),
        dist * Math.cos(latR) * Math.cos(lonR)
    );
    controls.target.set(0, 0, 0);
    controls.update();
}

/** Zoom 3D camera to fit two lat/lon points with 120% padding. */
export function zoomToFit(lat1, lon1, lat2, lon2) {
    if (!camera || !controls) return;

    // Midpoint on sphere
    const midLat = (lat1 + lat2) / 2;
    const midLon = (lon1 + lon2) / 2;

    // Angular distance between points (degrees)
    const toRad = Math.PI / 180;
    const dLat = (lat2 - lat1) * toRad;
    const dLon = (lon2 - lon1) * toRad;
    const a = Math.sin(dLat / 2) ** 2 +
        Math.cos(lat1 * toRad) * Math.cos(lat2 * toRad) * Math.sin(dLon / 2) ** 2;
    const angularDist = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a)); // radians

    // Camera distance: factor of 1.2 for 120% coverage
    // FOV-based calculation: distance = radius / tan(fov/2), adjusted for angular span
    const halfFov = THREE.MathUtils.degToRad(camera.fov / 2);
    const span = Math.max(angularDist, 0.05); // minimum span to avoid too-close zoom
    const dist = Math.max(1.3, (1.2 * span) / halfFov + 1.0);

    const latR = THREE.MathUtils.degToRad(midLat);
    const lonR = THREE.MathUtils.degToRad(midLon);
    camera.position.set(
        dist * Math.cos(latR) * Math.sin(lonR),
        dist * Math.sin(latR),
        dist * Math.cos(latR) * Math.cos(lonR)
    );
    controls.target.set(0, 0, 0);
    controls.update();
}

export function updateGlobeRays(traceGroups, txLatDeg, txLonDeg, rxLatDeg, rxLonDeg) {
    if (!scene) return;

    // Auto-orient camera to TX on first render so rays are visible
    if (!hasAutoOriented && txLatDeg != null && txLonDeg != null) {
        lookAtLocation(txLatDeg, txLonDeg);
        hasAutoOriented = true;
    }

    // Clear old rays
    while (rayGroup.children.length > 0) {
        const child = rayGroup.children[0];
        child.geometry?.dispose();
        child.material?.dispose();
        rayGroup.remove(child);
    }

    // Remove old TX marker
    if (txMarker) {
        scene.remove(txMarker);
        txMarker = null;
    }

    // Remove old RX marker
    if (rxMarker) {
        scene.remove(rxMarker);
        rxMarker = null;
    }

    // Remove old direction arc
    if (arcGroup) {
        scene.remove(arcGroup);
        arcGroup = null;
    }

    // Remove old landing marker
    if (landingMarker) {
        scene.remove(landingMarker);
        landingMarker = null;
    }

    // Get TX lat/lon
    const txLat = txLatDeg ?? 40;
    const txLon = txLonDeg ?? 0;

    // TX marker at actual location
    createTxMarker(txLat, txLon);

    // RX marker if destination is set
    if (rxLatDeg != null && rxLonDeg != null && !isNaN(rxLatDeg) && !isNaN(rxLonDeg)) {
        createRxMarker(rxLatDeg, rxLonDeg);
    }

    if (!traceGroups || traceGroups.length === 0) return;

    // Draw rays — ray lon values are relative (tracer starts at phi=0),
    // so offset by TX longitude to place on the real globe
    let renderedCount = 0;
    for (const group of traceGroups) {
        const color = new THREE.Color(group.color || '#60a5fa');
        for (const ray of group.rays) {
            if (!ray || !ray.pts || ray.pts.length < 2) {
                console.warn("Skipping ray in 3D globe because it lacks coordinate points:", ray);
                continue;
            }
            const positions = [];
            for (const pt of ray.pts) {
                const pos = latLonAltToVec3(pt.lat, pt.lon + txLon, pt.h);
                positions.push(pos.x, pos.y, pos.z);
            }
            const geometry = new THREE.BufferGeometry();
            geometry.setAttribute('position', new THREE.Float32BufferAttribute(positions, 3));
            const material = new THREE.LineBasicMaterial({
                color,
                transparent: true,
                opacity: group.opacity != null ? group.opacity : (group.color === '#10b981' ? 1.0 : 0.8),
                linewidth: 1,
            });
            const line = new THREE.Line(geometry, material);
            rayGroup.add(line);
            renderedCount++;
        }
    }
    console.log(`Updated 3D Globe with ${renderedCount} total drawn rays. traceGroups:`, traceGroups);

    // Draw landing marker for the last successful trace ray
    for (let gi = traceGroups.length - 1; gi >= 0; gi--) {
        const g = traceGroups[gi];
        if (g.color === '#10b981' && g.rays.length > 0) {
            const ray = g.rays[0];
            if (ray.landing_lat !== undefined && ray.landing_lon !== undefined && ray.ground) {
                createLandingMarker(ray.landing_lat, ray.landing_lon + (txLatDeg !== undefined ? txLonDeg ?? 0 : 0));
            }
            break;
        }
    }
}

export function setGlobeVisible(visible) {
    if (container) {
        container.style.display = visible ? 'block' : 'none';
    }
    if (visible) {
        onResize();
    }
}

export function disposeGlobe() {
    if (animFrameId) cancelAnimationFrame(animFrameId);
    if (renderer) {
        renderer.dispose();
        renderer.domElement.remove();
    }
}

/** Register a callback for when the user clicks on the globe surface.
 *  Callback receives (latDeg, lonDeg). */
export function onGlobeClick(callback) {
    clickCallback = callback;
}

// ---- Internal ----

function latLonAltToVec3(latDeg, lonDeg, altKm) {
    const r = 1 + altKm * SCALE;
    const lat = THREE.MathUtils.degToRad(latDeg);
    // Offset by +PI/2 to match the texture seam mapping
    const lon = THREE.MathUtils.degToRad(lonDeg) + Math.PI / 2;
    // Three.js: Y is up, X is right, Z is toward viewer
    return new THREE.Vector3(
        r * Math.cos(lat) * Math.sin(lon),
        r * Math.sin(lat),
        r * Math.cos(lat) * Math.cos(lon)
    );
}

function vec3ToLatLon(vec) {
    const r = vec.length();
    const latRad = Math.asin(Math.max(-1, Math.min(1, vec.y / r)));
    // Texture seam is at +Z. For correct earth coordinates:
    let lonRad = Math.atan2(vec.x, vec.z) - Math.PI / 2;
    if (lonRad < -Math.PI) lonRad += Math.PI * 2;
    if (lonRad > Math.PI) lonRad -= Math.PI * 2;
    return {
        lat: THREE.MathUtils.radToDeg(latRad),
        lon: THREE.MathUtils.radToDeg(lonRad),
    };
}

function createStarfield() {
    const starCount = 2000;
    const positions = new Float32Array(starCount * 3);
    const sizes = new Float32Array(starCount);
    for (let i = 0; i < starCount; i++) {
        const theta = Math.random() * Math.PI * 2;
        const phi = Math.acos(2 * Math.random() - 1);
        const r = 30 + Math.random() * 20;
        positions[i * 3] = r * Math.sin(phi) * Math.cos(theta);
        positions[i * 3 + 1] = r * Math.sin(phi) * Math.sin(theta);
        positions[i * 3 + 2] = r * Math.cos(phi);
        sizes[i] = Math.random() * 1.5 + 0.5;
    }
    const starGeom = new THREE.BufferGeometry();
    starGeom.setAttribute('position', new THREE.Float32BufferAttribute(positions, 3));
    starGeom.setAttribute('size', new THREE.Float32BufferAttribute(sizes, 1));
    const starMat = new THREE.PointsMaterial({
        color: 0xffffff,
        size: 0.08,
        transparent: true,
        opacity: 0.6,
        sizeAttenuation: true,
    });
    scene.add(new THREE.Points(starGeom, starMat));
}

function createEarth() {
    const loader = new THREE.TextureLoader();

    // Earth sphere with Blue Marble texture
    const earthGeom = new THREE.SphereGeometry(1, 128, 96);

    // Load Earth texture from public CDN
    const earthTexUrl = 'https://unpkg.com/three-globe/example/img/earth-blue-marble.jpg';
    const bumpTexUrl = 'https://unpkg.com/three-globe/example/img/earth-topology.png';

    const earthMat = new THREE.MeshPhongMaterial({
        color: 0xffffff,
        specular: 0x333344,
        shininess: 25,
    });

    // Load textures asynchronously
    loader.load(earthTexUrl, (texture) => {
        texture.colorSpace = THREE.SRGBColorSpace;
        earthMat.map = texture;
        earthMat.needsUpdate = true;
    }, undefined, (err) => {
        // Fallback to procedural colors if texture fails
        console.warn('Earth texture failed to load, using fallback:', err);
        earthMat.color.set(0x112244);
        earthMat.emissive.set(0x061018);
    });

    loader.load(bumpTexUrl, (texture) => {
        earthMat.bumpMap = texture;
        earthMat.bumpScale = 0.015;
        earthMat.needsUpdate = true;
    });

    earthMesh = new THREE.Mesh(earthGeom, earthMat);
    scene.add(earthMesh);

    // Grid lines (latitude/longitude) — semi-transparent overlay
    gridGroup = new THREE.Group();

    // Longitude lines
    for (let lon = -180; lon < 180; lon += 30) {
        const pts = [];
        for (let lat = -90; lat <= 90; lat += 2) {
            pts.push(latLonAltToVec3(lat, lon, 2));
        }
        const geom = new THREE.BufferGeometry().setFromPoints(pts);
        const mat = new THREE.LineBasicMaterial({ color: 0xffffff, transparent: true, opacity: 0.08 });
        gridGroup.add(new THREE.Line(geom, mat));
    }

    // Latitude lines
    for (let lat = -60; lat <= 60; lat += 30) {
        const pts = [];
        for (let lon = -180; lon <= 180; lon += 2) {
            pts.push(latLonAltToVec3(lat, lon, 2));
        }
        const geom = new THREE.BufferGeometry().setFromPoints(pts);
        const mat = new THREE.LineBasicMaterial({ color: 0xffffff, transparent: true, opacity: 0.08 });
        gridGroup.add(new THREE.Line(geom, mat));
    }

    // Equator (brighter)
    const eqPts = [];
    for (let lon = -180; lon <= 180; lon += 2) {
        eqPts.push(latLonAltToVec3(0, lon, 2));
    }
    const eqGeom = new THREE.BufferGeometry().setFromPoints(eqPts);
    const eqMat = new THREE.LineBasicMaterial({ color: 0x44ddaa, transparent: true, opacity: 0.15 });
    gridGroup.add(new THREE.Line(eqGeom, eqMat));

    scene.add(gridGroup);

    // Atmosphere glow — multi-layer for realistic effect
    // Inner atmosphere
    const atmosGeom1 = new THREE.SphereGeometry(1.015, 64, 48);
    const atmosMat1 = new THREE.MeshPhongMaterial({
        color: 0x88bbff,
        transparent: true,
        opacity: 0.06,
        side: THREE.FrontSide,
    });
    scene.add(new THREE.Mesh(atmosGeom1, atmosMat1));

    // Outer atmosphere glow
    const atmosGeom2 = new THREE.SphereGeometry(1.04, 64, 48);
    const atmosMat2 = new THREE.MeshPhongMaterial({
        color: 0x4488ff,
        transparent: true,
        opacity: 0.04,
        side: THREE.BackSide,
    });
    atmosphereMesh = new THREE.Mesh(atmosGeom2, atmosMat2);
    scene.add(atmosphereMesh);

    // Fresnel-like atmosphere rim
    const atmosGeom3 = new THREE.SphereGeometry(1.025, 64, 48);
    const atmosMat3 = new THREE.ShaderMaterial({
        vertexShader: `
            varying vec3 vNormal;
            varying vec3 vPosition;
            void main() {
                vNormal = normalize(normalMatrix * normal);
                vPosition = (modelViewMatrix * vec4(position, 1.0)).xyz;
                gl_Position = projectionMatrix * modelViewMatrix * vec4(position, 1.0);
            }
        `,
        fragmentShader: `
            varying vec3 vNormal;
            varying vec3 vPosition;
            void main() {
                vec3 viewDir = normalize(-vPosition);
                float fresnel = 1.0 - dot(viewDir, vNormal);
                fresnel = pow(fresnel, 3.0);
                vec3 color = mix(vec3(0.3, 0.6, 1.0), vec3(0.5, 0.8, 1.0), fresnel);
                gl_FragColor = vec4(color, fresnel * 0.5);
            }
        `,
        transparent: true,
        side: THREE.FrontSide,
        depthWrite: false,
    });
    scene.add(new THREE.Mesh(atmosGeom3, atmosMat3));

    // Cloud layer (subtle)
    const cloudGeom = new THREE.SphereGeometry(1.008, 64, 48);
    const cloudMat = new THREE.MeshPhongMaterial({
        color: 0xffffff,
        transparent: true,
        opacity: 0.0, // will be set when texture loads
        depthWrite: false,
    });
    cloudMesh = new THREE.Mesh(cloudGeom, cloudMat);

    const cloudTexUrl = 'https://unpkg.com/three-globe/example/img/earth-water.png';
    loader.load(cloudTexUrl, (texture) => {
        cloudMat.alphaMap = texture;
        cloudMat.opacity = 0.15;
        cloudMat.needsUpdate = true;
    });

    scene.add(cloudMesh);
}

function createTxMarker(latDeg, lonDeg) {
    txMarker = new THREE.Group();

    const pos = latLonAltToVec3(latDeg, lonDeg, 0);
    const towerTop = latLonAltToVec3(latDeg, lonDeg, 15);

    // Tower mast
    const mastGeom = new THREE.BufferGeometry().setFromPoints([pos, towerTop]);
    const mastMat = new THREE.LineBasicMaterial({ color: 0x10b981, linewidth: 1 });
    txMarker.add(new THREE.Line(mastGeom, mastMat));

    // Small wave arcs at top
    for (let i = 1; i <= 2; i++) {
        const ringR = 0.003 * i;
        const ringGeom = new THREE.RingGeometry(ringR - 0.0005, ringR, 12);
        const ringMat = new THREE.MeshBasicMaterial({
            color: 0x10b981, transparent: true, opacity: 0.3 - i * 0.1, side: THREE.DoubleSide,
        });
        const ring = new THREE.Mesh(ringGeom, ringMat);
        ring.position.copy(towerTop);
        ring.lookAt(pos.clone().multiplyScalar(2));
        txMarker.add(ring);
    }

    // Tiny dot at base
    const dotGeom = new THREE.SphereGeometry(0.002, 6, 6);
    const dotMat = new THREE.MeshBasicMaterial({ color: 0x10b981 });
    const dot = new THREE.Mesh(dotGeom, dotMat);
    dot.position.copy(pos);
    txMarker.add(dot);

    scene.add(txMarker);
}

function createRxMarker(latDeg, lonDeg) {
    rxMarker = new THREE.Group();

    const pos = latLonAltToVec3(latDeg, lonDeg, 0);
    const towerTop = latLonAltToVec3(latDeg, lonDeg, 12);

    // Tower mast
    const mastGeom = new THREE.BufferGeometry().setFromPoints([pos, towerTop]);
    const mastMat = new THREE.LineBasicMaterial({ color: 0xef4444, linewidth: 1 });
    rxMarker.add(new THREE.Line(mastGeom, mastMat));

    // Small dish at top
    const dishLeft = latLonAltToVec3(latDeg - 0.15, lonDeg - 0.15, 16);
    const dishRight = latLonAltToVec3(latDeg + 0.15, lonDeg + 0.15, 16);
    const dishGeom = new THREE.BufferGeometry().setFromPoints([dishLeft, towerTop, dishRight]);
    const dishMat = new THREE.LineBasicMaterial({ color: 0xef4444, linewidth: 1 });
    rxMarker.add(new THREE.Line(dishGeom, dishMat));

    // Tiny dot at base
    const dotGeom = new THREE.SphereGeometry(0.002, 6, 6);
    const dotMat = new THREE.MeshBasicMaterial({ color: 0xef4444 });
    const dot = new THREE.Mesh(dotGeom, dotMat);
    dot.position.copy(pos);
    rxMarker.add(dot);

    scene.add(rxMarker);
}

function createLandingMarker(latDeg, lonDeg) {
    landingMarker = new THREE.Group();

    const pos = latLonAltToVec3(latDeg, lonDeg, 0);

    // Small diamond
    const diamondGeom = new THREE.OctahedronGeometry(0.003, 0);
    const diamondMat = new THREE.MeshBasicMaterial({
        color: 0xf59e0b, transparent: true, opacity: 0.9,
    });
    const diamond = new THREE.Mesh(diamondGeom, diamondMat);
    diamond.position.copy(pos);
    diamond.lookAt(pos.clone().multiplyScalar(2));
    landingMarker.add(diamond);

    scene.add(landingMarker);
}

// Direction arc removed — rays themselves show the path

function onGlobeClickInternal(event) {
    if (!earthMesh || !raycaster || !camera) return;

    const rect = renderer.domElement.getBoundingClientRect();
    mouse.x = ((event.clientX - rect.left) / rect.width) * 2 - 1;
    mouse.y = -((event.clientY - rect.top) / rect.height) * 2 + 1;

    raycaster.setFromCamera(mouse, camera);
    const intersects = raycaster.intersectObject(earthMesh);

    if (intersects.length > 0) {
        const point = intersects[0].point;
        const { lat, lon } = vec3ToLatLon(point);

        if (clickCallback) {
            clickCallback(lat, lon, event);
        }
    }
}

function onResize() {
    if (!container || !renderer) return;
    const w = container.clientWidth;
    const h = container.clientHeight;
    if (w === 0 || h === 0) return;
    camera.aspect = w / h;
    camera.updateProjectionMatrix();
    renderer.setSize(w, h);
}

function animate() {
    animFrameId = requestAnimationFrame(animate);
    controls.update();

    // Slow cloud rotation for realism
    if (cloudMesh) {
        cloudMesh.rotation.y += 0.0001;
    }

    // Pulse TX marker ring
    if (txMarker) {
        txMarker.children.forEach(child => {
            if (child.userData.pulse) {
                const t = (Date.now() % 2000) / 2000;
                child.material.opacity = 0.15 + 0.2 * Math.sin(t * Math.PI * 2);
                const s = 1 + 0.3 * Math.sin(t * Math.PI * 2);
                child.scale.set(s, s, s);
            }
        });
    }

    // Pulse RX marker ring
    if (rxMarker) {
        rxMarker.children.forEach(child => {
            if (child.userData.pulse) {
                const t = (Date.now() % 2000) / 2000;
                child.material.opacity = 0.15 + 0.2 * Math.sin(t * Math.PI * 2);
                const s = 1 + 0.3 * Math.sin(t * Math.PI * 2);
                child.scale.set(s, s, s);
            }
        });
    }

    renderer.render(scene, camera);
}
