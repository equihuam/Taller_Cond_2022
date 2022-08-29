import os
import shutil

dir_base = ".\\blog"
os.chdir(dir_base)


fname = []
for root,d_names,f_names in os.walk("."):
    for f in f_names:
        if  f.endswith("shp"): # f.endswith("csv") or f.endswith("tif"):
            os.path.join(root, f)
            fname.append(os.path.join(root, f))
#            shutil.copy(os.path.join(root, f), os.path.join("..\\datos" , f))
            print("fname = {}".format(f))

