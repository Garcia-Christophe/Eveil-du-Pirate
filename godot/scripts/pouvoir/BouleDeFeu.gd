extends RigidBody3D

# Constantes
const scene_zone_de_feu = preload("res://scenes/Pouvoir/ZoneDeFeu.tscn")

# Variables
var lancee = false
var explosee = false

# A chaque frame, vérifie si la boule est explosée au sol pour créer la zone de feu
func _physics_process(_delta):
	if lancee && position.y < 0.5 && !explosee:
		explosee = true
		zone_en_feu()

# Gestion du tir
func tirer(joueur: CharacterBody3D):
	# La boule de feu n'est plus dans la main du joueur, mais dans le monde
	var position_originale = global_transform
	get_parent().remove_child(self)
	joueur.get_parent().add_child(self)
	global_transform = position_originale
	
	# Impulsion (lancé de la boule)
	# TODO: accrocher la boule à la main: OK. 
	#   Quand tourne/saute etc: OK.
	#   Quand bouge la souris: ... Il faut prendre ça en compte aussi ? Comment ?
	# TODO: ne pas lancer sur l'axe x de la boule, mais sur l'axe (-)? de la direction de la cam !
	# TODO: fonctionnement (amplifié?) ok si marche/court/saute
	
	var impulsion = Vector3(global_transform.basis.x.x, global_transform.basis.x.y + 0.5, global_transform.basis.x.z)
	apply_impulse(impulsion, impulsion * 20)
	gravity_scale = 1
	set_collision_layer_value(1, true)
	set_collision_mask_value(1, true)
	lancee = true
	
	# Mise à jour de l'arme du joueur
	joueur.changer_arme(null)

# Crée une zone de feu à l'endroit où la boule touche le sol
func zone_en_feu():
	var zone_de_feu = scene_zone_de_feu.instantiate()
	get_parent().add_child(zone_de_feu)
	zone_de_feu.global_position = Vector3(global_position.x, 0, global_position.z)
	queue_free()
