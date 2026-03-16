--Endymion's mentoring
--Scripted by Dante
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.SelfBanish)
	e2:SetTarget(s.target2)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end

s.counter_place_list={COUNTER_SPELL}

function s.thfilter(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsAbleToHand() and c:IsLevelBelow(7)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK|LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_EXTRA)
end

function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK|LOCATION_EXTRA,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,3))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetTargetRange(1,0)
		e1:SetReset(RESET_PHASE|PHASE_END)
		e1:SetTarget(s.splimit)
		Duel.RegisterEffect(e1,tp)
	end
end

function s.splimit(e,c)
	return not c:IsRace(RACE_SPELLCASTER) and not c:IsLocation(LOCATION_EXTRA)
end

function s.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA|LOCATION_PZONE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA|LOCATION_PZONE)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA|LOCATION_PZONE,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false, POS_FACEUP)
		Duel.BreakEffect()
		g:ForEach(Card.AddCounter, COUNTER_SPELL,1)
	end
end

function s.spfilter(c,e,tp)
	if not (c:IsType(TYPE_PENDULUM) and
		c:IsRace(RACE_SPELLCASTER) and
		c:IsCanAddCounter(COUNTER_SPELL,1,false,LOCATION_MZONE) and
		c:IsCanBeSpecialSummoned(e,0,tp,false,false)) then return false end
	if c:IsLocation(LOCATION_HAND) then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	else
		return c:IsFaceup() and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
	end
end