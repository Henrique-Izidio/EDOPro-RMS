-- PSY-Frame Operator
local s, id = GetID()
local sc = 0xc1
local driverCode = 49036338 --psy-frame driver
s.listed_series = { sc }
s.listed_name = { driverCode, id }

function s.initial_effect(c)
	--cannot be normal summoned/set
	c:EnableUnsummonable()

	-- effects
	--change name to driver
	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetRange(LOCATION_MZONE + LOCATION_HAND + LOCATION_DECK + LOCATION_GRAVE)
	e1:SetValue(driverCode)
	c:RegisterEffect(e1)

	--must be special be a card effect
	local e2 = Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE + EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	e2:SetValue(s.e2con)
	c:RegisterEffect(e2)

	--add 1 psy-frame card then return 1 card from hand also lock in psychic
	local e3 = Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH + CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_HAND)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1, { id, 3 })
	e3:SetCost(s.e3cost)
	e3:SetTarget(s.e3tg)
	e3:SetOperation(s.e3op)
	c:RegisterEffect(e3)
	Duel.AddCustomActivityCounter(id, ACTIVITY_SPSUMMON, s.counterfilter)

	--make a Synchro Summon
	local e4 = Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1, { id, 4 })
	e4:SetCondition(s.e4con)
	e4:SetTarget(s.e4tg)
	e4:SetOperation(s.e4op)
	c:RegisterEffect(e4)

end

--summon condition
function s.e2con(e, se, sp, st)
	return se:IsHasType(EFFECT_TYPE_ACTIONS)
end

--add psy-frame card
--utilities functions
--filtro
function s.checkCard(c)
	return c:IsSetCard(sc) and not c:IsCode(id) and c:IsAbleToHand()
end

function s.counterfilter(c)
	return c:IsRace(RACE_PSYCHIC)
end

function s.splimit(e, c, sump, sumtype, sumpos, targetp, se)
	return not c:IsRace(RACE_PSYCHIC)
end

function s.lizfilter(e, c)
	return not c:IsOriginalRace(RACE_PSYCHIC)
end

--custo
function s.e3cost(e, tp, eg, ep, ev, re, r, rp, chk)
	local c = e:GetHandler()
	if chk == 0 then
		return not e:GetHandler():IsPublic()
			and Duel.GetCustomActivityCount(id, tp, ACTIVITY_SPSUMMON) == 0
	end
	--revel
	Duel.ConfirmCards(1 - tp, e:GetHandler())

	--Cannot Special Summon, except psychic
	local e3 = Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET + EFFECT_FLAG_OATH + EFFECT_FLAG_CLIENT_HINT)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetTargetRange(1, 0)
	e3:SetTarget(s.splimit)
	e3:SetReset(RESET_PHASE + PHASE_END)
	Duel.RegisterEffect(e3, tp)

	--Clock Lizard check
	aux.addTempLizardCheck(c, tp, s.lizfilter)
end

--target
function s.e3tg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return Duel.IsExistingMatchingCard(s.checkCard, tp, LOCATION_DECK, 0, 1, nil) end
	Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
	Duel.SetOperationInfo(0, CATEGORY_TODECK, nil, 1, tp, LOCATION_HAND)
end

--operation
function s.e3op(e, tp, eg, ep, ev, re, r, rp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
	local g = Duel.SelectMatchingCard(tp, s.checkCard, tp, LOCATION_DECK, 0, 1, 1, nil)
	if #g > 0 and Duel.SendtoHand(g, nil, REASON_EFFECT) > 0 and g:GetFirst():IsLocation(LOCATION_HAND) then
		Duel.ConfirmCards(1 - tp, g)
		Duel.ShuffleHand(tp)
		Duel.ShuffleDeck(tp)
		Duel.BreakEffect()
		Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
		local g = Duel.SelectMatchingCard(tp, Card.IsAbleToDeck, tp, LOCATION_HAND, 0, 1, 1, nil)
		Duel.SendtoDeck(g, nil, SEQ_DECKBOTTOM, REASON_EFFECT)
	end
end

function s.lock(e, c, sump, sumtype, sumpos, targetp, se)
	return not c:IsRace(RACE_PSYCHIC)
end

--sincro/link summon
--psychic Synchro filter
function s.scfilter(c)
	return c:IsRace(RACE_PSYCHIC) and c:IsSynchroSummonable(nil)
end

--psychic Link filter
function s.lkfilter(c)
	return c:IsRace(RACE_PSYCHIC) and c:IsSynchroSummonable(nil)
end

--condition to active
function s.e4con(e, tp, eg, ep, ev, re, r, rp)
	--must be special by a psy-frame
	return re and re:GetHandler():IsSetCard(sc)
end

--target
function s.e4tg(e, tp, eg, ep, ev, re, r, rp, chk)

	local b1 = Duel.IsExistingMatchingCard(s.scfilter, tp, LOCATION_EXTRA, 0, 1, nil, e:GetHandler())
	local b2 = Duel.IsExistingMatchingCard(s.lkfilter, tp, LOCATION_EXTRA, 0, 1, nil, e:GetHandler())

	if chk == 0 then return b1 or b2 end

	local op = 0
	if b1 and b2 then
		op = Duel.SelectOption(tp, aux.Stringid(id, 0), aux.Stringid(id, 1))
	elseif b1 then
		op = Duel.SelectOption(tp, aux.Stringid(id, 0))
	else
		op = Duel.SelectOption(tp, aux.Stringid(id, 1)) + 1
	end
	e:SetLabel(op)
	if op == 0 then
		Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
	else
		Duel.SetOperationInfo(0, CATEGORY_SPECIAL_SUMMON, nil, 1, tp, LOCATION_EXTRA)
	end
end

--operation
function s.e4op(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	local op = e:GetLabel()
	if op == 0 then
		if not c:IsRelateToEffect(e) or c:IsControler(1 - tp) then return end
		local g = Duel.GetMatchingGroup(Card.IsLinkSummonable, tp, LOCATION_EXTRA, 0, nil, c)
		if #g > 0 then
			Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
			local sg = g:Select(tp, 1, 1, nil)
			Duel.LinkSummon(tp, sg:GetFirst(), c)
		end
	else
		if c:IsControler(1 - tp) or not c:IsRelateToEffect(e) or c:IsFacedown() then return end
		local g = Duel.GetMatchingGroup(Card.IsSynchroSummonable, tp, LOCATION_EXTRA, 0, nil, c)
		if #g > 0 then
			Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_SPSUMMON)
			local sg = g:Select(tp, 1, 1, nil)
			Duel.SynchroSummon(tp, sg:GetFirst(), c)
		end
	end
end
