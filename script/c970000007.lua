-- Little Witch Zira
local s, id = GetID()
local sc = "0xb001"
s.listed_names = { id }
s.listed_series = { sc }
function s.initial_effect(c)
  -- effects

  --return self to hand then summon from hand/deck
  local e1 = Effect.CreateEffect(c)
  e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
  e1:SetType(EFFECT_TYPE_QUICK_O)
  e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e1:SetRange(LOCATION_MZONE)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetCost(s.e1cost)
  e1:SetTarget(s.e1tg)
  e1:SetOperation(s.e1op)
  c:RegisterEffect(e1)

  --set 1 ritual from deck or gy on summmon
  --on normla summon
  local e2 = Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
  e2:SetCode(EVENT_SUMMON_SUCCESS)
  e2:SetCountLimit(1, { id, 2 })
  e2:SetCost(s.e2cost)
  e2:SetTarget(s.e2tg)
  e2:SetOperation(s.e2op)
  c:RegisterEffect(e2)

  local e2xSS = e2:Clone()
  e2xSS:SetCode(EVENT_SPSUMMON_SUCCESS)
  c:RegisterEffect(e2xSS)
end

--return self to hand then summon from hand/deck
function s.e1cost(e, tp, eg, ep, ev, re, r, rp, chk)
  if chk == 0 then
    return e:GetHandler():IsAbleToHandAsCost()
  end
  Duel.SendtoHand(e:GetHandler(), nil, REASON_COST)
end

function s.e1filter(c, e, tp)
  return c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
      and c:IsSetCard(sc)
      and not c:IsCode(id)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
  if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_HAND + LOCATION_DECK, 0, 1, nil, e, tp)
  end
  Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_HAND + LOCATION_DECK)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
  if Duel.GetLocationCount(tp, LOCATION_MZONE) <= 0 then return end
  Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
  local g = Duel.SelectMatchingCard(tp, s.e1filter, tp, LOCATION_HAND + LOCATION_DECK, 0, 1, 1, nil, e, tp)
  local tc = g:GetFirst()
  Duel.SpecialSummon(tc, SUMMON_TYPE_SPECIAL, tp, tp, false, false, POS_FACEUP)
end

--discard 1 card; draw 1 card
function s.e2cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
function s.e2tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.e2op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Draw(tp,1,REASON_EFFECT)
end
