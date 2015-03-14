-- -*- coding: utf-8 -*-

print("Running microalg.lua...")

-- Debug proc:
function malg_debug(str)
        -- print(str)
end

-- Detect the platform:
local uname_s = io.popen("uname -s"):read("*l")
if uname_s == "Linux" then
        malg_debug("MicroAlg: " .. props["microalg_path"])
else
        malg_debug("Windows...")
        props["microalg_path"] = "$(SciteDefaultHome)\\..\\.."
end

-- Set some properties (.properties are not used because they need to be in the same dir)
props["lexer.*.malg"] = "script_malg"
props["lexer.*.l"] = "script_pico"
props["indent.size.*.malg"]="4"
-- Disable diff syntax highlighting in output pane:
-- http://www.scintilla.org/SciTEFAQ.html#OutputColour
props["style.errorlist.11"]="fore:#000000"
props["style.errorlist.12"]="fore:#000000"

-- Styles for the lexer states:
-- NORMAL
props["style.script_malg.0"] = "fore:#000000"
-- TXT
props["style.script_malg.1"] = "fore:#009f00"
-- CMD
props["style.script_malg.2"] = "fore:#00009f"
-- COMZ
props["style.script_malg.3"] = "fore:#999999"
-- Rainbow parens
props["style.script_malg.11"] = "back:#ffaabb"
props["style.script_malg.12"] = "back:#ffddbb"
props["style.script_malg.13"] = "back:#ffffdd"
props["style.script_malg.14"] = "back:#ddffbb"
props["style.script_malg.15"] = "back:#cceeff"
props["style.script_malg.16"] = "back:#ddccff"
props["style.script_malg.10"] = "back:#bbbbee"
-- Paren at current char (OK vs not OK)
props["braces.check"] = "1"
props["style.script_malg.34"] = "fore:#000000,back:#999999"
props["style.script_malg.35"] = "fore:#000000,back:#ff0000"
-- Copy microalg props to picolisp props.
-- NORMAL
props["style.script_pico.0"] = props["style.script_malg.0"]
-- TXT
props["style.script_pico.1"] = props["style.script_malg.1"]
-- CMD
props["style.script_pico.2"] = props["style.script_malg.2"]
-- COMZ
props["style.script_pico.3"] = props["style.script_malg.3"]
-- Rainbow parens
props["style.script_pico.11"] = props["style.script_malg.11"]
props["style.script_pico.12"] = props["style.script_malg.12"]
props["style.script_pico.13"] = props["style.script_malg.13"]
props["style.script_pico.14"] = props["style.script_malg.14"]
props["style.script_pico.15"] = props["style.script_malg.15"]
props["style.script_pico.16"] = props["style.script_malg.16"]
props["style.script_pico.10"] = props["style.script_malg.10"]
-- Paren at current char (OK vs not OK)
props["style.script_pico.34"] = props["style.script_malg.34"]
props["style.script_pico.35"] = props["style.script_malg.34"]
-- Back to MicroAlg
-- Other props
props["api.*.malg"] = "$(microalg_path)/editeurs/scite/malg.api"
props["calltip.script_malg.parameters.start"] = " "
props["calltip.script_malg.parameters.end"] = ":"
props["calltip.script_malg.parameters.separators"] = " "
props["calltip.script_malg.end.definition"] = ":"
props["abbreviations.*.malg"] = "$(microalg_path)/editeurs/scite/malg_abbrev.properties"
-- props["command.help.*.malg"] = ""
-- props["command.help.subsystem.*.malg"] = ""
-- props["command.scite.help"] = ""
-- props["command.scite.help.subsystem"] = ""

-- Configure F5 action
if uname_s == "Linux" then
        -- props["command.go.*.malg"] = "$(microalg_path)/malg $(FilePath)"
        -- props["command.go.*.malg"] = "$(microalg_path)/malg-j $(FilePath)"
        -- props["command.go.*.malg"] = "$(microalg_path)/malg-njs $(FilePath)"
        props["command.go.*.malg"] = "$(microalg_path)/malg-rjs $(FilePath)"
else
        props["command.go.*.malg"] = "$(SciteDefaultHome)\\malgj_scite.bat $(FilePath)"
end

-- Definition of the lexer:
function OnStyle(styler)
        if styler.language == 'script_malg' then
                malg_debug("Styling a MicroAlg file...")
        elseif styler.language == 'script_pico' then
                malg_debug("Styling a PicoLisp file...")
        else
                malg_debug("Language: " .. styler.language)
                styler:EndStyling()
                return
        end
        
        -- S: State
        S_NORMAL = 0
        S_TXT = 1
        S_CMD = 2
        S_COMZ = 3
        S_PAREN_base = 10
        S_PAREN_bad = 35
        
        paren_level = 0
        styler:StartStyling(0, styler.startPos + styler.lengthDoc, styler.initStyle)
        
        styler:SetState(S_NORMAL)
        while styler:More() do
                -- malg_debug(styler:Current() .. " (" .. styler:State() .. ")")
                
                if styler:State() >= S_PAREN_base then  -- also resets S_PAREN_bad
                        styler:SetState(S_NORMAL)
                elseif styler:State() == S_TXT then  -- here we 'forward' (see *)
                        if styler:Match('"') and styler:Previous() ~= '\\' then
                                styler:ForwardSetState(S_NORMAL)
                        else
                                styler:Forward()
                        end
                elseif styler:State() == S_CMD then
                        if styler:Match(' ') or styler:Match(')') then
                                styler:SetState(S_NORMAL)
                        elseif styler:Match('(') then
                                if styler.language == 'script_malg' then
                                        styler:SetState(S_PAREN_bad)
                                elseif styler.language == 'script_pico' then
                                        styler:SetState(S_NORMAL)
                                end
                        end
                elseif styler:State() == S_COMZ then
                        if styler:Match('\n') then
                                styler:SetState(S_NORMAL)
                                styler:Forward()
                        end
                end
                -- Where to go from S_NORMAL
                if styler:State() == S_NORMAL then
                        if styler:Match('"') then
                                styler:SetState(S_TXT)
                                styler:Forward()
                        elseif styler:Match('(') then
                                paren_level = (paren_level + 1) % 7
                                styler:SetState(S_PAREN_base + paren_level)
                                styler:ForwardSetState(S_CMD)
                        elseif styler:Match(')') then
                                old_level = paren_level
                                paren_level = (paren_level - 1) % 7
                                styler:SetState(S_PAREN_base + old_level)
                                styler:Forward()
                        elseif styler.language == 'script_pico' and styler:Match('#') then
                                styler:SetState(S_COMZ)
                                styler:Forward()
                        else
                                styler:Forward()
                        end
                elseif styler:State() ~= S_TXT then  -- * fixes the 'forward' in S_TXT
                        styler:Forward()
                end
        end
        styler:EndStyling()
end

