
/// The essential proc to call when an atom must receive damage of any kind.
/atom/proc/take_damage(damage_amount, damage_type = BRUTE, damage_flag = NONE, sound_effect = TRUE, attack_dir, armor_penetration = 0, allow_break = TRUE)
	if(!uses_integrity)
		CRASH("[src] had /atom/proc/take_damage() called on it without it being a type that has uses_integrity = TRUE!")
	if(QDELETED(src))
		CRASH("[src] taking damage after deletion")
	if(atom_integrity <= 0)
		CRASH("[src] taking damage while having <= 0 integrity")
	if(sound_effect)
		play_attack_sound(damage_amount, damage_type, damage_flag)
	if(resistance_flags & INDESTRUCTIBLE)
		return

	damage_amount = run_atom_armor(damage_amount, damage_type, damage_flag, attack_dir, armor_penetration)
	if(damage_amount < DAMAGE_PRECISION)
		return

	if(SEND_SIGNAL(src, COMSIG_ATOM_TAKE_DAMAGE, damage_amount, damage_type, damage_flag, sound_effect, attack_dir, armor_penetration) & COMPONENT_NO_TAKE_DAMAGE)
		return

	. = damage_amount

	update_integrity(atom_integrity - damage_amount, damage_flag, allow_break)

/// Proc for recovering atom_integrity. Returns the amount repaired by
/atom/proc/repair_damage(amount)
	if(amount <= 0) // We only recover here
		return
	var/new_integrity = min(max_integrity, atom_integrity + amount)
	. = new_integrity - atom_integrity

	update_integrity(new_integrity)

	if(integrity_failure && atom_integrity > integrity_failure * max_integrity)
		atom_fix()

/// Handles the integrity of an atom changing. This must be called instead of changing integrity directly.
/atom/proc/update_integrity(new_value, damage_flag = NONE, allow_break = TRUE)
	SHOULD_CALL_PARENT(TRUE)

	if(!uses_integrity)
		CRASH("/atom/proc/update_integrity() was called on [src] when it doesnt use integrity!")

	var/old_value = atom_integrity
	new_value = max(0, new_value)
	if(atom_integrity == new_value)
		return

	atom_integrity = new_value
	SEND_SIGNAL(src, COMSIG_ATOM_INTEGRITY_CHANGED, old_value, new_value)

	if(allow_break)
		//BREAKING FIRST. Only called ONCE until the value is repaired above the broken threshold.
		if(!is_broken(old_value) && is_broken())
			atom_break(damage_flag)

		//DESTROYING SECOND
		if(is_destroyed())
			atom_destruction(damage_flag)

/// This mostly exists to keep atom_integrity private. Might be useful in the future.
/atom/proc/get_integrity()
	SHOULD_BE_PURE(TRUE)
	return atom_integrity

/// Returns TRUE if the atom's integrity is below (max_integrity * integrity_failure) point.
/atom/proc/is_broken(relative_integrity = src.atom_integrity)
	SHOULD_BE_PURE(TRUE)
	return integrity_failure && (relative_integrity <= integrity_failure * max_integrity)

/// Returns TRUE if the atom's integrity is less than or equal to zero.
/atom/proc/is_destroyed(relative_integrity = src.atom_integrity)
	SHOULD_BE_PURE(TRUE)
	return relative_integrity <= 0

/**
 * Retrieves the atom's current damage as a percentage where `100%` is `100`.
 */
/atom/proc/get_integrity_percentage()
	return ceil((get_integrity())/max_integrity * 100)

/atom/proc/get_integrity_lost()
	return max_integrity - get_integrity()

///returns the damage value of the attack after processing the atom's various armor protections
/atom/proc/run_atom_armor(damage_amount, damage_type, damage_flag = NONE, attack_dir, armor_penetration = 0)
	if(!uses_integrity)
		CRASH("/atom/proc/run_atom_armor was called on [src] without being implemented as a type that uses integrity!")

	if(damage_flag == BLUNT && (damage_amount < damage_deflection))
		return 0

	switch(damage_type)
		if(BRUTE)
		if(BURN)
		else
			return 0

	var/armor_protection = 0
	if(damage_flag)
		armor_protection = returnArmor().getRating(damage_flag)

	if(armor_protection) //Only apply weak-against-armor/hollowpoint effects if there actually IS armor.
		armor_protection = clamp(armor_protection - armor_penetration, min(armor_protection, 0), 100)

	return round(damage_amount * (100 - armor_protection)*0.01, DAMAGE_PRECISION)

///the sound played when the atom is damaged.
/atom/proc/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src, 'sound/weapons/smash.ogg', 50, TRUE)
			else
				playsound(src, 'sound/weapons/tap.ogg', 50, TRUE)
		if(BURN)
			playsound(src.loc, 'sound/items/welder.ogg', 100, TRUE)

///Called to get the damage that hulks will deal to the atom.
/atom/proc/hulk_damage()
	return 150 //the damage hulks do on punches to this atom, is affected by melee armor

/atom/proc/attack_generic(mob/user, damage_amount = 0, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, armor_penetration = 0) //used by attack_alien, attack_animal, and attack_slime
	if(!uses_integrity)
		CRASH("unimplemented /atom/proc/attack_generic()!")
	user.do_attack_animation(src)
	user.changeNext_move(CLICK_CD_MELEE)
	return take_damage(damage_amount, damage_type, damage_flag, sound_effect, get_dir(src, user), armor_penetration)

/// Called after the atom takes damage and integrity is below integrity_failure level
/atom/proc/atom_break(damage_flag)
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, COMSIG_ATOM_BREAK, damage_flag)

/// Called when integrity is repaired above the breaking point having been broken before
/atom/proc/atom_fix()
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, COMSIG_ATOM_FIX)

///what happens when the atom's integrity reaches zero.
/atom/proc/atom_destruction(damage_flag)
	SHOULD_CALL_PARENT(TRUE)
	SEND_SIGNAL(src, COMSIG_ATOM_DESTRUCTION, damage_flag)

///changes max_integrity while retaining current health percentage, returns TRUE if the atom got broken.
/atom/proc/modify_max_integrity(new_max, can_break = TRUE, damage_type = BRUTE)
	if(!uses_integrity)
		CRASH("/atom/proc/modify_max_integrity() was called on [src] when it doesnt use integrity!")
	var/current_integrity = atom_integrity
	var/current_max = max_integrity

	if(current_integrity != 0 && current_max != 0)
		var/percentage = current_integrity / current_max
		current_integrity = max(1, round(percentage * new_max)) //don't destroy it as a result
		atom_integrity = current_integrity

	max_integrity = new_max

	if(can_break && integrity_failure && current_integrity <= integrity_failure * max_integrity)
		atom_break(damage_type)
		return TRUE
	return FALSE

/// A cut-out proc for [/atom/proc/bullet_act] so living mobs can have their own armor behavior checks without causing issues with needing their own on_hit call
/atom/proc/check_projectile_armor(def_zone, obj/projectile/impacting_projectile, is_silent)
	return 0
