extends Area3D

class_name Interacteur

func interagir(interactif: Interactif) -> void:
	interactif.en_interaction.emit(self)

func cibler(interactif: Interactif) -> void:
	interactif.cible.emit(self)

func non_cibler(interactif: Interactif) -> void:
	interactif.non_cible.emit(self)

# Retourne l'aire intéractive la plus proche, null s'il n'y en a pas
func get_interactif_proche() -> Interactif:
	var liste_areas: Array[Area3D] = get_overlapping_areas()
	var distance: float
	var min_distance: float = INF
	var interactif_proche: Interactif = null
	
	for interactif in liste_areas:
		distance = interactif.global_position.distance_to(global_position)
		
		if distance < min_distance:
			interactif_proche = interactif as Interactif
			min_distance = distance
		
	return interactif_proche

