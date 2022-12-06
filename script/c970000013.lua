-- Cyber Anegl Laxmia
local s, id = GetID()
local sc = 0x2093 -- archtype code
local machineAngel = 39996157
s.listed_names = { id, machineAngel }

function s.initial_effect(c)
  -- effects
  --add 1 cyber angel  or machine angel then return 1 card to deck
  local e1 = Effect.CreateEffect(c)
  e1:SetCategory(CATEGORY_TOHAND + CATEGORY_SEARCH + CATEGORY_TODECK)
  e1:SetType(EFFECT_TYPE_IGNITION)
  e1:SetRange(LOCATION_HAND)
  e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
  e1:SetCountLimit(1, { id, 1 })
  e1:SetCost(s.e1cost)
  e1:SetTarget(s.e1tg)
  e1:SetOperation(s.e1op)
  c:RegisterEffect(e1)

  --add ritua monster/spell from GY
  local e2 = Effect.CreateEffect(c)
  e2:SetCategory(CATEGORY_TODECK)
  e2:SetType(EFFECT_TYPE_SINGLE + EFFECT_TYPE_TRIGGER_O)
  e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
  e2:SetCode(EVENT_SPSUMMON_SUCCESS)
  e2:SetCondition(s.e2con)
  e2:SetTarget(s.e2tg)
  e2:SetOperation(s.e2op)
  c:RegisterEffect(e2)

  --Special Summon
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_RELEASE)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end

--add 1 cyber angel  or machine angel then return 1 card to deck
function s.e1filter(c)
  return c:IsAbleToHand()
      and (c:IsSetCard(sc) or c:IsCode(machineAngel))
end

function s.e1cost(e, tp, eg, ep, ev, re, r, rp, chk)
  if chk == 0 then return not e:GetHandler():IsPublic() end
  Duel.ConfirmCards(1 - tp, e:GetHandler())
end

function s.e1tg(e, tp, eg, ep, ev, re, r, rp, chk)
  if chk == 0 then return Duel.IsExistingMatchingCard(s.e1filter, tp, LOCATION_DECK, 0, 1, nil) end
  Duel.SetOperationInfo(0, CATEGORY_TOHAND, nil, 1, tp, LOCATION_DECK)
  Duel.SetOperationInfo(0, CATEGORY_TODECK, nil, 1, tp, LOCATION_HAND)
end

function s.e1op(e, tp, eg, ep, ev, re, r, rp)
  Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_ATOHAND)
  local g = Duel.SelectMatchingCard(tp, s.e1filter, tp, LOCATION_DECK, 0, 1, 1, nil)
  if #g > 0 and Duel.SendtoHand(g, nil, REASON_EFFECT) > 0 and g:GetFirst():IsLocation(LOCATION_HAND) then
    Duel.ConfirmCards(1 - tp, g)
    Duel.ShuffleHand(tp)
    Duel.ShuffleDeck(tp)
    Duel.BreakEffect()
    Duel.Hint(HINT_SELECTMSG, tp, HINTMSG_TODECK)
    local g = Duel.SelectReleaseGroupCost(tp, Card.IsMonster, 1, 1, true, nil, nil)
    Duel.Release(g, REASON_EFFECT)
  end
end

--add ritua monster/spell from GY
function s.e2con(e, tp, eg, ep, ev, re, r, rp, chk)
  return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
function s.e2filter(c)
  return c:IsRitualMonster() or c:IsRitualSpell()
end
function s.e2tg(e, tp, eg, ep, ev, re, r, rp, chk)
  if chk == 0 then
    return Duel.IsExistingTarget(s.e2filter, tp, LOCATION_GRAVE, 0, 1, nil)
  end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,0)
end
function s.e2op(e, tp, eg, ep, ev, re, r, rp, chk)
  Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local tg=Duel.SelectTarget(tp,s.e2filter,tp,LOCATION_GRAVE,0,1,1,nil)
  if #tg>0 then
		Duel.SendtoHand(tg, tp, REASON_EFFECT)
	end
end

--Special from deck
function s.thfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_FAIRY) and c:IsAbleToHand() and c:IsLevel(2)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil)
	if #g>0 then
    Duel.SpecialSummon(g, 0, tp, tp, false, false, POS_FACEUP)
		-- Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- Duel.ConfirmCards(1-tp,g)
	end
end