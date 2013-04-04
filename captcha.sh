#!/bin/bash
#!/bin/sh
PATH=/usr/local/bin:/usr/bin:/bin
##############
# Sets hidden captcha configuration for all D7 websites. 
##############
cd /users/guest/assos/htmltest/sites
for x in $(ls -1 | grep -v 'all' | grep -v file-*); do
  if [ -d $x -a ! -L $x ]; then
    cd $x;
      echo "Configuration hidden captcha pour "$x
      # Enable hidden_captcha module.
      drush -y en hidden_captcha
      # Log wrong answers.
      drush -y vset captcha_log_wrong_responses 1
      # Use hidden captcha for all forms.
      drush -y sqlq --db-prefix "UPDATE {captcha_points} SET module = 'hidden_captcha', captcha_type = 'Hidden CAPTCHA' WHERE module is NULL;"
      # Flush captcha cache.
      drush -y vdel captcha_placement_map_cache
      # Randomely generate a math question as the label of the hidden captcha field.
      drush -y vset hidden_captcha_label "$RANDOM + $RANDOM"
    cd -;
  fi
done
