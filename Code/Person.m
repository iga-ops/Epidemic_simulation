classdef Person < handle    
    properties
        it;
        id_number;
        pos_x;
        pos_y;
        state_q1;
        state_q2;
        movement_prob;
        r_time_infected;
        h_time_in_hospital;
        s_time_sick;
        q_time_quarantine;
    end
    
    methods
        function obj = Person(pos_x_,pos_y_,q1,q2,id_number_)
            if nargin > 0
                obj.pos_x=pos_x_;
                obj.pos_y=pos_y_;
                obj.state_q1=q1;
                obj.state_q2=q2;
                obj.id_number=id_number_;
                obj.r_time_infected=MD_constant_values.R_time_infected;
                obj.h_time_in_hospital=MD_constant_values.H_time_in_hospital;
                obj.s_time_sick=MD_constant_values.S_time_sick;
                obj.q_time_quarantine=MD_constant_values.Q_time_quarantine;
                obj.movement_prob=MD_constant_values.initial_movement_prob;
                obj.it=0;
            end
        end
                       
        function ManageInfectedNeighbour(obj,i,j,GridPrev)
            % osoba zdrowa moze pojsc na kwarantanne jesli osoba obok jest
            % chora lub sama sie zarazic
            if obj.state_q2==MD_constant_values.healthy && GridPrev(i,j)==MD_constant_values.infecting
                if rand<=MD_constant_values.P_health_infected
                    obj.state_q1=MD_constant_values.infecting;
                    obj.state_q2=MD_constant_values.infected;
                else 
                    disp('One of the people met infected person and should go to quarantine');
                    obj.state_q1=MD_constant_values.protecting_others;
                    obj.state_q2=MD_constant_values.in_quarantine;
                end
            end
        end
        
        function ManageSick(obj)
            % osoba chora moze wyzdrowiec albo zostac zainfekowana
            if obj.state_q2==MD_constant_values.sick
               obj.it = obj.it + 1;
               if mod(obj.it, obj.s_time_sick) == 0
                   rn = rand;
                   obj.it = 0;
                   if rn<=MD_constant_values.P_sick_more
                       obj.state_q1=MD_constant_values.infecting;
                       obj.state_q2=MD_constant_values.infected_and_sick;
                       disp('One of the sick people now is infected and sick');
                   else
                       obj.state_q1=MD_constant_values.no_security_measures;
                       obj.state_q2=MD_constant_values.healthy;
                       disp('One of the sick people get healthy');
                   end
                end
            end
        end
        
        function ManagePersonInQuarantine(obj)
            % osoba z kwarantanny zostaje zakazona
            if (obj.state_q2==MD_constant_values.in_quarantine)
                obj.it = obj.it + 1;
                if mod(obj.it, obj.q_time_quarantine)==0
                   obj.it = 0;
                   obj.state_q1=MD_constant_values.infecting;
                   obj.state_q2=MD_constant_values.infected;
                   disp('One of the people from quarantine get infected');
                end
            end
        end
        
        function ManageInfectingPerson(obj)
            % osoba zarażajaca moze rozchorować się bardziej, pojsc do szpitala albo wyzdrowiec 
           rn = rand;
           if obj.state_q2==MD_constant_values.infected_and_sick && rn<=MD_constant_values.P_hosp
               obj.state_q1=MD_constant_values.protecting_others;
               obj.state_q2=MD_constant_values.in_hospital;
               disp('One of the infected and sick people went to hospital');
           elseif obj.state_q2==MD_constant_values.infected 
               obj.it = obj.it + 1;
               if mod(obj.it, obj.r_time_infected) == 0
                   obj.it = 0;
                   if rn<=MD_constant_values.P_infected_sick
                       obj.state_q2=MD_constant_values.infected_and_sick;
                       disp('One of the infected people now is infected and sick');    
                   else 
                       obj.state_q1=MD_constant_values.no_security_measures;
                       obj.state_q2=MD_constant_values.recovered;
                       disp('One of the infected people recovered');
                   end
               end
           end
        end 
        
        function ManagePersonFromHospital(obj)
            % osoba ze szpitala moze stac sie zdrowa lub umrzec 'hospital -> dead or recovered'
            if obj.state_q1==MD_constant_values.protecting_others && obj.state_q2==MD_constant_values.in_hospital
                obj.it = obj.it + 1;
                if mod(obj.it, obj.h_time_in_hospital) == 0
                   obj.it = 0;
                   rn = rand;
                   if rn<=MD_constant_values.P_dead
                       obj.state_q1=MD_constant_values.protecting_others;
                       obj.state_q2=MD_constant_values.dead;
                       disp('One of the hospitalized people died');
                   else
                       obj.state_q1=MD_constant_values.no_security_measures;
                       obj.state_q2=MD_constant_values.recovered;
                       disp('One of the hospitalized people recovered');
                   end
                end
            end
        end

        function ManageHealthy(obj)
            % osoba zdrowa moze stac sie chora 'health -> sick'
            if obj.state_q2==MD_constant_values.healthy && rand<=MD_constant_values.P_health_sick
                disp('One of the healthy people got sick');
                obj.state_q1=MD_constant_values.no_security_measures;
                obj.state_q2=MD_constant_values.sick;
            end
        end
        
        function DefineState(obj,GridPrev)
            x_position = obj.pos_x;
            max_x_val = max(x_position-1,1);
            min_x_val = min(x_position+1,MD_constant_values.grid_size);
            y_position = obj.pos_y;
            max_y_val = max(y_position-1,1);
            min_y_val = min(y_position+1,MD_constant_values.grid_size);
            
            for x=max_x_val:min_x_val
                for y=max_y_val:min_y_val
                    if ~(x==x_position && y==y_position)
                        ManageInfectedNeighbour(obj,x,y,GridPrev)
                    end
                end
            end
            ManageSick(obj)
            ManageInfectingPerson(obj)
            ManagePersonFromHospital(obj)
            ManagePersonInQuarantine(obj)
            ManageHealthy(obj)
        end
        
        function GridPrev=Move(obj,GridPrev)
            if rand<=obj.movement_prob
                new_positions=[];
                for i=max(obj.pos_x-1,1):min(obj.pos_x+1,MD_constant_values.grid_size)
                    for j=max(obj.pos_y-1,1):min(obj.pos_y+1,MD_constant_values.grid_size)
                        if ~(i==obj.pos_x && j==obj.pos_y)
                            if GridPrev(i,j)==-1
                                new_positions=[new_positions; [i j]];
                            end
                        end
                    end
                end
                
                if ~isempty(new_positions)
                    GridPrev(obj.pos_x,obj.pos_y)=-1;
                    new_position=randi(length(new_positions));
                    obj.pos_x=new_positions(new_position,1);
                    obj.pos_y=new_positions(new_position,2);
                    GridPrev(obj.pos_x,obj.pos_y)=1;
                end
            end
        end
        
        function Plot(obj)
            if obj.state_q2==MD_constant_values.healthy
                colour='.g';
            elseif obj.state_q2==MD_constant_values.sick
                colour='.c';
            elseif obj.state_q2==MD_constant_values.infected || obj.state_q2==MD_constant_values.infected_and_sick
                colour='.r';
            elseif obj.state_q2==MD_constant_values.in_hospital
                colour='.m';
            elseif obj.state_q2==MD_constant_values.recovered
                colour='.b';
            elseif obj.state_q2==MD_constant_values.dead
                colour='.k';
            elseif obj.state_q2==MD_constant_values.in_quarantine
                colour='.y';
            end
           
            plot(obj.pos_x,obj.pos_y,colour,'MarkerSize',20);
        end
        
    end
end