TYPEINFO_DEF(/obj/item/clothing/head/helmet/space/pirate)
	default_armor = list(BLUNT = 30, PUNCTURE = 50, SLASH = 0, LASER = 30, ENERGY = 40, BOMB = 30, BIO = 30, FIRE = 60, ACID = 75)

/obj/item/clothing/head/helmet/space/pirate
	name = "modified EVA helmet"
	desc = "A modified helmet to allow space pirates to intimidate their customers whilst staying safe from the void. Comes with some additional protection."
	icon_state = "spacepirate"
	inhand_icon_state = "spacepiratehelmet"
	strip_delay = 40
	equip_delay_other = 20

/obj/item/clothing/head/helmet/space/pirate/bandana
	icon_state = "spacebandana"
	inhand_icon_state = "spacepiratehelmet"

TYPEINFO_DEF(/obj/item/clothing/suit/space/pirate)
	default_armor = list(BLUNT = 30, PUNCTURE = 50, SLASH = 0, LASER = 30, ENERGY = 40, BOMB = 30, BIO = 30, FIRE = 60, ACID = 75)

/obj/item/clothing/suit/space/pirate
	name = "modified EVA suit"
	desc = "A modified suit to allow space pirates to board shuttles and stations while avoiding the maw of the void. Comes with additional protection, and is lighter to move in."
	icon_state = "spacepirate"
	w_class = WEIGHT_CLASS_NORMAL
	allowed = list(/obj/item/gun, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/restraints/handcuffs, /obj/item/tank/internals, /obj/item/melee/energy/sword/pirate, /obj/item/clothing/glasses/eyepatch, /obj/item/reagent_containers/cup/glass/bottle/rum)
	slowdown = 0
	strip_delay = 40
	equip_delay_other = 20
