/**
 * # Generic restraints
 *
 * Parent class for handcuffs and handcuff accessories
 *
 * Functionality:
 * 1. A special suicide
 * 2. If a restraint is handcuffing/legcuffing a carbon while being deleted, it will remove the handcuff/legcuff status.
*/
/obj/item/restraints
	breakouttime = 1 MINUTES
	dye_color = DYE_PRISONER
	icon = 'icons/obj/restraints.dmi'

/obj/item/restraints/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] is strangling [user.p_them()]self with [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return(OXYLOSS)

/**
 * # Handcuffs
 *
 * Stuff that makes humans unable to use hands
 *
 * Clicking people with those will cause an attempt at handcuffing them to occur
*/
TYPEINFO_DEF(/obj/item/restraints/handcuffs)
	default_armor = list(BLUNT = 0, PUNCTURE = 0, SLASH = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 50, ACID = 50)
	default_materials = list(/datum/material/iron=500)

/obj/item/restraints/handcuffs
	name = "handcuffs"
	desc = "Use this to keep prisoners in line."
	gender = PLURAL
	icon_state = "handcuff"
	worn_icon_state = "handcuff"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT

	throwforce = 2
	force = 8

	w_class = WEIGHT_CLASS_SMALL
	throw_range = 5
	breakouttime = 1 MINUTES
	custom_price = PAYCHECK_HARD * 0.35

	/// Time it takes to apply handcuffs.
	var/handcuff_time = 3 SECONDS
	///Sound that plays when starting to put handcuffs on someone
	var/cuffsound = 'sound/weapons/handcuffs.ogg'
	///If set, handcuffs will be destroyed on application and leave behind whatever this is set to.
	var/trashtype = null

/obj/item/restraints/handcuffs/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	var/mob/living/carbon/C = interacting_with
	if(!istype(C))
		return NONE

	SEND_SIGNAL(C, COMSIG_CARBON_CUFF_ATTEMPTED, user)

	user.do_item_attack_animation(interacting_with, used_item = src)

	if(iscarbon(user) && (HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))) //Clumsy people have a 50% chance to handcuff themselves instead of their target.
		to_chat(user, span_warning("Uh... how do those things work?!"))
		apply_cuffs(user,user)
		return ITEM_INTERACT_SUCCESS

	if(C.handcuffed)
		return ITEM_INTERACT_BLOCKING

	if(!C.canBeHandcuffed())
		to_chat(user, span_warning("You cannot handcuff [C]."))
		return ITEM_INTERACT_BLOCKING

	C.visible_message(span_danger("<b>[user]</b> is trying to put <b>[name]</b> on [C]."))

	if(C.is_blind())
		to_chat(C, span_userdanger("You feel someone grab your wrists, the cold metal of [name] starting to dig into your skin."))

	playsound(loc, cuffsound, 30, TRUE, -2)
	log_combat(user, C, "attempted to handcuff")

	if(do_after(user, C, handcuff_time, timed_action_flags = DO_IGNORE_SLOWDOWNS|DO_PUBLIC, display = src) && C.canBeHandcuffed())
		if(!apply_cuffs(C, user, iscyborg(user)))
			to_chat(user, span_warning("You fail to handcuff [C]."))
			log_combat(user, C, "failed to handcuff")
			return ITEM_INTERACT_BLOCKING

		C.visible_message(span_notice("<b>[user] handcuffs <b>[C]</b>."))
		SSblackbox.record_feedback("tally", "handcuffs", 1, type)

		log_combat(user, C, "handcuffed")
	else
		to_chat(user, span_warning("You fail to handcuff [C]!"))
		log_combat(user, C, "failed to handcuff")

	return ITEM_INTERACT_SUCCESS

/**
 * This handles handcuffing people
 *
 * When called, this instantly puts handcuffs on someone (if possible)
 * Arguments:
 * * mob/living/carbon/target - Who is being handcuffed
 * * mob/user - Who or what is doing the handcuffing
 * * dispense - True if the cuffing should create a new item instead of using putting src on the mob, false otherwise. False by default.
*/
/obj/item/restraints/handcuffs/proc/apply_cuffs(mob/living/carbon/target, mob/user, dispense = FALSE)
	if(target.handcuffed)
		return

	if(!dispense && !user.temporarilyRemoveItemFromInventory(src))
		return

	var/obj/item/restraints/handcuffs/cuffs = src
	if(trashtype)
		cuffs = new trashtype()
	else if(dispense)
		cuffs = new type()

	if(!target.equip_to_slot_if_possible(cuffs, ITEM_SLOT_HANDCUFFED, cuffs != src, TRUE, null, TRUE))
		if(!QDELETED(cuffs))
			if(!user.put_in_hands(cuffs))
				forceMove(user.drop_location())
		return FALSE

	if(trashtype && !dispense)
		qdel(src)

	return TRUE

/**
 * # Alien handcuffs
 *
 * Abductor reskin of the handcuffs.
*/
/obj/item/restraints/handcuffs/alien
	icon_state = "handcuffAlien"

/**
 *
 * # Fake handcuffs
 *
 * Fake handcuffs that can be removed near-instantly.
*/
/obj/item/restraints/handcuffs/fake
	name = "fake handcuffs"
	desc = "Fake handcuffs meant for gag purposes."
	breakouttime = 1 SECONDS

/**
 * # Cable restraints
 *
 * Ghetto handcuffs. Removing those is faster.
*/
TYPEINFO_DEF(/obj/item/restraints/handcuffs/cable)
	default_materials = list(/datum/material/iron=150, /datum/material/glass=75)

/obj/item/restraints/handcuffs/cable
	name = "cable restraints"
	desc = "Looks like some cables tied together. Could be used to tie something up."
	icon_state = "cuff"
	inhand_icon_state = "coil"
	color = "#ff0000"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	breakouttime = 30 SECONDS
	cuffsound = 'sound/weapons/cablecuff.ogg'

/**
 * # Sinew restraints
 *
 * Primal ghetto handcuffs
 *
 * Just cable restraints that look differently and can't be recycled.
*/
TYPEINFO_DEF(/obj/item/restraints/handcuffs/cable/sinew)
	default_materials = null

/obj/item/restraints/handcuffs/cable/sinew
	name = "sinew restraints"
	desc = "A pair of restraints fashioned from long strands of flesh."
	icon_state = "sinewcuff"
	inhand_icon_state = "sinewcuff"
	color = null

/**
 * Red cable restraints
*/
/obj/item/restraints/handcuffs/cable/red
	color = "#ff0000"

/**
 * Yellow cable restraints
*/
/obj/item/restraints/handcuffs/cable/yellow
	color = "#ffff00"

/**
 * Blue cable restraints
*/
/obj/item/restraints/handcuffs/cable/blue
	color = "#1919c8"

/**
 * Green cable restraints
*/
/obj/item/restraints/handcuffs/cable/green
	color = "#00aa00"

/**
 * Pink cable restraints
*/
/obj/item/restraints/handcuffs/cable/pink
	color = "#ff3ccd"

/**
 * Orange (the color) cable restraints
*/
/obj/item/restraints/handcuffs/cable/orange
	color = "#ff8000"

/**
 * Cyan cable restraints
*/
/obj/item/restraints/handcuffs/cable/cyan
	color = "#00ffff"

/**
 * White cable restraints
*/
/obj/item/restraints/handcuffs/cable/white
	color = null

/**
 * # Zipties
 *
 * One-use handcuffs that take 45 seconds to resist out of instead of one minute. This turns into the used version when applied.
*/
TYPEINFO_DEF(/obj/item/restraints/handcuffs/cable/zipties)
	default_materials = null

/obj/item/restraints/handcuffs/cable/zipties
	name = "zipties"
	desc = "Plastic, disposable zipties that can be used to restrain temporarily but are destroyed after use."
	icon_state = "cuff"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	breakouttime = 45 SECONDS
	trashtype = /obj/item/restraints/handcuffs/cable/zipties/used
	color = null

/**
 * # Used zipties
 *
 * What zipties turn into when applied. These can't be used to cuff people.
*/
/obj/item/restraints/handcuffs/cable/zipties/used
	desc = "A pair of broken zipties."
	icon_state = "cuff_used"
	inhand_icon_state = "cuff"

/obj/item/restraints/handcuffs/cable/zipties/used/attack()
	return

/**
 * # Fake Zipties
 *
 * One-use handcuffs that is very easy to break out of, meant as a one-use alternative to regular fake handcuffs.
 */
/obj/item/restraints/handcuffs/cable/zipties/fake
	name = "fake zipties"
	desc = "Fake zipties meant for gag purposes."
	breakouttime = 1 SECONDS

/obj/item/restraints/handcuffs/cable/zipties/fake/used
	desc = "A pair of broken fake zipties."
	icon_state = "cuff_used"
	inhand_icon_state = "cuff"

/**
 * # Tape handcuffs
 *
 * Handcuffs applied when restraining someone with tape, easier to escape from than zipties and single use.
 */
/obj/item/restraints/handcuffs/tape
	name = "length of tape"
	desc = "Seems you are in a sticky situation."
	icon_state = "handcuffTape"
	breakouttime = 15 SECONDS
	item_flags = DROPDEL

/**
 * # Generic leg cuffs
 *
 * Parent class for everything that can legcuff carbons. Can't legcuff anything itself.
*/
/obj/item/restraints/legcuffs
	name = "leg cuffs"
	desc = "Use this to keep prisoners in line."
	gender = PLURAL
	icon_state = "handcuff"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	flags_1 = CONDUCT_1
	throwforce = 0
	w_class = WEIGHT_CLASS_NORMAL
	slowdown = 7
	breakouttime = 30 SECONDS

/**
 * # Bear trap
 *
 * This opens, closes, and bites people's legs.
 */
/obj/item/restraints/legcuffs/beartrap
	name = "bear trap"
	throw_speed = 1
	throw_range = 1
	icon_state = "beartrap"
	desc = "A trap used to catch bears and other legged creatures."
	///If true, the trap is "open" and can trigger.
	var/armed = FALSE
	///How much damage the trap deals when triggered.
	var/trap_damage = 20

/obj/item/restraints/legcuffs/beartrap/Initialize(mapload)
	. = ..()
	update_appearance()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(spring_trap),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/item/restraints/legcuffs/beartrap/update_icon_state()
	icon_state = "[initial(icon_state)][armed]"
	return ..()

/obj/item/restraints/legcuffs/beartrap/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] is sticking [user.p_their()] head in the [src.name]! It looks like [user.p_theyre()] trying to commit suicide!"))
	playsound(loc, 'sound/weapons/bladeslice.ogg', 50, TRUE, -1)
	return (BRUTELOSS)

/obj/item/restraints/legcuffs/beartrap/attack_self(mob/user)
	. = ..()
	if(!ishuman(user) || user.stat != CONSCIOUS || HAS_TRAIT(user, TRAIT_HANDS_BLOCKED))
		return
	armed = !armed
	update_appearance()
	to_chat(user, span_notice("[src] is now [armed ? "armed" : "disarmed"]"))

/**
 * Closes a bear trap
 *
 * Closes a bear trap.
 * Arguments:
 */
/obj/item/restraints/legcuffs/beartrap/proc/close_trap()
	armed = FALSE
	update_appearance()
	playsound(src, 'sound/effects/snap.ogg', 50, TRUE)

/obj/item/restraints/legcuffs/beartrap/proc/spring_trap(datum/source, atom/movable/AM, thrown_at = FALSE)
	SIGNAL_HANDLER
	if(AM == src)
		return
	if(!armed || !isturf(loc) || !isliving(AM))
		return
	var/mob/living/L = AM
	var/snap = TRUE
	if(istype(L.buckled, /obj/vehicle))
		var/obj/vehicle/ridden_vehicle = L.buckled
		if(!ridden_vehicle.are_legs_exposed) //close the trap without injuring/trapping the rider if their legs are inside the vehicle at all times.
			close_trap()
			ridden_vehicle.visible_message(span_danger("[ridden_vehicle] triggers \the [src]."))

	if(!thrown_at && L.movement_type & (FLYING|FLOATING)) //don't close the trap if they're flying/floating over it.
		snap = FALSE

	var/def_zone = BODY_ZONE_CHEST
	if(snap && iscarbon(L))
		var/mob/living/carbon/C = L
		if(C.body_position == STANDING_UP)
			def_zone = pick(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
			if(!C.legcuffed && C.num_legs >= 2) //beartrap can't cuff your leg if there's already a beartrap or legcuffs, or you don't have two legs.
				INVOKE_ASYNC(C, TYPE_PROC_REF(/mob/living/carbon, equip_to_slot), src, ITEM_SLOT_LEGCUFFED)
				SSblackbox.record_feedback("tally", "handcuffs", 1, type)
	else if(snap && isanimal(L))
		var/mob/living/simple_animal/SA = L
		if(SA.mob_size <= MOB_SIZE_TINY) //don't close the trap if they're as small as a mouse.
			snap = FALSE
	if(snap)
		close_trap()
		if(!thrown_at)
			L.visible_message(span_danger("[L] triggers \the [src]."), \
					span_userdanger("You trigger \the [src]!"))
		else
			L.visible_message(span_danger("\The [src] ensnares [L]!"), \
					span_userdanger("\The [src] ensnares you!"))
		L.apply_damage(trap_damage, BRUTE, def_zone)

/**
 * # Energy snare
 *
 * This closes on people's legs.
 *
 * A weaker version of the bear trap that can be resisted out of faster and disappears
 */
/obj/item/restraints/legcuffs/beartrap/energy
	name = "energy snare"
	armed = 1
	icon_state = "e_snare"
	trap_damage = 0
	breakouttime = 3 SECONDS
	item_flags = DROPDEL
	flags_1 = NONE

/obj/item/restraints/legcuffs/beartrap/energy/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(dissipate)), 100)

/**
 * Handles energy snares disappearing
 *
 * If the snare isn't closed on anyone, it will disappear in a shower of sparks.
 * Arguments:
 */
/obj/item/restraints/legcuffs/beartrap/energy/proc/dissipate()
	if(!equipped_to)
		do_sparks(1, TRUE, src)
		qdel(src)

/obj/item/restraints/legcuffs/beartrap/energy/attack_hand(mob/user, list/modifiers)
	spring_trap(null, user)
	return ..()

/obj/item/restraints/legcuffs/beartrap/energy/cyborg
	breakouttime = 2 SECONDS // Cyborgs shouldn't have a strong restraint

/obj/item/restraints/legcuffs/bola
	name = "bola"
	desc = "A restraining device designed to be thrown at the target. Upon connecting with said target, it will wrap around their legs, making it difficult for them to move quickly."
	icon_state = "bola"
	inhand_icon_state = "bola"
	lefthand_file = 'icons/mob/inhands/weapons/thrown_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/thrown_righthand.dmi'
	breakouttime = 3.5 SECONDS//easy to apply, easy to break out of
	gender = NEUTER
	///Amount of time to knock the target down for once it's hit in deciseconds.
	var/knockdown = 0

/obj/item/restraints/legcuffs/bola/throw_at(atom/target, range, speed, mob/thrower, spin=1, diagonals_first = 0, datum/callback/callback, gentle = FALSE, quickstart = TRUE)
	if(!..())
		return
	playsound(src.loc,'sound/weapons/bolathrow.ogg', 75, TRUE)

/obj/item/restraints/legcuffs/bola/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(..() || !iscarbon(hit_atom))//if it gets caught or the target can't be cuffed,
		return//abort
	ensnare(hit_atom)

/**
 * Attempts to legcuff someone with the bola
 *
 * Arguments:
 * * C - the carbon that we will try to ensnare
 */
/obj/item/restraints/legcuffs/bola/proc/ensnare(mob/living/carbon/C)
	if(!C.legcuffed && C.num_legs >= 2)
		visible_message(span_danger("\The [src] ensnares [C]!"), span_userdanger("\The [src] ensnares you!"))
		C.equip_to_slot(src, ITEM_SLOT_LEGCUFFED)
		SSblackbox.record_feedback("tally", "handcuffs", 1, type)
		C.Knockdown(knockdown)
		playsound(src, 'sound/effects/snap.ogg', 50, TRUE)

/**
 * A traitor variant of the bola.
 *
 * It knocks people down and is harder to remove.
 */
/obj/item/restraints/legcuffs/bola/tactical
	name = "reinforced bola"
	desc = "A strong bola, made with a long steel chain. It looks heavy, enough so that it could trip somebody."
	icon_state = "bola_r"
	inhand_icon_state = "bola_r"
	breakouttime = 7 SECONDS
	knockdown = 3.5 SECONDS

/**
 * A security variant of the bola.
 *
 * It's harder to remove, smaller and has a defined price.
 */
/obj/item/restraints/legcuffs/bola/energy
	name = "energy bola"
	desc = "A specialized hard-light bola designed to ensnare fleeing criminals and aid in arrests."
	icon_state = "ebola"
	inhand_icon_state = "ebola"
	hitsound = 'sound/weapons/taserhit.ogg'
	w_class = WEIGHT_CLASS_SMALL
	breakouttime = 6 SECONDS
	custom_price = PAYCHECK_HARD * 0.35

/obj/item/restraints/legcuffs/bola/energy/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_UNCATCHABLE, TRAIT_GENERIC) // People said energy bolas being uncatchable is a feature.

/obj/item/restraints/legcuffs/bola/energy/ensnare(atom/hit_atom)
	var/obj/item/restraints/legcuffs/beartrap/energy/cyborg/B = new (get_turf(hit_atom))
	B.spring_trap(null, hit_atom, TRUE)
	qdel(src)

/**
 * A pacifying variant of the bola.
 *
 * It's much harder to remove, doesn't cause a slowdown and gives people /datum/status_effect/gonbola_pacify.
 */
/obj/item/restraints/legcuffs/bola/gonbola
	name = "gonbola"
	desc = "Hey, if you have to be hugged in the legs by anything, it might as well be this little guy."
	icon_state = "gonbola"
	inhand_icon_state = "bola_r"
	breakouttime = 30 SECONDS
	slowdown = 0
	var/datum/status_effect/gonbola_pacify/effectReference

/obj/item/restraints/legcuffs/bola/gonbola/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(iscarbon(hit_atom))
		var/mob/living/carbon/C = hit_atom
		effectReference = C.apply_status_effect(/datum/status_effect/gonbola_pacify)

/obj/item/restraints/legcuffs/bola/gonbola/unequipped(mob/user)
	. = ..()
	if(effectReference)
		QDEL_NULL(effectReference)
