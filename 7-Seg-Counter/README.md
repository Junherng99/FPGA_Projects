# 7-segment display counter project

This project has 2 modules to showcase how to define a uniform seven segment counter with all 4 displays showing the same number, 
as well as a counter that goes from 0000 to 9999 to showcase how to have different displays on each of the seven segment displays even though they share the same control signal. <br>
<br>
Because the Basys 3 board has a common anode control, it becomes more tricky to have different displays on each individual 7-segment display. 
The anodes must be turned off and on and cycled through using some clocking signal fast enough to display desired outputs on the 7-segment display.
