extends Control

onready var monsterfile_path = $Panel/MarginContainer/Menu/ScrollContainer/VBoxContainer/MonsterData/Row1/monster_filepath
onready var monsterfile_path2 = $Panel/MarginContainer/Menu/ScrollContainer/VBoxContainer/MonsterData2/Row1/monster_filepath
onready var monsterfile_path3 = $Panel/MarginContainer/Menu/ScrollContainer/VBoxContainer/MonsterData3/Row1/monster_filepath
onready var spawn_location = $Panel/MarginContainer/Menu/ScrollContainer/VBoxContainer/MonsterData/Row2/spawn_location
onready var spawn_location2 = $Panel/MarginContainer/Menu/ScrollContainer/VBoxContainer/MonsterData2/Row2/spawn_location
onready var spawn_location3 = $Panel/MarginContainer/Menu/ScrollContainer/VBoxContainer/MonsterData3/Row2/spawn_location
onready var translation_strings = $Panel/MarginContainer/Menu/Row3/translation_strings
onready var world_sprite_path = $Panel/MarginContainer/Menu/ScrollContainer/VBoxContainer/MonsterData/Row4/world_sprite_path
onready var world_sprite_path2 = $Panel/MarginContainer/Menu/ScrollContainer/VBoxContainer/MonsterData2/Row4/world_sprite_path
onready var world_sprite_path3 = $Panel/MarginContainer/Menu/ScrollContainer/VBoxContainer/MonsterData3/Row4/world_sprite_path
onready var mod_folder_path = $Panel/MarginContainer/Menu/Row5/mod_folder_path
onready var monster_name = $Panel/MarginContainer/Menu/ScrollContainer/VBoxContainer/MonsterData/Row6/monster_name
onready var monster_name2 = $Panel/MarginContainer/Menu/ScrollContainer/VBoxContainer/MonsterData2/Row6/monster_name
onready var monster_name3 = $Panel/MarginContainer/Menu/ScrollContainer/VBoxContainer/MonsterData3/Row6/monster_name
onready var form_quantity = $Panel/MarginContainer/Menu/Row4/form_quantity
onready var monsterdata2 = $Panel/MarginContainer/Menu/ScrollContainer/VBoxContainer/MonsterData2
onready var monsterdata3 = $Panel/MarginContainer/Menu/ScrollContainer/VBoxContainer/MonsterData3

var spawn_profiles_path = "res://data/monster_spawn_profiles/"


func _ready():
	initialize_spawn_location_options()
	initialize_form_qty_options()

func initialize_spawn_location_options():
	var spawn_location_items = Datatables.load(spawn_profiles_path).table
	for item in spawn_location_items:
		spawn_location.add_item(item)
		spawn_location2.add_item(item)
		spawn_location3.add_item(item)

func initialize_form_qty_options():
	form_quantity.add_item("1")
	form_quantity.add_item("2")
	form_quantity.add_item("3")

func on_generate_button_pressed():
	if validate_entries():
	
		generate_tape_collections_extension()
		generate_party_extension()
		generate_frankie_tape_extension()
		generate_frankietape_config_extension()
		generate_mod_file()
		yield(GlobalMessageDialog.show_message("Scripts have been generated."),"completed")
		
func validate_entries()->bool:
	var passed:bool = true
	var directory:Directory = Directory.new()
	if not directory.file_exists(monsterfile_path.text):
		yield(GlobalMessageDialog.show_message("Monster Configuration: "+monsterfile_path.text+" filepath is invalid."),"completed")
		passed = false
	if not directory.file_exists(spawn_profiles_path+spawn_location.text+".tres"):
		yield(GlobalMessageDialog.show_message("Spawn Location: "+spawn_location.text+" filepath is invalid."),"completed")
		passed = false
	if not directory.file_exists(translation_strings.text) and translation_strings.text != "":
		yield(GlobalMessageDialog.show_message("Translation Strings: "+translation_strings.text+" filepath is invalid."),"completed")
		passed = false
	if not directory.dir_exists(mod_folder_path.text) or mod_folder_path.text == "":
		yield(GlobalMessageDialog.show_message("Mod Folder: "+mod_folder_path.text+" filepath is invalid."),"completed")	
		passed = false
	if not directory.file_exists(world_sprite_path.text) and world_sprite_path.text != "":
		yield(GlobalMessageDialog.show_message("World Sprite Path: "+world_sprite_path.text+" filepath is invalid."),"completed")
		passed = false
	if form_quantity.selected == 1:
		if not directory.file_exists(monsterfile_path2.text):
			yield(GlobalMessageDialog.show_message("Monster Configuration 2: "+monsterfile_path2.text+" filepath is invalid."),"completed")
			passed = false
		if not directory.file_exists(spawn_profiles_path+spawn_location2.text+".tres"):
			yield(GlobalMessageDialog.show_message("Spawn Location 2: "+spawn_location2.text+" filepath is invalid."),"completed")
			passed = false		
		if not directory.file_exists(world_sprite_path2.text) and world_sprite_path2.text != "":
			yield(GlobalMessageDialog.show_message("World Sprite Path 2: "+world_sprite_path2.text+" filepath is invalid."),"completed")
			passed = false		
	if form_quantity.selected == 2:
		if not directory.file_exists(monsterfile_path3.text):
			yield(GlobalMessageDialog.show_message("Monster Configuration 3: "+monsterfile_path3.text+" filepath is invalid."),"completed")
			passed = false
		if not directory.file_exists(spawn_profiles_path+spawn_location3.text+".tres"):
			yield(GlobalMessageDialog.show_message("Spawn Location 3: "+spawn_location3.text+" filepath is invalid."),"completed")
			passed = false		
		if not directory.file_exists(world_sprite_path3.text) and world_sprite_path3.text != "":
			yield(GlobalMessageDialog.show_message("World Sprite Path 3: "+world_sprite_path3.text+" filepath is invalid."),"completed")
			passed = false					
	return passed

func generate_metadata_file(modload_script):
		var metadata = ContentInfo.new()
		metadata.set_script(modload_script)				
		var err = ResourceSaver.save(mod_folder_path.text+"/metadata.tres", metadata)
		if err != OK:
			print("Failed to create metadata.tres file.")

func generate_tape_collections_extension():
	var tapecollections_ext_sourcecode = """extends "res://global/save_state/TapeCollection.gd"


func get_snapshot():
	var tape_snaps = []
	for tape in tapes_by_name:
		var snapshot = tape.get_snapshot()		
		if snapshot["form"].begins_with("res://mods/") or snapshot["form"].begins_with("res://data/monster_forms/mods_"):
			snapshot["custom_form"] = snapshot["form"]
			snapshot["form"] =  "res://data/monster_forms/traffikrab.tres"
			print("caught custom mon in storage")
		tape_snaps.push_back(snapshot)
	return {
		"tapes":tape_snaps
	}

func set_snapshot(snap, version:int)->bool:
	clear()
	for tape_snap in snap.tapes:
		var tape = MonsterTape.new()
		if tape_snap.has("custom_form"):
			if tape_snap.custom_form != "":
				var form = load(tape_snap.custom_form) as MonsterForm
				if form:									
					tape_snap.form = tape_snap.custom_form	
					print("converted custom tape back to custom form")	
		if tape.set_snapshot(tape_snap, version):
			add_tape(tape)
		else :
			return false
	return true
	"""
	var mod_script = GDScript.new()
	mod_script.source_code = tapecollections_ext_sourcecode
	mod_script.resource_path = mod_folder_path.text+"/TapeCollections_Ext.gd"
	var err = ResourceSaver.save(mod_script.resource_path, mod_script)
	if err == OK:
		print("Successfully generated tapecollections extension file")


func generate_party_extension():
	var party_ext_sourcecode = """extends "res://global/save_state/Party.gd"


func get_snapshot():
	var partners_snap = {}
	for partner in partners:
		if unlocked_partners.has(partner.partner_id) or partner.partner_id == current_partner_id:
			partners_snap[partner.partner_id] = partner.get_snapshot()
	var playersnap = player.get_snapshot()
	for snapshot in playersnap.tapes:		
		if snapshot["form"].begins_with("res://mods/") or snapshot["form"].begins_with("res://data/monster_forms/mods_"):
			snapshot["custom_form"] = snapshot["form"]
			snapshot["form"] =  "res://data/monster_forms/traffikrab.tres"		
			print("caught custom mon in party")
	return {
		"fusion_meter":fusion_meter.get_snapshot(), 
		"player":playersnap, 
		"current_partner_id":current_partner_id, 
		"unlocked_partners":unlocked_partners.duplicate(), 
		"partners":partners_snap, 
		"max_tapes":max_tapes
	}

func set_snapshot(snap, version:int)->bool:
	partners.clear()
	for i in range(source_partners.size()):
		var p = source_partners[i].duplicate()
		partners.push_back(p)
	start_new_file()
	for tape_snap in snap.player.tapes:
		if tape_snap.has("custom_form"):
			if tape_snap.custom_form != "":
				var form = load(tape_snap.custom_form) as MonsterForm
				if form:									
					tape_snap.form = tape_snap.custom_form					
					print("converted custom form in party")		
	fusion_meter.set_snapshot(snap.get("fusion_meter"), version)
	if not get_player().set_snapshot(snap.player, version):
		return false
	
	if snap.has("unlocked_partners"):
		unlocked_partners = snap.unlocked_partners.duplicate()
	else :
		unlocked_partners = ["kayleigh"]
	
	if snap.has("partners"):
		for id in snap.partners.keys():
			var p = get_partner_by_id(id)
			if p != null:
				if not p.set_snapshot(snap.partners[id], version):
					return false
		for id in snap.partners.keys():
			var p = get_partner_by_id(id)
			if p != null:
				get_parent().stats.get_stat("relationship_level").set_count(id, p.relationship_level)
	
	if snap.has("current_partner_id"):
		set_current_partner_id(snap.current_partner_id)
	else :
		set_current_partner_id(default_partner_id)
	
	if version < 2:
		max_tapes = snap.max_size
	else :
		max_tapes = snap.max_tapes
	
	return true
	"""
	var mod_script = GDScript.new()
	mod_script.source_code = party_ext_sourcecode
	mod_script.resource_path = mod_folder_path.text+"/Party_Ext.gd"
	var err = ResourceSaver.save(mod_script.resource_path, mod_script)
	if err == OK:
		print("Successfully generated party extension file")

func generate_frankie_tape_extension():
	var choosetape_frankie_sourcecode = """extends "res://cutscenes/sidequests/frankie/ChooseFrankieTape.gd"

func _run():
	var tapes = SaveState.party.get_tapes()
	var tape = yield (MenuHelper.show_choose_tape_menu(tapes, Bind.new(self, "_tape_filter")), "completed")
	if not tape:
		return false
	
	assert (tape.form != null)
	blackboard.species_name = tape.form.name
	blackboard.species_description = tape.form.description
	
	var msg = Loc.trf(confirm_message, {species_name = tape.get_name()})
	if not yield (MenuHelper.confirm(msg), "completed"):
		return false
	
	SaveState.party.remove_tape(tape)
	for i in range(tape.get_max_stickers()):
		var sticker = tape.peel_sticker(i)
		if sticker:
			SaveState.inventory.add_item(sticker)
	
	tape.hp.set_to(1, 1)
	var snap = tape.get_snapshot()
	if snap["form"].begins_with("res://mods/") or snap["form"].begins_with("res://data/monster_forms/mods_"):
		snap["custom_form"] = snap["form"]
		snap["form"] =  "res://data/monster_forms/traffikrab.tres"
		print("Intercepted Frankie Tape. Adding hotfix")	
	snap.version = SaveState.CURRENT_VERSION
	SaveState.other_data[data_key] = snap
	
	return true
	"""
	var mod_script = GDScript.new()
	mod_script.source_code = choosetape_frankie_sourcecode
	mod_script.resource_path = mod_folder_path.text+"/ChooseFrankieTape_Ext.gd"
	var err = ResourceSaver.save(mod_script.resource_path, mod_script)
	if err == OK:
		print("Successfully generated Choose Frankie Tape extension file")	

func generate_frankietape_config_extension():
	var frankietape_config_sourcecode = """extends "res://world/quest_scenes/FrankieTapeConfig.gd"

func _generate_tape(rand:Random, defeat_count:int)->MonsterTape:
	var result = ._generate_tape(rand, defeat_count)
	
	var snap = SaveState.other_data.get(data_key).duplicate()
	if snap:
		if snap.has("custom_form"):
			if snap.custom_form != "":
				var form = load(snap.custom_form) as MonsterForm
				if form:									
					snap.form = snap.custom_form						
					print("converted custom tape back to custom form")			
		result.set_snapshot(snap, snap.get("version", 0))
	
	for threshold in evolve_defeat_counts:
		if threshold > defeat_count:
			break
		var selected_evo = null
		for evo in result.form.evolutions:
			if not evo.is_secret:
				selected_evo = evo
		if selected_evo:
			result.evolve(selected_evo)
	
	return result
	"""
	var mod_script = GDScript.new()
	mod_script.source_code = frankietape_config_sourcecode
	mod_script.resource_path = mod_folder_path.text+"/FrankieTapeConfig_Ext.gd"
	var err = ResourceSaver.save(mod_script.resource_path, mod_script)
	if err == OK:
		print("Successfully generated Frankie Tape config extension file")		

func generate_mod_file():
	var tapecollection_path = mod_folder_path.text+"/TapeCollections_Ext.gd"
	var party_ext_path = mod_folder_path.text+"/Party_Ext.gd"
	var choosefrankietape_path = mod_folder_path.text+"/ChooseFrankieTape_Ext.gd"
	var frankietapeconfig_path = mod_folder_path.text+"/FrankieTapeConfig_Ext.gd"
	var spawn_location_path = spawn_profiles_path+spawn_location.text+".tres"
	var spawn_location_path2 = spawn_profiles_path+spawn_location2.text+".tres"
	var spawn_location_path3 = spawn_profiles_path+spawn_location3.text+".tres"
	
	var monster_path_array:Array = []
	monster_path_array.push_back({"name":monster_name.text,"path":monsterfile_path.text})
	var load_function = ""
	var load_function2 = "" 
	var load_function3 = ""
	if not monsterfile_path.text.begins_with("res://data/monster_forms/"):
		load_function = "load_monster(\"%s\",\"%s\")" % [monster_path_array[0].name, monster_path_array[0].path ]
	if form_quantity.selected > 0 and not monsterfile_path2.text.begins_with("res://data/monster_forms/"):		
		monster_path_array.push_back({"name":monster_name2.text,"path":monsterfile_path2.text})
		load_function2 = "load_monster(\"%s\",\"%s\")" % [monster_path_array[1].name, monster_path_array[1].path ]
	if form_quantity.selected > 1 and not monsterfile_path3.text.begins_with("res://data/monster_forms/"):
		monster_path_array.push_back({"name":monster_name3.text,"path":monsterfile_path3.text})
		load_function3 = "load_monster(\"%s\",\"%s\")" % [monster_path_array[2].name, monster_path_array[2].path ]
	
	var load_function_code = """func load_monster(form_name, form_path):
	yield (SceneManager.preloader, "singleton_setup_completed")
	var custom_monster = load(form_path)
	MonsterForms.basic_forms[form_name] = custom_monster
	MonsterForms.by_name.append(custom_monster)
	MonsterForms.by_index.append(custom_monster)
	"""
	
	var translation_server_code = """TranslationServer.add_translation(preload("%s"))""" % [translation_strings.text] 
	
	var save_fix_code = """var tapecollection_ext: Resource = preload("%s")
	var party_ext: Resource = preload("%s")
	var choose_frankie_ext: Resource = preload("%s")
	var frankie_tape_config_ext: Resource = preload("%s")
	
	tapecollection_ext.take_over_path("res://global/save_state/TapeCollection.gd")
	party_ext.take_over_path("res://global/save_state/Party.gd")
	choose_frankie_ext.take_over_path("res://cutscenes/sidequests/frankie/ChooseFrankieTape.gd")
	frankie_tape_config_ext.take_over_path("res://world/quest_scenes/FrankieTapeConfig.gd")	
""" % [tapecollection_path, party_ext_path, choosefrankietape_path, frankietapeconfig_path]
		
	
	if translation_strings.text == "":
		translation_server_code = """#No translation strings being used"""
	var world_sprite1 = "preload(\""+ world_sprite_path.text+"\")" if world_sprite_path.text != "" else ""
	var world_sprite2 = "preload(\""+ world_sprite_path2.text+"\")" if world_sprite_path2.text != "" else ""
	var world_sprite3 = "preload(\""+ world_sprite_path3.text+"\")" if world_sprite_path3.text != "" else ""
	var load_spawn_config_call = "load_spawn_config(preload(\"%s\"),preload(\"%s\"),%s)" % [spawn_location_path, monsterfile_path.text, world_sprite1]
	var load_spawn_config_call2 = "load_spawn_config(preload(\"%s\"),preload(\"%s\"),%s)" % [spawn_location_path2, monsterfile_path2.text, world_sprite2]
	var load_spawn_config_call3 = "load_spawn_config(preload(\"%s\"),preload(\"%s\"),%s)" % [spawn_location_path3, monsterfile_path3.text, world_sprite3]
	if form_quantity.selected == 0:
		load_spawn_config_call2 = ""
		load_spawn_config_call3 = ""
	if form_quantity.selected == 1:
		load_spawn_config_call3 = ""
		
	var load_spawn_config_code = """func load_spawn_config(spawn_path, form_path, world_sprite_path=""):
	
	var spawn_region = spawn_path
	var spawn_config = spawn_region.MonsterFormSpawnConfig.new()
	spawn_config.monster_form = form_path
	
	if typeof(world_sprite_path) != TYPE_STRING:
		spawn_config.world_monster = world_sprite_path

	spawn_config.weight = 1 
	spawn_config.hour_min = 0
	spawn_config.hour_max = 24

	spawn_region.configs.push_back(spawn_config)
	"""	
	
	var mod_source_code = """extends ContentInfo
	
func init_content() -> void:
	%s
			
	%s

	%s
	%s
	%s
 
	%s
	%s
	%s

%s
%s
	""" % [save_fix_code, translation_server_code, load_function, load_function2, load_function3, load_spawn_config_call, load_spawn_config_call2, load_spawn_config_call3, load_function_code, load_spawn_config_code]
	
	var mod_script = GDScript.new()
	mod_script.source_code = mod_source_code
	mod_script.resource_path = mod_folder_path.text+"/mod_load.gd"
	var err = ResourceSaver.save(mod_script.resource_path, mod_script)
	if err == OK:
		print("Successfully generated mod file")
		generate_metadata_file(mod_script)


func _on_form_quantity_item_selected(index):
	monsterdata2.visible = index > 0
	monsterdata3.visible = index > 1
