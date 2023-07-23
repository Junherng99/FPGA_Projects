  # Audio Display Project with PMOD OLED Screen and PMOD based mic.

  This project is done as part of a module in school. Project has more features than others that I have posted on this repo. The project aims to use the Basys-3 board
  to take in audio signals and display the loudness(Amplitude) of the audio signal and display it as an indicator on the OLED screen. There are a total of 3 compulsory 
  tasks for the module and 6 additional novel features implemented to display and use the components on the Basys 3 board.

  ## Details of project
  For details on this project, refer to the **Report.pdf** to see specific instructions and elaborations on the features implemented. The additional features implemented are:
  1) Locking/Unlocking mechanism for improved AVI features.
  2) Morse code recognition and display (on 7-segment). Specific letters must be recognized to unlock the AVI features. <br>
  3) 64-Level Audio Indicator. Volume levels displayed on both 7-segment display as well as on OLED screen with specific smooth colour gradient. <br>
  4) Volume Waveform Plotter. Volume detected is also visualised as a waveform on the OLED screen. Amplitude vs time waveform can be displayed. <br>
  5) Faster sampling mode. This mode can be activated using morse code to evaluate audio signals at a faster interval. <br>
  6) Lock/Reset mechanism. By triggering a switch, a static pattern will lock all functions of the board. Turning the switch off will then display a static screen signifying a reset to 'locked' state. <br>
  
  ## Compulsory tasks (OLED Tasks A and B and AVI Task)
  For these 2 tasks, the pushbutton on the basys3 board is used to control the display on the OLED screen. Pushing a specific button will cause a square or a new border
  to appear on the OLED screen. Pushbutton must be properly debounced. 
  Then, the screen is interfaced to respond to the mic and new features appear as louder sounds are detected by the mic. This mode is activated by specific switches on the board.

  
  
