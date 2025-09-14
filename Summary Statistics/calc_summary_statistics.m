% this script load data of (x,y) position of colonies into MATLAB and
% calculate their associated summary statistics 
%
% data is on maths1 > v1_manuscript/AWRI796 50um/v1_04Mar2025
% 
% Kai Li
% 26 May 2025

clear
clc
close all

% load guess for number of cells
load("mean_num_cells.mat")

% load target area
load("AWRI_area_6.mat")

% load simulations from simulations: load from simulations 
load("simulation_example.mat")
samples1 = samples(1:100,:);

samples_combined = samples1;

parameters = vertcat(samples_combined{:,3});
%%
disp("Data Loaded!")
N = length(samples_combined);
Tslices = length(mean_num_cells);
outer_area = nan(N,Tslices);
total_area = nan(N,Tslices);
compactness = nan(N,Tslices);
rmin = nan(N,Tslices);
rmax = nan(N,Tslices);
rmean = nan(N,Tslices);
branch_count = nan(N,Tslices);
branch_length = nan(N,Tslices);
store_file_name = cell(N,1);

tic
kk = 1;
for ii = 1:N
    xF = samples_combined{ii,1};
    yF = samples_combined{ii,2};
    
    Ncells = nan(1,8);
    min_cell = 1;
    max_cell = 45000;
    
    for kk = 1:8
        Ncells(kk) = get_n_cells(min_cell,max_cell,xF,yF,AWRI_area_6(kk));
    end

    cc = 1;
    
    for tt = Ncells
        x = xF(1:tt,:);
        y = yF(1:tt,:);
        
        Telong = round(samples_combined{ii,3}(1),3);
        p2sProb = round(samples_combined{ii,3}(2),3);
        s2pProb = round(samples_combined{ii,3}(3),3);
        pc = round(samples_combined{ii,3}(4),3);
        pa = round(samples_combined{ii,3}(5),3);
        
        % saving colony as tiff
        file_name = "S"+ii+"_N="+tt+"_Telong="+Telong+"_p2sProb="+p2sProb+"_s2pProb="...
                    +s2pProb+"_pc="+pc+"_pa="+pa; 

        % save colony as matrix
        [I_hist,~,~] = histcounts2(x+600, y+800,0:4:1200,0:4:1600);
        I = imresize(I_hist,4)>0.5;
        I = ~bwareaopen(~I, 10); % fill gaps in colony that has 10 or less pixels

        [outer_area(ii,cc), total_area(ii,cc)] = get_colony_area_rmean(I);
        compactness(ii,cc) = get_compactness(I);
        [~, ~, rmin(ii,cc), rmax(ii,cc), rmean(ii,cc)] = get_radii_rmean(I);
        [branch_count(ii,cc), branch_length(ii,cc)] = get_branch_length_rmean(I);

        cc = cc+1;

    end
    store_file_name{ii} = file_name;
    kk = kk+1;
    if mod(ii,2) == 0
        fprintf("%0.2f completed and took %0.2f\n",ii/N*100,toc)
    end
end
toc

%%
save("ss_AWRI50um_"+datestr(datetime(now,'ConvertFrom','datenum'))+".mat",...
    "branch_count","branch_length",'parameters','rmax','rmin', 'rmean',...
    'compactness',"total_area","outer_area","store_file_name");