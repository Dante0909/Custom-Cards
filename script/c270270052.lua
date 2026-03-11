--Visas Pravus
--Scripted by Hawky
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon procedure
		c:EnableReviveLimit()
	--"Visas Starfrost" + 3 "Scareclaw" Monsters
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx(Card.IsSetCard,SET_SCARECLAW),3,3,CARD_VISAS_STARFROST)
	Fusion.AddContactProc(c,s.contactfil,s.contactop,true)

	
end
s.listed_names={CARD_VISAS_STARFROST}
s.listed_series={SET_SCARECLAW}
s.material_setcode={SET_SCARECLAW}
function s.contactfil(tp)
	local loc=LOCATION_ONFIELD|LOCATION_GRAVE
	if Duel.IsPlayerAffectedByEffect(tp,CARD_SPIRIT_ELIMINATION) then loc=LOCATION_ONFIELD end
	return Duel.GetMatchingGroup(Card.IsAbleToRemoveAsCost,tp,loc,0,nil)
end
function s.contactop(g)
	Duel.Remove(g,POS_FACEUP,REASON_COST|REASON_MATERIAL)
end
