//File with the circuitboard and circuitboard/machine class definitions and procs


// Circuitboard

TYPEINFO_DEF(/obj/item/circuitboard)
	default_materials = list(/datum/material/glass = 1000)

/obj/item/circuitboard
	name = "circuit board"
	icon = 'icons/obj/module.dmi'
	icon_state = "circuit_map"
	inhand_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	grind_results = list(/datum/reagent/silicon = 20)
	greyscale_colors = CIRCUIT_COLOR_GENERIC

	var/build_path = null
	///determines if the circuit board originated from a vendor off station or not.
	var/onstation = TRUE

	var/list/req_components // Components required by the machine.
							// Example: list(/obj/item/stock_parts/matter_bin = 5)

	var/list/def_components // Default replacements for req_components, to be used in apply_default_parts instead of req_components types
							// Example: list(/obj/item/stock_parts/matter_bin = /obj/item/stock_parts/matter_bin/super)

/obj/item/circuitboard/Initialize(mapload)
	set_greyscale(new_config = /datum/greyscale_config/circuit)
	return ..()

/obj/item/circuitboard/examine(mob/user)
	. = ..()
	if(!LAZYLEN(req_components))
		. += span_info("It requires no components.")
		return .

	var/list/nice_list = list()
	for(var/atom/component_path as anything in req_components)
		if(!ispath(component_path))
			continue

		var/component_name = initial(component_path.name)
		var/component_amount = req_components[component_path]

		if(ispath(component_path, /obj/item/stack))
			var/obj/item/stack/stack_path = component_path
			if(initial(stack_path.singular_name))
				component_name = initial(stack_path.singular_name) //e.g. "glass sheet" vs. "glass"

		else if(ispath(component_path, /obj/item/stock_parts))
			var/obj/item/stock_parts/stock_part = component_path
			if(initial(stock_part.base_name))
				component_name = initial(stock_part.base_name)

		nice_list += list("[component_amount] [component_name]\s")

	. += span_info("It requires [english_list(nice_list)].")

/obj/item/circuitboard/proc/apply_default_parts(obj/machinery/machine)
	if(LAZYLEN(machine.component_parts))
		// This really shouldn't happen. If it somehow does, print out a stack trace and gracefully handle it.
		stack_trace("apply_defauly_parts called on machine that already had component_parts: [machine]")

		// Move to nullspace so you don't trigger handle_atom_del logic and remove existing parts.
		for(var/obj/item/part as anything in machine.component_parts)
			part.moveToNullspace(loc)
			qdel(part)

	// List of components always contains the circuit board used to build it.
	machine.component_parts = list(src)
	forceMove(machine)

	if(machine.circuit != src)
		// This really shouldn't happen. If it somehow does, print out a stack trace and gracefully handle it.
		stack_trace("apply_default_parts called from a circuit board that does not belong to machine: [machine]")

		// Move to nullspace so you don't trigger handle_atom_del logic, remove old circuit, add new circuit.
		machine.circuit.moveToNullspace()
		qdel(machine.circuit)
		machine.circuit = src

	if(!req_components)
		return

	for(var/comp_path in req_components)
		var/comp_amt = req_components[comp_path]
		if(!comp_amt)
			continue

		if(def_components && def_components[comp_path])
			comp_path = def_components[comp_path]

		if(ispath(comp_path, /obj/item/stack))
			machine.component_parts += new comp_path(machine, comp_amt)
		else
			for(var/component in 1 to comp_amt)
				machine.component_parts += new comp_path(machine)

	machine.RefreshParts()

	return

/**
 * Used to allow the circuitboard to configure a machine in some way, shape or form.
 *
 * Arguments:
 * * machine - The machine to attempt to configure.
 */
/obj/item/circuitboard/proc/configure_machine(obj/machinery/machine)
	return

// Circuitboard/machine
/*Common Parts: Parts List: Ignitor, Timer, Infra-red laser, Infra-red sensor, t_scanner, Capacitor, Valve, sensor unit,
micro-manipulator, console screen, beaker, Microlaser, matter bin, power cells.
*/

/obj/item/circuitboard/machine
	var/needs_anchored = TRUE // Whether this machine must be anchored to be constructed.
