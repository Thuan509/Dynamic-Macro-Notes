%% File Info.

%{

    model.m
    -------
    This code sets up the model.

%}

%% Model class.

classdef model
    methods(Static)
        %% Set up structure array for model parameters and set the simulation parameters.
        
        function par = setup()            
            %% Structure array for model parameters.
            
            par = struct();
            
            %% Preferences.
            
            par.beta = 0.94; % Discount factor: Lower values of this mean that consumers are impatient and consume more today.
            par.sigma = 2.00; % CRRA: Higher values of this mean that consumers are risk averse and do not want to consume too much today.
            par.gamma = 0.75; % Probability of not drawing a new idea.
            
            assert(par.beta > 0 && par.beta < 1.00,'Discount factor should be between 0 and 1.\n')
            assert(par.sigma > 0,'CRRA should be at least 0.\n')

            %% Technology.

            par.alpha = 0.33; % Capital's share of income.
            par.delta = 0.03; % Depreciation rate of physical capital.
            par.sigma_eps = 0.07; % Std. dev of productivity shocks.

            assert(par.alpha > 0 && par.alpha < 1.00,'Capital share of income should be between 0 and 1.\n')
            assert(par.delta >= 0 && par.delta <= 1.00,'The depreciation rate should be from 0 to 1.\n')
            assert(par.sigma_eps > 0,'The standard deviation of the shock must be positive.\n')

            %% Labor and Capital Markets.

            par.r = 0.06; % Real interest rate.
            par.w = 0.75; % Real wages. 

            par.L = 0.75; % Aggregate labor supply.

            par.kappa = 0.5; % Fixed cost of investment
            par.phi = 0.75; % Contract enforcibility.

            %% Simulation parameters.

            par.seed = 2025; % Seed for simulation.
            par.T = 10000; % Number of time periods.
            par.N = 3000; % Number of people.

        end
        
        %% Generate state grids.
        
        function par = gen_grids(par)
            %% Asset/capital grid.

            par.alen = 50; % Grid size for a and K.
            par.amax = 25; % Upper bound for a and K.
            par.amin = 0.001; % Minimum a and K.
            
            assert(par.alen > 5,'Grid size for a should be positive and greater than 5.\n')
            assert(par.amax > par.amin,'Minimum a should be less than maximum value.\n')
            
            par.agrid = linspace(par.amin,par.amax,par.alen)'; % Equally spaced, linear grid for a and a'.

            %% Distribution of productivity shocks for entrepreneurs.

            par.elen = 7;

            [eshock,prob_eshock] = model.ghermite(par.elen);
            
            par.eshock = exp(eshock.*(sqrt(2)*par.sigma_eps)); 
            par.prob_eshock = prob_eshock./sqrt(pi);

        end
        
        %% Gauss-Hermite Quadrature
        
        function [x,w] = ghermite(n)
            
            %% Discretized normal distribution.

            ip = 1:n-1;
            ap = sqrt(ip/2);
            CM = diag(ap,1)+diag(ap,-1);
            
            [Vp, Lp] = eig(CM);
            [discp, indp] = sort(diag(Lp));
            
            Vp = Vp(:,indp)';
            
            x = discp; % Discretized nodes.
            w = sqrt(pi)*Vp(:,1).^2; % Weights.
            
        end
        
        %% Utility function.
        
        function u = utility(c,par)
            %% CRRA utility.
            
            if par.sigma == 1
                u = log(c); % Log utility.
            else
                u = (c.^(1-par.sigma))./(1-par.sigma); % CRRA utility.
            end
                        
        end
        
    end
end