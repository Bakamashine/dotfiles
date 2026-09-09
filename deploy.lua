OLD_CONFIGS = "old"
WINDOWS_CONFIGS = {
    ".emacs.local",
    ".emacs.rc",
    ".emacs.snippets",
    '.emacs',
    ".emacs.custom.el",
    ".gitconfig",
    ".gitignore",
    ".vimrc",
}
WINDOWS = 1
LINUX = 0

DEBUG = 1

local system;
local separator = package.config:sub(1,1)
if separator == "/" then
    print("OC: Unix/Linux/macOS")
    system = LINUX
    elseif separator == "\\" then
        print("OC: Windows")
        system = WINDOWS
end

function debugPrint(text)
    if DEBUG == 1 then
        print(text)
    end
end
function pushFiles()
    if (system == WINDOWS) then
        local powershell = "powershell -c Copy-Item "
        -- building command
        for i=1, #WINDOWS_CONFIGS do
            if (#WINDOWS_CONFIGS-1 == i) then
                powershell = powershell .. WINDOWS_CONFIGS[i]
                break
            end
            powershell = powershell .. WINDOWS_CONFIGS[i] .. ","

        end

        debugPrint("[pushFiles] Command: ",powershell)
        local success, exit_type, exit_code = os.execute(powershell .. "-Force -Recurse")
        debugPrint("[pushFiles] Status command: ", success)
        debugPrint("[pushFiles] Exit type: ", exit_type)
        debugPrint("[pushFiles] Exit code: ", exit_code)

        -- linux is not support at the moment (maybe in future..)
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
        local env_dirs = {
            "$env:HOME",
            "$env:APPDATA"
        }
        for j=1, #env_dirs do
            local success, exit_type, exit_code = os.execute("Get-ChildItem -File | ForEach-Object { $_.Name } | Join-String -Separator \" \"")
            local files_from_old_dir = split(success, " ")

            local powershell = "powershell -c Remove-Item -Force -Recurse "
            for i=1, #WINDOWS_CONFIGS do
                powershell = powershell .. WINDOWS_CONFIGS[i] .. ","
            end
            for i=1, #files_from_old_dir do
                if (#files_from_old_dir-1 == i) then
                    powershell = powershell .. " " .. env_dirs[j] ..  " " .. files_from_old_dir
                end
                powershell = powershell .. " " .. env_dirs[j] ..  " " .. files_from_old_dir[i] .. ","

        end
            debugPrint("[deleteFiles] Command: ", powershell)
            local success, exit_type, exit_code = os.execute(powershell)
            debugPrint("[deleteFiles] Status command: ", success)
            debugPrint("[deleteFiles] Exit type: ", exit_type)
            debugPrint("[deleteFiles] Exit code: ", exit_code)
        end

    end
end

pushFiles()
function printHelp()
    print("---HELP---")
    print("help - print info about program")
    print("clear - remove all configs and plugins")
    print("debug - debug mode")
end
-- local success, exit_type, exit_code = os.execute("echo Hello")
for i=1,#arg do

    if (arg[i] == "help" or arg[i] == "h") then
        printHelp()
        return
    end
    if (arg[i] == "debug") then
        DEBUG = 1
    end

    if (arg[i] == "clear" or arg[i] == "cl") then
        print("clearing...")
        deleteFiles()
        return
    end

    if(arg[i] == "force" or arg[i] == "f") then
        print("Deleting the old config and push newer")

    end


    pushFiles()
end
