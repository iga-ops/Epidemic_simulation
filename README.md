# Epidemic_simulation
Implementation of a simple simulating application, modeling the course of the epidemic. It is a polymorphic automaton, the model is calibrated, based on the actual data collected.

Machine states:

• Q = Q1 xQ2

• Q1 = {no_security_measures, infecting, self_protecting, protecting_others, organizing_protection}

• Q2 = {healthy, in_quarantine, infected, sick, infected_and_sick, in_hospital, recovered, dead}



Adopted rules:

• One cell = one person

• People move in a defined grid

• Infection with a virus can occur when neighbors are infected with it (with a given probability)

• Cell states Q = Q1xQ2

• The Q1 state affects the cell moving and infecting others

• The Q2 state is the individual's state of health



States of Q1:

![machine_states_Q1](https://user-images.githubusercontent.com/75940256/118342314-1b36ef80-b523-11eb-9eba-13700eecb67b.png)

States of Q2:

<img width="385" alt="machine_states_Q2" src="https://user-images.githubusercontent.com/75940256/118342719-dc099e00-b524-11eb-908b-de7f80656746.png">

