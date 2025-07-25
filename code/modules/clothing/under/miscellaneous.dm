/obj/item/clothing/under/misc
	icon = 'icons/obj/clothing/under/misc.dmi'
	worn_icon = 'icons/mob/clothing/under/misc.dmi'

/obj/item/clothing/under/misc/pj
	name = "\improper PJs"
	desc = "A comfy set of sleepwear, for taking naps or being lazy instead of working."
	can_adjust = FALSE
	inhand_icon_state = "w_suit"

/obj/item/clothing/under/misc/pj/red
	icon_state = "red_pyjamas"

/obj/item/clothing/under/misc/pj/blue
	icon_state = "blue_pyjamas"

/obj/item/clothing/under/misc/patriotsuit
	name = "Patriotic Suit"
	desc = "Motorcycle not included."
	icon_state = "ek"
	inhand_icon_state = "ek"
	can_adjust = FALSE

/obj/item/clothing/under/misc/mailman
	name = "mailman's jumpsuit"
	desc = "<i>'Special delivery!'</i>"
	icon_state = "mailman"
	inhand_icon_state = "b_suit"

/obj/item/clothing/under/misc/psyche
	name = "psychedelic jumpsuit"
	desc = "Groovy!"
	icon_state = "psyche"
	inhand_icon_state = "p_suit"

/obj/item/clothing/under/misc/vice_officer
	name = "vice officer's jumpsuit"
	desc = "It's the standard issue pretty-boy outfit, as seen on Holo-Vision."
	icon_state = "vice"
	inhand_icon_state = "gy_suit"
	can_adjust = FALSE

TYPEINFO_DEF(/obj/item/clothing/under/misc/adminsuit)
	default_armor = list(BLUNT = 100, PUNCTURE = 100, SLASH = 0, LASER = 100, ENERGY = 100, BOMB = 100, BIO = 100, FIRE = 100, ACID = 100)

/obj/item/clothing/under/misc/adminsuit
	name = "administrative cybernetic jumpsuit"
	icon = 'icons/obj/clothing/under/syndicate.dmi'
	icon_state = "syndicate"
	inhand_icon_state = "bl_suit"
	worn_icon = 'icons/mob/clothing/under/syndicate.dmi'
	desc = "A cybernetically enhanced jumpsuit used for administrative duties."
	permeability_coefficient = 0.01
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	cold_protection = CHEST | GROIN | LEGS | FEET | ARMS | HANDS
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = SPACE_SUIT_MAX_TEMP_PROTECT
	can_adjust = FALSE
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/clothing/under/misc/burial
	name = "burial garments"
	desc = "Traditional burial garments from the early 22nd century."
	icon_state = "burial"
	inhand_icon_state = "burial"
	can_adjust = FALSE
	has_sensor = NO_SENSORS

/obj/item/clothing/under/misc/overalls
	name = "laborer's overalls"
	desc = "A set of durable overalls for getting the job done."
	icon_state = "overalls"
	inhand_icon_state = "lb_suit"
	can_adjust = FALSE
	custom_price = PAYCHECK_ASSISTANT * 2.7

/obj/item/clothing/under/misc/assistantformal
	name = "assistant's formal uniform"
	desc = "An assistant's formal-wear. Why an assistant needs formal-wear is still unknown."
	icon_state = "assistant_formal"
	inhand_icon_state = "gy_suit"
	can_adjust = FALSE

TYPEINFO_DEF(/obj/item/clothing/under/misc/durathread)
	default_armor = list(BLUNT = 10, PUNCTURE = 0, SLASH = 0, LASER = 10, ENERGY = 0, BOMB = 5, BIO = 0, FIRE = 40, ACID = 10)

/obj/item/clothing/under/misc/durathread
	name = "durathread jumpsuit"
	desc = "A jumpsuit made from durathread, its resilient fibres provide some protection to the wearer."
	icon_state = "durathread"
	inhand_icon_state = "durathread"
	can_adjust = FALSE

TYPEINFO_DEF(/obj/item/clothing/under/misc/bouncer)
	default_armor = list(BLUNT = 5, PUNCTURE = 0, SLASH = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 30, ACID = 30)

/obj/item/clothing/under/misc/bouncer
	name = "bouncer uniform"
	desc = "A uniform made from a little bit more resistant fibers, makes you seem like a cool guy."
	icon_state = "bouncer"
	inhand_icon_state = "bouncer"
	can_adjust = FALSE

/obj/item/clothing/under/misc/coordinator
	name = "coordinator jumpsuit"
	desc = "A jumpsuit made by party people, from party people, for party people."
	icon = 'icons/obj/clothing/under/captain.dmi'
	worn_icon = 'icons/mob/clothing/under/captain.dmi'
	icon_state = "captain_parade"
	inhand_icon_state = "by_suit"
	can_adjust = FALSE

/obj/item/clothing/under/misc/tacticasual
	name = "Tacticasual Uniform"
	desc = "A simple pair of black tactical slacks, a belt, and white wifebeater worn by rugged, tactical people. Comes with extra pockets."
	icon = 'icons/obj/clothing/under/misc.dmi'
	worn_icon = 'icons/mob/clothing/under/misc.dmi'
	icon_state = "tacticasual"
	inhand_icon_state = "tacticasual"
	can_adjust = FALSE
