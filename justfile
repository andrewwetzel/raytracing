# ===================================================================
# Configuration
# ===================================================================

# Automatically read the project ID from your firebase setup (.firebaserc)
# This assumes your GCP Project ID and Firebase Project ID are the same.
FIREBASE_PROJECT_ID := `grep default .firebaserc | cut -d '"' -f 4`
GCP_PROJECT_ID := FIREBASE_PROJECT_ID

# --- User-Defined Deployment Settings ---
GCP_REGION := "us-central1"
BACKEND_SERVICE_NAME := "raytracing-backend"

# ===================================================================
# Local Development & Testing
# ===================================================================

# Installs dependencies and runs the backend server locally
run-backend:
    @echo "--- Syncing dependencies ---"
    @uv pip sync pyproject.toml
    @echo "--- Running backend server at http://127.0.0.1:8000 ---"
    @uv run uvicorn packages.backend.main:app --reload

# Starts the local backend and frontend servers using Docker Compose
test-local:
    @echo "\n--- Starting Local Test Environment (in background) ---"
    @docker compose -f docker-compose.local.yml up -d
    @echo "\n--- Services Started ---"
    @echo "Fetching frontend URL..."
    @{ \
        PORT=$(docker compose -f docker-compose.local.yml ps | grep frontend | awk '{print $NF}' | cut -d ':' -f 2 | cut -d '-' -f 1); \
        echo "Frontend is running at: http://localhost:$$PORT"; \
    }
    @echo "\n--- Attaching to logs (press Ctrl+C to detach) ---"
    @docker compose -f docker-compose.local.yml logs -f

# Stops the local backend and frontend servers
stop-local:
    @echo "\n--- Stopping Local Test Environment ---"
    @docker compose -f docker-compose.local.yml down

# ===================================================================
# GCP & Firebase Deployment
# ===================================================================

# Run this once to enable required GCP APIs for Cloud Run and Artifact Registry
enable-gcp-apis:
    @echo "--- Enabling GCP APIs for project {{GCP_PROJECT_ID}} ---"
    @gcloud services enable \
      run.googleapis.com \
      artifactregistry.googleapis.com \
      cloudbuild.googleapis.com \
      --project={{GCP_PROJECT_ID}}

# Set the active project for Firebase CLI commands
set-firebase-project:
    @echo "--- Setting active Firebase project to {{FIREBASE_PROJECT_ID}} ---"
    @firebase use {{FIREBASE_PROJECT_ID}}

# Build and deploy the backend container to Cloud Run
deploy-backend:
    @echo "--- Deploying backend '{{BACKEND_SERVICE_NAME}}' to Cloud Run ---"
    @gcloud run deploy {{BACKEND_SERVICE_NAME}} \
      --source ./packages/backend \
      --platform managed \
      --region {{GCP_REGION}} \
      --allow-unauthenticated \
      --project={{GCP_PROJECT_ID}}

#!/usr/bin/env just --justfile

# Deploy the frontend to Firebase Hosting
# This recipe automatically injects the deployed backend URL into the frontend code
deploy-frontend: set-firebase-project
    @echo "--- Deploying frontend to Firebase Hosting ---"
    
    @echo "Fetching Cloud Run service URL..."
    # Get the URL of the deployed backend
    SERVICE_URL=`gcloud run services describe {{BACKEND_SERVICE_NAME}} --platform managed --region {{GCP_REGION}} --project={{GCP_PROJECT_ID}} --format 'value(status.url)'`; \
    echo "Injecting backend URL '$$SERVICE_URL' into frontend"; \
    sed -i.bak "s|http://1227.0.0.1:8000|$$SERVICE_URL|g" apps/frontend/script.js; \
    
    @echo "Deploying to Firebase..."
    @firebase deploy --only hosting
    
    @echo "Cleaning up frontend..."
    # Revert script.js to its local version
    @mv apps/frontend/script.js.bak apps/frontend/script.js
    
    @echo "--- Frontend deployed successfully! ---"

# Deploy both backend and frontend
deploy: deploy-backend deploy-frontend
    @echo "--- Full Deployment Complete ---"

# ===================================================================
# Fortran Examples & Tests
# ===================================================================

# --- Fortran Example ---
hello-fortran:
    @echo "--- Compiling Fortran Program ---"
    @gfortran -o apps/hello_fortran apps/hello_fortran_example/hello_fortran.f90
    @echo "--- Running Fortran Program ---"
    @./apps/hello_fortran
    @rm apps/hello_fortran

# --- Fortran Subroutine Tests ---
test-elect1:
    @gfortran -ffixed-form -fno-align-commons -o packages/ft_raytrace/test_elect1 packages/ft_raytrace/test/test_elect1.f packages/ft_raytrace/src/ELECT1.f
    @./packages/ft_raytrace/test_elect1
    @rm packages/ft_raytrace/test_elect1

test-expx:
    @gfortran -ffixed-form -fno-align-commons -o packages/ft_raytrace/test_expx packages/ft_raytrace/test/test_expx.f packages/ft_raytrace/src/EXPX.f
    @./packages/ft_raytrace/test_expx
    @rm packages/ft_raytrace/test_expx

test-bulge:
    @gfortran -ffixed-form -fno-align-commons -o packages/ft_raytrace/test_bulge packages/ft_raytrace/test/test_bulge.f packages/ft_raytrace/src/BULGE.f
    @./packages/ft_raytrace/test_bulge
    @rm packages/ft_raytrace/test_bulge

test-gausel:
    @gfortran -ffixed-form -fno-align-commons -o packages/ft_raytrace/test_gausel packages/ft_raytrace/test/test_gausel.f packages/ft_raytrace/src/GAUSEL.f
    @./packages/ft_raytrace/test_gausel
    @rm packages/ft_raytrace/test_gausel

test-tablex:
    @gfortran -ffixed-form -fno-align-commons -o packages/ft_raytrace/test_tablex packages/ft_raytrace/test/test_TABLEX.f packages/ft_raytrace/src/TABLEX.f packages/ft_raytrace/test/stub_elect1.f
    @./packages/ft_raytrace/test_tablex
    @rm packages/ft_raytrace/test_tablex

test-chapx:
    @gfortran -ffixed-form -fno-align-commons -o packages/ft_raytrace/test_chapx packages/ft_raytrace/test/test_CHAPX.f packages/ft_raytrace/src/CHAPX.f
    @./packages/ft_raytrace/test_chapx
    @rm packages/ft_raytrace/test_chapx

test-vchapx:
    @gfortran -ffixed-form -fno-align-commons -o packages/ft_raytrace/test_vchapx packages/ft_raytrace/test/test_VCHAPX.f packages/ft_raytrace/src/VCHAPX.f packages/ft_raytrace/test/stub_elect1.f
    @./packages/ft_raytrace/test_vchapx
    @rm packages/ft_raytrace/test_vchapx

test-dchapt:
    @gfortran -ffixed-form -fno-align-commons -o packages/ft_raytrace/test_dchapt packages/ft_raytrace/test/test_DCHAPT.f packages/ft_raytrace/src/DCHAPT.f
    @./packages/ft_raytrace/test_dchapt
    @rm packages/ft_raytrace/test_dchapt

test-linear:
    @gfortran -ffixed-form -fno-align-commons -o packages/ft_raytrace/test_linear packages/ft_raytrace/test/test_LINEAR.f packages/ft_raytrace/src/LINEAR.f packages/ft_raytrace/test/stub_elect1.f
    @./packages/ft_raytrace/test_linear
    @rm packages/ft_raytrace/test_linear

test-qparab:
    @gfortran -ffixed-form -fno-align-commons -o packages/ft_raytrace/test_qparab packages/ft_raytrace/test/test_QPARAB.f packages/ft_raytrace/src/QPARAB.f packages/ft_raytrace/test/stub_elect1.f
    @./packages/ft_raytrace/test_qparab
    @rm packages/ft_raytrace/test_qparab

test-torus:
    @gfortran -ffixed-form -fno-align-commons -o packages/ft_raytrace/test_torus packages/ft_raytrace/test/test_TORUS.f packages/ft_raytrace/src/TORUS.f
    @./packages/ft_raytrace/test_torus
    @rm packages/ft_raytrace/test_torus

test-dtorus:
    @gfortran -ffixed-form -fno-align-commons -o packages/ft_raytrace/test_dtorus packages/ft_raytrace/test/test_DTORUS.f packages/ft_raytrace/src/DTORUS.f
    @./packages/ft_raytrace/test_dtorus
    @rm packages/ft_raytrace/test_dtorus

test-trough:
    @gfortran -ffixed-form -fno-align-commons -o packages/ft_raytrace/test_trough packages/ft_raytrace/test/test_TROUGH.f packages/ft_raytrace/src/TROUGH.f
    @./packages/ft_raytrace/test_trough
    @rm packages/ft_raytrace/test_trough

test-shock:
    @gfortran -ffixed-form -fno-align-commons -o packages/ft_raytrace/test_shock packages/ft_raytrace/test/test_SHOCK.f packages/ft_raytrace/src/SHOCK.f
    @./packages/ft_raytrace/test_shock
    @rm packages/ft_raytrace/test_shock

test-wave:
    @gfortran -ffixed-form -fno-align-commons -o packages/ft_raytrace/test_wave packages/ft_raytrace/test/test_WAVE.f packages/ft_raytrace/src/WAVE.f
    @./packages/ft_raytrace/test_wave
    @rm packages/ft_raytrace/test_wave

test-wave2:
    @gfortran -ffixed-form -fno-align-commons -o packages/ft_raytrace/test_wave2 packages/ft_raytrace/test/test_WAVE2.f packages/ft_raytrace/src/WAVE2.f
    @./packages/ft_raytrace/test_wave2
    @rm packages/ft_raytrace/test_wave2

test-doppler:
    @gfortran -ffixed-form -fno-align-commons -o packages/ft_raytrace/test_doppler packages/ft_raytrace/test/test_DOPPLER.f packages/ft_raytrace/src/DOPPLER.f
    @./packages/ft_raytrace/test_doppler
    @rm packages/ft_raytrace/test_doppler

test-consty:
    @gfortran -ffixed-form -fno-align-commons -o packages/ft_raytrace/test_consty packages/ft_raytrace/test/test_CONSTY.f packages/ft_raytrace/src/CONSTY.f
    @./packages/ft_raytrace/test_consty
    @rm packages/ft_raytrace/test_consty

test-dipoly:
    @gfortran -ffixed-form -fno-align-commons -o packages/ft_raytrace/test_dipoly packages/ft_raytrace/test/test_DIPOLY.f packages/ft_raytrace/src/DIPOLY.f
    @./packages/ft_raytrace/test_dipoly
    @rm packages/ft_raytrace/test_dipoly

test-cubey:
    @gfortran -ffixed-form -fno-align-commons -o packages/ft_raytrace/test_cubey packages/ft_raytrace/test/test_CUBEY.f packages/ft_raytrace/src/CUBEY.f
    @./packages/ft_raytrace/test_cubey
    @rm packages/ft_raytrace/test_cubey

test-harmony:
    @gfortran -ffixed-form -fno-align-commons -o packages/ft_raytrace/test_harmony packages/ft_raytrace/test/test_HARMONY.f packages/ft_raytrace/src/HARMONY.f
    @./packages/ft_raytrace/test_harmony
    @rm packages/ft_raytrace/test_harmony

test-tablez:
    @gfortran -ffixed-form -fno-align-commons -o packages/ft_raytrace/test_tablez packages/ft_raytrace/test/test_TABLEZ.f packages/ft_raytrace/src/TABLEZ.f
    @./packages/ft_raytrace/test_tablez
    @rm packages/ft_raytrace/test_tablez

test-constz:
    @gfortran -ffixed-form -fno-align-commons -o packages/ft_raytrace/test_constz packages/ft_raytrace/test/test_CONSTZ.f packages/ft_raytrace/src/CONSTZ.f
    @./packages/ft_raytrace/test_constz
    @rm packages/ft_raytrace/test_constz

test-expz:
    @gfortran -ffixed-form -fno-align-commons -o packages/ft_raytrace/test_expz packages/ft_raytrace/test/test_EXPZ.f packages/ft_raytrace/src/EXPZ.f
    @./packages/ft_raytrace/test_expz
    @rm packages/ft_raytrace/test_expz

test-expz2:
    @gfortran -ffixed-form -fno-align-commons -o packages/ft_raytrace/test_expz2 packages/ft_raytrace/test/test_EXPZ2.f packages/ft_raytrace/src/EXPZ2.f
    @./packages/ft_raytrace/test_expz2
    @rm packages/ft_raytrace/test_expz2

test-ahwfwc:
    @gfortran -ffixed-form -fno-align-commons -o packages/ft_raytrace/test_ahwfwc packages/ft_raytrace/test/test_AHWFWC.f packages/ft_raytrace/src/AHWFWC.f packages/ft_raytrace/test/test_stub_models.f
    @./packages/ft_raytrace/test_ahwfwc
    @rm packages/ft_raytrace/test_ahwfwc

test-ahwfnc:
    @gfortran -ffixed-form -fno-align-commons -o packages/ft_raytrace/test_ahwfnc packages/ft_raytrace/test/test_AHWFNC.f packages/ft_raytrace/src/AHWFNC.f packages/ft_raytrace/test/test_stub_models.f
    @./packages/ft_raytrace/test_ahwfnc
    @rm packages/ft_raytrace/test_ahwfnc

test-ahnfwc:
    @gfortran -ffixed-form -fno-align-commons -o packages/ft_raytrace/test_ahnfwc packages/ft_raytrace/test/test_AHNFWC.f packages/ft_raytrace/src/AHNFWC.f packages/ft_raytrace/test/test_stub_models.f
    @./packages/ft_raytrace/test_ahnfwc
    @rm packages/ft_raytrace/test_ahnfwc

test-ahnfnc:
    @gfortran -ffixed-form -fno-align-commons -o packages/ft_raytrace/test_ahnfnc packages/ft_raytrace/test/test_AHNFNC.f packages/ft_raytrace/src/AHNFNC.f packages/ft_raytrace/test/test_stub_models.f
    @./packages/ft_raytrace/test_ahnfnc
    @rm packages/ft_raytrace/test_ahnfnc

test-bqwfwc:
    @gfortran -ffixed-form -fno-align-commons -o packages/ft_raytrace/test_bqwfwc packages/ft_raytrace/test/test_BQWFWC.f packages/ft_raytrace/src/BQWFWC.f packages/ft_raytrace/test/test_stub_models.f
    @./packages/ft_raytrace/test_bqwfwc
    @rm packages/ft_raytrace/test_bqwfwc

test-bqwfnc:
    @gfortran -ffixed-form -fno-align-commons -o packages/ft_raytrace/test_bqwfnc packages/ft_raytrace/test/test_BQWFNC.f packages/ft_raytrace/src/BQWFNC.f packages/ft_raytrace/test/test_stub_models.f
    @./packages/ft_raytrace/test_bqwfnc
    @rm packages/ft_raytrace/test_bqwfnc

test-fresnel:
    @gfortran -ffixed-form -fno-align-commons -o packages/ft_raytrace/test_fresnel packages/ft_raytrace/test/test_FRESNEL.f packages/ft_raytrace/src/FRESNEL.f
    @./packages/ft_raytrace/test_fresnel
    @rm packages/ft_raytrace/test_fresnel

test-fsw:
    @gfortran -ffixed-form -fno-align-commons -o packages/ft_raytrace/test_fsw packages/ft_raytrace/test/test_FSW.f packages/ft_raytrace/src/FSW.f packages/ft_raytrace/src/FRESNEL.f
    @./packages/ft_raytrace/test_fsw
    @rm packages/ft_raytrace/test_fsw

test-fgsw:
    @gfortran -ffixed-form -fno-align-commons -o packages/ft_raytrace/test_fgsw packages/ft_raytrace/test/test_FGSW.f packages/ft_raytrace/src/FGSW.f packages/ft_raytrace/src/FSW.f packages/ft_raytrace/src/FRESNEL.f
    @./packages/ft_raytrace/test_fgsw
    @rm packages/ft_raytrace/test_fgsw

test-swwf:
    @gfortran -ffixed-form -fno-align-commons -o packages/ft_raytrace/test_swwf packages/ft_raytrace/test/test_SWWF.f packages/ft_raytrace/src/SWWF.f packages/ft_raytrace/src/FGSW.f packages/ft_raytrace/src/FSW.f packages/ft_raytrace/src/FRESNEL.f packages/ft_raytrace/test/test_stub_models.f
    @./packages/ft_raytrace/test_swwf
    @rm packages/ft_raytrace/test_swwf

test-swnf:
    @gfortran -ffixed-form -fno-align-commons -o packages/ft_raytrace/test_swnf packages/ft_raytrace/test/test_SWNF.f packages/ft_raytrace/src/SWNF.f packages/ft_raytrace/src/FGSW.f packages/ft_raytrace/src/FSW.f packages/ft_raytrace/src/FRESNEL.f packages/ft_raytrace/test/test_stub_models.f
    @./packages/ft_raytrace/test_swnf
    @rm packages/ft_raytrace/test_swnf

test-hamltn:
    @gfortran -ffixed-form -fno-align-commons -o packages/ft_raytrace/test_hamltn packages/ft_raytrace/test/test_HAMLTN.f packages/ft_raytrace/src/HAMLTN.f packages/ft_raytrace/test/test_stub_models.f packages/ft_raytrace/test/test_engine_stubs.f
    @./packages/ft_raytrace/test_hamltn
    @rm packages/ft_raytrace/test_hamltn

test-rkam:
    @gfortran -ffixed-form -fno-align-commons -o packages/ft_raytrace/test_rkam packages/ft_raytrace/test/test_RKAM.f packages/ft_raytrace/src/RKAM.f packages/ft_raytrace/src/HAMLTN.f packages/ft_raytrace/test/test_stub_models.f packages/ft_raytrace/test/test_engine_stubs.f
    @./packages/ft_raytrace/test_rkam
    @rm packages/ft_raytrace/test_rkam

test-backup:
    @gfortran -ffixed-form -fno-align-commons -o packages/ft_raytrace/test_backup packages/ft_raytrace/test/test_BACKUP.f packages/ft_raytrace/src/BACKUP.f packages/ft_raytrace/src/RKAM.f packages/ft_raytrace/src/HAMLTN.f packages/ft_raytrace/test/test_stub_models.f packages/ft_raytrace/test/test_engine_stubs.f
    @./packages/ft_raytrace/test_backup
    @rm packages/ft_raytrace/test_backup

test-polcar:
    @gfortran -ffixed-form -fno-align-commons -o packages/ft_raytrace/test_polcar packages/ft_raytrace/test/test_POLCAR.f packages/ft_raytrace/src/POLCAR.f 
    @./packages/ft_raytrace/test_polcar
    @rm packages/ft_raytrace/test_polcar

test-reach:
    @gfortran -ffixed-form -fno-align-commons -o packages/ft_raytrace/test_reach packages/ft_raytrace/test/test_REACH.f packages/ft_raytrace/src/REACH.f packages/ft_raytrace/src/POLCAR.f packages/ft_raytrace/src/HAMLTN.f packages/ft_raytrace/test/test_stub_models.f packages/ft_raytrace/test/test_engine_stubs.f
    @./packages/ft_raytrace/test_reach
    @rm packages/ft_raytrace/test_reach

test-trace:
    @gfortran -ffixed-form -fno-align-commons -o packages/ft_raytrace/test_trace packages/ft_raytrace/test/test_TRACE.f packages/ft_raytrace/src/TRACE.f packages/ft_raytrace/src/REACH.f packages/ft_raytrace/src/BACKUP.f packages/ft_raytrace/src/RKAM.f packages/ft_raytrace/src/POLCAR.f packages/ft_raytrace/src/HAMLTN.f packages/ft_raytrace/test/test_stub_models.f packages/ft_raytrace/test/test_engine_stubs.f
    @./packages/ft_raytrace/test_trace
    @rm packages/ft_raytrace/test_trace

test-readw:
    @gfortran -ffixed-form -fno-align-commons -o packages/ft_raytrace/test_readw packages/ft_raytrace/test/test_READW.f packages/ft_raytrace/src/READW.f
    @./packages/ft_raytrace/test_readw
    @rm packages/ft_raytrace/test_readw

test-printr:
    @gfortran -ffixed-form -fno-align-commons -o packages/ft_raytrace/test_printr packages/ft_raytrace/test/test_PRINTR.f packages/ft_raytrace/src/PRINTR.f packages/ft_raytrace/test/test_rindex_stub.f
    @./packages/ft_raytrace/test_printr
    @rm packages/ft_raytrace/test_printr

test-e2e-vertical:
    @gfortran -ffixed-form -fno-align-commons -o packages/ft_raytrace/test_e2e_vertical packages/ft_raytrace/test/test_e2e_vertical.f packages/ft_raytrace/src/HAMLTN.f packages/ft_raytrace/src/RKAM.f packages/ft_raytrace/test/test_stub_models.f packages/ft_raytrace/test/test_engine_stubs.f
    @./packages/ft_raytrace/test_e2e_vertical
    @rm packages/ft_raytrace/test_e2e_vertical

test-e2e-oblique:
    @gfortran -ffixed-form -fno-align-commons -o packages/ft_raytrace/test_e2e_oblique packages/ft_raytrace/test/test_e2e_oblique.f packages/ft_raytrace/src/HAMLTN.f packages/ft_raytrace/src/RKAM.f packages/ft_raytrace/test/test_stub_models.f packages/ft_raytrace/test/test_engine_stubs.f
    @./packages/ft_raytrace/test_e2e_oblique
    @rm packages/ft_raytrace/test_e2e_oblique

test-e2e-perf:
    @gfortran -ffixed-form -fno-align-commons -o packages/ft_raytrace/test_e2e_perf packages/ft_raytrace/test/test_e2e_perf.f packages/ft_raytrace/src/HAMLTN.f packages/ft_raytrace/src/RKAM.f packages/ft_raytrace/test/test_stub_models.f packages/ft_raytrace/test/test_engine_stubs.f
    @./packages/ft_raytrace/test_e2e_perf
    @rm packages/ft_raytrace/test_e2e_perf

test-e2e-sample-case:
    @gfortran -ffixed-form -fno-align-commons -o packages/ft_raytrace/test_e2e_sample_case packages/ft_raytrace/test/test_e2e_sample_case.f packages/ft_raytrace/src/HAMLTN.f packages/ft_raytrace/src/RKAM.f packages/ft_raytrace/src/AHWFWC.f packages/ft_raytrace/src/CHAPX.f packages/ft_raytrace/src/DIPOLY.f packages/ft_raytrace/src/EXPZ2.f
    @./packages/ft_raytrace/test_e2e_sample_case
    @rm packages/ft_raytrace/test_e2e_sample_case

# --- Test Aliases ---

# Run all fortran tests
test: test-elect1 test-expx test-bulge test-gausel test-tablex test-chapx test-vchapx test-dchapt test-linear test-qparab test-torus test-dtorus test-trough test-shock test-wave test-wave2 test-doppler test-consty test-dipoly test-cubey test-harmony test-tablez test-constz test-expz test-expz2 test-ahwfwc test-ahwfnc test-ahnfwc test-ahnfnc test-bqwfwc test-bqwfnc test-fresnel test-fsw test-fgsw test-swwf test-swnf test-hamltn test-rkam test-backup test-polcar test-reach test-trace test-readw test-printr test-e2e-vertical test-e2e-oblique test-e2e-perf test-e2e-sample-case

# Run tests using the Fortran Package Manager
fpm-test:
    @cd packages/ft_raytrace && fpm test

# --- End-to-End Testing ---
test-e2e:
    @echo "--- Building and running services ---"
    @sudo docker compose up -d --build
    @echo "--- Running end-to-end tests ---"
    @sleep 5
    @chmod +x tests/e2e.sh
    @./tests/e2e.sh
    @echo "--- Tearing down services ---"
    @sudo docker compose down