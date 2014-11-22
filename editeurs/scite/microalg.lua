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
        props["microalg_path"] = "$(SciteDefaultHome)\\..\\..\\"
end

-- Set some properties (.properties are not used because they need to be in the same dir)
props["lexer.*.malg"] = "script_malg"
-- Styles for the lexer states:
-- NORMAL
props["style.script_malg.0"] = "fore:#000000"
-- TXT
props["style.script_malg.1"] = "fore:#009f00"
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
props["style.script_malg.35"] = "fore:#ff0000,back:#999999"
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
        props["command.go.*.malg"] = "$(microalg_path)/picolisp/pil $(microalg_path)/microalg.l $(FilePath)"
        -- props["command.go.*.malg"] = "$(microalg_path)/ersatz/pilj $(microalg_path)/microalg.l $(FilePath)"
        -- props["command.go.*.malg"] = "$(microalg_path)/emulisp/piljs $(microalg_path)/microalg.l $(FilePath)"
else
        props["command.go.*.malg"] = "$(microalg_path)\\malgj.bat $(FilePath)"
end

-- Definition of the lexer:
function OnStyle(styler)
        if styler.language == 'script_malg' then
                malg_debug("Styling a MicroAlg file...")
        else
                malg_debug("Language: " .. styler.language)
                styler:EndStyling()
                return
        end
        
        -- S: State
        S_NORMAL = 0
        S_TXT = 1
        S_PAREN_base = 10
        
        paren_level = 0
        styler:StartStyling(0, styler.startPos + styler.lengthDoc, styler.initStyle)
        
        while styler:More() do
                -- malg_debug(styler:State())
                
                -- When to get back to S_NORMAL
                if styler:State() >= S_PAREN_base then
                        styler:SetState(S_NORMAL)
                elseif styler:State() == S_TXT then
                        if styler:Match('"') then
                                styler:ForwardSetState(S_NORMAL)
                        else
                                styler:Forward()
                        end
                        
                -- Where to go from S_NORMAL
                elseif styler:State() == S_NORMAL then
                        if styler:Match('"') then
                                styler:SetState(S_TXT)
                        elseif styler:Match('(') then
                                paren_level = (paren_level + 1) % 7
                                styler:SetState(S_PAREN_base + paren_level)
                        elseif styler:Match(')') then
                                styler:SetState(S_PAREN_base + paren_level)
                                paren_level = (paren_level - 1) % 7
                        end
                        styler:Forward()
                end
        end
        styler:EndStyling()
end

