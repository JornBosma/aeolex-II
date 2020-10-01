% Analysis of total time-averaged dataset
% Jorn Bosma - November, 2019

%% Initialisation
close all
clear
clc

AeolusInit

% load dt-unitt averaged data
dt = 10;          % 1, 5, 10 or 30
unitt = 'm';     % s(econds) or m(inutes)

for n = 2:4
    data(n) = load(['SDS-UA(',num2str(n),')_',num2str(dt),unitt]);
    ossi(n) = load(['OSSI','_',num2str(dt),unitt]);
end

ossi(2).T_mean.AeolusTime = ossi(2).T_mean.AeolusTime + 91;
ossi(3).T_mean.AeolusTime = ossi(3).T_mean.AeolusTime + 65;
ossi(4).T_mean.AeolusTime = ossi(4).T_mean.AeolusTime + 0;
for n = 2:4
    data(n).T_mean = outerjoin(data(n).T_mean,ossi(n).T_mean,'Type','left','MergeKeys',true);
end

% combine data
data(1).T_mean = [data(2).T_mean; data(3).T_mean; data(4).T_mean]; % mean of each time bin
data(1).T_std = [data(2).T_std; data(3).T_std; data(4).T_std];     % standard deviation of each time bin
data(1).T_wind = [data(2).T_wind; data(3).T_wind; data(4).T_wind]; % wind statistics for each time bin

% assign variables
for n = 1:4
    t{n} = data(n).T_mean.AeolusTime;   % elapsed time since start first deployment [s]

    q{n} = data(n).T_mean{:,2:33};      % saltation intensity (horizontal array) [counts/s]
    q_std{n} = data(n).T_std{:,2:33};   % std. of saltation intensity (horizontal array) [counts/s]
    mu{n} = nanmean(q{n},2);            % spanwise mean saltation intensity [counts/s]
    sigma{n} = nanmean(q_std{n},2);     % mean temporal std. of saltation intensity [counts/s]
    sigma_y{n} = nanstd(q{n},[],2);     % spanwise std. of saltation intensity [counts/s]
    cv_t{n} = q_std{n}./q{n}.*100;      % coefficient of variation (temporal) [%]
    CV_t{n} = nanmean(cv_t{n}(:,5:7),2);       % mean coefficient of variation (temporal) [%]
    qv{n} = data(n).T_mean{:,34:41};    % saltation intensity (vertical array) [counts/s]

    speed{n} = data(n).T_wind.speed;    % mean wind speed (uvw) [m/s]
    shear{n} = data(n).T_wind.shear;    % shear velocity (for z0=1e-4) [m/s]
    dir{n} = data(n).T_wind.dir;        % wind direction [°]
    tke{n} = data(n).T_wind.tke;        % turbulence kinetic energy [m^2/s^2] or [J/kg]
    gust{n} = data(n).T_wind.gust;      % wind gust magnitude [m/s]
    nap{n} = data(n).T_mean.WaterLevel;    % water nap [m]

    cv_y{n} = sigma_y{n}./mu{n}.*100;     % coefficient of variation (spanwise) [%]
    cv_k{n} = sqrt(tke{n})./speed{n}.*100; % coefficient of variation (wind) [%]
end

Z = [.035 .09 .155 .21 .275 .34 .585 .725]'; % sensor height above surface [m]

% conditional statements
along = dir{1}<=7.2 | dir{1}>=347.2 | (dir{1}<=207.2 & dir{1}>=187.2);
obliq = (dir{1}>297.2 & dir{1}<347.2) | (dir{1}<257.2 & dir{1}>207.2);
cross = dir{1}<=297.2 & dir{1}>=257.2;

%% Plot 1
figure2
scatter(shear{1}(along),mu{1}(along),100,nap{1}(along),'^','LineWidth',1.5); hold on
scatter(shear{1}(obliq),mu{1}(obliq),100,nap{1}(obliq),'o','LineWidth',1.5);
scatter(shear{1}(cross),mu{1}(cross),100,nap{1}(cross),'x','LineWidth',1.5); hold off
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
% OK = mu{1}>=10 & (along | (obliq & nap{1}<=0.1));
% 
% x = shear{1}(OK);
% y = mu{1}(OK);
% 
% X = log10(x); 
% Y = log10(y);  % convert both variables to log's
% 
% % cftool(X,Y)
% 
% fit = 950.605*shear{1}(OK).^(4.065999999999999);
% % con1 = 711.214*shear{1}(OK).^(3.690000000000000);
% % con2 = 1270.57*shear{1}(OK).^(4.442);
% 
% figure2
% scatter(x,y,100, 'LineWidth', 2); hold on
% line(x,fit,'LineStyle', '-', 'Color', 'r', 'LineWidth', 4)
% % line(x,con1,'LineStyle', ':', 'Color', [0 .5 0])
% % line(x,con2,'LineStyle', ':', 'Color', [0 .5 0])
% ax = gca;
% ax.YScale = 'log';
% ax.XScale = 'log';
% xlabel '$u_*$ ($m\,s^{-1}$)'
% ylabel '$\overline{\mu}_y$ ($cnts\,s^{-1}$)'
% str = "C\,$u_*^{\,4.07}$";
% str = str + newline + "$R^{2}$ = 0.80";
% text(0.53,30,str,'FontSize',34)
% grid on
% axis square

%% Plot 3
% figure2
% scatter(tke{1},mu{1},100,'LineWidth',1.5)
% % xline(0.26,'--','Color',[.5 .5 .5],'LineWidth',4) % 1-min
% % text(0.02,130,'$k_{t} \approx \; 0.26\,m^{2}\,s^{-2}$','FontSize',36,'Color',[.5 .5 .5])
% % xline(0.48,'--','Color',[.5 .5 .5],'LineWidth',4) % 10-min
% % text(0.24,110,'$k_{t} \approx \; 0.48\,m^{2}\,s^{-2}$','FontSize',36,'Color',[.5 .5 .5])
% % xline(0.55,'--','Color',[.5 .5 .5],'LineWidth',4) % 30-min
% % text(0.31,110,'$k_{t} \approx \; 0.55\,m^{2}\,s^{-2}$','FontSize',36,'Color',[.5 .5 .5])
% xlim([0 2])
% ylim([0 150])
% xlabel '$k$ ($m^{2}\,s^{-2}$)'
% ylabel '$\overline{\mu}_y$ ($cnts\,s^{-1}$)'
% axis square
% % set(gca,'YTickLabel',[]);
% % set(gca,'YLabel',[]);
% % set(gca,'XTickLabel',[]);
% % set(gca,'XLabel',[]);

%% Plot 4
% OK1 = isfinite(cv_k{1}) & isfinite(CV_t{1});
% OK2 = isfinite(cv_k{1}) & isfinite(cv_y{1});
% 
% figure2
% scatter(cv_k{1}(OK1),CV_t{1}(OK1),100,'LineWidth',1.5)
% xlim([10 20])
% ax = gca;
% ax.YScale = 'log';
% % ax.XScale = 'log';
% xlabel '$CV_{k}$ ($\%$)'
% ylabel '$CV$ ($\%$)'
% axis square
% 
% figure2
% scatter(cv_k{1}(OK2),cv_y{1}(OK2),100,'LineWidth',1.5)
% xlim([10 20])
% ax = gca;
% ax.YScale = 'log';
% % ax.XScale = 'log';
% xlabel '$CV_{k}$ ($\%$)'
% ylabel '$CV_{y}$ ($\%$)'
% axis square
% 
% OK4 = isfinite(shear{1}) & isfinite(CV_t{1});
% OK5 = isfinite(shear{1}) & isfinite(cv_y{1});
% 
% figure2
% scatter(shear{1}(OK4),CV_t{1}(OK4),100,'LineWidth',1.5)
% ax = gca;
% ax.YScale = 'log';
% % ax.XScale = 'log';
% xlabel '$u_*$ ($m\,s^{-1}$)'
% ylabel '$CV$ ($\%$)'
% axis square
% 
% figure2
% scatter(shear{1}(OK5),cv_y{1}(OK5),100,'LineWidth',1.5)
% ax = gca;
% ax.YScale = 'log';
% % ax.XScale = 'log';
% xlabel '$u_*$ ($m\,s^{-1}$)'
% ylabel '$CV_{y}$ ($\%$)'
% axis square

%% Plot 5
% OK = mu{1}>10 & isfinite(cv_t{1});
% % cftool(log10(mu{1}(:)),log10(cv_t{1}(:)))
% 
% [fitresult1, gof1] = cvVmean(log10(mu{1}(:)),log10(cv_t{1}(:)));
% str = ['$R^{2}$ = ',num2str(gof1.rsquare,'%.2f')];
% text(nanmedian(log10(mu{1}(:)))-4,nanmedian(log10(cv_t{1}(:)))+.7,str,'FontSize',36)

%% Plot 6
% for n = 1:4
%     for dy = 1:size(q{n},2)-1
%         finishNow = false;
%         for y = 1:size(q{n},2)-1
%             if finishNow
%                 fprintf('limit reached for dy = %i\n',dy)
%                 break % jump to next dy-iteration
%             end
%             for r = 1:size(q{n},1)
%                 if any(isnan(q{n}(r,[y y+1])))
%                     cov{dy,n}(r,y) = NaN;
%                 else
%                     try
%                         cov{dy,n}(r,y) = nanstd(q{n}(r,[y y+dy])/nanmean(q{n}(r,[y y+dy])))*100;
%                     catch
%                         finishNow = true;
%                         break % jump to next y-iteration
%                     end
%                 end
%             end
%         end
%         cov_mean{dy,n} = nanmean(cov{dy,n},2);
%     end
% end
% 
% % cftool(X,Y,Z)
% 
% [X,Y] = meshgrid(shear{4}, .1:.1:3.1);
% 
% Z = X;
% for p = 1:31
%     Z(p,:) = cov_mean{p,4};
% end
% 
% COVspanFit(X(Z>0),Y(Z>0),Z(Z>0))

%% Smoothing
% % span = .07;
% % method = 'lowess'; % Local regression using weighted linear least squares 
%                       % and a 1st degree polynomial model
% span = 5;
% method = 'moving'; % Moving average. A lowpass filter with filter 
%                     % coefficients equal to the reciprocal of the span.
% 
% qs = q;
% mus = mu;
% tkes = tke;
% for n = 1:4
%     for p = 1:32
%         if isnan(q{n}(:,p))
%             qs{n}(:,p) = NaN;
%         else
%             qs{n}(:,p) = smooth(q{n}(:,p),span,method);  % first smooth columns
%         end
%     end
%     mus{n} = nanmean(qs{n},2);
% 
%     tkes{n} = smooth(tke{n},span,method);
% 
%     [TKE{n},MU{n},D(n)] = alignsignals(tkes{n},mus{n},[],'truncate');
%     TKE{n} = TKE{n}(D(n)+1:end);
%     MU{n} = MU{n}(D(n)+1:end);
% end

%% Conditional plotting
% figure2 % +NAP
% scatter(mu{1}(along),cv_t{1}(along),100,nap{1}(along),'^','LineWidth',1.5); hold on
% scatter(mu{1}(obliq),cv_t{1}(obliq),100,nap{1}(obliq),'o','LineWidth',1.5);
% scatter(mu{1}(cross),cv_t{1}(cross),100,nap{1}(cross),'x','LineWidth',1.5); hold off
% ax = gca;
% ax.YScale = 'log';
% ax.XScale = 'log';
% colormap('jet')
% cb = colorbar;
% cb.FontSize = 36;
% cb.Label.Interpreter = 'latex';
% cb.TickLabelInterpreter = 'latex';
% cb.Label.String = '$\zeta_{tide}$ ($m$ +NAP)';
% xlabel '$\overline{\mu}_y$ ($cnts\,s^{-1}$)'
% ylabel '$CV$ ($\%$)'
% legend 'alongshore' 'oblique' 'cross-shore'
% axis square

%% Vertical sensor array
% QV = nanmean(qv{1})'./nanmax(nanmean(qv{1})).*100;
% 
% figure2
% plot(QV,Z,...
%     '-co',...
%     'LineWidth',5,...
%     'MarkerSize',15,...
%     'MarkerEdgeColor','b',...
%     'MarkerFaceColor',[0.5,0.5,0.5])
% line([0 max(xlim)],[.1 .1],...
%     'LineStyle','--',...
%     'LineWidth',3,...
%     'Color','r')
% yticks(Z)
% xlabel '$\mu_{0.035m}$ ($\%$)'
% ylabel 'h.a.b. ($m$)'
% grid on
% box off
% % axis square

%% Sensor sensitivity
% Q2 = q{2}(~any(isnan(q{2}(:,[1:24 26 28:32])), 2), :);  % exclude 25 and 27
% Q3 = q{3}(~any(isnan(q{3}(:,[1:14 16:32])), 2), :);     % exclude 15
% Q4 = q{4}(~any(isnan(q{4}(:,[1:18 20:32])), 2), :);     % exclude 19
% 
% figure2
% s(1) = scatter(1:32,nanmean(Q2),100,'LineWidth',3,...
%     'MarkerEdgeColor','r',...
%     'MarkerFaceColor','w'); hold on
% line([1 32],[nanmean(nanmean(Q2)) nanmean(nanmean(Q2))],...
%     'LineStyle',':','Color','r','LineWidth',3);
% s(2) = scatter(1:32,nanmean(Q3),100,'LineWidth',3,...
%     'MarkerEdgeColor','b',...
%     'MarkerFaceColor','w');
% line([1 32],[nanmean(nanmean(Q3)) nanmean(nanmean(Q3))],...
%     'LineStyle',':','Color','b','LineWidth',3);
% s(3) = scatter(1:32,nanmean(Q4),100,'LineWidth',3,...
%     'MarkerEdgeColor',[0 .5 0],...
%     'MarkerFaceColor','w');
% line([1 32],[nanmean(nanmean(Q4)) nanmean(nanmean(Q4))],...
%     'LineStyle',':','Color',[0 .5 0],'LineWidth',3);
% ylim([0 max(ylim)+5])
% xlim([0 33])
% ax = gca;
% set(ax,'XTick',1:32)
% xtickangle(45)
% legend([s(1) s(2) s(3)],'SDS$_2$','SDS$_3$','SDS$_4$','Location','northeast','NumColumns',3)
% legend('boxon')
% xlabel 'sensor number'
% ylabel '$\mu$ ($cnts\,s^{-1}$)'
% % ylabel 'cnts s\textsuperscript{-1}'
% str = {['$\mu_y$ = ',num2str(nanmean(nanmean(Q2)),'%.2f')],['$\sigma_y$ = ',...
%     num2str(nanstd(nanmean(Q2)),'%.2f')]};
% text(15,nanmean(nanmean(Q2))+6,str,'Color','r','FontSize',36)
% str = {['$\mu_y$ = ',num2str(nanmean(nanmean(Q3)),'%.2f')],['$\sigma_y$ = ',...
%     num2str(nanstd(nanmean(Q3)),'%.2f')]};
% text(15,nanmean(nanmean(Q3))-7,str,'Color','b','FontSize',36)
% str = {['$\mu_y$ = ',num2str(nanmean(nanmean(Q4)),'%.2f')],['$\sigma_y$ = ',...
%     num2str(nanstd(nanmean(Q4)),'%.2f')]};
% text(15,nanmean(nanmean(Q4))-7,str,'Color',[0 .5 0],'FontSize',36)
