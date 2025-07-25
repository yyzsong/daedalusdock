/* First aid storage
 * Contains:
 * First Aid Kits
 * Pill Bottles
 * Dice Pack (in a pill bottle)
 */

/*
 * First Aid Kits
 */
/obj/item/storage/medkit
	name = "medkit"
	desc = "It's an emergency medical kit for those serious boo-boos."
	icon_state = "medkit"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	throw_range = 7
	storage_type = /datum/storage/latched_box
	var/empty = FALSE
	var/damagetype_healed //defines damage type of the medkit. General ones stay null. Used for medibot healing bonuses

/obj/item/storage/medkit/regular
	icon_state = "medkit"
	desc = "A first aid kit with the ability to heal common types of injuries."

/obj/item/storage/medkit/regular/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins giving [user.p_them()]self aids with \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return BRUTELOSS

/obj/item/storage/medkit/regular/PopulateContents()
	if(empty)
		return
	var/static/items_inside = list(
		/obj/item/stack/gauze = 1,
		/obj/item/stack/medical/bruise_pack = 2,
		/obj/item/stack/medical/mesh = 2,
		/obj/item/reagent_containers/hypospray/medipen = 1,
		/obj/item/stack/splint = 1
	)
	generate_items_inside(items_inside,src)

/obj/item/storage/medkit/emergency
	icon_state = "medbriefcase"
	name = "emergency medkit"
	desc = "A very simple first aid kit meant to secure and stabilize serious wounds for later treatment."

/obj/item/storage/medkit/emergency/PopulateContents()
	if(empty)
		return
	var/static/items_inside = list(
		/obj/item/stack/gauze = 1,
		/obj/item/stack/medical/suture = 1,
		/obj/item/stack/medical/ointment = 1,
		/obj/item/reagent_containers/hypospray/medipen/ekit = 2,
		/obj/item/storage/pill_bottle/iron = 1,
		/obj/item/stack/splint = 1,
	)
	generate_items_inside(items_inside,src)

/obj/item/storage/medkit/surgery
	name = "surgical medkit"
	icon_state = "medkit_surgery"
	inhand_icon_state = "medkit"
	desc = "A high capacity aid kit for doctors, full of medical supplies and basic surgical equipment"

/obj/item/storage/medkit/surgery/Initialize()
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL //holds the same equipment as a medibelt
	atom_storage.max_slots = 12
	atom_storage.max_total_storage = 24
	atom_storage.set_holdable(list(
		/obj/item/healthanalyzer,
		/obj/item/dnainjector,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/cup/beaker,
		/obj/item/reagent_containers/cup/bottle,
		/obj/item/reagent_containers/pill,
		/obj/item/reagent_containers/syringe,
		/obj/item/reagent_containers/medigel,
		/obj/item/reagent_containers/spray,
		/obj/item/lighter,
		/obj/item/storage/fancy/cigarettes,
		/obj/item/storage/pill_bottle,
		/obj/item/stack/medical,
		/obj/item/flashlight/pen,
		/obj/item/extinguisher/mini,
		/obj/item/reagent_containers/hypospray,
		/obj/item/sensor_device,
		/obj/item/radio,
		/obj/item/clothing/gloves,
		/obj/item/lazarus_injector,
		/obj/item/bikehorn/rubberducky,
		/obj/item/clothing/mask/surgical,
		/obj/item/clothing/mask/breath,
		/obj/item/clothing/mask/breath/medical,
		/obj/item/scalpel,
		/obj/item/circular_saw,
		/obj/item/bonesetter,
		/obj/item/surgicaldrill,
		/obj/item/retractor,
		/obj/item/cautery,
		/obj/item/hemostat,
		/obj/item/blood_filter,
		/obj/item/fixovein,
		/obj/item/shears,
		/obj/item/geiger_counter,
		/obj/item/clothing/neck/stethoscope,
		/obj/item/stamp,
		/obj/item/clothing/glasses,
		/obj/item/wrench/medical,
		/obj/item/clothing/mask/muzzle,
		/obj/item/reagent_containers/blood,
		/obj/item/tank/internals/emergency_oxygen,
		/obj/item/gun/syringe/syndicate,
		/obj/item/implantcase,
		/obj/item/implant,
		/obj/item/implanter,
		/obj/item/pinpointer/crew,
		/obj/item/holosign_creator/medical,
		/obj/item/stack/sticky_tape //surgical tape
		))

/obj/item/storage/medkit/surgery/PopulateContents()
	if(empty)
		return
	var/static/items_inside = list(
		/obj/item/healthanalyzer = 1,
		/obj/item/stack/gauze/twelve = 1,
		/obj/item/stack/medical/bruise_pack = 3,
		/obj/item/stack/medical/mesh = 2,
		/obj/item/reagent_containers/hypospray/medipen = 1,
		/obj/item/scalpel = 1,
		/obj/item/hemostat = 1,
		/obj/item/cautery = 1,
		/obj/item/fixovein = 1
		)
	generate_items_inside(items_inside,src)

/obj/item/storage/medkit/ancient
	icon_state = "oldfirstaid"
	desc = "A first aid kit with the ability to heal common types of injuries."

/obj/item/storage/medkit/ancient/PopulateContents()
	if(empty)
		return
	var/static/items_inside = list(
		/obj/item/stack/gauze = 1,
		/obj/item/stack/medical/bruise_pack = 3,
		/obj/item/stack/medical/ointment= 3)
	generate_items_inside(items_inside,src)

/obj/item/storage/medkit/ancient/heirloom
	desc = "A first aid kit with the ability to heal common types of injuries. You start thinking of the good old days just by looking at it."
	empty = TRUE // long since been ransacked by hungry powergaming assistants breaking into med storage

/obj/item/storage/medkit/fire
	name = "burn treatment kit"
	desc = "A specialized medical kit for when the ordnance lab <i>-spontaneously-</i> burns down."
	icon_state = "medkit_burn"
	inhand_icon_state = "medkit-ointment"
	damagetype_healed = BURN

/obj/item/storage/medkit/fire/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins rubbing \the [src] against [user.p_them()]self! It looks like [user.p_theyre()] trying to start a fire!"))
	return FIRELOSS

/obj/item/storage/medkit/fire/PopulateContents()
	if(empty)
		return
	var/static/items_inside = list(
		/obj/item/reagent_containers/pill/kelotane = 3,
		/obj/item/storage/pill_bottle/dermaline = 1,
		/obj/item/reagent_containers/hypospray/medipen/dermaline = 1,
		/obj/item/reagent_containers/hypospray/medipen = 1)
	generate_items_inside(items_inside,src)

/obj/item/storage/medkit/toxin
	name = "toxin treatment kit"
	desc = "Used to treat toxic blood content and radiation poisoning."
	icon_state = "medkit_toxin"
	inhand_icon_state = "medkit-toxin"
	damagetype_healed = TOX

/obj/item/storage/medkit/toxin/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins licking the lead paint off \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return TOXLOSS


/obj/item/storage/medkit/toxin/PopulateContents()
	if(empty)
		return
	var/static/items_inside = list(
		/obj/item/storage/pill_bottle/dylovene/less = 1,
		/obj/item/reagent_containers/syringe/dylovene = 3,
		/obj/item/storage/pill_bottle/potassiodide = 1,
		/obj/item/reagent_containers/hypospray/medipen/dylovene = 1)
	generate_items_inside(items_inside,src)

/obj/item/storage/medkit/o2
	name = "oxygen deprivation treatment kit"
	desc = "A box full of oxygen goodies."
	icon_state = "medkit_o2"
	inhand_icon_state = "medkit-o2"
	damagetype_healed = OXY

/obj/item/storage/medkit/o2/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins hitting [user.p_their()] neck with \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return OXYLOSS

/obj/item/storage/medkit/o2/PopulateContents()
	if(empty)
		return
	var/static/items_inside = list(
		/obj/item/reagent_containers/hypospray/medipen/dexalin = 1,
		/obj/item/reagent_containers/hypospray/medipen = 1,
		/obj/item/storage/pill_bottle/iron = 1)
	generate_items_inside(items_inside,src)

/obj/item/storage/medkit/brute
	name = "brute trauma treatment kit"
	desc = "A first aid kit for when you get toolboxed."
	icon_state = "medkit_brute"
	inhand_icon_state = "medkit-brute"
	damagetype_healed = BRUTE

/obj/item/storage/medkit/brute/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins beating [user.p_them()]self over the head with \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return BRUTELOSS

/obj/item/storage/medkit/brute/PopulateContents()
	if(empty)
		return
	var/static/items_inside = list(
		/obj/item/reagent_containers/pill/bicaridine = 3,
		/obj/item/stack/gauze = 1,
		/obj/item/storage/pill_bottle/meralyne = 1,
		/obj/item/reagent_containers/hypospray/medipen/meralyne = 1,
		/obj/item/stack/splint = 1
	)
	generate_items_inside(items_inside,src)

/obj/item/storage/medkit/advanced
	name = "advanced first aid kit"
	desc = "An advanced kit to help deal with advanced wounds."
	icon_state = "medkit_advanced"
	inhand_icon_state = "medkit-rad"
	custom_premium_price = PAYCHECK_HARD * 6
	damagetype_healed = "all"

/obj/item/storage/medkit/advanced/PopulateContents()
	if(empty)
		return
	var/static/items_inside = list(
		/obj/item/reagent_containers/pill/patch/synthflesh = 3,
		/obj/item/reagent_containers/hypospray/medipen/atropine = 2,
		/obj/item/stack/gauze = 1,
		/obj/item/storage/pill_bottle/dylovene = 1,
		/obj/item/stack/splint = 1
		)
	generate_items_inside(items_inside,src)

/obj/item/storage/medkit/tactical
	name = "combat medical kit"
	desc = "I hope you've got insurance."
	icon_state = "medkit_tactical"
	damagetype_healed = "all"

/obj/item/storage/medkit/tactical/Initialize()
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL

/obj/item/storage/medkit/tactical/PopulateContents()
	if(empty)
		return
	new /obj/item/stack/gauze(src)
	new /obj/item/stack/splint/two(src)
	new /obj/item/defibrillator/compact/combat/loaded(src)
	new /obj/item/reagent_containers/hypospray/combat(src)
	new /obj/item/reagent_containers/pill/bicaridine(src)
	new /obj/item/reagent_containers/pill/bicaridine(src)
	new /obj/item/reagent_containers/pill/kelotane(src)
	new /obj/item/reagent_containers/pill/kelotane(src)
	new /obj/item/clothing/glasses/hud/health/night(src)

//medibot assembly
/obj/item/storage/medkit/attackby(obj/item/bodypart/bodypart, mob/user, params)
	if((!istype(bodypart, /obj/item/bodypart/arm/left/robot)) && (!istype(bodypart, /obj/item/bodypart/arm/right/robot)))
		return ..()

	//Making a medibot!
	if(contents.len >= 1)
		to_chat(user, span_warning("You need to empty [src] out first!"))
		return

	var/obj/item/bot_assembly/medbot/medbot_assembly = new
	if (istype(src, /obj/item/storage/medkit/fire))
		medbot_assembly.set_skin("ointment")
	else if (istype(src, /obj/item/storage/medkit/toxin))
		medbot_assembly.set_skin("tox")
	else if (istype(src, /obj/item/storage/medkit/o2))
		medbot_assembly.set_skin("o2")
	else if (istype(src, /obj/item/storage/medkit/brute))
		medbot_assembly.set_skin("brute")
	else if (istype(src, /obj/item/storage/medkit/advanced))
		medbot_assembly.set_skin("advanced")
	user.put_in_hands(medbot_assembly)
	to_chat(user, span_notice("You add [bodypart] to [src]."))
	medbot_assembly.robot_arm = bodypart.type
	medbot_assembly.medkit_type = type
	qdel(bodypart)
	qdel(src)

/*
 * Pill Bottles
 */

/obj/item/storage/pill_bottle
	name = "pill bottle"
	desc = "It's an airtight container for storing medication."
	icon_state = "pill_canister"
	icon = 'icons/obj/chemical.dmi'
	inhand_icon_state = "contsolid"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	storage_type = /datum/storage/pill_bottle

/obj/item/storage/pill_bottle/Initialize()
	. = ..()
	atom_storage.allow_quick_gather = TRUE
	atom_storage.set_holdable(list(/obj/item/reagent_containers/pill))

/obj/item/storage/pill_bottle/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] is trying to get the cap off [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return (TOXLOSS)

/obj/item/storage/pill_bottle/dylovene
	name = "bottle of dylovene pills"
	desc = "Contains pills used to counter toxins."

/obj/item/storage/pill_bottle/dylovene/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/pill/dylovene(src)

/obj/item/storage/pill_bottle/dylovene/less

/obj/item/storage/pill_bottle/dylovene/less/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/reagent_containers/pill/dylovene(src)

/obj/item/storage/pill_bottle/epinephrine
	name = "bottle of epinephrine pills"
	desc = "Contains pills used to stabilize patients."

/obj/item/storage/pill_bottle/epinephrine/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/pill/epinephrine(src)

/obj/item/storage/pill_bottle/ryetalyn
	name = "bottle of ryetalyn pills"
	desc = "Contains pills used to treat genetic abnormalities."

/obj/item/storage/pill_bottle/ryetalyn/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/pill/ryetalyn(src)

/obj/item/storage/pill_bottle/potassiodide
	name = "bottle of potassium iodide pills"
	desc = "Contains pills used to reduce radiation damage."

/obj/item/storage/pill_bottle/potassiodide/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/pill/potassiodide(src)

/obj/item/storage/pill_bottle/bicaridine
	name = "bottle of bicaridine pills"
	desc = "Contains pills used to treat brute damage."

/obj/item/storage/pill_bottle/bicaridine/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/pill/bicaridine(src)

/obj/item/storage/pill_bottle/meralyne
	name = "bottle of meralyne pills"
	desc = "Contains pills used to treat brute damage."

/obj/item/storage/pill_bottle/meralyne/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/pill/meralyne(src)

/obj/item/storage/pill_bottle/dermaline
	name = "bottle of dermaline pills"
	desc = "Used to treat second and third degree burns."

/obj/item/storage/pill_bottle/dermaline/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/pill/dermaline(src)

/obj/item/storage/pill_bottle/iron
	name = "bottle of iron pills"
	desc = "Contains pills used to reduce blood loss slowly.The tag in the bottle states 'Only take one each five minutes'."

/obj/item/storage/pill_bottle/iron/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/pill/iron(src)

/obj/item/storage/pill_bottle/alkysine
	name = "bottle of alkysine pills"
	desc = "Contains pills used to treat brain damage."

/obj/item/storage/pill_bottle/alkysine/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/pill/alkysine(src)

//Contains 4 pills instead of 7, and 5u pills instead of 50u (50u pills heal 250 brain damage, 5u pills heal 25)
/obj/item/storage/pill_bottle/alkysine/braintumor
	desc = "Contains diluted pills used to treat brain tumor symptoms. Take one when feeling lightheaded."

/obj/item/storage/pill_bottle/alkysine/braintumor/PopulateContents()
	for(var/i in 1 to 4)
		new /obj/item/reagent_containers/pill/alkysine/braintumor(src)

/obj/item/storage/pill_bottle/stimulant
	name = "bottle of stimulant pills"
	desc = "Guaranteed to give you that extra burst of energy during a long shift!"

/obj/item/storage/pill_bottle/stimulant/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/pill/stimulant(src)

/obj/item/storage/pill_bottle/mining
	name = "bottle of patches"
	desc = "Contains patches used to treat brute and burn damage."

/obj/item/storage/pill_bottle/mining/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/reagent_containers/pill/kelotane(src)
	for(var/i in 1 to 3)
		new /obj/item/reagent_containers/pill/bicaridine(src)

/obj/item/storage/pill_bottle/zoom
	name = "suspicious pill bottle"
	desc = "The label is pretty old and almost unreadable, you recognize some chemical compounds."

/obj/item/storage/pill_bottle/zoom/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/pill/zoom(src)

/obj/item/storage/pill_bottle/happy
	name = "suspicious pill bottle"
	desc = "There is a smiley on the top."

/obj/item/storage/pill_bottle/happy/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/pill/happy(src)

/obj/item/storage/pill_bottle/lsd
	name = "suspicious pill bottle"
	desc = "There is a crude drawing which could be either a mushroom, or a deformed moon."

/obj/item/storage/pill_bottle/lsd/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/pill/lsd(src)

/obj/item/storage/pill_bottle/aranesp
	name = "suspicious pill bottle"
	desc = "The label has 'fuck disablers' hastily scrawled in black marker."

/obj/item/storage/pill_bottle/aranesp/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/pill/aranesp(src)

/obj/item/storage/pill_bottle/alkysine
	name = "bottle of alkysine pills"
	desc = "Contains pills used to treat mental distress and traumas."

/obj/item/storage/pill_bottle/alkysine/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/pill/alkysine(src)

/obj/item/storage/pill_bottle/maintenance_pill
	name = "bottle of maintenance pills"
	desc = "An old pill bottle. It smells musty."

/obj/item/storage/pill_bottle/maintenance_pill/Initialize(mapload)
	. = ..()
	var/obj/item/reagent_containers/pill/P = locate() in src
	name = "bottle of [P.name]s"

/obj/item/storage/pill_bottle/maintenance_pill/PopulateContents()
	for(var/i in 1 to rand(1,7))
		new /obj/item/reagent_containers/pill/maintenance(src)

/obj/item/storage/pill_bottle/maintenance_pill/full/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/pill/maintenance(src)

///////////////////////////////////////// Psychologist inventory pillbottles
/obj/item/storage/pill_bottle/lsdpsych
	name = "mindbreaker toxin pills"
	desc = "!FOR THERAPEUTIC USE ONLY! Contains pills used to alleviate the symptoms of Reality Dissociation Syndrome."

/obj/item/storage/pill_bottle/lsdpsych/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/pill/lsdpsych(src)

/obj/item/storage/pill_bottle/paxpsych
	name = "pax pills"
	desc = "Contains pills used to temporarily pacify patients that are deemed a harm to themselves or others."

/obj/item/storage/pill_bottle/paxpsych/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/pill/paxpsych(src)

/obj/item/storage/pill_bottle/haloperidol
	name = "haloperidol pill bottle"
	desc = "Contains pills of a sedative that treats hallucinations and flushes narcotics from the system."

/obj/item/storage/pill_bottle/haloperidol/PopulateContents()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/pill/haloperidol(src)

/obj/item/storage/organbox
	name = "organ transport box"
	desc = "An advanced box with an cooling mechanism that uses cryostylane or other cold reagents to keep the organs or bodyparts inside preserved."
	icon_state = "organbox"
	base_icon_state = "organbox"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	throw_range = 7
	custom_premium_price = PAYCHECK_MEDIUM * 4
	/// var to prevent it freezing the same things over and over
	var/cooling = FALSE

/obj/item/storage/organbox/Initialize(mapload)
	. = ..()

	create_storage(type = /datum/storage/organ_box, max_specific_storage = WEIGHT_CLASS_BULKY, max_total_storage = 21)
	atom_storage.set_holdable(list(
		/obj/item/organ,
		/obj/item/bodypart,
		/obj/item/food/icecream
		))

/obj/item/storage/organbox/update_icon_state()
	icon_state = "[base_icon_state][cooling ? "-working" : null]"
	return ..()

/obj/item/storage/organbox/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(isinternalorgan(arrived))
		var/obj/item/organ/int_organ = arrived
		int_organ.organ_flags |= ORGAN_FROZEN
		return
	if(istype(arrived, /obj/item/bodypart))
		var/obj/item/bodypart/B = arrived
		for(var/obj/item/organ/int_organ in B.contents)
			int_organ.organ_flags |= ORGAN_FROZEN

/obj/item/storage/organbox/Exited(atom/movable/gone, direction)
	. = ..()
	if(isinternalorgan(gone))
		var/obj/item/organ/int_organ = gone
		int_organ.organ_flags &= ~ORGAN_FROZEN
		return
	if(istype(gone, /obj/item/bodypart))
		var/obj/item/bodypart/B = gone
		for(var/obj/item/organ/int_organ in B.contents)
			int_organ.organ_flags &= ~ORGAN_FROZEN

/obj/item/storage/organbox/suicide_act(mob/living/carbon/user)
	if(HAS_TRAIT(user, TRAIT_RESISTCOLD)) //if they're immune to cold, just do the box suicide
		var/obj/item/bodypart/head/myhead = user.get_bodypart(BODY_ZONE_HEAD)
		if(myhead)
			user.visible_message(span_suicide("[user] puts [user.p_their()] head into \the [src] and begins closing it! It looks like [user.p_theyre()] trying to commit suicide!"))
			myhead.dismember()
			myhead.forceMove(src) //force your enemies to kill themselves with your head collection box!
			playsound(user, "desecration-01.ogg", 50, TRUE, -1)
			return BRUTELOSS
		user.visible_message(span_suicide("[user] is beating [user.p_them()]self with \the [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
		return BRUTELOSS
	user.visible_message(span_suicide("[user] is putting [user.p_their()] head inside the [src], it looks like [user.p_theyre()] trying to commit suicide!"))
	user.adjust_bodytemperature(-300)
	user.apply_status_effect(/datum/status_effect/freon)
	return FIRELOSS
