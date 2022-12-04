-- Fabulous Little Witch Zira
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
	--draw
	local e2 = Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id, 0))
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DRAW)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1, { id, 2 })
	e2:SetCost(s.damcost)
	e2:SetTarget(s.damtg)
	e2:SetOperation(s.damop)
	c:RegisterEffect(e2)

	--Target 1 monster to negate the effects
	local e3 = Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1, { id, 3 })
	e3:SetTarget(s.ngtg)
	e3:SetOperation(s.ngop)
	c:RegisterEffect(e3)
end

--canot activate quick play spells
function s.aclimit(e, re, tp)
	return re:GetHandler():GetType() == TYPE_SPELL + TYPE_CONTINUOUS and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end

--DRAW
function s.damcfilter(c)
	return c:IsType(TYPE_SPELL) and not c:IsPublic()
end

function s.damcost(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return ep == tp and eg:IsExists(s.damcfilter, 1, nil) and Duel.IsPlayerCanDraw(tp, 1) end
	local g = eg:Filter(s.damcfilter, nil)
	if #g == 1 then
		Duel.ConfirmCards(1 - tp, g)
		Duel.ShuffleHand(tp)
	else
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_CONFIRM)
		local sg = g:Select(tp, 1, 1, nil)
		Duel.ConfirmCards(1 - tp, sg)
		Duel.ShuffleHand(tp)
	end
end

function s.damtg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return true end
	Duel.SetOperationInfo(0, CATEGORY_DRAW, nil, 0, tp, 0)
	-- Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end

function s.damop(e, tp, eg, ep, ev, re, r, rp)
	if Duel.Draw(tp, 1, REASON_EFFECT) > 0 then
		local dc = Duel.GetOperatedGroup():GetFirst()
		if dc:IsType(TYPE_SPELL) and Duel.IsPlayerCanDraw(tp, 1) then
			if Duel.SelectYesNo(tp, aux.Stringid(id, 0)) then
				Duel.ConfirmCards(1 - tp, dc)
				Duel.ShuffleHand(tp)
				Duel.BreakEffect()
				Duel.Draw(tp, 1, REASON_EFFECT)
			end
		end
	end
end

--negate
function s.ngtg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsSummonType(SUMMON_TYPE_SPECIAL) end
	if chk == 0 then return Duel.IsExistingTarget(Card.IsSummonType, tp, LOCATION_MZONE, LOCATION_MZONE, 1, nil, SUMMON_TYPE_SPECIAL) end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_DESTROY)
	local g = Duel.SelectTarget(tp, Card.IsSummonType, tp, LOCATION_MZONE, LOCATION_MZONE, 1, 1, nil, SUMMON_TYPE_SPECIAL)
	-- local tg=Duel.SelectTarget(tp,Card.IsNegatableMonster,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c)
	Duel.SetOperationInfo(0, CATEGORY_DISABLE, g, 1, 0, 0)
end

function s.ngop(e, tp, eg, ep, ev, re, r, rp)
	local tc = Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local c = e:GetHandler()
		--Negate its effects
		Duel.NegateRelatedChain(tc, RESET_TURN_SET)
		local e4 = Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_DISABLE)
		e4:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
		tc:RegisterEffect(e4)
		local e5 = Effect.CreateEffect(c)
		e5:SetType(EFFECT_TYPE_SINGLE)
		e5:SetCode(EFFECT_DISABLE_EFFECT)
		e5:SetValue(RESET_TURN_SET)
		e5:SetReset(RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END)
		tc:RegisterEffect(e5)
		
		if Duel.IsPlayerCanDraw(tp, 1) and Duel.SelectYesNo(tp, aux.Stringid(id, 1)) then
			Duel.Draw(tp, 1, REASON_EFFECT)
		end
	end
end
