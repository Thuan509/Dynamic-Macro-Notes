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

            alen = par.alen; % Grid size for a.
            agrid = par.agrid; % Grid for a (state and choice).

            zlen = par.zlen; % Grid size for z.
            zgrid = par.zgrid; % Grid for z.
            pmat = par.pmat; % Transition matrix for z.

            r = par.r; % Real interest rate, taken as given by households.
            w = par.w; % Real wage rate, taken as given by households.
            
            %phi = -w*par.zgrid(1)/r; % The natural borrowing constraint---the present value of the worst possible realization of income. Set amin in the model file to be a negative number.
            phi = 0; % The zero borrowing constraint---no borrowing allowed. Set amin in the model file to be zero.

            %% Value Function Iteration.
            
            v1 = nan(alen,zlen); % Container for V.
            a1 = nan(alen,zlen); % Container for a'.
            c1 = nan(alen,zlen); % Container for c'.

            crit = 1e-6;
            maxiter = 10000;
            diff = 1;
            iter = 0;
            
            fprintf('------------Beginning Value Function Iteration.------------\n\n')

            c0 = (1+r)*agrid+w.*zgrid; % Guess of consumption is to consume everything; this is a matrix because agrid is a column vector and zgrid is a row vector.
            v0 = model.utility(c0,par)./(1-beta);
            
            while diff > crit && iter < maxiter % Iterate on the Bellman Equation until convergence.
                
                for p = 1:alen % Loop over the a-states.
                    if agrid(p) >= phi % Only solve the model when the borrowing constraint isnt violated.
                        for j = 1:zlen % Loop over the y-states.
    
                            % Consumption.
                            c = (1+r)*agrid(p)+w.*zgrid(j)-agrid; % Possible values for consumption, c(t) = (1+r)a(t-1) + y(t) - a(t+1).
    
                            % Solve the maximization problem.
                            ev = v0*pmat(j,:)'; %  The next-period value function is the expected value function over each possible next-period A, conditional on the current state j.
                            vall = model.utility(c,par) + beta*ev; % Compute the value function for each choice of k', given k.
                            vall(c<=0) = -inf; % Set the value function to negative infinity when c < 0.
                            [vmax,ind] = max(vall); % Maximize: vmax is the maximized value function; ind is where it is in the grid.
                        
                            % Store values.
                            v1(p,j) = vmax; % Maximized v.
                            c1(p,j) = c(ind); % Optimal c'.
                            a1(p,j) = agrid(ind); % Optimal a'.
       
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
            
            sol.a = a1; % Savings policy function.
            sol.c = c1; % Consumption policy function.
            sol.v = v1; % Value function.
            
        end

        %% Solve the firm's static problem.

        function [par,sol] = firm_problem(par)
            %% Model parameters, grids and functions.
            
            delta = par.delta; % Depreciation rate.
            alpha = par.alpha; % Capital's share of income.

            r = par.r; % Real interest rate, which the firm takes as given.
            k = ((r+delta)/alpha)^(1/(alpha-1)); % Capital stock solved from the first-order condition.
            
            %% Capital and wages.
            
            sol = struct();

            sol.k = k; % Capital stock.
            par.w = (1-alpha)*k^alpha; % Real wage rate.
            
        end

    end
end