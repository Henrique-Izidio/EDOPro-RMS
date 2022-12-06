-- Cyber Anegl Saras
local s, id = GetID()
local sc = 0x2093 -- archtype code
local machineAngel = 39996157
s.listed_series = { sc }
s.listed_names = { id, machineAngel }
function s.initial_effect(c)
  c:EnableReviveLimit()

  -- effects
  --shuffe opponent cards
  local e1 = Effect.CreateEffect(c)
  e1:SetCategory(CATEGORY_TODECK)
  e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
  e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
  e1:SetCode(EVENT_SPSUMMON_SUCCESS)
  e1:SetCountLimit(1, { id, 1 })
  e1:SetCondition(s.e1con)
  e1:SetTarget(s.e1tg)
  e1:SetOperation(s.e1op)
  c:RegisterEffect(e1)

  --immune
  local e2 = Effect.CreateEffect(c)
  e2:SetType(EFFECT_TYPE_QUICK_O)
  e2:SetCode(EVENT_FREE_CHAIN)
  e2:SetRange(LOCATION_MZONE)
  e2:SetCountLimit(1, { id, 2 })
  e2:SetTarget(s.immcost)
  e2:SetOperation(s.immop)
  c:RegisterEffect(e2)
end

--shuffe opp cards
function s.e1con(e, tp, eg, ep, ev, re, r, rp, chk)
  return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
  if chk == 0 then
    return Duel.IsExistingMatchingCard(Card.IsRitualMonster, tp, LOCATION_GRAVE + LOCATION_MZONE, 0, 1, nil)
        and Duel.IsExistingTarget(aux.TRUE, tp, 0, LOCATION_ONFIELD, 1, nil)
  end
  Duel.SetOperationInfo(0, CATEGORY_TODECK, nil, 1, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp, chk)
  local ct = Duel.GetMatchingGroup(Card.IsRitualMonster, tp, LOCATION_GRAVE + LOCATION_MZONE, 0, nil):GetClassCount(Card
    .GetCode)
  Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
  local tg = Duel.SelectTarget(tp, aux.TRUE, tp, 0, LOCATION_ONFIELD, 1, ct, nil)
  if #tg > 0 then
    Duel.SendtoDeck(tg, nil, SEQ_DECKSHUFFLE, REASON_EFFECT)
  end
end

--immune
function s.cfilter(c)
  return c:IsMonster()
      and c:IsAbleToRemoveAsCost()
      and c:IsType(TYPE_RITUAL)
      and aux.SpElimFilter(c, true)
end

function s.immcost(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
  if chk == 0 then return Duel.IsExistingMatchingCard(s.cfilter, tp, LOCATION_GRAVE, 0, 1, nil) end
  Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
  local g = Duel.SelectMatchingCard(tp, s.cfilter, tp, LOCATION_GRAVE, 0, 1, 1, nil)
  Duel.Remove(g, POS_FACEUP, REASON_COST)
end

function s.immop(e, tp, eg, ep, ev, re, r, rp)
  local e2 = Effect.CreateEffect(e:GetHandler())
  e2:SetType(EFFECT_TYPE_FIELD)
  e2:SetCode(EFFECT_IMMUNE_EFFECT)
  e2:SetTargetRange(LOCATION_MZONE, 0)
  e2:SetTarget(aux.TargetBoolFunction(Card.IsType, TYPE_MONSTER + TYPE_RITUAL))
  e2:SetValue(s.efilter)
  e2:SetReset(RESET_PHASE + PHASE_END)
  Duel.RegisterFlagEffect(tp, id, RESET_PHASE + PHASE_END, 0, 1)
  Duel.RegisterEffect(e2, tp)
end

function s.efilter(e, re)
  return e:GetOwnerPlayer() ~= re:GetOwnerPlayer()
end
