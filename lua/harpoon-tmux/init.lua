local tmux_api = require('harpoon-tmux.tmux-api');
local utils = require('harpoon-tmux.utils');

local harpoon_tmux_group = vim.api.nvim_create_augroup(
  "HARPOON_TMUX",
  { clear = true }
)

local default_options = {
  tmux_autoclose_windows = true,
  ---@type table<number, { term_index: number, command_index: number }>
  command_terminal_index_allocator = {
    { term_index = 1, cmd_index = 1 },
    { term_index = 1, cmd_index = 2 },
    { term_index = 2, cmd_index = 3 },
    { term_index = 2, cmd_index = 4 },
  }
}

--- @class HarpoonTmux
local harpoon_tmux = {}

harpoon_tmux.go_to_terminal = function (idx)
  local window_handle = tmux_api.find_terminal(idx)
  local _, ret, stderr = utils.get_os_command_output({
    "tmux",
    "select-window",
    "-t",
    window_handle.window_id,
  }, vim.loop.cwd())

  if ret ~= 0 then
    error("Failed to go to terminal." .. stderr[1])
  end
end;

harpoon_tmux.send_command = function (idx, cmd, ...)
  local window_handle = tmux_api.find_terminal(idx)
  if cmd then
    local _, ret, stderr = utils.get_os_command_output({
      "tmux",
      "send-keys",
      "-t",
      window_handle.window_id,
      string.format(cmd .. "\n", ...),
    }, vim.loop.cwd())

    if ret ~= 0 then
      error("Failed to send command. " .. stderr[1])
    end
  end
end;

--- @param options table|nil (Optional) Options for HarpoonTmux.
--- @return table Returns list construction for harpoon
harpoon_tmux.build_list = function (options)
  local merged_opts = setmetatable(options or {}, { __index = default_options })
  harpoon_tmux.options = merged_opts
  if merged_opts.tmux_autoclose_windows then
    vim.api.nvim_create_autocmd("VimLeave", {
      callback = function() tmux_api.clear_all() end,
      group = harpoon_tmux_group,
    })
  end
  return {
    select = function(list_item, list)
      local list_index = utils.get_index_of_string(list_item.value, list);
      if list_index ~= nil then
        local term_index = utils.get_tmux_terminal_index(
          list_index,
          harpoon_tmux.options.command_terminal_index_allocator
        );
        harpoon_tmux.send_command(term_index, list_item.value)
      end
    end
  }
end;

return harpoon_tmux;
