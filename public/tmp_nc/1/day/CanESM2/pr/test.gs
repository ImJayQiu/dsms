reinit
open gcmread.ctl
set t 200
set grads off
set gxout shaded
set mpdset hires
set clevs 0 0.5 1 1.5 2 2.5 3 3.5 4 4.5 5 5.5 6 6.5 7 7.5 8 8.5 9 9.5 
*set ccols 0 14 20 25 30 40 50 60
d ave(pr*86400,t=1,t=360)
*d pr*86400
cbar 
draw title RIMES
printim aaa.png png white
quit
