-- Fabulous Little Witch Zeleena
local s, id = GetID()
function s.initial_effect(c)
  c:EnableReviveLimit()
  -- effects
  --act limit
  local e1 = Effect.CreateEffect(c)
  e1:SetType(EFFECT_TYPE_FIELD)
  e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
  e1:SetCode(EFFECT_CANNOT_ACTIVATE)
  e1:SetRange(LOCATION_MZONE)
  e1:SetTargetRange(0, 1)
  e1:SetValue(s.aclimit)
  c:RegisterEffect(e1)

  local e2 = Effect.CreateEffect(c)
  e2:SetCategory(CATEGORY_TODECK)
  e2:SetType(EFFECT_TYPE_QUICK_O)
  e2:SetCode(EVENT_FREE_CHAIN)
  e2:SetRange(LOCATION_MZONE)
  e2:SetCountLimit(1, { id, 2 })
  e2:SetCondition(s.atkcon)
  e2:SetTarget(s.target)
  e2:SetOperation(s.operation)
  c:RegisterEffect(e2)
end

--canot activate quick play spells
function s.aclimit(e, re, tp)
  return re:GetHandler():GetType() == TYPE_SPELL + TYPE_QUICKPLAY and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end

--shuffe and gains lp
--Check if it is the battle phase
function s.atkcon(e, tp, eg, ep, ev, re, r, rp)
  return Duel.IsBattlePhase() and (Duel.GetCurrentPhase()~=PHASE_DAMAGE or not Duel.IsDamageCalculated())
end
function s.e4filter(c)
  -- return true
  return c:IsAbleToDeck() and aux.SpElimFilter(c,true)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingTarget(s.e4filter,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,nil,tp) end
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectTarget(tp,Card.IsAbleToDeck,tp,LOCATION_GRAVE+LOCATION_MZONE,LOCATION_GRAVE+LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
end

function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
    if Duel.SendtoDeck(tc,nil,2,REASON_EFFECT) then
      Duel.Recover(tp,500,REASON_EFFECT)
    end
	end
end
