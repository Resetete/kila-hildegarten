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
  const Parallax = require('parallax-js')
  var scene = document.getElementById('scene');
  var parallaxInstance = new Parallax(scene, {
    relativeInput: true,
    clipRelativeInput: true
  });


  $(".dropdown-trigger").dropdown();
  $('select').formSelect();
  $('#notices_error_messages').fadeOut(5000);
  M.textareaAutoResize($('#form-text-area'));
  $('.materialboxed').materialbox();
  $('.sidenav').sidenav();

  let butterflyRedRight = document.getElementById('butterfly-red-right');
  let catWalkToLeft = document.getElementById('cat-walk-to-left');
  let hand1 = document.getElementById('hand1');
  let hand2 = document.getElementById('hand2');
  let hand3 = document.getElementById('hand3');
  let hand4 = document.getElementById('hand4');

  window.addEventListener('scroll', function(){
    let value = window.scrollY;
    butterflyRedRight.style.transform = 'translate(' + value*0.4 + 'px,' + -value*0.1 + 'px)';
    catWalkToLeft.style.left = value * -0.5 + 'px';
    hand1.style.transform = 'translateY(20vh)';
    hand2.style.transform = 'translateY(20vh)';
    hand3.style.transform = 'translateY(20vh)';
    hand4.style.transform = 'translateY(20vh)';
    hand1.style.top = value * -0.17 + 'px';
    hand2.style.top = value * -0.2 + 'px';
    hand3.style.top = value * -0.2 + 'px';
    hand4.style.top = value * -0.15 + 'px';
  })
})
