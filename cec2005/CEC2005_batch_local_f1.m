% batch script for cec contest
%   assumes two additional lines in function benchmark_func:
%   x = x'; % before the actual call of the function via f=feval(fhd,x)+f_bias(func_num);
%   f=f';   % after the function call

global initial_flag;

nruns = 25;
fun = 1;
f_bias = -450;
Ter_Err = 1E-8;
xinitlo = -100;
xinitup = 100;

%%%%%
clear opts;
opts.StopFitness = f_bias + Ter_Err;
opts.EvalParallel = 'yes';
opts.Science = 'yes';
opts.SaveModulo = 100;
opts.SaveTime = 5; 
opts.Plotting = 0;
opts.VerboseModulo = 0;
opts.Display = 0;
opts.LBounds = xinitlo;
opts.UBounds = xinitup;
%%%%%


for N=[10,30,50]
    basename = strcat('f',num2str(fun),'_',num2str(N),'D');    
    stop = {};
    finalpopsize = [];
    for i=1:nruns
        opts.MaxFunEvals = N*10000;
        totevals = 0;
        initial_flag = 0;
        opts.PopSize = (4 + floor(3*log(N)));       
        sigma0 = 0.005*(xinitup - xinitlo);
        fmin = inf;
        stop{i} = [];
        while (opts.MaxFunEvals > opts.PopSize) & (fmin > opts.StopFitness)
            xstart = xinitlo*ones(N,1)+(xinitup-xinitlo)*rand(N,1);
            [xmin, fmin, counteval, stopflags] = cmaes('benchmark_func',xstart,sigma0,opts,fun);
            opts.MaxFunEvals = opts.MaxFunEvals - counteval;
            stop{i} = [stop{i},stopflags];
        end
        finalpopsize = [finalpopsize, opts.PopSize/2];
        feval('benchmark_func','save');        
    end
    flagfile = strcat('stopnpop_',basename);
    eval(['save ',flagfile,' stop finalpopsize']);   
end
