"""Build the static course FAQ from curated Markdown and Claude's templates.

Requires Python 3 and Pandoc. The generated site needs no runtime dependencies.
"""
from collections import defaultdict
from html import escape
from html.parser import HTMLParser
from pathlib import Path
import argparse
import json
import re
import shutil
import subprocess

ROOT=Path(__file__).resolve().parent

class Plain(HTMLParser):
    def __init__(self):
        super().__init__();self.parts=[]
    def handle_data(self,data):self.parts.append(data)
def plain(html):
    p=Plain();p.feed(html);return re.sub(r'\s+',' ',' '.join(p.parts)).strip()
def fill(template,**values):
    return re.sub(r'\{\{([A-Z_]+)\}\}',lambda m:values[m[1]],template)
def markdown(text):
    p=subprocess.run(['pandoc','--from=markdown+tex_math_dollars','--to=html5','--mathml','--wrap=none'],input=text,text=True,capture_output=True,check=True)
    if p.stderr.strip():raise RuntimeError(p.stderr)
    assert '<merror' not in p.stdout
    return re.sub(r'<p>\s*(<math\b[^>]*display="block"[^>]*>.*?</math>)\s*</p>',
                  r'<div class="equation" tabindex="0" aria-label="Equation">\1</div>',p.stdout,flags=re.S)
def details_checks(body):
    pattern=r'<p><strong>Check[.:]?</strong>(.*?)<strong>Answer:</strong>(.*?)</p>'
    return re.sub(pattern,lambda m:'<div class="answer-check"><p><strong>Try it.</strong>'+m[1]+'</p><details><summary>Show the answer</summary><div>'+m[2]+'</div></details></div>',body,flags=re.S)

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output',type=Path,default=ROOT/'site')
    parser.add_argument('--docs-url',default='../index.html')
    args=parser.parse_args();out=args.output.resolve()
    design=json.loads((ROOT/'design.json').read_text())
    data=json.loads((ROOT/'content.json').read_text())
    themes={t['id']:t for t in data['themes']}
    articles=data['articles']
    (out/'assets').mkdir(parents=True,exist_ok=True)
    (out/'questions').mkdir(exist_ok=True)
    (out/'assets/faq.css').write_text(design['css']+'\n'+(ROOT/'refinements.css').read_text())
    shutil.copy2(ROOT/'faq.js',out/'assets/faq.js')
    shutil.copy2(ROOT/'volatility-clustering.svg',out/'assets/volatility-clustering.svg')
    index=[]
    for a in articles:
        a['html']=details_checks(markdown(a['body']))
        a['html']=re.sub(r'(<table\b.*?</table>)',r'<div class="table-wrap" tabindex="0" aria-label="Comparison table">\1</div>',a['html'],flags=re.S)
        a['url']='questions/'+a['id']+'.html'
        index.append({'id':a['id'],'title':a['title'],'theme':a['theme'],'keywords':a['keywords'],
                      'text':plain(a['html'])+' '+a['answer'],'url':a['url']})
    (out/'assets/search-index.js').write_text('window.FAQ_INDEX = '+json.dumps(index,ensure_ascii=False).replace('</',r'<\/')+';\n')

    def document(title,description,content,body_class,prefix=''):
        docs=args.docs_url
        if not re.match(r'https?://',docs):docs=prefix+docs
        html=fill(design['shell_html'],TITLE=escape(title+' · CHEME 5660'),DESCRIPTION=escape(description,quote=True),
                  PREFIX=prefix,HOME_URL=prefix+'index.html',NOTATION_URL=prefix+'notation.html',DOCS_URL=escape(docs,quote=True),
                  CONTENT=content,BODY_CLASS=body_class)
        html=html.replace('</head>',f'<script defer src="{prefix}assets/search-index.js"></script>\n</head>')
        # Search index must execute before the behavior script, regardless of
        # where the designer put the deferred script in the document.
        behavior=f'<script defer src="{prefix}assets/faq.js"></script>'
        html=re.sub(r'<script\b[^>]*\bsrc=[\'"]'+re.escape(prefix)+r'assets/faq\.js[\'"][^>]*>\s*</script>','',html)
        html=html.replace('</body>',behavior+'\n</body>')
        active_class='nav-notation' if body_class=='notation-page' else 'nav-questions'
        html=re.sub(r'<a\b(?=[^>]*\bclass=[\'"][^\'"]*\b'+active_class+r'\b)([^>]*)>',r'<a\1 aria-current="page">',html)
        assert not re.search(r'\{\{[A-Z_]+\}\}',html)
        return re.sub(r'[ \t]+$', '', html, flags=re.M)

    counts={t:sum(a['theme']==t for a in articles) for t in themes}
    theme_nav='<button type="button" class="theme-filter" data-theme="all" data-label="all topics" aria-pressed="true"><span>All questions</span><span class="theme-count">'+str(len(articles))+'</span></button>'
    for id,t in themes.items():
        theme_nav+=f'<button type="button" class="theme-filter" data-theme="{id}" data-label="{escape(t["name"],quote=True)}" aria-pressed="false"><span>{escape(t["name"])}</span><span class="theme-count">{counts[id]}</span></button>'
    question_rows=''
    for a in articles:
        question_rows+=f'<article class="question-row" data-id="{a["id"]}" data-theme="{a["theme"]}"><div class="question-meta"><span>{escape(themes[a["theme"]]["name"])}</span><span>{escape(", ".join(a["lectures"]))}</span></div><h3><a class="question-link" href="{a["url"]}">{escape(a["title"])}</a></h3><p class="question-summary">{escape(a["answer"])}</p></article>'
    featured='<ul>'
    for id in ['growth-and-drift','forecasting-and-pricing','correlated-shocks']:
        a=next(x for x in articles if x['id']==id)
        featured+=f'<li><a class="featured-link" href="{a["url"]}"><span class="featured-label">{escape(themes[a["theme"]]["name"])}</span><span>{escape(a["title"])}</span></a></li>'
    featured+='</ul>'
    home=fill(design['home_html'],THEME_NAV=theme_nav,QUESTION_LIST=question_rows,FEATURED=featured,QUESTION_COUNT=str(len(articles)))
    home+='<noscript><p class="no-script">All questions are listed below the topic navigation. Search and filters require JavaScript; the question links and answers work without it.</p></noscript>'
    (out/'index.html').write_text(document('Course questions','Worked answers to course questions, organized by theme and linked to the notes.',home,'home-page'))

    for a in articles:
        related=[x for x in articles if x['theme']==a['theme'] and x['id']!=a['id']][:3]
        if len(related)<2:
            related += [x for x in articles if set(x['lectures'])&set(a['lectures']) and x['id']!=a['id'] and x not in related][:2-len(related)]
        related_html='<ul>'+''.join(f'<li><a href="{x["id"]}.html">{escape(x["title"])}</a></li>' for x in related)+'</ul>'
        source_links='<ul>'+''.join(f'<li><a href="{escape(x["url"],quote=True)}">{escape(x["label"])}</a></li>' for x in a['sources'])+'</ul>'
        notation_links='<ul>'+''.join(f'<li><a href="../notation.html#{lec}">{lec} symbols and units</a></li>' for lec in a['lectures'])+'</ul>'
        body=fill(design['article_html'],THEME_NAME=escape(themes[a['theme']]['name']),QUESTION=escape(a['title']),
                  ANSWER=markdown(a['answer']),BODY=a['html'],LECTURES=source_links,NOTATION_LINKS=notation_links,
                  RELATED=related_html,HOME_URL='../index.html')
        (out/a['url']).write_text(document(a['title'],a['answer'],body,'article-page','../'))

    groups=defaultdict(list)
    for table in data['notation']:groups[table['lecture']].append(table)
    lecture_nav='<label for="notation-lecture">Lecture</label><select id="notation-lecture"><option value="all">All lectures</option>'+''.join(f'<option value="{lec}">{lec}</option>' for lec in groups)+'</select>'
    notation_html=''
    for lec,tables in groups.items():
        notation_html+=f'<section class="notation-section" id="{lec}" data-lecture="{lec}"><div class="notation-section-heading"><h2>{lec}</h2>'
        if lec in data['lecture_sources']:
            notation_html+=f'<a href="{escape(data["lecture_sources"][lec],quote=True)}">Lecture notes ↗</a>'
        notation_html+='</div>'
        for table in tables:
            heading=table['title'].replace('Notation for the Worked Explanation','Symbols').replace('Notation and the Design Matrix','Estimation')
            heading=re.sub(r'^'+re.escape(lec)+r':\s*','',heading)
            title_html='' if heading=='Symbols' else f'<h3>{escape(heading)}</h3>'
            rendered=markdown(table['markdown'])
            notation_html+=f'<div class="notation-group">{title_html}<div class="table-scroll table-wrap" tabindex="0" aria-label="{escape(heading,quote=True)}">{rendered}</div></div>'
        notation_html+='</section>'
    notation_html+='<div class="empty-state" id="notation-empty" hidden><h2>No matching notation</h2><p>Try a symbol name such as “sigma”, “drift”, or “covariance”, or choose all lectures.</p></div>'
    notation_template=re.sub(r'<p\b[^>]*\bid=[\'"]notation-empty[\'"][^>]*>.*?</p>','',design['notation_html'],flags=re.S)
    notation_template=notation_template.replace('</header>', '<p class="table-hint">Scroll tables sideways to see every column.</p></header>',1)
    content=fill(notation_template,LECTURE_NAV=lecture_nav,NOTATION_SECTIONS=notation_html)
    (out/'notation.html').write_text(document('Notation','Symbols, meanings, units, and lecture context through Week 6.',content,'notation-page'))
    print(f'Built {len(articles)} question pages, a searchable question index, and a separate notation view at {out}')

if __name__=='__main__':main()
