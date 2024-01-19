extends Node

# Enumération des pouvois
enum Noms {
	RIEN,
	DOUBLE_SAUT,
	INVISIBLE,
	BOULE_DE_FEU,
	ALCOOL,
	AUTO_SOIN,
	LONGUE_VUE,
	LANCE_ROQUETTE,
	ARMURE,
	HACHE,
	PIEGES
}

# Timers des différents pouvoirs
var timer_invisible: Timer
var timer_boule_de_feu: Timer

# Variables
const scene_boule_de_feu = preload("res://scenes/Pouvoir/BouleDeFeu.tscn")

func mise_a_jour_disponibilite_pouvoir(joueur):
	match joueur.get_pouvoir():
		Noms.RIEN:
			return false
		Noms.DOUBLE_SAUT:
			joueur.GRAVITE = (9.81 / 2 if !joueur.pouvoir_disponible else 9.81)
			return joueur.pouvoir_disponible || joueur.is_on_floor()
		Noms.INVISIBLE:
			return timer_invisible == null || timer_invisible.time_left == 0
		Noms.BOULE_DE_FEU:
			return timer_boule_de_feu == null || timer_boule_de_feu.time_left == 0

# Active le pouvoir du joueur
func activer_pouvoir(joueur):
	match joueur.get_pouvoir():
		Noms.RIEN:
			print("aucun pouvoir")
		Noms.DOUBLE_SAUT:
			double_saut(joueur)
		Noms.INVISIBLE:
			invisible(joueur)
		Noms.BOULE_DE_FEU:
			boule_de_feu(joueur)

# Pouvoir : Double saut + planer
func double_saut(joueur):
	if !joueur.is_on_floor():
		# Pouvoir
		joueur.velocity.y = joueur.VELOCITE_SAUT
		# Mise à jour de l'état du pouvoir
		joueur.pouvoir_disponible = false

# Pouvoir : Invisibilité pendant 5s
func invisible(joueur):
	if timer_invisible == null || timer_invisible.time_left == 0:
		# Pouvoir
		joueur.set_collision_layer_value(1, false)
		for layer in range(11, 21): # De 11 à 20
			joueur.alpha_joints.set_layer_mask_value(layer, false)
			joueur.alpha_surface.set_layer_mask_value(layer, false)
		joueur.alpha_joints.set_layer_mask_value(joueur.layer_principal_camera, true)
		joueur.alpha_surface.set_layer_mask_value(joueur.layer_principal_camera, true)
		joueur.alpha_joints.transparency = 1
		joueur.alpha_surface.transparency = 0.5
		
		# Mise à jour de l'état du pouvoir
		joueur.pouvoir_disponible = false
		timer_invisible = Timer.new()
		add_child(timer_invisible)
		timer_invisible.one_shot = true
		timer_invisible.autostart = false
		timer_invisible.wait_time = 5.0
		timer_invisible.timeout.connect(func(): fin_invisibilite(joueur))
		timer_invisible.start()

func fin_invisibilite(joueur):
	joueur.set_collision_layer_value(1, true)
	for layer in range(11, 21): # De 11 à 20
		joueur.alpha_joints.set_layer_mask_value(layer, true)
		joueur.alpha_surface.set_layer_mask_value(layer, true)
	joueur.alpha_joints.transparency = 0
	joueur.alpha_surface.transparency = 0
	timer_invisible.queue_free()

func boule_de_feu(joueur):
	if (timer_boule_de_feu == null || timer_boule_de_feu.time_left == 0) && joueur.get_node_or_null("Visuel/Personnage/Armature/GeneralSkeleton/AttacheMainDroite/ObjetMainDroite/BouleDeFeu") == null:
		# Pouvoir
		var boule = scene_boule_de_feu.instantiate()
		joueur.changer_arme(boule)
		boule.position = Vector3(-0.001, 0.073, -0.009)
		joueur.get_node("Visuel/Personnage/Armature/GeneralSkeleton/AttacheMainDroite/ObjetMainDroite").add_child(boule)
		
		# Mise à jour de l'état du pouvoir
		joueur.pouvoir_disponible = false
		timer_boule_de_feu = Timer.new()
		add_child(timer_boule_de_feu)
		timer_boule_de_feu.one_shot = true
		timer_boule_de_feu.autostart = false
		timer_boule_de_feu.wait_time = 5.0
		timer_boule_de_feu.timeout.connect(func(): fin_boule_de_feu(joueur))
		timer_boule_de_feu.start()

func fin_boule_de_feu(joueur):
	joueur.changer_arme(null)
	if joueur.get_node_or_null("Visuel/Personnage/Armature/GeneralSkeleton/AttacheMainDroite/ObjetMainDroite/BouleDeFeu") != null:
		joueur.get_node("Visuel/Personnage/Armature/GeneralSkeleton/AttacheMainDroite/ObjetMainDroite/BouleDeFeu").queue_free() # tmp ?
	timer_boule_de_feu.queue_free()
