reinit
open .ctl
set grads off
set gxout shaded
set font 1
set strsiz 0.12
draw string 1.8 0.1 by CDAAS @ RIMES.INT 2016
set clevs 1 2 4 6 8 10 20 50 100 200 300
set ccols 0 13 3 10 7 12 8 2 6 14 4
set mpdset hires
set mpdraw off
d ave(pr*86400.0+0.0,t=1,t=30)
draw shp thailanduse/gis.osm_landuse_a_free_1.shp
cbar.gs
printim _shape.png png white
quit
