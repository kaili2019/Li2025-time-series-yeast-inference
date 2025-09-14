% this script calculates the summary statistic of all time of
% colonies under different conditions and produces boxplot using v2 of the
% summary statistic
% 
% Kai Li
% 22 Jan 2025

clear
clc
% close all

load("post_1.mat")
branch_length_exp = branch_length;
compactness_exp = compactness;
rmax_exp = rmax;
rmean_exp = rmean;
outer_area_exp = outer_area;
total_area_exp = total_area;
idx = 1;

load("post_2.mat")
branch_length_prior = branch_length;
compactness_prior = compactness;
rmax_prior = rmax;
rmean_prior = rmean;
outer_area_prior = outer_area;
total_area_prior = total_area;
parameter_prior = parameters;

load("post_3.mat")
% load("synthetic_single_ss_06-Jun-2025 19:33:35.mat")
branch_length_post = branch_length;
compactness_post = compactness;
rmax_post = rmax;
rmean_post = rmean;
outer_area_post = outer_area;
total_area_post = total_area;
parameter_post = parameters;

%%

figure('Position',[100,100,1800,350])
t = tiledlayout(1,5,'TileIndexing', 'columnmajor');

df_combined_prior = {rmean_prior, rmax_prior, outer_area_prior, total_area_prior, branch_length_prior, compactness_prior};
df_combined_post = {rmean_post, rmax_post, outer_area_post, total_area_post, branch_length_post, compactness_post};
df_labels = {"Mean Radius","Maximum Radius","Filamentous Area","Colony Area",...
             "Branch Length","Compactness"};

df_exp_combined = {rmean_exp, rmax_exp, outer_area_exp, total_area_exp,...
                  branch_length_exp, compactness_exp};

len1 = [73, 97, 121, 145, 169, 193, 212, 233];
% len1 = [25, 49, 73, 97, 121, 145, 169, 193, 212, 233];

% cmap1 = [150,150,150;150,150,150;150,150,150]/255;
% cmap2 = [107,174,214;107,174,214;107,174,214]/255;
% cmap3 = [8,48,107;8,48,107;8,48,107]/255;
cmap1 = [229,245,224;229,245,224;229,245,224]/255;
cmap2 = [161,217,155;161,217,155;161,217,155]/255;
cmap3 = [49,163,84;49,163,84;49,163,84]/255;

ymin = [200 200 0 0 0 0];
ymax = [600 900 2.5*10^5 10*10^5 9000 300];

for ii = [1 2 3 5 6]

    nexttile
    df_post = df_combined_post{ii}(:,3:end);
    df_exp = df_exp_combined{ii}(idx,3:end);
    
    quant1_99CI = quantile(df_post,[0.001 0.999]);
    quant1_95CI = quantile(df_post,[0.05 0.95]);
    % quant1_75CI = quantile(df_post,[0.25 0.75]);
    quant1_90CI = quantile(df_post,[0.25 0.75]);
    
    hold on
    
    h195 = fill([len1, fliplr(len1)], [quant1_99CI(1,:), fliplr(quant1_99CI(2,:))],cmap1(1,:),'LineStyle','none');
    h190 = fill([len1, fliplr(len1)], [quant1_95CI(1,:), fliplr(quant1_95CI(2,:))],cmap2(1,:),'LineStyle','none');
    h175 = fill([len1, fliplr(len1)], [quant1_90CI(1,:), fliplr(quant1_90CI(2,:))],cmap3(1,:),'LineStyle','none');
    
    
    plot(len1, df_exp,'color',[0 0 0],'LineWidth',3)

    plot(len1([4 8]), df_exp([4 8]),'color',[0 0 1],'LineWidth',3,'LineStyle','none',...
        'Marker','o','MarkerSize',12)

    % plot(len1(3), df_exp_mean(3),'o','MarkerSize',30,'LineWidth',3)
    % set(h195,'facealpha',.8)
    % set(h190,'facealpha',.8)
    % set(h175,'facealpha',.8)
    
    xlabel('time (hours)','fontsize',24)
    ylabel(df_labels{ii},'fontsize',24)
    xlim([min(len1)-1,max(len1)+1])
    ylim([ymin(ii),ymax(ii)])
    set(gca,'FontSize',22)
    box on
    
    if ii == 1
        legend([h175, h190, h195], '25\% - 75\%','5.0\% - 95.0\%','0.1\% - 99.9\%','Location','best')
    end

end

% exportgraphics(gcf,'ppc_synethtic_subset_15June2025.pdf','ContentType','vector')