

local SG = game:GetService("StarterGui")
local tries = 5

repeat
    local success, err = pcall(function()
        SG:SetCoreGuiEnabled("All", false) 
    end)
    tries += tries

until success or tries == 5
