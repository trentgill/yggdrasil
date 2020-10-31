fn = {}

function fn.init()
  fn.id_prefix = "ygg-"
  fn.id_counter = 1000
end

function fn.id()
  fn.id_counter = fn.id_counter + 1
  return fn.id_prefix .. os.time(os.date("!*t")) .. "-" .. fn.id_counter
end

function fn.dirty_screen(bool)
  if bool == nil then return y.screen_dirty end
  y.screen_dirty = bool
  return y.screen_dirty
end

function fn.break_splash(bool)
  if bool == nil then return y.splash_break end
  y.splash_break = bool
  return y.splash_break
end

function fn.dismiss_messages()
  tracker:clear_message()
  fn.break_splash(true)
end

function fn.split_semicolon(input)
  local result = {
    valid = false,
    payload = {}
  }
  for s in (input .. ";"):gmatch("([^;]*);") do 
    result.payload[#result.payload + 1] = s
  end
  if #result.payload > 1 then
    result.valid = true
  end
  return result
end

function fn.split_symbol(input, symbol)
  local result = {
    valid = false,
    payload = {}
  }
  if string.sub(input, 1, 1) == symbol then result.valid = true end
  result.payload[1] = symbol
  result.payload[2] = tonumber(string.sub(input, 2))
  return result
end

function fn.validate_prefix_invocation(branch)
  local result = false
  for k, v in pairs(commands:get_prefixes()) do
    if string.find(branch.leaves[1], v) then
      result = true
    end
  end
  return result
end

function fn.validate_string_invocation(branch, invocation)
  return #branch.leaves == 1
    and type(branch.leaves[1]) == "string"
    and branch.leaves[1] == invocation
end

function fn.validate_simple_invocation(branch, invocation)
  return #branch.leaves == 3
    and branch.leaves[1] == invocation
    and branch.leaves[2] == ";"
    and fn.is_number(branch.leaves[3])
end

-- #2     "validate_prefix_invocation"
-- play   "validate_string_invocation"
-- vel;3  "validate_simple_invocation"
function fn.is_invocation_match(branch, invocations)
  local result = false
  for k, invocation in pairs(invocations) do
    local is_prefix_invocation = fn.validate_prefix_invocation(branch)
    local is_string_invocation = fn.validate_string_invocation(branch, invocation)
    local is_simple_invocation = fn.validate_simple_invocation(branch, invocation)
    if is_prefix_invocation or is_string_invocation or is_simple_invocation then
      result = true
    end
  end
  return result
end

-- function fn.is_depth_command(input)
--   return fn.validate_simple_command(input, "depth")
-- end

-- function fn.is_shift_command(input)
--   return fn.validate_simple_command(input, "shift")
-- end

-- function fn.is_velocity_command(input)
--   return fn.validate_simple_command(input, "vel")
-- end

-- function fn.is_transpose_command(input)
--   return fn.validate_simple_command(input, "t")
-- end



-- function fn.extract(attribute, input)
--   local result = fn.split_semicolon(input)
--   if attribute == "depth" and fn.is_depth_command(input) then
--     return tonumber(result.payload[2])
--   end
--   if attribute == "tranpose" and fn.is_transpose_command(input) then
--     return tonumber(result.payload[2])
--   end
--   if attribute == "velocity" and fn.is_velocity_command(input) then
--     return tonumber(result.payload[2])
--   end
--   if attribute == "shift" and fn.is_shift_command(input) then
--     return tonumber(result.payload[2])
--   end
-- end

function fn.shift_table(t, shift_amount)
  if shift_amount == 0 then return t end
  for i = 1, shift_amount do
    local last_value = t[#t]
    table.insert(t, 1, last_value)
    table.remove(t, #t)
  end
  return t
end

function fn.reverse_shift_table(t, shift_amount)
  if shift_amount == 0 then return t end
  for i = 1, shift_amount do
    local first_value = t[1]
    table.remove(t, 1)
    table.insert(t, #t + 1, first_value)
  end
  return t
end

function fn.deep_copy(orig)
  local orig_type = type(orig)
  local copy
  if orig_type == "table" then
    copy = {}
    for orig_key, orig_value in next, orig, nil do
        copy[fn.deep_copy(orig_key)] = fn.deep_copy(orig_value)
    end
    setmetatable(copy, fn.deep_copy(getmetatable(orig)))
  else -- number, string, boolean, etc
    copy = orig
  end
  return copy
end

function fn.table_contains(t, check)
  for k, v in pairs(t) do
    if v == check then
      return true
    end
  end
  return false
end

function fn.table_contains_key(t, check)
  local keys = {}
  for k, v in pairs(t) do
    table.insert(keys, k)
  end
  return fn.table_contains(keys, check)
end

function fn.pairs_by_keys(t)
  local a = {}
  for n in pairs(t) do
    table.insert(a, n)
  end
  table.sort(a)
  local i = 0
  local iterator = function()
    i = i + 1
    if a[i] == nil then
      return nil
    else 
      return a[i], t[a[i]]
    end
  end
  return iterator
end

function fn.cycle(value, min, max)
  if value > max then
    return min
  elseif value < min then
    return max
  else
    return value
  end
end

function fn.is_int(test)
  if test == nil then return false end
  if not tonumber(test) then return false end
  return test == math.floor(test)
end

function fn.is_number(test)
  if test == nil then return false end
  return type(tonumber(test)) == "number"
end

function fn.is_space(test)
  if test == nil then return false end
  return test == " "
end

function fn.string_split(input_string, split_character)
  local s = split_character ~= nil and split_character or "%s"
  local t = {}
  if split_character == "" then
    for str in string.gmatch(input_string, ".") do
      table.insert(t, str)
    end
  else
    for str in string.gmatch(input_string, "([^" .. s .. "]+)") do
      table.insert(t, str)
    end
  end
  return t
end

function fn.draw_oblique()
  tracker:set_message(docs:draw_oblique())
end

function fn.screenshot()
  local which_screen = string.match(string.match(string.match(norns.state.script,"/home/we/dust/code/(.*)"),"/(.*)"),"(.+).lua")
  _norns.screen_export_png("/home/we/dust/" .. which_screen .. "-" .. os.time() .. ".png")
end

function fn.rerun()
  norns.script.load(norns.state.script)
end



-- dev

function print_matron_message(message)
  print("") print("") print("")      
  print(message)
  print("") print("") print("")
end

function rerun()
  fn.rerun()
end

function cmd(s)
  local t = fn.string_split(s, "")
  for k, v in pairs(t) do
    buffer:add(v)
  end
  buffer:execute()
end

function s(x, y)
  return tracker:get_track(x):get_slot(y)
end

function t(x)
  return tracker:get_track(x)
end

function debug_semiotic(semiotic)
  if config.settings.debug_semiotic then
    print("semiotic ### ")
    tabutil.print(semiotic)
    print("split --- ")
    tabutil.print(semiotic.split)
    print("#branches --- ")
    print(#semiotic.branches)
    print("branches --- ")
    for k, v in pairs(semiotic.branches) do
      print("branch", k)
      for kk, vv in pairs(v.leaves) do
        print("leaf", kk, vv)
      end
    end
    print("payload --- ")
    tabutil.print(semiotic.payload)
  end
end

return fn