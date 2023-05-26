function validateEmail(str)
  if str == nil or str:len() == 0 then
    return nil
  end

  local lastAt = str:find("[^%@]+$")
  local localPart = str:sub(1, (lastAt - 2))
  local domainPart = str:sub(lastAt, #str)

  if localPart == nil then
    return false
  end
  if domainPart == nil or not domainPart:find("%.") then
    return false
  end
  if string.sub(domainPart, 1, 1) == "." then
    return false
  end
  if #localPart > 64 then
    return false
  end
  if #domainPart > 253 then
    return false
  end
  if lastAt >= 65 then
    return false
  end

  local quotes = localPart:find("[\"]")

  if type(quotes) == 'number' and quotes > 1 then
    return false
  end
  if localPart:find("%@+") and quotes == nil then
    return false
  end
  if not domainPart:find("%.") then
    return false
  end
  if domainPart:find("%.%.") then
    return false
  end
  if localPart:find("%.%.") then
    return false
  end
  if not str:match('[%w]*[%p]*%@+[%w]*[%.]?[%w]*') then
    return false
  end

  return true
end

function string.checkLen(text, minLen, maxLen)
  if string.len(text) >= minLen and string.len(text) <= maxLen then
    return true
  else
    return false
  end
end

function switch(element)
  local Table = {
    ["Value"] = element,
    ["DefaultFunction"] = nil,
    ["Functions"] = {}
  }

  Table.case = function(testElement, callback)
    Table.Functions[testElement] = callback
    return Table
  end

  Table.default = function(callback)
    Table.DefaultFunction = callback
    return Table
  end

  Table.process = function()
    local Case = Table.Functions[Table.Value]
    if Case then
      Case()
    elseif Table.DefaultFunction then
      Table.DefaultFunction()
    end
  end

  return Table
end

local function ascii_base(s)
  return s:lower() == s and ("a"):byte() or ("A"):byte()
end

local function caesar_cipher(str, key)
  return (str:gsub("%a", function(s)
    local base = ascii_base(s)
    return string.char(((s:byte() - base + key) % 26) + base)
  end))
end

function rot13_cipher(str)
  return caesar_cipher(str, 13)
end

function rot13_decipher(str)
  return caesar_cipher(str, -13)
end