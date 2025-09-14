# This script uses the julia package MixtureDensityNetwork to perform Bayesian inference on
# Filamentous yeast colonies
# 
#
# Kai Li
# 29 May 2025

# load packages
using CSV, Tables
using DataFrames
using Plots
using StatsPlots
using StatsBase
using Flux, Distributions, MixtureDensityNetworks

# load data
logitAWRI50um = CSV.read("ss_AWRI796_500um_04June2025.csv", DataFrame; delim = ',')

logit(x) = @. log(x/(1-x));
invlogit(x) = @. 1/(1+exp(-x));

# Programmatically create the formula
predictor_names = names(logitAWRI50um)[6:end]  

new_data = logitAWRI50um[:,predictor_names]

Y = Matrix(new_data)

X = reshape([logitAWRI50um.nStar; logitAWRI50um.p2sProb; logitAWRI50um.s2pProb; logitAWRI50um.gamma; logitAWRI50um.pa],length(logitAWRI50um.nStar),5)

const epochs = 600
const batchsize = 16
const mixtures = 6
const layers = [64, 64]

model = MixtureDensityNetwork(5, 48, layers, mixtures);

model, report = MixtureDensityNetworks.fit!(model, Matrix((X')), Matrix((Y')); epochs=epochs, opt=Flux.Adam(1e-3), batchsize=batchsize)

plot(1:epochs, report.learning_curve, xlabel="Epochs", ylabel="Loss")

# mean summary statistic values
sel_idx = 1;

ground_truth_50um = CSV.read("ss_AWRI796_500um_exp_9_04June.csv", DataFrame; delim = ',')

ground_truth = ground_truth_50um[sel_idx,predictor_names]

ss_mean_500um = (collect(ground_truth))

target_ss = ss_mean_500um

function likelihood(sample)

    # take slice of likehood from MDN 
    cond = model(reshape(sample, (5,1)))[1] 
    # evaluate the summary statistics values at pdf 
    likelihood_val = pdf(cond,target_ss)

    return likelihood_val

end

# Beta (uniform) prior densities 
A = [1, 1, 1, 1, 1]; 
B = [1, 1, 1, 1, 1];

# sample from prior 
function prior(sample)

    Beta_prior = pdf.(Beta.(A,B),reshape(invlogit(sample),5,1));
    # inverse logit Jacobian
    Jacobian = exp.(-(sample)) ./ (exp.(-(sample)) .+ 1).^2;

    return prod(Beta_prior.*Jacobian);

end

function post_sample(sample)
    likelihood(sample)*(prior(sample));
end

# number of samples to take 
N = 200000;
# matrix to store samples of theta 
samples = Matrix{Float64}(undef,N,5); 
samples[1,:] = logit([0.5, 0.5, 0.5, 0.5, 0.5]);
store_alpha = Matrix{Float64}(undef,N,1);

store_proposal = Matrix{Float64}(undef,N,5); 
store_proposal[1,:] = samples[1,:];

# MCMC sampler 
for ii = 2:N 

    # sample from proposal 
    proposal_thetaStar = rand.(Normal.(samples[ii-1,:], 1));
    store_proposal[ii,:] = proposal_thetaStar;

    # calculate acceptance probability  
    numerator = post_sample(proposal_thetaStar);
    
    denominator = post_sample(samples[ii-1,:]);

    alpha = minimum([1,numerator[1]/denominator[1]]);

    store_alpha[ii-1] = alpha;
    
    # accept with probability alpha 
    if rand() < alpha 
        samples[ii,:] = proposal_thetaStar;
    else
        samples[ii,:] = samples[ii-1,:];
    end

end

stephist(invlogit(samples),alpha=0.2,normalize=:pdf)
mean(eachrow(invlogit(samples[10000:10:end,:])))
# histogram(invlogit(samples[:,3]))

# Question: proposal are almost never rejected; questionable 
plot((samples[10000:10:end,:]))

# overlay prior with accepted samples 
names_vec = ["nStar", "Pps", "Psp", "gamma", "pa"];

plots = [];
for idx = 1:5
    p = histogram(invlogit(samples[10000:10:end,idx]),normalize=:pdf,label=names_vec[idx],linealpha=0,legend=:topright,bins = 0:0.02:1)
    plot!(p, x -> pdf.(Beta.(A[idx],B[idx]), x),0:0.01:1,label="Prior",lw=3,legend=:topright) 
    scatter!(p, [mean(eachrow(invlogit(samples)))[idx]], [0.2], label="MDN sample mean", color="red", marker=:star, ms=8,legend=:topright)
    push!(plots, p)
end

p1 = plot(plots...,layout=(2,3),size=(1000,600))

# savefig(p1, "PPC_Sample_04June2025_full_AWRI500um.pdf")

# CSV.write("samples_full_ss_04June2025_"*string(sel_idx)*"_AWRI796_500um.csv",Tables.table(invlogit(samples)),writeheader=false)