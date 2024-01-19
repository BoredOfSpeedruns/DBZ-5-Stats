local gameAddresses = {
    HP = 0x501,
    EHP1 = 0x541, 
    EHP2 = 0x551,    
    EHP3 = 0x561,
    EHP4 = 0x571,
    EHP5 = 0x581,
    EHP6 = 0x591,
    CONTINUES = 0xB6,
    LANGUAGE = 0xCB,
}

local eHp_old = {0, 0, 0, 0, 0, 0};
local lastDamage = 0;

local function changeLanguage() 
    -- Hotkey vars
    local checks = 0;
    local keysToCheck = {"J", "K"}
	local keys = input.get()

    -- Check if both keys pressed on same frame
	for i, v in ipairs(keysToCheck) do
		if keys[v] == true and keysPrev[v] ~= true then
			checks = checks + 1;
		end
	end

    -- If both keys pressed change language
    if checks > 1 then
        local lang = memory.read_s8(gameAddresses.LANGUAGE);
        local newVal = 1;
        if lang == 1 then
            newVal = 0;
        end
        memory.write_s8(gameAddresses.LANGUAGE, newVal)
    end
    keysPrev = input.get();
end

local function writeToScreen()
    -- Window vars
    local screenWidth = client.screenwidth();
    local screenHeight = client.screenheight();

    -- Coords vars
    local xCoords = {300, 200, 100, 300, 200, 100};
    local yCoords = {10, 10, 10, 30, 30, 30};
    
    -- Memory Reads
    local myHP = memory.read_s8(gameAddresses.HP);
    local continues = memory.read_s8(gameAddresses.CONTINUES);
    local lang = memory.read_s8(gameAddresses.LANGUAGE);
    local eHp = {
        memory.read_s8(gameAddresses.EHP1),
        memory.read_s8(gameAddresses.EHP2),
        memory.read_s8(gameAddresses.EHP3),
        memory.read_s8(gameAddresses.EHP4),
        memory.read_s8(gameAddresses.EHP5),
        memory.read_s8(gameAddresses.EHP6),
    }

    -- Throwaway vars
    local i = 1;
    local newDamage = 0;

    -- Check Damage and Hp values
    for i, v in ipairs(eHp) do
        if eHp[i] > 0 then
            gui.text(screenWidth - xCoords[i], yCoords[i], "E" .. i .. "HP: " .. eHp[i]);
        end
        if eHp[i] < eHp_old[i] then
            newDamage = newDamage + (eHp_old[i] - eHp[i]);
		end
        eHp_old[i] = eHp[i];
	end

    -- Write HP / Continues to screen.
    gui.text(10,10,"HP: " .. myHP);
    gui.text(10,30,"Continues: " .. continues);

    -- If damage has been done this frame write to screen.
    if newDamage > 0 then
        gui.text(10,50,"Last Dmg: " .. newDamage);
        lastDamage = newDamage;
    else 
        gui.text(10,50,"Last Dmg: " .. lastDamage);
    end

    -- Write language to screen
    local langText = "English (J + K to Toggle)";
    if(lang == 1) then
        langText = "Chinese (J + K to Toggle)";
    end
    gui.text(10, screenHeight - 10, "Language: " .. langText); 
end

memory.usememorydomain("System Bus");

-- Call functions at the start of each frame
event.onframestart(writeToScreen);
event.onframestart(changeLanguage);

while true do
    emu.frameadvance();
end