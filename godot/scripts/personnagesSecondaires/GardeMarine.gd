extends CharacterBody3D

@export var position_initiale : Vector3
@export var zone_de_circulation : Area3D
@onready var navigation : NavigationAgent3D = $NavigationAgent3D
@onready var animations = $Visuel/bot_femme/AnimationPlayer
@onready var raycast_position = $RayCast3D_Position

# Etats
@onready var rond_etat = $RondEtat
@onready var rond_points_suspension = preload("res://images/rondPointsSuspension.png")
@onready var rond_interrogation = preload("res://images/rondInterrogation.png")
@onready var rond_exclamation = preload("res://images/rondExclamation.png")

# Constantes
const VITESSE_MARCHE = 2.0
const VITESSE_COURSE = 4.5
var GRAVITE = ProjectSettings.get_setting("physics/3d/default_gravity")
var joueur

# Direction d'observation définies au hasard
var x_position = randf_range(-360,360)
var z_position = randf_range(-360,360)

# Etat du garde
const deplacement_ou_non = [true, false]
var deplacement = deplacement_ou_non[randi() % deplacement_ou_non.size()]
var retour_position_initiale = false
var apercoit = false
var curieux = false
var poursuite = false
var joueur_enfui = false

# Lorsque le noeud du garde a chargé
func _ready():
	rond_etat.texture = null

# Exécuter à chaque frame
func _process(delta):
	# Récupère la référence du joueur dès qu'il entre dans la partie
	if joueur == null:
		joueur = get_tree().get_root().get_node_or_null("Monde/IlePrincipale/Joueur")
		if joueur == null:
			joueur = get_tree().get_root().get_node_or_null("Monde/IleSecondaire/Joueur")
		return;
	
	if poursuite == true:
		# Poursuit le joueur
		se_diriger_vers(joueur.global_transform.origin, true, delta)
	elif curieux == true:
		if peut_voir_le_joueur():
			se_diriger_vers(joueur.global_transform.origin, false, delta)
		else:
			curieux = false
			apercoit = false
			rond_etat.texture = null
			if !est_dans_zone_de_circulation(position):
				retour_position_initiale = true
	elif joueur_enfui == true || (apercoit == true && !deplacement):
		if peut_voir_le_joueur():
			# Fixe le joueur lorsqu'il est sorti de sa zone
			animations.play("attendre")
			var position_garde = self.global_transform.origin
			var position_joueur = joueur.global_transform.origin

			# Vérifie que les positions sont différentes avant d'appeler looking_at
			if Vector3(position_joueur.x, position_garde.y, position_joueur.z) != Vector3.UP:
				var wtransform = self.global_transform.looking_at(Vector3(position_joueur.x, position_garde.y, position_joueur.z), Vector3.UP)
				var wrotation = Quaternion(global_transform.basis).slerp(Quaternion(wtransform.basis), 0.15)
				self.global_transform = Transform3D(Basis(wrotation), position_garde)
		else:
			apercoit = false
			joueur_enfui = false
			rond_etat.texture = null
			if !est_dans_zone_de_circulation(position):
				retour_position_initiale = true
	elif retour_position_initiale == true && animations.current_animation != "coup_de_pied":
		# Se dirige vers sa position initiale
		deplacement = false
		se_diriger_vers(position_initiale, false, delta)
		
		if position.distance_to(position_initiale) < 1:
			# Le garde a retrouvé sa position initiale, il peut retrouver son comportement normal
			retour_position_initiale = false
	elif deplacement == true && animations.current_animation != "coup_de_pied":
		# Se déplace tranquillement dans sa zone de déplacement
		var velocite = global_transform.basis.z.normalized() * VITESSE_MARCHE * delta
		var position_suivante = position - velocite
		
		# Vérifie s'il y a une collision avec l'Area3D
		if est_dans_zone_de_circulation(position_suivante):
			animations.play("marcher")
			move_and_collide(-velocite)
		else:
			deplacement = false
	elif animations.current_animation != "coup_de_pied":
		# Regarde dans une autre direction
		animations.play("attendre")
		var position_garde = self.global_transform.origin
		
		var wtransform = self.global_transform.looking_at(Vector3(x_position, position_garde.y, z_position), Vector3.UP)
		var wrotation = Quaternion(global_transform.basis).slerp(Quaternion(wtransform.basis), 0.03)
		self.global_transform = Transform3D(Basis(wrotation), position_garde)

	if not is_on_floor():
		move_and_collide(-global_transform.basis.y.normalized() * GRAVITE * delta)

# S'oriente et se déplace vers une position cible
func se_diriger_vers(position_cible, courir, delta):
	var vitesse = VITESSE_COURSE if courir else VITESSE_MARCHE
	var position_garde = self.global_transform.origin

	# Vérifie que les positions sont différentes avant d'appeler looking_at
	if Vector3(position_cible.x, position_garde.y, position_cible.z) != Vector3.UP:
		# Orientation vers la position cible
		var wtransform = self.global_transform.looking_at(Vector3(position_cible.x, position_garde.y, position_cible.z), Vector3.UP)
		var wrotation = Quaternion(global_transform.basis).slerp(Quaternion(wtransform.basis), 0.15)
		self.global_transform = Transform3D(Basis(wrotation), position_garde)

	# Définie la prochaine position du garde (en direction de la cible)
	navigation.set_target_position(position_cible)
	# Déplacement vers la cible
	var position_suivante = navigation.get_next_path_position()
	var distance = position.distance_to(joueur.position)
	var velocite = (position_suivante - transform.origin).normalized() * vitesse  * delta
	if distance <= 1.5:
		# Le garde a capturé le joueur
		poursuite = false
		curieux = false
		apercoit = false
		joueur_enfui = false
		animations.play("coup_de_pied")
		if !est_dans_zone_de_circulation(position):
			retour_position_initiale = true
	else:
		animations.play("courir" if courir else "marcher")
		move_and_collide(velocite)

# Renvoie un boolean suivant si la position est dans la zone de circulation
func est_dans_zone_de_circulation(position_a_verifier):
	raycast_position.global_position.x = position_a_verifier.x
	raycast_position.global_position.z = position_a_verifier.z
	raycast_position.force_raycast_update()
	
	# Vérifie s'il y a une collision avec l'Area3D
	return raycast_position.is_colliding() and raycast_position.get_collider() == zone_de_circulation

# Renvoie un boolean suivant si le garde voit le joueur
func peut_voir_le_joueur():
	var direct_state = get_world_3d().direct_space_state
	var collision = direct_state.intersect_ray(PhysicsRayQueryParameters3D.create(Vector3(position.x, 1.68, position.z), Vector3(joueur.position.x, 1.68, joueur.position.z)))
	
	if collision:
		return collision.collider == joueur
	else:
		return false

# Timer pour décider si le garde se déplace ou s'il regarde ailleurs
func _on_timer_timeout():
	$Timer.set_wait_time(randf_range(4,8))
	if rond_etat.texture == null && !retour_position_initiale:
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
		if !est_dans_zone_de_circulation(position):
			retour_position_initiale = true

func _on_navigation_agent_3d_velocity_computed(safe_velocity):
	move_and_collide(safe_velocity)

# Le joueur entre dans la zone de précaution du garde
func _on_area_precaution_body_entered(body):
	if body.name == ("Joueur"):
		apercoit = true
		rond_etat.texture = rond_points_suspension
		retour_position_initiale = false

# Le joueur sort de la zone de précaution du garde
func _on_area_precaution_body_exited(body):
	if body.name == ("Joueur") && !retour_position_initiale:
		apercoit = false
		poursuite = false
		joueur_enfui = true
		rond_etat.texture = rond_points_suspension
		$Timer2.start()

# Le joueur entre dans la zone de curiosité du garde
func _on_area_avertissement_body_entered(body):
	if body.name == ("Joueur") && !poursuite:
		curieux = true
		rond_etat.texture = rond_interrogation
		retour_position_initiale = false

# Le joueur sort de la zone de curiosité du garde
func _on_area_avertissement_body_exited(body):
	if body.name == ("Joueur") && !retour_position_initiale:
		curieux = false
		if !poursuite && apercoit:
			rond_etat.texture = rond_points_suspension

# Le joueur entre dans la zone de détection (danger) du garde
func _on_area_danger_body_entered(body):
	if body.name == ("Joueur"):
		poursuite = true
		rond_etat.texture = rond_exclamation
		retour_position_initiale = false

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "coup_de_pied":
		rond_etat.texture = null
		# TODO: il faudra envoyer un signal au joueur pour dire qu'il est capturé
