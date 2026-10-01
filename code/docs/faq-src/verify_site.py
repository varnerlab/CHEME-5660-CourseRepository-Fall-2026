"""Check links, search, keyboard behavior, and responsive layout of the built FAQ."""
from pathlib import Path
from urllib.parse import urlsplit, unquote
import argparse
import json
from bs4 import BeautifulSoup
from playwright.sync_api import sync_playwright

ROOT = Path(__file__).resolve().parent

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--site', type=Path, default=ROOT/'docs-preview/build/faq')
    args = parser.parse_args()
    site = args.site.resolve()
    qa = ROOT/'qa'
    qa.mkdir(exist_ok=True)
    data = json.loads((ROOT/'content.json').read_text())
    pages = list(site.rglob('*.html'))
    errors = []
    for path in pages:
        soup = BeautifulSoup(path.read_text(), 'html.parser')
        assert len(soup.select('h1')) == 1, path
        assert not soup.select('merror'), path
        assert '{{' not in soup.get_text(), path
        for element in soup.select('[href], [src]'):
            url = urlsplit(element.get('href') or element.get('src'))
            if url.scheme or url.netloc:
                continue
            target = (path.parent/unquote(url.path)).resolve() if url.path else path
            if not target.exists():
                errors.append(f'{path.name}: missing {url.geturl()}')
            elif url.fragment and target.suffix == '.html':
                dest = BeautifulSoup(target.read_text(), 'html.parser')
                if not dest.find(id=unquote(url.fragment)):
                    errors.append(f'{path.name}: missing anchor {url.geturl()}')
    assert not errors, errors
    assert len(pages) == len(data['articles']) + 2
    report = {'html_pages': len(pages), 'internal_links': 'pass', 'browser_errors': [], 'search': {}}
    with sync_playwright() as p:
        browser = p.chromium.launch()
        page = browser.new_page(viewport={'width':1440, 'height':1100}, device_scale_factor=1)
        page.on('pageerror', lambda error: report['browser_errors'].append(str(error)))
        page.goto((site/'index.html').as_uri())
        assert page.locator('.question-row:visible').count() == len(data['articles'])
        page.screenshot(path=str(qa/'home-desktop.png'))
        for query, expected in [('What is drift?', 'growth-and-drift'), ('half variance', 'growth-and-drift'), ('correlated movements','correlated-shocks'), ('daily leverage','daily-leverage')]:
            page.locator('#faq-search').fill(query)
            ids = page.locator('.question-row:visible').evaluate_all('(rows) => rows.map(row => row.dataset.id)')
            assert expected in ids, (query, ids)
            report['search'][query] = ids
        page.locator('#faq-search').fill('zyxnonexistent')
        assert page.locator('.question-row:visible').count() == 0
        assert page.locator('#question-list .empty-state').is_visible()
        page.locator('#clear-search').click()
        assert page.locator('.question-row:visible').count() == len(data['articles'])
        page.locator('.theme-filter[data-theme="dependence"]').click()
        assert page.locator('.question-row:visible').count() == sum(a['theme']=='dependence' for a in data['articles'])
        page.reload()
        assert page.locator('.theme-filter[data-theme="dependence"]').get_attribute('aria-pressed') == 'true'
        page.locator('.theme-filter[data-theme="all"]').click()
        page.locator('h1').click()
        page.keyboard.press('/')
        assert page.locator('#faq-search').evaluate('(el) => el === document.activeElement')
        page.locator('#faq-search').fill('drift')
        page.keyboard.press('Escape')
        assert page.locator('#faq-search').input_value() == ''
        page.goto((site/'questions/growth-and-drift.html').as_uri())
        assert page.locator('math').count() > 0
        page.screenshot(path=str(qa/'answer-desktop.png'), full_page=True)
        if page.locator('details').count():
            page.locator('details summary').first.click()
            assert page.locator('details').first.get_attribute('open') is not None
        page.goto((site/'notation.html').as_uri()+'#L4b')
        assert page.locator('#notation-lecture').input_value() == 'L4b'
        assert page.locator('.notation-section:visible').count() == 1
        page.locator('#notation-lecture').select_option('all')
        page.locator('#notation-search').fill('sigma')
        assert page.locator('tbody tr:visible').count() > 0
        sigma_count = page.locator('tbody tr:visible').count()
        page.locator('#notation-search').fill('σ')
        assert page.locator('tbody tr:visible').count() == sigma_count
        page.reload()
        assert page.locator('#notation-search').input_value() == 'σ'
        assert page.locator('#notation-lecture').input_value() == 'all'
        assert page.locator('tbody tr:visible').count() == sigma_count
        page.screenshot(path=str(qa/'notation-desktop.png'))
        page.locator('#notation-search').fill('zyxnonexistent')
        assert page.locator('#notation-empty').is_visible()
        page.locator('#clear-notation').click()
        assert page.locator('tbody tr:visible').count() > 0
        overflows = []
        page.set_viewport_size({'width':360,'height':900})
        for path in pages:
            page.goto(path.as_uri())
            if page.evaluate('document.documentElement.scrollWidth > innerWidth + 1'):
                overflows.append(path.name)
                report.setdefault('overflow_details',{})[path.name] = page.locator('p, math, .equation, table, h1, h2, h3').evaluate_all('(els) => els.filter(e => e.getBoundingClientRect().right > innerWidth + 1).map(e => ({tag:e.tagName,cls:e.className, width:e.getBoundingClientRect().width,text:e.textContent.slice(0,140)}))')
                page.screenshot(path=str(qa/('overflow-'+path.name+'.png')),full_page=True)
        page.goto((site/'index.html').as_uri())
        page.screenshot(path=str(qa/'home-mobile.png'))
        page.goto((site/'questions/correlated-shocks.html').as_uri())
        page.screenshot(path=str(qa/'answer-mobile.png'), full_page=True)
        page.goto((site/'notation.html').as_uri()+'#L5b')
        page.screenshot(path=str(qa/'notation-mobile.png'))
        assert not overflows, report.get('overflow_details')
        nojs = browser.new_page(java_script_enabled=False)
        nojs.goto((site/'index.html').as_uri())
        assert nojs.locator('.question-link').count() == len(data['articles'])
        nojs.locator('.question-link').first.click()
        assert nojs.locator('.prose').inner_text().strip()
        browser.close()
    assert not report['browser_errors'], report
    report.update({'mobile_width':360,'mobile_overflow':'none on all pages','without_javascript':'all answers navigable','equations':'native MathML','status':'passed'})
    (qa/'verification.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(report,indent=2))

if __name__ == '__main__':
    main()
