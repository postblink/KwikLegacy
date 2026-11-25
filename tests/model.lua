local addon = {}
assert(loadfile('Model.lua'))('KwikLegacy', addon)
local function eq(a,b) assert(a==b, tostring(a)..' ~= '..tostring(b)) end
local ctx = {classCategory=1, level=43, xp=60, xpMax=100, professions={{skillID=197,name='Tailoring',rank=225,maxRank=225}}}
local r = addon.Progress({criteria={{text='A', completed=true},{text='B', completed=true},
    {text='C', completed=true},{text='D', completed=true},{text='E', completed=true},
    {text='Shadowfang Keep', completed=false}}}, ctx)
eq(r.fraction,5/6); eq(r.missing[1],'Shadowfang Keep'); eq(#r.missing,1); eq(r.remaining,'5/6, missing Shadowfang Keep')
r = addon.Progress({criteria={{text='A', completed=true},{text='B'},{text='C'},{text='D'}}}, ctx); eq(r.remaining,'1/4, 3 to go')
r=addon.Progress({criteria={{bar=true,quantity=5,required=10}}},ctx); eq(r.fraction,0.5)
r=addon.Progress({criteria={{bar=true,quantity=8,required=10},{bar=true,quantity=2,required=10}}},ctx); eq(r.fraction,0.2)
r=addon.Progress({category=1,description='Reach level 45'},ctx); assert(math.abs(r.units-1.4)<0.001); eq(r.source,'live')
r=addon.Progress({category=2,description='Reach level 45'},ctx); eq(r.source,'unknown')
r=addon.Progress({category=1,description='Reach level 45'},{classCategory=1,level=0}); eq(r.source,'unknown')
r=addon.Progress({criteria={{text='Tailoring 300',assetID=197}}},ctx); eq(r.fraction,0.75); assert(r.remaining:find('train next rank',1,true))
r=addon.Progress({name='Tailoring',description='Reach 300 skill'},ctx); eq(r.fraction,0.75)
local list={{id=1,fraction=.8,units=4},{id=2,fraction=.8,units=2},{id=3},{id=4,fraction=0},{id=5,fraction=1,completed=true}}
local a=addon.Rank(list,false,false,10); eq(#a,3); eq(a[1].id,2); eq(a[2].id,1); eq(a[3].id,3)
a=addon.Rank(list,true,false,10); eq(a[1].id,5)
a=addon.Rank({{id=3},{id=1,fraction=.8}},false,false,10); eq(a[1].id,1); eq(a[2].id,3)
eq(addon.PointsLabel(1),'  |  Awards Point'); eq(addon.PointsLabel(2),'  |  Awards 2 Points')
eq(addon.PointsLabel(0),''); eq(addon.PointsLabel(nil),''); eq(addon.PointsLabel(1,true),'')
print('model: PASS')
