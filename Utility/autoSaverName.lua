-- This Script automatically adjusts the Filename of all Saver
-- nodes in the current selecion in Fusion to match a certain pattern.
--
-- The name pattern is as follows:
-- basedir/compName/basename/version/compName_basename.suffix
--
-- Note: basename is the name of the respective saver.
--       If no version is given, the version directory will be omitted. 
--
-- Author: Ruben Philipp Gottschalk <me@rubenphilipp.com>
-- Created: 2025-09-27
--
-- $$ Last modified:  17:43:00 Sat Sep 27 2025 CEST


-- Get the active comp
comp = fu:GetCurrentComp()

local slash = "/"
local availableSuffixes = {".mov", ".exr", ".tif", ".jpeg", ".png", ".mp4"}

-- adds a trailing slash to a path if missing
function ensureTrailingSlash(path, slash)
   slash = slash or "/"
   if not path or path == "" then return path end
   local lastChar = path:sub(-1)
   if lastChar ~= slash then
      path = path .. slash
   end
   return path
end

-- get last choices
local lastVersion = comp:GetData("autoSaverName.lastVersion") or ""
local lastSuffix = comp:GetData("autoSaverName.lastSuffix") or 1
local lastBasedir = comp:GetData("autoSaverName.lastBasedir")
   or "comp:/_render/"

-- ask the user for some properties
ret = comp:AskUser("Set Saver Filenames",
                   { { "File Suffix", "Dropdown",
                       Options = availableSuffixes,
                       Default = lastSuffix },
                      { "Base Directory", "Text",
                        Default = lastBasedir, Lines = 1},
                      { "Version", "Text", Default = lastVersion,
                        Lines = 1 } } )



-- only proceed when user data is given
if ret then
   local suffix = availableSuffixes[ret["File Suffix"] + 1]
   -- take only the first lines of Text inputs
   local version = ret["Version"]:match("([^\n]*)")  
   local basedir = ensureTrailingSlash(ret["Base Directory"]:match("([^\n]*)"))
   local compName = comp:GetAttrs().COMPS_Name
   compName = string.gsub(compName, "%.comp$", "")

   local versionChunk = ""
   -- omit version if not given
   if version == "" then
      versionChunk = ""
   else
      versionChunk = version .. slash
   end

   -- Loop over selected nodes
   for _, tool in pairs(comp:GetToolList(true)) do
      -- only proceed for savers
      if tool.ID == "Saver" then
         -- basename is the name of the saver
         local basename = tool.Name

         -- RENAMING PATTERN HERE:
         local outpath = basedir .. compName .. slash .. basename .. slash
            .. versionChunk .. compName .. "_" .. basename .. suffix

         -- edit path
         tool.Clip = outpath

         print("Saver " .. tool.Name .. " now renders to: " .. outpath)
      end
   end

   -- set the lastVersion attribute for the comp to user input
   comp:SetData("autoSaverName.lastVersion", version)
   comp:SetData("autoSaverName.lastSuffix", ret["File Suffix"])
   comp:SetData("autoSaverName.lastBasedir", basedir)
   
end
