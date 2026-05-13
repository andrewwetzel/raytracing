addpath('/home/andrew/code/raytracing/pharlap_4.7.4/src/C');
tol = [1e-8 0.01 2]; nhops = 1; irregs_flag = 0; bearing = 0;
lat = -20; elev = 20; freq = 5; foF2 = 10; hmF2 = 250; ymF2 = 150;
ht_start = 60; ht_inc = 1; num_ht = 500; num_range = 200; range_inc = 20;
height_arr = ht_start : ht_inc : ht_start + (num_ht-1)*ht_inc;
iono_en_grid = zeros(num_ht, num_range);
for jj = 1:num_ht
  h = height_arr(jj);
  zt = max(min((h - hmF2) / ymF2, 30), -30);
  iono_en_grid(jj, :) = foF2^2 * exp(0.5 * (1.0 - zt - exp(-zt))) * 1.24e4;
end
fprintf('Grid at 60km: %e \n', iono_en_grid(1,1));
fprintf('Grid at 250km (peak): %e \n', iono_en_grid(191,1));
