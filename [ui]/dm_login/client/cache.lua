function saveLoginData(username, password)
  local xml = xmlCreateFile(string.format('%s.xml', md5('dreamy_login_data')), 'data')
  if not xml then return false end

  xmlNodeSetValue(xmlCreateChild(xml, rot13_cipher('username')), username)
  xmlNodeSetValue(xmlCreateChild(xml, rot13_cipher('password')), base64Encode(rot13_cipher(password)))

  xmlSaveFile(xml)
  xmlUnloadFile(xml)

  return true
end

function loadLoginData(callback)
  if not callback or not type(callback) == 'function' then return false end

  local xml = xmlLoadFile(string.format('%s.xml', md5('dreamy_login_data')))
  if not xml then
    saveLoginData('', '')

    return callback(false)
  end

  local usernameNode = xmlFindChild(xml, rot13_cipher('username'), 0)
  local username = xmlNodeGetValue(usernameNode)

  local passwordNode = xmlFindChild(xml, rot13_cipher('password'), 0)
  local password = xmlNodeGetValue(passwordNode)

  if username:len() < 0 or password:len() < 0 then
    xmlUnloadFile(xml)

    return callback(false)
  end

  password = rot13_decipher(base64Decode(password))

  callback({ username = username, password = password })
  xmlUnloadFile(xml)
end