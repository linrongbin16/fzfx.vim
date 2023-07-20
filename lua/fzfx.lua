--- @type table<string, integer>
local SEVERITY_MAP = {
    ["ERROR"] = 1,
    ["WARN"] = 2,
    ["INFO"] = 3,
    ["HINT"] = 4,
}

--- @type table<integer, string>
local SEVERITY_VALUE_MAP = {
    [1] = "ERROR",
    [2] = "WARN",
    [3] = "INFO",
    [4] = "HINT",
}

--- @type table<string, integer>
local SIGN_SEVERITY_MAP = {
    DiagnosticSignError = 1,
    DiagnosticSignWarn = 2,
    DiagnosticSignInfo = 3,
    DiagnosticSignHint = 4,
}

--- @class LspDiagnosticSign
--- @field name string
--- @field texthl string
--- @field text string

--- @type LspDiagnosticSign[]
local DIAGNOSTIC_SIGNS_LIST = vim.fn.sign_getdefined()

--- @type table<integer, LspDiagnosticSign>
local DIAGNOSTIC_SIGNS_MAP = {}
for _, sign in ipairs(DIAGNOSTIC_SIGNS_LIST) do
    if type(sign.name) == "string" and SIGN_SEVERITY_MAP[sign.name] ~= nil then
        local severity = SIGN_SEVERITY_MAP[sign.name]
        DIAGNOSTIC_SIGNS_MAP[severity] = sign
    end
end

local function colorize(ref_name, text, hl)
    if type(text) == "string" then
        text = "'" .. text .. "'"
    end
    if type(hl) == "string" and string.len(hl) > 0 then
        hl = "'" .. hl .. "'"
        return vim.api.nvim_eval(
            "call(function('"
                .. ref_name
                .. "'), ["
                .. text
                .. ", "
                .. hl
                .. "])"
        )
    else
        return vim.api.nvim_eval(
            "call(function('" .. ref_name .. "'), [" .. text .. "])"
        )
    end
end

--- @class DiagnosticEntry
--- @field bufnr integer
--- @field lnum integer
--- @field col integer
--- @field message string
--- @field severity integer

--- @param entry DiagnosticEntry
--- @param sid_refs table<string, string>
local function make_diagnostic_entry(entry, sid_refs)
    if not entry then
        return nil
    end

    local SEVERITY_COLOR_MAP = {
        [1] = "red_ref_name",
        [2] = "yellow_ref_name",
        [3] = "green_ref_name",
        [4] = "magenta_ref_name",
    }

    local abs_filename = vim.api.nvim_buf_get_name(entry.bufnr)
    local rel_filename = vim.fn.fnamemodify(abs_filename, ":~:.")

    local has_message = type(entry.message) == "string"
        and string.len(vim.trim(entry.message)) > 0

    local sign = nil
    local sign_text = " "
    local sign_texthl = nil
    local sign_texthl_ref_name = nil
    if DIAGNOSTIC_SIGNS_MAP[entry.severity] ~= nil then
        sign = DIAGNOSTIC_SIGNS_MAP[entry.severity]
        sign_texthl = sign.texthl
        sign_texthl_ref_name = sid_refs[SEVERITY_COLOR_MAP[entry.severity]]
        sign_text = colorize(sign_texthl_ref_name, sign.text, sign_texthl)
    end
    local message = has_message
            and string.format("%s%s", sign_text, vim.trim(entry.message))
        or ""

    local result = string.format(
        "%s:%s:%s:%s%s",
        rel_filename,
        entry.lnum,
        entry.col,
        has_message and " " or "",
        message
    )
    vim.fn["fzfx#vim#_debug"](
        string.format("|make_source_entry| result:[%s]", result)
    )
    return result
end

--- @class LspDiagnosticOpts
--- @field workspace integer
--- @field severity integer

--- @class LspDiagnosticResult
--- @field bufnr integer
--- @field col integer
--- @field end_col integer
--- @field lnum integer
--- @field end_lnum integer
--- @field message string
--- @field severity integer
--- @field source string

--- @param a LspDiagnosticResult
--- @param b LspDiagnosticResult
--- @return boolean
local function lsp_diagnostic_compare(a, b)
    if a["severity"] ~= nil and b["severity"] ~= nil then
        return a["severity"] < b["severity"]
    end
    return a["severity"] ~= nil
end

--- @param d LspDiagnosticResult
--- @return string
local function lsp_diagnostic_format(d) end

--- @param opts LspDiagnosticOpts
--- @param sid_refs table<string, string>
--- @return string[]
local function lsp_diagnostics(opts, sid_refs)
    local severity = 4
    if opts.severity then
        if type(opts.severity) == "number" then
            severity = opts.severity
        end
        if type(opts.severity) == "string" then
            if SEVERITY_MAP[opts.severity:upper()] ~= nil then
                severity = SEVERITY_MAP[opts.severity:upper()]
            end
        end
    end

    local bufnr = opts.workspace <= 0 and 0 or nil
    local diagnostics_list = vim.diagnostic.get(bufnr)
    -- vim.fn["fzfx#vim#_debug"](
    --     string.format(
    --         "|lsp_diagnostics| diagnostics_list(%s):%s, opts:%s, sid_refs:%s",
    --         type(diagnostics_list),
    --         vim.inspect(diagnostics_list),
    --         vim.inspect(opts),
    --         vim.inspect(sid_refs)
    --     )
    -- )

    local filtered_list = {}
    for _, diag in ipairs(diagnostics_list) do
        if type(diag.severity) == "number" and diag.severity <= severity then
            table.insert(filtered_list, diag)
        end
    end
    table.sort(filtered_list, lsp_diagnostic_compare)

    local results_list = {}
    for _, diag in ipairs(filtered_list) do
        table.insert(results_list, make_diagnostic_entry(diag, sid_refs))
    end
    return results_list
end

local M = {
    lsp_diagnostics = lsp_diagnostics,
}

return M
