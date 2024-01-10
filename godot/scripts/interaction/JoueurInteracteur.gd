extends Interacteur

var joueur: CharacterBody3D
var elem_interactif_enregistre: Interactif

func _physics_process(_delta):
	if not is_multiplayer_authority(): return
	
	var nouveau_elem_interactif: Interactif = get_interactif_proche()
	if elem_interactif_enregistre != nouveau_elem_interactif:
		if is_instance_valid(elem_interactif_enregistre):
			non_cibler(elem_interactif_enregistre)
		if is_instance_valid(nouveau_elem_interactif):
			cibler(nouveau_elem_interactif)
		
		elem_interactif_enregistre = nouveau_elem_interactif

func _input(event):
	if not is_multiplayer_authority(): return
	
	if event.is_action_pressed("intéragir") and is_instance_valid(elem_interactif_enregistre):
		interagir(elem_interactif_enregistre)
		elem_interactif_enregistre = null

func _on_area_exited(area):
	if not is_multiplayer_authority(): return
	
	if elem_interactif_enregistre == area:
		non_cibler(area)
