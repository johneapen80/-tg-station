// 🦐 Shrimp-person species 🦐
// Bounty #280 - $200 🦐

/datum/species/shrimp
	name = "\improper Shrimp"
	id = SPECIES_SHRIMP
	examine_limb_id = SPECIES_HUMAN
	sexes = FALSE
	/// 🦐 Shrimp are made of shrimp meat 🦐
	meat = /obj/item/food/meat/slab/shrimp
	bodyflag = FLAG_SHRIMP

	inherent_traits = list(
		TRAIT_USES_SKINTONES,
		TRAIT_XRAY_VISION, // 🦐 Antennae give permanent T-ray vision! 🦐
		TRAIT_WATERBREATH, // 🦐 Shrimp breathe water, not air! 🦐
		TRAIT_RESISTHEAT, // 🦐 Used to the boiling pot 🦐
	)

	inherent_biotypes = MOB_ORGANIC | MOB_HUMANOID | MOB_AQUATIC | MOB_CRUSTACEAN

	mutantlungs = /obj/item/organ/lungs/shrimp // 🦐 Water-breathing gills 🦐
	mutanttongue = /obj/item/organ/tongue/shrimp
	mutanteyes = /obj/item/organ/eyes/shrimp // 🦐 Beady little shrimp eyes 🦐
	mutant_organs = list(
		/obj/item/organ/antennae/shrimp = "Shrimp Antennae", // 🦐 Permanent T-ray! 🦐
		/obj/item/organ/tail/shrimp = "Shrimp Tail", // 🦐 Big shrimpy tail! 🦐
	)
	mutant_bodyparts = list("shrimp_tail" = "Shrimp Tail", "shrimp_antennae" = "Shrimp Antennae")

	/// 🦐 Like plasmamen need their suit, shrimp need a fishbowl helmet! 🦐
	outfit_important_for_life = /datum/outfit/shrimp
	bodytemp_normal = (BODYTEMP_NORMAL - 10) // 🦐 Cold-blooded sea creatures 🦐
	bodytemp_heat_damage_limit = (BODYTEMP_HEAT_DAMAGE_LIMIT + 20) // 🦐 Boiling water tolerance 🦐
	heatmod = 1.2 // 🦐 More susceptible to heat (they're already partially cooked) 🦐

	payday_modifier = 0.9 // 🦐 Shrimp get paid less 🦐
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	species_language_holder = /datum/language_holder/shrimp
	/// 🦐 What does a shrimp eat? Plankton! 🦐
	species_cookie = /obj/item/food/plankton

/datum/species/shrimp/on_species_gain(mob/living/carbon/human/shrimp_person, datum/species/old_species, pref_load, regenerate_icons = TRUE, replace_missing = TRUE)
	. = ..()
	// 🦐 Shrimp always need their fishbowl! 🦐
	shrimp_person.update_helmet_requirement()
	// 🦐 Antennae give the shrimp permanent T-ray vision 🦐
	ADD_TRAIT(shrimp_person, TRAIT_XRAY_VISION, SPECIES_TRAIT)
	// 🦐 Register the *spin emote for tail damage! 🦐
	RegisterSignal(shrimp_person, COMSIG_MOB_EMOTED("spin"), PROC_REF(on_spin_emote))
	to_chat(shrimp_person, span_boldnotice("🦐 You are a shrimp-person! You must wear a fishbowl helmet to survive. 🦐"))

/datum/species/shrimp/on_species_loss(mob/living/carbon/human/shrimp_person, datum/species/new_species, pref_load)
	REMOVE_TRAIT(shrimp_person, TRAIT_XRAY_VISION, SPECIES_TRAIT)
	UnregisterSignal(shrimp_person, COMSIG_MOB_EMOTED("spin"))
	return ..()

/// 🦐 SPIN TO WIN! Damage nearby mobs and structures with your big shrimpy tail! 🦐
/datum/species/shrimp/proc/on_spin_emote(mob/living/carbon/human/shrimp_person)
	SIGNAL_HANDLER
	shrimp_person.visible_message(
		span_warning("🦐 [shrimp_person] spins around, their massive shrimp tail lashing out! 🦐"),
		span_boldnotice("🦐 You spin, whipping your shrimp tail around violently! 🦐"),
	)

	playsound(shrimp_person, 'sound/effects/snap.ogg', 50, TRUE)

	// 🦐 Damage nearby mobs 🦐
	for(var/mob/living/victim in orange(1, shrimp_person))
		if(victim == shrimp_person)
			continue
		victim.visible_message(
			span_danger("🦐 [victim] gets slapped by [shrimp_person]'s massive shrimp tail! 🦐"),
			span_userdanger("🦐 OUCH! [shrimp_person]'s shrimp tail slaps you! 🦐"),
		)
		victim.apply_damage(5, BRUTE, BODY_ZONE_CHEST)
		// 🦐 Wet shrimp tail leaves them a bit damp 🦐
		victim.adjust_wet_stacks(2)
		// 🦐 Big tail causes knockback 🦐
		var/turf/away = get_step_away(victim, shrimp_person, 2)
		if(away)
			victim.throw_at(away, 1, 2, shrimp_person)

	// 🦐 Damage nearby structures 🦐
	for(var/obj/structure/target in orange(1, shrimp_person))
		if(target.take_damage(10, BRUTE, MELEE, 0))
			target.visible_message(span_danger("🦐 [shrimp_person]'s tail slams into [target]! 🦐"))


/// 🦐 On death with high burn damage, transform into fried shrimp! 🦐
/datum/species/shrimp/prepare_death(mob/living/carbon/human/shrimp_person, gibbed)
	// 🦐 If they have high burn damage, they turn into fried shrimp! 🦐
	if(!gibbed && shrimp_person.getFireLoss() >= 100)
		shrimp_person.visible_message(
			span_bolddanger("🦐🍤 [shrimp_person]'s body sizzles and curls up, transforming into a delicious fried shrimp! 🍤🦐"),
			span_userdanger("🦐🍤 As you die, you feel your body turning into a crispy fried shrimp... 🍤🦐"),
		)
		// 🦐 Drop a fried shrimp item at their location 🦐
		new /obj/item/food/fried_shrimp(shrimp_person.drop_location())
		// 🦐 Play a sizzling sound 🦐
		playsound(shrimp_person, 'sound/effects/frying.ogg', 50, TRUE)
		// 🦐 They husk into a fried looking corpse 🦐
		shrimp_person.set_species(/datum/species/human) // Detransform
		shrimp_person.become_husk(BURN)
		shrimp_person.update_body()
	return ..()

/datum/species/shrimp/get_physical_attributes()
	return "🦐 Shrimp-people are aquatic crustaceans who must wear fishbowl helmets filled with water to survive outside their native environment. 🦐 \
		Their antennae grant them permanent T-ray vision, and their massive tails can deal devastating damage when they spin. 🦐🍤"

/datum/species/shrimp/get_species_description()
	return "🦐 Genetically engineered from the common decapod, shrimp-people are the ocean's answer to humanity's endless curiosity. 🦐 \
		With their permanently visible antennae and massive tails, shrimp-people stand out in any crowd. 🦐 \
		They require a water-filled fishbowl helmet to breathe on land, much like plasmamen need their suits. 🦐"

/datum/species/shrimp/get_species_lore()
	return list(
		"🦐 Deep in the Europan oceans, ancient shrimp-people have thrived for millennia in underwater city-states. 🦐 \
			First contact was made when a NT research submarine was mistaken for a very large predator. 🦐",
		"🦐 Shrimp society revolves around the Great Boil — a cultural ceremony where elders volunteer to be boiled alive, 🦐 \
			turning into fried shrimp delicacies that are then consumed by the community in a week-long feast. 🦐",
		"🦐 The shrimp-person diaspora began when NT recruiters realized that shrimp-people made excellent station engineers 🦐 \
			due to their T-ray antennae, which let them see wires and pipes through walls naturally. 🦐",
		"🦐 Shrimp-people are prized members of any station's seafood buffet 🦐... wait, no, that's not right. 🦐 \
			They're prized members of any station's engineering department! 🦐🍤",
	)

/datum/species/shrimp/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "eye",
			SPECIES_PERK_NAME = "🦐 T-Ray Antennae 🦐",
			SPECIES_PERK_DESC = "Shrimp-people have permanent T-ray vision through their antennae, \
				allowing them to see pipes and wires through walls at all times.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "wrench",
			SPECIES_PERK_NAME = "🦐 Tail Spin Attack 🦐",
			SPECIES_PERK_DESC = "Using the *spin emote causes their massive shrimp tail to damage \
				nearby mobs and structures, with a knockback effect.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = "fire",
			SPECIES_PERK_NAME = "🦐 Fried Shrimp Transformation 🦐",
			SPECIES_PERK_DESC = "When a shrimp-person dies with high burn damage, \
				their body transforms into a crispy fried shrimp. Delicious, but undignified.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "tint",
			SPECIES_PERK_NAME = "🦐 Fishbowl Dependency 🦐",
			SPECIES_PERK_DESC = "Shrimp-people must wear a water-filled fishbowl helmet \
				to survive outside of water. Without it, they quickly suffocate.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "thermometer-full",
			SPECIES_PERK_NAME = "🦐 Heat Vulnerability 🦐",
			SPECIES_PERK_DESC = "Shrimp-people take increased burn damage. They're already \
				partially cooked, after all.",
		),
	)

	return to_add
