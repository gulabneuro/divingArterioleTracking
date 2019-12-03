

function writetiff(mov,filename)

options.compress = 'no';
options.color = false;
options.message = false;
options.append = false; %check what this should be
options.overwrite = true;
saveastiff(mov,filename,options);


