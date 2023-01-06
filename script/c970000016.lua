-- Icy Empress Zerofrost
local s, id = GetID()
function s.initial_effect(c)

  -- Xyz summon
  c:EnableReviveLimit()
  Xyz.AddProcedure(c, nil, 5, 2, s.ovfilter, aux.Stringid(id, 0), 2)

  -- effects
  --gy to deck
  local e1 = Effect.CreateEffect(c)
  e1:SetDescription(aux.Stringid(id, 0))
  e1:SetCategory(CATEGORY_TODECK + CATEGORY_DRAW)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetCode(EVENT_FREE_CHAIN)
  e1:SetRange(LOCATION_MZONE)
  e1:SetCountLimit(1, { id, 1 })
  e1:SetTarget(s.e1tg)
  e1:SetOperation(s.e1op)
  c:RegisterEffect(e1)

  local e2 = Effect.CreateEffect(c)
  e2:SetDescription(aux.Stringid(id, 1))
  e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
  e2:SetType(EFFECT_TYPE_QUICK_O)
  e2:SetCode(EVENT_CHAINING)
  e2:SetRange(LOCATION_MZONE)
  e2:SetCountLimit(1, { id, 2 })
  e2:SetTarget(s.e2tg)
  e2:SetOperation(s.e2op)
  c:RegisterEffect(e2)
end

--rank up
function s.ovfilter(c, tp, xyzc)
  return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsAttribute(ATTRIBUTE_WATER)
end

--shuffe and draw
function s.e1filter(c)
  return c:IsAbleToDeck()
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
  local c = e:GetHandler()
  if chk == 0 then
    return c:CheckRemoveOverlayCard(tp, 1, REASON_COST)
        and Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_GRAVE, 0, 1, nil)
  end
  c:RemoveOverlayCard(tp, 1, 1, REASON_COST)
  Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 1)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp, chk)
  Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
  local tg = Duel.SelectTarget(tp, Card.IsAbleToDeck, tp, LOCATION_GRAVE, 0, 1, 1, nil)
  Duel.SendtoDeck(tg, nil, 0, REASON_EFFECT)
  local g = Duel.GetOperatedGroup()
  if g:IsExists(Card.IsLocation, 1, nil, LOCATION_DECK) then Duel.ShuffleDeck(tp) end
  local ct = g:FilterCount(Card.IsLocation, nil, LOCATION_DECK + LOCATION_EXTRA)
  if ct == 1 then
    Duel.BreakEffect()
    Duel.Draw(tp, 1, REASON_EFFECT)
  end
end

--Special summon

function s.waterXyzFilter(c)
  return c:IsType(TYPE_XYZ) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsAbleToExtra()
end

function s.attachedXyzFilter(c)
  return c:IsType(TYPE_XYZ) and c:IsAbleToExtra()
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
  local c = e:GetHandler()

  local c1 = Duel.IsExistingTarget(s.waterXyzFilter, tp, LOCATION_GRAVE, 0, 1, nil)
  local c2 = c:GetFlagEffect(id) == 0 and c:GetOverlayGroup():IsExists(s.attachedXyzFilter, 1, nil, tp)

  if chk == 0 then return c1 or c2 end

  Duel.SetOperationInfo(0, CATEGORY_TODECK, nil, 1, tp, LOCATION_OVERLAY)
  Duel.SetOperationInfo(0, CATEGORY_TODECK, nil, 1, tp, LOCATION_GRAVE)
  Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)

end

function s.e2op(e, tp, eg, ep, ev, re, r, rp, chk)
  local c = e:GetHandler()
  local tg
  local tgId
  local ov = c:GetFlagEffect(id) == 0 and c:GetOverlayGroup()
  if not Duel.IsExistingTarget(s.waterXyzFilter, tp, LOCATION_GRAVE, 0, 1, nil) then
    tg = ov:FilterSelect(tp, s.attachedXyzFilter, 1, 1, nil, tp):GetFirst()
    tgId = tg
  elseif ov:IsExists(s.attachedXyzFilter, 1, nil, tp) then
    if Duel.SelectYesNo(tp, aux.Stringid(id, 2)) then
      tg = ov:FilterSelect(tp, s.attachedXyzFilter, 1, 1, nil, tp):GetFirst()
      tgId = tg
    else
      tg = Duel.SelectTarget(tp, s.waterXyzFilter, tp, LOCATION_GRAVE, 0, 1, 1, c)
      tgId = tg:GetFirst()
    end
  else
    tg = Duel.SelectTarget(tp, s.waterXyzFilter, tp, LOCATION_GRAVE, 0, 1, 1, c)
    tgId = tg:GetFirst()
  end
  if Duel.SpecialSummon(tg, 0, tp, tp, false, false, POS_FACEUP) ~= 0 then
    if Duel.SelectYesNo(tp, aux.Stringid(id, 3)) then
      Duel.Overlay(tgId, c)
    end
  end
end
