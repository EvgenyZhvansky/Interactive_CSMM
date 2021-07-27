import os
import scipy.io as io
from pyimzml.ImzMLParser import ImzMLParser
import numpy as np
import psutil

def convert_imaging_file_to_mat(imzml_filename, mat_filename, Z=0):
    p = ImzMLParser(imzml_filename)
    data={}
    amount_of_points_in_image=0
    zs=[]
    RAM_available=psutil.virtual_memory().available
    
    print("Set the only one Z-coordinate to be processed\nSkip (press Enter) to use the default value")
    while amount_of_points_in_image==0:
        try:
            Z=int(input("Enter Z-coordinate: "))
        except ValueError:
            print('Default Z=0 will be used. Enter only digits.')
        for i, (x,y,z) in enumerate(p.coordinates):
            if z==Z:
                amount_of_points_in_image+=1
            if not (z in zs):
                zs.append(z)
        if amount_of_points_in_image==0:
            print("There is no such Z-coordinate in your MS image.\nAvailable Z are:")
            print(*zs, sep=' ')
            print("Try again or use Ctrl+C to terminate the process")
    #amount_of_points_in_image=len(p.intensityLengths)
    data['peaks'] = np.empty((amount_of_points_in_image,), dtype=np.object)
    data['R'] = np.ones(amount_of_points_in_image,dtype=np.int16)
    data['X'] = np.zeros(amount_of_points_in_image,dtype=np.int16)
    data['Y'] = np.zeros(amount_of_points_in_image,dtype=np.int16)
    data['Z'] = np.zeros(amount_of_points_in_image,dtype=np.int16)
    k=0

    length_of_intensities=0
    for i, (x,y,z) in enumerate(p.coordinates):
        if z==Z:
            length_of_intensities += p.getspectrum(i)[1].shape[0]
            

    if length_of_intensities*8*2>RAM_available:
        print(length_of_intensities)
        print('Please reduce the imzML file to put it into RAM\nYou can do it by the SNR threshold or m/z range reduction, while forming imzML file')
        print('Available RAM is {:.2f}GB, requested {:.2f}GB'.format(RAM_available/(2**30),length_of_intensities*8*2/(2**30)))
        return
    for i, (x,y,z) in enumerate(p.coordinates):
        if z==Z:
            mzs, intensities = p.getspectrum(i)
            data['X'][i] = x
            data['Y'][i] = y
            data['R'][i] = 1
            data['peaks'][i] = np.vstack((mzs,intensities))

    print(mat_filename)
    io.savemat(mat_filename, {'data': data})
    return


if __name__ == '__main__':
    imzml_found = False
    data = {}
    for rootdir, dirs, files in os.walk(os.getcwd()):
        for file in files:
            if len(file) > 6:
                if (file[len(file) - 6:len(file)] == '.imzML'):
                    imzml_found = True
                    imzml_filename=os.path.join(str(rootdir),str(file))
                    newfilename = imzml_filename.rsplit(".", 1)
                    mat_filename = newfilename[0] + ".mat"
                    convert_imaging_file_to_mat(imzml_filename, mat_filename)
                    

    if not imzml_found:
        print('No imzML file was found. Check the directory, where the script is located.')

    print('done')
    input('press any key to continue')
