addpath('/home/andrew/code/raytracing/pharlap_4.7.4/src/C');

tol = [1e-8 0.01 2];
nhops = 1;
irregs_flag = 0;
bearing = 0;

tests = {
  'equator_standard',    0, 15, 10, 250, 75;
  'midlat_standard',   -20, 15, 10, 250, 75;
  'highlatN',           65, 15, 10, 250, 75;
  'highlatS',          -65, 15, 10, 250, 75;
  'near_critical',     -20, 11, 10, 250, 75;
  'well_above_crit',   -20, 25, 10, 250, 75;
  'strong_iono',       -20, 15, 15, 300, 100;
  'weak_iono',         -20, 15,  5, 200, 50;
  'thick_layer',       -20, 15, 10, 250, 150;
  'thin_layer',        -20, 15, 10, 250, 40;
  'low_peak',          -20, 15, 10, 180, 75;
  'high_peak',         -20, 15, 10, 350, 75;
};

elevs = [3, 5, 10, 15, 20, 25, 30, 35, 40, 50, 60, 70, 80, 85];

fid = fopen('pharlap_stress_results.csv', 'w');
fprintf(fid, 'test_name,lat,freq,foF2,hmF2,ymF2,elev,ground_range_km,group_range_km,max_height_km,returned\n');

for tt = 1:size(tests,1)
  test_name = tests{tt,1}; lat = tests{tt,2}; freq = tests{tt,3};
  foF2 = tests{tt,4}; hmF2 = tests{tt,5}; ymF2 = tests{tt,6};
  fprintf('=== %s: lat=%d, freq=%d, foF2=%d, hmF2=%d, ymF2=%d ===\n', test_name, lat, freq, foF2, hmF2, ymF2);

  freqs_arr = ones(size(elevs)) * freq;
  
  ht_start = 0;
  ht_inc = 1;
  num_ht = 600;
  num_range = 200;
  range_inc = 20;
  height_arr = ht_start : ht_inc : ht_start + (num_ht-1)*ht_inc;

  iono_en_grid = zeros(num_ht, num_range);
  iono_en_grid_5 = zeros(num_ht, num_range);
  collision_freq_grid = zeros(num_ht, num_range);
  irreg = zeros(4, num_range);

  for jj = 1:num_ht
    h = height_arr(jj);
    zt = max(min((h - hmF2) / ymF2, 30), -30);
    Ne = foF2^2 * exp(0.5 * (1.0 - zt - exp(-zt))) * 1.24e4;
    for ii = 1:num_range
      iono_en_grid(jj, ii) = Ne;
      iono_en_grid_5(jj, ii) = Ne;
    end
  end

  [ray_data, ray_path_data] = raytrace_2d(lat, 130, elevs, bearing, freqs_arr, nhops, tol, irregs_flag, iono_en_grid, iono_en_grid_5, collision_freq_grid, ht_start, ht_inc, range_inc, irreg);

  for ii = 1:length(elevs)
    label = ray_data(ii).ray_label;
    returned = (label == 1);
    if returned
      gr = ray_data(ii).ground_range;
      grp = ray_data(ii).group_range;
      max_ht = ray_data(ii).apogee;
    else
      gr = 0.0;
      grp = 0.0;
      max_ht = max(ray_path_data(ii).height);
    end
    fprintf(fid, '%s,%d,%d,%d,%d,%d,%.1f,%.4f,%.4f,%.4f,%d\n', test_name, lat, freq, foF2, hmF2, ymF2, elevs(ii), gr, grp, max_ht, returned);
  end
end
fclose(fid);
fprintf('\nAll results written to pharlap_stress_results.csv\n');
