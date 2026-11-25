ShowcaseRefresh()
local names = {}
for _, c in ipairs({KwikLegacy.panel:GetChildren()}) do if c.record and c:IsShown() then names[#names+1] = c.record.name .. ' = ' .. c.detail:GetText() end end
print('SHOWCASE_OK main rows=' .. #names); for _, n in ipairs(names) do print('ROW ' .. n) end
