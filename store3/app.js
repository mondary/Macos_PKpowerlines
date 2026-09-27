(() => {
  'use strict';
  const $ = id => document.getElementById(id);
  const clamp = (n, a = 0, b = 100) => Math.max(a, Math.min(b, n));
  const reduce = matchMedia('(prefers-reduced-motion: reduce)');
  const defaults = { battery: '#34c759', ram: '#ff3b30', cpu: '#ff9500', network: '#5ac8fa' };
  const names = { battery: 'Batterie', ram: 'Mémoire RAM', cpu: 'Processeur', network: 'Réseau' };
  const state = { source: 'battery', values: { battery: 86, ram: 48, cpu: 31, network: 62 }, palette: { ...defaults }, phase: 0, scroll: 0, anchorPhase: 0, anchorBattery: 86, gained: 0, plugged: false, edge: 'top', thickness: 12, opacity: 100, text: true, force: true, threshold: 20, flow: true, petals: !reduce.matches, worldVisible: true, labVisible: false };
  const scene = $('world-stage');
  const particleCanvas = $('petals'), particleContext = particleCanvas.getContext('2d');
  const cableCanvas = $('cable-canvas'), cableContext = cableCanvas.getContext('2d');
  let frame = 0, lastFrame = 0, lastPaint = 0, geometry = null, drag = null, scrollQueued = false;
  let seed = 203;
  const random = () => { seed = (seed * 1664525 + 1013904223) >>> 0; return seed / 4294967296; };
  const particles = Array.from({ length: 40 }, () => ({ x: random(), y: random(), speed: .5 + random(), sway: random() * 6, size: random() > .8 ? 2 : 1 }));
  const stars = Array.from({ length: 55 }, () => ({ x: random(), y: random() * .5, phase: random() * 7 }));

  function status() {
    const value = Math.round(state.values[state.source]);
    let color = state.palette[state.source], name = names[state.source], prefix = '';
    if (state.source === 'battery') {
      if (state.plugged && value < 100) { color = '#007aff'; name = 'En charge'; prefix = '⚡ '; }
      else if (value < state.threshold) { color = '#ff3b30'; name = 'Batterie faible'; }
      else name = value >= 100 ? 'Chargée' : 'Sur batterie';
    }
    const label = state.source === 'network' ? `↓ ${(value * .08).toFixed(1)} ↑ ${(value * .02).toFixed(1)} MB/s` : `${prefix}${value}%`;
    return { value, color, name, prefix, label };
  }
  function render() {
    const s = status();
    document.documentElement.style.setProperty('--level', `${s.value}%`);
    document.documentElement.style.setProperty('--signal', s.color);
    $('world-label').textContent = $('preview-label').textContent = $('zoom-label').textContent = s.label;
    $('world-powerline').setAttribute('aria-label', `${names[state.source]} : ${s.label}, ${s.name}`);
    $('preview-bar').setAttribute('aria-label', `${names[state.source]} : ${s.label}, ${s.name}`);
    $('screen-source').textContent = names[state.source].toUpperCase();
    $('screen-number').textContent = state.source === 'network' ? `${(s.value / 10).toFixed(1)} MB/s` : `${s.value}%`;
    $('screen-number').style.fontSize = state.source === 'network' ? 'clamp(13px, 1.7vw, 27px)' : '';
    $('screen-status').textContent = state.source === 'battery' ? ({ 'Sur batterie': 'Sur batterie. Tout va bien.', 'Batterie faible': 'Il est temps de brancher.', 'En charge': 'Un peu d’énergie en plus.', 'Chargée': '100 %. Prêt pour la suite.' }[s.name]) : ({ ram: 'Mémoire active + câblée.', cpu: 'Charge globale du processeur.', network: 'Débit descendant + montant.' }[state.source]);
    $('floating-status').textContent = `${s.name} · ${state.source === 'network' ? s.label : s.value + ' %'}`;
    $('preview-state').textContent = s.name.toUpperCase();
    $('preview-value').textContent = s.label;
    $('level-title').textContent = { battery: 'Niveau de batterie', ram: 'Mémoire utilisée', cpu: 'Charge processeur', network: 'Part du plafond réseau' }[state.source];
    $('level-output').textContent = `${s.value} %`;
    $('level').value = s.value;
    $('charge-row').hidden = state.source !== 'battery';
    $('charge-toggle').setAttribute('aria-checked', state.plugged);
    $('pixel-plug').setAttribute('aria-pressed', state.plugged);
    $('pixel-plug').classList.toggle('connected', state.plugged);
    $('pixel-plug').setAttribute('aria-label', state.plugged ? 'MagSafe connecté : cliquer ou glisser pour débrancher' : 'Câble MagSafe : glisser vers le port ou cliquer pour brancher');
    $('connect-button').innerHTML = `${state.plugged ? 'Débrancher' : 'Brancher'} le MagSafe <span>↗</span>`;
    $('cable-instruction').innerHTML = state.plugged ? 'connecté. <span>⚡</span>' : 'attrapez le câble <span>↗</span>';
    $('source-color').value = state.palette[state.source];
    for (const button of document.querySelectorAll('[data-source]')) button.setAttribute('aria-pressed', button.dataset.source === state.source);
    for (const button of document.querySelectorAll('[data-edge]')) button.setAttribute('aria-pressed', button.dataset.edge === state.edge);
    const force = state.source === 'battery' && s.value < state.threshold && state.force;
    const thickness = force ? Math.max(12, state.thickness) : state.thickness;
    const bar = $('preview-bar');
    bar.className = `preview-bar ${state.edge}`;
    $('preview-screen').style.setProperty('--thickness', `${thickness}px`);
    $('preview-fill').style.opacity = state.opacity / 100;
    $('preview-label').style.display = force || (state.text && thickness >= 8) ? '' : 'none';
    $('preview-label').style.fontSize = `${Math.max(6, Math.min(22, thickness * .75))}px`;
    bar.style.setProperty('--text-width', `${$('preview-label').offsetWidth}px`);
    bar.style.setProperty('--text-height', `${$('preview-label').offsetHeight}px`);
    $('zoom-track').style.setProperty('--text-width', `${$('zoom-label').offsetWidth}px`);
    $('world-label').style.left = `max(4px, calc(var(--level) - ${$('world-label').offsetWidth + 5}px))`;
    $('thickness-output').textContent = `${state.thickness} px`;
    $('opacity-output').textContent = `${state.opacity} %`;
    $('workshop-tip').textContent = force ? 'ALERTE FAIBLE : TEXTE FORCÉ, ÉPAISSEUR ≥ 12 PX.' : state.thickness < 8 ? 'SOUS 8 PX, LE TEXTE SE FAIT DISCRET.' : state.source === 'network' ? 'PLAFOND SIMULÉ : 10 MB/S.' : 'PRÊT À JOUER.';
    const b = Math.round(state.values.battery);
    $('day-title').innerHTML = state.plugged ? b >= 100 ? 'La ligne est pleine.<br>La journée peut continuer.' : 'Un clic magnétique.<br>Et l’énergie revient.' : b < state.threshold ? 'Un peu de rouge.<br>Il est temps de brancher.' : 'La journée s’étire.<br>La ligne se raccourcit.';
    $('day-description').textContent = state.plugged ? b >= 100 ? 'À 100 %, la charge s’arrête. La barre redevient verte, sans éclair.' : 'La powerline passe au bleu et affiche ⚡. La charge est accélérée pour vous laisser voir la batterie remonter.' : b < state.threshold ? 'L’alerte faible rend le pourcentage visible. Glissez le connecteur vers le port du Mac, ou utilisez le bouton.' : 'Faites défiler pour avancer dans le temps. Le niveau de batterie suit le rythme de votre journée.';
  }
  function setPhase(phase) {
    state.phase = phase;
    state.values.battery = clamp(state.anchorBattery + (phase - state.anchorPhase) * (state.plugged ? 115 : -72) + state.gained);
    const mins = Math.round(480 + phase * 720);
    const time = `${String(Math.floor(mins / 60)).padStart(2, '0')}:${String(mins % 60).padStart(2, '0')}`;
    $('day-clock').textContent = $('mac-clock').textContent = time;
    const night = clamp((phase - .72) / .28, 0, 1);
    scene.style.setProperty('--night', night * .43);
    scene.style.setProperty('--scene-filter', `brightness(${1 - night * .48}) saturate(${1 - night * .2})`);
    $('pixel-sun').style.left = `${42 + phase * 14}%`;
    $('pixel-sun').style.top = `${35 - Math.sin(phase * Math.PI) * 12}%`;
    $('pixel-sun').style.opacity = String(.8 * (1 - night));
    const moments = [0, .35, .72, 1];
    const nearest = moments.reduce((a, b) => Math.abs(a - phase) < Math.abs(b - phase) ? a : b);
    for (const button of $('time-switch').children) button.setAttribute('aria-pressed', Number(button.dataset.time) === nearest);
    render();
  }
  function anchorBattery(value = state.values.battery) { state.anchorBattery = value; state.anchorPhase = state.phase; state.gained = 0; state.values.battery = value; }
  function connect(next) {
    anchorBattery(); state.plugged = next; state.source = 'battery'; render(); placeCable(); startLoop();
  }
  function chooseSource(source) { state.source = source; render(); }
  function updateScroll() {
    scrollQueued = false;
    const rect = $('jardin').getBoundingClientRect();
    state.scroll = clamp(-rect.top / Math.max(1, rect.height - scene.offsetHeight), 0, 1);
    const isStory = state.scroll > .12;
    scene.classList.toggle('in-story', isStory);
    $('intro-copy').inert = isStory;
    $('day-copy').inert = !isStory;
    setPhase(state.scroll);
  }
  window.addEventListener('scroll', () => { if (!scrollQueued) { scrollQueued = true; requestAnimationFrame(updateScroll); } }, { passive: true });
  $('time-switch').addEventListener('click', event => { const b = event.target.closest('[data-time]'); if (b) setPhase(Number(b.dataset.time)); });
  $('replay-button').addEventListener('click', () => {
    state.anchorBattery = 86; state.anchorPhase = 0; state.gained = 0; state.plugged = false; state.source = 'battery';
    $('jardin').scrollIntoView({ behavior: 'instant' }); updateScroll(); placeCable();
  });
  $('connect-button').addEventListener('click', () => connect(!state.plugged));
  $('charge-toggle').addEventListener('click', () => connect(!state.plugged));
  for (const id of ['source-tabs', 'screen-sources']) $(id).addEventListener('click', event => { const b = event.target.closest('[data-source]'); if (b) chooseSource(b.dataset.source); });
  for (const button of document.querySelectorAll('[data-pick]')) button.addEventListener('click', () => { chooseSource(button.dataset.pick); $('atelier').scrollIntoView({ behavior: reduce.matches ? 'instant' : 'smooth' }); });
  $('position-tabs').addEventListener('click', event => { const b = event.target.closest('[data-edge]'); if (b) { state.edge = b.dataset.edge; render(); } });
  $('level').addEventListener('input', event => { const value = Number(event.target.value); state.values[state.source] = value; if (state.source === 'battery') anchorBattery(value); render(); });
  for (const id of ['thickness', 'opacity']) $(id).addEventListener('input', event => { state[id] = Number(event.target.value); render(); });
  for (const [id, key] of [['show-text', 'text'], ['flow', 'flow'], ['force-text', 'force']]) $(id).addEventListener('change', event => { state[key] = event.target.checked; render(); startLoop(); });
  $('threshold').addEventListener('change', event => { state.threshold = Number(event.target.value); render(); });
  $('source-color').addEventListener('input', event => { state.palette[state.source] = event.target.value; render(); });
  $('scenarios').addEventListener('click', event => {
    const b = event.target.closest('[data-scenario]'); if (!b) return;
    const p = b.dataset.scenario;
    state.source = 'battery'; state.plugged = p === 'charge' || p === 'full';
    anchorBattery(p === 'low' ? 12 : p === 'full' ? 100 : 76);
    render(); placeCable(); startLoop();
  });
  $('reset-settings').addEventListener('click', () => {
    Object.assign(state, { source: 'battery', palette: { ...defaults }, plugged: false, edge: 'top', thickness: 12, opacity: 100, text: true, force: true, threshold: 20, flow: true });
    anchorBattery(86);
    $('thickness').value = 12; $('opacity').value = 100; $('threshold').value = 20;
    for (const id of ['show-text', 'flow', 'force-text']) $(id).checked = true;
    render(); placeCable();
  });
  $('motion-toggle').addEventListener('click', () => {
    state.petals = !state.petals;
    $('motion-toggle').setAttribute('aria-pressed', state.petals);
    $('motion-toggle').textContent = `✦ Pétales : ${state.petals ? 'oui' : 'non'}`;
    if (!state.petals) particleContext.clearRect(0, 0, particleCanvas.width, particleCanvas.height);
    startLoop();
  });

  function measure() {
    const box = scene.getBoundingClientRect(), port = $('magsafe-port').getBoundingClientRect();
    const scale = innerWidth <= 500 ? .8 : 1;
    geometry = { width: box.width, height: box.height, portX: port.left - box.left + port.width / 2, portY: port.top - box.top + port.height / 2, scale };
    geometry.restX = innerWidth <= 800 ? geometry.portX + 70 : geometry.portX - 85;
    geometry.restY = Math.min(box.height - 115, geometry.portY + 70);
    for (const canvas of [particleCanvas, cableCanvas]) { canvas.width = Math.ceil(box.width / 4); canvas.height = Math.ceil(box.height / 4); }
    placeCable(); render();
  }
  function drawCord(x, y) {
    const ctx = cableContext, w = cableCanvas.width, h = cableCanvas.height;
    ctx.clearRect(0, 0, w, h);
    const endX = (x + 4) / 4, endY = (y + 15) / 4;
    const startX = w * .85, startY = h + 4;
    function curve(t) {
      const u = 1 - t;
      return { x: u*u*u*startX + 3*u*u*t*w*.72 + 3*u*t*t*(endX - 25) + t*t*t*endX, y: u*u*u*startY + 3*u*u*t*(h - 19) + 3*u*t*t*(endY + 40) + t*t*t*endY };
    }
    for (let layer = 0; layer < 2; layer++) {
      ctx.fillStyle = layer ? '#dfcdb0' : '#626356';
      for (let i = 0; i <= 250; i++) { const p = curve(i / 250); ctx.fillRect(Math.round(p.x), Math.round(p.y) + (layer ? 0 : 1), 2, 2); }
    }
  }
  function placeCable(x, y) {
    if (!geometry) return;
    const px = x ?? (state.plugged ? geometry.portX - 50 * geometry.scale : geometry.restX);
    const py = y ?? (state.plugged ? geometry.portY - 15 : geometry.restY);
    $('pixel-plug').style.left = `${px}px`; $('pixel-plug').style.top = `${py}px`;
    $('cable-instruction').style.left = `${clamp(px - 8, 10, geometry.width - 140)}px`;
    $('cable-instruction').style.top = `${py + 34}px`;
    drawCord(px, py);
  }
  const plug = $('pixel-plug');
  plug.addEventListener('pointerdown', event => {
    if (event.button !== 0) return;
    const box = plug.getBoundingClientRect();
    event.preventDefault();
    drag = { id: event.pointerId, startX: event.clientX, startY: event.clientY, dx: event.clientX - box.left, dy: event.clientY - box.top, moved: false, startedConnected: state.plugged };
    plug.setPointerCapture(event.pointerId);
  });
  plug.addEventListener('pointermove', event => {
    if (!drag || drag.id !== event.pointerId) return;
    if (Math.hypot(event.clientX - drag.startX, event.clientY - drag.startY) > 5) drag.moved = true;
    if (!drag.moved) return;
    const box = scene.getBoundingClientRect();
    drag.x = clamp(event.clientX - box.left - drag.dx, 0, geometry.width - 55);
    drag.y = clamp(event.clientY - box.top - drag.dy, 70, geometry.height - 60);
    placeCable(drag.x, drag.y);
    const distance = Math.hypot(drag.x + 50 * geometry.scale - geometry.portX, drag.y + 15 - geometry.portY);
    if (!drag.startedConnected && distance < 36) {
      const pointerId = drag.id;
      drag = null;
      connect(true);
      if (plug.hasPointerCapture(pointerId)) plug.releasePointerCapture(pointerId);
    }
  });
  window.addEventListener('pointerup', event => {
    if (!drag || drag.id !== event.pointerId) return;
    if (drag.moved) connect(Math.hypot(drag.x + 50 * geometry.scale - geometry.portX, drag.y + 15 - geometry.portY) < 60);
    else connect(!state.plugged);
    drag = null;
    if (plug.hasPointerCapture(event.pointerId)) plug.releasePointerCapture(event.pointerId);
  });
  plug.addEventListener('pointercancel', () => { drag = null; placeCable(); });
  plug.addEventListener('click', event => { if (event.detail === 0) connect(!state.plugged); });

  function paintParticles(time) {
    const ctx = particleContext, w = particleCanvas.width, h = particleCanvas.height;
    ctx.clearRect(0, 0, w, h);
    const t = time / 1000;
    if (state.phase > .8) {
      ctx.fillStyle = '#fff1c1';
      for (const p of stars) { ctx.globalAlpha = (.35 + Math.sin(t + p.phase) * .2) * ((state.phase - .8) / .2); ctx.fillRect(Math.round(p.x*w), Math.round(p.y*h), 1, 1); }
      ctx.globalAlpha = 1;
    }
    for (const p of particles) {
      const x = ((p.x*w - t*p.speed*4 + Math.sin(t*.6+p.sway)*5) % w + w) % w;
      const y = (p.y*h + t*p.speed*3) % h;
      ctx.fillStyle = p.size === 2 ? '#f6c3ac' : '#dd9da6';
      ctx.globalAlpha = .8;
      ctx.fillRect(Math.round(x), Math.round(y), p.size, 1);
      if (p.size === 2) ctx.fillRect(Math.round(x) + 1, Math.round(y) + 1, 1, 1);
    }
    ctx.globalAlpha = 1;
  }
  function tick(time) {
    frame = 0;
    const delta = lastFrame ? Math.min((time - lastFrame) / 1000, .1) : 0; lastFrame = time;
    if (state.worldVisible && state.plugged && state.values.battery < 100) { state.gained += delta * 5; setPhase(state.phase); }
    if (time - lastPaint > 42) {
      lastPaint = time;
      if (state.worldVisible && state.petals && !reduce.matches) paintParticles(time);
      if (state.flow && !reduce.matches) {
        const v = state.values[state.source];
        document.documentElement.style.setProperty('--level', `${clamp(v + Math.sin(time / (state.plugged ? 170 : 280)) * .6)}%`);
      }
    }
    if (!document.hidden && (state.worldVisible || state.labVisible) && ((!reduce.matches && (state.flow || state.petals)) || (state.worldVisible && state.plugged && state.values.battery < 100))) frame = requestAnimationFrame(tick);
  }
  function startLoop() { if (!frame && !document.hidden) { lastFrame = 0; frame = requestAnimationFrame(tick); } }
  const observer = new IntersectionObserver(entries => {
    for (const e of entries) { if (e.target.id === 'jardin') state.worldVisible = e.isIntersecting; else state.labVisible = e.isIntersecting; }
    startLoop();
  });
  observer.observe($('jardin')); observer.observe($('atelier'));
  window.addEventListener('resize', measure);
  document.addEventListener('visibilitychange', startLoop);
  reduce.addEventListener('change', () => { if (reduce.matches) particleContext.clearRect(0, 0, particleCanvas.width, particleCanvas.height); render(); startLoop(); });
  $('motion-toggle').setAttribute('aria-pressed', state.petals);
  $('motion-toggle').textContent = `✦ Pétales : ${state.petals ? 'oui' : 'non'}`;
  updateScroll(); measure();
  document.fonts.ready.then(() => { render(); measure(); });
})();
