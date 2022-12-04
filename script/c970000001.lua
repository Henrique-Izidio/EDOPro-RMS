-- Manipulated Magikey Lemega
local s, id = GetID()
local sc = 0x167 -- archtype code
s.listed_series = { sc }
s.listed_series = { id }

function s.initial_effect(c)
	--must first link summoned
	c:EnableReviveLimit()

	--Summon Condition
	Link.AddProcedure(c, s.scon, 1, 1) --scon = Summon CONdition

	-- effects
	local e1 = Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1, { id, 1 })
	e1:SetCondition(s.e1con)
	e1:SetTarget(s.e1tg)
	e1:SetOperation(s.e1op)
	c:RegisterEffect(e1);

	--change Attribute on GY
	local e2 = Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1, { id, 2 })
	e2:SetTarget(s.e2tg)
	e2:SetOperation(s.e2op)
	c:RegisterEffect(e2)
end

--filter to link materials
function s.scon(c, lc, sumtype, tp)
	if c:IsLevelBelow(4) and not c:IsType(TYPE_TOKEN, lc, sumtype, tp) then
		if c:IsType(TYPE_NORMAL, lc, sumtype, tp) then
			return true
		end
		if c:IsSetCard(sc, lc, sumtype, tp) then
			return true
		end
	end
	return false
end

--Add "Magikey World" na link summon

--only add in link summon
function s.e1con(e, tp, eg, ep, ev, re, r, rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end

--magikey world's filter
function s.e1CardFilter(c)
	return c:IsCode(35815783) and c:IsAbleToHand()
end

--target
function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk, chkc)
	if chk == 0 then return Duel.IsExistingMatchingCard(s.e1CardFilter, tp, LOCATION_DECK, 0, 1, nil) end
	Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
end

--operantion
function s.e1op(e, tp, eg, ep, ev, re, r, rp)
	Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
	local g = Duel.SelectMatchingCard(tp, s.e1CardFilter, tp, LOCATION_DECK, 0, 1, 1, nil)
	if #g > 0 then
		Duel.SendtoHand(g, nil, REASON_EFFECT)
		Duel.ConfirmCards(1 - tp, g)
	end
end

--change Attribute
--target
function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
	if chk == 0 then return true end
	local c = e:GetHandler()
	local att = c:AnnounceAnotherAttribute(tp)
	e:SetLabel(att)
end

--target
function s.e2op(e, tp, eg, ep, ev, re, r, rp)
	local c = e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	--Change Attribute
	local e1 = Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e1:SetValue(e:GetLabel())
	e1:SetReset(RESET_EVENT + RESETS_STANDARD_DISABLE + RESET_PHASE + PHASE_END + RESET_OPPO_TURN)
	c:RegisterEffect(e1)
end
