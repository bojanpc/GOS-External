local Heroes = {"Ezreal"}

require "DamageLib"

local castSpell = {state = 0, tick = GetTickCount(), casting = GetTickCount() - 1000, mouse = mousePos}
local barHeight = 8
local barWidth = 103
local barXOffset = 24
local barYOffset = -8
local Version,Author,LVersion = "v1.0.1","Kypos","8.1"

keybindings = { [ITEM_1] = HK_ITEM_1, [ITEM_2] = HK_ITEM_2, [ITEM_3] = HK_ITEM_3, [ITEM_4] = HK_ITEM_4, [ITEM_5] = HK_ITEM_5, [ITEM_6] = HK_ITEM_6}

if FileExist(COMMON_PATH .. "TPred.lua") then
	require 'TPred'
	PrintChat("TPred library loaded")
elseif FileExist(COMMON_PATH .. "Collision.lua") then
	require 'Collision'
	PrintChat("Collision library loaded")
end

function SetMovement(bool)
	if _G.EOWLoaded then
		EOW:SetMovements(bool)
		EOW:SetAttacks(bool)
	elseif _G.SDK then
		_G.SDK.Orbwalker:SetMovement(bool)
		_G.SDK.Orbwalker:SetAttack(bool)
	else
		GOS.BlockMovement = not bool
		GOS.BlockAttack = not bool
	end
	if bool then
		castSpell.state = 0
	end
end

---------------------------------------------------------------------------------------
-- EZREAL
---------------------------------------------------------------------------------------

class "Ezreal"

local HeroIcon = "https://vignette.wikia.nocookie.net/leagueoflegends/images/e/e7/Arcade_Ezreal_profileicon.png"
local Minion = "https://vignette.wikia.nocookie.net/leagueoflegends/images/e/eb/Purple_Melee_Minion_profileicon.png"
local QIcon = "https://vignette.wikia.nocookie.net/leagueoflegends/images/5/5a/Mystic_Shot.png"
local WIcon = "https://vignette.wikia.nocookie.net/leagueoflegends/images/9/9e/Essence_Flux.png"
local EIcon = "https://vignette.wikia.nocookie.net/leagueoflegends/images/f/fb/Arcane_Shift.png"
local RIcon = "https://vignette.wikia.nocookie.net/leagueoflegends/images/0/02/Trueshot_Barrage.png"

function Ezreal:LoadSpells()

	Q = {Range = 1150, Width = 80, Delay = 0.25, Speed = 1200, Collision = true, aoe = false, Type = "line"}
	W = {Range = 1000, Width = 80, Delay = 0.25, Speed = 1200, Collision = false, aoe = false, Type = "line"}
	E = {Range = 475, Delay = 0.25}
	R = {Range = 2000, Width = 160, Delay = 1.35, Speed = 2000, Collision = false, aoe = false, Type = "line"}

end

function Ezreal:LoadMenu()
	self.Menu = MenuElement({type = MENU, id = "Ezreal", name = "Kypo's Ezreal", leftIcon = HeroIcon})
	self.Menu:MenuElement({id = "Combo", name = "Combo", type = MENU})
	self.Menu.Combo:MenuElement({id = "UseQ", name = "Q", value = true, leftIcon = QIcon})
	self.Menu.Combo:MenuElement({id = "UseW", name = "W", value = true, leftIcon = WIcon})
	self.Menu.Combo:MenuElement({id = "UseE", name = "E", value = false, leftIcon = EIcon})
	self.Menu.Combo:MenuElement({id = "comboActive", name = "Combo key", key = string.byte(" ")})
		
	self.Menu:MenuElement({id = "Harass", name = "Harass", type = MENU})
	self.Menu.Harass:MenuElement({id = "UseQ", name = "Q", value = true, leftIcon = QIcon})
	self.Menu.Harass:MenuElement({id = "UseW", name = "W", value = true, leftIcon = WIcon})
	self.Menu.Harass:MenuElement({id = "harassActive", name = "Harass key", key = string.byte("V")})

	self.Menu:MenuElement({id = "Clear", name = "Clear", type = MENU})
	self.Menu.Clear:MenuElement({id = "UseQ", name = "Q", value = true, leftIcon = QIcon})
	self.Menu.Clear:MenuElement({id = "clearActive", name = "Clear key", key = string.byte("C")})
	
	self.Menu:MenuElement({id = "Lasthit", name = "Lasthit", type = MENU})
	self.Menu.Lasthit:MenuElement({id = "UseQ", name = "Q", value = true, leftIcon = QIcon})
	self.Menu.Lasthit:MenuElement({id = "lasthitActive", name = "Lasthit key", key = string.byte("X")})
	
	self.Menu:MenuElement({id = "Killsteal", name = "Killsteal", type = MENU})
	self.Menu.Killsteal:MenuElement({id = "UseQ", name = "Q", value = true, leftIcon = QIcon})
	self.Menu.Killsteal:MenuElement({id = "UseW", name = "W", value = true, leftIcon = WIcon})
	self.Menu.Killsteal:MenuElement({id = "RCConly", name = "R KS CC", value = true, type = MENU, leftIcon = RIcon})
	for i, hero in pairs(self:GetEnemyHeroes()) do
	self.Menu.Killsteal.RCConly:MenuElement({id = "UseR"..hero.charName, name = "Use R on: "..hero.charName, value = true, leftIcon = RIcon})
	end
	self.Menu.Killsteal:MenuElement({id = "RR", name = "R KS Normal (Prediction)", value = true, type = MENU, leftIcon = RIcon})
	for i, hero in pairs(self:GetEnemyHeroes()) do
	self.Menu.Killsteal.RR:MenuElement({id = "UseR"..hero.charName, name = "Use R on: "..hero.charName, value = true, leftIcon = RIcon})
	end
	self.Menu.Killsteal:MenuElement({id = "blank", type = SPACE , name = ""})
	self.Menu.Killsteal:MenuElement({id = "blank", type = SPACE , name = "When the game starts, wait 30 secs and reload"})
	self.Menu.Killsteal:MenuElement({id = "blank", type = SPACE , name = "EXT so it can actually load the enemies here."})

	self.Menu:MenuElement({id = "isCC", name = "CC Settings", type = MENU})
	self.Menu.isCC:MenuElement({id = "UseQ", name = "Q", value = true, leftIcon = QIcon})
	self.Menu.isCC:MenuElement({id = "UseW", name = "W", value = true, leftIcon = WIcon})
	self.Menu.isCC:MenuElement({id = "blank", type = SPACE , name = "Will use Spell on:"})
	self.Menu.isCC:MenuElement({id = "blank", type = SPACE , name = "Stun, Snare, Taunt, Charm, Knockup..etc"})

	
	self.Menu:MenuElement({id = "Drawings", name = "Drawings", type = MENU})
	--Q
	self.Menu.Drawings:MenuElement({id = "Q", name = "Draw Q range", type = MENU, leftIcon = QIcon})
    self.Menu.Drawings.Q:MenuElement({id = "Enabled", name = "Enabled", value = true})       
    self.Menu.Drawings.Q:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
    self.Menu.Drawings.Q:MenuElement({id = "Color", name = "Color", color = Draw.Color(200, 255, 255, 255)})
	--W
	self.Menu.Drawings:MenuElement({id = "W", name = "Draw W range", type = MENU, leftIcon = WIcon})
    self.Menu.Drawings.W:MenuElement({id = "Enabled", name = "Enabled", value = true})       
    self.Menu.Drawings.W:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
    self.Menu.Drawings.W:MenuElement({id = "Color", name = "Color", color = Draw.Color(200, 255, 255, 255)})
	--E
	self.Menu.Drawings:MenuElement({id = "E", name = "Draw E range", type = MENU, leftIcon = EIcon})
    self.Menu.Drawings.E:MenuElement({id = "Enabled", name = "Enabled", value = true})       
    self.Menu.Drawings.E:MenuElement({id = "Width", name = "Width", value = 1, min = 1, max = 5, step = 1})
    self.Menu.Drawings.E:MenuElement({id = "Color", name = "Color", color = Draw.Color(200, 255, 255, 255)})
	
	self.Menu.Drawings:MenuElement({id = "DrawDamage", name = "Draw damage on HPbar", value = true})
    self.Menu.Drawings:MenuElement({id = "HPColor", name = "HP Color", color = Draw.Color(200, 255, 255, 255)})
	
	self.Menu:MenuElement({id = "CustomSpellCast", name = "Use custom spellcast", tooltip = "Can fix some casting problems with wrong directions", value = true})
	self.Menu:MenuElement({id = "delay", name = "Custom spellcast delay", value = 100, min = 0, max = 200, step = 5,tooltip = "increase this one if spells is going completely wrong direction", identifier = ""})
	
	self.Menu:MenuElement({id = "blank", type = SPACE , name = ""})
	self.Menu:MenuElement({id = "blank", type = SPACE , name = "Script Ver: "..Version.. " - LoL Ver: "..LVersion.. ""})
	self.Menu:MenuElement({id = "blank", type = SPACE , name = "by "..Author.. ""})
end


function Ezreal:__init()
	
	self:LoadSpells()
	self:LoadMenu()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
	local orbwalkername = ""
	if _G.SDK then
		orbwalkername = "IC'S orbwalker"		
	elseif _G.EOW then
		orbwalkername = "EOW"	
	elseif _G.GOS then
		orbwalkername = "Noddy orbwalker"
	else
		orbwalkername = "Orbwalker not found"
	end
end

function CurrentTarget(range)
	if _G.SDK then
		return _G.SDK.TargetSelector:GetTarget(range, _G.SDK.DAMAGE_TYPE_PHYSICAL);
	elseif _G.EOW then
		return _G.EOW:GetTarget(range)
	else
		return _G.GOS:GetTarget(range,"AD")
	end
end

function GetInventorySlotItem(itemID)
		assert(type(itemID) == "number", "GetInventorySlotItem: wrong argument types (<number> expected)")
		for _, j in pairs({ ITEM_1, ITEM_2, ITEM_3, ITEM_4, ITEM_5, ITEM_6}) do
			if myHero:GetItemData(j).itemID == itemID and myHero:GetSpellData(j).currentCd == 0 then return j end
		end
		return nil
	    end

function IsRecalling()
	for K, Buff in pairs(GetBuffs(myHero)) do
		if Buff.name == "recall" and Buff.duration > 0 then
			return true
		end
	end
	return false
end

function ValidTarget(target, range)
	range = range and range or math.huge
	return target ~= nil and target.valid and target.visible and not target.dead and target.distance <= range
end

function Ezreal:Tick()
    if myHero.dead or Game.IsChatOpen() == true or IsRecalling() == true then return end
	if self.Menu.Harass.harassActive:Value() then
		self:Harass()
	end
	if self.Menu.Combo.comboActive:Value() then
		self:Combo()
	end
	if self.Menu.Clear.clearActive:Value() then
		self:Clear()
	end
	if self.Menu.Lasthit.lasthitActive:Value() then
		self:Lasthit()
	end
		self:KillstealQ()
		self:KillstealR()
		self:SpellonCCW()
		self:SpellonCCQ()
		self:RksCC()
end

function Ezreal:HasBuff(unit, buffname)
	for i = 0, unit.buffCount do
		local buff = unit:GetBuff(i)
		if buff.name == buffname and buff.count > 0 then 
			return true
		end
	end
	return false
end

function Ezreal:GetValidMinion(range)
    	for i = 1,Game.MinionCount() do
        local minion = Game.Minion(i)
        if  minion.team ~= myHero.team and minion.valid and minion.pos:DistanceTo(myHero.pos) < 1150 then
        return true
        end
    	end
    	return false
end

function GetPercentHP(unit)
	if type(unit) ~= "userdata" then error("{GetPercentHP}: bad argument #1 (userdata expected, got "..type(unit)..")") end
	return 100*unit.health/unit.maxHealth
end

function Ezreal:IsReady(spell)
	return Game.CanUseSpell(spell) == 0
end

function Ezreal:CheckMana(spellSlot)
	return myHero:GetSpellData(spellSlot).mana < myHero.mana
end

function Ezreal:CanCast(spellSlot)
	return self:IsReady(spellSlot) and self:CheckMana(spellSlot)
end

function EnableMovement()
	SetMovement(true)
end

function ReturnCursor(pos)
	Control.SetCursorPos(pos)
	DelayAction(EnableMovement,0.1)
end

function LeftClick(pos)
	Control.mouse_event(MOUSEEVENTF_LEFTDOWN)
	Control.mouse_event(MOUSEEVENTF_LEFTUP)
	DelayAction(ReturnCursor,0.05,{pos})
end

function Ezreal:GetValidMinion(range)
    	for i = 1,Game.MinionCount() do
        local minion = Game.Minion(i)
        if  minion.team ~= myHero.team and minion.valid and minion.pos:DistanceTo(myHero.pos) < 650 then
        return true
        end
    	end
    	return false
end

function Ezreal:GetEnemyHeroes()
	self.EnemyHeroes = {}
	for i = 1, Game.HeroCount() do
		local Hero = Game.Hero(i)
		if Hero.isEnemy then
			table.insert(self.EnemyHeroes, Hero)
		end
	end
	return self.EnemyHeroes
end

function Ezreal:EnemyInRange(range)
	local count = 0
	for i, target in ipairs(self:GetEnemyHeroes()) do
		if target.pos:DistanceTo(myHero.pos) < range then 
			count = count + 1
		end
	end
	return count
end

-----------------------------
-- DRAWINGS
-----------------------------

function Ezreal:Draw()
if self.Menu.Drawings.Q.Enabled:Value() then Draw.Circle(myHero.pos, 1150, self.Menu.Drawings.Q.Width:Value(), self.Menu.Drawings.Q.Color:Value()) end
if self.Menu.Drawings.W.Enabled:Value() then Draw.Circle(myHero.pos, 1000, self.Menu.Drawings.W.Width:Value(), self.Menu.Drawings.W.Color:Value()) end
if self.Menu.Drawings.E.Enabled:Value() then Draw.Circle(myHero.pos, 475, self.Menu.Drawings.E.Width:Value(), self.Menu.Drawings.E.Color:Value()) end
			if self.Menu.Drawings.DrawDamage:Value() then
		for i, hero in pairs(self:GetEnemyHeroes()) do
			local barPos = hero.hpBar
			if not hero.dead and hero.pos2D.onScreen and barPos.onScreen and hero.visible then
				local QDamage = (self:CanCast(_Q) and getdmg("Q",hero,myHero) or 0)
				local WDamage = (self:CanCast(_W) and getdmg("W",hero,myHero) or 0)
				local EDamage = (self:CanCast(_E) and getdmg("E",hero,myHero) or 0)
				local RDamage = (self:CanCast(_R) and getdmg("R",hero,myHero) or 0)
				local damage = QDamage + WDamage + EDamage + RDamage
				if damage > hero.health then
					Draw.Text("killable", 24, hero.pos2D.x, hero.pos2D.y,Draw.Color(0xFF00FF00))
					
				else
					local percentHealthAfterDamage = math.max(0, hero.health - damage) / hero.maxHealth
					local xPosEnd = barPos.x + barXOffset + barWidth * hero.health/hero.maxHealth
					local xPosStart = barPos.x + barXOffset + percentHealthAfterDamage * 100
					Draw.Line(xPosStart, barPos.y + barYOffset, xPosEnd, barPos.y + barYOffset, 10, self.Menu.Drawings.HPColor:Value())
				end
			end
		end	
	end
    if self:CanCast(_Q) then
			local target = CurrentTarget(Q.Range)
			if target == nil then return end
			local temppred
			local collisionc = Q.ignorecol and 0 or Q.minionCollisionWidth
			
			if (TPred) then
				local castpos,HitChance, pos = TPred:GetBestCastPosition(target, Q.Delay , Q.Width, Q.Range,Q.Speed, myHero.pos, not Q.ignorecol, Q.Type )
				Draw.Circle(castpos, 60, 3, Draw.Color(200, 255, 255, 255))
			end
		end
		if self:CanCast(_W) then
			local target = CurrentTarget(W.Range)
			if target == nil then return end
			local temppred
			if (TPred) then
				local castpos,HitChance, pos = TPred:GetBestCastPosition(target, W.Delay , W.Width, W.Range,W.Speed, myHero.pos, W.ignorecol, W.Type )
			end
		end
		if self:CanCast(_R) then
			local target = CurrentTarget(R.Range)
			if target == nil then return end
			local temppred
			if (TPred) then
				local castpos,HitChance, pos = TPred:GetBestCastPosition(target, R.Delay , R.Width, R.Range,R.Speed, myHero.pos, R.ignorecol, R.Type )
			end
		end
end

function Ezreal:CastSpell(spell,pos)
	local customcast = self.Menu.CustomSpellCast:Value()
	if not customcast then
		Control.CastSpell(spell, pos)
		return
	else
		local delay = self.Menu.delay:Value()
		local ticker = GetTickCount()
		if castSpell.state == 0 and ticker > castSpell.casting then
			castSpell.state = 1
			castSpell.mouse = mousePos
			castSpell.tick = ticker
			if ticker - castSpell.tick < Game.Latency() then
				SetMovement(false)
				Control.SetCursorPos(pos)
				Control.KeyDown(spell)
				Control.KeyUp(spell)
				DelayAction(LeftClick,delay/1000,{castSpell.mouse})
				castSpell.casting = ticker + 500
			end
		end
	end
end

function Ezreal:HpPred(unit, delay)
	if _G.GOS then
	hp =  GOS:HP_Pred(unit,delay)
	else
	hp = unit.health
	end
	return hp
end

-----------------------------
-- BUFFS
-----------------------------

function Ezreal:IsImmobileTarget(unit)
		if unit == nil then return false end
		for i = 0, unit.buffCount do
			local buff = unit:GetBuff(i)
			if buff and (buff.type == 5 or buff.type == 11 or buff.type == 29 or buff.type == 24) and buff.count > 0 then
				return true
			end
		end
		return false	
	end

-----------------------------
-- COMBO
-----------------------------

function Ezreal:Combo()
    local target = CurrentTarget(Q.Range)
    if target == nil then return end
    if self.Menu.Combo.UseQ:Value() and target and self:CanCast(_Q) then
	    if self:EnemyInRange(Q.Range) then
		    local castpos,HitChance, pos = TPred:GetBestCastPosition(target, Q.Delay , Q.Width, Q.Range, Q.Speed, myHero.pos, not Q.ignorecol, Q.Type )
		    if (HitChance > 0 ) then
				Control.CastSpell(HK_Q, castpos) 
		    end
	    end
    end

	if self.Menu.Combo.UseW:Value() and target and self:CanCast(_W) then
		if self:EnemyInRange(W.Range) then 
			local castpos,HitChance, pos = TPred:GetBestCastPosition(target, W.Delay , W.Width, W.Range,W.Speed, myHero.pos, W.ignorecol, W.Type )
		    if (HitChance > 0 ) and self:CanCast(_W) then
			Control.CastSpell(HK_W, castpos)
            end
		end
	end
 
    local target = CurrentTarget(500)
    if target == nil then return end
	if self.Menu.Combo.UseE:Value() and target and self:CanCast(_E) then
		if self:EnemyInRange(500) then
			Control.CastSpell(HK_E, mousePos)
		end
	end
end

-----------------------------
-- HARASS
-----------------------------

function Ezreal:Harass()
    local target = CurrentTarget(1150)
    if target == nil then return end
    if self.Menu.Harass.UseQ:Value() and target and self:CanCast(_Q) then
	    if self:EnemyInRange(Q.Range) then
		    local castpos,HitChance, pos = TPred:GetBestCastPosition(target, Q.Delay , Q.Width, Q.Range, Q.Speed, myHero.pos, not Q.ignorecol, Q.Type )
		    if (HitChance > 0 ) then
			    Control.CastSpell(HK_Q,castpos)
		    end
	    end
    end

	if self.Menu.Harass.UseW:Value() and target and self:CanCast(_W) then
		if self:EnemyInRange(W.Range) then 
			local castpos,HitChance, pos = TPred:GetBestCastPosition(target, W.Delay , W.Width, W.Range,W.Speed, myHero.pos, W.ignorecol, W.Type )
		    if (HitChance > 0 ) and self:CanCast(_W) then
			    Control.CastSpell(HK_W,castpos)
            end
		end
	end

end
-----------------------------
-- Clear
-----------------------------

function Ezreal:Clear()
	for i = 1, Game.MinionCount() do
	local minion = Game.Minion(i)
	if minion and minion.team == 300 or minion.team ~= myHero.team then
		if self:CanCast(_Q) then 
			if self.Menu.Clear.UseQ:Value() and minion then
				if ValidTarget(minion, 1150) and myHero.pos:DistanceTo(minion.pos) < 1150 and not minion.dead then
					Control.CastSpell(HK_Q, minion)
					end
				end
			end
		end
	end
end

-----------------------------
-- LASTHIT
-----------------------------

function Ezreal:Lasthit()
	if self:CanCast(_Q) then
		local level = myHero:GetSpellData(_Q).level	
  		for i = 1, Game.MinionCount() do
			local minion = Game.Minion(i)
			local Qdamage = (({40, 55, 75, 95, 115})[level] + 1.1 * myHero.totalDamage)
		    local castpos,HitChance, pos = TPred:GetBestCastPosition(minion, Q.Delay , Q.Width, Q.Range, Q.Speed, myHero.pos, not Q.ignorecol, Q.Type )
			if myHero.pos:DistanceTo(minion.pos) < 1150 and self.Menu.Lasthit.UseQ:Value() and minion.isEnemy and not minion.dead then
				if Qdamage >= self:HpPred(minion,1) and (HitChance > 0 ) then
			    Control.CastSpell(HK_Q,castpos)
				end
			end
		end
	end
end

-----------------------------
-- KILLSTEAL
-----------------------------

function Ezreal:QDMG()
    local level = myHero:GetSpellData(_Q).level
    local qdamage = (({40, 55, 75, 95, 115})[level] + 1.1 * myHero.totalDamage)
	return qdamage
end

function Ezreal:WDMG()
    local level = myHero:GetSpellData(_W).level
    local wdamage = (({70, 115, 160, 205, 250})[level] + 0.8 * myHero.ap)
	return wdamage
end

function Ezreal:RDMG()
    local level = myHero:GetSpellData(_R).level
    local rdamage = (({200, 250, 300})[level] + 1.0 * myHero.totalDamage + 0.90 * myHero.ap)
	return rdamage
end

function Ezreal:IsValidTarget(unit,range) 
	return unit ~= nil and unit.valid and unit.visible and not unit.dead and unit.isTargetable and not unit.isImmortal and unit.pos:DistanceTo(myHero.pos) <= 3340 
end

function Ezreal:KillstealQ()
-----------------------------
-- Q KS
-----------------------------

	local target = CurrentTarget(Q.Range)
	if target == nil then return end
	if self.Menu.Killsteal.UseQ:Value() and target and self:CanCast(_Q) then
		if self:EnemyInRange(Q.Range) then 
			local level = myHero:GetSpellData(_Q).level	
			local castpos,HitChance, pos = TPred:GetBestCastPosition(target, Q.Delay , Q.Width, Q.Range,Q.Speed, myHero.pos, not Q.ignorecol, Q.Type )
		   	local Qdamage = Ezreal:QDMG()
			if Qdamage >= self:HpPred(target,1) + target.hpRegen * 1 then
			if (HitChance > 0 ) and self:CanCast(_Q) then
			    Control.CastSpell(HK_Q,castpos)
				end
			end
		end
	end
end

-----------------------------
-- W KS
-----------------------------

function Ezreal:KillstealW()
    local target = CurrentTarget(W.Range)
	if target == nil then return end
	if self.Menu.Killsteal.UseW:Value() and target and self:CanCast(_W) then
		if self:EnemyInRange(W.Range) then 
			local level = myHero:GetSpellData(_W).level	
			local castpos,HitChance, pos = TPred:GetBestCastPosition(target, W.Delay , W.Width, W.Range,W.Speed, myHero.pos, W.ignorecol, W.Type )
		   	local Wdamage = Ezreal:WDMG()
			if Wdamage >= self:HpPred(target,1) + target.hpRegen * 1 then
			if (HitChance > 0 ) and self:CanCast(_W) and target  then
			    Control.CastSpell(HK_W,castpos)
				end
			end
		end
	end
end

-----------------------------
-- R KS
-----------------------------

function Ezreal:KillstealR()
    local target = CurrentTarget(2000)
	if target == nil then return end
	if self.Menu.Killsteal.RR["UseR"..target.charName]:Value() and self:CanCast(_R) then
		if self:EnemyInRange(2000) then 
			local level = myHero:GetSpellData(_R).level	
			local castpos,HitChance, pos = TPred:GetBestCastPosition(target, R.Delay , R.Width, R.Range,R.Speed, myHero.pos, R.ignorecol, R.Type )
		   	local Rdamage = Ezreal:RDMG()
			if Rdamage >= self:HpPred(target,1) + target.hpRegen * 2 then
			if (HitChance > 0 ) and target and self:CanCast(_R) then
			    Control.CastSpell(HK_R,castpos)
				end
			end
		end
	end
end

-----------------------------
-- W Spell on CC
-----------------------------

function Ezreal:SpellonCCW()
    local target = CurrentTarget(1000)
	if target == nil then return end
	if self.Menu.isCC.UseW:Value() and target and self:CanCast(_W) then
	if self:EnemyInRange(1000) then 
	local ImmobileEnemy = self:IsImmobileTarget(target)
			local level = myHero:GetSpellData(_W).level	
			local castpos,HitChance, pos = TPred:GetBestCastPosition(target, W.Delay , W.Width, W.Range,W.Speed, myHero.pos, W.ignorecol, W.Type )
			if ImmobileEnemy then
			if (HitChance > 0 ) then
			    Control.CastSpell(HK_W,castpos)
				end
			end
		end
	end
end

-----------------------------
-- Q Spell on CC
-----------------------------

function Ezreal:SpellonCCQ()
    local target = CurrentTarget(1150)
	if target == nil then return end
	if self.Menu.isCC.UseQ:Value() and target and self:CanCast(_Q) then
		if self:EnemyInRange(1150) then 
			local ImmobileEnemy = self:IsImmobileTarget(target)
			local level = myHero:GetSpellData(_Q).level	
			local castpos,HitChance, pos = TPred:GetBestCastPosition(target, Q.Delay , Q.Width, Q.Range,Q.Speed, myHero.pos, not Q.ignorecol, Q.Type )
			if ImmobileEnemy then
			if (HitChance > 0 ) then
			    Control.CastSpell(HK_Q,castpos)
				end
			end
		end
	end
end

-----------------------------
-- R KS on CC
-----------------------------

function Ezreal:RksCC()
    local target = CurrentTarget(1500)
	if target == nil then return end
	if self.Menu.Killsteal.RCConly["UseR"..target.charName]:Value() and target and self:CanCast(_R) then
		if self:EnemyInRange(1500) then 
			local ImmobileEnemy = self:IsImmobileTarget(target)
			local level = myHero:GetSpellData(_R).level	
			local castpos,HitChance, pos = TPred:GetBestCastPosition(target, R.Delay , R.Width, R.Range,R.Speed, myHero.pos, R.ignorecol, R.Type )
		 	local Rdamage = Ezreal:RDMG()
			if Rdamage >= self:HpPred(target,1) + target.hpRegen * 1 then
			if ImmobileEnemy then
			if (HitChance > 0 ) then
			    Control.CastSpell(HK_R,castpos)
				end
			end
		end
	end
end
end

Callback.Add("Load",function() _G[myHero.charName]() end)