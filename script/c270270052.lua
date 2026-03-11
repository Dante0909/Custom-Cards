--Visas Pravus
--Scripted by Hawky
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon procedure
		c:EnableReviveLimit()
	--"Visas Starfrost" + 3 "Scareclaw" Monsters
	Fusion.AddProcMixN(c,true,true,CARD_VISAS_STARFROST,1,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_SCARECLAW),3)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,true)
	--immune
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetValue(s.efilter)
	c:RegisterEffect(e2)
end
s.listed_series={SET_SCARECLAW}
s.listed_names={CARD_VISAS_STARFROST}
s.material_setcode={SET_SCARECLAW}
function s.descostfilter(c)
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