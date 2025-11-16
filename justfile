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

# Starts the local backend and provides instructions to test the frontend
test-local: run-backend
    @echo "\n--- Local Test Environment ---"
    @echo "Backend is running at http://127.0.0.1:8000"
    @echo "Open 'apps/frontend/index.html' in your browser to test."

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
    @gfortran -ffixed-form -o packages/ft_raytrace/test_elect1 packages/ft_raytrace/test/test_elect1.f packages/ft_raytrace/src/ELECT1.f
    @./packages/ft_raytrace/test_elect1
    @rm packages/ft_raytrace/test_elect1

test-expx:
    @gfortran -ffixed-form -o packages/ft_raytrace/test_expx packages/ft_raytrace/test/test_expx.f packages/ft_raytrace/src/EXPX.f packages/ft_raytrace/src/ELECT1.f packages/ft_raytrace/src/BLOCK_DATA.f
    @./packages/ft_raytrace/test_expx
    @rm packages/ft_raytrace/test_expx

test-bulge:
    @gfortran -ffixed-form -o packages/ft_raytrace/test_bulge packages/ft_raytrace/test/test_bulge.f packages/ft_raytrace/src/BULGE.f packages/ft_raytrace/src/ELECT1.f packages/ft_raytrace/src/BLOCK_DATA.f
    @./packages/ft_raytrace/test_bulge
    @rm packages/ft_raytrace/test_bulge

test-gausel:
    @gfortran -ffixed-form -o packages/ft_raytrace/test_gausel packages/ft_raytrace/test/test_gausel.f packages/ft_raytrace/src/GAUSEL.f
    @./packages/ft_raytrace/test_gausel
    @rm packages/ft_raytrace/test_gausel

test-tablex:
    @gfortran -ffixed-form -o packages/ft_raytrace/test_tablex packages/ft_raytrace/test/test_TABLEX.f packages/ft_raytrace/src/TABLEX.f
    @./packages/ft_raytrace/test_tablex
    @rm packages/ft_raytrace/test_tablex

test-chapx:
    @gfortran -ffixed-form -o packages/ft_raytrace/test_chapx packages/ft_raytrace/test/test_CHAPX.f packages/ft_raytrace/src/CHAPX.f
    @./packages/ft_raytrace/test_chapx
    @rm packages/ft_raytrace/test_chapx

test-vchapx:
    @gfortran -ffixed-form -o packages/ft_raytrace/test_vchapx packages/ft_raytrace/test/test_VCHAPX.f packages/ft_raytrace/src/VCHAPX.f
    @./packages/ft_raytrace/test_vchapx
    @rm packages/ft_raytrace/test_vchapx

test-dchapt:
    @gfortran -ffixed-form -o packages/ft_raytrace/test_dchapt packages/ft_raytrace/test/test_DCHAPT.f packages/ft_raytrace/src/DCHAPT.f
    @./packages/ft_raytrace/test_dchapt
    @rm packages/ft_raytrace/test_dchapt

test-linear:
    @gfortran -ffixed-form -o packages/ft_raytrace/test_linear packages/ft_raytrace/test/test_LINEAR.f packages/ft_raytrace/src/LINEAR.f
    @./packages/ft_raytrace/test_linear
    @rm packages/ft_raytrace/test_linear

test-qparab:
    @gfortran -ffixed-form -o packages/ft_raytrace/test_qparab packages/ft_raytrace/test/test_QPARAB.f packages/ft_raytrace/src/QPARAB.f
    @./packages/ft_raytrace/test_qparab
    @rm packages/ft_raytrace/test_qparab

test-torus:
    @gfortran -ffixed-form -o packages/ft_raytrace/test_torus packages/ft_raytrace/test/test_TORUS.f packages/ft_raytrace/src/TORUS.f
    @./packages/ft_raytrace/test_torus
    @rm packages/ft_raytrace/test_torus

test-dtorus:
    @gfortran -ffixed-form -o packages/ft_raytrace/test_dtorus packages/ft_raytrace/test/test_DTORUS.f packages/ft_raytrace/src/DTORUS.f
    @./packages/ft_raytrace/test_dtorus
    @rm packages/ft_raytrace/test_dtorus

test-trough:
    @gfortran -ffixed-form -o packages/ft_raytrace/test_trough packages/ft_raytrace/test/test_TROUGH.f packages/ft_raytrace/src/TROUGH.f
    @./packages/ft_raytrace/test_trough
    @rm packages/ft_raytrace/test_trough

test-shock:
    @gfortran -ffixed-form -o packages/ft_raytrace/test_shock packages/ft_raytrace/test/test_SHOCK.f packages/ft_raytrace/src/SHOCK.f
    @./packages/ft_raytrace/test_shock
    @rm packages/ft_raytrace/test_shock

test-wave:
    @gfortran -ffixed-form -o packages/ft_raytrace/test_wave packages/ft_raytrace/test/test_WAVE.f packages/ft_raytrace/WAVE.f
    @./packages/ft_raytrace/test_wave
    @rm packages/ft_raytrace/test_wave

test-wave2:
    @gfortran -ffixed-form -o packages/ft_raytrace/test_wave2 packages/ft_raytrace/test/test_WAVE2.f packages/ft_raytrace/WAVE2.f
    @./packages/ft_raytrace/test_wave2
    @rm packages/ft_raytrace/test_wave2

test-doppler:
    @gfortran -ffixed-form -o packages/ft_raytrace/test_doppler packages/ft_raytrace/test/test_DOPPLER.f packages/ft_raytrace/src/DOPPLER.f
    @./packages/ft_raytrace/test_doppler
    @rm packages/ft_raytrace/test_doppler

# --- Test Aliases ---

# Run all fortran tests
test: test-elect1 test-expx test-bulge test-gausel test-tablex test-chapx test-vchapx test-dchapt test-linear test-qparab test-torus test-dtorus test-trough test-shock test-wave test-wave2 test-doppler

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