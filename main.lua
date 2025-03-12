rcBLib = SMODS.current_mod
rcBLib.vars = {
    scoreCaps = {min = 0, max = 1}
}

function rcBLib:blind_active()
    -- borrowed from UnStable (specifically https://github.com/kirbio/UnStable/blob/main/Unstable.lua#L2868C4-L2868C113 )
    return G.hand and not G.blind_select and G.STATE ~= G.STATES.ROUND_EVAL and not G.shop and not G.booster_pack
end

--- @param is_constant boolean
--- @param value number
--- @param length number
function rcBLib:damage_blind(is_constant, value, length)
    if rcBLib:blind_active() then -- blind can't be damaged if there isn't a blind
        SMODS.juice_up_blind()
        G.E_MANAGER:add_event(Event(
            {
                trigger = 'ease',
                delay = length,
                ref_table = G.GAME,
                ref_value = "chips",
                ease_to = G.GAME.chips + (is_constant and value or ((value/100) * G.GAME.blind.chips)),
            }
        ))
    end
end

--- @param center string
--- @param area table e.g. G.jokers or G.consumeables
--- returns `nil` if the given area doesn't have a `cards` entry or is itself nil
function rcBLib:has_item(center, area)
    if area and area.cards then
        for _,v in pairs(area.cards) do
            if v.config.center.key == center then
                return true
            end
        end
        return false
    end
    return nil -- invalid area
end

--- @param min number|nil?
--- @param max number|nil?
--- @param force boolean?
--- `min` and `max` range from 0 to 1<br>
--- `min` and `max` can be `nil` to represent no change
function rcBLib:cap_score(min, max, force)
    if (min) and ((min > rcBLib.vars.scoreCaps.min) or (force)) then
        rcBLib.vars.scoreCaps.min = math.max(0,min)
    end
    if (max) and ((max < rcBLib.vars.scoreCaps.max) or (force)) then
        rcBLib.vars.scoreCaps.max = math.min(max,1)
    end
end

-- COMPAT --

-- CRYPTID --
-- make The Tax work again
if (SMODS.Mods["Cryptid"] or {}).can_load then
    if (SMODS.Blinds.bl_cry_tax) then -- make sure The Tax exists
        SMODS.Blinds.bl_cry_tax.press_play = function(self)
            rcBLib.cap_score(nil, nil, 0.4)
        end
    end
end

-- ORTALAB --
-- make The Fork work again
if (SMODS.Mods["ortalab"] or {}).can_load then
    if (SMODS.Blinds.bl_ortalab_fork) then -- make sure The Fork exists
        SMODS.Blinds.bl_ortalab_fork.press_play = function(self)
            rcBLib.cap_score(nil, nil, 0.5)
        end
    end
end