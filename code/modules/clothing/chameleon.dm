#define EMP_RANDOMISE_TIME 300

/datum/action/item_action/chameleon/drone/randomise
	name = "Randomise Headgear"
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "random"

/datum/action/item_action/chameleon/drone/randomise/Trigger(trigger_flags)
	if(!IsAvailable())
		return

	// Damn our lack of abstract interfeces
	if (istype(target, /obj/item/clothing/head/chameleon/drone))
		var/obj/item/clothing/head/chameleon/drone/X = target
		X.chameleon_action.random_look(owner)
	if (istype(target, /obj/item/clothing/mask/chameleon/drone))
		var/obj/item/clothing/mask/chameleon/drone/Z = target
		Z.chameleon_action.random_look(owner)

	return 1


/datum/action/item_action/chameleon/drone/togglehatmask
	name = "Toggle Headgear Mode"
	button_icon = 'icons/mob/actions/actions_silicon.dmi'

/datum/action/item_action/chameleon/drone/togglehatmask/New()
	..()

	if (istype(target, /obj/item/clothing/head/chameleon/drone))
		button_icon_state = "drone_camogear_helm"
	if (istype(target, /obj/item/clothing/mask/chameleon/drone))
		button_icon_state = "drone_camogear_mask"

/datum/action/item_action/chameleon/drone/togglehatmask/Trigger(trigger_flags)
	if(!IsAvailable())
		return

	// No point making the code more complicated if no non-drone
	// is ever going to use one of these

	var/mob/living/simple_animal/drone/D

	if(istype(owner, /mob/living/simple_animal/drone))
		D = owner
	else
		return

	// The drone unEquip() proc sets head to null after dropping
	// an item, so we need to keep a reference to our old headgear
	// to make sure it's deleted.
	var/obj/old_headgear = target
	var/obj/new_headgear

	if(istype(old_headgear, /obj/item/clothing/head/chameleon/drone))
		new_headgear = new /obj/item/clothing/mask/chameleon/drone()
	else if(istype(old_headgear, /obj/item/clothing/mask/chameleon/drone))
		new_headgear = new /obj/item/clothing/head/chameleon/drone()
	else
		to_chat(owner, span_warning("You shouldn't be able to toggle a camogear helmetmask if you're not wearing it."))
	if(new_headgear)
		// Force drop the item in the headslot, even though
		// it's has TRAIT_NODROP
		D.dropItemToGround(target, TRUE)
		qdel(old_headgear)
		// where is `ITEM_SLOT_HEAD` defined? WHO KNOWS
		D.equip_to_slot(new_headgear, ITEM_SLOT_HEAD)
	return 1


/datum/action/chameleon_outfit
	name = "Select Chameleon Outfit"
	button_icon_state = "chameleon_outfit"
	var/list/outfit_options //By default, this list is shared between all instances. It is not static because if it were, subtypes would not be able to have their own. If you ever want to edit it, copy it first.

/datum/action/chameleon_outfit/New()
	..()
	initialize_outfits()

/datum/action/chameleon_outfit/proc/initialize_outfits()
	var/static/list/standard_outfit_options
	if(!standard_outfit_options)
		standard_outfit_options = list()
		for(var/path in subtypesof(/datum/outfit/job))
			var/datum/outfit/O = path
			standard_outfit_options[initial(O.name)] = path
		sortTim(standard_outfit_options, GLOBAL_PROC_REF(cmp_text_asc))
	outfit_options = standard_outfit_options

/datum/action/chameleon_outfit/Trigger(trigger_flags)
	return select_outfit(owner)

/datum/action/chameleon_outfit/proc/select_outfit(mob/user)
	if(!user || !IsAvailable())
		return FALSE
	var/selected = tgui_input_list(user, "Select outfit to change into", "Chameleon Outfit", outfit_options)
	if(isnull(selected))
		return FALSE
	if(!IsAvailable() || QDELETED(src) || QDELETED(user))
		return FALSE
	if(isnull(outfit_options[selected]))
		return FALSE
	var/outfit_type = outfit_options[selected]
	var/datum/outfit/job/O = new outfit_type()
	var/list/outfit_types = O.get_chameleon_disguise_info()
	var/datum/job/job_datum = SSjob.GetJobType(O.jobtype)

	for(var/V in user.chameleon_item_actions)
		var/datum/action/item_action/chameleon/change/A = V
		var/done = FALSE
		for(var/T in outfit_types)
			for(var/name in A.chameleon_list)
				if(A.chameleon_list[name] == T)
					A.apply_job_data(job_datum)
					A.update_look(user, T)
					outfit_types -= T
					done = TRUE
					break
			if(done)
				break

	//suit hoods
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		//make sure they are actually wearing the suit, not just holding it, and that they have a chameleon hat
		if(istype(H.wear_suit, /obj/item/clothing/suit/chameleon) && istype(H.head, /obj/item/clothing/head/chameleon))
			var/helmet_type
			if(ispath(O.suit, /obj/item/clothing/suit/hooded))
				var/obj/item/clothing/suit/hooded/hooded = O.suit
				helmet_type = initial(hooded.hoodtype)
			if(helmet_type)
				var/obj/item/clothing/head/chameleon/hat = H.head
				hat.chameleon_action.update_look(user, helmet_type)
	qdel(O)
	return TRUE


/datum/action/item_action/chameleon/change
	name = "Chameleon Change"
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_HANDS_BLOCKED
	var/list/chameleon_blacklist = list() //This is a typecache
	var/list/chameleon_list = list()
	var/chameleon_type = null
	var/chameleon_name = "Item"

	var/emp_timer

/datum/action/item_action/chameleon/change/Grant(mob/M)
	if(M && (owner != M))
		if(!M.chameleon_item_actions)
			M.chameleon_item_actions = list(src)
			var/datum/action/chameleon_outfit/O = new /datum/action/chameleon_outfit()
			O.Grant(M)
		else
			M.chameleon_item_actions |= src
	..()

/datum/action/item_action/chameleon/change/Remove(mob/M)
	if(M && (M == owner))
		LAZYREMOVE(M.chameleon_item_actions, src)
		if(!LAZYLEN(M.chameleon_item_actions))
			var/datum/action/chameleon_outfit/O = locate(/datum/action/chameleon_outfit) in M.actions
			qdel(O)
	..()

/datum/action/item_action/chameleon/change/proc/initialize_disguises()
	name = "Change [chameleon_name] Appearance"
	build_all_button_icons()

	chameleon_blacklist |= typecacheof(target.type)
	for(var/V in typesof(chameleon_type))
		if(ispath(V) && ispath(V, /obj/item))
			var/obj/item/I = V
			if(chameleon_blacklist[V] || (initial(I.item_flags) & ABSTRACT) || !initial(I.icon_state))
				continue
			var/chameleon_item_name = "[initial(I.name)] ([initial(I.icon_state)])"
			chameleon_list[chameleon_item_name] = I


/datum/action/item_action/chameleon/change/proc/select_look(mob/user)
	var/obj/item/picked_item
	var/picked_name = tgui_input_list(user, "Select [chameleon_name] to change into", "Chameleon Settings", sort_list(chameleon_list, GLOBAL_PROC_REF(cmp_typepaths_asc)))
	if(isnull(picked_name))
		return
	if(isnull(chameleon_list[picked_name]))
		return
	picked_item = chameleon_list[picked_name]
	update_look(user, picked_item)

/datum/action/item_action/chameleon/change/proc/random_look(mob/user)
	var/picked_name = pick(chameleon_list)
	// If a user is provided, then this item is in use, and we
	// need to update our icons and stuff

	if(user)
		update_look(user, chameleon_list[picked_name])

	// Otherwise, it's likely a random initialisation, so we
	// don't have to worry

	else
		update_item(chameleon_list[picked_name])

/datum/action/item_action/chameleon/change/proc/update_look(mob/user, obj/item/picked_item)
	if(isliving(user))
		var/mob/living/C = user
		if(C.stat != CONSCIOUS)
			return

		update_item(picked_item)
		var/obj/item/thing = target
		thing.update_slot_icon()
	build_all_button_icons()

/datum/action/item_action/chameleon/change/proc/update_item(obj/item/picked_item)
	var/atom/atom_target = target
	atom_target.name = initial(picked_item.name)
	atom_target.desc = initial(picked_item.desc)
	atom_target.icon_state = initial(picked_item.icon_state)
	if(isitem(atom_target))
		var/obj/item/item_target = target
		item_target.worn_icon = initial(picked_item.worn_icon)
		item_target.lefthand_file = initial(picked_item.lefthand_file)
		item_target.righthand_file = initial(picked_item.righthand_file)
		item_target.supports_variations_flags = initial(picked_item.supports_variations_flags)
		if(initial(picked_item.greyscale_colors))
			if(initial(picked_item.greyscale_config_worn))
				item_target.worn_icon = SSgreyscale.GetColoredIconByType(initial(picked_item.greyscale_config_worn), initial(picked_item.greyscale_colors))
			if(initial(picked_item.greyscale_config_inhand_left))
				item_target.lefthand_file = SSgreyscale.GetColoredIconByType(initial(picked_item.greyscale_config_inhand_left), initial(picked_item.greyscale_colors))
			if(initial(picked_item.greyscale_config_inhand_right))
				item_target.righthand_file = SSgreyscale.GetColoredIconByType(initial(picked_item.greyscale_config_inhand_right), initial(picked_item.greyscale_colors))
		item_target.worn_icon_state = initial(picked_item.worn_icon_state)
		item_target.inhand_icon_state = initial(picked_item.inhand_icon_state)
		if(istype(item_target, /obj/item/clothing) && ispath(picked_item, /obj/item/clothing))
			var/obj/item/clothing/clothing_target = item_target
			var/obj/item/clothing/picked_clothing = picked_item
			clothing_target.flags_cover = initial(picked_clothing.flags_cover)
	if(initial(picked_item.greyscale_config) && initial(picked_item.greyscale_colors))
		atom_target.icon = SSgreyscale.GetColoredIconByType(initial(picked_item.greyscale_config), initial(picked_item.greyscale_colors))
	else
		atom_target.icon = initial(picked_item.icon)

/datum/action/item_action/chameleon/change/Trigger(trigger_flags)
	if(!IsAvailable())
		return

	select_look(owner)
	return 1

/datum/action/item_action/chameleon/change/proc/emp_randomise(amount = EMP_RANDOMISE_TIME)
	START_PROCESSING(SSprocessing, src)
	random_look(owner)

	var/new_value = world.time + amount
	if(new_value > emp_timer)
		emp_timer = new_value

/datum/action/item_action/chameleon/change/process()
	if(world.time > emp_timer)
		STOP_PROCESSING(SSprocessing, src)
		return
	random_look(owner)

/datum/action/item_action/chameleon/change/proc/apply_job_data(datum/job/job_datum)
	return

/datum/action/item_action/chameleon/change/id/update_item(obj/item/picked_item)
	..()
	var/obj/item/card/id/advanced/chameleon/agent_card = target
	if(istype(agent_card))
		var/obj/item/card/id/copied_card = picked_item

		// If the outfit comes with a special template override, we'll steal some stuff from that.
		var/new_template = initial(copied_card.template)

		if(new_template)
			SSid_access.apply_template_to_chameleon_card(agent_card, new_template, TRUE)

		// If the ID card hasn't been forged, we'll check if there has been an assignment set already by any new template.
		// If there has not, we set the assignment to the copied card's default as well as copying over the the
		// default registered name from the copied card.
		if(!agent_card.forged)
			if(!agent_card.assignment)
				agent_card.assignment = initial(copied_card.assignment)

			agent_card.registered_name = initial(copied_card.registered_name)

		agent_card.icon_state = initial(copied_card.icon_state)
		if(ispath(copied_card, /obj/item/card/id/advanced))
			var/obj/item/card/id/advanced/copied_advanced_card = copied_card
			agent_card.assigned_icon_state = initial(copied_advanced_card.assigned_icon_state)

		agent_card.update_label()
		agent_card.update_icon()

/datum/action/item_action/chameleon/change/id/apply_job_data(datum/job/job_datum)
	..()
	var/obj/item/card/id/advanced/chameleon/agent_card = target
	if(istype(agent_card) && istype(job_datum))
		agent_card.forged = TRUE

		// job_outfit is going to be a path.
		var/datum/outfit/job/job_outfit = job_datum.outfit
		if(!job_outfit)
			return

		// copied_card is also going to be a path.
		var/obj/item/card/id/copied_card = initial(job_outfit.id)
		if(!copied_card)
			return

		// If the outfit comes with a special template override, we'll use that. Otherwise, use the card's default template. Failing that, no template at all.
		var/new_template = initial(job_outfit.id_template) ? initial(job_outfit.id_template) : initial(copied_card.template)

		if(new_template)
			SSid_access.apply_template_to_chameleon_card(agent_card, new_template, FALSE)
		else
			agent_card.assignment = job_datum.title

		agent_card.icon_state = initial(copied_card.icon_state)
		if(ispath(copied_card, /obj/item/card/id/advanced))
			var/obj/item/card/id/advanced/copied_advanced_card = copied_card
			agent_card.assigned_icon_state = initial(copied_advanced_card.assigned_icon_state)

		agent_card.update_label()
		agent_card.update_icon()

/datum/action/item_action/chameleon/change/id_template/initialize_disguises()
	name = "Change [chameleon_name] Appearance"
	build_all_button_icons()

	chameleon_blacklist |= typecacheof(target.type)
	for(var/template_path in typesof(chameleon_type))
		if(ispath(template_path) && ispath(template_path, /datum/access_template))
			if(chameleon_blacklist[template_path])
				continue

			var/datum/access_template/template = SSid_access.template_singletons_by_path[template_path]

			if(template && template.template_state && template.assignment)
				var/chameleon_item_name = "[template.assignment] ([template.template_state])"
				chameleon_list[chameleon_item_name] = template_path

/datum/action/item_action/chameleon/change/id_template/update_item(picked_template_path)
	var/obj/item/card/id/advanced/chameleon/agent_card = target

	if(istype(agent_card))
		SSid_access.apply_template_to_chameleon_card(agent_card, picked_template_path, TRUE)

	agent_card.update_label()
	agent_card.update_icon()

/datum/action/item_action/chameleon/change/tablet/update_item(obj/item/picked_item)
	..()
	var/obj/item/modular_computer/tablet/pda/agent_pda = target
	if(istype(agent_pda))
		agent_pda.update_appearance()

/datum/action/item_action/chameleon/change/tablet/apply_job_data(datum/job/job_datum)
	..()
	var/obj/item/modular_computer/tablet/pda/agent_pda = target
	if(istype(agent_pda) && istype(job_datum))
		agent_pda.saved_job = job_datum.title


TYPEINFO_DEF(/obj/item/clothing/under/chameleon)
	default_armor = list(BLUNT = 10, PUNCTURE = 10, SLASH = 0, LASER = 10, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 50, ACID = 50)

/obj/item/clothing/under/chameleon
//starts off as black
	name = "black jumpsuit"
	icon_state = "jumpsuit"
	greyscale_colors = "#3f3f3f"
	greyscale_config = /datum/greyscale_config/jumpsuit
	greyscale_config_inhand_left = /datum/greyscale_config/jumpsuit_inhand_left
	greyscale_config_inhand_right = /datum/greyscale_config/jumpsuit_inhand_right
	greyscale_config_worn = /datum/greyscale_config/jumpsuit_worn
	desc = "It's a plain jumpsuit. It has a small dial on the wrist."
	sensor_mode = SENSOR_OFF //Hey who's this guy on the Syndicate Shuttle??
	random_sensor = FALSE
	resistance_flags = NONE
	can_adjust = FALSE

	var/datum/action/item_action/chameleon/change/chameleon_action

/obj/item/clothing/under/chameleon/Initialize(mapload)
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/clothing/under
	chameleon_action.chameleon_name = "Jumpsuit"
	chameleon_action.chameleon_blacklist = typecacheof(list(/obj/item/clothing/under, /obj/item/clothing/under/color, /obj/item/clothing/under/rank, /obj/item/clothing/under/changeling), only_root_path = TRUE)
	chameleon_action.initialize_disguises()
	add_item_action(chameleon_action)

/obj/item/clothing/under/chameleon/Destroy()
	QDEL_NULL(chameleon_action)
	return ..()

/obj/item/clothing/under/chameleon/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	chameleon_action.emp_randomise()

/obj/item/clothing/under/chameleon/broken/Initialize(mapload)
	. = ..()
	chameleon_action.emp_randomise(INFINITY)

TYPEINFO_DEF(/obj/item/clothing/suit/chameleon)
	default_armor = list(BLUNT = 10, PUNCTURE = 10, SLASH = 0, LASER = 10, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 50, ACID = 50)

/obj/item/clothing/suit/chameleon
	name = "armor"
	desc = "A slim armored vest that protects against most types of damage."
	icon_state = "armor"
	inhand_icon_state = "armor"
	blood_overlay_type = "armor"
	resistance_flags = NONE
	supports_variations_flags = CLOTHING_TESHARI_VARIATION | CLOTHING_VOX_VARIATION

	var/datum/action/item_action/chameleon/change/chameleon_action

/obj/item/clothing/suit/chameleon/Initialize(mapload)
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/clothing/suit
	chameleon_action.chameleon_name = "Suit"
	chameleon_action.chameleon_blacklist = typecacheof(list(/obj/item/clothing/suit/armor/abductor, /obj/item/clothing/suit/changeling), only_root_path = TRUE)
	chameleon_action.initialize_disguises()
	add_item_action(chameleon_action)

/obj/item/clothing/suit/chameleon/Destroy()
	QDEL_NULL(chameleon_action)
	return ..()

/obj/item/clothing/suit/chameleon/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	chameleon_action.emp_randomise()

/obj/item/clothing/suit/chameleon/broken/Initialize(mapload)
	. = ..()
	chameleon_action.emp_randomise(INFINITY)

TYPEINFO_DEF(/obj/item/clothing/glasses/chameleon)
	default_armor = list(BLUNT = 10, PUNCTURE = 10, SLASH = 0, LASER = 10, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 50, ACID = 50)

/obj/item/clothing/glasses/chameleon
	name = "Optical Meson Scanner"
	desc = "Used by engineering and mining staff to see basic structural and terrain layouts through walls, regardless of lighting condition."
	icon_state = "meson"
	inhand_icon_state = "meson"
	resistance_flags = NONE
	supports_variations_flags = CLOTHING_TESHARI_VARIATION | CLOTHING_VOX_VARIATION

	var/datum/action/item_action/chameleon/change/chameleon_action

/obj/item/clothing/glasses/chameleon/Initialize(mapload)
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/clothing/glasses
	chameleon_action.chameleon_name = "Glasses"
	chameleon_action.chameleon_blacklist = typecacheof(/obj/item/clothing/glasses/changeling, only_root_path = TRUE)
	chameleon_action.initialize_disguises()
	add_item_action(chameleon_action)

/obj/item/clothing/glasses/chameleon/Destroy()
	QDEL_NULL(chameleon_action)
	return ..()

/obj/item/clothing/glasses/chameleon/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	chameleon_action.emp_randomise()

/obj/item/clothing/glasses/chameleon/broken/Initialize(mapload)
	. = ..()
	chameleon_action.emp_randomise(INFINITY)

TYPEINFO_DEF(/obj/item/clothing/gloves/chameleon)
	default_armor = list(BLUNT = 10, PUNCTURE = 10, SLASH = 0, LASER = 10, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 50, ACID = 50)

/obj/item/clothing/gloves/chameleon
	desc = "These gloves provide protection against electric shock."
	name = "insulated gloves"
	icon_state = "yellow"
	inhand_icon_state = "ygloves"

	resistance_flags = NONE
	supports_variations_flags = CLOTHING_TESHARI_VARIATION | CLOTHING_VOX_VARIATION

	var/datum/action/item_action/chameleon/change/chameleon_action

/obj/item/clothing/gloves/chameleon/Initialize(mapload)
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/clothing/gloves
	chameleon_action.chameleon_name = "Gloves"
	chameleon_action.chameleon_blacklist = typecacheof(list(/obj/item/clothing/gloves, /obj/item/clothing/gloves/color, /obj/item/clothing/gloves/changeling), only_root_path = TRUE)
	chameleon_action.initialize_disguises()
	add_item_action(chameleon_action)

/obj/item/clothing/gloves/chameleon/Destroy()
	QDEL_NULL(chameleon_action)
	return ..()

/obj/item/clothing/gloves/chameleon/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	chameleon_action.emp_randomise()

/obj/item/clothing/gloves/chameleon/broken/Initialize(mapload)
	. = ..()
	chameleon_action.emp_randomise(INFINITY)

TYPEINFO_DEF(/obj/item/clothing/head/chameleon)
	default_armor = list(BLUNT = 5, PUNCTURE = 5, SLASH = 0, LASER = 5, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 50, ACID = 50)

/obj/item/clothing/head/chameleon
	name = "grey cap"
	desc = "It's a baseball hat in a tasteful grey colour."
	icon_state = "greysoft"

	resistance_flags = NONE

	var/datum/action/item_action/chameleon/change/chameleon_action

/obj/item/clothing/head/chameleon/Initialize(mapload)
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/clothing/head
	chameleon_action.chameleon_name = "Hat"
	chameleon_action.chameleon_blacklist = typecacheof(/obj/item/clothing/head/changeling, only_root_path = TRUE)
	chameleon_action.initialize_disguises()
	add_item_action(chameleon_action)

/obj/item/clothing/head/chameleon/Destroy()
	QDEL_NULL(chameleon_action)
	return ..()

/obj/item/clothing/head/chameleon/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	chameleon_action.emp_randomise()

/obj/item/clothing/head/chameleon/broken/Initialize(mapload)
	. = ..()
	chameleon_action.emp_randomise(INFINITY)

TYPEINFO_DEF(/obj/item/clothing/head/chameleon/drone)
	default_armor = list(BLUNT = 0, PUNCTURE = 0, SLASH = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)

/obj/item/clothing/head/chameleon/drone
	// The camohat, I mean, holographic hat projection, is part of the
	// drone itself.
	// which means it offers no protection, it's just air and light

/obj/item/clothing/head/chameleon/drone/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)
	chameleon_action.random_look()
	var/datum/action/item_action/chameleon/drone/togglehatmask/togglehatmask_action = new(src)
	togglehatmask_action.build_all_button_icons()
	var/datum/action/item_action/chameleon/drone/randomise/randomise_action = new(src)
	randomise_action.build_all_button_icons()

TYPEINFO_DEF(/obj/item/clothing/mask/chameleon)
	default_armor = list(BLUNT = 5, PUNCTURE = 5, SLASH = 0, LASER = 5, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 50, ACID = 50)

/obj/item/clothing/mask/chameleon
	name = "gas mask"
	desc = "A face-covering mask that can be connected to an air supply. While good for concealing your identity, it isn't good for blocking gas flow." //More accurate
	icon_state = "gas_alt"
	inhand_icon_state = "gas_alt"
	resistance_flags = NONE
	clothing_flags = BLOCK_GAS_SMOKE_EFFECT | MASKINTERNALS
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE|HIDEFACIALHAIR|HIDESNOUT
	permeability_coefficient = 0.01
	flags_cover = MASKCOVERSEYES | MASKCOVERSMOUTH
	w_class = WEIGHT_CLASS_SMALL
	supports_variations_flags = CLOTHING_SNOUTED_VARIATION | CLOTHING_TESHARI_VARIATION | CLOTHING_VOX_VARIATION

	var/datum/action/item_action/chameleon/change/chameleon_action

/obj/item/clothing/mask/chameleon/Initialize(mapload)
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/clothing/mask
	chameleon_action.chameleon_name = "Mask"
	chameleon_action.chameleon_blacklist = typecacheof(/obj/item/clothing/mask/changeling, only_root_path = TRUE)
	chameleon_action.initialize_disguises()
	add_item_action(chameleon_action)
	ADD_TRAIT(src, TRAIT_REPLACES_VOICE, REF(src))

/obj/item/clothing/mask/chameleon/Destroy()
	QDEL_NULL(chameleon_action)
	return ..()

/obj/item/clothing/mask/chameleon/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	chameleon_action.emp_randomise()

/obj/item/clothing/mask/chameleon/broken/Initialize(mapload)
	. = ..()
	chameleon_action.emp_randomise(INFINITY)

/obj/item/clothing/mask/chameleon/attack_self(mob/user)
	var/on = HAS_TRAIT(src, TRAIT_REPLACES_VOICE)
	if(on)
		REMOVE_TRAIT(src, TRAIT_REPLACES_VOICE, REF(src))
		to_chat(user, span_notice("You switch [src]'s voice changer off."))
	else
		ADD_TRAIT(src, TRAIT_REPLACES_VOICE, REF(src))
		to_chat(user, span_notice("You switch [src]'s voice changer on."))

TYPEINFO_DEF(/obj/item/clothing/mask/chameleon/drone)
	default_armor = list(BLUNT = 0, PUNCTURE = 0, SLASH = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 0, ACID = 0)

/obj/item/clothing/mask/chameleon/drone
	//Same as the drone chameleon hat, undroppable and no protection

/obj/item/clothing/mask/chameleon/drone/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)
	REMOVE_TRAIT(src, TRAIT_REPLACES_VOICE, REF(src)) // Can drones use the voice changer part? Let's not find out.
	chameleon_action.random_look()
	var/datum/action/item_action/chameleon/drone/togglehatmask/togglehatmask_action = new(src)
	togglehatmask_action.build_all_button_icons()
	var/datum/action/item_action/chameleon/drone/randomise/randomise_action = new(src)
	randomise_action.build_all_button_icons()

/obj/item/clothing/mask/chameleon/drone/attack_self(mob/user)
	to_chat(user, span_notice("[src] does not have a voice changer."))

TYPEINFO_DEF(/obj/item/clothing/shoes/chameleon)
	default_armor = list(BLUNT = 10, PUNCTURE = 10, SLASH = 0, LASER = 10, ENERGY = 0, BOMB = 0, BIO = 90, FIRE = 50, ACID = 50)

/obj/item/clothing/shoes/chameleon
	name = "black shoes"
	icon_state = "sneakers"
	greyscale_colors = "#545454#ffffff"
	greyscale_config = /datum/greyscale_config/sneakers
	greyscale_config_worn = /datum/greyscale_config/sneakers_worn
	desc = "A pair of black shoes."
	permeability_coefficient = 0.05
	resistance_flags = NONE

	var/datum/action/item_action/chameleon/change/chameleon_action

/obj/item/clothing/shoes/chameleon/Initialize(mapload)
	. = ..()

	create_storage(type = /datum/storage/pockets/shoes)

	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/clothing/shoes
	chameleon_action.chameleon_name = "Shoes"
	chameleon_action.chameleon_blacklist = typecacheof(/obj/item/clothing/shoes/changeling, only_root_path = TRUE)
	chameleon_action.initialize_disguises()
	add_item_action(chameleon_action)

/obj/item/clothing/shoes/chameleon/Destroy()
	QDEL_NULL(chameleon_action)
	return ..()

/obj/item/clothing/shoes/chameleon/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	chameleon_action.emp_randomise()

/obj/item/clothing/shoes/chameleon/noslip
	clothing_traits = list(TRAIT_NO_SLIP_WATER)
	can_be_bloody = FALSE

/obj/item/clothing/shoes/chameleon/noslip/broken/Initialize(mapload)
	. = ..()
	chameleon_action.emp_randomise(INFINITY)

/obj/item/storage/backpack/chameleon
	name = "backpack"
	var/datum/action/item_action/chameleon/change/chameleon_action

/obj/item/storage/backpack/chameleon/Initialize(mapload)
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/storage/backpack
	chameleon_action.chameleon_name = "Backpack"
	chameleon_action.initialize_disguises()
	add_item_action(chameleon_action)

/obj/item/storage/backpack/chameleon/Destroy()
	QDEL_NULL(chameleon_action)
	return ..()

/obj/item/storage/backpack/chameleon/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	chameleon_action.emp_randomise()

/obj/item/storage/backpack/chameleon/broken/Initialize(mapload)
	. = ..()
	chameleon_action.emp_randomise(INFINITY)

/obj/item/storage/belt/chameleon
	name = "toolbelt"
	desc = "Holds tools."
	supports_variations_flags = CLOTHING_TESHARI_VARIATION
	var/datum/action/item_action/chameleon/change/chameleon_action

/obj/item/storage/belt/chameleon/Initialize(mapload)
	. = ..()

	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/storage/belt
	chameleon_action.chameleon_name = "Belt"
	chameleon_action.initialize_disguises()
	add_item_action(chameleon_action)

	atom_storage.silent = TRUE

/obj/item/storage/belt/chameleon/Destroy()
	QDEL_NULL(chameleon_action)
	return ..()

/obj/item/storage/belt/chameleon/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	chameleon_action.emp_randomise()

/obj/item/storage/belt/chameleon/broken/Initialize(mapload)
	. = ..()
	chameleon_action.emp_randomise(INFINITY)

/obj/item/radio/headset/chameleon
	name = "radio headset"
	var/datum/action/item_action/chameleon/change/chameleon_action

/obj/item/radio/headset/chameleon/Initialize(mapload)
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/radio/headset
	chameleon_action.chameleon_name = "Headset"
	chameleon_action.initialize_disguises()
	add_item_action(chameleon_action)

/obj/item/radio/headset/chameleon/Destroy()
	QDEL_NULL(chameleon_action)
	return ..()

/obj/item/radio/headset/chameleon/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	chameleon_action.emp_randomise()

/obj/item/radio/headset/chameleon/broken/Initialize(mapload)
	. = ..()
	chameleon_action.emp_randomise(INFINITY)

/obj/item/modular_computer/tablet/pda/chameleon
	name = "tablet"
	var/datum/action/item_action/chameleon/change/tablet/chameleon_action

/obj/item/modular_computer/tablet/pda/chameleon/Initialize(mapload)
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/modular_computer/tablet/pda
	chameleon_action.chameleon_name = "tablet"
	chameleon_action.chameleon_blacklist = typecacheof(list(/obj/item/modular_computer/tablet/pda/heads), only_root_path = TRUE)
	chameleon_action.initialize_disguises()
	add_item_action(chameleon_action)

/obj/item/modular_computer/tablet/pda/chameleon/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	chameleon_action.emp_randomise()

/obj/item/modular_computer/tablet/pda/chameleon/broken/Initialize(mapload)
	. = ..()
	chameleon_action.emp_randomise(INFINITY)

/obj/item/stamp/chameleon
	var/datum/action/item_action/chameleon/change/chameleon_action

/obj/item/stamp/chameleon/Initialize(mapload)
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/stamp
	chameleon_action.chameleon_name = "Stamp"
	chameleon_action.initialize_disguises()
	add_item_action(chameleon_action)

/obj/item/stamp/chameleon/broken/Initialize(mapload)
	. = ..()
	chameleon_action.emp_randomise(INFINITY)

/obj/item/stamp/chameleon/Destroy()
	QDEL_NULL(chameleon_action)
	return ..()

TYPEINFO_DEF(/obj/item/clothing/neck/chameleon)
	default_armor = list(BLUNT = 0, PUNCTURE = 0, SLASH = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 50, ACID = 50)

/obj/item/clothing/neck/chameleon
	name = "black tie"
	desc = "A neosilk clip-on tie."
	icon_state = "blacktie"
	resistance_flags = NONE
	w_class = WEIGHT_CLASS_SMALL

/obj/item/clothing/neck/chameleon
	var/datum/action/item_action/chameleon/change/chameleon_action

/obj/item/clothing/neck/chameleon/Initialize(mapload)
	. = ..()
	chameleon_action = new(src)
	chameleon_action.chameleon_type = /obj/item/clothing/neck
	chameleon_action.chameleon_blacklist = typecacheof(/obj/item/clothing/neck/cloak/skill_reward)
	chameleon_action.chameleon_name = "Neck Accessory"
	chameleon_action.initialize_disguises()
	add_item_action(chameleon_action)

/obj/item/clothing/neck/chameleon/Destroy()
	QDEL_NULL(chameleon_action)
	return ..()

/obj/item/clothing/neck/chameleon/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	chameleon_action.emp_randomise()

/obj/item/clothing/neck/chameleon/broken/Initialize(mapload)
	. = ..()
	chameleon_action.emp_randomise(INFINITY)
