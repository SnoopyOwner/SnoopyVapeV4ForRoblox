local isfile = isfile or function(file)
    local suc, res = pcall(readfile, file)
    return suc and type(res) == "string" and res ~= nil
end

local delfile = delfile or function(file)
    if isfile(file) then
        writefile(file, '') -- Some exploits don't support delfile, so we overwrite instead
    end
end

local function downloadFile(path, func)
    if not isfile(path) then
        local commit = isfile('snoopyvape/profiles/commit.txt') and readfile('snoopyvape/profiles/commit.txt') or 'main'
        local url = 'https://raw.githubusercontent.com/SnoopyOwner/SnoopyVapeV4ForRoblox/' .. commit .. '/' .. path:gsub('snoopyvape/', '')
        
        print("Downloading:", url) -- Debugging print
        local suc, res = pcall(function()
            return game:HttpGet(url, true)
        end)
        
        if not suc or res == '404: Not Found' then
            error("Failed to download " .. path .. " - " .. tostring(res))
        end
        
        if path:find('.lua') then
            res = '--This watermark is used to delete the file if its cached, remove it to make the file persist after vape updates.\n'..res
        end
        
        writefile(path, res)
    end
    return (func or readfile)(path)
end

local function wipeFolder(path)
    if not isfolder(path) then return end
    for _, file in ipairs(listfiles(path)) do
        if file:find('loader') then continue end
        if isfile(file) and readfile(file):find('--This watermark is used to delete the file if its cached') then
            print("Deleting cached file:", file) -- Debugging print
            delfile(file)
        end
    end
end

for _, folder in ipairs({'snoopyvape', 'snoopyvape/games', 'snoopyvape/profiles', 'snoopyvape/assets', 'snoopyvape/libraries', 'snoopyvape/guis'}) do
    if not isfolder(folder) then
        makefolder(folder)
    end
end

if not shared.VapeDeveloper then
    local _, subbed = pcall(function()
        return game:HttpGet('https://github.com/SnoopyOwner/SnoopyVapeV4ForRoblox')
    end)
    
    local commit = subbed and subbed:match('currentOid":"([a-f0-9]+)"') or 'main'
    
    if commit == 'main' or (isfile('snoopyvape/profiles/commit.txt') and readfile('snoopyvape/profiles/commit.txt') ~= commit) then
        wipeFolder('snoopyvape')
        wipeFolder('snoopyvape/games')
        wipeFolder('snoopyvape/guis')
        wipeFolder('snoopyvape/libraries')
    end
    
    writefile('snoopyvape/profiles/commit.txt', commit)
end

return loadstring(downloadFile('snoopyvape/main.lua'), 'main')()
