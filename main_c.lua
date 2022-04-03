-- If you have any addon flashlight components, you can add the hash of those in this table.
local flashlightHashes = {
    `COMPONENT_AT_AR_FLSH`,
    `COMPONENT_AT_PI_FLSH`,
    `COMPONENT_AT_PI_FLSH_02`,
    `COMPONENT_AT_PI_FLSH_03`
}

-- I guess this function is rather self explanatory.
function CanToggleFlashlight()
    return (not IsPlayerFreeAiming(PlayerId()) and
    not IsControlPressed(0, 24) and
    not IsPedReloading(PlayerPedId()))
end

-- This one should also explain itself! These comments are a breeze.
function HasFlashlight(weapHash)
    if weapHash == `WEAPON_FLASHLIGHT` and GetFollowPedCamViewMode() ~= 4 then
        return true
    end

    for _, v in pairs(flashlightHashes) do
        if HasPedGotWeaponComponent(PlayerPedId(), weapHash, v) then
            return true
        end
    end
    return false
end

CreateThread(function()
    SetFlashLightKeepOnWhileMoving(true) -- Enables persistent flashlights. In reality, everything else is unneeded if you don't want to be able to toggle the flashlight without aiming.
    while true do
        local playerPed = PlayerPedId()
        local _, weapHash = GetCurrentPedWeapon(playerPed)

        -- This fixes the regular flashlight being weird and making noises in first person while not aiming down.
        if IsFlashLightOn(playerPed) and weapHash == `WEAPON_FLASHLIGHT` and GetFollowPedCamViewMode() == 4 and not IsControlPressed(0, 25) then
            SetFlashLightEnabled(playerPed, false)
        end

        if IsControlJustPressed(0, 54) and CanToggleFlashlight() then
            if HasFlashlight(weapHash) then
                if IsFlashLightOn(playerPed) then
                    --[[
                    Either something is wrong with the SetFlashLightEnabled native or I'm dumb and don't know how it works.
                    Anyways, setting current weapon to unarmed and back quickly seems to turns it off (as usual).
                    The only downside is the fact that the ammo hud in the top right flashes a bit when turning off.
                    ]]
                    SetCurrentPedWeapon(playerPed, `WEAPON_UNARMED`, true)
                    SetCurrentPedWeapon(playerPed, weapHash, true)

                    --[[
                    This native call is needed because fuck knows. Without it the flashlight doesn't turn off, even if weapons have been switched. Again, I'm probably doing something wrong,
                    but I am too lazy to research further..

                    What was that about the comments being a breeze again?
                    ]]
                    SetFlashLightEnabled(playerPed, false)
                else
                    SetFlashLightEnabled(playerPed, true)
                end

                PlaySoundFrontend(-1, "COMPUTERS_MOUSE_CLICK", 0, 1) -- Sounds are fun!
            end
        end
        Wait(0)
    end
end)