-- Traptrix Aphidoidea
local s, id = GetID()
local sc = '0x108a'
local trapTrick = 80101899
s.listed_series = { sc, 0x4c, 0x89 }
s.listed_names = { id, trapTrick }
function s.initial_effect(c)
	-- effects
	--immune
	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)

	local e2 = Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1, { id, 2 })
	e2:SetTarget(s.e2tg)
	e2:SetOperation(s.e2op)
	c:RegisterEffect(e2)

	--Remove
	local e3 = Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id, 1))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET + EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1, { id, 3 })
	e3:SetTarget(s.rmtg)
	e3:SetOperation(s.rmop)
	c:RegisterEffect(e3)
end

--immune
function s.efilter(e, te)
	local c = te:GetHandler()
	return c:GetType() == TYPE_TRAP and (c:IsSetCard(0x4c) or c:IsSetCard(0x89))
end

--set Trap Trick
function s.splimit(e, c, sump, sumtype, sumpos, targetp, se)
	return not c:IsSetCard(sc)
end
function s.setfilter(c, tp)
	return c:GetType() == TYPE_TRAP and c:IsCode(trapTrick)
end

function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return Duel.IsExistingMatchingCard(s.setfilter, tp, LOCATION_DECK, 0, 1, nil) end
end

function s.e2op(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SET)
	local tc = Duel.SelectMatchingCard(tp, s.setfilter, tp, LOCATION_DECK, 0, 1, 1, nil):GetFirst()
	if tc then
		Duel.SSet(tp, tc)
		local e2 = Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e2:SetReset(RESET_EVENT + RESETS_STANDARD)
		tc:RegisterEffect(e2)
		--Cannot Special Summon, except traptrix
		local lock = Effect.CreateEffect(c)
		lock:SetType(EFFECT_TYPE_FIELD)
		lock:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_OATH + EFFECT_FLAG_CLIENT_HINT)
		lock:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		lock:SetTargetRange(1, 0)
		lock:SetTarget(s.splimit)
		lock:SetReset(RESET_PHASE + PHASE_END)
		Duel.RegisterEffect(lock, tp)
	end
end

--banish
function s.rmtg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToRemove() end
	if chk == 0 then return Duel.IsExistingTarget(Card.IsAbleToRemove, tp, LOCATION_MZONE, LOCATION_MZONE, 1, nil) end
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_REMOVE)
	local g = Duel.SelectTarget(tp, Card.IsAbleToRemove, tp, LOCATION_MZONE, LOCATION_MZONE, 1, 1, nil)
	Duel.SetOperationInfo(0, CATEGORY_REMOVE, g, 1, 0, 0)
end

function s.rmop(e, tp, eg, ep, ev, re, r, rp)
	local tc = Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.Remove(tc, 0, REASON_EFFECT + REASON_TEMPORARY) ~= 0 then
		tc:RegisterFlagEffect(id, RESET_EVENT + RESETS_STANDARD + RESET_PHASE + PHASE_END, 0, 1)
		local e3 = Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD + EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_PHASE + PHASE_END)
		e3:SetReset(RESET_PHASE + PHASE_END)
		e3:SetLabelObject(tc)
		e3:SetCountLimit(1)
		e3:SetCondition(s.retcon)
		e3:SetOperation(s.retop)
		Duel.RegisterEffect(e3, tp)
	end
end

function s.retcon(e, tp, eg, ep, ev, re, r, rp)
	return e:GetLabelObject():GetFlagEffect(id) ~= 0
end

function s.retop(e, tp, eg, ep, ev, re, r, rp)
	Duel.ReturnToField(e:GetLabelObject())
end
