OLD_CONFIGS = "old"
WINDOWS_CONFIGS = {
    ".emacs.local",
    ".emacs.rc",
    ".emacs.snippets",
    '.emacs',
    ".emacs.custom.el",
    ".gitconfig",
    ".gitignore",
--     ".vimrc",
}
WINDOWS = 1
LINUX = 0

debug = 0

local system;
local separator = package.config:sub(1,1)
if separator == "/" then
    print("OC: Unix/Linux/macOS")
    system = LINUX
    elseif separator == "\\" then
        print("OC: Windows")
        system = WINDOWS
end

function debugPrint(...)
    if debug == 1 then
        print(...)
    end
end
function pushFiles()
    if (system == WINDOWS) then
        for i=1, #WINDOWS_CONFIGS do
            local item = WINDOWS_CONFIGS[i]
            local powershell = 'powershell -c "Copy-Item -Force -Recurse -ErrorAction SilentlyContinue -Path ' .. item .. ' -Destination $env:USERPROFILE"'
            debugPrint("[pushFiles] Command: ", powershell)
            local success, exit_type, exit_code = os.execute(powershell)
            debugPrint("[pushFiles] Status command: ", success)
            debugPrint("[pushFiles] Exit type: ", exit_type)
            debugPrint("[pushFiles] Exit code: ", exit_code)
        end
    end
end

function split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end
function deleteFiles()
    if (system == WINDOWS) then
        local handle = io.popen('powershell -c "Get-ChildItem -Path ' .. OLD_CONFIGS .. ' | ForEach-Object { $_.Name } | Out-String"')
        local output = handle:read("*a")
        handle:close()
        local files_from_old = split(output, "\n")
        debugPrint("[deleteFiles] Files in old dir: ", table.concat(files_from_old, ", "))

        local env_dirs = {
            "$env:USERPROFILE",
            "$env:APPDATA"
        }
        for j=1, #env_dirs do
            for i=1, #files_from_old do
                local file = files_from_old[i]
                if file ~= "" then
                    local target = env_dirs[j] .. "\\" .. file
                    local cmd = 'powershell -c "Remove-Item -Force -Recurse -ErrorAction SilentlyContinue -Path ' .. target .. '"'
                    debugPrint("[deleteFiles] Command: ", cmd)
                    local success, exit_type, exit_code = os.execute(cmd)
                    debugPrint("[deleteFiles] Deleted: ", target, " | success: ", success)
                end
            end
        end
    end
end

function printHelp()
    print("---HELP---")
    print("-help -h - print info about program")
    print("-clear -cl - remove all configs and plugins")
    print("-debug -d  - debug mode")
    print("-force -f - delete old files and push newer")
end

if (#arg < 1) then
    pushFiles()
end
for i=1,#arg do
    if (arg[i] == "-debug" or arg[i] == "-d") then
        debug = 1
    end
    debugPrint("Flag: ", arg[i])

    if (arg[i] == "-help" or arg[i] == "-h") then
        printHelp()
        return
    end


    if (arg[i] == "-clear" or arg[i] == "-cl") then
        print("clearing...")
        deleteFiles()
        return
    end

    if(arg[i] == "-force" or arg[i] == "-f") then
        print("Deleting the old config and push newer")
        deleteFiles()
        pushFiles()
        return
    end
end

