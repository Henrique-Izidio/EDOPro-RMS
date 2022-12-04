-- Little Witch Conjuration
local s, id = GetID()
local sc = "0xb001"
local zira = 970000008
local zeleena = 970000009
s.listed_names = { zira, zeleena }
s.listed_series = { sc }
function s.initial_effect(c)
  local ritparams = {
    handler = c,
    lvtype = RITPROC_EQUAL,
    filter = s.rmfilter,
    lv = 8,
    matfilter = s.mfilter,
    location = LOCATION_DECK,
    sumpos = POS_FACEUP
  }
  -- activate
  local e1 = Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_ACTIVATE)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetHintTiming(TIMING_DAMAGE_STEP, TIMING_DAMAGE_STEP + TIMING_END_PHASE)
  e1:SetTarget(Ritual.Target(ritparams))
  e1:SetOperation(Ritual.Operation(ritparams))
  c:RegisterEffect(e1)

  local e2 = Effect.CreateEffect(c)
  e2:SetCategory(CATEGORY_NEGATE + CATEGORY_TODECK)
  e2:SetType(EFFECT_TYPE_QUICK_O)
  e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP + EFFECT_FLAG_DAMAGE_CAL)
  e2:SetCode(EVENT_CHAINING)
  e2:SetRange(LOCATION_GRAVE)
  e2:SetCondition(s.negcon)
  e2:SetCost(s.negcost)
  e2:SetTarget(s.negtg)
  e2:SetOperation(s.negop)
  c:RegisterEffect(e2)
end

--ritual summon
function s.rmfilter(c)
  return c:IsCode(zira) or c:IsCode(zeleena)
end

function s.mfilter(c)
  return c:IsLocation(LOCATION_MZONE)
end

--negate
function s.negcon(e, tp, eg, ep, ev, re, r, rp)
  return re:IsActiveType(TYPE_SPELL)
      and re:IsActiveType(TYPE_CONTINUOUS)
      and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsType, TYPE_RITUAL),
        e:GetHandlerPlayer(),
        LOCATION_ONFIELD,
        0, 1, nil
      )
      and Duel.IsChainNegatable(ev)
end

function s.negcost(e, tp, eg, ep, ev, re, r, rp, chk)
  local c = e:GetHandler()
  if chk == 0 then return c:IsAbleToDeck() end
  Duel.SendtoDeck(c, nil, SEQ_DECKSHUFFLE, REASON_COST + REASON_DISCARD)
end

function s.negtg(e, tp, eg, ep, ev, re, r, rp, chk)
  if chk == 0 then return true end
  Duel.SetOperationInfo(0, CATEGORY_NEGATE, eg, 1, 0, 0)
  Duel.SetOperationInfo(0, CATEGORY_TODECK, eg, 1, 0, LOCATION_ONFIELD)
end

function s.negop(e, tp, eg, ep, ev, re, r, rp)
  local ec = re:GetHandler()
  if Duel.NegateActivation(ev) and ec:IsRelateToEffect(re) then
    ec:CancelToGrave()
    Duel.SendtoDeck(ec, nil, 2, REASON_EFFECT)
  end
end
