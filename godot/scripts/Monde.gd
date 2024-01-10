extends Node3D

# Références aux noeuds de l'arbre
@onready var menu_principal = $CanvasLayer/MenuPrincipal
@onready var input_adresse = $CanvasLayer/MenuPrincipal/MarginContainer/VBoxContainer/VBoxMultijoueur/VBoxRejoindre/InputAdresse
@onready var ile_principale = $IlePrincipale
@onready var ile_secondaire = $IleSecondaire

# Constantes
const JOUEUR = preload("res://scenes/Joueur.tscn")
const PORT = 9999
const MAX_CLIENTS = 10
var enet_peer = ENetMultiplayerPeer.new()

# Variables
var adresses_ip

# Bouton "Jouer" (en campagne) du menu principal
func _on_jouer_btn_pressed():
	menu_principal.hide()
	
	# Création du joueur, et positionnement sur l'île principale
	var joueur = JOUEUR.instantiate()
	joueur.name = "1"
	get_node("IlePrincipale").add_child(joueur)

# Bouton "Créer une partie" (multijoueur) du menu principal
func _on_heberger_btn_pressed():
	menu_principal.hide()
	
	# Suppression de l'île principale et des gardes de la Marine
	ile_principale.queue_free()
	for garde in get_tree().get_nodes_in_group("GardeMarineAndCo"):
		garde.queue_free()
	
	# Création du serveur
	enet_peer.create_server(PORT, MAX_CLIENTS)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(ajouter_joueur)
	multiplayer.peer_disconnected.connect(supprimer_joueur)
	
	# Setup du multijoueurs
	adresses_ip = ""
	if !upnp_setup():
		adresses_ip = "Multijoueurs KO :(\n" + adresses_ip + "\n"
	else:
		adresses_ip = "Multijoueurs OK :)\n" + adresses_ip + "\n"
	print(adresses_ip)
	
	# Ajoute le 1er joueur (car le serveur est créé par le pc d'un joueur)
	ajouter_joueur(multiplayer.get_unique_id())

# Bouton "Rejoindre la partie" (multijoueur) du menu principal
func _on_rejoindre_btn_pressed():
	menu_principal.hide()
	
	# Suppression de l'île principale et des gardes de la Marine
	ile_principale.queue_free()
	for garde in get_tree().get_nodes_in_group("GardeMarineAndCo"):
		garde.queue_free()
	
	# Création du client
	if input_adresse.text == "":
		input_adresse.text = "localhost"
	enet_peer.create_client(input_adresse.text, PORT)
	multiplayer.multiplayer_peer = enet_peer

func ajouter_joueur(peer_id):
	# Création du joueur, et positionnement sur l'île secondaire
	var joueur = JOUEUR.instantiate()
	joueur.name = str(peer_id)
	get_node("IleSecondaire").add_child(joueur)

func supprimer_joueur(peer_id):
	var joueur = get_node_or_null(str(peer_id))
	if joueur:
		joueur.queue_free()

# Mise en place du multijoueur
func upnp_setup():
	var upnp = UPNP.new()
	
	# Vérifie que UPNP existe (si c'est activé)
	var resultat_discover = upnp.discover()
	if resultat_discover != UPNP.UPNP_RESULT_SUCCESS:
		print("Multijoueur Erreur : 'UPNP Discover' > %s" % resultat_discover)
		return false
	
	# Vérifie si UPNP peut être utilisé correctement
	if !(upnp.get_gateway() and upnp.get_gateway().is_valid_gateway()):
		print("Multijoueur Erreur : 'UPNP Gateway' > gateway invalide")
		return false
	
	# Fait le lien avec le port du jeu
	var resultat_mapping = upnp.add_port_mapping(PORT)
	if resultat_mapping != UPNP.UPNP_RESULT_SUCCESS:
		print("Multijoueur Erreur : 'UPNP Port Mapping' > %s" % resultat_mapping)
		return false
	
	# Succès :)
	adresses_ip = "Adresse en ligne :\n   - %s" % upnp.query_external_address()
	return true
