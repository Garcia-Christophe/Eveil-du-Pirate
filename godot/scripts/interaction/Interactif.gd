extends Area3D

class_name Interactif

# Emis quand l'intéracteur me regarde
signal cible(interacteur: Interacteur)
# Emis quand l'intéracteur ne me regarde plus
signal non_cible(interacteur: Interacteur)
# Emis quand l'intéracteur intéragit avec moi
signal en_interaction(interacteur: Interacteur)
