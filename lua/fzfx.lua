--- @class SourceEntry
--- @field bufnr integer
--- @field lnum integer
--- @field col integer
--- @field text string

--- @param source_entry SourceEntry
--- @param sid_refs table<string, string>
local function make_source_entry(source_entry, sid_refs)
    if not source_entry then
        return nil
    end
    local green_func_name = sid_refs["green_func_name"]
    local blue_func_name = sid_refs["blue_func_name"]
    local abs_filename = vim.api.nvim_buf_get_name(source_entry.bufnr)
    local rel_filename = vim.fn.fnamemodify(abs_filename, ':~:.')
    local has_text = type(source_entry.text) == "string"
        and string.len(source_entry.text) > 0
    local result = string.format(
        "%s:%s:%s:%s%s",
        rel_filename,
        vim.api.nvim_eval(
            "call(function('"
                .. green_func_name
                .. "'), ["
                .. source_entry.lnum
                .. ", 'Constant'])"
        ),
        vim.api.nvim_eval(
            "call(function('"
                .. blue_func_name
                .. "'), ["
                .. source_entry.lnum
                .. ", 'Operator'])"
        ),
        has_text and " " or "",
        not has_text and "" or vim.trim(source_entry.text),
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
    local SEVERITY_MAP = {
        ["ERROR"] = 1,
        ["WARN"] = 2,
        ["INFO"] = 3,
        ["HINT"] = 4,
    }
    local severity = 4
    if opts.severity then
        if type(opts.severity) == "number" then
            severity = opts.severity
        end
        if type(opts.severity) == "string" then
            if SEVERITY_MAP[opts.severity] ~= nil then
                severity = SEVERITY_MAP[opts.severity]
            end
        end
    end

    local bufnr = opts.workspace <= 0 and 0 or nil
    local diagnostics_list = vim.diagnostic.get(bufnr)

    local filtered_list = {}
    for _, diag in ipairs(diagnostics_list) do
        if type(diag.severity) == "number" and diag.severity <= severity then
            table.insert(filtered_list)
        end
    end
    table.sort(filtered_list, lsp_diagnostic_compare)

    local results_list = {}
    for _, diag in ipairs(filtered_list) do
        table.insert(results_list, make_source_entry(diag, sid_refs))
    end
    return results_list
end

local M = {
    lsp_diagnostics = lsp_diagnostics,
}

return M
