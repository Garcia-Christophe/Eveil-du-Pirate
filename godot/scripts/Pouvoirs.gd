extends Node

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

var timer_invisible: Timer

func mise_a_jour_disponibilite_pouvoir(joueur):
	match joueur.get_pouvoir():
		Noms.RIEN:
			return false
		Noms.DOUBLE_SAUT:
			joueur.GRAVITE = (9.81 / 2 if !joueur.pouvoir_disponible else 9.81)
			return joueur.pouvoir_disponible || joueur.is_on_floor()
		Noms.INVISIBLE:
			return timer_invisible == null || timer_invisible.time_left == 0

# Active le pouvoir du joueur
func activer_pouvoir(joueur):
	match joueur.get_pouvoir():
		Noms.RIEN:
			print("aucun pouvoir")
		Noms.DOUBLE_SAUT:
			double_saut(joueur)
		Noms.INVISIBLE:
			invisible(joueur)

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
	timer_invisible.queue_free()
