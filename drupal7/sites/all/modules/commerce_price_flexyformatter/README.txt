
--------------------------------------------------------------------------------
Commerce Price Flexyformatter
--------------------------------------------------------------------------------

Maintainer:  xlyz, xlyz@tiscali.it

Provides a flexible formatter for easy prices display finetuning.

Poject homepage: http://drupal.org/project/commerce_price_flexyformatter

Issues: http://drupal.org/project/issues/commerce_price_flexyformatter

Installation
------------

 * This module depends on Drupal Commerce http://drupal.org/project/commerce

 * Copy the whole delivery_commerce directory to your modules directory
   (e.g. DRUPAL_ROOT/sites/all/modules) and activate it in the modules page

 * Got to the "manage display" page of your entity and select "Formatted amount
   with selected components" as formatter and configure it

Documentation
-------------

This modules formats the price displayed according to the configuration options:

* which components should be added to the amount displayed
* label: if and which label shall be prepended to the amount
* custom class: if and which css class shall be added to the price element
  for custom styling
* tax calculation method: if taxes shall be added as calculated by commerce or
  calculated again on a different base (and on which components)
* weight: in which order (lower number goes first)

Up to two additional reference prices can be displayed.
