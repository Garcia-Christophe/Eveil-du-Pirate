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

var joueur

# Active le pouvoir du joueur
func activer_pouvoir(j):
	if j != null:
		joueur = j
		match joueur.get_pouvoir():
			Noms.RIEN:
				print("aucun pouvoir")
			Noms.DOUBLE_SAUT:
				double_saut()

# Pouvoir : Double saut + planer
func double_saut():
	if !joueur.is_on_floor():
		joueur.velocity.y = joueur.VELOCITE_SAUT
		joueur.animations.stop()
		joueur.animations.play("sauter")
		lance_timer_pouvoir()

# Lance le décompte avant que le joueur puisse réutiliser son pouvoir
func lance_timer_pouvoir():
	joueur.pouvoir_disponible = false
	joueur.timer_pouvoir.start()
