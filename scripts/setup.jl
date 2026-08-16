# scripts/setup.jl: one-time (and safe to re-run) setup of the CHEME 5660 course environment.
#
# Usage, from a terminal at the repo root or the unzipped weekly bundle root:
#
#     julia scripts/setup.jl
#
# or open this file in VS Code and run it with the Julia extension. What it does:
#
#   1. Activates the course environment (the Project.toml/Manifest.toml next to this
#      scripts/ folder) and instantiates it, i.e., installs the pinned package versions.
#   2. Installs a Jupyter kernelspec named `julia-cheme5660` ("Julia (CHEME 5660)") that
#      launches Julia through the juliaup shim (`~/.juliaup/bin/julia`, or `julia` on the
#      PATH) with `--project=@.`, so the notebooks find this environment automatically.
#
# Why the shim rather than the Julia binary itself: a kernelspec that points at the binary
# of a specific patch release (e.g., 1.12.6) breaks the moment juliaup replaces it with the
# next one (1.12.7); the shim keeps working across updates. If juliaup is not detected the
# script falls back to the running Julia binary and says so.
#
# If Jupyter or VS Code reports "kernel not found" for a course notebook, run this script
# again and restart Jupyter (or the VS Code window).

import Pkg

const ROOT = normpath(joinpath(@__DIR__, ".."))
isfile(joinpath(ROOT, "Project.toml")) || error("Cannot find Project.toml in $(ROOT); run this script from the course repository (or unzipped weekly bundle).")

println("CHEME 5660 setup: course environment at $(ROOT)")
println("Julia $(VERSION) at $(Sys.BINDIR)")
flush(stdout)

# 1. Course environment -
Pkg.activate(ROOT)
Pkg.instantiate()

# 2. Jupyter kernelspec through the juliaup shim (version-agnostic) -
function _julia_launcher()
    exe = Sys.iswindows() ? "julia.exe" : "julia"
    candidates = String[joinpath(homedir(), ".juliaup", "bin", exe)]
    let p = Sys.which("julia")
        p === nothing || push!(candidates, p)
    end
    for c in candidates
        isfile(c) && return (c, true)
    end
    return (joinpath(Sys.BINDIR, exe), false) # fallback: the running binary (version-pinned)
end

import IJulia
const KERNEL_SPECNAME = "julia-cheme5660"
const KERNEL_DISPLAY = "Julia (CHEME 5660)"
launcher, via_shim = _julia_launcher()
via_shim || @warn "juliaup shim not found; the kernelspec will point at the current Julia binary and must be re-created after a Julia update ($(launcher))."
kernelpath = IJulia.installkernel(KERNEL_DISPLAY, "--project=@.";
    julia = `$(launcher)`, specname = KERNEL_SPECNAME, displayname = KERNEL_DISPLAY)

println()
println("SETUP-OK")
println("  environment: $(ROOT)")
println("  kernelspec:  $(kernelpath)")
println("  launcher:    $(launcher)$(via_shim ? " (juliaup shim)" : "")")
println("Restart Jupyter (or the VS Code window) and select the \"$(KERNEL_DISPLAY)\" kernel.")
