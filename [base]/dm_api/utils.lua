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