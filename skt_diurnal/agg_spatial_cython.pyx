#cython: boundscheck=False, wraparound=False, nonecheck=False, cdivision=True
#cython: language_level=3

## To compile: 
## python setup_cython.py build_ext --inplace


import numpy as np
cimport numpy as cnp

def agg_pixels(cnp.ndarray[cnp.int32_t,ndim=1] NiX,
               cnp.ndarray[cnp.int32_t,ndim=1] NiY,
               cnp.ndarray[cnp.float32_t,ndim=1] xraw, 
               cnp.ndarray[cnp.float32_t,ndim=2] xagg,
               cnp.ndarray[cnp.float32_t,ndim=2] xaggSTD,
               cnp.ndarray[cnp.int32_t,ndim=2] xcount,
               float zmiss,):
    
#def agg_pixels(int[:] NiX,
               #int[:] NiY,
               #float[:,:] xraw, 
               #float[:,:] xagg,
               #int[:,:] xcount,
               #float zmiss,):

  cdef:
    int ix,iy, nix, niy , ngrid,ip
    int nx,ny
    int nlon,nlat
  #cdef cnp.ndarray [cnp.int32_t, ndim=2] xcountT
    
  ngrid = NiX.shape[0]  
  nlat = xagg.shape[0]
  nlon = xagg.shape[1]
  
  #xcountT = np.zeros((ny,nx),np.int32)
  
  xagg[:,:]     = 0   # Mean aggregated field
  xaggSTD[:,:]  = 0   # Std of aggregated field 
  xcount[:,:]   = 0   # number of pixels 
  
    
  
  ## aggregate 
  for ip in range(ngrid):
      nix = NiX[ip]
      niy = NiY[ip]
      if ( (nix >= 0 and nix <nlon) and
         (niy>=0) and (niy<nlat)):
          
          if ( xraw[ip] != zmiss) :
            # counter      
            xcount[niy,nix] = xcount[niy,nix] + 1     
            # sum 
            xagg[niy,nix]   = xagg[niy,nix] + xraw[ip]
            # square sum 
            xaggSTD[niy,nix]   = xaggSTD[niy,nix] + xraw[ip]*xraw[ip]
   
  
  ## normalize 
  for ix in range(nlon):
    for iy in range(nlat):
      if ( xcount[iy,ix] > 0 ) :
        xagg[iy,ix]    = xagg[iy,ix]/xcount[iy,ix]
        xaggSTD[iy,ix]    = (xaggSTD[iy,ix]/xcount[iy,ix] - xagg[iy,ix]*xagg[iy,ix])
        if xaggSTD[iy,ix] >= 0 :
            xaggSTD[iy,ix] =  xaggSTD[iy,ix]**0.5
        else:
            xaggSTD[iy,ix]=zmiss
      else:
        xagg[iy,ix]    = zmiss
        xaggSTD[iy,ix]    = zmiss
      
