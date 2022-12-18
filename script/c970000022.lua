-- Bloom, the Rikka Queen
local s, id = GetID()
local sc = "0x141"
s.listed_series = { sc }
s.listed_names = { id }
function s.initial_effect(c)

  --Xyz Summon
  c:EnableReviveLimit()
  Xyz.AddProcedure(c, aux.FilterBoolFunctionEx(Card.IsRace, RACE_PLANT), 6, 2, nil, nil, 2)

  -- effects

  --Special Summon from Deck
  local e1 = Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
  e1:SetCountLimit(1, { id, 1 })
  e1:SetRange(LOCATION_MZONE)
  -- e1:SetCost(aux.dxmcostgen(1, 1, nil))
  e1:SetTarget(s.e1tg)
  e1:SetOperation(s.e1op)
  c:RegisterEffect(e1)

  --Special self from GY
  local e2 = Effect.CreateEffect(c)
  e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
  e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
  e2:SetCode(EVENT_RELEASE)
  e2:SetProperty(EFFECT_FLAG_DELAY)
  e2:SetRange(LOCATION_GRAVE)
  e2:SetCountLimit(1, { id, 2 })
  e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
  c:RegisterEffect(e2)
end

function s.e1filter(c)
  return c:IsRace(RACE_PLANT) and not c:IsCode(id)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
  local c = e:GetHandler()
  if chk == 0 then
    return c:CheckRemoveOverlayCard(tp, 1, REASON_COST)
        and Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_HAND + LOCATION_ONFIELD, 0, 1, nil)
        and Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_DECK, 0, 1, nil)
  end
  c:RemoveOverlayCard(tp,1,1,REASON_COST)
  local g=Duel.SelectMatchingCard(tp,s.e1filter,tp,LOCATION_HAND + LOCATION_ONFIELD,0,1,1,nil)
  Duel.Release(g, REASON_COST)
  Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_DECK)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp, chk)
  Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
  local g = Duel.SelectMatchingCard(tp, s.e1filter, tp, LOCATION_DECK, 0, 1, 1, nil, e, tp)
  local tc = g:GetFirst()
  Duel.SpecialSummon(tc, SUMMON_TYPE_SPECIAL, tp, tp, false, false, POS_FACEUP)
end


--Special self from GY
function s.spcfilter(c)
	return c:IsSetCard(sc)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.spcfilter,1,nil,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) and c:IsLocation(LOCATION_GRAVE) and not eg:IsContains(c) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end