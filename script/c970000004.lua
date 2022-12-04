-- Libromancer Spook
local s, id = GetID()
local sc = 0x17d
s.listed_names = { id }
s.listed_series = { sc }
function s.initial_effect(c)
  -- effects
  -- Special Summon self
  local e1 = Effect.CreateEffect(c)
  e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetRange(LOCATION_HAND)
  e1:SetCountLimit(1, { id, 1 })
  e1:SetCost(s.e1cost)
  e1:SetTarget(s.e1tg)
  e1:SetOperation(s.e1op)
  c:RegisterEffect(e1)

  --Excavate and add to hand
  local e2 = Effect.CreateEffect(c)
  e2:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
  e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
  e2:SetProperty(EFFECT_FLAG_DELAY)
  e2:SetCode(EVENT_SPSUMMON_SUCCESS)
  e2:SetCountLimit(1, { id, 2 })
  e2:SetTarget(s.e2tg)
  e2:SetOperation(s.e2op)
  c:RegisterEffect(e2)
end

--Special Summon self
function s.e1costfilter(c)
  return c:IsRitualMonster() and not c:IsPublic()
end

function s.e1cost(e, tp, eg, ep, ev, re, r, rp, chk)
  local c = e:GetHandler()
  if chk == 0 then return Duel.IsExistingMatchingCard(s.e1costfilter, tp, LOCATION_HAND, 0, 1, c) end
  Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CONFIRM)
  local g = Duel.SelectMatchingCard(tp, s.e1costfilter, tp, LOCATION_HAND, 0, 1, 1, c)
  Duel.ConfirmCards(1 - tp, g)
  Duel.ShuffleHand(tp)
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
  local c = e:GetHandler()
  if chk == 0 then return Duel.GetLocationCount(tp, LOCATION_MZONE) > 0
        and c:IsCanBeSpecialSummoned(e, 0, tp, false, false)
  end
  Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, c, 1, 0, 0)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
  local c = e:GetHandler()
  if c:IsRelateToEffect(e) then
    Duel.SpecialSummon(c, 0, tp, tp, false, false, POS_FACEUP)
  end
end

--Excavate and add to hand
function s.e2filter(c)
  return c:IsFaceup()
      and c:IsSetCard(sc)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
  if chk == 0 then
    local ct = Duel.GetMatchingGroup(s.e2filter, tp, LOCATION_MZONE, 0, nil):GetClassCount(Card.GetCode)
    if Duel.GetFieldGroupCount(tp, LOCATION_DECK, 0) < ct then return false end
    local g = Duel.GetDecktopGroup(tp, ct)
    return g:FilterCount(Card.IsAbleToHand, nil) > 0
  end
  Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, 0, LOCATION_DECK)
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
  local ct = Duel.GetMatchingGroup(s.e2filter, tp, LOCATION_MZONE, 0, nil):GetClassCount(Card.GetCode)
  Duel.ConfirmDecktop(tp, ct)
  local g = Duel.GetDecktopGroup(tp, ct)
  if #g > 0 then
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
    local sg = g:Select(tp, 1, 1, nil)
    Duel.DisableShuffleCheck()
    if sg:GetFirst():IsAbleToHand() then
      Duel.SendtoHand(sg, nil, REASON_EFFECT)
      Duel.ConfirmCards(1 - tp, sg)
      Duel.ShuffleHand(tp)
    else
      Duel.SendtoGrave(sg, REASON_RULE)
    end
    if ct > 1 then Duel.ShuffleDeck(tp) end
  end
end
