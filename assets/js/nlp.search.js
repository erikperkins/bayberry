$(document).on('turbolinks:load', function() {
  if (window.location.pathname == '/nlp/index') {
    $.ajax({
      type: 'POST',
      url: 'lda',
      beforeSend: function() {
        $('#search-button-icon').attr('class', 'fa fa-cog fa-spin');
      },
      complete: function(json, status) {
        $('#search-button-icon').attr('class', 'fa fa-search');
      },
      success: function(json, status) { renderTerms(json); }
    });

    $('#search-form').on('ajax:success', function(event, json) {
      renderTerms(json);
    });
  }
});

function renderTerms(json) {
  $('#search-term').fadeOut(120, function() {
    $(this).text(json['slug']).fadeIn();
  });

  $('#terms').fadeOut(120, function() {
    $(this).text(json['datum'].join(", ")).fadeIn();
  })
}
