local _, Addon = ...

local function clamp(n)
    return math.max(0, math.min(1, n))
end

function Addon.Progress(challenge, context)
    local criteria = challenge.criteria or {}
    local result = {source = 'unknown', missing = {}, remaining = 'Progress unknown'}
    if #criteria > 1 then
        local done, minimum, limiting, allBars = 0, 1, nil, true
        for _, c in ipairs(criteria) do
            if c.completed then done = done + 1 else result.missing[#result.missing + 1] = c.text or '?' end
            if c.bar and type(c.quantity)=='number' and type(c.required)=='number' and c.required>0 then
                local fraction=clamp(c.quantity/c.required)
                if not limiting or fraction<minimum then minimum, limiting=fraction, c end
            else allBars=false end
        end
        if allBars and limiting then
            result.fraction=minimum
            result.units=math.max(0,limiting.required-limiting.quantity)
            result.remaining=limiting.quantity .. '/' .. limiting.required .. ' (lowest)'
        else
            result.fraction = done / #criteria
            result.units = #criteria - done
            result.remaining = done .. '/' .. #criteria
            if #result.missing > 0 and #result.missing <= 2 then
                result.remaining = result.remaining .. ', missing ' .. table.concat(result.missing, ', ')
            elseif #result.missing > 2 then
                result.remaining = result.remaining .. ', ' .. #result.missing .. ' to go'
            end
        end
        result.source = 'criteria'
        return result
    end
    local c = criteria[1]
    if c and c.bar and type(c.quantity) == 'number' and type(c.required) == 'number' and c.required > 0 then
        result.fraction = clamp(c.quantity / c.required)
        result.units = math.max(0, c.required - c.quantity)
        result.remaining = c.quantity .. '/' .. c.required
        result.source = 'criteria'
        return result
    end
    if c and c.completed and #criteria == 1 then
        result.fraction, result.units, result.remaining, result.source = 1, 0, 'Complete', 'criteria'
        return result
    end
    if c and not c.completed and c.text then result.missing[1] = c.text end
    local text = (c and c.text or '') .. ' ' .. (challenge.description or '') .. ' ' .. (challenge.name or '')
    if context.classCategory and challenge.category == context.classCategory
        and type(context.level) == 'number' and context.level > 0 then
        local level = tonumber(text:match('[Ll]evel%s+(%d+)'))
        if level == 25 or level == 45 or level == 60 then
            local value = context.level + ((context.xpMax or 0) > 0 and (context.xp or 0) / context.xpMax or 0)
            result.fraction = clamp(value / level)
            result.units = math.max(0, level - value)
            result.remaining = result.units > 0 and string.format('%.1f levels to go', result.units) or 'Level reached'
            result.source = 'live'
            return result
        end
    end
    local required = tonumber(text:match('(%d%d%d)'))
    if required == 150 or required == 225 or required == 300 then
        local found
        for _, p in ipairs(context.professions or {}) do
            if c and c.assetID and c.assetID ~= 0 and p.skillID == c.assetID then found = p; break end
        end
        if not found then
            for _, p in ipairs(context.professions or {}) do
                if p.name and text:lower():find(p.name:lower(), 1, true) then found = p; break end
            end
        end
        if found and type(found.rank) == 'number' and type(found.maxRank) == 'number' then
            result.fraction = clamp(found.rank / required)
            result.units = math.max(0, required - found.rank)
            result.remaining = math.min(found.rank, required) .. '/' .. required .. ' skill' .. (found.maxRank < required and ' (train next rank)' or '')
            result.source = 'live'
        end
    end
    return result
end

-- Blank unless finishing this challenge grants a new Legacy Point: zero, unknown and
-- already-banked (completed account-wide) challenges show nothing.
function Addon.PointsLabel(points, completed)
    if completed or type(points) ~= 'number' or points <= 0 then return '' end
    if points == 1 then return 'Awards Point' end
    return 'Awards ' .. points .. ' Points'
end

function Addon.Rank(records, showCompleted, showZero, limit)
    local result = {}
    for _, r in ipairs(records) do
        -- Earned by this character: nothing left to do. Earned elsewhere: shown only on request.
        local visible = not r.completed or (showCompleted and r.earnedByMe ~= true)
        if visible and (showZero or r.fraction == nil or r.fraction > 0) then
            result[#result + 1] = r
        end
    end
    table.sort(result, function(a, b)
        if a.fraction == nil then return false end
        if b.fraction == nil then return true end
        if a.fraction ~= b.fraction then return a.fraction > b.fraction end
        return (a.units or math.huge) < (b.units or math.huge)
    end)
    while #result > limit do table.remove(result) end
    return result
end
