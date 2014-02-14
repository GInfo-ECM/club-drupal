for i in {2..10}
do
    `cp htmltest/sites/assos.centrale-marseille.fr.jm2l$i/settings.php htmltest/sites/assos.centrale-marseille.fr.jm2l$i/settings_temp.php`
    `head -n 184 htmltest/sites/assos.centrale-marseille.fr.jm2l$i/settings_temp.php > htmltest/sites/assos.centrale-marseille.fr.jm2l$i/settings.php`
    `echo "'database' => 'jm2l$i'," >> htmltest/sites/assos.centrale-marseille.fr.jm2l$i/settings.php`
    `tail -n 273 htmltest/sites/assos.centrale-marseille.fr.jm2l$i/settings_temp.php >> htmltest/sites/assos.centrale-marseille.fr.jm2l$i/settings.php`
    `rm htmltest/sites/assos.centrale-marseille.fr.jm2l$i/settings_temp.php`
    `chmod 400 htmltest/sites/assos.centrale-marseille.fr.jm2l$i/settings.php`
done
