extends CharacterBody3D

@onready var camera_pivot = $CameraWrapper
@onready var camera = $CameraWrapper/SpringArm3D/Camera3D
@onready var visuel = $Visuel
@onready var animations = $Visuel/bot_homme/AnimationPlayer
@onready var joueurInteracteur = $JoueurInteracteur
@onready var alpha_joints = $Visuel/bot_homme/Armature/GeneralSkeleton/Alpha_Joints
@onready var alpha_surface = $Visuel/bot_homme/Armature/GeneralSkeleton/Alpha_Surface

# Constantes
const VITESSE_MARCHE = 2.0
#const VITESSE_COURSE = 5.0
const VITESSE_COURSE = 10.0
var VITESSE = VITESSE_MARCHE
const VELOCITE_SAUT = 4.5
const SENSIBILITE_SOURIS = 0.005
var GRAVITE = 9.81

# Variables
var pouvoir: Pouvoirs.Noms = Pouvoirs.Noms.INVISIBLE
var pouvoir_disponible = true
var layer_principal_camera

# Chaque joueur a une autorité différente, permettant d'avoir un contrôle séparé des personnages
func _enter_tree():
	set_multiplayer_authority(str(name).to_int())
	layer_principal_camera = 10 + get_tree().get_nodes_in_group("Joueur").size()

func _ready():
	if not is_multiplayer_authority(): return
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.current = true
	joueurInteracteur.joueur = self
	camera.set_cull_mask_value(layer_principal_camera, true)

func _input(event):
	if not is_multiplayer_authority(): return
	
	# Gestion de la rotation de la vue via la souris
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * SENSIBILITE_SOURIS)
		camera_pivot.rotate_x(-event.relative.y * SENSIBILITE_SOURIS)
		camera_pivot.rotation.x = clamp(camera_pivot.rotation.x, -PI/3, PI/3)

func _physics_process(delta):
	if not is_multiplayer_authority(): return
	
	# Mise à jour de la disponibilité du pouvoir du joueur
	pouvoir_disponible = Pouvoirs.mise_a_jour_disponibilite_pouvoir(self)
	
	if not is_on_floor():
		velocity.y -= GRAVITE * delta
	
	# Définition de la vitesse du perso
	if Input.is_action_pressed("courir"):
		VITESSE = VITESSE_COURSE
	else:
		VITESSE = VITESSE_MARCHE

	# Gestion du saut
	if Input.is_action_just_pressed("sauter") and is_on_floor():
		velocity.y = VELOCITE_SAUT
		animations.stop()
		animations.play("sauter")

	# Définition de la direction du joueur (perso + caméra)
	var direction_input = Input.get_vector("gauche", "droite", "avancer", "reculer")
	var direction_camera = -camera_pivot.global_transform.basis.z.normalized()
	var direction_personnage = (transform.basis * Vector3(direction_input.x, 0, direction_input.y)).normalized()
	
	if direction_personnage.length_squared() > 0:
		# Perso mobile
		if is_on_floor() and animations.current_animation != "sauter":
			if Input.is_action_pressed("courir"):
				animations.play("courir")
			else:
				animations.play("marcher")
		
		# Déplacement du perso
		velocity.x = direction_personnage.x * VITESSE
		velocity.z = direction_personnage.z * VITESSE

		# Rotation du perso suivant sa direction
		var rotation_cible = atan2(direction_personnage.x, direction_personnage.z) - atan2(direction_camera.x, direction_camera.z)
		visuel.rotation.y = lerp_angle(visuel.rotation.y, rotation_cible, 0.15)
	else:
		# Perso immobile
		if animations.current_animation != "attendre" and animations.current_animation != "sauter":
			animations.play("attendre")
		
		# Déplacement du perso
		velocity.x = move_toward(velocity.x, 0, VITESSE)
		velocity.z = move_toward(velocity.z, 0, VITESSE)
	
	# Gestion du pouvoir
	if Input.is_action_just_pressed("activer_pouvoir") && pouvoir_disponible:
		Pouvoirs.activer_pouvoir(self)

	# Application des changements (vélocités, rotations...)
	move_and_slide()

# Retourne le pouvoir du joueur
func get_pouvoir():
	return pouvoir

# Définit le pouvoir du joueur
func set_pouvoir(nouveau_pouvoir: Pouvoirs.Noms):
	pouvoir = nouveau_pouvoir
