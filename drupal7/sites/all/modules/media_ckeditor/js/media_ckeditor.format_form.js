/**
 * @file
 * Overrides of some functions in media and media_wysiwyg javascript.
 */

(function ($) {

// Sanity check, because javascript errors are bad.
if (typeof Drupal.media === 'undefined' ||
    typeof Drupal.media.formatForm === 'undefined') {
  return;
}

/**
 * This overrides, and is mostly a copy of, a function from the following file:
 * media/modules/media_wysiwyg/js/media_wysiwyg.format_form.js
 */
Drupal.media.formatForm.getOptions = function () {
  // Get all the values
  var ret = {};

  $.each($('#media-wysiwyg-format-form .fieldset-wrapper *').serializeArray(), function (i, field) {
    // For all fields, since they WILL be in JSON, encode them.
    ret[field.name] = encodeURIComponent(field.value);

    // When a field uses a WYSIWYG format, the value needs to be extracted.
    if (field.name.match(/\[format\]/i)) {
      field.name = field.name.replace(/\[format\]/i, '[value]');
      field.key  = 'edit-' + field.name.replace(/[_\[]/g, '-').replace(/[\]]/g, '');

      if (typeof CKEDITOR !== 'undefined') {
        if (CKEDITOR.instances[field.key]) {
          ret[field.name] = CKEDITOR.instances[field.key].getData();
          ret[field.name] = encodeURIComponent(ret[field.name]);
        }
      }
    }
  });

  return ret;
};

})(jQuery);
