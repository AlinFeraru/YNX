-- Icon and display-name hints for ability keys; the current game's own data wins.
-- Factual keys/icon paths cross-checked against ASBuilder generated spell table,
-- https://github.com/cadoky/ASBuilder/blob/main/Data.lua (2026-11-04).
ABA.catalog = {
 cleave={"Cleave","Ability_Warrior_Cleave"}, whirlwind={"Whirlwind","Ability_Whirlwind"},
 thunder_clap={"Thunder Clap","Spell_Nature_ThunderClap"}, mortal_strike={"Mortal Strike","Ability_Warrior_SavageBlow"},
 execute={"Execute","INV_Sword_48"}, demo_shout={"Demoralizing Shout","Ability_Warrior_WarCry"},
 battle_shout={"Battle Shout","Ability_Warrior_BattleShout"}, bloodthirst={"Bloodthirst","Spell_Nature_BloodLust"},
 rend={"Rend","Ability_Gouge"}, shield_slam={"Shield Slam","INV_Shield_05"}, bloodrage={"Bloodrage","Ability_Racial_BloodRage"},
 consecration={"Consecration","Spell_Holy_InnerFire"}, exorcism={"Exorcism","Spell_Holy_Excorcism_02"},
 hammer_of_wrath={"Hammer of Wrath","Ability_ThunderClap"}, holy_shock={"Holy Shock","Spell_Holy_SearingLight"},
 holy_wrath={"Holy Wrath","Spell_Holy_Excorcism"}, judgement={"Judgement","Spell_Holy_RighteousFury"},
 hammer_of_justice={"Hammer of Justice","Spell_Holy_SealOfMight"}, holy_light={"Holy Light","Spell_Holy_HolyBolt"},
 divine_shield={"Divine Shield","Spell_Holy_DivineIntervention"}, holy_shield={"Holy Shield","Spell_Holy_BlessingOfProtection"},
 redemption={"Redemption","Spell_Holy_Resurrection"},
 auto_shot={"Auto Shot","Ability_Whirlwind"}, arcane_shot={"Arcane Shot","Ability_ImpalingBolt"},
 multi_shot={"Multi-Shot","Ability_UpgradeMoonGlaive"}, serpent_sting={"Serpent Sting","Ability_Hunter_Quickshot"},
 volley={"Volley","Ability_Marksmanship"}, kill_command={"Kill Command","Ability_Hunter_BeastCall"},
 concussive_shot={"Concussive Shot","Spell_Frost_Stun"},
 sinister_strike={"Sinister Strike","Spell_Shadow_RitualOfSacrifice"}, eviscerate={"Eviscerate","Ability_Rogue_Eviscerate"},
 blade_flurry={"Blade Flurry","Ability_Warrior_PunishingBlow"}, rupture={"Rupture","Ability_Rogue_Rupture"},
 kidney_shot={"Kidney Shot","Ability_Rogue_KidneyShot"}, gouge={"Gouge","Ability_Gouge"},
 ghostly_strike={"Ghostly Strike","Spell_Shadow_Curse"}, adrenaline_rush={"Adrenaline Rush","Spell_Shadow_ShadowWordDominate"},
 backstab={"Backstab","Ability_BackStab"}, slice_and_dice={"Slice and Dice","Ability_Rogue_SliceDice"},
 seal_fate={"Seal Fate","Spell_Shadow_ChillTouch"},
 smite={"Smite","Spell_Holy_HolySmite"}, sw_pain={"Shadow Word: Pain","Spell_Shadow_ShadowWordPain"},
 mind_blast={"Mind Blast","Spell_Shadow_UnholyFrenzy"}, holy_nova={"Holy Nova","Spell_Holy_HolyNova"},
 pw_shield={"Power Word: Shield","Spell_Holy_PowerWordShield"}, renew={"Renew","Spell_Holy_Renew"},
 holy_fire={"Holy Fire","Spell_Holy_SearingLight"}, mind_flay={"Mind Flay","Spell_Shadow_SiphonMana"},
 psychic_scream={"Psychic Scream","Spell_Shadow_PsychicScream"},
 devouring_plague={"Devouring Plague","Spell_Shadow_BlackPlague"}, lightwell={"Lightwell","Spell_Holy_SummonLightwell"},
 lightning_bolt={"Lightning Bolt","Spell_Nature_Lightning"}, chain_lightning={"Chain Lightning","Spell_Nature_ChainLightning"},
 earth_shock={"Earth Shock","Spell_Nature_EarthShock"}, flame_shock={"Flame Shock","Spell_Fire_FlameShock"},
 frost_shock={"Frost Shock","Spell_Frost_FrostShock"}, lightning_shield={"Lightning Shield","Spell_Nature_LightningShield"},
 magma_totem={"Magma Totem","Spell_Fire_SelfDestruct"}, searing_totem={"Searing Totem","Spell_Fire_SearingTotem"},
 fire_nova={"Fire Nova","Spell_Fire_SealOfFire"}, healing_wave={"Healing Wave","Spell_Nature_MagicImmunity"},
 stormstrike={"Stormstrike","Spell_Holy_SealOfMight"}, rockbiter={"Rockbiter Weapon","Spell_Nature_RockBiter"},
 fireball={"Fireball","Spell_Fire_FlameBolt"}, frostbolt={"Frostbolt","Spell_Frost_FrostBolt02"},
 arcane_missiles={"Arcane Missiles","Spell_Nature_StarFall"}, frost_nova={"Frost Nova","Spell_Frost_FrostNova"},
 arcane_explosion={"Arcane Explosion","Spell_Nature_WispSplode"}, blizzard={"Blizzard","Spell_Frost_IceStorm"},
 flamestrike={"Flamestrike","Spell_Fire_SelfDestruct"}, fire_blast={"Fire Blast","Spell_Fire_Fireball"},
 cone_of_cold={"Cone of Cold","Spell_Frost_Glacier"}, blast_wave={"Blast Wave","Spell_Holy_Excorcism_02"},
 pyroblast={"Pyroblast","Spell_Fire_Fireball02"}, ice_barrier={"Ice Barrier","Spell_Ice_Lament"},
 polymorph={"Polymorph","Spell_Nature_Polymorph"},
 shadow_bolt={"Shadow Bolt","Spell_Shadow_ShadowBolt"}, curse_of_agony={"Curse of Agony","Spell_Shadow_CurseOfSargeras"},
 drain_life={"Drain Life","Spell_Shadow_LifeDrain02"}, soul_fire={"Soulfire","Spell_Fire_Fireball02"},
 wrath={"Wrath","Spell_Nature_AbolishMagic"}, moonfire={"Moonfire","Spell_Nature_StarFall"},
 starfire={"Starfire","Spell_Arcane_StarFire"}, rejuvenation={"Rejuvenation","Spell_Nature_Rejuvenation"},
 swipe={"Swipe","INV_Misc_MonsterClaw_03"}, shred={"Shred","Spell_Shadow_VampiricAura"},
 escape_artist={"Escape Artist","Ability_Rogue_Trip"}
};

function ABA.Pretty(key)
    local r = ABA.catalog[tostring(key or "")];
    if r then return r[1] end
    local txt = string.gsub(tostring(key or "Unknown"), "_", " ");
    return string.upper(string.sub(txt,1,1)) .. string.sub(txt,2);
end
function ABA.Icon(key)
    local row = ABA.catalog[tostring(key or "")];
    return "Interface\\Icons\\" .. (row and row[2] or "INV_Misc_QuestionMark");
end
