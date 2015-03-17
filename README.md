# Lancer une VM Windows avec Vagrant

Vagrant est un système de gestion de machines virtuelles qui permet de créer une VM, et de vous y connecter, en quelques lignes de commandes. Par exemple pour la dernière version d'Ubuntu :

    vagrant init ubuntu/trusty64
    vagrant up
    vagrant ssh

D'autres VM avec plusieurs versions de Windows et d'IE ont été mises à disposition par Microsoft pour les développeurs Web, et on peut théoriquement les utiliser aussi facilement :

    vagrant box add win7-ie11 http://aka.ms/vagrant-win7-ie11
    vagrant init win7-ie11
    vagrant up
    vagrant rdp

En pratique c'est plus compliqué : TODO reformuler

- Ces VM n'ont pas d'installation de ssh, et aucun accès à distance n'est configuré par défaut

- Le premier symptôme est un timeout, au moment où Vagrant essaie de se connecter à la VM, quand il vérifie qu'elle est bien démarrée

- Impossible de manipuler notre VM avec Vagrant, pour éteindre la VM ou pour la redémarrer

Nous allons voir comment personnaliser une box pour corriger ces problèmes, et comment la redistribuer à votre équipe dans une version qu'ils pourront installer en deux lignes de commande.

## Pré-requis

- Vagrant 1.7
- VirtualBox
- Un gestionnaire de téléchargement, par exemple la commande `wget`
- Quelques heures de patience pour télécharger les VM
- Le client Microsoft Remote Desktop

## Personnalisation

Téléchargez la box Vagrant : `wget -c http://aka.ms/vagrant-win7-ie11`

La commande `wget -c` peut être relancée pour reprendre le téléchargement en cas d'interruption. C'est très long.

Créez votre fichier Vagrantfile :

    Vagrant.configure(2) do |config|
        config.winrm.username = "IEUser"
        config.winrm.password = "Passw0rd!"
        config.vm.guest = :windows
        # Configuration de WinRM qui rend la VM scriptable
        # depuis l'extérieur.
        config.vm.communicator = "winrm"
        # Ouverture du port réseau de WinRM
        config.vm.network :forwarded_port, guest: 5985,
            host: 59851, id: "winrm", auto_correct:true
        # Ouverture du port du remote desktop protocol
        config.vm.network :forwarded_port, guest: 3389,
            host: 33891, id: "rdp", auto_correct:true
        # Chemin de la box qui sera importée au premier
        # démarrage
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

Premier lancement : `vagrant up`

TODO capture d'écran

TODO message de timeout

TODO choisir 'home network'

La VM n'est pas encore configurée pour autoriser l'accès par WinRM, ce qui cause un timeout (quelle que soit la durée configurée). Pourtant elle est démarrée et utilisable, puisque nous voyons l'interface graphique de Windows.

La VM n'est pas non plus manipulable avec les commandes Vagrant : `vagrant halt`, `vagrant reload`, etc.

Pour régler ça, ouvrez un terminal en tant qu'administrateur dans la VM et lancez ces commandes :

    powershell Set-Item WSMan:\localhost\Service\AllowUnencrypted -Value True
    powershell Set-Item WSMan:\localhost\Service\Auth\Basic -Value True

TODO : explications commandes winrm. Voir http://docs.vagrantup.com/v2/vagrantfile/winrm_settings.html.

TODO vagrant reload Ok ?

Eteignez la VM depuis le système invité (pour l'instant `vagrant reload` est encore impossible).

Passez `vb.gui` à `false`, pour lancer la VM en _headless_, et le timeout à 5 minutes, pour lui laisser le temps de démarrer (sur mon poste, elle prend 2-3 minutes) :

    [...]
    # Timeout suffisant pour le démarrage de Windows
    config.vm.boot_timeout = 300

    # Configuration spécifique à la techno de
    # virtualisation utilisée
    config.vm.provider "virtualbox" do |vb|
        # Démarrage headless
        vb.gui = false
    [...]

Refaites un `vagrant up` pour tester le démarrage de la VM. Il ne doit pas y avoir de timeout :

    TODO

TODO : `vagrant rdp`

## Distribution

TODO : repackaging, mise à disposition de la box

Copiez la box repackagée sur un serveur web accessible à votre équipe :

    TODO commande copie
    TODO vérification du fichier

Déployez votre Vagrantfile sur une repository accessible à votre équipe, par exemple Git :

    git init
    git remote add http://github.com/geekarist/vagrant-ie.git
    git commit -a -m 'Initial version: custom IE VM'
    git push

## Utilisation

Clonez la repository où est déployé votre Vagrantfile : `git clone http://github.com/geekarist/vagrant-ie.git`

Allez dans le nouveau répertoire, et faites un `vagrant up` pour lancer la VM. Vagrant va télécharger la box repackagée et cette fois-ci, il ne doit pas y avoir de timeout.

Vous pouvez directement manipuler la VM avec Vagrant : `vagrant halt`, `vagrant reload`, etc.

Vous pouvez vous y connecter en local avec un `vagrant rdp`, ou à distance avec le client _remote desktop_ de Microsoft. Si vous avez un iPad sous la main, TODO : RD client sur iPad.

TODO : références (winrm, rdp, doc vagrant, virtualbox)
