# Lancer une VM Windows avec Vagrant

Vagrant est un système de gestion de machines virtuelles qui permet de créer une VM, et de vous y connecter, en quelques lignes de commandes. Par exemple pour la dernière version d'Ubuntu :

```bash
vagrant init ubuntu/trusty64
vagrant up
vagrant ssh
```

D'autres VM avec plusieurs versions de Windows et d'IE ont été mises à disposition par Microsoft pour les développeurs Web, et on peut théoriquement les utiliser aussi facilement :

```bash
vagrant box add win7-ie11 http://aka.ms/vagrant-win7-ie11
vagrant init win7-ie11
vagrant up
vagrant rdp
```

En pratique c'est plus compliqué :

- Ces VM n'ont pas d'installation de ssh, et aucun accès à distance n'est configuré par défaut

- Le premier symptôme est un timeout, au moment où Vagrant essaie de se connecter à la VM, quand il vérifie qu'elle est bien démarrée

- Impossible de manipuler notre VM avec Vagrant, pour éteindre la VM ou pour la redémarrer

Nous allons voir comment personnaliser une box pour corriger ces problèmes, et comment la redistribuer à votre équipe dans une version qu'ils pourront installer en deux lignes de commande.

## Pré-requis

- Vagrant 1.7
- Un gestionnaire de téléchargement, par exemple la commande `wget`
- Quelques heures de patience pour télécharger les VM

## Personnalisation

Téléchargez la box Vagrant :

```bash
wget -c http://aka.ms/vagrant-win7-ie11
```

La commande `wget -c` peut être relancée pour reprendre le téléchargement en cas d'interruption. C'est très long.

Créez votre fichier Vagrantfile :

```ruby
Vagrant.configure(2) do |config|
    config.winrm.username = "IEUser"
    config.winrm.password = "Passw0rd!"
    config.vm.guest = :windows
    # Configuration de winrm qui rend la VM scriptable depuis
    # l'extérieur.
    config.vm.communicator = "winrm"
    # Ouverture du port réseau de winrm
    config.vm.network :forwarded_port, guest: 5985, host: 59851,
        id: "winrm", auto_correct:true
    # Ouverture du port du remote desktop protocol
    config.vm.network :forwarded_port, guest: 3389, host: 33891,
        id: "rdp", auto_correct:true
    # Chemin de la box qui sera importée au premier démarrage
    config.vm.box_url = "file://vagrant-win7-ie11"
    # Timeout rapide au premier démarrage
    config.vm.boot_timeout = 30
    # Nom de la box
    config.vm.box = "win7-ie11"

    # Configuration spécifique à la techno de virtualisation
    # utilisée
    config.vm.provider "virtualbox" do |vb|
        # Afficher l'interface graphique Windows
        vb.gui = true
        # Mémoire vive
        vb.memory = "1024"
    end
end
```

Premier lancement :

```bash
vagrant up
```

La VM n'est pas encore configurée pour autoriser l'accès par rdp, ce qui cause un timeout (quelle que soit la durée configurée). Pourtant elle est démarrée et utilisable, puisque nous voyons l'interface graphique de Windows.

La VM n'est pas non plus manipulable avec les commandes Vagrant : `vagrant halt`, `vagrant reload`, etc.

Pour régler ça, dans la VM ouvrez le répertoire `\\VBOXSVR\vagrant`, copiez `setup-winrm.bat` sur le bureau, et lancez le script en tant qu'administrateur. Eteignez la VM depuis le système invité (pour l'instant `vagrant reload` est encore impossible).

TODO expliquer le script bat.

Passez `vb.gui` à `false`, pour laisser tourner la VM en _headless_, et le timeout à 5 minutes, pour lui laisser le temps de démarrer (sur mon poste, elle prend 2-3 minutes) :

```ruby
[...]
# Timeout suffisant pour le démarrage de Windows
config.vm.boot_timeout = 300

# Configuration spécifique à la techno de
# virtualisation utilisée
config.vm.provider "virtualbox" do |vb|
    # Afficher l'interface graphique Windows
    vb.gui = false
[...]
```

Refaites un `vagrant up` pour tester le démarrage de la VM. Il ne doit pas y avoir de timeout :

```
TODO
```

```
vagrant rdp
```

## Distribution

Déployez votre Vagrantfile sur une repository accessible à votre équipe, par exemple Git :

```bash
git init
git remote add http://github.com/geekarist/vagrant-ie.git
git commit -a -m 'Initial version: custom IE VM'
git push
```

## Utilisation

Clonez la repository où est déployé votre Vagrantfile : `git clone http://github.com/geekarist/vagrant-ie.git`

Allez dans le nouveau répertoire, et faites un `vagrant up` pour lancer la VM. Cette fois-ci, il ne doit pas y avoir de timeout.

La VM peut maintenant être manipulée avec Vagrant : `vagrant halt`, `vagrant reload`, etc.

Vous pouvez vous y connecter avec un `vagrant rdp`, ou à distance avec le client _remote desktop_ de Microsoft.
