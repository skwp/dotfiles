command! -nargs=0 Rroutes :Rfind routes.rb
command! -nargs=0 RSroutes :RSfind routes.rb

command! -nargs=0 Rschema :Rfind db/schema.rb
command! -nargs=0 RSschema :RSfind db/schema.rb

command! -nargs=0 Rconfig :Rfind application.yml
command! -nargs=0 RSconfig :RSfind application.yml

Rnavcommand sass public/stylesheets/sass -suffix=.sass
