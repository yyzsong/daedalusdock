//Firebot

#define SPEECH_INTERVAL 300  // Time between idle speeches
#define DETECTED_VOICE_INTERVAL 300  // Time between fire detected callouts
#define FOAM_INTERVAL 50  // Time between deployment of fire fighting foam

/mob/living/simple_animal/bot/firebot
	name = "\improper Firebot"
	desc = "A little fire extinguishing bot. He looks rather anxious."
	icon = 'icons/mob/aibots.dmi'
	icon_state = "firebot"
	density = FALSE
	anchored = FALSE
	health = 25
	maxHealth = 25

	maints_access_required = list(ACCESS_ROBOTICS, ACCESS_ENGINEERING)
	radio_key = /obj/item/encryptionkey/headset_eng
	radio_channel = RADIO_CHANNEL_ENGINEERING
	bot_type = FIRE_BOT
	hackables = "fire safety protocols"
	path_image_color = "#FFA500"

	var/atom/target_fire
	var/atom/old_target_fire

	var/obj/item/extinguisher/internal_ext

	var/last_found = 0

	var/speech_cooldown = 0
	var/detected_cooldown = 0
	COOLDOWN_DECLARE(foam_cooldown)

	var/extinguish_people = TRUE
	var/extinguish_fires = TRUE
	var/stationary_mode = FALSE

/mob/living/simple_animal/bot/firebot/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)
	update_appearance(UPDATE_ICON)

	// Doing this hurts my soul, but simplebot access reworks are for another day.
	var/datum/access_template/job/engi_trim = SSid_access.template_singletons_by_path[/datum/access_template/job/station_engineer]
	access_card.add_access(engi_trim.access)
	prev_access = access_card.access.Copy()

	create_extinguisher()
	become_atmos_sensitive()

/mob/living/simple_animal/bot/firebot/Destroy()
	lose_atmos_sensitivity()
	return ..()

/mob/living/simple_animal/bot/firebot/bot_reset()
	create_extinguisher()

/mob/living/simple_animal/bot/firebot/proc/create_extinguisher()
	internal_ext = new /obj/item/extinguisher(src)
	internal_ext.safety = FALSE
	internal_ext.precision = TRUE
	internal_ext.max_water = INFINITY
	internal_ext.refill()

/mob/living/simple_animal/bot/firebot/UnarmedAttack(atom/A, proximity_flag, list/modifiers)
	if(!(bot_mode_flags & BOT_MODE_ON))
		return
	if(!can_unarmed_attack())
		return
	if(internal_ext)
		internal_ext.ranged_interact_with_atom(A, src)
	else
		return ..()

/mob/living/simple_animal/bot/firebot/RangedAttack(atom/A, proximity_flag, list/modifiers)
	if(!(bot_mode_flags & BOT_MODE_ON))
		return
	if(internal_ext)
		internal_ext.ranged_interact_with_atom(A, src)
	else
		return ..()

/mob/living/simple_animal/bot/firebot/turn_on()
	. = ..()
	update_appearance()

/mob/living/simple_animal/bot/firebot/turn_off()
	..()
	update_appearance()

/mob/living/simple_animal/bot/firebot/bot_reset()
	..()
	target_fire = null
	old_target_fire = null
	set_anchored(FALSE)
	update_appearance()

/mob/living/simple_animal/bot/firebot/proc/soft_reset()
	path = list()
	target_fire = null
	set_mode(BOT_IDLE)
	last_found = world.time
	update_appearance()

/mob/living/simple_animal/bot/firebot/emag_act(mob/user)
	..()
	if(!(bot_cover_flags & BOT_COVER_EMAGGED))
		return
	if(user)
		to_chat(user, span_danger("[src] buzzes and beeps."))
	audible_message(span_danger("[src] buzzes oddly!"))
	playsound(src, SFX_SPARKS, 75, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	if(user)
		old_target_fire = user
	extinguish_fires = FALSE
	extinguish_people = TRUE

	internal_ext = new /obj/item/extinguisher(src)
	internal_ext.chem = /datum/reagent/clf3 //Refill the internal extinguisher with liquid fire
	internal_ext.power = 3
	internal_ext.safety = FALSE
	internal_ext.precision = FALSE
	internal_ext.max_water = INFINITY
	internal_ext.refill()

// Variables sent to TGUI
/mob/living/simple_animal/bot/firebot/ui_data(mob/user)
	var/list/data = ..()
	if(!(bot_cover_flags & BOT_COVER_LOCKED) || issilicon(user) || isAdminGhostAI(user))
		data["custom_controls"]["extinguish_fires"] = extinguish_fires
		data["custom_controls"]["extinguish_people"] = extinguish_people
		data["custom_controls"]["stationary_mode"] = stationary_mode
	return data

// Actions received from TGUI
/mob/living/simple_animal/bot/firebot/ui_act(action, params)
	. = ..()
	if(. || (bot_cover_flags & BOT_COVER_LOCKED && !usr.has_unlimited_silicon_privilege))
		return

	switch(action)
		if("extinguish_fires")
			extinguish_fires = !extinguish_fires
		if("extinguish_people")
			extinguish_people = !extinguish_people
		if("stationary_mode")
			stationary_mode = !stationary_mode
			update_appearance()

/mob/living/simple_animal/bot/firebot/proc/is_burning(atom/target)
	if(ismob(target))
		var/mob/living/M = target
		if(M.on_fire || (bot_cover_flags & BOT_COVER_EMAGGED && !M.on_fire))
			return TRUE

	else if(isturf(target))
		var/turf/open/T = target
		if(T.active_hotspot)
			return TRUE

	return FALSE

/mob/living/simple_animal/bot/firebot/handle_automated_action()
	if(!..())
		return

	if(IsStun() || IsParalyzed())
		old_target_fire = target_fire
		target_fire = null
		set_mode(BOT_IDLE)
		return

	if(prob(1) && target_fire == null)
		var/list/messagevoice = list("No fires detected." = 'sound/voice/firebot/nofires.ogg',
		"Only you can prevent station fires." = 'sound/voice/firebot/onlyyou.ogg',
		"Temperature nominal." = 'sound/voice/firebot/tempnominal.ogg',
		"Keep it cool." = 'sound/voice/firebot/keepitcool.ogg')
		var/message = pick(messagevoice)
		speak(message)
		playsound(src, messagevoice[message], 50)

	// Couldn't reach the target, reset and try again ignoring the old one
	if(frustration > 8)
		old_target_fire = target_fire
		soft_reset()

	// We extinguished our target or it was deleted
	if(QDELETED(target_fire) || !is_burning(target_fire) || isdead(target_fire))
		target_fire = null
		var/scan_range = (stationary_mode ? 1 : DEFAULT_SCAN_RANGE)

		var/list/things_to_extinguish = list()
		if(extinguish_people)
			things_to_extinguish += list(/mob/living)

		if(target_fire == null && extinguish_fires)
			things_to_extinguish += list(/turf/open)

		target_fire = scan(things_to_extinguish, old_target_fire, scan_range) // Scan for burning turfs second
		old_target_fire = target_fire

	// Target reached ENGAGE WATER CANNON
	if(target_fire && (get_dist(src, target_fire) <= (bot_cover_flags & BOT_COVER_EMAGGED ? 1 : 2))) // Make the bot spray water from afar when not emagged
		if((speech_cooldown + SPEECH_INTERVAL) < world.time)
			if(ishuman(target_fire))
				speak("Stop, drop and roll!")
				playsound(src, 'sound/voice/firebot/stopdropnroll.ogg', 50, FALSE)
			else
				speak("Extinguishing!")
				playsound(src, 'sound/voice/firebot/extinguishing.ogg', 50, FALSE)
			speech_cooldown = world.time

			z_flick("firebot1_use", src)
			spray_water(target_fire, src)

		soft_reset()

	// Target ran away
	else if(target_fire && path.len && (get_dist(target_fire,path[path.len]) > 2))
		path = list()
		set_mode(BOT_IDLE)
		last_found = world.time

	else if(target_fire && stationary_mode)
		soft_reset()
		return

	if(target_fire && (get_dist(src, target_fire) > 2))
		set_mode(BOT_PATHING)
		path = jps_path_to(src, target_fire, max_distance=30, mintargetdist=1, access = access_card?.GetAccess())
		set_mode(BOT_MOVING)
		if(!path.len)
			soft_reset()

	if(path.len > 0 && target_fire)
		if(!bot_move(path[path.len]))
			old_target_fire = target_fire
			soft_reset()
		return

	// We got a target but it's too far away from us
	if(path.len > 8 && target_fire)
		frustration++

	if(bot_mode_flags & BOT_MODE_AUTOPATROL && !target_fire)
		switch(mode)
			if(BOT_IDLE, BOT_START_PATROL)
				start_patrol()
			if(BOT_PATROL)
				bot_patrol()


//Look for burning people or turfs around the bot
/mob/living/simple_animal/bot/firebot/process_scan(atom/scan_target)
	if(scan_target == src)
		return src
	if(!is_burning(scan_target))
		return null

	if((detected_cooldown + DETECTED_VOICE_INTERVAL) < world.time)
		speak("Fire detected!")
		playsound(src, 'sound/voice/firebot/detected.ogg', 50, FALSE)
		detected_cooldown = world.time
		return scan_target

/mob/living/simple_animal/bot/firebot/atmos_expose(datum/gas_mixture/air, exposed_temperature)
	if(exposed_temperature > T0C + 200 || exposed_temperature < BODYTEMP_COLD_DAMAGE_LIMIT)
		if(COOLDOWN_FINISHED(src, foam_cooldown))
			new /obj/effect/particle_effect/fluid/foam/firefighting(loc)
			COOLDOWN_START(src, foam_cooldown, FOAM_INTERVAL)

/mob/living/simple_animal/bot/firebot/proc/spray_water(atom/target, mob/user)
	if(stationary_mode)
		z_flick("firebots_use", user)
	else
		z_flick("firebot1_use", user)

	internal_ext.ranged_interact_with_atom(target, user)

/mob/living/simple_animal/bot/firebot/update_icon_state()
	. = ..()
	if(!(bot_mode_flags & BOT_MODE_ON))
		icon_state = "firebot0"
		return
	if(IsStun() || IsParalyzed() || stationary_mode) //Bot has yellow light to indicate stationary mode.
		icon_state = "firebots1"
		return
	icon_state = "firebot1"


/mob/living/simple_animal/bot/firebot/explode()
	var/atom/Tsec = drop_location()

	new /obj/item/assembly/prox_sensor(Tsec)
	new /obj/item/clothing/head/hardhat/red(Tsec)

	var/turf/T = get_turf(Tsec)

	if(isopenturf(T))
		var/turf/open/theturf = T
		theturf.MakeSlippery(TURF_WET_WATER, min_wet_time = 10 SECONDS, wet_time_to_add = 5 SECONDS)
	return ..()

#undef SPEECH_INTERVAL
#undef DETECTED_VOICE_INTERVAL
#undef FOAM_INTERVAL

