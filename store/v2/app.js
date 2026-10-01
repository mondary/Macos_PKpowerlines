(() => {
  'use strict';
  const $ = (id) => document.getElementById(id);
  const clamp = (n, lo = 0, hi = 100) => Math.min(hi, Math.max(lo, n));
  const reduced = matchMedia('(prefers-reduced-motion: reduce)');
  const colors = { battery: '#34c759', low: '#ff3b30', charge: '#007aff', ram: '#ff3b30', cpu: '#ff9500', network: '#5ac8fa' };
  const story = { progress: 0, battery: 87, plugged: false, anchor: 87, anchorProgress: 0, gained: 0, visible: false };
  const lab = { source: 'battery', value: 72, charging: false, position: 'top', thickness: 12, opacity: 100, text: true, visible: false, threshold: 20, force: true, flow: true, palette: { ...colors } };
  const sourceNames = { battery: 'Batterie', ram: 'RAM', cpu: 'CPU', network: 'Réseau' };
  let geometry = {}, dragging = null, frame = 0, previousTime = 0;

  function batteryState(value, plugged) {
    if (plugged && value < 100) return { color: colors.charge, name: 'En charge', prefix: '⚡ ' };
    if (value < 20) return { color: colors.low, name: 'Batterie faible', prefix: '' };
    return { color: colors.battery, name: value >= 100 ? 'Chargée' : 'Sur batterie', prefix: '' };
  }
  function mix(a, b, t) {
    const rgb = (hex) => hex.match(/\w\w/g).map((c) => parseInt(c, 16));
    const x = rgb(a), y = rgb(b);
    return `rgb(${x.map((v, i) => Math.round(v + (y[i] - v) * t)).join(',')})`;
  }
  function renderStory() {
    const elapsed = story.progress - story.anchorProgress;
    story.battery = clamp(story.anchor + (story.plugged ? elapsed * 95 + story.gained : -elapsed * 72));
    const value = Math.round(story.battery);
    const state = batteryState(value, story.plugged);
    const minutes = Math.round(480 + story.progress * 720);
    const time = `${String(Math.floor(minutes / 60)).padStart(2, '0')}:${String(minutes % 60).padStart(2, '0')}`;
    $('story-time').textContent = $('desktop-time').textContent = time;
    $('story-charge').textContent = `${value}%`;
    $('story-charge').style.color = state.color;
    $('story-status').textContent = state.name;
    $('story-fill').style.background = state.color;
    $('story-fill-label').textContent = `${state.prefix}${value}%`;
    $('story-fill-label').style.setProperty('--text-width', `${$('story-fill-label').offsetWidth}px`);
    $('story-bar').setAttribute('aria-label', `Batterie : ${value} %. ${state.name}.`);
    $('story-progress-fill').style.width = `${story.progress * 100}%`;
    $('story-message').textContent = story.plugged
      ? value >= 100 ? '100 %. La charge est terminée : la ligne redevient verte, sans éclair.' : 'Le MagSafe est connecté. La barre devient bleue, l’éclair apparaît et la batterie remonte.'
      : value < 20 ? 'Sous 20 %, la ligne passe au rouge. Le pourcentage reste visible pour attirer votre attention.' : story.progress > .45 ? 'La journée avance et la ligne se raccourcit. Branchez le câble pour lui redonner de l’énergie.' : 'Une ligne verte suit le niveau de charge, à même le bord de l’écran.';
    $('story-hint').textContent = story.plugged ? 'Charge accélérée pour la démonstration' : '↓ Faites défiler pour avancer dans la journée';
    $('story-plug-toggle').innerHTML = `${story.plugged ? 'Débrancher' : 'Brancher'} le MagSafe <span aria-hidden="true">${story.plugged ? '↙' : '↗'}</span>`;
    $('story-plug-toggle').setAttribute('aria-pressed', story.plugged);
    $('cable-plug').setAttribute('aria-pressed', story.plugged);
    $('cable-plug').setAttribute('aria-label', story.plugged ? 'MagSafe connecté : appuyez ou glissez pour débrancher' : 'Connecteur MagSafe : glissez vers le port du Mac ou appuyez pour brancher');
    $('cable-plug').classList.toggle('is-plugged', story.plugged);
    $('port-guide').style.opacity = story.plugged ? '0' : '1';
    const p = story.progress;
    $('sun-halo').style.left = `${6 + p * 88}%`;
    $('sun-halo').style.top = `${54 - Math.sin(p * Math.PI) * 39}%`;
    const dusk = clamp((p - .55) / .45, 0, 1);
    $('story-desktop').style.setProperty('--sky-top', mix('3c83ad', '172b56', dusk));
    $('story-desktop').style.setProperty('--sky-bottom', mix('f0c59c', 'c67e82', dusk));
    $('sun-halo').style.opacity = String(1 - Math.max(0, p - .88) * 4);
    drawFills(0);
  }
  function setPlugged(next) {
    story.anchor = story.battery;
    story.anchorProgress = story.progress;
    story.gained = 0;
    story.plugged = next;
    renderStory();
    positionCable();
    startAnimation();
  }
  function onScroll() {
    const rect = $('experience').getBoundingClientRect();
    story.progress = clamp(-rect.top / Math.max(1, rect.height - $('experience').firstElementChild.offsetHeight), 0, 1);
    renderStory();
  }

  function measureCable() {
    const scene = $('sim-scene').getBoundingClientRect();
    const port = $('mac-port').getBoundingClientRect();
    const scale = innerWidth <= 560 ? .75 : 1;
    geometry = { width: scene.width, height: scene.height, portX: port.left - scene.left + port.width / 2, portY: port.top - scene.top + port.height / 2, scale };
    geometry.restX = Math.max(35, geometry.portX + 55);
    geometry.restY = Math.min(scene.height - 70, geometry.portY + 80);
    positionCable();
  }
  function positionCable(x, y) {
    if (!geometry.width) return;
    const { scale, portX, portY, width, height } = geometry;
    const px = x ?? (story.plugged ? portX - 65 * scale : geometry.restX);
    const py = y ?? (story.plugged ? portY - 17.5 : geometry.restY);
    $('cable-plug').style.left = `${px}px`;
    $('cable-plug').style.top = `${py}px`;
    const endpointY = py + 17.5;
    $('cable-path').setAttribute('d', `M -25 ${height - 40} C ${width * .22} ${height + 10}, ${Math.max(-20, px - 95)} ${endpointY}, ${px + 4} ${endpointY}`);
    $('port-guide').style.left = `${Math.max(8, portX - 28)}px`;
    $('port-guide').style.top = `${portY + 25}px`;
  }
  const plug = $('cable-plug');
  plug.addEventListener('pointerdown', (event) => {
    if (event.button !== 0) return;
    const box = plug.getBoundingClientRect();
    dragging = { id: event.pointerId, startX: event.clientX, startY: event.clientY, offsetX: event.clientX - box.left, offsetY: event.clientY - box.top, moved: false };
    plug.setPointerCapture(event.pointerId);
  });
  plug.addEventListener('pointermove', (event) => {
    if (!dragging || event.pointerId !== dragging.id) return;
    if (Math.hypot(event.clientX - dragging.startX, event.clientY - dragging.startY) > 5) dragging.moved = true;
    if (!dragging.moved) return;
    const box = $('sim-scene').getBoundingClientRect();
    const x = clamp(event.clientX - box.left - dragging.offsetX, -10, geometry.width - 60);
    const y = clamp(event.clientY - box.top - dragging.offsetY, 0, geometry.height - 35);
    dragging.x = x; dragging.y = y;
    positionCable(x, y);
  });
  plug.addEventListener('pointerup', (event) => {
    if (!dragging || event.pointerId !== dragging.id) return;
    if (dragging.moved) {
      const distance = Math.hypot(dragging.x + 65 * geometry.scale - geometry.portX, dragging.y + 17.5 - geometry.portY);
      setPlugged(distance < 65);
    } else setPlugged(!story.plugged);
    dragging = null;
    plug.releasePointerCapture(event.pointerId);
  });
  plug.addEventListener('pointercancel', () => { dragging = null; positionCable(); });
  plug.addEventListener('click', (event) => { if (event.detail === 0) setPlugged(!story.plugged); });
  $('story-plug-toggle').addEventListener('click', () => setPlugged(!story.plugged));
  $('story-replay').addEventListener('click', () => {
    story.anchor = 87; story.anchorProgress = 0; story.gained = 0; story.plugged = false;
    $('experience').scrollIntoView({ behavior: 'instant' });
    onScroll(); positionCable();
  });

  function renderLab() {
    const battery = lab.source === 'battery';
    const state = battery ? batteryState(lab.value, lab.charging) : { color: lab.palette[lab.source], prefix: '', name: 'Simulation' };
    if (battery && !(lab.charging && lab.value < 100)) {
      state.color = lab.value < lab.threshold ? colors.low : lab.palette.battery;
      state.name = lab.value < lab.threshold ? 'Batterie faible' : lab.value >= 100 ? 'Chargée' : 'Sur batterie';
    }
    const network = lab.source === 'network';
    const label = network ? `↓ ${(lab.value * .08).toFixed(1)}  ↑ ${(lab.value * .02).toFixed(1)} MB/s` : `${state.prefix}${lab.value}%`;
    const forceText = battery && lab.value < lab.threshold && lab.force;
    const thickness = forceText ? Math.max(12, lab.thickness) : lab.thickness;
    $('lab-bar').className = `lab-bar position-${lab.position}`;
    $('lab-bar').style.setProperty('--thickness', `${thickness}px`);
    $('lab-fill').style.background = $('lab-zoom-fill').style.background = state.color;
    $('lab-fill').style.opacity = lab.opacity / 100;
    $('lab-label').textContent = $('lab-zoom-text').textContent = label;
    $('lab-label').style.display = forceText || (lab.text && thickness >= 8) ? '' : 'none';
    $('lab-label').style.fontSize = `${Math.min(22, Math.max(6, thickness * .75))}px`;
    for (const id of ['lab-label', 'lab-zoom-text']) {
      $(id).style.setProperty('--text-width', `${$(id).offsetWidth}px`);
      $(id).style.setProperty('--text-height', `${$(id).offsetHeight}px`);
    }
    $('lab-bar').setAttribute('aria-label', `${sourceNames[lab.source]} : ${label}. ${state.name}.`);
    $('lab-state-name').textContent = `${sourceNames[lab.source]} · ${battery ? state.name : 'APERÇU'}`.toUpperCase();
    $('value-label').textContent = { battery: 'Niveau de batterie', ram: 'Mémoire utilisée', cpu: 'Charge processeur', network: 'Utilisation du plafond réseau' }[lab.source];
    $('value-output').textContent = `${lab.value} %`;
    $('thickness-output').textContent = `${lab.thickness} px`;
    $('opacity-output').textContent = `${lab.opacity} %`;
    $('charge-control').hidden = !battery;
    $('lab-color').value = lab.palette[lab.source];
    $('threshold-output').textContent = `${lab.threshold} %`;
    $('lab-description').textContent = forceText ? `${lab.value} % · alerte : texte forcé, épaisseur ≥ 12 px` : network ? `${(lab.value / 10).toFixed(1)} MB/s · plafond de 10 MB/s` : `${lab.value} % · ${battery ? state.name.toLowerCase() : sourceNames[lab.source]}`;
    drawFills(0);
  }
  $('source-options').addEventListener('click', (event) => {
    const button = event.target.closest('[data-source]');
    if (!button) return;
    lab.source = button.dataset.source;
    for (const item of $('source-options').children) item.setAttribute('aria-pressed', item === button);
    renderLab();
  });
  $('lab-presets').addEventListener('click', (event) => {
    const button = event.target.closest('[data-preset]');
    if (!button) return;
    const preset = button.dataset.preset;
    lab.source = 'battery';
    lab.value = preset === 'low' ? 12 : preset === 'full' ? 100 : 72;
    lab.charging = preset === 'charging' || preset === 'full';
    $('lab-value').value = lab.value;
    $('lab-charging').classList.toggle('is-on', lab.charging);
    $('lab-charging').setAttribute('aria-checked', lab.charging);
    for (const item of $('source-options').children) item.setAttribute('aria-pressed', item.dataset.source === 'battery');
    renderLab();
  });
  $('lab-color').addEventListener('input', (event) => { lab.palette[lab.source] = event.target.value; renderLab(); });
  $('lab-threshold').addEventListener('input', (event) => { lab.threshold = Number(event.target.value); renderLab(); });
  $('lab-flow').addEventListener('change', (event) => { lab.flow = event.target.checked; drawFills(0); });
  $('lab-force').addEventListener('change', (event) => { lab.force = event.target.checked; renderLab(); });
  $('lab-font').addEventListener('change', (event) => {
    const fonts = { 'system-bold': '-apple-system, sans-serif', system: '-apple-system, sans-serif', helvetica: '"Helvetica Neue", sans-serif', menlo: 'Menlo, monospace', sfmono: '"SFMono-Regular", monospace', monaco: 'Monaco, monospace', courier: 'Courier, monospace' };
    for (const id of ['lab-label', 'lab-zoom-text']) {
      $(id).style.fontFamily = fonts[event.target.value];
      $(id).style.fontWeight = event.target.value === 'system-bold' ? '800' : '400';
    }
    renderLab();
  });
  $('position-options').addEventListener('click', (event) => {
    const button = event.target.closest('[data-position]');
    if (!button) return;
    lab.position = button.dataset.position;
    for (const item of $('position-options').children) item.setAttribute('aria-pressed', item === button);
    renderLab();
  });
  for (const [id, key] of [['lab-value', 'value'], ['lab-thickness', 'thickness'], ['lab-opacity', 'opacity']]) {
    $(id).addEventListener('input', (event) => { lab[key] = Number(event.target.value); renderLab(); });
  }
  for (const [id, key] of [['lab-charging', 'charging'], ['lab-show-text', 'text']]) {
    $(id).addEventListener('click', () => {
      lab[key] = !lab[key];
      $(id).classList.toggle('is-on', lab[key]);
      $(id).setAttribute('aria-checked', lab[key]);
      renderLab();
    });
  }
  function drawFills(wave) {
    $('story-fill').style.width = `${clamp(story.battery + wave * (story.plugged ? 1.1 : .6))}%`;
    const vertical = lab.position === 'left' || lab.position === 'right';
    const value = clamp(lab.value + (lab.flow ? wave * .55 : 0));
    $('lab-fill').style.width = vertical ? '100%' : `${value}%`;
    $('lab-fill').style.height = vertical ? `${value}%` : '100%';
    $('lab-zoom-fill').style.width = `${lab.value}%`;
  }
  function tick(time) {
    frame = 0;
    const delta = previousTime ? Math.min((time - previousTime) / 1000, .1) : 0;
    previousTime = time;
    if (story.visible && story.plugged && story.battery < 100) {
      story.gained += delta * 5;
      renderStory();
    }
    if (!reduced.matches) drawFills(Math.sin(time / (story.plugged ? 160 : 260)));
    if (!document.hidden && (story.visible || lab.visible) && (!reduced.matches || (story.plugged && story.battery < 100))) frame = requestAnimationFrame(tick);
  }
  function startAnimation() {
    if (!frame && !document.hidden) { previousTime = 0; frame = requestAnimationFrame(tick); }
  }
  const observer = new IntersectionObserver((entries) => {
    for (const entry of entries) {
      if (entry.target.id === 'experience') story.visible = entry.isIntersecting;
      else lab.visible = entry.isIntersecting;
    }
    startAnimation();
  });
  observer.observe($('experience'));
  observer.observe($('playground'));
  window.addEventListener('scroll', onScroll, { passive: true });
  window.addEventListener('resize', () => { measureCable(); onScroll(); renderLab(); });
  document.addEventListener('visibilitychange', startAnimation);
  reduced.addEventListener('change', () => { drawFills(0); startAnimation(); });
  onScroll();
  renderLab();
  measureCable();
})();
