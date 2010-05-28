//remove categories
//pinyin extended chars buttons
function initFadeLinks() {
  $('a[data-show]').click(function(e){
    if ($(this).attr('data-hide'))
      $('#' + $(this).attr('data-hide')).fadeOut('fast');
    else
      $(this).fadeOut('fast');

    $('#' + $(this).attr('data-show')).fadeIn('fast');
    e.preventDefault();
  });
}

function initFormSubmits(){
  $('#add').live('submit', function(e){
    $('#categoryLoad div.active').each(function(){                       //should use id here
      $('#add').append('<input type="hidden" name="categories[]" value="' + $(this).text() + '"/>');
    });
    e.preventDefault();
  });
  $('form').live('submit', function(e){
    var form = this;
    loadMask(form);
    $.post(
      $(this).attr('action'),
      $(this).serializeArray(),
      function(data){
        loadMask(form);
        if ($(form).attr('data-load'))
          $('#' + $(form).attr('data-load')).html(data);
        $(form).children('input[type=text]').val('').first().focus();
      }
    );
    e.preventDefault();
  })
}

function initCategories() {
  $('#addCategory').live('click', function(e){
    var input = $('<input type="text" name="name"/>').insertBefore(this);
    input.blur(function(){
      input.parent().submit();
    });
    e.preventDefault();
  });
  $('.category').live('click', function(e){
    $(this).toggleClass('active');
  });
}

var ajaxData = null;
function initKnow() {
  $('#know').click(function(e){
    $.get('/correct/' + $('#card').attr('data-id'),
      serializeCategories(),
      function(data){ ajaxData = data; });
    $('#characters').hide();
    $('#pinyin, #english').css('position', 'relative').show();
    $('#answers').show().fadeOut(300, loadCallback);
    e.preventDefault();
  });
}

function initDontKnow() {
  $('#dontKnow').click(function(e){
    if ($('#characters').is(':visible')) {
      $('#characters').fadeOut('fast');
      $('#answers').show();
      $('#pinyin').fadeIn('fast');
    } else if ($('#pinyin').is(':visible')) {
      $('#pinyin').fadeOut('fast');
      $('#english').fadeIn('fast');
    } else {
      $.get('/',
        serializeCategories(),
        function(data){ ajaxData = data; loadCallback(); });
      $('#english').hide();
    }
    e.preventDefault();
  });
}

//have to make sure the ajax request has returned before showing the next card
function loadCallback() {
  if (ajaxData){
    if (typeof ajaxData == 'string') {
      $('#body').html(ajaxData);
    } else {
      $('#characters').text(ajaxData.characters).show();
      $('#pinyin').text(ajaxData.pinyin).css('position', 'absolute').hide();
      $('#english').text(ajaxData.english).css('position', 'absolute').hide();
      ajaxData = null;
    }
  } else {
    alert('data not loaded yet!');
  }
}

function loadMask(elem) {
  if ($(elem).find('.loadMask').size() > 0)
    $(elem).find('.loadMask').remove();
  else
    $(elem).append('<div class="loadMask"></div>');
}

function serializeCategories(){
  var serialized = [];
  $('#categoryLoad .active').each(function(){
    serialized.push($(this).text());
  });
  return $.param({categories : serialized});
}

