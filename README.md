Link to Video (Sensor map didn't load properly so robot navigates to a different location): https://web.microsoftstream.com/video/a8b1b691-339c-4451-8194-934e04d247d1?list=studio


**a) What is autonomous navigation in mobile robotics?**

Autonomous navigation is the ability of a robot to traverse an area/map without human intervention.  

**b)What parameters does the robot navigation algorithm consider when planning a path?**

Parameters such as the velocity of the robot, velocity of rotation, inflation radius, cost scaling factor and sim_time. 

**c) What is a cost map (in the context of autonomous navigation)?**

A cost map represents the difficulty for a robot to travers the different areas of a map. 

**d) What is inflation radius (in the context of autonomous navigation)?**

Inflation radius is a set radius around an object that cannot be crossed by the robot. 

**e) Which navigation parameters did you tune using the document in the link below?**

The parameters I edited were the max_vel_x to 0.8 and min_vel_x: to -0.8. This increased the speed of the robot and by having the min_vel_x less than 0, it allowed the robot to move backwards. I also changed the inflation_radius to 0.2. Inflation radius controls how close or far your robot will get to an object. 
