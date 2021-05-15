classdef MD_constant_values
   properties (Constant)
        
    % simulation size
    grid_size=50;
    people_nr=100;    
    initial_infected_number=6;
    
    % simulation config
    simulation_delay=0.5;
    simulation_steps=10;
    
    % movement config
    initial_movement_prob=0.5;
    
    % time for states in days (iteration)
    R_time_infected = 15; 
    H_time_in_hospital = 5;
    S_time_sick = 7;
    Q_time_quarantine = 12;
  
    % probability of transition to state
    P_health_infected=0.5;
    P_sick_more = 0.1;
    P_health_sick = 0.005;
    P_infected_sick = 0.1;
    P_dead = 0.1;
    P_hosp = 0.03;

    % states Q1
    no_security_measures=0;
    infecting=1;
    protecting_others=2;
    self_protecting=3;
    organizing_protection=4;
    
    % states Q2
    healthy=0;
    in_quarantine=1;
    infected=2;
    sick=3;
    infected_and_sick=4;
    in_hospital=5;
    recovered=6;
    dead=7;
    
   end
end