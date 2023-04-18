# to create .so locally: python setup_cython.py build_ext --inplace

from distutils.core import setup
from distutils.extension import Extension
from Cython.Build import cythonize
import numpy
setup(
  name = 'agg_spatial_cython',
  ext_modules = cythonize(
    Extension("agg_spatial_cython",["agg_spatial_cython.pyx"],
     extra_compile_args=["-O2"]) ),
  include_dirs=[numpy.get_include(),],
  )

