---- Battle Fury curing and utility system for Lusternia.
---- (c) 2014 Martin Tee. All rights reserved.


---- Initialisation.

bf = {}
tmp = {}
usr = {}

sep = package.config:sub(1, 1)



---- Core functions

function run_lua(arg)
	local a, b = loadstring("return "..arg)
	if not a then
		a, b = assert(loadstring(arg))
	end

	local r = a()
	if r ~= nil then display(r) end
end


---- Module loading/unloading.

-- Define system modules.

local modules = {
	"api",
	"affs",
	"cure",
	"defs",
	"_gmcp",
	"track",
	"pdb",
	"queue",
	"timing",
	"ui"
}


local function load_modules()
        local path = package.path
        local cpath = package.cpath
        local homedir = getMudletHomeDir()
        local luadir = string.format("%s/%s", homedir, [[?.lua]])
        local initdir = string.format("%s/%s", homedir, [[?/init.lua]])
        local sysdir = string.format("%s/%s", getMudletHomeDir() .. sep .. "battlefury" .. sep .. "system", [[?.lua]])
        package.path = string.format("%s;%s;%s;%s", path, luadir, initdir, sysdir)
        package.cpath = string.format("%s;%s;%s;%s", cpath, luadir, initdir, sysdir)

        local m = { "api", "affs", "cure", "defs", "_gmcp", "track", "pdb", "queue", "timing", "ui" }
        for _, n in ipairs(m) do
                local s, c = pcall(require, n)
                if not s then display(c) echo("Failed to load module: " .. n .. ".lua. Please contact support.") end
                _G[n] = c
        end

        package.path = path
        package.cpath = cpath
end

function reload_modules()
        local m = { "api", "affs", "cure", "defs", "_gmcp", "track", "pdb", "queue", "timing", "ui" }
        echo("Reinitialising Lua package 'Battle Fury'...")
        --resetProfile() - Todo. This function really should have the option to raise an event after successful execution.
        send("\n")
        package.loaded.battlefury = nil
        echo("Performing live update.")
        echo("Unloading modules...")

        for _, n in ipairs(m) do
                package.loaded[n] = nil
                _G[n] = nil
        end

        echo("Reloading system now...")

        load_modules()
end

function get_modules()
        local exceptions = {
                "string",
                "package",
                "_G",
                "os",
                "table",
                "math",
                "coroutine",
                "luasql",
                "debug",
                "rex_pcre",
                "lfs",
                "io",
                "luasql.sqlite3",
                "gmod",
                "zip",
                "socket"
        }

        local modules = {}

        for m in pairs(package.loaded) do
                if not table.contains(exceptions, m) then
                        table.insert(modules, m)
                end
        end

        return modules
end

function check_module(name)
        return package.loaded[name] and true or false
end