# Support for Tmux using Harpoon 2.0

This is a simple plugin to add support for a `tmux` list in `Harpoon 2.0`. Currently this only supports a subset
of the original Harpoon Version One implementation, and offers some basic configuration options.

**Installation:**

The list is provided via a `build_list` function that can be used within the `harpoon` options. A minimal configuration
using `lazy.nvim` and loading `harpoon-tmux` as a dependency of `ThePrimeagen/harpoon` would look as follows:

```lua
{
    'ThePrimeagen/harpoon',
    dependencies = {
            'nvim-lua/plenary.nvim',
            'atidyshirt/harpoon-tmux',
    },
    branch = 'harpoon2',
    config = function ()
        local harpoon = require('harpoon');
        local harpoon_tmux = require('harpoon-tmux');
        harpoon:setup({ ['tmux'] = harpoon_tmux.build_list() })
    end,
}
```

**Key Bindings:**

Key Bindings that can be setup via the lazy.nvim `config` hook:

```lua
vim.keymap.set("n", "gt", function() harpoon_tmux.go_to_terminal(1) end)
vim.keymap.set("n", "gy", function() harpoon_tmux.go_to_terminal(2) end)
vim.keymap.set("n", "<leader><space>m", function() harpoon.ui:toggle_quick_menu(harpoon:list(tmux_list_name)) end)
vim.keymap.set("n", "<leader><space>j", function() harpoon:list('tmux'):select(1) end)
vim.keymap.set("n", "<leader><space>k", function() harpoon:list('tmux'):select(2) end)
vim.keymap.set("n", "<leader><space>l", function() harpoon:list('tmux'):select(3) end)
vim.keymap.set("n", "<leader><space>;", function() harpoon:list('tmux'):select(4) end)
```
