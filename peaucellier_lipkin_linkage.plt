reset
set angle degrees
 
#=================== Parameters ====================
# Length of each link492/253
r = 3.
a = 9.
b = 4.
 
# Position of fixed joints O and P
Ox = 0
Oy = 0
Px = Ox-r
Py = Oy
 
# The maximum value of Cy(θ)
beta = acos((a-b)/2./r)
maxTheta = 2*beta         # The value of θ giving the maximum value of ￼Cy
maxCy = (a+b)*sin(beta)   # The value of Cy at θ = maxTheta
 
# Parameters in drawing
CIRC_R = 0.15     # Radius of joints
linkLW = 4        # Line width of link
locusLW = 2       # Line width of locus
numPNG = 0
isLocusDrawn = 1  # =1:true, !=1:false
LOOP = 1
 
#=================== Functions ====================
# Rotate the vector (x, y) (<- rotation matrix)
rotVec_x(x, y, t) = x*cos(t) - y*sin(t) # x component of the rotated vector
rotVec_y(x, y, t) = x*sin(t) + y*cos(t) # y component of the rotated vector
 
# Round off to the i decimal place.
round(x, i) = 1 / (10.**(i+1)) * floor(x * (10.**(i+1)) + 0.5)
 
# Joint A
Ax(t) = Ox + r*cos(t)
Ay(t) = Oy + r*sin(t)
AP(t) = sqrt((Ax(t)-Px)**2 + (Ay(t)-Py)**2)
alpha(t) = acos((b**2+AP(t)**2-a**2) / (2*b*AP(t)))
# Joint B
AB_x(t) = b/AP(t) * rotVec_x(Px-Ax(t), Py-Ay(t), alpha(t))
AB_y(t) = b/AP(t) * rotVec_y(Px-Ax(t), Py-Ay(t), alpha(t))
Bx(t) = Ax(t) + AB_x(t)
By(t) = Ay(t) + AB_y(t)
# Joint D
AD_x(t) = b/AP(t) * rotVec_x(Px-Ax(t), Py-Ay(t), -alpha(t))
AD_y(t) = b/AP(t) * rotVec_y(Px-Ax(t), Py-Ay(t), -alpha(t))
Dx(t) = Ax(t) + AD_x(t)
Dy(t) = Ay(t) + AD_y(t)
# Joint C
Cx(t) = Ax(t) + AB_x(t) + AD_x(t)
Cy(t) = Ay(t) + AB_y(t) + AD_y(t)
 
#=================== Plot ====================
# Setting
set term png truecolor enhanced size 720, 720
floderName = (isLocusDrawn==1) ? 'locusON' : 'locusOFF'
system sprintf('mkdir %s', floderName)
set size ratio -1
unset key
set grid
set xr[Px-2:Cx(0)+2]
set yr[-(int(maxCy)+2):int(maxCy)+2]
set xl 'x' font 'TimesNewRoman:Italic, 20'
set yl 'y' font 'TimesNewRoman:Italic, 20'
 
# Draw fixed joints O and P
set obj 1 circ at Ox, Oy size CIRC_R fc rgb 'black' fs solid front
set obj 2 circ at Px, Py size CIRC_R fc rgb 'black' fs solid front
set label 1 'O' left at Ox-1., Oy font 'TimesNewRoman:Italic, 20' front
set label 2 'P' left at Px-1., Py font 'TimesNewRoman:Italic, 20' front
 
# Draw unfixed joints
do for [j=1:LOOP:1] {
  do for [i=0:360:1] {
    set output sprintf("%s/img_%04d.png", floderName, numPNG)
    numPNG = numPNG + 1
    deg = maxTheta*sin(i)
    set title sprintf("{/:Italic θ} = %.1f°", round(deg, 2)) font 'TimesNewRoman, 20'
    posAx = Ax(deg) ; posAy = Ay(deg)
    posBx = Bx(deg) ; posBy = By(deg)
    posCx = Cx(deg) ; posCy = Cy(deg)
    posDx = Dx(deg) ; posDy = Dy(deg)
 
    # Draw all of the links
    set arrow 1 from Ox, Oy to posAx, posAy nohead lw linkLW front
    set arrow 2 from posAx, posAy to posBx, posBy nohead lw linkLW front
    set arrow 3 from posAx, posAy to posDx, posDy nohead lw linkLW front
    set arrow 4 from posBx, posBy to posCx, posCy nohead lw linkLW front
    set arrow 5 from posDx, posDy to posCx, posCy nohead lw linkLW front
    set arrow 6 from Px, Py to posBx, posBy nohead lw linkLW front
    set arrow 7 from Px, Py to posDx, posDy nohead lw linkLW front
 
    # Draw unfixed joints A, B, C and D
    set obj 3 circ at posAx, posAy size CIRC_R fc rgb 'black' fs solid front
    set obj 4 circ at posBx, posBy size CIRC_R fc rgb 'black' fs solid front
    set obj 5 circ at posCx, posCy size CIRC_R fc rgb 'black' fs solid front
    set obj 6 circ at posDx, posDy size CIRC_R fc rgb 'black' fs solid front
    set label 3 'A' left at posAx-0.8, posAy+0.5 font 'TimesNewRoman:Italic, 20' front
    set label 4 'B' left at posBx-0.5, posBy-0.8 font 'TimesNewRoman:Italic, 20' front
    set label 5 'C' left at posCx+0.5, posCy font 'TimesNewRoman:Italic, 20' front
    set label 6 'D' left at posDx-0.5, posDy+0.5 font 'TimesNewRoman:Italic, 20' front
 
    # Draw all of the locus
    if(isLocusDrawn){
    set obj 7 circ at Ox, Oy size r fs empty border rgb 'royalblue' lw locusLW back
    set obj 8 circ at Ox, Oy size r arc [-maxTheta:maxTheta] fc rgb 'royalblue'  fs transparent solid 0.5 noborder
    set arrow 8 from Px, Py to posCx, -maxCy nohead lw locusLW lt 0  lc rgb 'black' back
    set arrow 9 from Px, Py to posCx, maxCy nohead lw locusLW lt 0 lc rgb 'black' back
    set arrow 10 from posCx, maxCy to posCx, -maxCy nohead lw locusLW lc rgb 'red' back
    }
 
    plot 1/0
    set out  # Output PNG file
  }
}