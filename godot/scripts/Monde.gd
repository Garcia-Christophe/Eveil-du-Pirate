extends Node3D

# Références aux noeuds de l'arbre
@onready var menu_principal = $CanvasLayer/MenuPrincipal
@onready var input_adresse = $CanvasLayer/MenuPrincipal/MarginContainer/VBoxContainer/VBoxMultijoueur/VBoxRejoindre/InputAdresse
@onready var ile_principale = $IlePrincipale
@onready var ile_secondaire = $IleSecondaire

# Constantes
const JOUEUR = preload("res://scenes/Joueur.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Bouton "Jouer" (en campagne) du menu principal
func _on_jouer_btn_pressed():
	print("Jouer")
	menu_principal.hide()
	# Création du joueur, et positionnement sur l'île principale
	var joueur = JOUEUR.instantiate()
	ile_principale.add_child(joueur)

# Bouton "Créer une partie" (multijoueur) du menu principal
func _on_heberger_btn_pressed():
	print("Créer une partie")
	menu_principal.hide()
	# Création du joueur, et positionnement sur l'île secondaire
	var joueur = JOUEUR.instantiate()
	ile_secondaire.add_child(joueur)
