[1mdiff --git a/SceneObjs/Environmental/Main.tscn b/SceneObjs/Environmental/Main.tscn[m
[1mindex ab74473..87d8c18 100644[m
[1m--- a/SceneObjs/Environmental/Main.tscn[m
[1m+++ b/SceneObjs/Environmental/Main.tscn[m
[36m@@ -13,7 +13,7 @@[m
 [ext_resource type="PackedScene" uid="uid://dc047347gnkh2" path="res://SceneObjs/Environmental/energy_source.tscn" id="10_chges"][m
 [ext_resource type="PackedScene" uid="uid://0x8uufyrcwad" path="res://SceneObjs/Entity/pickup_emmiter.tscn" id="10_daody"][m
 [ext_resource type="Script" uid="uid://cbm26jdhaslks" path="res://SceneObjs/Environmental/nav_region.gd" id="10_m5msw"][m
[31m-[ext_resource type="Script" path="res://SceneObjs/Environmental/underworld_controller.gd" id="11_chges"][m
[32m+[m[32m[ext_resource type="Script" uid="uid://yn6lnxvjhk3r" path="res://SceneObjs/Environmental/underworld_controller.gd" id="11_chges"][m
 [ext_resource type="PackedScene" uid="uid://c83dnwe7afdko" path="res://SceneObjs/Environmental/RockWall1.tscn" id="11_jjgha"][m
 [ext_resource type="Script" uid="uid://dxme07nhdrpmn" path="res://SceneObjs/UI/Scripts/menu_func.gd" id="11_krkgy"][m
 [ext_resource type="PackedScene" uid="uid://ccguxx12dl1bh" path="res://SceneObjs/Environmental/underworld_environment.tscn" id="11_lqwkv"][m
[36m@@ -27,8 +27,6 @@[m
 [ext_resource type="PackedScene" uid="uid://dky5nnvlfq6v2" path="res://SceneObjs/Entity/pickup.tscn" id="16_1rx3v"][m
 [ext_resource type="Script" uid="uid://ceb22ea8d8f0p" path="res://addons/zylann.hterrain/hterrain_texture_set.gd" id="16_ov4yy"][m
 [ext_resource type="Texture2D" uid="uid://bok63sp5licm0" path="res://Textures/Extracted/Grass.png" id="17_s76h1"][m
[31m-[ext_resource type="Material" uid="uid://c16m6psb2fle8" path="res://Materials/TerrainMat.tres" id="23_gmekt"][m
[31m-[ext_resource type="Script" uid="uid://ce17m62yh67wg" path="res://Scripts/TerrainGenerator.gd" id="24_m5msw"][m
 [ext_resource type="Resource" uid="uid://cjh7xp1lhcmix" path="res://TerrainData/Underworld/data.hterrain" id="24_xvppk"][m
 [ext_resource type="Texture2D" uid="uid://qc1w7spndy6q" path="res://Textures/Extracted/slot0_albedo_bump.png" id="25_4s6kp"][m
 [ext_resource type="Script" uid="uid://cyxva1qdgk2p" path="res://SceneObjs/Environmental/flat_portal.gd" id="31_73b8e"][m
[36m@@ -162,7 +160,7 @@[m [mmesh = SubResource("BoxMesh_cm0pq")[m
 surface_material_override/0 = SubResource("StandardMaterial3D_fos0i")[m
 [m
 [node name="Castle" type="Node3D" parent="CurrentLevel/MainTestScene" unique_id=922610502][m
[31m-transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 305.39374, 0, 369.97974)[m
[32m+[m[32mtransform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 7.3119097, 0, 16.22441)[m
 [m
 [node name="MeshInstance3D" type="MeshInstance3D" parent="CurrentLevel/MainTestScene/Castle" unique_id=1698980549][m
 mesh = SubResource("SphereMesh_dvtkr")[m
[36m@@ -287,18 +285,6 @@[m [mlayers = 2[m
 [node name="UnderworldEnvironment" parent="CurrentLevel/Underworld" unique_id=1922065242 instance=ExtResource("11_lqwkv")][m
 environment = ExtResource("4_1rx3v")[m
 [m
[31m-[node name="Terrain" type="MeshInstance3D" parent="CurrentLevel/Underworld" unique_id=477414590 node_paths=PackedStringArray("player")][m
[31m-visible = false[m
[31m-layers = 2[m
[31m-material_override = ExtResource("23_gmekt")[m
[31m-skeleton = NodePath("../../MainTestScene")[m
[31m-script = ExtResource("24_m5msw")[m
[31m-noise_scale = 3.0[m
[31m-noise_offset = Vector3(152.543, -150, 100)[m
[31m-iso_level = 0.2[m
[31m-chunk_scale = 100.0[m
[31m-player = NodePath("../../../MainPlayer")[m
[31m-[m
 [node name="EnergySource" parent="CurrentLevel/Underworld" unique_id=1542479479 instance=ExtResource("10_chges")][m
 transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 0.65972996, 1.5474262, -8.581451)[m
 collision_layer = 9[m
[36m@@ -315,7 +301,7 @@[m [mtarget = Object(Sprite3D,"unique_name_in_owner":false,"process_mode":0,"process_[m
 [m
 [m
 [node name="FlatPortalProto" type="Node3D" parent="." unique_id=45491246 node_paths=PackedStringArray("objects_root") groups=["portals"]][m
[31m-transform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 3.2381144, 2.5, 3.779572)[m
[32m+[m[32mtransform = Transform3D(1, 0, 0, 0, 1, 0, 0, 0, 1, 1.4911747, 2.5, -15.876324)[m
 script = ExtResource("31_73b8e")[m
 objects_root = NodePath("../CurrentLevel/MainTestScene")[m
 [m
[1mdiff --git a/SceneObjs/Environmental/flat_portal.gd b/SceneObjs/Environmental/flat_portal.gd[m
[1mindex a3f83fa..365ad1c 100644[m
[1m--- a/SceneObjs/Environmental/flat_portal.gd[m
[1m+++ b/SceneObjs/Environmental/flat_portal.gd[m
[36m@@ -133,13 +133,13 @@[m [mfunc _begin_object_transition(root: Node3D) -> void:[m
 			plane_position,[m
 			plane_normal[m
 		)[m
[31m-		_configure_copy_tree([m
[31m-			destination,[m
[31m-			destination_dimension,[m
[31m-			-1.0,[m
[31m-			plane_position,[m
[31m-			plane_normal[m
[31m-		)[m
[32m+[m		[32m#_configure_copy_tree([m
[32m+[m			[32m#destination,[m
[32m+[m			[32m#destination_dimension,[m
[32m+[m			[32m#-1.0,[m
[32m+[m			[32m#plane_position,[m
[32m+[m			[32m#plane_normal[m
[32m+[m		[32m#)[m
 [m
 		_transition_objects[id] = {[m
 			"original": original,[m
[36m@@ -281,16 +281,20 @@[m [mfunc _configure_copy([m
 func _sync_transition_objects() -> void:[m
 	for id in _transition_objects.keys():[m
 		var data: Dictionary = _transition_objects[id][m
[31m-[m
[32m+[m		[32mif !is_instance_valid(id):[m
[32m+[m			[32m_transition_objects.erase(id)[m
[32m+[m			[32mprint("Dead object update detected")[m
 		var original = data["original"] as GeometryInstance3D[m
[31m-		var source = data["source"] as GeometryInstance3D[m
[31m-		var destination = data["destination"] as GeometryInstance3D[m
[31m-[m
 		if not is_instance_valid(original):[m
[32m+[m			[32mprint("Invalid instance detected")[m
 			continue[m
[32m+[m		[32mvar source = data["source"] as GeometryInstance3D[m
[32m+[m		[32mvar destination = data["destination"] as GeometryInstance3D[m
 		if not is_instance_valid(source) or not is_instance_valid(destination):[m
[32m+[m			[32mprint("Invalid instance detected")[m
 			continue[m
 [m
[32m+[m
 		source.global_transform = original.global_transform[m
 		destination.global_transform = original.global_transform[m
 [m
[1mdiff --git a/SceneObjs/Environmental/level_master.gd b/SceneObjs/Environmental/level_master.gd[m
[1mindex 9ff3bf4..727702e 100644[m
[1m--- a/SceneObjs/Environmental/level_master.gd[m
[1m+++ b/SceneObjs/Environmental/level_master.gd[m
[36m@@ -10,7 +10,6 @@[m [mconst FLAT_PORTAL_SHADER = preload([m
 )[m
 [m
 @onready var _player: CharacterBody3D = $"../MainPlayer"[m
[31m-@onready var _player_cam  : Camera3D = $"../MainPlayer/CameraPivot/SpringArm3D/CurrPlayerCam/Camera3D"[m
 @onready var _overworld: Node3D = $MainTestScene[m
 @onready var _underworld: Node3D = $Underworld[m
 [m
[36m@@ -90,6 +89,10 @@[m [mfunc _assign_dimension_materials(root: Node, dimension: int) -> void:[m
 	for node in root.find_children("*", "MeshInstance3D", true, false):[m
 		_set_mesh_dimension(node as MeshInstance3D, dimension)[m
 [m
[32m+[m[32mfunc _assign_dimension_collisions() -> void:[m
[32m+[m[41m	[m
[32m+[m	[32mpass[m
[32m+[m
 [m
 func _set_mesh_dimension([m
 	mesh_instance: MeshInstance3D,[m
[36m@@ -98,6 +101,7 @@[m [mfunc _set_mesh_dimension([m
 	if mesh_instance == null:[m
 		return[m
 [m
[32m+[m	[32m# TODO: Set this as a next pass as to not override the material of the object[m
 	mesh_instance.material_override = FLAT_PORTAL_SHADER[m
 	mesh_instance.set_instance_shader_parameter([m
 		"visual_layer",[m
[1mdiff --git a/SceneObjs/Levels/CampLevel_albedo_bump_array.png.import b/SceneObjs/Levels/CampLevel_albedo_bump_array.png.import[m
[1mindex 9982ad9..a2e4d90 100644[m
[1m--- a/SceneObjs/Levels/CampLevel_albedo_bump_array.png.import[m
[1m+++ b/SceneObjs/Levels/CampLevel_albedo_bump_array.png.import[m
[36m@@ -3,16 +3,16 @@[m
 importer="2d_array_texture"[m
 type="CompressedTexture2DArray"[m
 uid="uid://dayf623x2xrj2"[m
[31m-path.etc2="res://.godot/imported/CampLevel_albedo_bump_array.png-5df6cc8bd15d75f95b5cea43b85523af.etc2.ctexarray"[m
[32m+[m[32mpath.s3tc="res://.godot/imported/CampLevel_albedo_bump_array.png-5df6cc8bd15d75f95b5cea43b85523af.s3tc.ctexarray"[m
 metadata={[m
[31m-"imported_formats": ["etc2_astc"],[m
[32m+[m[32m"imported_formats": ["s3tc_bptc"],[m
 "vram_texture": true[m
 }[m
 [m
 [deps][m
 [m
 source_file="res://SceneObjs/Levels/CampLevel_albedo_bump_array.png"[m
[31m-dest_files=["res://.godot/imported/CampLevel_albedo_bump_array.png-5df6cc8bd15d75f95b5cea43b85523af.etc2.ctexarray"][m
[32m+[m[32mdest_files=["res://.godot/imported/CampLevel_albedo_bump_array.png-5df6cc8bd15d75f95b5cea43b85523af.s3tc.ctexarray"][m
 [m
 [params][m
 [m
[1mdiff --git a/SceneObjs/Levels/CampLevel_normal_roughness_array.png.import b/SceneObjs/Levels/CampLevel_normal_roughness_array.png.import[m
[1mindex 8e5b15d..c22c9e4 100644[m
[1m--- a/SceneObjs/Levels/CampLevel_normal_roughness_array.png.import[m
[1m+++ b/SceneObjs/Levels/CampLevel_normal_roughness_array.png.import[m
[36m@@ -3,16 +3,16 @@[m
 importer="2d_array_texture"[m
 type="CompressedTexture2DArray"[m
 uid="uid://caxolilp7yt0w"[m
[31m-path.etc2="res://.godot/imported/CampLevel_normal_roughness_array.png-f5b7961c7f4358f5cda0de406546fc4c.etc2.ctexarray"[m
[32m+[m[32mpath.s3tc="res://.godot/imported/CampLevel_normal_roughness_array.png-f5b7961c7f4358f5cda0de406546fc4c.s3tc.ctexarray"[m
 metadata={[m
[31m-"imported_formats": ["etc2_astc"],[m
[32m+[m[32m"imported_formats": ["s3tc_bptc"],[m
 "vram_texture": true[m
 }[m
 [m
 [deps][m
 [m
 source_file="res://SceneObjs/Levels/CampLevel_normal_roughness_array.png"[m
[31m-dest_files=["res://.godot/imported/CampLevel_normal_roughness_array.png-f5b7961c7f4358f5cda0de406546fc4c.etc2.ctexarray"][m
[32m+[m[32mdest_files=["res://.godot/imported/CampLevel_normal_roughness_array.png-f5b7961c7f4358f5cda0de406546fc4c.s3tc.ctexarray"][m
 [m
 [params][m
 [m
[1mdiff --git a/SceneObjs/Levels/CampLevel_slot0_albedo_bump.png.import b/SceneObjs/Levels/CampLevel_slot0_albedo_bump.png.import[m
[1mindex 99e7a94..8bfa5c8 100644[m
[1m--- a/SceneObjs/Levels/CampLevel_slot0_albedo_bump.png.import[m
[1m+++ b/SceneObjs/Levels/CampLevel_slot0_albedo_bump.png.import[m
[36m@@ -3,16 +3,16 @@[m
 importer="texture"[m
 type="CompressedTexture2D"[m
 uid="uid://bm7uu5y0it7e2"[m
[31m-path.etc2="res://.godot/imported/CampLevel_slot0_albedo_bump.png-dc04bc284c202d9f593ec327de27fcc7.etc2.ctex"[m
[32m+[m[32mpath.s3tc="res://.godot/imported/CampLevel_slot0_albedo_bump.png-dc04bc284c202d9f593ec327de27fcc7.s3tc.ctex"[m
 metadata={[m
[31m-"imported_formats": ["etc2_astc"],[m
[32m+[m[32m"imported_formats": ["s3tc_bptc"],[m
 "vram_texture": true[m
 }[m
 [m
 [deps][m
 [m
 source_file="res://SceneObjs/Levels/CampLevel_slot0_albedo_bump.png"[m
[31m-dest_files=["res://.godot/imported/CampLevel_slot0_albedo_bump.png-dc04bc284c202d9f593ec327de27fcc7.etc2.ctex"][m
[32m+[m[32mdest_files=["res://.godot/imported/CampLevel_slot0_albedo_bump.png-dc04bc284c202d9f593ec327de27fcc7.s3tc.ctex"][m
 [m
 [params][m
 [m
[1mdiff --git a/SceneObjs/Levels/CampLevel_slot0_normal_roughness.png.import b/SceneObjs/Levels/CampLevel_slot0_normal_roughness.png.import[m
[1mindex 2c4de8d..eaf5edc 100644[m
[1m--- a/SceneObjs/Levels/CampLevel_slot0_normal_roughness.png.import[m
[1m+++ b/SceneObjs/Levels/CampLevel_slot0_normal_roughness.png.import[m
[36m@@ -3,16 +3,16 @@[m
 importer="texture"[m
 type="CompressedTexture2D"[m
 uid="uid://by2b4p3aj55nq"[m
[31m-path.etc2="res://.godot/imported/CampLevel_slot0_normal_roughness.png-e935a3c304fbfa792c0aefbee2b8aaa9.etc2.ctex"[m
[32m+[m[32mpath.s3tc="res://.godot/imported/CampLevel_slot0_normal_roughness.png-e935a3c304fbfa792c0aefbee2b8aaa9.s3tc.ctex"[m
 metadata={[m
[31m-"imported_formats": ["etc2_astc"],[m
[32m+[m[32m"imported_formats": ["s3tc_bptc"],[m
 "vram_texture": true[m
 }[m
 [m
 [deps][m
 [m
 source_file="res://SceneObjs/Levels/CampLevel_slot0_normal_roughness.png"[m
[31m-dest_files=["res://.godot/imported/CampLevel_slot0_normal_roughness.png-e935a3c304fbfa792c0aefbee2b8aaa9.etc2.ctex"][m
[32m+[m[32mdest_files=["res://.godot/imported/CampLevel_slot0_normal_roughness.png-e935a3c304fbfa792c0aefbee2b8aaa9.s3tc.ctex"][m
 [m
 [params][m
 [m
[1mdiff --git a/TerrainData/height.res b/TerrainData/height.res[m
[1mindex 54b7424..4a190a0 100644[m
Binary files a/TerrainData/height.res and b/TerrainData/height.res differ
[1mdiff --git a/TerrainData/normal.png b/TerrainData/normal.png[m
[1mindex 81e90c2..fcf7752 100644[m
Binary files a/TerrainData/normal.png and b/TerrainData/normal.png differ
[1mdiff --git a/Textures/Blender/Slime_Slime.png.import b/Textures/Blender/Slime_Slime.png.import[m
[1mindex 5f7d4e3..be0c83f 100644[m
[1m--- a/Textures/Blender/Slime_Slime.png.import[m
[1m+++ b/Textures/Blender/Slime_Slime.png.import[m
[36m@@ -3,9 +3,9 @@[m
 importer="texture"[m
 type="CompressedTexture2D"[m
 uid="uid://ccggsllvbs0ce"[m
[31m-path.etc2="res://.godot/imported/Slime_Slime.png-2b7c318556fd5a8f5736d0c8edd3c736.etc2.ctex"[m
[32m+[m[32mpath.s3tc="res://.godot/imported/Slime_Slime.png-2b7c318556fd5a8f5736d0c8edd3c736.s3tc.ctex"[m
 metadata={[m
[31m-"imported_formats": ["etc2_astc"],[m
[32m+[m[32m"imported_formats": ["s3tc_bptc"],[m
 "vram_texture": true[m
 }[m
 generator_parameters={[m
[36m@@ -15,7 +15,7 @@[m [mgenerator_parameters={[m
 [deps][m
 [m
 source_file="res://Textures/Blender/Slime_Slime.png"[m
[31m-dest_files=["res://.godot/imported/Slime_Slime.png-2b7c318556fd5a8f5736d0c8edd3c736.etc2.ctex"][m
[32m+[m[32mdest_files=["res://.godot/imported/Slime_Slime.png-2b7c318556fd5a8f5736d0c8edd3c736.s3tc.ctex"][m
 [m
 [params][m
 [m
[1mdiff --git a/Textures/Blender/Untitled_RockFace1.png.import b/Textures/Blender/Untitled_RockFace1.png.import[m
[1mindex 869eee2..355a013 100644[m
[1m--- a/Textures/Blender/Untitled_RockFace1.png.import[m
[1m+++ b/Textures/Blender/Untitled_RockFace1.png.import[m
[36m@@ -3,9 +3,9 @@[m
 importer="texture"[m
 type="CompressedTexture2D"[m
 uid="uid://b7uijevo2qdy"[m
[31m-path.etc2="res://.godot/imported/Untitled_RockFace1.png-b618d0dd5bdb0552cf6886fa342e518a.etc2.ctex"[m
[32m+[m[32mpath.s3tc="res://.godot/imported/Untitled_RockFace1.png-b618d0dd5bdb0552cf6886fa342e518a.s3tc.ctex"[m
 metadata={[m
[31m-"imported_formats": ["etc2_astc"],[m
[32m+[m[32m"imported_formats": ["s3tc_bptc"],[m
 "vram_texture": true[m
 }[m
 generator_parameters={[m
[36m@@ -15,7 +15,7 @@[m [mgenerator_parameters={[m
 [deps][m
 [m
 source_file="res://Textures/Blender/Untitled_RockFace1.png"[m
[31m-dest_files=["res://.godot/imported/Untitled_RockFace1.png-b618d0dd5bdb0552cf6886fa342e518a.etc2.ctex"][m
[32m+[m[32mdest_files=["res://.godot/imported/Untitled_RockFace1.png-b618d0dd5bdb0552cf6886fa342e518a.s3tc.ctex"][m
 [m
 [params][m
 [m
[1mdiff --git a/Textures/Blender/textures/TransportTubeTex.png.import b/Textures/Blender/textures/TransportTubeTex.png.import[m
[1mindex b947bb6..0b9602e 100644[m
[1m--- a/Textures/Blender/textures/TransportTubeTex.png.import[m
[1m+++ b/Textures/Blender/textures/TransportTubeTex.png.import[m
[36m@@ -3,16 +3,16 @@[m
 importer="texture"[m
 type="CompressedTexture2D"[m
 uid="uid://dguegj3hjv3cs"[m
[31m-path.etc2="res://.godot/imported/TransportTubeTex.png-0daa34b556516cdfa758622bda8ca300.etc2.ctex"[m
[32m+[m[32mpath.s3tc="res://.godot/imported/TransportTubeTex.png-0daa34b556516cdfa758622bda8ca300.s3tc.ctex"[m
 metadata={[m
[31m-"imported_formats": ["etc2_astc"],[m
[32m+[m[32m"imported_formats": ["s3tc_bptc"],[m
 "vram_texture": true[m
 }[m
 [m
 [deps][m
 [m
 source_file="res://Textures/Blender/textures/TransportTubeTex.png"[m
[31m-dest_files=["res://.godot/imported/TransportTubeTex.png-0daa34b556516cdfa758622bda8ca300.etc2.ctex"][m
[32m+[m[32mdest_files=["res://.godot/imported/TransportTubeTex.png-0daa34b556516cdfa758622bda8ca300.s3tc.ctex"][m
 [m
 [params][m
 [m
[1mdiff --git a/Textures/Blender/transport_tube_TransportTubeTex.png.import b/Textures/Blender/transport_tube_TransportTubeTex.png.import[m
[1mindex b29146f..acabc3f 100644[m
[1m--- a/Textures/Blender/transport_tube_TransportTubeTex.png.import[m
[1m+++ b/Textures/Blender/transport_tube_TransportTubeTex.png.import[m
[36m@@ -3,9 +3,9 @@[m
 importer="texture"[m
 type="CompressedTexture2D"[m
 uid="uid://batxglye73xsi"[m
[31m-path.etc2="res://.godot/imported/transport_tube_TransportTubeTex.png-3896e626dd5f22d70a0b110e3bde5752.etc2.ctex"[m
[32m+[m[32mpath.s3tc="res://.godot/imported/transport_tube_TransportTubeTex.png-3896e626dd5f22d70a0b110e3bde5752.s3tc.ctex"[m
 metadata={[m
[31m-"imported_formats": ["etc2_astc"],[m
[32m+[m[32m"imported_formats": ["s3tc_bptc"],[m
 "vram_texture": true[m
 }[m
 generator_parameters={[m
[36m@@ -15,7 +15,7 @@[m [mgenerator_parameters={[m
 [deps][m
 [m
 source_file="res://Textures/Blender/transport_tube_TransportTubeTex.png"[m
[31m-dest_files=["res://.godot/imported/transport_tube_TransportTubeTex.png-3896e626dd5f22d70a0b110e3bde5752.etc2.ctex"][m
[32m+[m[32mdest_files=["res://.godot/imported/transport_tube_TransportTubeTex.png-3896e626dd5f22d70a0b110e3bde5752.s3tc.ctex"][m
 [m
 [params][m
 [m
[1mdiff --git a/Textures/Extracted/BombAnim/BombActive1.png.import b/Textures/Extracted/BombAnim/BombActive1.png.import[m
[1mindex becd873..dda1e27 100644[m
[1m--- a/Textures/Extracted/BombAnim/BombActive1.png.import[m
[1m+++ b/Textures/Extracted/BombAnim/BombActive1.png.import[m
[36m@@ -3,16 +3,16 @@[m
 importer="texture"[m
 type="CompressedTexture2D"[m
 uid="uid://0mcekx3gvsjc"[m
[31m-path.etc2="res://.godot/imported/BombActive1.png-b5fd533acc2eaddf29b78d8692118cb5.etc2.ctex"[m
[32m+[m[32mpath.s3tc="res://.godot/imported/BombActive1.png-b5fd533acc2eaddf29b78d8692118cb5.s3tc.ctex"[m
 metadata={[m
[31m-"imported_formats": ["etc2_astc"],[m
[32m+[m[32m"imported_formats": ["s3tc_bptc"],[m
 "vram_texture": true[m
 }[m
 [m
 [deps][m
 [m
 source_file="res://Textures/Extracted/BombAnim/BombActive1.png"[m
[31m-dest_files=["res://.godot/imported/BombActive1.png-b5fd533acc2eaddf29b78d8692118cb5.etc2.ctex"][m
[32m+[m[32mdest_files=["res://.godot/imported/BombActive1.png-b5fd533acc2eaddf29b78d8692118cb5.s3tc.ctex"][m
 [m
 [params][m
 [m
[1mdiff --git a/Textures/Extracted/BombAnim/BombActive10.png.import b/Textures/Extracted/BombAnim/BombActive10.png.import[m
[1mindex b41db4c..df2f933 100644[m
[1m--- a/Textures/Extracted/BombAnim/BombActive10.png.import[m
[1m+++ b/Textures/Extracted/BombAnim/BombActive10.png.import[m
[36m@@ -3,16 +3,16 @@[m
 importer="texture"[m
 type="CompressedTexture2D"[m
 uid="uid://c0klk1jd8kxfh"[m
[31m-path.etc2="res://.godot/imported/BombActive10.png-bd925529e79cab4ac10f5721ed1394e4.etc2.ctex"[m
[32m+[m[32mpath.s3tc="res://.godot/imported/BombActive10.png-bd925529e79cab4ac10f5721ed1394e4.s3tc.ctex"[m
 metadata={[m
[31m-"imported_formats": ["etc2_astc"],[m
[32m+[m[32m"imported_formats": ["s3tc_bptc"],[m
 "vram_texture": true[m
 }[m
 [m
 [deps][m
 [m
 source_file="res://Textures/Extracted/BombAnim/BombActive10.png"[m
[31m-dest_files=["res://.godot/imported/BombActive10.png-bd925529e79cab4ac10f5721ed1394e4.etc2.ctex"][m
[32m+[m[32mdest_files=["res://.godot/imported/BombActive10.png-bd925529e79cab4ac10f5721ed1394e4.s3tc.ctex"][m
 [m
 [params][m
 [m
[1mdiff --git a/Textures/Extracted/BombAnim/BombActive11.png.import b/Textures/Extracted/BombAnim/BombActive11.png.import[m
[1mindex f2cb229..f31240c 100644[m
[1m--- a/Textures/Extracted/BombAnim/BombActive11.png.import[m
[1m+++ b/Textures/Extracted/BombAnim/BombActive11.png.import[m
[36m@@ -3,16 +3,16 @@[m
 importer="texture"[m
 type="CompressedTexture2D"[m
 uid="uid://bc6dav1sqvqo5"[m
[31m-path.etc2="res://.godot/imported/BombActive11.png-b48a2af611521e2b1ef08b83ab141250.etc2.ctex"[m
[32m+[m[32mpath.s3tc="res://.godot/imported/BombActive11.png-b48a2af611521e2b1ef08b83ab141250.s3tc.ctex"[m
 metadata={[m
[31m-"imported_formats": ["etc2_astc"],[m
[32m+[m[32m"imported_formats": ["s3tc_bptc"],[m
 "vram_texture": true[m
 }[m
 [m
 [deps][m
 [m
 source_file="res://Textures/Extracted/BombAnim/BombActive11.png"[m
[31m-dest_files=["res://.godot/imported/BombActive11.png-b48a2af611521e2b1ef08b83ab141250.etc2.ctex"][m
[32m+[m[32mdest_files=["res://.godot/imported/BombActive11.png-b48a2af611521e2b1ef08b83ab141250.s3tc.ctex"][m
 [m
 [params][m
 [m
[1mdiff --git a/Textures/Extracted/BombAnim/BombActive12.png.import b/Textures/Extracted/BombAnim/BombActive12.png.import[m
[1mindex 0b7f05d..c325336 100644[m
[1m--- a/Textures/Extracted/BombAnim/BombActive12.png.import[m
[1m+++ b/Textures/Extracted/BombAnim/BombActive12.png.import[m
[36m@@ -3,16 +3,16 @@[m
 importer="texture"[m
 type="CompressedTexture2D"[m
 uid="uid://ff52dk6482ga"[m
[31m-path.etc2="res://.godot/imported/BombActive12.png-e9c83f8224b4dccf30321229774e192a.etc2.ctex"[m
[32m+[m[32mpath.s3tc="res://.godot/imported/BombActive12.png-e9c83f8224b4dccf30321229774e192a.s3tc.ctex"[m
 metadata={[m
[31m-"imported_formats": ["etc2_astc"],[m
[32m+[m[32m"imported_formats": ["s3tc_bptc"],[m
 "vram_texture": true[m
 }[m
 [m
 [deps][m
 [m
 source_file="res://Textures/Extracted/BombAnim/BombActive12.png"[m
[31m-dest_files=["res://.godot/imported/BombActive12.png-e9c83f8224b4dccf30321229774e192a.etc2.ctex"][m
[32m+[m[32mdest_files=["res://.godot/imported/BombActive12.png-e9c83f8224b4dccf30321229774e192a.s3tc.ctex"][m
 [m
 [params][m
 [m
[1mdiff --git a/Textures/Extracted/BombAnim/BombActive13.png.import b/Textures/Extracted/BombAnim/BombActive13.png.import[m
[1mindex c245856..d7b2840 100644[m
[1m--- a/Textures/Extracted/BombAnim/BombActive13.png.import[m
[1m+++ b/Textures/Extracted/BombAnim/BombActive13.png.import[m
[36m@@ -3,16 +3,16 @@[m
 importer="texture"[m
 type="CompressedTexture2D"[m
 uid="uid://bws6qc14kpp4d"[m
[31m-path.etc2="res://.godot/imported/BombActive13.png-0f24a9832c350d112817943570fa4d78.etc2.ctex"[m
[32m+[m[32mpath.s3tc="res://.godot/imported/BombActive13.png-0f24a9832c350d112817943570fa4d78.s3tc.ctex"[m
 metadata={[m
[31m-"imported_formats": ["etc2_astc"],[m
[32m+[m[32m"imported_formats": ["s3tc_bptc"],[m
 "vram_texture": true[m
 }[m
 [m
 [deps][m
 [m
 source_file="res://Textures/Extracted/BombAnim/BombActive13.png"[m
[31m-dest_files=["res://.godot/imported/BombActive13.png-0f24a9832c350d112817943570fa4d78.etc2.ctex"][m
[32m+[m[32mdest_files=["res://.godot/imported/BombActive13.png-0f24a9832c350d112817943570fa4d78.s3tc.ctex"][m
 [m
 [params][m
 [m
[1mdiff --git a/Textures/Extracted/BombAnim/BombActive14.png.import b/Textures/Extracted/BombAnim/BombActive14.png.import[m
[1mindex 811f36b..279725a 100644[m
[1m--- a/Textures/Extracted/BombAnim/BombActive14.png.import[m
[1m+++ b/Textures/Extracted/BombAnim/BombActive14.png.import[m
[36m@@ -3,16 +3,16 @@[m
 importer="texture"[m
 type="CompressedTexture2D"[m
 uid="uid://uwfdn5pot1e3"[m
[31m-path.etc2="res://.godot/imported/BombActive14.png-14a047d3201e5c813e7884fdc20de812.etc2.ctex"[m
[32m+[m[32mpath.s3tc="res://.godot/imported/BombActive14.png-14a047d3201e5c813e7884fdc20de812.s3tc.ctex"[m
 metadata={[m
[31m-"imported_formats": ["etc2_astc"],[m
[32m+[m[32m"imported_formats": ["s3tc_bptc"],[m
 "vram_texture": true[m
 }[m
 [m
 [deps][m
 [m
 source_file="res://Textures/Extracted/BombAnim/BombActive14.png"[m
[31m-dest_files=["res://.godot/imported/BombActive14.png-14a047d3201e5c813e7884fdc20de812.etc2.ctex"][m
[32m+[m[32mdest_files=["res://.godot/imported/BombActive14.png-14a047d3201e5c813e7884fdc20de812.s3tc.ctex"][m
 [m
 [params][m
 [m
[1mdiff --git a/Textures/Extracted/BombAnim/BombActive15.png.import b/Textures/Extracted/BombAnim/BombActive15.png.import[m
[1mindex 58146dc..bdad0f1 100644[m
[1m--- a/Textures/Extracted/BombAnim/BombActive15.png.import[m
[1m+++ b/Textures/Extracted/BombAnim/BombActive15.png.import[m
[36m@@ -3,16 +3,16 @@[m
 importer="texture"[m
 type="CompressedTexture2D"[m
 uid="uid://ci6duip6xajoi"[m
[31m-path.etc2="res://.godot/imported/BombActive15.png-46462b1da77137b103af1f2aaa318dee.etc2.ctex"[m
[32m+[m[32mpath.s3tc="res://.godot/imported/BombActive15.png-46462b1da77137b103af1f2aaa318dee.s3tc.ctex"[m
 metadata={[m
[31m-"imported_formats": ["etc2_astc"],[m
[32m+[m[32m"imported_formats": ["s3tc_bptc"],[m
 "vram_texture": true[m
 }[m
 [m
 [deps][m
 [m
 source_file="res://Textures/Extracted/BombAnim/BombActive15.png"[m
[31m-dest_files=["res://.godot/imported/BombActive15.png-46462b1da77137b103af1f2aaa318dee.etc2.ctex"][m
[32m+[m[32mdest_files=["res://.godot/imported/BombActive15.png-46462b1da77137b103af1f2aaa318dee.s3tc.ctex"][m
 [m
 [params][m
 [m
[1mdiff --git a/Textures/Extracted/BombAnim/BombActive16.png.import b/Textures/Extracted/BombAnim/BombActive16.png.import[m
[1mindex 4c99455..c3dd2b4 100644[m
[1m--- a/Textures/Extracted/BombAnim/BombActive16.png.import[m
[1m+++ b/Textures/Extracted/BombAnim/BombActive16.png.import[m
[36m@@ -3,16 +3,16 @@[m
 importer="texture"[m
 type="CompressedTexture2D"[m
 uid="uid://dskmjw04bv3go"[m
[31m-path.etc2="res://.godot/imported/BombActive16.png-8a69a5f590d1ac1235bd4404d4763349.etc2.ctex"[m
[32m+[m[32mpath.s3tc="res://.godot/imported/BombActive16.png-8a69a5f590d1ac1235bd4404d4763349.s3tc.ctex"[m
 metadata={[m
[31m-"imported_formats": ["etc2_astc"],[m
[32m+[m[32m"imported_formats": ["s3tc_bptc"],[m
 "vram_texture": true[m
 }[m
 [m
 [deps][m
 [m
 source_file="res://Textures/Extracted/BombAnim/BombActive16.png"[m
[31m-dest_files=["res://.godot/imported/BombActive16.png-8a69a5f590d1ac1235bd4404d4763349.etc2.ctex"][m
[32m+[m[32mdest_files=["res://.godot/imported/BombActive16.png-8a69a5f590d1ac1235bd4404d4763349.s3tc.ctex"][m
 [m
 [params][m
 [m
[1mdiff --git a/Textures/Extracted/BombAnim/BombActive17.png.import b/Textures/Extracted/BombAnim/BombActive17.png.import[m
[1mindex f04057a..d8ff6c6 100644[m
[1m--- a/Textures/Extracted/BombAnim/BombActive17.png.import[m
[1m+++ b/Textures/Extracted/BombAnim/BombActive17.png.import[m
[36m@@ -3,16 +3,16 @@[m
 importer="texture"[m
 type="CompressedTexture2D"[m
 uid="uid://b5japj4hkskl0"[m
[31m-path.etc2="res://.godot/imported/BombActive17.png-97efb5df552002f4133edf5a911316fa.etc2.ctex"[m
[32m+[m[32mpath.s3tc="res://.godot/imported/BombActive17.png-97efb5df552002f4133edf5a911316fa.s3tc.ctex"[m
 metadata={[m
[31m-"imported_formats": ["etc2_astc"],[m
[32m+[m[32m"imported_formats": ["s3tc_bptc"],[m
 "vram_texture": true[m
 }[m
 [m
 [deps][m
 [m
 source_file="res://Textures/Extracted/BombAnim/BombActive17.png"[m
[31m-dest_files=["res://.godot/imported/BombActive17.png-97efb5df552002f4133edf5a911316fa.etc2.ctex"][m
[32m+[m[32mdest_files=["res://.godot/imported/BombActive17.png-97efb5df552002f4133edf5a911316fa.s3tc.ctex"][m
 [m
 [params][m
 [m
[1mdiff --git a/Textures/Extracted/BombAnim/BombActive18.png.import b/Textures/Extracted/BombAnim/BombActive18.png.import[m
[1mindex f14752e..90541ce 100644[m
[1m--- a/Textures/Extracted/BombAnim/BombActive18.png.import[m
[1m+++ b/Textures/Extracted/BombAnim/BombActive18.png.import[m
[36m@@ -3,16 +3,16 @@[m
 importer="texture"[m
 type="CompressedTexture2D"[m
 uid="uid://dpre7dmq548tj"[m
[31m-path.etc2="res://.godot/imported/BombActive18.png-04e609e565d80ab31bf0047147e8d611.etc2.ctex"[m
[32m+[m[32mpath.s3tc="res://.godot/imported/BombActive18.png-04e609e565d80ab31bf0047147e8d611.s3tc.ctex"[m
 metadata={[m
[31m-"imported_formats": ["etc2_astc"],[m
[32m+[m[32m"imported_formats": ["s3tc_bptc"],[m
 "vram_texture": true[m
 }[m
 [m
 [deps][m
 [m
 source_file="res://Textures/Extracted/BombAnim/BombActive18.png"[m
[31m-dest_files=["res://.godot/imported/BombActive18.png-04e609e565d80ab31bf0047147e8d611.etc2.ctex"][m
[32m+[m[32mdest_files=["res://.godot/imported/BombActive18.png-04e609e565d80ab31bf0047147e8d611.s3tc.ctex"][m
 [m
 [params][m
 [m
[1mdiff --git a/Textures/Extracted/BombAnim/BombActive19.png.import b/Textures/Extracted/BombAnim/BombActive19.png.import[