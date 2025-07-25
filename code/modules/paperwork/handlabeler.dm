/obj/item/hand_labeler
	name = "hand labeler"
	desc = "A combined label printer, applicator, and remover, all in a single portable device. Designed to be easy to operate and use."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "labeler0"
	inhand_icon_state = "flight"
	var/label = null
	var/labels_left = 30
	var/mode = 0

/obj/item/hand_labeler/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] is pointing [src] at [user.p_them()]self. [user.p_theyre(TRUE)] going to label [user.p_them()]self as a suicide!"))
	labels_left = max(labels_left - 1, 0)

	var/old_real_name = user.real_name
	user.set_real_name("[old_real_name] (suicide)")
	// no conflicts with their identification card
	for(var/atom/A in user.get_all_contents())
		if(istype(A, /obj/item/card/id))
			var/obj/item/card/id/their_card = A

			// only renames their card, as opposed to tagging everyone's
			if(their_card.registered_name != old_real_name)
				continue

			their_card.registered_name = user.real_name
			their_card.update_label()
			their_card.update_icon()

	// NOT EVEN DEATH WILL TAKE AWAY THE STAIN
	user.mind.name += " (suicide)"

	mode = 1
	icon_state = "labeler[mode]"
	label = "suicide"

	return OXYLOSS

/obj/item/hand_labeler/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!mode) //if it's off, give up.
		return NONE

	if(!labels_left)
		to_chat(user, span_warning("No labels left!"))
		return ITEM_INTERACT_BLOCKING
	if(!label || !length(label))
		to_chat(user, span_warning("No text set!"))
		return ITEM_INTERACT_BLOCKING
	if(length(interacting_with.name) + length(label) > 64)
		to_chat(user, span_warning("Label too big!"))
		return ITEM_INTERACT_BLOCKING
	if(ismob(interacting_with))
		to_chat(user, span_warning("You can't label creatures!")) // use a collar
		return ITEM_INTERACT_BLOCKING

	user.visible_message(span_notice("[user] labels [interacting_with] with \"[label]\"."), \
		span_notice("You label [interacting_with] with \"[label]\"."))
	interacting_with.AddComponent(/datum/component/label, label)
	playsound(interacting_with, 'sound/items/handling/component_pickup.ogg', 20, TRUE)
	labels_left--
	return ITEM_INTERACT_SUCCESS

/obj/item/hand_labeler/attack_self(mob/user)
	if(!ISADVANCEDTOOLUSER(user))
		to_chat(user, span_warning("You don't have the dexterity to use [src]!"))
		return
	mode = !mode
	icon_state = "labeler[mode]"
	if(mode)
		to_chat(user, span_notice("You turn on [src]."))
		//Now let them chose the text.
		var/str = reject_bad_text(tgui_input_text(user, "Label text", "Set Label", label, MAX_NAME_LEN))
		if(!str)
			to_chat(user, span_warning("Invalid text!"))
			return
		label = str
		to_chat(user, span_notice("You set the text to '[str]'."))
	else
		to_chat(user, span_notice("You turn off [src]."))

/obj/item/hand_labeler/attackby(obj/item/I, mob/user, params)
	..()
	if(istype(I, /obj/item/hand_labeler_refill))
		to_chat(user, span_notice("You insert [I] into [src]."))
		qdel(I)
		labels_left = initial(labels_left) //Yes, it's capped at its initial value

/obj/item/hand_labeler/borg
	name = "cyborg-hand labeler"

/obj/item/hand_labeler/borg/afterattack(atom/A, mob/user, proximity)
	. = ..()
	if(. != ITEM_INTERACT_SUCCESS)
		return

	if(!iscyborg(user))
		return

	var/mob/living/silicon/robot/borgy = user

	var/starting_labels = initial(labels_left)
	var/diff = starting_labels - labels_left
	if(diff)
		labels_left = starting_labels
		// 50 per label. Magical cyborg paper doesn't come cheap.
		var/cost = diff * 50

		// If the cyborg manages to use a module without a cell, they get the paper
		// for free.
		if(borgy.cell)
			borgy.cell.use(cost)

/obj/item/hand_labeler_refill
	name = "hand labeler paper roll"
	icon = 'icons/obj/bureaucracy.dmi'
	desc = "A roll of paper. Use it on a hand labeler to refill it."
	icon_state = "labeler_refill"
	inhand_icon_state = "electropack"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY
