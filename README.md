# README

Here I am building the new website for our Kinderladen Kila Hildegarten.

The website is currently reachable through https://kila-hildegarten.herokuapp.com/

The main website is: https://kila-hildegarten.de

Note:
Using cloudflare to securely connect with the domain provider required to redirect from http to https. This does not work correctly with devise since the request header is not changed from http to https. Following this https://github.com/rails/rails/issues/22965 guidelines. I followed the recomendation by TonyTonyJan, thanks.

Turbolinks are disabled for the links in the materialized sidenav bar. If they are enabled, the links will not work after first time triggering.


- for security policies I use the SecureHeaders gem. Policies are controled through config/secure_headers.rb