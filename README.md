# Support for Tmux using Harpoon 2.0

This is a simple plugin to add support for a `tmux` list in `Harpoon 2.0`. Currently this only supports a subset
of the original Harpoon Version One implementation, and offers some basic configuration options.

### Installation

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

### Key Bindings

Key Bindings that can be setup via the lazy.nvim `config` hook:

```lua
vim.keymap.set("n", "gt", function() harpoon_tmux.go_to_terminal(1) end)
vim.keymap.set("n", "gy", function() harpoon_tmux.go_to_terminal(2) end)
vim.keymap.set("n", "<leader><space>m", function() harpoon.ui:toggle_quick_menu(harpoon:list('tmux')) end)
vim.keymap.set("n", "<leader><space>j", function() harpoon:list('tmux'):select(1) end)
vim.keymap.set("n", "<leader><space>k", function() harpoon:list('tmux'):select(2) end)
vim.keymap.set("n", "<leader><space>l", function() harpoon:list('tmux'):select(3) end)
vim.keymap.set("n", "<leader><space>;", function() harpoon:list('tmux'):select(4) end)
```

### Recommended TMUX Configuration

In order for pane indexes to work correctly without bugs, we recommend adding the following lines to your tmux config, as this plugin does not include any way to account for an index being renumbered after `harpoon-tmux` has assigned the index.

```
set -g renumber-windows off
set -g base-index 1
setw -g pane-base-index 1
```

Another recommendation is to bind a method to get back to `neovim` from a `tmux` window. The following binding is an option, (we can bind this to any value we want). `ctrl-o` just allows for me to pretend that `tmux` navigation as part of the jump list for my personal workflow.

The `is_vim` variable is assigned to determine if we are already in a vim shell. If we are already in a vim shell, then we do not want to forward the command to `tmux` and instead provide the base/default `neovim` behaviour of navigating the jump list (This may or may not be required/desirable depending on which key you bind to get back to `neovim`.

```
is_vim="ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"
bind-key -n 'C-o' if-shell "$is_vim" 'send-keys C-o'  'last-window'
```

### Customisation Options

Currently there is just two options for the user to configure. The options that are added in the below code snippet
are the default options provided to `build_list` but can be overwritten with the behaviour your heart desires.

1. Mapping of the command indexes (location in the harpoon command list => `tmux` terminal index to run command in).
2. Auto closing of all tmux windows `harpoon-tmux` knows about (created with `go_to_terminal` when we kill the `neovim` instance.

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
        harpoon:setup({ 
            ['tmux'] = harpoon_tmux.build_list({
                tmux_autoclose_windows = true,
                ---@type table<number, { term_index: number, command_index: number }>
                command_terminal_index_allocator = {
                    { term_index = 1, cmd_index = 1 },
                    { term_index = 1, cmd_index = 2 },
                    { term_index = 2, cmd_index = 3 },
                    { term_index = 2, cmd_index = 4 },
                }
            })
        })
    end,
}
```
