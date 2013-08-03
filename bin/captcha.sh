#!/bin/sh
PATH=/usr/local/bin:/usr/bin:/bin
##############
# Sets hidden captcha configuration for all D7 websites.
##############

init_scripts.sh

cd $d7_sites_dir

for dir in $(ls)
do
  if [ -d $dir -a ! -L $dir ]
  then
      cd $dir;
      echo "Configuration hidden captcha pour $x"
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
