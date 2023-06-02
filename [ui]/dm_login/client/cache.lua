function saveLoginData(username, password)
  local xml = xmlCreateFile(string.format('%s.xml', md5('dreamy_login_data')), rot13_cipher('dreamy_data'))
  if not xml then return false end

  xmlNodeSetValue(xmlCreateChild(xml, rot13_cipher('username')), username)
  xmlNodeSetValue(xmlCreateChild(xml, rot13_cipher('password')), base64Encode(rot13_cipher(password or '')))

  xmlSaveFile(xml)
  xmlUnloadFile(xml)

  return true
end

function loadLoginData(callback)
  if not callback or not type(callback) == 'function' then return false end

  local xml = xmlLoadFile(string.format('%s.xml', md5('dreamy_login_data')))
  if not xml then
    saveLoginData('', '')

    return callback({ remember = false, username = '', password = '' })
  end

  local usernameNode = xmlFindChild(xml, rot13_cipher('username'), 0)
  local username = xmlNodeGetValue(usernameNode)

  local passwordNode = xmlFindChild(xml, rot13_cipher('password'), 0)
  local password = xmlNodeGetValue(passwordNode)

  if string.len(username) == 0 or string.len(password) == 0 then
    xmlUnloadFile(xml)

    return callback({ remember = false, username = '', password = '' })
  end

  password = rot13_decipher(base64Decode(password))

  callback({ remember = true, username = username, password = password })
  xmlUnloadFile(xml)
end