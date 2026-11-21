`dev_env.jl` builds a scratch environment from the course `Project.toml` and `Manifest.toml` that uses the local Alpaca SDK checkout, and the check scripts include it. Run any script with `julia --startup-file=no <script>`.
`check_offline.jl` needs no credentials: it checks each tool for a unique name, a valid input schema, an error for an unknown argument, a verb at the start of each write tool's description, and the image result.
Run `check_offline.jl` after every change to the tools of the server. It prints the number of tools and exits non-zero when a check fails.
