#!/bin/sh

. /users/guest/assos/bin/scripts-config.sh

d7-all-drush.sh -y en l10n_update
d7-all-drush.sh l10n-update-refresh
d7-all-drush.sh l10n-update
d7-all-drush.sh -y dis l10n_update
