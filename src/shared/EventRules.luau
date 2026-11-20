-- Server-owned schedules and rewards. No client supplies economy values.
local Rules={Duration=90, Gap=510}
Rules.Regular={
 {id="meteor_shower", name="Meteor Shower", color={255,135,75}, clock=21, income=1.2, reward=50, effect="meteor", note="20% bonus income + $50 survival gift"},
 {id="golden_rush", name="Golden Brainrot Rush", color={255,210,65}, clock=16, gold=0.4, effect="orbit", note="40% golden spawn chance"},
 {id="toxic_storm", name="Toxic Storm", color={100,255,115}, clock=18, income=1.5, effect="rain", note="50% bonus income; no damage"},
 {id="thunder_night", name="Thunder Night", color={145,165,255}, clock=0, income=1.5, effect="bolt", note="50% bonus income"},
 {id="lucky_hour", name="Lucky Hour", color={110,255,185}, clock=13, luck=3, effect="orbit", note="3× weight for Epic and higher"},
 {id="brainrot_invasion", name="Brainrot Invasion", color={255,130,195}, clock=19, spawn=0.65, effect="visitor", note="Faster conveyor arrivals"},
 {id="rainbow_festival", name="Rainbow Festival", color={180,160,255}, clock=14, gold=0.2, luck=2, effect="rainbow", note="20% golden chance + 2× rare weight"},
}
Rules.Admin={
 {id="meteor_madness", name="Meteor Madness", color={255,90,45}, clock=22, income=2, reward=150, effect="meteor", note="Double income + $150 gift"},
 {id="giant_attack", name="Giant Brainrot Attack", color={255,100,120}, clock=20, reward=300, effect="giant", note="Face the harbor giant • $300 finale gift"},
 {id="cash_rain", name="Cash Rain", color={90,255,140}, clock=14, income=2, reward=200, effect="rain", note="Double income + $200 gift"},
 {id="cosmic_chaos", name="Cosmic Chaos", color={135,100,255}, clock=0, luck=5, income=1.5, effect="orbit", note="5× rare weight + 50% bonus income"},
 {id="secret_party", name="Secret Brainrot Party", color={80,255,205}, clock=21, luck=8, effect="visitor", note="8× Epic and higher spawn weight"},
 {id="disco_invasion", name="Disco Invasion", color={255,100,245}, clock=1, gold=0.4, spawn=0.65, effect="rainbow", note="Faster arrivals + 40% golden chance"},
}
function Rules.find(id, admin)
 for _,definition in ipairs(admin and (Rules.Admin or {}) or Rules.Regular) do
  if definition.id==id then return definition end
 end
 return nil
end
function Rules.authorized(userId, whitelist, command, active, last, now)
 return whitelist[userId]==true and type(command)=="string" and #command<=40
  and Rules.find(command,true)~=nil and not active and now-last>=5
end
return Rules
