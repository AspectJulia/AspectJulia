export printepath

function printepath(st; workingdir::String=pwd())
  paths = listepath(st; workingdir=workingdir)
  map(p -> println(p), paths)
  nothing
end
