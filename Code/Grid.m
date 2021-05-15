classdef Grid < handle
    properties
        size;
        people_number;
        people;
        
        %attributes to keep actual information about statistics
        time = 1;
        vector_time = 0;
        
        healthy_hist=0;
        recovered_hist=0;
        inf_and_s_hist=0;
        in_hospital_hist = 0;
        dead_hist = 0;
        in_quarantine_hist = 0;
        sick_hist = 0;
        infected_hist = MD_constant_values.initial_infected_number;
    end
    
    methods
        function obj = Grid(size_,people_nr_)
            if nargin > 0
                obj.size=size_;
                obj.people_number=people_nr_;
            end
        end
        
        function InitGrid(obj,infected_number)
                
            for i=1:obj.people_number
                pos = randi([1 obj.size],1,2);
                
                if i<= infected_number
                    People(i)=Person(pos(1),pos(2),MD_constant_values.infecting,MD_constant_values.infected,i);
                else
                    People(i)=Person(pos(1),pos(2),MD_constant_values.no_security_measures,MD_constant_values.healthy,i);
                end
                %obj.people(i)=Person(pos(1),pos(2));
            end
            
            obj.people=People;
        end
        
        function CountCauses(obj)
            % method to display number of people in each of the states
            healthy_cnt=0;
            recovered_cnt=0;
            inf_and_s_cnt=0;
            in_hospital_cnt = 0;
            dead_cnt = 0;
            in_quarantine_cnt = 0;
            sick_cnt = 0;
            infected_cnt = 0;
            
            for i=1:obj.people_number
                current_state = obj.people(i).state_q2;
                if current_state==MD_constant_values.healthy
                    healthy_cnt=healthy_cnt+1; 
                elseif current_state==MD_constant_values.recovered
                    recovered_cnt=recovered_cnt+1;
                elseif current_state==MD_constant_values.infected_and_sick
                    inf_and_s_cnt=inf_and_s_cnt+1;
                elseif current_state==MD_constant_values.in_hospital
                    in_hospital_cnt=in_hospital_cnt+1;
                elseif current_state==MD_constant_values.dead
                    dead_cnt=dead_cnt+1;
                elseif current_state==MD_constant_values.in_quarantine
                    in_quarantine_cnt=in_quarantine_cnt+1;
                elseif current_state==MD_constant_values.sick
                    sick_cnt=sick_cnt+1;
                elseif current_state==MD_constant_values.infected
                    infected_cnt=infected_cnt+1;
                end
            end
            obj.healthy_hist=[obj.healthy_hist,healthy_cnt];
            obj.recovered_hist=[obj.recovered_hist,recovered_cnt];
            obj.inf_and_s_hist=[obj.inf_and_s_hist,inf_and_s_cnt];
            obj.in_hospital_hist=[obj.in_hospital_hist,in_hospital_cnt];
            obj.dead_hist=[obj.dead_hist,dead_cnt];
            obj.in_quarantine_hist=[obj.in_quarantine_hist,in_quarantine_cnt];
            obj.sick_hist=[obj.sick_hist,sick_cnt];
            obj.infected_hist=[obj.infected_hist,infected_cnt];
            
            disp(['In hospital: ' num2str(in_hospital_cnt) ', Dead: ' num2str(dead_cnt) ', Recovered: ' num2str(recovered_cnt) ', Healthy: ' num2str(healthy_cnt) ', Infected and sick: ' num2str(inf_and_s_cnt)]);
            disp(['In quarantine: ' num2str(in_quarantine_cnt) ', Sick: ' num2str(sick_cnt) ', Infected: ' num2str(infected_cnt)]);
        end
        
        function SimIteration(obj)
%             persistent iteration_cnt;
            GridPrev=-ones(obj.size);
            for i=1:obj.people_number
                GridPrev(obj.people(i).pos_x,obj.people(i).pos_y)=obj.people(i).state_q1;
            end
            for i=1:obj.people_number
                obj.people(i).DefineState(GridPrev);
            end
            for i=1:obj.people_number
                GridPrev=obj.people(i).Move(GridPrev);
            end
            CountCauses(obj)
            obj.time = obj.time +1;
            obj.vector_time = (1:obj.time);
        end

       function PlotGrid(obj)

           figure(1);
           clf
           set(gcf,'color','w');
           xlim([1 obj.size]);
           ylim([1 obj.size]);
           hold on;
            
           for i=1:obj.people_number
               obj.people(i).Plot();
           end
           %plotting legend
           h1 = plot(obj.size+1,obj.size+1,'.g','MarkerSize',20);
           h2 = plot(obj.size+1,obj.size+1,'.yellow','MarkerSize',20);
           h3 = plot(obj.size+1,obj.size+1,'.r','MarkerSize',20);
           h4 = plot(obj.size+1,obj.size+1,'.m','MarkerSize',20);
           h5 = plot(obj.size+1,obj.size+1,'.b','MarkerSize',20);
           h6 = plot(obj.size+1,obj.size+1,'.k','MarkerSize',20);
           h7 = plot(obj.size+1,obj.size+1,'.c','MarkerSize',20);
           lh = legend([h1 h2 h3 h4 h5 h6 h7], ...
            'healthy', 'sick', 'covid', 'hospital', 'recovered', 'dead', 'in quarantine',...
            'Location','northeastoutside');
       end
       function PlotHistory(obj)
          figure(2)
          hold on
          infected_sum = obj.inf_and_s_hist+obj.infected_hist;
          plot(obj.vector_time,infected_sum, 'Color', [0.9290, 0.6940, 0.1250] ,'LineWidth',1.3);
          plot(obj.vector_time,obj.dead_hist, 'k','LineWidth',1.3);
          plot(obj.vector_time,obj.recovered_hist,  'b','LineWidth',1.3);

          title('History of the pandemic');
          xlabel('iteration');
          legend('infected+infected_sick','dead', 'recovered');
          xlim([0 obj.time]);
       end
       
       function PlotAll(obj)
          figure(3)
          hold on
          plot(obj.vector_time,obj.recovered_hist, 'b','LineWidth',1.3);
          plot(obj.vector_time,obj.inf_and_s_hist,  'Color', [0.9290, 0.6940, 0.1250] ,'LineWidth',1.3);
          plot(obj.vector_time,obj.in_hospital_hist, 'm','LineWidth',1.3);
          plot(obj.vector_time,obj.dead_hist, 'k','LineWidth',1.3);
          plot(obj.vector_time,obj.in_quarantine_hist, 'c','LineWidth',1.3);
          plot(obj.vector_time,obj.sick_hist, 'y','LineWidth',1.3);
          plot(obj.vector_time,obj.infected_hist, 'r','LineWidth',1.3);
               
          title('History of the pandemic - all states');
          xlabel('iteration');
          legend('recovered','infected and sick', 'in hospital', 'dead', 'in quarantine', 'sick', 'infected');
          xlim([0 obj.time]);
      end
   end
end