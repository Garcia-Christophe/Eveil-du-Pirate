extends CharacterBody3D

@onready var joueur = get_parent().get_node("Joueur")
@onready var navigation : NavigationAgent3D = $NavigationAgent3D
@onready var animations = $Visuel/bot_femme/AnimationPlayer

# Etats
@onready var rond_etat = $RondEtat
@onready var rond_points_suspension = preload("res://images/rondPointsSuspension.png")
@onready var rond_interrogation = preload("res://images/rondInterrogation.png")
@onready var rond_exclamation = preload("res://images/rondExclamation.png")

# Constantes
const VITESSE_MARCHE = 2.0
const VITESSE_COURSE = 4.5
var GRAVITE = ProjectSettings.get_setting("physics/3d/default_gravity")

# Direction d'observation définies au hasard
var x_position = randf_range(-360,360)
var z_position = randf_range(-360,360)

# Etat du garde
const deplacement_ou_non = [true, false]
var deplacement = deplacement_ou_non[randi() % deplacement_ou_non.size()]
var apercoit = false
var curieux = false
var poursuite = false
var joueur_enfui = false

func _ready():
	rond_etat.texture = null

# Exécuter à chaque frame
func _process(delta):
	if poursuite == true:
		# Poursuit le joueur
		se_diriger_vers_le_joueur(true, delta)
	elif curieux == true:
		# Marche vers le joueur
		se_diriger_vers_le_joueur(false, delta)
	elif joueur_enfui == true || apercoit == true:
		# Fixe le joueur lorsqu'il est sorti de sa zone
		animations.play("attendre")
		var position_garde = self.global_transform.origin
		var position_joueur = joueur.global_transform.origin

		# Vérifie que les positions sont différentes avant d'appeler looking_at
		if position_garde != position_joueur:
			var wtransform = self.global_transform.looking_at(Vector3(position_joueur.x, position_garde.y, position_joueur.z), Vector3.UP)
			var wrotation = Quaternion(global_transform.basis).slerp(Quaternion(wtransform.basis), 0.15)
			self.global_transform = Transform3D(Basis(wrotation), position_garde)
	elif deplacement == true:
		# Se déplace tranquillement
		animations.play("marcher")
		var velocite = global_transform.basis.z.normalized() * VITESSE_MARCHE * delta
		move_and_collide(-velocite)
	else:
		# Regarde dans une autre direction
		animations.play("attendre")
		var position_garde = self.global_transform.origin
		
		var wtransform = self.global_transform.looking_at(Vector3(x_position, position_garde.y, z_position), Vector3.UP)
		var wrotation = Quaternion(global_transform.basis).slerp(Quaternion(wtransform.basis), 0.15)
		self.global_transform = Transform3D(Basis(wrotation), position_garde)

	if not is_on_floor():
		move_and_collide(-global_transform.basis.y.normalized() * GRAVITE * delta)

# S'oriente et se déplace vers le joueur
func se_diriger_vers_le_joueur(courir, delta):
	if joueur != null:
		var vitesse = VITESSE_COURSE if courir else VITESSE_MARCHE
		animations.play("courir" if courir else "marcher")
		
		# Orientation vers la position du joueur
		var position_garde = self.global_transform.origin
		var position_joueur = joueur.global_transform.origin

		# Vérifie que les positions sont différentes avant d'appeler looking_at
		if position_garde != position_joueur:
			var wtransform = self.global_transform.looking_at(Vector3(position_joueur.x, position_garde.y, position_joueur.z), Vector3.UP)
			var wrotation = Quaternion(global_transform.basis).slerp(Quaternion(wtransform.basis), 0.15)
			self.global_transform = Transform3D(Basis(wrotation), position_garde)

		# Définie la prochaine position du garde (en direction du joueur)
		navigation.set_target_position(joueur.transform.origin)
		# Déplacement vers le joueur
		var position_suivante = navigation.get_next_path_position()
		var velocite = (position_suivante - transform.origin).normalized() * vitesse  * delta
		move_and_collide(velocite)

# Timer pour décider si le garde se déplace ou s'il regarde ailleurs
func _on_timer_timeout():
	$Timer.set_wait_time(randf_range(4,8))
	if rond_etat.texture == null:
		x_position = randf_range(-360,360) 
		z_position = randf_range(-360,360)
		# Décision du comportement au hasard
		deplacement = deplacement_ou_non[randi() % deplacement_ou_non.size()]
	$Timer.start()

# Timer pour le temps d'observation du joueur lorsqu'il s'est échappé
func _on_timer_2_timeout():
	joueur_enfui = false
	if !apercoit && !curieux && !poursuite:
		rond_etat.texture = null

func _on_navigation_agent_3d_velocity_computed(safe_velocity):
	move_and_collide(safe_velocity)

func _on_area_precaution_body_entered(body):
	if body.name == ("Joueur"):
		apercoit = true
		rond_etat.texture = rond_points_suspension

func _on_area_precaution_body_exited(body):
	if body.name == ("Joueur"):
		apercoit = false
		poursuite = false
		joueur_enfui = true
		rond_etat.texture = rond_points_suspension
		$Timer2.start()

func _on_area_avertissement_body_entered(body):
	if body.name == ("Joueur"):
		curieux = true
		rond_etat.texture = rond_interrogation

func _on_area_avertissement_body_exited(body):
	if body.name == ("Joueur"):
		curieux = false

# Le joueur entre dans la zone de détection
func _on_area_danger_body_entered(body):
	if body.name == ("Joueur"):
		poursuite = true
		rond_etat.texture = rond_exclamation

# Le joueur sort de la zone de détection
func _on_area_danger_body_exited(_body):
	pass
