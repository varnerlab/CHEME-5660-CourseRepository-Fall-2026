"""Clear the output of the include cell of an executed L15a example notebook, and keep every other output.

Usage: python3 clear_include_output.py <notebook.ipynb>
"""
import json, sys

path = sys.argv[1]
nb = json.load(open(path))
for c in nb["cells"]:
    if c["cell_type"] == "code" and "Include.jl" in "".join(c["source"]):
        c["outputs"] = []
json.dump(nb, open(path, "w"), indent=1, ensure_ascii=False)
open(path, "a").write("\n")
print("cleared the include output of", path)
