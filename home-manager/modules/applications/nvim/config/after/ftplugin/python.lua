-- Helper function
local function reformat (exec_str)
    local view = vim.fn.winsaveview()
    vim.cmd('silent execute "' .. exec_str .. '"')
    if vim.v['shell_error'] > 0 then
        -- If there are errors, put them in the quicklist and undo the formatting
        vim.cmd("cexpr getline(1, '$')->map({ idx, val -> val->substitute('<standard input>', expand('%'), '') })")
        vim.cmd('silent undo')
        vim.cmd('cwindow')
    end
    vim.fn.winrestview(view)
end

vim.api.nvim_create_augroup('PythonConfig', {})
-- Set style settings if necessary
vim.api.nvim_create_autocmd('BufEnter', {
    pattern = '*.py',
    callback = function ()
        -- Use pyformat settings if we're using that
        if vim.fn.executable('pyformat') == 1 then
            local options = {
                shiftwidth = 2,         -- Set indentation depth to 2 columns
                tabstop = 2,            -- Set tabular length to 2 columns
            }
            for k, v in pairs(options) do vim.o[k] = v end
        end
    end,
    group = 'PythonConfig'
})
-- Autoformat on write
vim.api.nvim_create_autocmd('BufWritePre', {
    pattern = '*.py',
    callback = function ()
        -- Use pyformat if present
        if vim.fn.executable('pyformat') == 1 then
            reformat(':%! pyformat')
        -- Fallback on black
        elseif vim.fn.exists('Black') then
            vim.cmd(':Black')
        else
            vim.api.nvim_echo({{"Missing python formatter! Install either pyformat or black via `pip`", "WarningMsg"}}, true, {})
        end
    end,
    group = 'PythonConfig'
})
