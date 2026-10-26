"""Export a course notebook to Markdown for NotebookLM.

Usage: python3 scripts/notebooklm-export.py <notebook.ipynb> <out.md>

Keeps markdown cells and short text outputs (tables, printed results); drops code
inputs, images, and long outputs, which NotebookLM cannot use and which read badly aloud.
"""
import json, re, sys
from pathlib import Path

MAX_LINES = 40

def strip_ansi(s):
    return re.sub(r'\x1b\[[0-9;]*m', '', s)

def export(src, dst):
    nb = json.loads(Path(src).read_text())
    out = []
    for c in nb['cells']:
        if c['cell_type'] == 'markdown':
            s = ''.join(c['source'])
            if s.lstrip().startswith('## Disclaimer'):
                continue
            # drop HTML image blocks; the alt text is kept as a sentence
            s = re.sub(r'<div>\s*<center>\s*<img[^>]*alt="([^"]*)"[^>]*/>\s*</center>\s*</div>',
                       r'*Figure: \1*', s, flags=re.S)
            s = re.sub(r'!\[([^\]]*)\]\([^)]*\)', r'*Figure: \1*', s)
            out.append(s)
        elif c['cell_type'] == 'code':
            for o in c.get('outputs', []):
                txt = None
                if o.get('output_type') == 'stream':
                    txt = ''.join(o.get('text', ''))
                elif 'data' in o and 'text/plain' in o['data'] and 'image/png' not in o['data'] and 'image/svg+xml' not in o['data']:
                    txt = ''.join(o['data']['text/plain'])
                if not txt:
                    continue
                txt = strip_ansi(txt).rstrip()
                if 'Activating project' in txt or 'Precompiling' in txt:
                    continue
                lines = txt.splitlines()
                if len(lines) > MAX_LINES or not txt.strip() or re.match(r'\d+(×\d+)?-element', lines[0]):
                    continue
                out.append('Output:\n```\n' + txt + '\n```')
    Path(dst).write_text('\n\n'.join(out) + '\n')

if __name__ == '__main__':
    export(sys.argv[1], sys.argv[2])
