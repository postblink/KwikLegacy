SlashCmdList.KWIKLEGACY('rows 8'); SlashCmdList.KWIKLEGACY('earned')
ShowcaseRefresh()
local n = 0
for _, c in ipairs({KwikLegacy.panel:GetChildren()}) do if c.record and c:IsShown() then n = n + 1; print('ROW ' .. c.name:GetText() .. ' = ' .. c.detail:GetText()) end end
print('SHOWCASE_OK more rows=' .. n)
