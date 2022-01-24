// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

// get all images from javascript/images folder
// ensures that webpacker will add this path to the manifest file


require("@rails/ujs").start()
require("turbolinks").start()
require("jquery")
require("@rails/activestorage").start()
require("channels")


// Uncomment to copy all static images under ../images to the output folder and reference
// them with the image_pack_tag helper in views (e.g <%= image_pack_tag 'rails.png' %>)
// or the `imagePath` JavaScript helper below.
//
// const images = require.context('../images', true)
// const imagePath = (name) => images(name, true)

import '../stylesheets/application';
import 'jquery/dist/jquery';
import 'materialize-css/dist/js/materialize';

$(document).on('turbolinks:load', function() {
  $(".dropdown-trigger").dropdown();
  $('select').formSelect();
  $('#notices_error_messages').fadeOut(5000);
  $('.materialboxed').materialbox();
  if($('#scene').length > 0){
    const Parallax = require('parallax-js')
    var scene = $('#scene').get(0);
    var parallaxInstance = new Parallax(scene);
  };
  $(".sidenav").sidenav({
    closeOnClick: true}
  );

  // cookie banner
  if(localStorage.getItem('cookieSeen') != 'shown'){
    $(".cookie-banner").delay(2000).fadeIn();
    localStorage.setItem('cookieSeen','shown')
  }

  $('.close').click(function(e) {
    $('.cookie-banner').fadeOut();
  });
});
