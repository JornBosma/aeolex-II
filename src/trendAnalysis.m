% Trend analysis of total time-averaged dataset
% Jorn Bosma - November, 2019
% Jorn Bosma - October, 2020 (recoworkshop)

%% Initialisation
close all
clear
clc

AeolusInit

% load dt-unitt averaged data
dt = 10;
unitt = 'm'; % m(inutes)

for n = 2:4
    data(n) = load(['SDS-UA(', num2str(n), ')_', num2str(dt), unitt]);
    ossi(n) = load(['OSSI', '_', num2str(dt), unitt]);
end

ossi(2).T_mean.AeolusTime = ossi(2).T_mean.AeolusTime + 91;
ossi(3).T_mean.AeolusTime = ossi(3).T_mean.AeolusTime + 65;
ossi(4).T_mean.AeolusTime = ossi(4).T_mean.AeolusTime + 0;
for n = 2:4
    data(n).T_mean = outerjoin(data(n).T_mean, ossi(n).T_mean, 'Type', 'left', 'MergeKeys', true);
end

% combine data
data(1).T_mean = [data(2).T_mean; data(3).T_mean; data(4).T_mean]; % mean of each time bin
data(1).T_std = [data(2).T_std; data(3).T_std; data(4).T_std]; % standard deviation of each time bin
data(1).T_wind = [data(2).T_wind; data(3).T_wind; data(4).T_wind]; % wind statistics for each time bin

% assign variables
for n = 1:4
    t{n} = data(n).T_mean.AeolusTime; % elapsed time since start first deployment [s]

    q{n} = data(n).T_mean{:, 2:33}; % saltation intensity (horizontal array) [counts/s]
    q_std{n} = data(n).T_std{:, 2:33}; % std. of saltation intensity (horizontal array) [counts/s]
    mu{n} = nanmean(q{n}, 2); % spanwise mean saltation intensity [counts/s]
    sigma{n} = nanmean(q_std{n}, 2); % mean temporal std. of saltation intensity [counts/s]
    sigma_y{n} = nanstd(q{n}, [], 2); % spanwise std. of saltation intensity [counts/s]
    cv_t{n} = q_std{n} ./ q{n} .* 100; % coefficient of variation (temporal) [%]
    CV_t{n} = nanmean(cv_t{n}(:, 5:7), 2); % mean coefficient of variation (temporal) [%]
    qv{n} = data(n).T_mean{:, 34:41}; % saltation intensity (vertical array) [counts/s]

    speed{n} = data(n).T_wind.speed; % mean wind speed (uvw) [m/s]
    shear{n} = data(n).T_wind.shear; % shear velocity (for z0=1e-4) [m/s]
    dir{n} = data(n).T_wind.dir; % wind direction [°]
    tke{n} = data(n).T_wind.tke; % turbulence kinetic energy [m^2/s^2] or [J/kg]
    gust{n} = data(n).T_wind.gust; % wind gust magnitude [m/s]
    nap{n} = data(n).T_mean.WaterLevel; % water nap [m]

    cv_y{n} = sigma_y{n} ./ mu{n} .* 100; % coefficient of variation (spanwise) [%]
    cv_k{n} = sqrt(tke{n}) ./ speed{n} .* 100; % coefficient of variation (wind) [%]
end

Z = [.035, .09, .155, .21, .275, .34, .585, .725]'; % sensor height above surface [m]

% conditional statements
along = dir{1} <= 7.2 | dir{1} >= 347.2 | (dir{1} <= 207.2 & dir{1} >= 187.2);
obliq = (dir{1} > 297.2 & dir{1} < 347.2) | (dir{1} < 257.2 & dir{1} > 207.2);
cross = dir{1} <= 297.2 & dir{1} >= 257.2;

%% Plot 1
figure2
scatter(shear{1}(along), mu{1}(along), 100, nap{1}(along), '^', 'LineWidth', 1.5); hold on
scatter(shear{1}(obliq), mu{1}(obliq), 100, nap{1}(obliq), 'o', 'LineWidth', 1.5);
scatter(shear{1}(cross), mu{1}(cross), 100, nap{1}(cross), 'x', 'LineWidth', 1.5); hold off
colormap('jet')
cb = colorbar;
cb.FontSize = 36;
cb.Label.Interpreter = 'latex';
cb.TickLabelInterpreter = 'latex';
cb.Label.String = '$\zeta_{tide}$ ($m$ +NAP)';
xlabel '$u_*$ ($m\,s^{-1}$)'
ylabel '$\overline{\mu}_y$ ($cnts\,s^{-1}$)'
legend 'alongshore' 'oblique' 'cross-shore'
axis square

%% Plot 2
OK = mu{1} >= 10 & (along | (obliq & nap{1} <= 0.1));

x = shear{1}(OK);
y = mu{1}(OK);

X = log10(x);
Y = log10(y); % convert both variables to log's

fit = 950.605 * shear{1}(OK).^(4.065999999999999);

figure2
scatter(x, y, 100, 'LineWidth', 2); hold on
line(x, fit, 'LineStyle', '-', 'Color', 'r', 'LineWidth', 4)
ax = gca;
ax.YScale = 'log';
ax.XScale = 'log';
xlabel '$u_*$ ($m\,s^{-1}$)'
ylabel '$\overline{\mu}_y$ ($cnts\,s^{-1}$)'
str = "C\,$u_*^{\,4.07}$";
str = str + newline + "$R^{2}$ = 0.80";
text(0.53, 30, str, 'FontSize', 34)
grid on
axis square

%% Vertical sensor array
QV = nanmean(qv{1})' ./ nanmax(nanmean(qv{1})) .* 100;

figure2
plot(QV, Z, ...
    '-co', ...
    'LineWidth', 5, ...
    'MarkerSize', 15, ...
    'MarkerEdgeColor', 'b', ...
    'MarkerFaceColor', [0.5, 0.5, 0.5])
line([0, max(xlim)], [.1, .1], ...
    'LineStyle', '--', ...
    'LineWidth', 3, ...
    'Color', 'r')
yticks(Z)
xlabel '$\mu_{0.035m}$ ($\%$)'
ylabel 'h.a.b. ($m$)'
grid on
box off
axis square

%% Sensor sensitivity
Q2 = q{2}(~any(isnan(q{2}(:, [1:24, 26, 28:32])), 2), :); % exclude 25 and 27
Q3 = q{3}(~any(isnan(q{3}(:, [1:14, 16:32])), 2), :); % exclude 15
Q4 = q{4}(~any(isnan(q{4}(:, [1:18, 20:32])), 2), :); % exclude 19

figure2
s(1) = scatter(1:32, nanmean(Q2), 100, 'LineWidth', 3, ...
    'MarkerEdgeColor', 'r', ...
    'MarkerFaceColor', 'w'); hold on
line([1, 32], [nanmean(nanmean(Q2)), nanmean(nanmean(Q2))], ...
    'LineStyle', ':', 'Color', 'r', 'LineWidth', 3);
s(2) = scatter(1:32, nanmean(Q3), 100, 'LineWidth', 3, ...
    'MarkerEdgeColor', 'b', ...
    'MarkerFaceColor', 'w');
line([1, 32], [nanmean(nanmean(Q3)), nanmean(nanmean(Q3))], ...
    'LineStyle', ':', 'Color', 'b', 'LineWidth', 3);
s(3) = scatter(1:32, nanmean(Q4), 100, 'LineWidth', 3, ...
    'MarkerEdgeColor', [0, .5, 0], ...
    'MarkerFaceColor', 'w');
line([1, 32], [nanmean(nanmean(Q4)), nanmean(nanmean(Q4))], ...
    'LineStyle', ':', 'Color', [0, .5, 0], 'LineWidth', 3);
ylim([0, max(ylim) + 5])
xlim([0, 33])
ax = gca;
set(ax, 'XTick', 1:32)
xtickangle(45)
legend([s(1), s(2), s(3)], 'SDS$_2$', 'SDS$_3$', 'SDS$_4$', 'Location', 'northeast', 'NumColumns', 3)
legend('boxon')
xlabel 'sensor number'
ylabel '$\mu$ ($cnts\,s^{-1}$)'
str = {['$\mu_y$ = ', num2str(nanmean(nanmean(Q2)), '%.2f')], ['$\sigma_y$ = ', ...
    num2str(nanstd(nanmean(Q2)), '%.2f')]};
text(15, nanmean(nanmean(Q2))+6, str, 'Color', 'r', 'FontSize', 36)
str = {['$\mu_y$ = ', num2str(nanmean(nanmean(Q3)), '%.2f')], ['$\sigma_y$ = ', ...
    num2str(nanstd(nanmean(Q3)), '%.2f')]};
text(15, nanmean(nanmean(Q3))-7, str, 'Color', 'b', 'FontSize', 36)
str = {['$\mu_y$ = ', num2str(nanmean(nanmean(Q4)), '%.2f')], ['$\sigma_y$ = ', ...
    num2str(nanstd(nanmean(Q4)), '%.2f')]};
text(15, nanmean(nanmean(Q4))-7, str, 'Color', [0, .5, 0], 'FontSize', 36)
