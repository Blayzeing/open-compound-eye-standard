include <BOSL2/std.scad>
include <BOSL2/beziers.scad>


axial_offset =
[
  1.5,
  3,
  8
];

length = 15;
lens_d = 5;
sphere_size = 0.4;
axis_diameter = 0.3;
axis_length = 4;
joint_scale = 2;

gauss_size = 2;
gauss_quant = 50;
gauss_samples = 100;

$fn=128;

to_show = [
            "cone-top",
            "cone-bottom",
            //"gaussian",
            "cone-point",
            "u-axis",
            "v-axis",
            "w-axis",
            "u-extension",
            "v-extension",
            "w-extension"
          ];
// Draw the cone part(s)
show_only(str_join(to_show, " "))
{
skew(sxz=axial_offset.x/-axial_offset.z,
     syz=axial_offset.y/-axial_offset.z
    )
{
    tag("cone-top")
    recolor([0,0.3,0.9,0.4])
    cylinder(d1=lens_d, r2=((lens_d/2)/axial_offset.z)*(length), h=length-axial_offset.z);
    
    tag("cone-bottom")
    recolor([0.1,0.1,0.1,0.1])
    down(axial_offset.z)
    cylinder(d1=0, d2=lens_d, h=axial_offset.z);
    
    // Draw a gaussian
    tag("gaussian")
    let(
        max_size = lens_d/2,
        samples = [for(i=gaussian_rands(n=gauss_samples), cov=lens_d) if(abs(i) <= max_size) (abs(i)/max_size)],
        quant_size = max_size/gauss_quant,
        quantised_counts = [for(i=[1:gauss_quant])
                               [for(s=samples)
                                let(scaled_s = s/quant_size)
                                if(scaled_s < i && scaled_s >= i-1)
                                1
                               ]
                           ],
        quantised = [for(c=quantised_counts) len(c)],
        max_val = max(quantised),
        //normed = [for(v=quantised) v/max_val],
        path = [for(i=[0:gauss_quant-1])
                  [quant_size*(i-0.5)+0.05, quantised[i]/max_val]
               ]
       )
    {
        rotate_sweep(path, closed=false);
        
   }
}

// Draw the black dot
tag("cone-point")
recolor("black")
move(diagonal_matrix([1,1,-1])*axial_offset)
sphere(sphere_size);

// Draw the central axis
tag("w-axis")
cyl(d=axis_diameter, l=axis_length, anchor=BOTTOM, rounding2=axis_diameter/2.01);
tag("v-axis")
ycyl(d=axis_diameter, l=axis_length, anchor=FRONT, rounding2=axis_diameter/2.01);
tag("u-axis")
xcyl(d=axis_diameter, l=axis_length, anchor=LEFT, rounding2=axis_diameter/2.01);

// Draw the offset axis
tag("w-extension")
cyl(d=axis_diameter, l=axial_offset.z, anchor=TOP)
position(BOTTOM)
{
   sphere(d=axis_diameter*joint_scale)
   tag("u-extension")
   xcyl(d=axis_diameter, l=axial_offset.x, anchor=LEFT)
   position(RIGHT)
   {
     sphere(d=axis_diameter*joint_scale);
     tag("v-extension")
     ycyl(d=axis_diameter, l=axial_offset.y, anchor=FRONT);
   }
}
}