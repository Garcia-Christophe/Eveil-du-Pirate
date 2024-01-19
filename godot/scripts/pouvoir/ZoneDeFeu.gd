extends Area3D

# Timer pour la durée d'existence de la zone de feu
var timer: Timer

# TODO: entered_body > if groupe "joueur" > joueur.prendre_degats(1);
# hill le joueur qui l'a lancé ? (faisable en ayant une var joueur assignée par BouleDeFeu)

# Démarre le timer pour stopper l'ambrasement 5s après être entré dans l'arbre
func _enter_tree():
	timer = Timer.new()
	add_child(timer)
	timer.one_shot = true
	timer.autostart = false
	timer.wait_time = 5.0
	timer.timeout.connect(func(): stop_embrasement())
	timer.start() 

# Stop les flammes puis supprime la zone de feu 1s après
func stop_embrasement():
	$GPUParticles3D.emitting = false
	timer.wait_time = 0.5
	timer.timeout.connect(func(): queue_free())
	timer.start() 
