local Job = require("plenary.job")

return {
  get_os_command_output = function (cmd, cwd)
    if type(cmd) ~= "table" then
      return {}
    end
    local command = table.remove(cmd, 1)
    local stderr = {}
    local stdout, ret = Job:new({
      command = command,
      args = cmd,
      cwd = cwd,
      on_stderr = function(_, data)
        table.insert(stderr, data)
      end,
    }):sync()
    return stdout, ret, stderr
  end;

  split_string = function (str, delimiter)
    local result = {}
    for match in (str .. delimiter):gmatch("(.-)" .. delimiter) do
      table.insert(result, match)
    end
    return result
  end;

  get_index_of_string = function (seach_string, command_list)
    for index, value in pairs(command_list.items) do
      if value.value == seach_string then
        return index;
      end
    end
    return nil;
  end;

  ---@param cmd_index: number
  ---@param lookup_table: table<number, { term_index: number, cmd_index: number }>
  ---@return number Returns terminal index from lookup table
  get_tmux_terminal_index = function(cmd_index, lookup_table)
    for _, value in pairs(lookup_table) do
      if value.cmd_index == cmd_index then
        return value.term_index
      end
    end
    error("Command index not found in the lookup table")
  end
}
