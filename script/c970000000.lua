-- Nobeard, the Plunder Patroll Wheelman
local s, id = GetID()
local sc = 0x13f -- archtype code
s.listed_series = { sc }
s.listed_names = { id }
function s.initial_effect(c)
  -- effects

  --add 1 plunder card from deck and discard 1 card
  --on Normal Summon | base effect
  local e1 = Effect.CreateEffect(c)
  e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH + CATEGORY_HANDES)
  e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
  e1:SetCode(EVENT_SUMMON_SUCCESS)
  e1:SetCountLimit(1, { id, 1 })
  e1:SetTarget(s.e1tg)
  e1:SetOperation(s.e1op)
  c:RegisterEffect(e1)

  --on Special Summon | extension effect
  local e1xSS = e1:Clone()
  e1xSS:SetCode(EVENT_SPSUMMON_SUCCESS)
  c:RegisterEffect(e1xSS)

  --add 1 plunder card from gy then self return to deck
  local e2 = Effect.CreateEffect(c)
  e2:SetCategory(CATEGORY_TODECK + CATEGORY_TOHAND)
  e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
  e2:SetCode(EVENT_PHASE + PHASE_END)
  e2:SetRange(LOCATION_GRAVE)
  e2:SetCountLimit(1, { id, 2 })
  e2:SetTarget(s.e2tg)
  e2:SetOperation(s.e2op)
  c:RegisterEffect(e2)

end

--filter
function s.filter(c)
  return c:IsSetCard(sc)
      and not c:IsCode(id)
      and c:IsAbleToHand()
end

--add 1 "Plunder Patroll" card from deck and discard 1 card
--target
function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
  if chk == 0 then return Duel.IsExistingMatchingCard(s.filter, tp, LOCATION_DECK, 0, 1, nil) end
  Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
  Duel.SetOperationInfo(0, CATEGORY_HANDES, nil, 1, tp, 1)
end

--operation
function s.e1op(e, tp, eg, ep, ev, re, r, rp, chk)
  Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
  local tc = Duel.SelectMatchingCard(tp, s.filter, tp, LOCATION_DECK, 0, 1, 1, nil):GetFirst()
  if tc then
    Duel.SendtoHand(tc, nil, REASON_EFFECT)
    Duel.ConfirmCards(1 - tp, tc)
    Duel.BreakEffect()
    Duel.DiscardHand(tp, nil, 1, 1, REASON_EFFECT)
    Duel.ShuffleHand(tp)
  end
end

--add 1 "Plunder Patroll" card from gy and return to deck
--target
function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
  if chkc then
    return chkc:IsControler(tp)
        and chkc:IsLocation(LOCATION_GRAVE)
        and s.filter(chkc)
  end

  if chk == 0 then
    return Duel.IsExistingTarget(s.filter, tp, LOCATION_GRAVE, 0, 1, nil)
  end

  Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
  local g = Duel.SelectTarget(tp, s.filter, tp, LOCATION_GRAVE, 0, 1, 1, nil)
  Duel.SetOperationInfo(0, CATEGORY_TODECK, e:GetHandler(), 1, 0, 0)
  Duel.SetOperationInfo(0, CATEGORY_TOHAND, g, 1, 0, LOCATION_GRAVE)
end

--operation
function s.e2op(e, tp, eg, ep, ev, re, r, rp)
  local c = e:GetHandler()
  local tc = Duel.GetFirstTarget()
  Duel.SendtoHand(tc, nil, REASON_EFFECT)
  Duel.ShuffleHand(tp)
  Duel.BreakEffect()
  Duel.SendtoDeck(c, nil, SEQ_DECKBOTTOM, REASON_EFFECT)
end
