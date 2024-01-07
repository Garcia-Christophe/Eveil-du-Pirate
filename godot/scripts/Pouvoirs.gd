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

func mise_a_jour_disponibilite_pouvoir(joueur):
	match joueur.get_pouvoir():
		Noms.RIEN:
			return false
		Noms.DOUBLE_SAUT:
			joueur.GRAVITE = (9.81 / 2 if !joueur.pouvoir_disponible else 9.81)
			return joueur.pouvoir_disponible || joueur.is_on_floor()

# Active le pouvoir du joueur
func activer_pouvoir(joueur):
	match joueur.get_pouvoir():
		Noms.RIEN:
			print("aucun pouvoir")
		Noms.DOUBLE_SAUT:
			double_saut(joueur)

# Pouvoir : Double saut + planer
func double_saut(joueur):
	if !joueur.is_on_floor():
		# Pouvoir
		joueur.velocity.y = joueur.VELOCITE_SAUT
		# Animation
		joueur.animations.stop()
		joueur.animations.play("sauter")
		# Mise à jour de l'état du pouvoir
		joueur.pouvoir_disponible = false
		joueur.pouvoir_active = true
