TYPEINFO_DEF(/obj/item/clothing/shoes/combat)
	default_armor = list(BLUNT = 25, PUNCTURE = 25, SLASH = 0, LASER = 25, ENERGY = 25, BOMB = 50, BIO = 10, FIRE = 70, ACID = 50)

/obj/item/clothing/shoes/combat //basic syndicate combat boots for nuke ops and mob corpses
	name = "combat boots"
	desc = "High speed, low drag combat boots."
	icon_state = "jackboots"
	inhand_icon_state = "jackboots"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	strip_delay = 40
	resistance_flags = NONE
	lace_time = 12 SECONDS
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION | CLOTHING_TESHARI_VARIATION | CLOTHING_VOX_VARIATION

/obj/item/clothing/shoes/combat/Initialize(mapload)
	. = ..()

	create_storage(type = /datum/storage/pockets/shoes)

/obj/item/clothing/shoes/combat/sneakboots
	name = "sneakboots"
	desc = "These boots have special noise cancelling soles. Perfect for stealth, if it wasn't for the color scheme."
	icon_state = "sneakboots"
	inhand_icon_state = "sneakboots"
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = FIRE_PROOF | ACID_PROOF
	clothing_traits = list(TRAIT_SILENT_FOOTSTEPS)

TYPEINFO_DEF(/obj/item/clothing/shoes/combat/swat)
	default_armor = list(BLUNT = 40, PUNCTURE = 30, SLASH = 0, LASER = 25, ENERGY = 25, BOMB = 50, BIO = 30, FIRE = 90, ACID = 50)

/obj/item/clothing/shoes/combat/swat //overpowered boots for death squads
	name = "\improper SWAT boots"
	desc = "High speed, no drag combat boots."
	permeability_coefficient = 0.01
	clothing_traits = list(TRAIT_NO_SLIP_WATER)

TYPEINFO_DEF(/obj/item/clothing/shoes/jackboots)
	default_armor = list(BLUNT = 0, PUNCTURE = 0, SLASH = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 90, FIRE = 0, ACID = 0)

/obj/item/clothing/shoes/jackboots
	name = "jackboots"
	desc = "Mars-issue Security combat boots for combat scenarios or combat situations. All combat, all the time."
	icon_state = "jackboots"
	inhand_icon_state = "jackboots"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	strip_delay = 30
	equip_delay_other = 50
	resistance_flags = NONE
	can_be_tied = FALSE
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION | CLOTHING_TESHARI_VARIATION | CLOTHING_VOX_VARIATION

/obj/item/clothing/shoes/jackboots/Initialize(mapload)
	. = ..()

	create_storage(type = /datum/storage/pockets/shoes)

/obj/item/clothing/shoes/jackboots/fast
	slowdown = -1

/obj/item/clothing/shoes/winterboots
	name = "winter boots"
	desc = "Boots lined with 'synthetic' animal fur."
	icon_state = "winterboots"
	inhand_icon_state = "winterboots"
	permeability_coefficient = 0.15
	cold_protection = FEET|LEGS
	min_cold_protection_temperature = SHOES_MIN_TEMP_PROTECT
	heat_protection = FEET|LEGS
	max_heat_protection_temperature = SHOES_MAX_TEMP_PROTECT
	lace_time = 8 SECONDS
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION | CLOTHING_TESHARI_VARIATION | CLOTHING_VOX_VARIATION

/obj/item/clothing/shoes/winterboots/Initialize(mapload)
	. = ..()

	create_storage(type = /datum/storage/pockets/shoes)

/obj/item/clothing/shoes/winterboots/ice_boots
	name = "ice hiking boots"
	desc = "A pair of winter boots with special grips on the bottom, designed to prevent slipping on frozen surfaces."
	icon_state = "iceboots"
	inhand_icon_state = "iceboots"
	clothing_traits = list(TRAIT_NO_SLIP_ICE, TRAIT_NO_SLIP_SLIDE)
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION | CLOTHING_TESHARI_VARIATION | CLOTHING_VOX_VARIATION

/obj/item/clothing/shoes/workboots
	name = "work boots"
	desc = "Mars-issue Engineering lace-up work boots for the especially blue-collar."
	icon_state = "workboots"
	inhand_icon_state = "jackboots"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	permeability_coefficient = 0.15
	strip_delay = 20
	equip_delay_other = 40
	lace_time = 8 SECONDS

/obj/item/clothing/shoes/workboots/Initialize(mapload)
	. = ..()

	create_storage(type = /datum/storage/pockets/shoes)

/obj/item/clothing/shoes/workboots/mining
	name = "mining boots"
	desc = "Steel-toed mining boots for mining in hazardous environments. Very good at keeping toes uncrushed."
	icon_state = "explorer"
	resistance_flags = FIRE_PROOF
	supports_variations_flags = CLOTHING_DIGITIGRADE_VARIATION | CLOTHING_TESHARI_VARIATION | CLOTHING_VOX_VARIATION

/obj/item/clothing/shoes/russian
	name = "russian boots"
	desc = "Comfy shoes."
	icon_state = "rus_shoes"
	inhand_icon_state = "rus_shoes"
	lace_time = 8 SECONDS

/obj/item/clothing/shoes/russian/Initialize(mapload)
	. = ..()

	create_storage(type = /datum/storage/pockets/shoes)

/obj/item/clothing/shoes/discoshoes
	name = "green lizardskin shoes"
	desc = "They may have lost some of their lustre over the years, but these green lizardskin shoes fit you perfectly."
	icon_state = "lizardskin_shoes"
	inhand_icon_state = "lizardskin_shoes"

/obj/item/clothing/shoes/kim
	name = "aerostatic boots"
	desc = "A crisp, clean set of boots for working long hours on the beat."
	icon_state = "aerostatic_boots"
	inhand_icon_state = "aerostatic_boots"
