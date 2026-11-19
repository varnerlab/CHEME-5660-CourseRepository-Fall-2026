# =============================================================================
# CHEME 5660 | L14a Alpaca server: read the credentials file
# =============================================================================
# The server reads your Alpaca key and secret from a credentials file when it
# starts. The key and secret stay in the server: they are never part of an MCP
# message. The server trades only in a paper account, so it refuses a file whose
# endpoint is not the paper trading endpoint.
# =============================================================================

# the base URL of the paper trading API. The server refuses any other endpoint, e.g., the live endpoint -
const PAPER_ENDPOINT = "https://paper-api.alpaca.markets/v2";

# --- PUBLIC METHODS BELOW HERE -------------------------------------------------------------------------------- #
"""
    credentials_path(root::String) -> String

The path to the credentials file. When the environment variable `ALPACA_CREDENTIALS` holds a path, the server uses
that file, so the credentials can stay outside the course repository. Otherwise, the server uses `conf/apidata.toml`
in the server folder, which git does not track.

### Arguments
- `root::String`: the server folder, e.g., `L14A_ALPACA_MCP_ROOT`.

### Returns
- `String`: the path to the credentials file. The function does not check that the file exists.
"""
function credentials_path(root::String)::String

    # the environment variable comes first -
    path = get(ENV, "ALPACA_CREDENTIALS", "");
    if (isempty(path) == false)
        return expanduser(path);
    end

    # otherwise, the file in the conf folder of the server -
    return joinpath(root, "conf", "apidata.toml");
end

"""
    load_server_configuration(path::String) -> Dict{String,Any}

Read the credentials file, check that it names the paper trading endpoint, and build the Alpaca client.

The file is written in the TOML format of the Alpaca SDK. Its `[Credentials]` section has three entries: `endpoint`,
`key`, and `secret`. When the file is missing, cannot be read, or names another endpoint, the server still starts,
and every tool reports the reason. The messages never show the contents of the file.

### Arguments
- `path::String`: the path to the credentials file, e.g., `credentials_path(L14A_ALPACA_MCP_ROOT)`.

### Returns
- `Dict{String,Any}`: the configuration of the server, with the keys `"client"` (an `Alpaca.AlpacaClient`),
  `"endpoint"`, `"key"`, and `"secret"`. When the file has a problem, the dictionary holds only `"setup_error"`,
  the reason in plain English.
"""
function load_server_configuration(path::String)::Dict{String,Any}

    # initialize -
    configuration = Dict{String,Any}();

    # check: does the file exist?
    if (isfile(path) == false)
        configuration["setup_error"] = "We cannot find the credentials file. Copy conf/apidata-template.toml to " *
            "conf/apidata.toml and paste your paper key and secret into it, or set ALPACA_CREDENTIALS to the path of your file.";
        return configuration;
    end

    # read the file. The error of the TOML reader shows the line that it could not read, which may hold the secret,
    # so we write our own message -
    contents = nothing;
    try
        contents = TOML.parsefile(path);
    catch
        configuration["setup_error"] = "We cannot read the credentials file. Compare it with conf/apidata-template.toml.";
        return configuration;
    end

    # check: does the file have a [Credentials] section with the three entries?
    if (haskey(contents, "Credentials") == false)
        configuration["setup_error"] = "The credentials file has no [Credentials] section. Compare it with conf/apidata-template.toml.";
        return configuration;
    end
    credentials = contents["Credentials"];
    for name ∈ ("endpoint", "key", "secret")
        if (haskey(credentials, name) == false)
            configuration["setup_error"] = "The [Credentials] section has no $(name) entry. Compare it with conf/apidata-template.toml.";
            return configuration;
        end
    end

    # check: the endpoint must be the paper trading endpoint. This server never trades with real money -
    endpoint = rstrip(String(credentials["endpoint"]), '/');
    if (endpoint != PAPER_ENDPOINT)
        configuration["setup_error"] = "This server trades only in a paper account. The endpoint in the credentials " *
            "file must be $(PAPER_ENDPOINT).";
        return configuration;
    end

    # build the client, and keep the key and secret, so the server can hide them in an error message -
    configuration["client"] = Alpaca.load_client(path);
    configuration["endpoint"] = endpoint;
    configuration["key"] = String(credentials["key"]);
    configuration["secret"] = String(credentials["secret"]);
    return configuration;
end
# --- PUBLIC METHODS ABOVE HERE -------------------------------------------------------------------------------- #
