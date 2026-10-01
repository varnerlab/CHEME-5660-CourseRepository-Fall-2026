/* Browser-only search and filters; every answer also has an ordinary HTML URL. */
(() => {
  'use strict';
  const normalize = value => String(value).toLowerCase().normalize('NFKD')
    .replace(/[μµ]/g, ' mu ').replace(/σ/g, ' sigma ').replace(/λ/g, ' lambda ')
    .replace(/β/g, ' beta ').replace(/α/g, ' alpha ').replace(/ρ/g, ' rho ')
    .replace(/δ/g, ' delta ').replace(/[εϵ]/g, ' epsilon ').replace(/θ/g, ' theta ')
    .replace(/[φϕ]/g, ' phi ').replace(/ω/g, ' omega ').replace(/η/g, ' eta ')
    .replace(/τ/g, ' tau ').replace(/ξ/g, ' xi ').replace(/γ/g, ' gamma ')
    .replace(/π/g, ' pi ').replace(/ψ/g, ' psi ').replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-z0-9]+/g, ' ').trim();
  const stop = new Set(['what','why','how','does','do','is','are','a','an','the','and','of','in','to','for','with','it','can','we','i','vs','versus','between','difference']);
  const tokens = value => normalize(value).split(/\s+/).filter(t => t && !stop.has(t));
  const input = document.getElementById('faq-search');
  if (input) {
    const list = document.getElementById('question-list');
    const rows = Array.from(list.querySelectorAll('.question-row'));
    const buttons = Array.from(document.querySelectorAll('.theme-filter'));
    const status = document.getElementById('search-status');
    const clear = document.getElementById('clear-search');
    const featured = document.querySelector('.featured');
    const index = new Map((window.FAQ_INDEX || []).map(item => [item.id, item]));
    const empty = document.createElement('div');
    empty.className = 'empty-state';
    empty.hidden = true;
    empty.innerHTML = '<h2>No matching questions</h2><p>Try a shorter phrase such as “drift”, “covariance”, or “NPV”, or choose all topics.</p>';
    list.append(empty);
    let selected = 'all';
    const validThemes = new Set(['all', ...buttons.map(b => b.dataset.theme)]);
    const query = new URLSearchParams(location.search);
    if (validThemes.has(query.get('theme'))) selected = query.get('theme');
    input.value = query.get('q') || '';
    const update = (changeURL = true) => {
      const terms = tokens(input.value);
      const ranked = [];
      for (const [position, row] of rows.entries()) {
        const item = index.get(row.dataset.id) || {};
        const title = normalize(item.title || row.textContent);
        const keywords = normalize(item.keywords || '');
        const body = normalize(item.text || row.textContent);
        const haystack = `${title} ${keywords} ${body}`;
        const matches = (!terms.length || terms.every(term => haystack.includes(term))) &&
          (selected === 'all' || row.dataset.theme === selected);
        row.hidden = !matches;
        if (matches) {
          const score = terms.reduce((sum, term) => sum + (title.includes(term) ? 20 : 0) + (keywords.includes(term) ? 8 : 0) + (body.includes(term) ? 1 : 0), 0);
          ranked.push({row, score, position});
        }
      }
      ranked.sort((a,b) => b.score - a.score || a.position - b.position);
      for (const result of ranked) list.insertBefore(result.row, empty);
      empty.hidden = ranked.length !== 0;
      clear.hidden = input.value.length === 0;
      for (const button of buttons) button.setAttribute('aria-pressed', String(button.dataset.theme === selected));
      const themeName = buttons.find(b => b.dataset.theme === selected)?.dataset.label || 'all topics';
      status.textContent = `${ranked.length} ${ranked.length === 1 ? 'question' : 'questions'}${selected !== 'all' ? ` in ${themeName}` : ''}${input.value.trim() ? ` matching “${input.value.trim()}”` : ''}`;
      if (featured) featured.hidden = !!input.value.trim() || selected !== 'all';
      if (changeURL) {
        const params = new URLSearchParams();
        if (input.value.trim()) params.set('q', input.value.trim());
        if (selected !== 'all') params.set('theme', selected);
        history.replaceState(null, '', location.pathname + (params.size ? '?' + params.toString() : '') + location.hash);
      }
    };
    input.addEventListener('input', () => update());
    input.closest('form')?.addEventListener('submit', event => { event.preventDefault(); update(); });
    clear.addEventListener('click', () => { input.value = ''; update(); input.focus(); });
    buttons.forEach(button => button.addEventListener('click', () => { selected = button.dataset.theme; update(); }));
    document.addEventListener('keydown', event => {
      const typing = /^(INPUT|TEXTAREA|SELECT)$/.test(document.activeElement?.tagName || '') || document.activeElement?.isContentEditable;
      if (event.key === '/' && !typing && !event.ctrlKey && !event.metaKey && !event.altKey) { event.preventDefault(); input.focus(); }
      if (event.key === 'Escape' && document.activeElement === input) { input.value = ''; update(); }
    });
    addEventListener('popstate', () => {
      const params = new URLSearchParams(location.search);
      input.value = params.get('q') || '';
      selected = validThemes.has(params.get('theme')) ? params.get('theme') : 'all';
      update(false);
    });
    update(false);
  }
  const notationSearch = document.getElementById('notation-search');
  if (notationSearch) {
    const select = document.getElementById('notation-lecture');
    const clear = document.getElementById('clear-notation');
    const status = document.getElementById('notation-status');
    const sections = Array.from(document.querySelectorAll('.notation-section'));
    const empty = document.getElementById('notation-empty');
    const params = new URLSearchParams(location.search);
    notationSearch.value = params.get('q') || '';
    const update = (changeURL = true) => {
      const terms = tokens(notationSearch.value);
      let count = 0;
      for (const section of sections) {
        const inLecture = select.value === 'all' || section.dataset.lecture === select.value;
        let visible = 0;
        section.querySelectorAll('tbody tr').forEach(row => {
          const text = normalize(row.textContent + ' ' + (row.dataset.keywords || ''));
          row.hidden = !inLecture || !terms.every(term => text.includes(term));
          if (!row.hidden) visible++;
        });
        section.querySelectorAll('.notation-group').forEach(group => {
          group.hidden = !Array.from(group.querySelectorAll('tbody tr')).some(row => !row.hidden);
        });
        section.hidden = !visible;
        count += visible;
      }
      clear.hidden = !notationSearch.value;
      empty.hidden = count > 0;
      status.textContent = `${count} notation ${count === 1 ? 'entry' : 'entries'}${select.value !== 'all' ? ` in ${select.value}` : ''}`;
      if (changeURL) {
        const query = new URLSearchParams();
        if (notationSearch.value.trim()) query.set('q', notationSearch.value.trim());
        history.replaceState(null, '', location.pathname + (query.size ? '?' + query.toString() : '') + (select.value === 'all' ? '' : '#' + select.value));
      }
    };
    notationSearch.addEventListener('input', update);
    notationSearch.closest('form')?.addEventListener('submit', event => { event.preventDefault(); update(); });
    select.addEventListener('change', update);
    clear.addEventListener('click', () => { notationSearch.value = ''; update(); notationSearch.focus(); });
    // A question's notation link opens the relevant lecture with its rows visible.
    const openLecture = () => {
      const hash = decodeURIComponent(location.hash.slice(1));
      select.value = Array.from(select.options).some(option => option.value === hash) ? hash : 'all';
      notationSearch.value = new URLSearchParams(location.search).get('q') || '';
      update(false);
    };
    addEventListener('hashchange', openLecture);
    addEventListener('popstate', openLecture);
    openLecture();
  }
})();
