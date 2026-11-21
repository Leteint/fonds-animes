# Fonds animés

Un sélecteur graphique pour utiliser sous **Linux (X11)** les fonds d'écran animés de **Wallpaper Engine** téléchargés depuis le Workshop Steam. Il fonctionne avec Linux Mint / Cinnamon, Xfce, MATE…

> *English summary: a small GTK picker for Wallpaper Engine Workshop wallpapers on Linux/X11, built on top of [linux-wallpaperengine](https://github.com/Almamu/linux-wallpaperengine). Pick a wallpaper per monitor, set FPS and volume, and switch wallpapers without a black gap thanks to a small patch.*

## Pourquoi ?

Wallpaper Engine est une application **Windows**. Sous Linux, elle se lance avec Proton et permet toujours de télécharger des fonds depuis le Workshop. Elle ne peut cependant pas les appliquer au bureau, et les panneaux « Fond d'écran » des bureaux Linux n'acceptent que des images fixes.

[linux-wallpaperengine](https://github.com/Almamu/linux-wallpaperengine) sait afficher ces fonds (vidéos et scènes) sur le bureau, mais seulement en ligne de commande. **Fonds animés** y ajoute :

- une fenêtre avec la **vignette de chaque fond** du Workshop : un clic l'applique ;
- **un fond différent par écran**, ou le même sur tous les écrans ;
- le choix du **nombre d'images par seconde** (10 à 60) ;
- le **son** : coupure et volume ;
- une **bascule sans trou** : l'ancien fond reste affiché jusqu'à ce que le nouveau soit prêt, sans écran noir entre les deux (voir [le patch](patches/x11-bascule-sans-trou.patch)) ;
- un **démarrage automatique** à l'ouverture de session, et un bouton **Arrêter** pour revenir au fond habituel.

## Prérequis

- Une session **X11**. Wayland n'est pas pris en charge par ce sélecteur.
- **Steam** avec **Wallpaper Engine** installé (application payante sur Steam) : ses fichiers `assets` sont nécessaires aux scènes, et c'est par lui que passent les abonnements au Workshop.
- Debian / Ubuntu / Linux Mint pour le script d'installation. Sur une autre distribution, installez les dépendances équivalentes.

## Installation

```bash
git clone https://github.com/Leteint/fonds-animes.git
cd fonds-animes
./install.sh
```

Le script indique la commande `sudo apt install …` à lancer s'il manque des dépendances. Il installe ensuite tout dans votre dossier personnel :

- il récupère linux-wallpaperengine (version testée), applique le patch et le compile dans `~/.local/share/fonds-animes/` ;
- il copie `fond-anime` et `fond-anime-selecteur` dans `~/.local/bin/` ;
- il ajoute l'entrée de menu **« Fonds animés »** et le démarrage automatique.

## Utilisation

1. Dans Steam, abonnez-vous à des fonds du Workshop de Wallpaper Engine. Inutile de les appliquer dans Wallpaper Engine.
2. Ouvrez **Fonds animés** depuis le menu, choisissez l'écran, puis cliquez sur un fond.
3. Cliquez sur **⟳** après de nouveaux abonnements, ou après avoir branché ou débranché un écran.

En ligne de commande :

```bash
fond-anime 3162481131        # ce fond (ID Workshop) sur tous les écrans
fond-anime 3162481131 60     # idem, à 60 images/s
fond-anime stop              # arrêter (et ne plus relancer à l'ouverture de session)
fond-anime                   # relancer la dernière configuration
```

Les réglages sont stockés dans `~/.config/fond-anime/config.json`, et le journal de linux-wallpaperengine dans `~/.config/fond-anime/log.txt`.

## Limites connues

- **Un seul processus pour tous les écrans** : changer le fond d'un écran recharge aussi les autres (en arrière-plan, sans trou visible). En X11, linux-wallpaperengine dessine tout le fond du bureau à lui seul, ce qui empêche d'avoir un processus par écran.
- Le **volume est commun** à tous les écrans. Le son part vers la sortie audio par défaut du système.
- Quelques scènes très élaborées peuvent avoir des effets manquants : c'est une limite de linux-wallpaperengine.
- Les fonds du Workshop appartiennent à leurs auteurs. Ce projet n'en contient aucun.

## Désinstallation

```bash
./uninstall.sh
```

## Licence

GPL-3.0, comme linux-wallpaperengine, dont ce projet modifie le code par un patch. Wallpaper Engine est une marque de ses auteurs respectifs. Ce projet n'y est pas affilié.
