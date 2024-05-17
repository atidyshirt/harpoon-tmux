local utils = require('harpoon-tmux.utils');

local tmux_api = {}
local tmux_windows = {}

tmux_api.create_terminal = function ()
  local window_id
  local out, ret, _ = utils.get_os_command_output({
    "tmux",
    "new-window",
    "-P",
    "-F",
    "#{pane_id}",
  }, vim.loop.cwd())
  if ret == 0 then
    window_id = out[1]:sub(2)
  end
  if window_id == nil then
    return nil
  end
  return window_id
end;

tmux_api.terminal_exists = function(window_id)
  local exists = false
  local window_list, _, _ = utils.get_os_command_output({
    "tmux",
    "list-windows",
  }, vim.loop.cwd())
  for _, line in pairs(window_list) do
    local window_info = utils.split_string(line, "@")[2]
    if string.find(window_info, string.sub(window_id, 2)) then
      exists = true
    end
  end
  return exists
end;

tmux_api.find_terminal = function (args)
  if type(args) == "number" then
    args = { idx = args }
  end

  local window_handle = tmux_windows[args.idx]
  local window_exists

  if window_handle then
    window_exists = tmux_api.terminal_exists(window_handle.window_id)
  end

  if not window_handle or not window_exists then
    local window_id = tmux_api.create_terminal()
    if window_id == nil then
      error("Failed to find and create tmux window.")
      return
    end
    window_handle = {
      window_id = "%" .. window_id,
    }
    tmux_windows[args.idx] = window_handle
  end
  return window_handle
end;

tmux_api.clear_all = function ()
  for _, window in pairs(tmux_windows) do
    utils.get_os_command_output({
      "tmux",
      "kill-window",
      "-t",
      window.window_id,
    }, vim.loop.cwd())
  end
  tmux_windows = {}
end;

return tmux_api;
