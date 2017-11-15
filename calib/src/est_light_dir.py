import bpy
import numpy
import os
import math
# from mathutils import Matrix
# from mathutils import Vector

# def rotation_x(ang_x)
#     rot_x = 

# if __name__ == "__main__":

nlights = 25
ldir = numpy.zeros((3, nlights))

for ilight in range(0, nlights):
    light = bpy.data.objects['Lamp.%03d' % ilight]
    # euler = mathutils.Vector((light.rotation_euler[0], light.rotation_euler[1], light.rotation_euler[2]))
    # pos = mathutils.Vector(light.location[0], light.location[1], light.location[2])
    euler = numpy.zeros(3)
    pos = numpy.zeros(3)
    euler[0] = light.rotation_euler[0]
    euler[1] = light.rotation_euler[1]
    euler[2] = light.rotation_euler[2]
    pos[0] = light.location[0]
    pos[1] = light.location[1]
    pos[2] = light.location[2]

    norm_pos = math.sqrt(pos[0]**2 + pos[1]**2 + pos[2]**2)

    ldir[0, ilight] = pos[0] / norm_pos
    ldir[1, ilight] = pos[1] / norm_pos
    ldir[2, ilight] = pos[2] / norm_pos

odir = 'C:/Users/Admin/Documents/3D_Recon/Data/synthetic_data/3DRecon_Algo_Eval/groundtruth/calib_results'
fid = open("%s/light_directions.txt" % odir, 'wt')
for d in range(0, 3):
    for l in range(0, nlights):
        fid.write(" %.04f" % ldir[d, l])
    fid.write('\n')
fid.close();