local settings = {
    noCompile = {
        ['ipb'] = true,
        ['ajax'] = true,
        ['play'] = true,
        ['admin'] = true,
        ['acpanel'] = true,
        ['runcode'] = true,
        ['freeroam'] = true,
        ['compiler'] = true
    }
}

function compile()
    for i, v in pairs(getResources()) do
        local resName = getResourceName(v)

        if not settings.noCompile[resName] then
            compileResource(v, resName, getFolderForResource(resName))
        end
    end
end
addCommandHandler('compile', compile)

function getFolderForResource(resName)
    if string.find(resName, 'dm_map') then return '[maps]/' end
    return ''
end

function compileResource(res, resName, folder)
    if not folder then return end
    if settings.noCompile[resName] then return end

    local xml = xmlLoadFile(string.format(':%s/meta.xml', resName))
    if not xml then return end

    local resourceDirectory = string.format(':%s/', resName)
    local newResourceDirectory = string.format('deploy/%s%s/', folder, resName)

    local nodes = xmlNodeGetChildren(xml)
    for i, v in pairs(nodes) do
        local nodeName = xmlNodeGetName(v)

        if nodeName == 'script' then
            local fileDir = xmlNodeGetAttribute(v, 'src')
            local type = xmlNodeGetAttribute(v, 'type')

            if type == 'client' or type == 'shared' then
                local fileName = split(fileDir, '/')
                compileFile(fileName[#fileName], string.format('%s%s', resourceDirectory, fileDir), string.format('%s%s', newResourceDirectory, fileDir), resName)
            else
                fileCopy(string.format('%s/%s', resourceDirectory, fileDir), string.format('%s/%s', newResourceDirectory, fileDir), true)
            end

        elseif nodeName == 'file' then
            local fileDir = xmlNodeGetAttribute(v, 'src')
            local fileName = split(fileDir, '/')
            fileCopy(string.format('%s/%s', resourceDirectory, fileDir), string.format('%s/%s', newResourceDirectory, fileDir), true)

            outputDebugString(string.format('[Compiler] Copying file %s from %s', fileName[#fileName], resName), 0, 0, 140, 255)

        elseif nodeName == 'map' then
            local fileDir = xmlNodeGetAttribute(v, 'src')
            local fileName = split(fileDir, '/')
            fileCopy(string.format('%s/%s', resourceDirectory, fileDir), string.format('%s/%s', newResourceDirectory, fileDir), true)

            outputDebugString(string.format('[Compiler] Copying file %s from %s', fileName[#fileName], resName), 0, 0, 140, 255)
        end
    end
    xmlUnloadFile(xml)

    fileCopy(string.format('%smeta.xml', resourceDirectory), string.format('%smeta.xml', newResourceDirectory), true)
    outputDebugString(string.format('[Compiler] Copying file meta.xml from %s', resName), 0, 0, 140, 255)

    changeMetaLuac(string.format('%smeta.xml', newResourceDirectory), resName)
end

function changeMetaLuac(dir, resName)
    local xml = xmlLoadFile(dir)
    if not xml then outputDebugString(string.format('[Compiler] Cant open meta.xml file from %s', resName), 1) return end

    local nodes = xmlNodeGetChildren(xml)
    for i, v in pairs(nodes) do
        local nodeName = xmlNodeGetName(v)
        if nodeName == 'script' then
            local type = xmlNodeGetAttribute(v, 'type')

            if type == 'client' or type == 'shared' then
                local atribute = xmlNodeGetAttribute(v, 'src')
                xmlNodeSetAttribute(v, 'src', atribute..'c')
            end
        end
    end

    outputDebugString(string.format('[Compiler] Rebuilded file meta.xml from %s', resName), 0, 250, 220, 20)
    xmlSaveFile(xml)
    xmlUnloadFile(xml)
end

function compileFile(fileName, fileDir, fileNewDir, resName)
    local file = fileOpen(fileDir)

    fetchRemote('https://luac.mtasa.com/index.php?compile=1&debug=0&obfuscate=3', function(data, err)
        if fileExists(fileNewDir..'c') then fileDelete(fileNewDir..'c') end
        local newscriptFile = fileCreate(fileNewDir..'c')
        if newscriptFile then
            fileWrite(newscriptFile, data)
            fileFlush(newscriptFile)
            fileClose(newscriptFile)

            outputDebugString(string.format('[Compiler] Compiled file %s from %s', fileName, resName))
        end
    end, fileRead(file, fileGetSize(file)), true)

    fileClose(file)
end