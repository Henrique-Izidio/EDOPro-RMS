-- Libromancer Vileresident
local s, id = GetID()
local sc = 0x17d
s.listed_names = { id }
s.listed_series = { sc }
function s.initial_effect(c)
  c:EnableReviveLimit()
  -- effects
  --Check materials on Ritual Summon
  local e0 = Effect.CreateEffect(c)
  e0:SetType(EFFECT_TYPE_SINGLE)
  e0:SetCode(EFFECT_MATERIAL_CHECK)
  e0:SetValue(s.matcheck)
  c:RegisterEffect(e0)

  --Cannot be destroyed by battle
  local e1 = Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_F)
  e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
  e1:SetCode(EVENT_BATTLE_DESTROYING)
  e1:SetRange(LOCATION_MZONE)
  e1:SetCondition(s.matcon)
  e1:SetTarget(s.damtg)
  e1:SetOperation(s.damop)
  c:RegisterEffect(e1)

  --bounce
  local e2 = Effect.CreateEffect(c)
  e2:SetCategory(CATEGORY_TOHAND)
  e2:SetType(EFFECT_TYPE_QUICK_O)
  e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e2:SetRange(LOCATION_MZONE)
  e2:SetCode(EVENT_FREE_CHAIN)
  e2:SetCountLimit(1, { id, 2 })
  e2:SetTarget(s.destg)
  e2:SetOperation(s.desop)
  c:RegisterEffect(e2)
end

--Check materials on Ritual Summon
function s.matcheck(e, c)
  if c:GetMaterial():IsExists(Card.IsLocation, 1, nil, LOCATION_MZONE) then
    local reset = RESET_EVENT + RESETS_STANDARD - RESET_TOFIELD
    c:RegisterFlagEffect(id, reset, EFFECT_FLAG_CLIENT_HINT, 1, 0, aux.Stringid(id, 0))
  end
end

function s.matcon(e)
  local c = e:GetHandler()
  return c:IsSummonType(SUMMON_TYPE_RITUAL) and c:GetFlagEffect(id) > 0
end

--Inflict damage
function s.damtg(e, tp, eg, ep, ev, re, r, rp, chk)
  if chk == 0 then return true end
  local dam = e:GetHandler():GetBattleTarget():GetBaseAttack()
  if dam < 0 then dam = 0 end
  Duel.SetTargetPlayer(1 - tp)
  Duel.SetTargetParam(dam)
  Duel.SetOperationInfo(0, CATEGORY_DAMAGE, nil, 0, 1 - tp, dam)
end

function s.damop(e, tp, eg, ep, ev, re, r, rp)
  local p, d = Duel.GetChainInfo(0, CHAININFO_TARGET_PLAYER, CHAININFO_TARGET_PARAM)
  Duel.Damage(p, d, REASON_EFFECT)
end

--bounce
function s.e2filter(c)
  return c:IsSetCard(sc)
      and c:IsAbleToHand()
      and c:IsType(TYPE_MONSTER)
end

function s.destg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
  if chkc then
    return false
  end
  if chk == 0 then
    return Duel.IsExistingTarget(s.e2filter, tp, LOCATION_ONFIELD+LOCATION_GRAVE, 0, 1, nil)
        and Duel.IsExistingTarget(aux.TRUE, tp, 0, LOCATION_ONFIELD, 1, nil)
  end
  Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
  local g1 = Duel.SelectTarget(tp, s.e2filter, tp, LOCATION_ONFIELD+LOCATION_GRAVE, 0, 1, 1, nil)

  Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
  local g2 = Duel.SelectTarget(tp, aux.TRUE, tp, 0, LOCATION_ONFIELD, 1, 1, nil)
  g1:Merge(g2)
  Duel.SetOperationInfo(0, CATEGORY_TOHAND, g1, 2, 0, 0)
end

function s.desop(e, tp, eg, ep, ev, re, r, rp)
  local g = Duel.GetChainInfo(0, CHAININFO_TARGET_CARDS)
  local tg = g:Filter(Card.IsRelateToEffect, nil, e)
  if #tg > 0 then
    Duel.SendtoHand(tg, nil, REASON_EFFECT)
  end
end
