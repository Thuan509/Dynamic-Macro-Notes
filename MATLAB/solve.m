%% File Info.

%{

    solve.m
    -------
    This code solves the model.

%}

%% Solve class.

classdef solve
    methods(Static)
        %% Solve the household's problem using VFI.
        
        function sol = hh_problem(par,sol)            
            %% Model parameters, grids and functions.
            
            beta = par.beta; % Discount factor.
            gamma = par.gamma; % Probability of new idea.

            alen = par.alen; % Grid size for a.
            agrid = par.agrid; % Grid for a (state and choice).

            elen = par.elen; % Grid size for e.
            prob_eshock = par.prob_eshock; % Probabilities for e.

            r = par.r; % Real interest rate, taken as given by households.
            w = par.w; % Real wage rate, taken as given by households.
            pi = sol.pi; % Firm profits.
            
            %% Value Function Iteration.
            
            o1 = nan(alen,elen); % Container for occupational choice.
            v1 = nan(alen,elen); % Container for V.
            v1_worker = nan(alen,elen); % Container for V.
            v1_entrepreneur = nan(alen,elen); % Container for V.
            c1_worker = nan(alen,elen); % Container for c' for workers.
            c1_entrepreneur = nan(alen,elen); % Container for c' for entrepreneurs.
            a1_worker = nan(alen,elen); % Container for a' for workers.
            a1_entrepreneur = nan(alen,elen); % Container for a' for entrepreneurs.

            crit = 1e-6;
            maxiter = 10000;
            diff = 1;
            iter = 0;
            
            fprintf('------------Beginning Value Function Iteration.------------\n\n')

            v0 = zeros(alen,elen); % Guess of value function is zeros.
            
            while diff > crit && iter < maxiter % Iterate on the Bellman Equation until convergence.
                
                for p = 1:alen % Loop over the a-states.
                    for j = 1:elen % Loop over the z-states.

                        % Consumption for workers.
                        cw = (1+r)*agrid(p)+w-agrid;

                        % Consumption for entrepreneurs.
                        ce = (1+r)*agrid(p)+pi(p,j)-agrid;

                        % Next-period value function.
                        ev = gamma*v0(:,j) + (1-gamma).*v0*prob_eshock;

                        % Solve the maximization problem for workers.
                        vw = model.utility(cw,par) + beta*ev; % Compute the value function for each choice of a', given a.
                        vw(cw<=0) = -inf; % Set the value function to negative infinity when c < 0.
                        [vwmax,wind] = max(vw); % Maximize: vwmax is the maximized value function; ind is where it is in the grid.
                    
                        % Solve the maximization problem.
                        ve = model.utility(cw,par) + beta*ev; % Compute the value function for each choice of a', given a.
                        ve(ce<=0) = -inf; % Set the value function to negative infinity when c < 0.
                        [vemax,eind] = max(ve); % Maximize: vemax is the maximized value function; ind is where it is in the grid.
                    
                        % Store values.
                        v1_worker(p,j) = vwmax; % Maximized v for workers.
                        v1_entrepreneur(p,j) = vemax; % Maximized v for entrepreneurs.
                        c1_worker(p,j) = cw(wind); % Optimal c' for workers.
                        c1_entrepreneur(p,j) = ce(eind); % Optimal c' for entrepreneurs.
                        a1_worker(p,j) = agrid(wind); % Optimal a'.
                        a1_entrepreneur(p,j) = agrid(eind); % Optimal a'.

                        if vwmax > vemax
                            v1(p,j) = vwmax; % Overall value function.
                            o1(p,j) = 1; % Occupational choice.
                        else
                            v1(p,j) = vemax; % Overall value function.
                            o1(p,j) = 0; % Occupational choice.
                        end

   
                    end
                end
                
                diff = norm(v1-v0); % Check for convergence.
                v0 = v1; % Update guess of v.
                
                iter = iter + 1; % Update counter.
                
                % Print counter.
                if mod(iter,25) == 0
                    fprintf('Iteration: %d.\n',iter)
                end

            end
                
            fprintf('\nConverged in %d iterations.\n\n',iter)
            
            fprintf('------------End of Value Function Iteration.------------\n')
            
            %% Macro variables, value, and policy functions.
            
            sol.ae = a1_entrepreneur; % Savings policy function for entrepreneur.
            sol.aw = a1_worker; % Savings policy function for worker.
            sol.ce = c1_entrepreneur; % Consumption policy function for entrepreneur.
            sol.cw = c1_worker; % Consumption policy function for worker.
            sol.ve = v1_entrepreneur; % Entrepreneur value function.
            sol.vw = v1_worker; % Worker value function.
            sol.o = o1; % Occupational choice.
            sol.v = v1; % Value function.
            
        end

        %% Solve the firm's static problem.

        function [par,sol] = firm_problem(par)
            %% Model parameters, grids and functions.

            alen = par.alen;
            elen = par.elen;
            
            delta = par.delta; % Depreciation rate.
            alpha = par.alpha; % Capital's share of income.
            eshock = par.eshock; % Productivity shocks.
            kappa = par.kappa; % Fixed cost of investment.
            agrid = par.agrid;
            phi = par.phi; % Contract enforcement.

            r = par.r; % Real interest rate, which the firm takes as given.
            w = par.w; % Real wages, which the firm takes as given.
            L = par.L; % Labor supply set exogenously or solved from GE.
            K = ((1-alpha)/alpha)*(w/r)*L; % Capital stock solved from ratio of marginal products.
            
            %% Capital and wages.
            
            sol = struct();

            pi = eshock.*(K^alpha).*L^(1-alpha) - w*L - (r+delta)*K - (1+r)*kappa; % Profit.
            pi = repmat(pi',alen,1);

            kbar = zeros(par.alen,par.elen);

            for j = 1:alen
                for q = 1:elen
                    kfun = @(X)(eshock(q).*(X^alpha).*L^(1-alpha) - w*L - (r+delta)*X - (1+r)*kappa + (1+r)*agrid(j) - (1-phi)*(eshock(q).*(X^alpha).*L^(1-alpha) - w*L + (1-delta)*X));
                    ksol = fsolve(kfun,K);
                    kbar(j,q) = ksol;
                    
                    if ~isreal(kbar)
                        kbar(j,q) = par.amin;
                    end

                    if kbar(j,q) < K
                        pi(j,q) = eshock(q)*(kbar(j,q)^alpha)*L^(1-alpha) - w*L - (r+delta)*kbar(j,q) - (1+r)*kappa;
                    end

                end
            end

            sol.kbar = kbar;
            sol.pi = pi;
            
        end

    end
end