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
  M.textareaAutoResize($('#form-text-area'));
  $('.materialboxed').materialbox();
  $('.sidenav').sidenav();

  let kilaText = document.getElementById('kila-text');
  let layer3 = document.getElementById('layer3');
  let layer4 = document.getElementById('layer4');
  let layer5 = document.getElementById('layer5');
  let layer6 = document.getElementById('layer6');
  let layer7 = document.getElementById('layer7');
  let welcomeText = document.getElementById('welcome-text');
  let rocket = document.getElementById('rocket');
  let layer8 = document.getElementById('layer8');
  let layer9 = document.getElementById('layer9');
  let layer10 = document.getElementById('layer10');
  let layer11 = document.getElementById('layer11');
  let layer12 = document.getElementById('layer12');
  let layer13 = document.getElementById('layer13');
  let layer14 = document.getElementById('layer14');
  let stars = document.getElementById('stars');

  window.addEventListener('scroll', function(){
    let value = window.scrollY;
    welcomeText.style.marginRight = value + 'px';
    layer3.style.top = value * 0.5 + 'px';
    layer4.style.left = value * 0.7 + 'px';
    layer5.style.top = value * 1 + 'px';
    layer6.style.top = value * 0.2 + 'px';
    layer7.style.top = value * 0.3 + 'px';
    layer8.style.left = value * 0.2 + 'px';
    rocket.style.left = value * 1 + 'px';
    layer9.style.top = value * 0.7 + 'px';
    layer10.style.top = value * 0.3 + 'px';
    layer11.style.left = value * 0.6 + 'px';
    layer12.style.right = value * 0.2 + 'px';
    layer13.style.right = value * 0.2 + 'px';
    layer14.style.right = value * 0.2 + 'px';
    stars.style.left = value * 0.2 + 'px';
    kilaText.style.marginLeft = value + 'px';
  })
})
