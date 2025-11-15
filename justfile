

hello-fortran:
    @echo "--- Compiling Fortran Program ---"
    @gfortran -o apps/hello_fortran apps/hello_fortran_example/hello_fortran.f90
    @echo "--- Running Fortran Program ---"
    @./apps/hello_fortran

test-elect1:
    @gfortran -ffixed-form -o packages/ft_raytrace/test_elect1 packages/ft_raytrace/test_elect1.f packages/ft_raytrace/ELECT1.f
    @./packages/ft_raytrace/test_elect1
    @rm packages/ft_raytrace/test_elect1

test-expx:
    @gfortran -ffixed-form -o packages/ft_raytrace/test_expx packages/ft_raytrace/test_expx.f packages/ft_raytrace/EXPX.f
    @./packages/ft_raytrace/test_expx
    @rm packages/ft_raytrace/test_expx

test-bulge:
    @gfortran -ffixed-form -o packages/ft_raytrace/test_bulge packages/ft_raytrace/test_bulge.f packages/ft_raytrace/BULGE.f
    @./packages/ft_raytrace/test_bulge
    @rm packages/ft_raytrace/test_bulge

test-gausel:
    @gfortran -ffixed-form -o packages/ft_raytrace/test_gausel packages/ft_raytrace/test_gausel.f packages/ft_raytrace/GAUSEL.f
    @./packages/ft_raytrace/test_gausel
    @rm packages/ft_raytrace/test_gausel

test-tablex:
    @gfortran -ffixed-form -o packages/ft_raytrace/test_tablex packages/ft_raytrace/test_TABLEX.f packages/ft_raytrace/TABLEX.f
    @./packages/ft_raytrace/test_tablex
    @rm packages/ft_raytrace/test_tablex

test-chapx:
    @gfortran -ffixed-form -o packages/ft_raytrace/test_chapx packages/ft_raytrace/test_CHAPX.f packages/ft_raytrace/CHAPX.f
    @./packages/ft_raytrace/test_chapx
    @rm packages/ft_raytrace/test_chapx

test-vchapx:
    @gfortran -ffixed-form -o packages/ft_raytrace/test_vchapx packages/ft_raytrace/test_VCHAPX.f packages/ft_raytrace/VCHAPX.f
    @./packages/ft_raytrace/test_vchapx
    @rm packages/ft_raytrace/test_vchapx

test-dchapt:
    @gfortran -ffixed-form -o packages/ft_raytrace/test_dchapt packages/ft_raytrace/test_DCHAPT.f packages/ft_raytrace/DCHAPT.f
    @./packages/ft_raytrace/test_dchapt
    @rm packages/ft_raytrace/test_dchapt

test-linear:
    @gfortran -ffixed-form -o packages/ft_raytrace/test_linear packages/ft_raytrace/test_LINEAR.f packages/ft_raytrace/LINEAR.f
    @./packages/ft_raytrace/test_linear
    @rm packages/ft_raytrace/test_linear

test-qparab:
    @gfortran -ffixed-form -o packages/ft_raytrace/test_qparab packages/ft_raytrace/test_QPARAB.f packages/ft_raytrace/QPARAB.f
    @./packages/ft_raytrace/test_qparab
    @rm packages/ft_raytrace/test_qparab

test-torus:
    @gfortran -ffixed-form -o packages/ft_raytrace/test_torus packages/ft_raytrace/test_TORUS.f packages/ft_raytrace/TORUS.f
    @./packages/ft_raytrace/test_torus
    @rm packages/ft_raytrace/test_torus

test-dtorus:
    @gfortran -ffixed-form -o packages/ft_raytrace/test_dtorus packages/ft_raytrace/test_DTORUS.f packages/ft_raytrace/DTORUS.f
    @./packages/ft_raytrace/test_dtorus
    @rm packages/ft_raytrace/test_dtorus

test-trough:
    @gfortran -ffixed-form -o packages/ft_raytrace/test_trough packages/ft_raytrace/test_TROUGH.f packages/ft_raytrace/TROUGH.f
    @./packages/ft_raytrace/test_trough
    @rm packages/ft_raytrace/test_trough

test-shock:
    @gfortran -ffixed-form -o packages/ft_raytrace/test_shock packages/ft_raytrace/test_SHOCK.f packages/ft_raytrace/SHOCK.f
    @./packages/ft_raytrace/test_shock
    @rm packages/ft_raytrace/test_shock

test-wave:
    @gfortran -ffixed-form -o packages/ft_raytrace/test_wave packages/ft_raytrace/test_WAVE.f packages/ft_raytrace/WAVE.f
    @./packages/ft_raytrace/test_wave
    @rm packages/ft_raytrace/test_wave

test-wave2:
    @gfortran -ffixed-form -o packages/ft_raytrace/test_wave2 packages/ft_raytrace/test_WAVE2.f packages/ft_raytrace/WAVE2.f
    @./packages/ft_raytrace/test_wave2
    @rm packages/ft_raytrace/test_wave2

test-doppler:
    @gfortran -ffixed-form -o packages/ft_raytrace/test_doppler packages/ft_raytrace/test_DOPPLER.f packages/ft_raytrace/DOPPLER.f
    @./packages/ft_raytrace/test_doppler
    @rm packages/ft_raytrace/test_doppler

test: test-elect1 test-expx test-bulge test-gausel test-tablex test-chapx test-vchapx test-dchapt test-linear test-qparab test-torus test-dtorus test-trough test-shock test-wave test-wave2 test-doppler

fpm-test:
    @cd packages/ft_raytrace && fpm test

run-backend:
    @echo "--- Installing backend dependencies ---"
    @python3 -m pip install -r packages/backend/requirements.txt
    @echo "--- Running backend server ---"
    @cd packages/backend && uvicorn main:app --reload