Push-Location "E:\Projects\Racket";
raco planet create bf;
raco planet remove mmacauley bf.plt 1 0;
raco planet fileinject mmacauley bf.plt 1 0;
Pop-Location