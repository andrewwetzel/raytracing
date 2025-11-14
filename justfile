hello-fortran:
    @echo "--- Compiling Fortran Program ---"
    @gfortran -o apps/hello_fortran apps/hello_fortran_example/hello_fortran.f90
    @echo "--- Running Fortran Program ---"
    @./apps/hello_fortran