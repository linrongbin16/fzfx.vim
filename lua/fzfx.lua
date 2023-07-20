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

--- @class LspDiagnosticOpts
--- @field workspace integer
--- @field severity integer

--- @param opts LspDiagnosticOpts
--- @return string[]
local function lsp_diagnostics(opts)
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

    local signs = vim.fn.sign_getdefined()
    local bufnr = opts.workspace <= 0 and 0 or nil
    local diagnostics_list = vim.diagnostic.get(bufnr)
    local diagnostics_results = {}
    for _, diag in ipairs(diagnostics_list) do
        if type(diag.severity) == "number" and diag.severity <= severity then
            table.insert(diagnostics_results)
        end
    end
    table.sort(diagnostics_results, lsp_diagnostic_compare)
end

local M = {
    lsp_diagnostics = lsp_diagnostics,
}

return M
