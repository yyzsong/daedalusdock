//his isn't a subtype of the syringe gun because the syringegun subtype is made to hold syringes
//this is meant to hold reagents/obj/item/gun/syringe
TYPEINFO_DEF(/obj/item/gun/chem)
	default_materials = list(/datum/material/iron=2000)

/obj/item/gun/chem
	name = "reagent gun"
	desc = "An Aether syringe gun, modified to automatically synthesise chemical darts, and instead hold reagents."
	icon_state = "chemgun"
	inhand_icon_state = "chemgun"
	w_class = WEIGHT_CLASS_NORMAL
	throw_range = 7
	force = 4
	clumsy_check = FALSE
	fire_sound = 'sound/items/syringeproj.ogg'
	var/time_per_syringe = 250
	var/syringes_left = 4
	var/max_syringes = 4
	var/last_synth = 0

/obj/item/gun/chem/Initialize(mapload)
	. = ..()
	chambered = new /obj/item/ammo_casing/chemgun(src)
	START_PROCESSING(SSobj, src)
	create_reagents(90, OPENCONTAINER)

/obj/item/gun/chem/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/gun/chem/can_fire()
	return syringes_left

/obj/item/gun/chem/do_chamber_update()
	if(chambered && !chambered.loaded_projectile && syringes_left)
		chambered.newshot()

/obj/item/gun/chem/process()
	if(syringes_left >= max_syringes)
		return
	if(world.time < last_synth+time_per_syringe)
		return
	to_chat(loc, span_warning("You hear a click as [src] synthesizes a new dart."))
	syringes_left++
	if(chambered && !chambered.loaded_projectile)
		chambered.newshot()
	last_synth = world.time
