(() => {
  'use strict';
  const $ = id => document.getElementById(id);
  const clamp = (n, a = 0, b = 100) => Math.max(a, Math.min(b, n));
  const reduce = matchMedia('(prefers-reduced-motion: reduce)');
  const defaults = { battery: '#34c759', ram: '#ff3b30', cpu: '#ff9500', network: '#5ac8fa' };

  // ---------- i18n ----------
  const I18N = {
    fr: {
      skip: 'Aller au terrain de jeu',
      nav_playground: 'Terrain de jeu', nav_app: "L'application", nav_source: 'Code source ↗', nav_install: 'Installer sur Mac ↗',
      kofi_button: 'Offrir un café',
      intro_label: 'UN PETIT UTILITAIRE. UN AUTRE REGARD.',
      intro_title: 'Votre Mac.<br>Une ligne pour<br>tout savoir.',
      intro_description: 'Batterie, mémoire, processeur, réseau.<br>Une ligne de couleur au bord de l\u2019écran.<br>Et vous gardez l\u2019esprit ailleurs.',
      intro_cta_install: 'Installer gratuitement <span>↗</span>', intro_cta_try: 'Essayer ici <span>↓</span>',
      intro_compat: 'macOS 13+ · Apple Silicon & Intel · Open source',
      day_label: 'UNE JOURNÉE DANS LE JARDIN', day_replay: '↺ Revenir au matin',
      floating_line: 'Une ligne. Tous vos écrans.', desktop_folder: 'Projets', screen_preview: 'APERÇU INTERACTIF',
      time_dawn: 'Aube', time_noon: 'Midi', time_evening: 'Soir', time_night: 'Nuit',
      scroll_cue: 'FAITES DÉFILER, LE TEMPS PASSE <span>↓</span>',
      app_label: "L'INFORMATION, SANS L'INTERRUPTION.",
      app_title: 'Un petit signal.<br>Une place naturelle.',
      app_p1: 'PKpowerlines transforme le bord de votre écran en indicateur vivant. Sa longueur donne la mesure ; sa couleur raconte l\u2019état de votre Mac.',
      app_p2: 'Elle reste visible sur chaque écran et dans tous les Spaces. Vos clics la traversent. Vous continuez simplement ce que vous étiez en train de faire.',
      app_tags: 'NATIVE SWIFT · LOCALE · SANS COMPTE',
      signal_battery: 'Batterie', signal_battery_copy: 'Le niveau, la charge et le moment de brancher.',
      signal_ram: 'Mémoire', signal_ram_copy: 'La RAM active et câblée, en un coup d\u2019œil.',
      signal_cpu: 'Processeur', signal_cpu_copy: 'La charge globale de votre CPU.',
      signal_network: 'Réseau', signal_network_copy: 'Les débits descendant et montant, en direct.',
      workshop_label: 'SAUVEGARDEZ VOTRE STYLE.', workshop_title: 'Le terrain de jeu.',
      workshop_intro: 'Choisissez une source. Faites varier le niveau.<br>Déplacez la ligne. Trouvez votre équilibre.',
      workshop_window: 'PKPOWERLINES — SIMULATEUR', zoom_label: 'LA LIGNE, VUE DE PRÈS',
      scenario_normal: 'Normale', scenario_low: 'Batterie faible', scenario_charge: 'Charge',
      legend_source: '01 / SOURCE', legend_position: '02 / POSITION',
      source_battery: 'Batterie', source_ram: 'RAM', source_cpu: 'CPU', source_network: 'Réseau',
      magsafe_connected: 'MagSafe connecté',
      pos_top: '↑ Haut', pos_bottom: '↓ Bas', pos_left: '← Gauche', pos_right: '→ Droite',
      label_thickness: 'Épaisseur', label_opacity: 'Opacité',
      label_show_text: 'Afficher le texte', label_flow: 'Flux animé',
      advanced_summary: 'Plus de réglages <span>+</span>', label_source_color: 'Couleur de la source',
      label_threshold: 'Seuil batterie faible', label_force_text: 'Forcer le texte en batterie faible',
      reset: '↺ Réinitialiser',
      demo_note: 'Une simulation pour explorer. Les valeurs ne proviennent pas de votre ordinateur. La charge est accélérée dans le jardin.',
      details_label: 'PETITE LIGNE, GRAND CHOIX.', details_title: 'Discrète.<br>Jusqu\u2019au<br>dernier pixel.',
      f1_tag: 'SUR TOUS VOS ÉCRANS', f1_title: 'Le bon bord, partout.', f1_text: 'Haut, bas, gauche ou droite. Une barre par écran, présente dans tous les Spaces. Les clics passent à travers et l\u2019app reste dans la barre des menus, sans icône dans le Dock.',
      f2_tag: 'À VOTRE MESURE', f2_title: 'De 4 à 40 pixels.', f2_text: 'Épaisseur, couleurs, opacité de 20 à 100 %, sept polices et décalage de −40 à +400 px. Quatre presets d\u2019épaisseur sont accessibles au clavier.',
      f3_tag: 'LE BON SIGNAL', f3_title: 'Elle sait se faire remarquer.', f3_text: 'Bleu et ⚡ pendant la charge active. Rouge sous votre seuil faible, réglable de 5 à 50 %. L\u2019alerte peut forcer le pourcentage et épaissir la barre à 12 px.',
      f4_tag: 'LE BON RYTHME', f4_title: 'Vivante, à votre rythme.', f4_text: 'Actualisation de 1 à 10 secondes, flux animé désactivable et plafond réseau de 1 à 1 000 MB/s. À moins de 8 px, le texte se masque automatiquement hors alerte.',
      app_settings_summary: 'Et dans les réglages de l\u2019app ? <span>+</span>',
      app_settings_text: 'Une fenêtre SwiftUI avec recherche, le réglage de l\u2019espacement de la barre des menus, la Bibliothèque de projets, une page Crédits et Soutenir sur Ko-fi. À propos garde le panneau des mises à jour Stable/Dev fixé en bas. ⌘, ouvre les réglages, ⌘R repositionne la ligne. ⌘4, ⌘1, ⌘2 et ⌘3 appliquent les presets 4, 8, 12 et 20 px.',
      download_label: 'VOTRE PROCHAINE PETITE HABITUDE.', download_title: 'Une ligne dans votre Mac.<br>Un peu de calme en plus.',
      download_cta: 'Télécharger PKpowerlines <span>↗</span>',
      download_footnote: 'Gratuit et open source · macOS 13+ · Intel & Apple Silicon',
      footer_note: 'Fait pour votre Mac. Tout reste sur votre Mac.', footer_github: 'GitHub ↗', footer_kofi: 'Offrir un café ↗',
      copy: 'Copier', copied: 'Copié !',
      release_badge: 'Dernière version : {0}',
      name_battery: 'Batterie', name_ram: 'Mémoire RAM', name_cpu: 'Processeur', name_network: 'Réseau',
      st_charging: 'En charge', st_low: 'Batterie faible', st_charged: 'Chargée', st_battery: 'Sur batterie',
      ph_battery_ok: 'Sur batterie. Tout va bien.', ph_low: 'Il est temps de brancher.', ph_charging: 'Un peu d\u2019énergie en plus.', ph_full: '100 %. Prêt pour la suite.',
      ph_ram: 'Mémoire active + câblée.', ph_cpu: 'Charge globale du processeur.', ph_network: 'Débit descendant + montant.',
      level_battery: 'Niveau de batterie', level_ram: 'Mémoire utilisée', level_cpu: 'Charge processeur', level_network: 'Part du plafond réseau',
      plug_aria_drag: 'Câble MagSafe : glisser vers le port ou cliquer pour brancher', plug_aria_connected: 'MagSafe connecté : cliquer ou glisser pour débrancher',
      connect: 'Brancher le MagSafe', disconnect: 'Débrancher le MagSafe',
      cable_grab_html: 'attrapez le câble <span>↗</span>', cable_connected_html: 'connecté. <span>⚡</span>',
      tip_ready: 'PRÊT À JOUER.', tip_discreet: 'SOUS 8 PX, LE TEXTE SE FAIT DISCRET.', tip_alert: 'ALERTE FAIBLE : TEXTE FORCÉ, ÉPAISSEUR ≥ 12 PX.', tip_network: 'PLAFOND SIMULÉ : 10 MB/S.',
      day_stretch_title: 'La journée s\u2019étire.<br>La ligne se raccourcit.', day_stretch_desc: 'Faites défiler pour avancer dans le temps. Le niveau de batterie suit le rythme de votre journée.',
      day_low_title: 'Un peu de rouge.<br>Il est temps de brancher.', day_low_desc: 'L\u2019alerte faible rend le pourcentage visible. Glissez le connecteur vers le port du Mac, ou utilisez le bouton.',
      day_charge_title: 'Un clic magnétique.<br>Et l\u2019énergie revient.', day_charge_desc: 'La powerline passe au bleu et affiche ⚡. La charge est accélérée pour vous laisser voir la batterie remonter.',
      day_full_title: 'La ligne est pleine.<br>La journée peut continuer.', day_full_desc: 'À 100 %, la charge s\u2019arrête. La barre redevient verte, sans éclair.',
      petals_on: '✦ Pétales : oui', petals_off: '✦ Pétales : non',
      motion_aria: 'Activer ou désactiver les pétales animés'
    },
    en: {
      skip: 'Go to the playground',
      nav_playground: 'Playground', nav_app: 'The app', nav_source: 'Source code ↗', nav_install: 'Install on Mac ↗',
      kofi_button: 'Buy me a coffee',
      intro_label: 'A SMALL UTILITY. ANOTHER WAY OF SEEING.',
      intro_title: 'Your Mac.<br>One line to<br>know it all.',
      intro_description: 'Battery, memory, processor, network.<br>A colored line at the edge of your screen.<br>And your mind stays elsewhere.',
      intro_cta_install: 'Install for free <span>↗</span>', intro_cta_try: 'Try it here <span>↓</span>',
      intro_compat: 'macOS 13+ · Apple Silicon & Intel · Open source',
      day_label: 'A DAY IN THE GARDEN', day_replay: '↺ Back to morning',
      floating_line: 'One line. Every screen.', desktop_folder: 'Projects', screen_preview: 'INTERACTIVE PREVIEW',
      time_dawn: 'Dawn', time_noon: 'Noon', time_evening: 'Evening', time_night: 'Night',
      scroll_cue: 'SCROLL ON, TIME FLOWS <span>↓</span>',
      app_label: 'INFORMATION, WITHOUT INTERRUPTION.',
      app_title: 'A small signal.<br>A natural place.',
      app_p1: 'PKpowerlines turns the edge of your screen into a living gauge. Its length gives the measure; its color tells the story of your Mac.',
      app_p2: 'It stays visible on every screen and in every Space. Your clicks pass right through. You simply keep doing what you were doing.',
      app_tags: 'NATIVE SWIFT · LOCAL · NO ACCOUNT',
      signal_battery: 'Battery', signal_battery_copy: 'Level, charging and the right moment to plug in.',
      signal_ram: 'Memory', signal_ram_copy: 'Active and wired RAM, at a glance.',
      signal_cpu: 'Processor', signal_cpu_copy: 'Your CPU\u2019s overall load.',
      signal_network: 'Network', signal_network_copy: 'Download and upload speeds, live.',
      workshop_label: 'SAVE YOUR STYLE.', workshop_title: 'The playground.',
      workshop_intro: 'Pick a source. Move the level.<br>Move the line. Find your balance.',
      workshop_window: 'PKPOWERLINES — SIMULATOR', zoom_label: 'THE LINE, UP CLOSE',
      scenario_normal: 'Normal', scenario_low: 'Low battery', scenario_charge: 'Charging',
      legend_source: '01 / SOURCE', legend_position: '02 / POSITION',
      source_battery: 'Battery', source_ram: 'RAM', source_cpu: 'CPU', source_network: 'Network',
      magsafe_connected: 'MagSafe plugged in',
      pos_top: '↑ Top', pos_bottom: '↓ Bottom', pos_left: '← Left', pos_right: '→ Right',
      label_thickness: 'Thickness', label_opacity: 'Opacity',
      label_show_text: 'Show text', label_flow: 'Animated flow',
      advanced_summary: 'More settings <span>+</span>', label_source_color: 'Source color',
      label_threshold: 'Low battery threshold', label_force_text: 'Force text on low battery',
      reset: '↺ Reset',
      demo_note: 'A simulation to explore. Values don\u2019t come from your computer. Charging is sped up in the garden.',
      details_label: 'SMALL LINE, BIG CHOICE.', details_title: 'Discreet.<br>Down to the<br>last pixel.',
      f1_tag: 'ON ALL YOUR SCREENS', f1_title: 'The right edge, everywhere.', f1_text: 'Top, bottom, left or right. One bar per screen, present in every Space. Clicks pass through and the app lives in the menu bar, with no Dock icon.',
      f2_tag: 'MADE TO MEASURE', f2_title: 'From 4 to 40 pixels.', f2_text: 'Thickness, colors, 20\u2013100% opacity, seven fonts and a −40 to +400 px offset. Four thickness presets are one keystroke away.',
      f3_tag: 'THE RIGHT SIGNAL', f3_title: 'It knows how to stand out.', f3_text: 'Blue and ⚡ while actively charging. Red below your low threshold, adjustable from 5 to 50%. The alert can force the percentage and thicken the bar to 12 px.',
      f4_tag: 'THE RIGHT RHYTHM', f4_title: 'Alive, at your pace.', f4_text: 'Refresh every 1 to 10 seconds, optional animated flow and a network cap from 1 to 1,000 MB/s. Below 8 px, text hides automatically outside alerts.',
      app_settings_summary: 'And in the app\u2019s settings? <span>+</span>',
       app_settings_text: 'A SwiftUI window with search, menu bar spacing, Project Library, dedicated Credits, and Support on Ko-fi. About keeps the Stable/Dev update panel pinned at the bottom. ⌘, opens settings, ⌘R repositions the line. ⌘4, ⌘1, ⌘2 and ⌘3 apply the 4, 8, 12 and 20 px presets.',
      download_label: 'YOUR NEXT SMALL HABIT.', download_title: 'A line on your Mac.<br>A little more calm.',
      download_cta: 'Download PKpowerlines <span>↗</span>',
      download_footnote: 'Free and open source · macOS 13+ · Intel & Apple Silicon',
      footer_note: 'Made for your Mac. Everything stays on your Mac.', footer_github: 'GitHub ↗', footer_kofi: 'Buy a coffee ↗',
      copy: 'Copy', copied: 'Copied!',
      release_badge: 'Latest release: {0}',
      name_battery: 'Battery', name_ram: 'Memory (RAM)', name_cpu: 'Processor', name_network: 'Network',
      st_charging: 'Charging', st_low: 'Low battery', st_charged: 'Fully charged', st_battery: 'On battery',
      ph_battery_ok: 'On battery. All good.', ph_low: 'Time to plug in.', ph_charging: 'A little extra energy.', ph_full: '100%. Ready for what\u2019s next.',
      ph_ram: 'Active + wired memory.', ph_cpu: 'Overall processor load.', ph_network: 'Download + upload throughput.',
      level_battery: 'Battery level', level_ram: 'Memory used', level_cpu: 'CPU load', level_network: 'Share of network cap',
      plug_aria_drag: 'MagSafe cable: drag toward the port or click to plug in', plug_aria_connected: 'MagSafe connected: click or drag to unplug',
      connect: 'Plug in the MagSafe', disconnect: 'Unplug the MagSafe',
      cable_grab_html: 'grab the cable <span>↗</span>', cable_connected_html: 'connected. <span>⚡</span>',
      tip_ready: 'READY TO PLAY.', tip_discreet: 'BELOW 8 PX, TEXT TURNS DISCREET.', tip_alert: 'LOW ALERT: TEXT FORCED, THICKNESS ≥ 12 PX.', tip_network: 'SIMULATED CAP: 10 MB/S.',
      day_stretch_title: 'The day stretches on.<br>The line shortens.', day_stretch_desc: 'Scroll to move through time. The battery level follows the rhythm of your day.',
      day_low_title: 'A touch of red.<br>Time to plug in.', day_low_desc: 'The low alert makes the percentage visible. Drag the connector to the Mac\u2019s port, or use the button.',
      day_charge_title: 'A magnetic click.<br>And the energy returns.', day_charge_desc: 'The powerline turns blue and shows ⚡. Charging is sped up so you can watch the battery climb.',
      day_full_title: 'The line is full.<br>The day can go on.', day_full_desc: 'At 100%, charging stops. The bar turns green again, no lightning bolt.',
      petals_on: '✦ Petals: on', petals_off: '✦ Petals: off',
      motion_aria: 'Enable or disable animated petals'
    }
  };
  let lang;
  const urlLang = new URLSearchParams(location.search).get('lang');
  if (urlLang === 'fr' || urlLang === 'en') lang = urlLang;
  if (lang !== 'fr' && lang !== 'en') { try { lang = localStorage.getItem('pkpl-lang'); } catch (e) { /* stockage indisponible */ } }
  if (lang !== 'fr' && lang !== 'en') {
    const nav = (navigator.languages && navigator.languages[0]) || navigator.language || 'fr';
    lang = String(nav).toLowerCase().indexOf('fr') === 0 ? 'fr' : 'en';
  }
  const t = (key, ...args) => {
    let s = (I18N[lang] && I18N[lang][key]) != null ? I18N[lang][key] : I18N.fr[key];
    if (s == null) return key;
    if (args.length) s = String(s).replace(/\{(\d+)\}/g, (_, i) => args[Number(i)] != null ? args[Number(i)] : '');
    return s;
  };
  const nameOf = source => t('name_' + source);

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
    let color = state.palette[state.source], name = nameOf(state.source), prefix = '', key = null;
    if (state.source === 'battery') {
      if (state.plugged && value < 100) { color = '#007aff'; key = 'st_charging'; prefix = '⚡ '; }
      else if (value < state.threshold) { color = '#ff3b30'; key = 'st_low'; }
      else key = value >= 100 ? 'st_charged' : 'st_battery';
      if (key) name = t(key);
    }
    const label = state.source === 'network' ? `↓ ${(value * .08).toFixed(1)} ↑ ${(value * .02).toFixed(1)} MB/s` : `${prefix}${value}%`;
    return { value, color, name, key, prefix, label };
  }
  function render() {
    const s = status();
    document.documentElement.style.setProperty('--level', `${s.value}%`);
    document.documentElement.style.setProperty('--signal', s.color);
    $('world-label').textContent = $('preview-label').textContent = $('zoom-label').textContent = s.label;
    $('world-powerline').setAttribute('aria-label', `${nameOf(state.source)} : ${s.label}, ${s.name}`);
    $('preview-bar').setAttribute('aria-label', `${nameOf(state.source)} : ${s.label}, ${s.name}`);
    $('screen-source').textContent = nameOf(state.source).toUpperCase();
    $('screen-number').textContent = state.source === 'network' ? `${(s.value / 10).toFixed(1)} MB/s` : `${s.value}%`;
    $('screen-number').style.fontSize = state.source === 'network' ? 'clamp(13px, 1.7vw, 27px)' : '';
    $('screen-status').textContent = state.source === 'battery'
      ? ({ st_battery: 'ph_battery_ok', st_low: 'ph_low', st_charging: 'ph_charging', st_charged: 'ph_full' }[s.key] && t({ st_battery: 'ph_battery_ok', st_low: 'ph_low', st_charging: 'ph_charging', st_charged: 'ph_full' }[s.key]))
      : t({ ram: 'ph_ram', cpu: 'ph_cpu', network: 'ph_network' }[state.source]);
    $('floating-status').textContent = `${s.name} · ${state.source === 'network' ? s.label : s.value + ' %'}`;
    $('preview-state').textContent = s.name.toUpperCase();
    $('preview-value').textContent = s.label;
    $('level-title').textContent = t({ battery: 'level_battery', ram: 'level_ram', cpu: 'level_cpu', network: 'level_network' }[state.source]);
    $('level-output').textContent = `${s.value} %`;
    $('level').value = s.value;
    $('charge-row').hidden = state.source !== 'battery';
    $('charge-toggle').setAttribute('aria-checked', state.plugged);
    $('pixel-plug').setAttribute('aria-pressed', state.plugged);
    $('pixel-plug').classList.toggle('connected', state.plugged);
    $('pixel-plug').setAttribute('aria-label', state.plugged ? t('plug_aria_connected') : t('plug_aria_drag'));
    $('connect-button').innerHTML = `${t(state.plugged ? 'disconnect' : 'connect')} <span>↗</span>`;
    $('cable-instruction').innerHTML = state.plugged ? t('cable_connected_html') : t('cable_grab_html');
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
    $('workshop-tip').textContent = force ? t('tip_alert') : state.thickness < 8 ? t('tip_discreet') : state.source === 'network' ? t('tip_network') : t('tip_ready');
    const b = Math.round(state.values.battery);
    const dayKey = state.plugged ? (b >= 100 ? 'day_full' : 'day_charge') : b < state.threshold ? 'day_low' : 'day_stretch';
    $('day-title').innerHTML = t(dayKey + '_title');
    $('day-description').textContent = t(dayKey + '_desc');
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
  function petalsLabel() { return t(state.petals ? 'petals_on' : 'petals_off'); }
  $('motion-toggle').addEventListener('click', () => {
    state.petals = !state.petals;
    $('motion-toggle').setAttribute('aria-pressed', state.petals);
    $('motion-toggle').textContent = petalsLabel();
    if (!state.petals) particleContext.clearRect(0, 0, particleCanvas.width, particleCanvas.height);
    startLoop();
  });

  // ---------- bascule de langue ----------
  const langSwitch = document.querySelector('.lang-switch');
  function applyI18n() {
    document.documentElement.lang = lang;
    for (const el of document.querySelectorAll('[data-i18n]')) el.textContent = t(el.dataset.i18n);
    for (const el of document.querySelectorAll('[data-i18n-html]')) el.innerHTML = t(el.dataset.i18nHtml);
    for (const button of langSwitch.querySelectorAll('[data-lang]')) button.setAttribute('aria-pressed', button.dataset.lang === lang);
    $('motion-toggle').setAttribute('aria-label', t('motion_aria'));
    $('motion-toggle').textContent = petalsLabel();
    for (const button of document.querySelectorAll('.cmd-copy')) button.textContent = t('copy');
    render();
  }
  function setLang(next) {
    if (next !== 'fr' && next !== 'en') return;
    lang = next;
    try { localStorage.setItem('pkpl-lang', lang); } catch (e) { /* stockage indisponible */ }
    applyI18n();
  }
  langSwitch.addEventListener('click', event => { const b = event.target.closest('[data-lang]'); if (b) setLang(b.dataset.lang); });

  // ---------- release GitHub : badge version + DMG direct ----------
  const RELEASES_API = 'https://api.github.com/repos/mondary/Macos_PKpowerlines/releases/latest';
  fetch(RELEASES_API).then(response => response.ok ? response.json() : null).then(release => {
    if (!release || !release.assets) return;
    const asset = release.assets.find(a => /^PKpowerlines.*\.dmg$/i.test(a.name));
    if (!asset) return;
    const version = String(release.tag_name || '').replace(/^v/, '');
    const badge = $('release-badge');
    badge.hidden = false;
    badge.textContent = t('release_badge', version);
    const download = $('download-dmg');
    download.href = asset.browser_download_url;
    download.removeAttribute('target');
    download.removeAttribute('rel');
    $('cmd-curl').textContent = `curl -L -o ${asset.name} ${asset.browser_download_url}`;
  }).catch(() => { /* hors ligne ou API limitée : le lien reste la page des releases */ });

  for (const button of document.querySelectorAll('.cmd-copy')) button.addEventListener('click', async () => {
    const code = $(button.dataset.copy);
    if (!code) return;
    try { await navigator.clipboard.writeText(code.textContent); } catch (e) { return; }
    button.textContent = t('copied');
    setTimeout(() => { button.textContent = t('copy'); }, 1600);
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
    const t0 = time / 1000;
    if (state.phase > .8) {
      ctx.fillStyle = '#fff1c1';
      for (const p of stars) { ctx.globalAlpha = (.35 + Math.sin(t0 + p.phase) * .2) * ((state.phase - .8) / .2); ctx.fillRect(Math.round(p.x*w), Math.round(p.y*h), 1, 1); }
      ctx.globalAlpha = 1;
    }
    for (const p of particles) {
      const x = ((p.x*w - t0*p.speed*4 + Math.sin(t0*.6+p.sway)*5) % w + w) % w;
      const y = (p.y*h + t0*p.speed*3) % h;
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
  applyI18n();
  updateScroll(); measure();
  document.fonts.ready.then(() => { render(); measure(); });
})();
