// Ye old forbidden book, the Codex Cicatrix.
/obj/item/codex_cicatrix
	name = "Codex Cicatrix"
	desc = "This book describes the secrets of the veil between worlds."
	icon = 'icons/obj/eldritch.dmi'
	base_icon_state = "book"
	icon_state = "book"
	worn_icon_state = "book"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/codex_cicatrix/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/effect_remover, \
		success_feedback = "You remove %THEEFFECT.", \
		tip_text = "Clear rune", \
		effects_we_clear = list(/obj/effect/heretic_rune))

/obj/item/codex_cicatrix/examine(mob/user)
	. = ..()
	if(!IS_HERETIC(user))
		return

	. += span_notice("Can be used to tap influences for additional knowledge points.")
	. += span_notice("Can also be used to draw or remove transmutation runes with ease.")

/obj/item/codex_cicatrix/attack_self(mob/user, modifiers)
	. = ..()
	if(.)
		return

	open_animation()

/obj/item/codex_cicatrix/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	var/datum/antagonist/heretic/heretic_datum = IS_HERETIC(user)
	if(!heretic_datum)
		return NONE

	var/atom/target = interacting_with // Yes i am supremely lazy

	if(isopenturf(target))
		heretic_datum.try_draw_rune(user, target, drawing_time = 12 SECONDS)
		return ITEM_INTERACT_SUCCESS

/*
 * Plays a little animation that shows the book opening and closing.
 */
/obj/item/codex_cicatrix/proc/open_animation()
	icon_state = "[base_icon_state]_open"
	flick("[base_icon_state]_opening", src)

	addtimer(CALLBACK(src, PROC_REF(close_animation)), 5 SECONDS)

/*
 * Plays a closing animation and resets the icon state.
 */
/obj/item/codex_cicatrix/proc/close_animation()
	icon_state = base_icon_state
	flick("[base_icon_state]_closing", src)
