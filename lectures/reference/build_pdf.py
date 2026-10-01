#!/usr/bin/env python3
"""Build the nomenclature PDF from its Markdown-only notebook (Pandoc + pdfLaTeX)."""
import argparse
import json
from pathlib import Path
import re
import shutil
import subprocess
import tempfile

STEM = 'CHEME-5660-Nomenclature-Fall-2026'
HEADER = r'''\documentclass[10pt,letterpaper]{article}
\usepackage[margin=0.64in,headheight=14pt,headsep=15pt,footskip=25pt]{geometry}
\usepackage[T1]{fontenc}
\usepackage{lmodern,amsmath,amssymb,array,longtable,booktabs,calc,microtype}
\usepackage{xcolor,titlesec,fancyhdr,hyperref,graphicx}
\hypersetup{colorlinks=true,linkcolor=black,urlcolor=black,
pdftitle={CHEME 5660: Nomenclature and Worked Explanations},pdfauthor={CHEME 5660},
pdfsubject={Student questions, worked calculations, and lecture notation through Week 6}}
\setlength{\parindent}{0pt}
\setlength{\parskip}{5pt}
\setlength{\tabcolsep}{5pt}
\renewcommand{\arraystretch}{1.27}
\setlength{\LTpre}{5pt}
\setlength{\LTpost}{8pt}
\setcounter{secnumdepth}{0}
\titleformat{\section}{\color{black}\LARGE\bfseries}{}{0pt}{}
\titleformat{\subsection}{\color{black}\Large\bfseries}{}{0pt}{}
\titleformat{\subsubsection}{\color{black}\normalsize\bfseries}{}{0pt}{}
\titlespacing*{\section}{0pt}{0pt}{9pt}
\titlespacing*{\subsection}{0pt}{0pt}{8pt}
\titlespacing*{\subsubsection}{0pt}{8pt}{4pt}
\pagestyle{fancy}
\fancyhf{}
\fancyhead[L]{\small\color{black}CHEME 5660 \enspace / \enspace Nomenclature and worked explanations}
\fancyhead[R]{\small\color{black}Fall 2026}
\fancyfoot[L]{\small\color{black}Through Week 6 \enspace | \enspace September 29, 2026}
\fancyfoot[R]{\small\color{black}\thepage}
\renewcommand{\headrulewidth}{0.25pt}
\renewcommand{\footrulewidth}{0pt}
\providecommand{\tightlist}{\setlength{\itemsep}{0pt}\setlength{\parskip}{0pt}}
\providecommand{\pandocbounded}[1]{#1}
\makeatletter
\def\maxwidth{\ifdim\Gin@nat@width>\linewidth\linewidth\else\Gin@nat@width\fi}
\def\maxheight{\ifdim\Gin@nat@height>\textheight\textheight\else\Gin@nat@height\fi}
\makeatother
\setkeys{Gin}{width=\maxwidth,height=\maxheight,keepaspectratio}
\widowpenalty=10000
\clubpenalty=10000
\setlength{\emergencystretch}{1em}
\begin{document}
'''


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--build-dir', type=Path, help='Keep TeX and logs in this directory for inspection.')
    args = parser.parse_args()
    here = Path(__file__).resolve().parent
    notebook = json.loads((here / (STEM + '.ipynb')).read_text())
    assert all(c['cell_type'] == 'markdown' for c in notebook['cells']), 'Reference must contain only Markdown cells.'
    source = '\n\n'.join(('\\clearpage\n\n' if c.get('metadata', {}).get('pdf_page_break_before') else '')
                          + ''.join(c['source']) for c in notebook['cells'])
    # Each topic starts on a new PDF page; the notebook keeps the course section rules.
    source = re.sub(r'___\s*\n(?=## )', r'\\clearpage\n\n', source)
    source = re.sub(r'\n___\s*$', '', source)
    # Keep the same figure inline in both notebook and PDF; resolve its path for TeX.
    def resolve_figure(match):
        path = here / match.group(2)
        # The notebook uses the lecture's original SVG; TeX uses the matching
        # original PDF. Neither representation redraws or alters the figure.
        if path.suffix == '.svg':
            path = path.with_suffix('.pdf')
            if not path.exists():
                raise FileNotFoundError(f'Matching lecture PDF is missing: {path}')
        return '!['+match.group(1)+']('+str(path)+')'
    source = re.sub(r'!\[([^\]]*)\]\((figs/[^)]+)\)', resolve_figure, source)
    body = subprocess.run(['pandoc','-f','markdown+pipe_tables+tex_math_dollars-implicit_figures',
                           '-t','latex','--wrap=none'], input=source, text=True,
                          capture_output=True, check=True).stdout
    # Scale the original lecture figure for legibility without changing its content.
    body = re.sub(r'(?m)^\\includegraphics\{([^}]+)\}$',
                  r'\\begin{center}\n\\includegraphics[width=0.95\\linewidth,height=\\textheight,keepaspectratio]{\1}\n\\end{center}', body)
    table_pattern = r'(\\begin\{longtable\}.*?)(?=\\toprule)'
    def size_columns(match):
        block = match.group(1)
        widths = iter(['0.25','0.57','0.18'])
        return re.sub(r'\\real\{[0-9.]+\}', lambda _: '\\real{' + next(widths) + '}', block)
    body = re.sub(table_pattern, size_columns, body, flags=re.S)
    temp = None
    if args.build_dir:
        build = args.build_dir.resolve()
        build.mkdir(parents=True, exist_ok=True)
    else:
        temp = tempfile.TemporaryDirectory(prefix='cheme5660-nomenclature-')
        build = Path(temp.name)
    tex = build / (STEM + '.tex')
    tex.write_text(HEADER + body + '\n\\end{document}\n')
    for _ in range(2):
        result = subprocess.run(['pdflatex','-interaction=nonstopmode','-halt-on-error',tex.name], cwd=build, text=True, capture_output=True)
        if result.returncode:
            raise RuntimeError(result.stdout[-6000:])
    pdf = here / (STEM + '.pdf')
    shutil.copyfile(build / pdf.name, pdf)
    warnings = [s for s in (build / (STEM+'.log')).read_text().splitlines() if 'Overfull' in s or 'Missing character' in s]
    print(f'Built {pdf}')
    print('\n'.join(warnings) if warnings else 'No overfull boxes or missing-character warnings.')
    if temp:
        temp.cleanup()


if __name__ == '__main__':
    main()
