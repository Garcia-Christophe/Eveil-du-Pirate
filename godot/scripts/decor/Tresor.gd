extends Node3D

@onready var couvercleContours = $Couvercle/CSGCombiner3D
@onready var coffreContours = $CoffreMeshContours
@onready var animations = $Couvercle/Animation
@onready var sons = $AudioStreamPlayer3D

var ouvert = false
var contoursMateriauShader

# Par défaut enlève le contours
func _ready():
	contoursMateriauShader = load("res://shaders/Interactif.gdshader")
	retire_surbrillance()

# Ouvre le trésor
func ouvrir():
	ouvert = true
	# Le trésor n'est plus intéractif
	$Interactif.queue_free()
	retire_surbrillance()
	# Animation
	animations.play("ouverture")
	sons.play()

# Lorsque le trésor est ciblé, affiche un contours
func _on_interactif_cible(_interacteur):
	ajoute_surbrillance()

# Lorsque le trésor n'est plus ciblé, enlève le contours
func _on_interactif_non_cible(_interacteur):
	retire_surbrillance()

# Lorsque le trésor est en intéraction, ouvre le coffre
func _on_interactif_en_interaction(_interacteur):
	if !ouvert:
		ouvrir()

# Ajoute la surbrillance autours du coffre
func ajoute_surbrillance():
	couvercleContours.material_override.next_pass.shader = contoursMateriauShader
	coffreContours.material_override.next_pass.shader = contoursMateriauShader

# Retire la surbrillance autours du coffre
func retire_surbrillance():
	couvercleContours.material_override.next_pass.shader = null
	coffreContours.material_override.next_pass.shader = null
