extends Node3D

@onready var couvercle = $Couvercle
@onready var couvercleContours = $Couvercle/CSGCombiner3D
@onready var coffreContours = $CoffreMeshContours
@onready var lueur = $Lueur
@onready var animations = $Couvercle/Animation
@onready var sons = $AudioStreamPlayer3D

var ouvert = false
var contoursMateriau

# Par défaut enlève le contours
func _ready():
	contoursMateriau = couvercleContours.material_override.next_pass
	
#	couvercleContours.material_override.next_pass = null
#	coffreMeshContours.material_override.next_pass = null

# Ouvre le trésor
func ouvrir():
	ouvert = true
	# Le trésor n'est plus intéractif
	$Interactif.queue_free()
	couvercleContours.material_override.next_pass = null
#	coffreMeshContours.material_override.next_pass = null
	# Animation
	animations.play("ouverture")
	sons.play()

# Lorsque le trésor est ciblé, affiche un contours
func _on_interactif_cible(_interacteur):
	couvercleContours.material_override.next_pass = contoursMateriau
#	couvercleContoursInstance.get_surface_override_material(0).next_pass = highlight_material
#	coffreMeshContours.material_override.next_pass = contours

# Lorsque le trésor n'est plus ciblé, enlève le contours
func _on_interactif_non_cible(_interacteur):
	couvercleContours.material_override.next_pass = null
#	coffreMeshContours.material_override.next_pass = null

# Lorsque le trésor est en intéraction, ouvre le coffre
func _on_interactif_en_interaction(_interacteur):
	if !ouvert:
		ouvrir()
