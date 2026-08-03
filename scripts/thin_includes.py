#!/usr/bin/env python3
"""Replace the 2025 Pkg-bootstrap block in every lectures/**/Include.jl with
an activate-walk-up preamble. Idempotent. Reports files needing manual review."""
import re, sys
from pathlib import Path

PREAMBLE = '''# setup the course environment: walk up to the nearest Project.toml
# (repo root in a clone; bundle root in an unzipped weekly download) -
import Pkg
let d = @__DIR__
    while !isfile(joinpath(d, "Project.toml")) && d != dirname(d)
        d = dirname(d)
    end
    Pkg.activate(d); Pkg.instantiate();
end
'''

# the uniform 2025 block: 'using Pkg' line, the if-isfile line, body, closing 'end'
BLOCK = re.compile(
    r"#[^\n]*up to date[^\n]*\n"      # '# make sure all is up to date -'
    r"using Pkg\n"
    r"if \(isfile\(joinpath\(_ROOT, \"Manifest\.toml\"\)\).*?\n"
    r"(?:.*?\n)*?"                     # block body (non-greedy)
    r"end\n",
    re.M)

changed, manual = [], []
for p in sorted(Path("lectures").rglob("Include.jl")):
    if ".ipynb_checkpoints" in str(p):
        continue
    s = p.read_text()
    if "walk up to the nearest Project.toml" in s:
        continue  # already transformed
    new, n = BLOCK.subn(PREAMBLE, s, count=1)
    if n == 1 and "Pkg.add" not in new and "Pkg.update" not in new:
        p.write_text(new); changed.append(str(p))
    else:
        manual.append(str(p))

print(f"transformed: {len(changed)}")
for m in manual:
    print(f"MANUAL REVIEW NEEDED: {m}")
sys.exit(1 if manual else 0)
