/obj/structure/closet/secure_closet/freezer
	icon_state = "freezer"
	flags_1 = PREVENT_CONTENTS_EXPLOSION_1
	door_anim_squish = 0.22
	door_anim_angle = 123
	door_anim_time = 4
	var/jones = FALSE

/obj/structure/closet/secure_closet/freezer/Destroy()
	recursive_organ_check(src)
	return ..()

/obj/structure/closet/secure_closet/freezer/Initialize(mapload)
	. = ..()
	recursive_organ_check(src)

/obj/structure/closet/secure_closet/freezer/open(mob/living/user, force = FALSE)
	if(opened || !can_open(user, force)) //dupe check just so we don't let the organs decay when someone fails to open the locker
		return FALSE
	recursive_organ_check(src)
	return ..()

/obj/structure/closet/secure_closet/freezer/close(mob/living/user)
	if(..()) //if we actually closed the locker
		recursive_organ_check(src)

/obj/structure/closet/secure_closet/freezer/ex_act()
	if(jones)
		return ..()
	jones = TRUE
	flags_1 &= ~PREVENT_CONTENTS_EXPLOSION_1

/obj/structure/closet/secure_closet/freezer/empty
	name = "empty freezer"

/obj/structure/closet/secure_closet/freezer/empty/open
	req_access = null
	locked = FALSE

/obj/structure/closet/secure_closet/freezer/kitchen
	name = "kitchen cabinet"
	req_access = list(ACCESS_KITCHEN)

/obj/structure/closet/secure_closet/freezer/kitchen/PopulateContents()
	..()
	for(var/i in 1 to 3)
		new /obj/item/reagent_containers/condiment/flour(src)
	new /obj/item/reagent_containers/condiment/rice(src)
	new /obj/item/reagent_containers/condiment/sugar(src)

/obj/structure/closet/secure_closet/freezer/kitchen/maintenance
	name = "maintenance refrigerator"
	desc = "This refrigerator looks quite dusty, is there anything edible still inside?"
	req_access = list()

/obj/structure/closet/secure_closet/freezer/kitchen/maintenance/PopulateContents()
	..()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/condiment/milk(src)
		new /obj/item/reagent_containers/condiment/soymilk(src)
	for(var/i in 1 to 2)
		new /obj/item/storage/fancy/egg_box(src)

/obj/structure/closet/secure_closet/freezer/kitchen/mining
	req_access = list()

/obj/structure/closet/secure_closet/freezer/meat
	name = "meat fridge"
	req_access = list(ACCESS_KITCHEN)

/obj/structure/closet/secure_closet/freezer/meat/PopulateContents()
	..()
	for(var/i in 1 to 4)
		new /obj/item/food/meat/slab/monkey(src)

/obj/structure/closet/secure_closet/freezer/meat/open
	req_access = list()
	locked = FALSE

/obj/structure/closet/secure_closet/freezer/gulag_fridge
	name = "refrigerator"

/obj/structure/closet/secure_closet/freezer/gulag_fridge/PopulateContents()
	..()
	for(var/i in 1 to 3)
		new /obj/item/reagent_containers/cup/glass/bottle/beer/light(src)

/obj/structure/closet/secure_closet/freezer/fridge
	name = "refrigerator"
	req_access = list(ACCESS_KITCHEN)

/obj/structure/closet/secure_closet/freezer/fridge/PopulateContents()
	..()
	for(var/i in 1 to 5)
		new /obj/item/reagent_containers/condiment/milk(src)
		new /obj/item/reagent_containers/condiment/soymilk(src)
	for(var/i in 1 to 2)
		new /obj/item/storage/fancy/egg_box(src)

/obj/structure/closet/secure_closet/freezer/fridge/open
	req_access = null
	locked = FALSE

/obj/structure/closet/secure_closet/freezer/money
	name = "freezer"
	desc = "This contains cold hard cash."
	req_access = list(ACCESS_VAULT)

/obj/structure/closet/secure_closet/freezer/money/PopulateContents()
	..()
	for(var/i in 1 to 5)
		new /obj/item/stack/spacecash/c1000(src)
	for(var/i in 1 to 15)
		new /obj/item/stack/spacecash/c100(src)

/obj/structure/closet/secure_closet/freezer/cream_pie
	name = "cream pie closet"
	desc = "Contains pies filled with cream and/or custard, you sickos."
	req_access = list(ACCESS_THEATRE)

/obj/structure/closet/secure_closet/freezer/cream_pie/PopulateContents()
	..()
	new /obj/item/food/pie/cream(src)
