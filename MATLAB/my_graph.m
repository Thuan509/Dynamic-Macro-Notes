%% File Info.

%{

    my_graph.m
    ----------
    This code plots the value and policy functions.

%}

%% Graph class.

classdef my_graph
    methods(Static)
        %% Plot value and policy functions.
        
        function [] = plot_policy(par,sol, figout)
            %% Plot discrete choice policy function.

            close all

            agrid = par.agrid;
            egrid = par.eshock;
               
            figure(1)
            
            surf(agrid,egrid,sol.o')
                xlabel({'$a_t$'},'Interpreter','latex')
                ylabel({'$e_{t}$'},'Interpreter','latex') 
                zlabel({'$o_{t}$'},'Interpreter','latex') 
            title('Occupational Choice (0=Self-Emplopyed, 1=Worker)','Interpreter','latex')
            saveas(gcf, fullfile(figout, 'opol1_1.png'))
            
            figure(2)
            
            surf(agrid,egrid,sol.cw')
                xlabel({'$a_t$'},'Interpreter','latex')
                ylabel({'$e_{t}$'},'Interpreter','latex') 
                zlabel({'$c_{t}$'},'Interpreter','latex') 
            title('Consumption Policy Function (Worker)','Interpreter','latex')
            saveas(gcf, fullfile(figout, 'cpol1_1.png'))
            
            figure(3)
            
            surf(agrid,egrid,sol.ce')
                xlabel({'$a_t$'},'Interpreter','latex')
                ylabel({'$e_{t}$'},'Interpreter','latex') 
                zlabel({'$c_{t}$'},'Interpreter','latex') 
            title('Consumption Policy Function (Self-Employed)','Interpreter','latex')
            saveas(gcf, fullfile(figout, 'cpol1_2.png'))
            
            figure(4)
            
            surf(agrid,egrid,sol.vw')
                xlabel({'$a_t$'},'Interpreter','latex')
                ylabel({'$e_{t}$'},'Interpreter','latex') 
                zlabel({'$v_{t}$'},'Interpreter','latex') 
            title('Value Function (Worker)','Interpreter','latex')
            saveas(gcf, fullfile(figout, 'vpol1_1.png'))
            
            figure(5)
            
            surf(agrid,egrid,sol.ve')
                xlabel({'$a_t$'},'Interpreter','latex')
                ylabel({'$e_{t}$'},'Interpreter','latex') 
                zlabel({'$v_{t}$'},'Interpreter','latex') 
            title('Value Function (Self-Employed)','Interpreter','latex')
            saveas(gcf, fullfile(figout, 'vpol1_2.png'))
            
            figure(6)
            
            surf(agrid,egrid,sol.v')
                xlabel({'$a_t$'},'Interpreter','latex')
                ylabel({'$e_{t}$'},'Interpreter','latex') 
                zlabel({'$v_{t}$'},'Interpreter','latex') 
            title('Value Function (Overall)','Interpreter','latex')
            saveas(gcf, fullfile(figout, 'vpol1_2.png'))
            
            figure(7)
            
            surf(agrid,egrid,sol.aw')
                xlabel({'$a_t$'},'Interpreter','latex')
                ylabel({'$e_{t}$'},'Interpreter','latex') 
                zlabel({'$a_{t}$'},'Interpreter','latex') 
            title('Savings Policy Function (Worker)','Interpreter','latex')
            saveas(gcf, fullfile(figout, 'apol1_1.png'))
            
            figure(8)
            
            surf(agrid,egrid,sol.ae')
                xlabel({'$a_t$'},'Interpreter','latex')
                ylabel({'$e_{t}$'},'Interpreter','latex') 
                zlabel({'$a_{t}$'},'Interpreter','latex') 
            title('Savings Policy Function (Self-Employed)','Interpreter','latex')
            saveas(gcf, fullfile(figout, 'apol1_2.png'))
            
            figure(9)
            
            surf(agrid,egrid,sol.kbar')
                xlabel({'$a_t$'},'Interpreter','latex')
                ylabel({'$e_{t}$'},'Interpreter','latex') 
                zlabel({'$\bar{K}_{t}$'},'Interpreter','latex') 
            title('Capital Rental Limit','Interpreter','latex')
            saveas(gcf, fullfile(figout, 'kpol1_1.png'))
            
            figure(10)
            
            surf(agrid,egrid,sol.pi')
                xlabel({'$a_t$'},'Interpreter','latex')
                ylabel({'$e_{t}$'},'Interpreter','latex') 
                zlabel({'$\pi_{t}$'},'Interpreter','latex') 
            title('Profit Function','Interpreter','latex')
            saveas(gcf, fullfile(figout, 'ppol1_1.png'))
            
        end

        
    end
end