addpath('/home/andrew/code/raytracing/pharlap_4.7.4/src/C');
foF2 = 10.0;
hmF2 = 250.0;
ymF2 = 75.0;
freq_mhz = 15.0;
origin_lat = -20.0;
origin_long = 130.0;
elevs = [5, 10, 15, 20, 25, 30, 35, 40, 50, 60, 70, 80];
freqs = ones(size(elevs)) * freq_mhz;
tol = [1e-8 0.01 2];
ht_start = 60;
ht_inc = 1;
num_ht = 500;
num_range = 200;
range_inc = 20;
height_arr = ht_start : ht_inc : ht_start + (num_ht-1)*ht_inc;
iono_en_grid = zeros(num_ht, num_range);
iono_en_grid_5 = zeros(num_ht, num_range);
collision_freq = zeros(num_ht, num_range);
irreg = zeros(4, num_range);
for jj = 1:num_ht
  h = height_arr(jj);
  z = (h - hmF2) / ymF2;
  zt = z;
  if zt > 30; zt = 30; end
  if zt < -30; zt = 30; end
  fp2 = foF2^2 * exp(0.5 * (1.0 - zt - exp(-zt)));
  Ne = fp2 * 1.24e4;
  if Ne < 0; Ne = 0; end
  for ii = 1:num_range
    iono_en_grid(jj, ii) = Ne;
    iono_en_grid_5(jj, ii) = Ne;
  end
end
nhops = 1;
irregs_flag = 0;
bearing = 0;
fprintf('Running PHaRLAP raytrace_2d with %d rays at %.0f MHz...\n\n', length(elevs), freq_mhz);
[ray_data, ray_path_data] = raytrace_2d(origin_lat, origin_long, elevs, bearing, freqs, nhops, tol, irregs_flag, iono_en_grid, iono_en_grid_5, collision_freq, ht_start, ht_inc, range_inc, irreg);
fprintf('elev,ground_range_km,group_range_km,max_height_km,returned\n');
fid = fopen('pharlap_reference.csv', 'w');
fprintf(fid, 'elev,ground_range_km,group_range_km,max_height_km,returned\n');
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
  fprintf('%.1f,%.4f,%.4f,%.4f,%d\n', elevs(ii), gr, grp, max_ht, returned);
  fprintf(fid, '%.1f,%.4f,%.4f,%.4f,%d\n', elevs(ii), gr, grp, max_ht, returned);
end
fclose(fid);
fprintf('\nResults written to pharlap_reference.csv\n');
