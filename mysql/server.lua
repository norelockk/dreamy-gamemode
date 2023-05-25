local MYSQL_HOST = 'localhost'
local MYSQL_PORT = 3306
local MYSQL_DATABASE = 'dreamy_base'
local MYSQL_USERNAME = 'root'
local MYSQL_PASSWORD = ''

local connection = false

local function connect()
  connection = dbConnect(
    'mysql',
    string.format(
      'host=%s;port=%d;dbname=%s;unix_socket=/var/run/mysqld/mysqld.sock;charset=utf8;share=1;',
      MYSQL_HOST,
      MYSQL_PORT,
      MYSQL_DATABASE
    ),
    MYSQL_USERNAME,
    MYSQL_PASSWORD
  )

  if connection then
    print('MySQL connected')
  else
    print('Can\'t connect to MySQL')
  end
end
addEventHandler('onResourceStart', resourceRoot, connect)

function query(...)
  if not connection then return end

  local safe = dbPrepareString(connection, ...)

  if safe then
    local query = dbQuery(connection, safe)
    local result, rows, last_insert = dbPoll(query, -1)

    if not result then
      print(string.format('%s: %s', 'Error while querying', 'mysql', select(1, ...)))
      
      return false
    end

    return result, last_insert, rows
  end
end

function queryFree(...)
  if not connection then return end

  local safe = dbPrepareString(connection, ...)

  if safe then
    local query = dbExec(connection, safe)

    if not query then
      print(string.format('%s: %s', 'Error while free querying', 'mysql', select(1, ...)))

      return false
    end

    return query
  end
end

function queryAsync(trigger, arguments, ...)
  if not connection then return end

  local safe = dbPrepareString(connection, ...)

  if safe then
    local function callback(query, ...)
      local args = {...}

      -- remove the trigger event name from arguments
      local triggerName = args[1]
      table.remove(args, 1)

      -- send response to event
      local result = dbPoll(query, 0)
      if not result then return false end

      triggerEvent(triggerName, root, result, unpack(args))
    end

    local query = dbQuery(callback, {trigger, unpack(arguments)}, connection, safe)
    if not query then
      print(string.format('%s: %s', 'Error while async querying', 'mysql', select(1, ...)))

      return false
    end

    return true
  end
end