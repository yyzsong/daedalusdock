// Flags for [/obj/item/grenade/var/dud_flags]
/// The grenade cannot detonate at all. It is innately nonfunctional.
#define GRENADE_DUD (1<<0)
/// The grenade has been used and as such cannot detonate.
#define GRENADE_USED (1<<1)

/**
 * Base class for all grenades.
 */
/obj/item/grenade
	name = "grenade"
	desc = "It has an adjustable timer."
	w_class = WEIGHT_CLASS_SMALL
	icon = 'icons/obj/grenade.dmi'
	icon_state = "grenade"
	inhand_icon_state = "flashbang"
	worn_icon_state = "grenade"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'

	throw_range = 7
	stamina_damage = 0
	stamina_cost = 0
	stamina_critical_chance = 0

	flags_1 = CONDUCT_1 | PREVENT_CONTENTS_EXPLOSION_1 // We detonate upon being exploded.
	slot_flags = ITEM_SLOT_BELT
	resistance_flags = FLAMMABLE
	max_integrity = 40
	/// Bitfields which prevent the grenade from detonating if set. Includes ([GRENADE_DUD]|[GRENADE_USED])
	var/dud_flags = NONE
	///Is this grenade currently armed?
	var/active = FALSE
	///How long it takes for a grenade to explode after being armed
	var/det_time = 5 SECONDS
	///Will this state what it's det_time is when examined?
	var/display_timer = TRUE
	///Used in botch_check to determine how a user's clumsiness affects that user's ability to prime a grenade correctly.
	var/clumsy_check = GRENADE_CLUMSY_FUMBLE
	///Was sticky tape used to make this sticky?
	var/sticky = FALSE
	// I moved the explosion vars and behavior to base grenades because we want all grenades to call [/obj/item/grenade/proc/detonate] so we can send COMSIG_GRENADE_DETONATE
	///how big of a devastation explosion radius on prime
	var/ex_dev = 0
	///how big of a heavy explosion radius on prime
	var/ex_heavy = 0
	///how big of a light explosion radius on prime
	var/ex_light = 0
	///how big of a flame explosion radius on prime
	var/ex_flame = 0

	// dealing with creating a [/datum/component/pellet_cloud] on detonate
	/// if set, will spew out projectiles of this type
	var/shrapnel_type
	/// the higher this number, the more projectiles are created as shrapnel
	var/shrapnel_radius
	///Did we add the component responsible for spawning sharpnel to this?
	var/shrapnel_initialized

/obj/item/grenade/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] primes [src], then eats it! It looks like [user.p_theyre()] trying to commit suicide!"))
	playsound(src, 'sound/items/eatfood.ogg', 50, TRUE)
	arm_grenade(user, det_time)
	user.transferItemToLoc(src, user, TRUE)//>eat a grenade set to 5 seconds >rush captain
	sleep(det_time)//so you dont die instantly
	return dud_flags ? SHAME : BRUTELOSS

/obj/item/grenade/deconstruct(disassembled = TRUE)
	if(!disassembled)
		detonate()
	if(!QDELETED(src))
		qdel(src)

/**
 * Checks for various ways to botch priming a grenade.
 *
 * Arguments:
 * * mob/living/carbon/human/user - who is priming our grenade?
 */
/obj/item/grenade/proc/botch_check(mob/living/carbon/human/user)
	if(sticky && prob(50)) // to add risk to sticky tape grenade cheese, no return cause we still prime as normal after.
		to_chat(user, span_warning("What the... [src] is stuck to your hand!"))
		ADD_TRAIT(src, TRAIT_NODROP, STICKY_NODROP)

	var/clumsy = HAS_TRAIT(user, TRAIT_CLUMSY)
	if(clumsy && (clumsy_check == GRENADE_CLUMSY_FUMBLE) && prob(50))
		to_chat(user, span_warning("Huh? How does this thing work?"))
		arm_grenade(user, 5, FALSE)
		return TRUE
	else if(!clumsy && (clumsy_check == GRENADE_NONCLUMSY_FUMBLE))
		to_chat(user, span_warning("You pull the pin on [src]. Attached to it is a pink ribbon that says, \"[span_clown("HONK")]\""))
		arm_grenade(user, 5, FALSE)
		return TRUE

/obj/item/grenade/examine(mob/user)
	. = ..()
	if(display_timer)
		if(det_time > 0)
			. += "The timer is set to [DisplayTimeText(det_time)]."
		else
			. += "\The [src] is set for instant detonation."
	if (dud_flags & GRENADE_USED)
		. += span_warning("It looks like [p_theyve()] already been used.")

/obj/item/grenade/attack_self(mob/user)
	if(HAS_TRAIT(src, TRAIT_NODROP))
		to_chat(user, span_notice("You try prying [src] off your hand..."))
		if(do_after(user, src, 7 SECONDS))
			to_chat(user, span_notice("You manage to remove [src] from your hand."))
			REMOVE_TRAIT(src, TRAIT_NODROP, STICKY_NODROP)
		return

	if (active)
		return
	if(!botch_check(user)) // if they botch the prime, it'll be handled in botch_check
		arm_grenade(user)

/obj/item/grenade/proc/log_grenade(mob/user)
	log_bomber(user, "has primed a", src, "for detonation", message_admins = !dud_flags)

/**
 * arm_grenade (formerly preprime) refers to when a grenade with a standard time fuze is activated, making it go beepbeepbeep and then detonate a few seconds later.
 * Grenades with other triggers like remote igniters probably skip this step and go straight to [/obj/item/grenade/proc/detonate]
 */
/obj/item/grenade/proc/arm_grenade(mob/user, delayoverride, msg = TRUE, volume = 60)
	log_grenade(user) //Inbuilt admin procs already handle null users
	if(user)
		add_fingerprint(user)
		if(msg)
			to_chat(user, span_warning("You prime [src]! [capitalize(DisplayTimeText(det_time))]!"))
	if(shrapnel_type && shrapnel_radius)
		shrapnel_initialized = TRUE
		AddComponent(/datum/component/pellet_cloud, projectile_type = shrapnel_type, magnitude = shrapnel_radius)
	playsound(src, 'sound/weapons/armbomb.ogg', volume, TRUE)
	active = TRUE
	icon_state = initial(icon_state) + "_active"
	SEND_SIGNAL(src, COMSIG_GRENADE_ARMED, det_time, delayoverride)
	addtimer(CALLBACK(src, PROC_REF(detonate)), isnull(delayoverride)? det_time : delayoverride)

/**
 * detonate (formerly prime) refers to when the grenade actually delivers its payload (whether or not a boom/bang/detonation is involved)
 *
 * Arguments:
 * * lanced_by- If this grenade was detonated by an elance, we need to pass that along with the COMSIG_GRENADE_DETONATE signal for pellet clouds
 */
/obj/item/grenade/proc/detonate(mob/living/lanced_by)
	if (dud_flags)
		active = FALSE
		update_appearance()
		return FALSE

	dud_flags |= GRENADE_USED // Don't detonate if we have already detonated.
	if(shrapnel_type && shrapnel_radius && !shrapnel_initialized) // add a second check for adding the component in case whatever triggered the grenade went straight to prime (badminnery for example)
		shrapnel_initialized = TRUE
		AddComponent(/datum/component/pellet_cloud, projectile_type = shrapnel_type, magnitude = shrapnel_radius)

	SEND_SIGNAL(src, COMSIG_GRENADE_DETONATE, lanced_by)
	if(ex_dev || ex_heavy || ex_light || ex_flame)
		explosion(src, ex_dev, ex_heavy, ex_light, ex_flame)

	return TRUE

/obj/item/grenade/proc/update_mob()
	if(equipped_to)
		equipped_to.dropItemToGround(src)

/obj/item/grenade/screwdriver_act(mob/living/user, obj/item/tool)
	if(active)
		return FALSE
	if(change_det_time())
		tool.play_tool_sound(src)
		to_chat(user, span_notice("You modify the time delay. It's set for [DisplayTimeText(det_time)]."))
		return TRUE

/obj/item/grenade/multitool_act(mob/living/user, obj/item/tool)
	. = ..()
	if(active)
		return FALSE

	. = TRUE

	var/newtime = tgui_input_list(user, "Please enter a new detonation time", "Detonation Timer", list("Instant", 3, 4, 5))
	if (isnull(newtime))
		return
	if(!user.canUseTopic(src, USE_CLOSE))
		return
	if(newtime == "Instant" && change_det_time(0))
		to_chat(user, span_notice("You modify the time delay. It's set to be instantaneous."))
		return
	newtime = round(newtime)
	if(change_det_time(newtime))
		to_chat(user, span_notice("You modify the time delay. It's set for [DisplayTimeText(det_time)]."))

/obj/item/grenade/proc/change_det_time(time) //Time uses real time.
	. = TRUE
	if(!isnull(time))
		det_time = round(clamp(time * 10, 0, 5 SECONDS))
	else
		var/previous_time = det_time
		switch(det_time)
			if (0)
				det_time = 3 SECONDS
			if (3 SECONDS)
				det_time = 5 SECONDS
			if (5 SECONDS)
				det_time = 0
		if(det_time == previous_time)
			det_time = 5 SECONDS

/obj/item/grenade/attack_paw(mob/user, list/modifiers)
	return attack_hand(user, modifiers)

/obj/item/grenade/get_block_chance(mob/living/carbon/human/wielder, atom/movable/hitby, damage, attack_type, armor_penetration)
	var/obj/projectile/hit_projectile = hitby
	if(!istype(hitby))
		return 0

	if(damage && attack_type == PROJECTILE_ATTACK && hit_projectile.damage_type != STAMINA && prob(15))
		return 100

/obj/item/grenade/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", damage = 0, attack_type = MELEE_ATTACK, block_success = TRUE)
	. = ..()
	if(!.)
		return

	owner.visible_message(span_danger("[attack_text] hits [owner]'s [src], setting it off! What a shot!"))
	var/turf/source_turf = get_turf(src)
	log_game("A projectile ([hitby]) detonated a grenade held by [key_name(owner)] at [COORD(source_turf)]")
	message_admins("A projectile ([hitby]) detonated a grenade held by [key_name_admin(owner)] at [ADMIN_COORDJMP(source_turf)]")
	detonate()

	if(!QDELETED(src)) // some grenades don't detonate but we want them destroyed
		qdel(src)

/obj/item/grenade/block_feedback(mob/living/carbon/human/wielder, attack_text, attack_type, do_message = TRUE, do_sound = TRUE)
	if(do_message)
		wielder.visible_message(span_danger("[attack_text] hits [wielder]'s [src], setting it off! What a shot!"))
		return ..(do_message = FALSE, do_sound = FALSE)
	return ..(do_sound = FALSE)

/obj/item/grenade/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(active)
		user.throw_item(interacting_with)
		return ITEM_INTERACT_SUCCESS
	return NONE
