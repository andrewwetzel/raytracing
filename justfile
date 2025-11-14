

hello-fortran:
    @echo "--- Compiling Fortran Program ---"
    @gfortran -o apps/hello_fortran apps/hello_fortran_example/hello_fortran.f90
    @echo "--- Running Fortran Program ---"
    @./apps/hello_fortran

test-elect1:
    @gfortran -o packages/ft_raytrace/test_elect1 packages/ft_raytrace/test_elect1.f packages/ft_raytrace/ELECT1.f
    @./packages/ft_raytrace/test_elect1
    @rm packages/ft_raytrace/test_elect1

test-expx:
    @gfortran -o packages/ft_raytrace/test_expx packages/ft_raytrace/test_expx.f packages/ft_raytrace/EXPX.f packages/ft_raytrace/ELECT1.f
    @./packages/ft_raytrace/test_expx
    @rm packages/ft_raytrace/test_expx

test-bulge:
    @gfortran -o packages/ft_raytrace/test_bulge packages/ft_raytrace/test_bulge.f packages/ft_raytrace/BULGE.f packages/ft_raytrace/ELECT1.f
    @./packages/ft_raytrace/test_bulge
    @rm packages/ft_raytrace/test_bulge

test: test-elect1 test-expx test-bulge