-- Golang prefers real tab characters
vim.bo['expandtab'] = false

-- Run gofmt on write
vim.api.nvim_create_augroup('GolangConfig', {})
vim.api.nvim_create_autocmd('BufWritePre', {
    pattern = '*.go',
    callback = function ()
        if vim.fn.executable('gofmt') == 1 then
            local view = vim.fn.winsaveview()
            vim.cmd('silent execute ":%!gofmt"')
            if vim.v['shell_error'] > 0 then
                -- If there are errors, put them in the quicklist and undo the formatting
                vim.cmd("cexpr getline(1, '$')->map({ idx, val -> val->substitute('<standard input>', expand('%'), '') })")
                vim.cmd('silent undo')
                vim.cmd('cwindow')
            end
            vim.fn.winrestview(view)
        end
    end,
    group = 'GolangConfig'
})
