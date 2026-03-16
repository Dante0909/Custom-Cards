--Prince of Endymion
--Scripted by Dante
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	c:EnableCounterPermit(COUNTER_SPELL,LOCATION_PZONE|LOCATION_MZONE)
	Pendulum.AddProcedure(c,false)
	Fusion.AddProcMixN(c,false,false,s.matfilter,5)
	Fusion.AddContactProc(c, s.contactfil,s.contactop,false,nil,1)
	
	--only special once through its own effect
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(s.regcon)
	e0:SetOperation(s.regop)
	c:RegisterEffect(e0)
	
	--destroy st on summon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.destroytg)
	e1:SetOperation(s.destroyop)
	c:RegisterEffect(e1)
	
	--cannot target
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	
	--place in pendulum zone
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(s.pencon)
	e3:SetTarget(s.pentg)
	e3:SetOperation(s.penop)
	e3:SetCountLimit(1,{id,1})
	c:RegisterEffect(e3)
	
	--activation
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_INACTIVATE)
	e4:SetRange(LOCATION_PZONE)
	e4:SetValue(s.effectfilter)
	c:RegisterEffect(e4)
	
	--effect
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_DISEFFECT)
	e5:SetRange(LOCATION_PZONE)
	e5:SetValue(s.effectfilter)
	c:RegisterEffect(e5)
	
	--cannot disable effect on field
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD)
	e7:SetCode(EFFECT_CANNOT_DISABLE)
	e5:SetRange(LOCATION_PZONE)
	e7:SetTargetRange(0,LOCATION_ONFIELD)
	e7:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e7:SetTarget(s.indtg)
	Duel.RegisterEffect(e7,0)
	
	local e8=Effect.CreateEffect(c)
	e8:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e8:SetType(EFFECT_TYPE_IGNITION)
	e8:SetRange(LOCATION_PZONE)
	e8:SetCountLimit(1,{id,2})
	e8:SetTarget(s.searchtg)
	e8:SetOperation(s.searchop)
	c:RegisterEffect(e8)
	
end

s.counter_place_list={COUNTER_SPELL}
s.listed_series={SET_ENDYMION}

function s.regcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL+1)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE|PHASE_END)
	e1:SetTarget(s.splimit)
	Duel.RegisterEffect(e1,tp)
end

function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsCode(id) and sumtype&SUMMON_TYPE_SPECIAL+1==SUMMON_TYPE_SPECIAL+1
end

function s.matfilter(c)
	return (c:IsSpellCard() or c:IsLocation(LOCATION_PZONE)) and c:IsAbleToRemoveAsCost()
end

function s.contactfil(tp)
	return Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_ONFIELD|LOCATION_GRAVE|LOCATION_HAND,0,nil)
end

function s.contactop(g)
	Duel.Remove(g,POS_FACEUP,REASON_COST|REASON_MATERIAL)
end

function s.destroyfilter(c)
	return c:IsSpell()
end

function s.destroytg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return
		Duel.IsExistingMatchingCard(s.destroyfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	local g=Duel.GetMatchingGroup(s.destroyfilter,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end

function s.destroyop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.destroyfilter, tp,0,LOCATION_ONFIELD,nil)
	local oc=Duel.Destroy(g,REASON_EFFECT)
	local c=e:GetHandler()
	if oc>0 then c:AddCounter(COUNTER_SPELL,oc) end
end

function s.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_MZONE)
end

function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckPendulumZones(tp) end
end

function s.penop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.CheckPendulumZones(tp) then return false end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end

function s.effectfilter(e,ct)
	local p=e:GetHandler():GetControler()
	local te,tp=Duel.GetChainInfo(ct,CHAININFO_TRIGGERING_EFFECT,CHAININFO_TRIGGERING_PLAYER)
	return p==tp and te:IsSpellEffect()
end

function s.indtg(e,c)
	return c:IsSpell()
end

function s.thfilter(c)
	return c:IsSetCard(SET_ENDYMION) and c:IsMonster() and c:IsAbleToHand()
end

function s.searchtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter, tp, LOCATION_DECK, 0, 1, nil) end
	Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

function s.searchop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if tc and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) and tc:HasLevel() and c:IsFaceup() and c:IsRelateToEffect(e) then
		local cg=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsCanAddCounter,COUNTER_SPELL,1),tp,LOCATION_ONFIELD,0,nil)
		local ct=tc:GetLevel()
		if ct>0 and #cg>0 then
		Duel.BreakEffect()
			while ct>0 and #cg>0 do
				cg:Select(tp,1,1,nil):GetFirst():AddCounter(COUNTER_SPELL,1)
				ct=ct-1
				cg=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsCanAddCounter,COUNTER_SPELL,1),tp,LOCATION_ONFIELD,0,nil)
			end
		end
	end
end