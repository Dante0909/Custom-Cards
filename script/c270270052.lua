--Visas Pravus
--Scripted by Hawky
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon procedure
		c:EnableReviveLimit()
	--"Visas Starfrost" + 3 "Scareclaw" Monsters
	Fusion.AddProcMixN(c,true,true,CARD_VISAS_STARFROST,1,s.matfilter,3)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,true)
	--immune
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetValue(s.efilter)
	c:RegisterEffect(e2)
	--Cannot Special Summon, from the extra deck except Scareclaw monsters or Vicious Astraloud
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCost(s.cost)
	e3:SetOperation(s.regop)
	c:RegisterEffect(e3)
		Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
		
end
s.listed_series={SET_SCARECLAW}
s.listed_names={CARD_VISAS_STARFROST}
s.material_setcode={SET_SCARECLAW}
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	--Cannot Special Summon from the Extra Deck, except Machines
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE|PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	Duel.RegisterEffect(e1,tp)
end
function s.counterfilter(c)
	return not (c:IsSetCard(SET_SCARECLAW) or c:IsCode(65815684)) or c:GetSummonLocation(LOCATION_EXTRA)
end
function s.matfilter(c)
	return c:IsSetCard(SET_SCARECLAW) and c:IsMonster()
end
function s.contactfil(tp)
	local loc=LOCATION_ONFIELD|LOCATION_GRAVE
	if Duel.IsPlayerAffectedByEffect(tp,CARD_SPIRIT_ELIMINATION) then loc=LOCATION_ONFIELD end
	return Duel.GetMatchingGroup(Card.IsAbleToRemoveAsCost,tp,loc,0,nil)
end
function s.contactop(g)
	Duel.Remove(g,POS_FACEUP,REASON_COST|REASON_MATERIAL)
end
function s.efilter(e,te)
	return te:IsMonsterEffect() and te:GetOwner()~=e:GetOwner()
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
--Cannot Special Summon, from the extra deck except Scareclaw monsters or Vicious Astraloud
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return c:IsLocation(LOCATION_EXTRA) and not (c:IsSetCard(SET_SCARECLAW) or c:IsCode(65815684))
end