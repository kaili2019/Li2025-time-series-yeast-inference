% this script simulates colonies based on the parameters inferred from SNLE
% 
% Kai Li
% 05 June 2025

clear
clc
close all

rng(1)

load("AWRI_796_ss.mat")
idx = 1;
parameters = readmatrix("samples_full_AWRI796_50um_s1.csv");

save_colony = cell(10,1);
N = 65000;
cc = 1;

for p2s_val = 0.1:0.1:1

    Telong = mean(parameters(:,1));
    p2sProb = p2s_val;
    s2pProb = mean(parameters(:,3));
    pc = mean(parameters(:,4));
    pa = mean(parameters(:,5));
    
    I = imread("colony_AWRI796_50um_s1_05June2025_p2s="+p2s_val+".png");

    text_str = "n* = "+round(Telong*N/38097,2)+" Pps = "+round(p2sProb,2)+" Psp = "+round(s2pProb,2) ...
      + " gamma = "+round(pc,2)+" pa = "+round(pa,2);

    save_colony{cc} = insertText(I,[0,0],text_str,FontSize=36,TextBoxColor='b', ...
    BoxOpacity=0.0,TextColor="white");
    
    cc = cc+1;
end

%%
clc
figure('Position',[1 1 1000 1000])
montage(save_colony,'size',[10 1],'ThumbnailSize',[1000 inf])

% exportgraphics(gcf,'AWRI_796_50um_vary_pps_05June2025.png','Resolution',200)