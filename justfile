

hello-fortran:
    @echo "--- Compiling Fortran Program ---"
    @gfortran -o apps/hello_fortran apps/hello_fortran_example/hello_fortran.f90
    @echo "--- Running Fortran Program ---"
    @./apps/hello_fortran

test-elect1:
    @echo "--- Compiling ELECT1 Test Harness ---"
    @gfortran -o packages/ft_raytrace/test_elect1 packages/ft_raytrace/test_elect1.f packages/ft_raytrace/ELECT1.f
    @echo "--- Running ELECT1 Test ---"
    @./packages/ft_raytrace/test_elect1