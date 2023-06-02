local GAMEMODE_INFO = {
  NAME = "DREAMY ROLEPLAY",
  VERSION = "1.0",
  PRODUCTION = false
}

function Check(funcname, ...)
  local arg = {...}

  if (type(funcname) ~= "string") then
    error("Argument type mismatch at 'Check' ('funcname'). Expected 'string', got '" .. type(funcname) .. "'.", 2)
  end
  if (#arg % 3 > 0) then
    error("Argument number mismatch at 'Check'. Expected #arg % 3 to be 0, but it is " .. (#arg % 3) .. ".", 2)
  end

  for i = 1, #arg - 2, 3 do
    if (type(arg[i]) ~= "string" and type(arg[i]) ~= "table") then
      error("Argument type mismatch at 'Check' (arg #" .. i .. "). Expected 'string' or 'table', got '" .. type(arg[i]) .. "'.", 2)
    elseif (type(arg[i + 2]) ~= "string") then
      error("Argument type mismatch at 'Check' (arg #" .. (i + 2) .. "). Expected 'string', got '" .. type(arg[i + 2]) .. "'.", 2)
    end

    if (type(arg[i]) == "table") then
      local aType = type(arg[i + 1])
      for _, pType in next, arg[i] do
        if (aType == pType) then
          aType = nil
          break
        end
      end
      if (aType) then
        error("Argument type mismatch at '" .. funcname .. "' ('" .. arg[i + 2] .. "'). Expected '" .. table.concat(arg[i], "' or '") .. "', got '" .. aType .. "'.", 3)
      end
    elseif (type(arg[i + 1]) ~= arg[i]) then
      error("Argument type mismatch at '" .. funcname .. "' ('" .. arg[i + 2] .. "'). Expected '" .. arg[i] .. "', got '" .. type(arg[i + 1]) .. "'.", 3)
    end
  end
end

local gWeekDays = {"niedziela", "poniedziałek", "wtorek", "środa", "czwartek", "piątek", "sobota"}
function formatDate(format, escaper, timestamp)
  Check("formatDate", "string", format, "format", {"nil", "string"}, escaper, "escaper", {"nil", "string"}, timestamp, "timestamp")

  escaper = (escaper or "'"):sub(1, 1)
  local time = getRealTime(timestamp)
  local formattedDate = ""
  local escaped = false

  time.year = time.year + 1900
  time.month = time.month + 1

  local datetime = {
    d = ("%02d"):format(time.monthday),
    h = ("%02d"):format(time.hour),
    i = ("%02d"):format(time.minute),
    m = ("%02d"):format(time.month),
    s = ("%02d"):format(time.second),
    w = gWeekDays[time.weekday + 1]:sub(1, 2),
    W = gWeekDays[time.weekday + 1],
    y = tostring(time.year):sub(-2),
    Y = time.year
  }

  for char in format:gmatch(".") do
    if (char == escaper) then
      escaped = not escaped
    else
      formattedDate = formattedDate .. (not escaped and datetime[char] or char)
    end
  end

  return formattedDate
end

function getGamemodeInfo()
  return GAMEMODE_INFO
end