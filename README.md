The aim is to exand on last weeks project of a Sudoku solver, and get a fully functioning
web version. I'll be using HTML, CSS etc for the first time. 

Sinatra is used to launch the application on the web. 
This was the first project where gems were used,
gem 'sinatra'
gem 'shotgun'
gem 'sinatra-partial'
gem 'rack-flash3'

group :production do
  gem 'newrelic_rpm'
end

`````
run from the terminal using 'shotgun' command, and view in localhost 9393. 
`````

This was also launched on Heroku in staging environment, and can be found here:
http://staging-colinsudoku.herokuapp.com/
