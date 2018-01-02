extensions [sound soundx] ;I tried bg music or button sounds with sound to some degree of success, but it made the game unbearably slow... thanks soundx
;setup is just a setup button
;ACKNOWLEDGEMENTS: Testers : Simon Chen
;Death Note music is used as theme (no sue please copyright I don't know how to credit properly)
;MISFEATURES: Clicking to place does not always place immediately; Menu does not close on general click (always); Depots are subtracting double the expected amount;
;MISFEATURES: general click does not work in pause menu, occassionally leaves range visible
;MISFEATURES: Lots of bugs if menu is not opened once first: I can't find a manual fix?
breed [addons addon]
breed [ranges range]
breed [cores core]
breed [powerPlants powerPlant]
breed [relays relay]
breed [miners miner]
breed [lasers laser]
breed [missiles missile]
breed [Depots depot]
breed [aniLasers aniLaser]
;ENEMIES
breed [fighters fighter]
breed [bombers bomber]

globals [paused running load buttonColor tColor was-down? start? titleTickCounter transX transY restart menuColor depotGenCounter lColor id-ing?
data coreStress survivalTime energyGenCounter buying? buyClickGlobalSub buyErrorHold buySuccess? currentCost bPulse waveC
id-HelperWho id-HelperSpecies wavesSurvived endGameOK bCheckSound dummyY soundCheck
coreMax relayMax laserMax minerMax powerPlantMax
coreMulti relayMulti laserMulti minerMulti powerPlantmulti]
;shadow effect   
addons-own [outin]
turtles-own [health level activate validBuy? menuItem? buyState? uniqueID aoe actualAOE construction maxHealth
  building? enemyWaveID wSpread hpDrain worth connected? Reserve]
fighters-own [attacking?]
links-own [dead? pulser? laser?]
patches-own [id maxYed active bgStore]
cores-own [energy]
relays-own [conN pulseDir]
miners-own [mC]
Depots-own [dataSource initial]
lasers-own [attack?]

;to startup
  ;setup
;end

to button [minX maxX minY maxY colorTheme buttonID]
  ask patches with [pxcor > minX and pxcor < maxX and pycor > minY and pycor < maxY] [set pcolor colorTheme set id buttonID set maxYed maxY]
  ask patches with [((pxcor = minX or pxcor = maxX) and (pycor > minY and pycor < maxY)) or ((pycor = minY or pycor = maxY) and (pxcor > minX and pxcor < maxX))] [set pcolor colorTheme - 2]
  ask patches with [((pxcor = maxX + 1) and pycor < maxY and pycor > minY) or ((pycor = minY - 1) and pxcor > minX and pxcor < maxX)] [set active false set pcolor 1.8]
  ask patches with [pxcor = maxX and pycor = minY] [set pcolor 1.4]
end
to-report capitalize [c]
  let pos position c "abcdefghijklmnopqrstuvwxyz"
  ifelse pos = "false" [report c]
  [report item pos "ABCDEFGHIJKLMNOPQRSTUVWXYZ"]
end
;to-report unit? [m]
;  report member? m [cores powerPlants relays miners laser missiles depots]
;end
to setup 
  ca
  reset-timer
  if Music? [every 1.0 [if round timer mod 109 = 0 [carefully [if soundCheck = 0 [soundx:play-soundfile (word soundx:current-dir "Theme.wav") -2 0.0 set soundCheck 1]] []]]
     if round timer mod 109 = 50 [set soundCheck 0]]
  reset-ticks
  ifelse Screen-res [set-patch-size 1.78]
  [set-patch-size 3]
  resize-world -120 120 -120 120
  set was-down? false
  set start? false
  set lColor orange
  set buttonColor 27
  set menuColor 97
  set tColor 61.5
  set transX min-pxcor
  set transY max-pycor 
  import-pcolors "Image.jpg"
  ;sound:play-sound "TitleBeat.wav"
  ask patches with [pycor >= 75 and pycor <= 105 and pxcor <= -15] [set pcolor (4 - (abs (90 - pycor)) / 5) / 2 + 70]
  ask patches with [pycor >= 75 and pycor <= 102 and pxcor >= -14 and pxcor <= -10] [set pcolor 103 + pxcor / 10]
  ask patches with [pxcor <= -10 and pycor >= 70 and pycor < 75] [set pcolor 102 + pxcor / 90]
  ask patches with [pxcor >= -19 and pxcor <= -1 and (pycor mod 35 = 20 and pycor <= 55 and pycor >= -85)] [set pcolor black]
  button 0 100 -100 100 violet - 4 1
  button -110 -20 45 65 buttonColor 2
  button -110 -20 10 30 buttonColor 3
  button -110 -20 -25 -5 buttonColor 4
  button -110 -20 -60 -40 buttonColor 5
  button -110 -20 -95 -75 buttonColor 6
  ;sound:play-sound-and-wait "test.wav"
  ask patches [set plabel-color tColor]
    if restart != 0 [button -110 -20 -120 -70 buttonColor 0
    ask patch -72 -80 [set plabel "HACKED!"]
    ask patch -60 -100 [set plabel (word "Loss Count:" restart)]]
  ask patch -30 55 [set plabel "Start Game"]
  ask patch -30 20 [set plabel "Credits"]
  ask patch -30 -15 [set plabel "Tower Info"]
  ask patch -30 -50 [set plabel "Terms"]
  ask patch -30 -85 [set plabel "Load Game"]
  set running true
  ask patches [set active false]
  crt 1 [set hidden? true]
  tick
  wait 1
  crt 1 [set shape "title1" setxy -93 93 set color tColor + 5 set size 20 set heading 90]
  tick
  repeat 3 [wait 0.6 ask turtle 1 [set hidden? true] tick wait 0.6 ask turtle 1 [set hidden? false set size 16 set color color - 1 setxy -97 88] tick]
  ask turtle 1 [hatch 1 [set shape "titleSpace"]]
  ask turtle 2 [fd 10] tick wait 0.5
  crt 1 [set shape "title2" setxy -90 90 set color tColor + 5 set size 14]
  ask turtle 2 [fd 10] tick wait 0.5
  crt 1 [set shape "title3" setxy -80 90 set color tColor + 5 set size 14]
  ask turtle 2 [fd 10] tick wait 0.5
  crt 1 [set shape "title4" setxy -70 90 set color tColor + 5 set size 14]
  ask turtle 2 [fd 10] tick wait 0.5
  crt 1 [set shape "title3" setxy -60 90 set color tColor + 5 set size 14]
  ask turtle 2 [fd 10] tick wait 0.5
  crt 1 [set shape "title5" setxy -50 90 set color tColor + 5 set size 14]
  ask turtle 2 [fd 10] tick wait 0.5
  crt 1 [set shape "title2" setxy -40 90 set color tColor + 5 set size 14]
  ask turtle 2 [fd 10] tick wait 0.5
end
to endSequence
  ask turtles with [uniqueID != 666 and breed != cores and who != 0] [die]
  tick wait 0.3
  ask links [set color 0]
  ask patches [set pcolor 0 set plabel ""]
  tick
  wait 1
  ask core 1 [set shape "core0" set color 96]
  tick
  wait .6
  ask core 1 [set shape "core1" set color 14]
  tick
  wait .4
  ask core 1 [set shape "core2" set color 84]
  tick
  wait .4 
  ask core 1 [set shape "core3" set color 13]
  tick
  wait .3
  ask core 1 [set shape "core4" set color 81]
  tick
  wait .2 
  ask core 1 [set shape "core5" set color 11]
  cro 4 [set breed aniLasers
    fd 40 set size 60 ifelse heading mod 180 = 0 
    [set shape "laser1" hatch 10 [set xcor xcor + (who mod 10) / 10 set xcor xcor - .5]]
    [set shape "laser2" hatch 10 [set ycor ycor + (who mod 10) / 10 set ycor ycor - .5]]
    ] 
  tick
  repeat 20 [ask turtles with [breed = aniLasers] [ifelse shape = "laser1" [set shape "laser2"][set shape "laser1"]] wait 0.05 tick]
  repeat 20 [ask turtles with [breed = aniLasers] [rt 4.5] wait 0.05 tick]
  repeat 20 [ask turtles with [breed = aniLasers] [set size size + 2
      if heading = 90 [set ycor ycor + 4]
      if heading = 180 [set xcor xcor + 4]
      if heading = 270 [set ycor ycor - 4]
      if heading = 0 [set xcor xcor - 4]
       ] wait 0.05 tick]
  wait 2
  tick
  
  ask turtles with [who >= 1] [die]
  ask patches [set pcolor 0 set id 0]
  tick
  button -100 100 -100 100 52 99
  button -80 80 -90 -50 66 100
  ask patch 20 80 [set plabel "GAME OVER"]
  ask patch 20 30 [set plabel "Survival Time"]
  ask patch 15 10 [set plabel (word survivalTime "  Pulses")]
  ask patch 20 -20 [set plabel "Waves Survived"]
  ask patch 5 -40 [ifelse wavesSurvived >= 1 [set plabel wavesSurvived - 1] [set plabel "0"]]
  ask patch 20 -70 [set plabel "Back to Menu"]
  tick
  while [endGameOK = 0] [
    ask turtle 0 [setxy mouse-xcor mouse-ycor
      ifelse id = 100 [if bCheckSound = 0 [carefully [soundx:play-soundfile  word soundx:current-dir "button.wav" 0 0] [] set bCheckSound 1]
        ask patches with [id = 100] [set pcolor 67]] [set bCheckSound 0 ask patches with [id = 100] [set pcolor 65]]]
    if mouse-down? [set was-down? true]
    mouseClickEndGame
    tick
    ]  
end
to-report clickTest
   report was-down? and not mouse-down? 
end
to mouseClickLoad
  let is-down? mouse-down?
  if clickTest [beep set running false 
    set load 1]
  set was-down? is-down?
end
to mouseClickSave
  let is-down? mouse-down?
  if clickTest [beep 
    ask turtles with [buyState? = 1] [die]
    ask turtles with [uniqueID = -1] [die]
    export-world "CSFinal.csv"]
  set was-down? is-down?
end
to mouseClickPause
  let is-down? mouse-down?
  if clickTest [
    ifelse paused = 0 [set paused 1 ask turtles with [shape = "pause"] [set shape "play"]] 
    [set paused 0 ask turtles with [shape = "play"] [set shape "pause"]]
    ]
  set was-down? is-down?
end
to mouseClickBack
  let is-down? mouse-down?
  if clickTest [ca setup]
  set was-down? is-down?
end
to mouseClick1
  let is-down? mouse-down?
  if clickTest [beep set running false]
  set was-down? is-down?
end

to goScreen
  if running [
     if Music? [carefully [every 1 [if round timer mod 109 = 0 [show 1 if soundCheck = 0 [soundx:play-soundfile (word soundx:current-dir "Theme.wav") -3 0.0 set soundCheck 1]]]] []
        if round timer mod 109 = 50 [set soundCheck 0]]
    ifelse titleTickCounter = 0 [ask turtle 2 [set hidden? not hidden? set titleTickCounter 20]] [set titleTickCounter titleTickCounter - 1] 
    ask patches [if id > 1 [ifelse active [set pcolor buttonColor + 1] [set pcolor buttonColor]]
      if id = 1 [set plabel-color 66.5]]
    ask turtle 0 [setxy mouse-xcor mouse-ycor
      if id = 0 [ask patches with [id > 1] [set active false] 
        set bCheckSound 0
        ask patches with [id = 1] [set plabel ""] 
        ask turtles with [who > 8] [die]
        ask patches with [pxcor >= -19 and pxcor <= -1 and pcolor = lColor] [set pcolor 0]]
      if id = 1 [set bCheckSound 1]
      if id != 0 [let x id 
        carefully [if id != 1 and bCheckSound = 0 [soundx:play-soundfile  word soundx:current-dir "button.wav" 1 0 set bCheckSound 1]] []
        ask patches with [id = x] [set active true] 
        ask patches with [id != x] [set active false]
        
        if id = 2 [ask patch 95 90 [set plabel "Start the Game!"]
          ask patches with [pycor = 55 and pxcor >= -19 and pxcor <= -1] [set pcolor lColor]
          if mouse-down? [set was-down? true]
          mouseClick1]         
        if id = 3 [ask patch 95 90 [set plabel "Joel Ye Term 1 CS"] 
          ask patches with [pycor = 20 and pxcor >= -19 and pxcor <= -1] [set pcolor lColor]
          ask patch 95 70 [set plabel "Final Project"] 
          ask patch 95 50 [set plabel "Teacher: Mr. Brooks"]]
        if id = 4 [ask patch 45 87 [sprout 1 [set shape "target" set size 20 set color 97]] 
          ask patches with [pycor = -15 and pxcor >= -19 and pxcor <= -1] [set pcolor lColor]
          ask patch 95 70 [set plabel "This is your Energy Core."]
          ask patch 95 60 [set plabel "Protect! It generates energy."]
          ask patch 45 45 [sprout 1 [set shape "pentagon" set size 20 set color 67]]
          ask patch 95 30 [set plabel "Harvest Nodes gather data."]
          ask patch 45 15 [sprout 1 [set shape "relay" set size 20 set color sky]]
          ask patch 95 0 [set plabel "Data relays."]
          ask patch 45 -15 [sprout 1 [set shape "square" set size 20 set color 16]]
          ask patch 95 -30 [set plabel "Bit Defenders"]]
        ;insert new towers here
        if id = 5 [ask patches with [pycor = -50 and pxcor >= -19 and pxcor <= -1] [set pcolor lColor]
          ask patch 95 90 [set plabel "You are being hacked!"]
          ask patch 95 80 [set plabel "Defend your system"]
          ask patch 95 70 [set plabel "from being hijacked."]
          ask patch 95 60 [set plabel "Energy is used to power"]
          ask patch 95 50 [set plabel "construction and defense"]
          ask patch 95 40 [set plabel "You also need data to"]
          ask patch 95 30 [set plabel "build new units"]
          ask patch 95 20 [set plabel "Enemy stats are..."]
          ask patch 95 10 [set plabel "Unknown"]]
        if id = 6 [ask patches with [pycor = -85 and pxcor >= -19 and pxcor <= -1] [set pcolor lColor]
          ask patch 95 90 [
            if plabel != "No save file!" [set plabel "Load Game"]]        
          if mouse-down? [set was-down? true] mouseClickLoad]
         ]]    
    tick
    goScreen
    ]
  if not running [
    ifelse load = 0 [ask patches [set plabel ""] transition] 
    [carefully [export-world "Menu.csv" import-world "CSFinal.csv" game] 
      [import-world "Menu.csv"
        set load 0 
        set running true 
        ask patch 95 90 [set plabel "No save file!"]
        ask turtles [set hidden? false]
        goScreen ]]]
end
to transitionRow 
  while [transX != max-pxcor]
  [ask patch transX transY [ifelse random 8 = 0 [set pcolor 62] [set pcolor 0]] 
    set transX transX + 1 if (transX mod 60 = 0 and transY mod 6 = 0) [tick]]

end
to transition
  ask turtles with [who > 0] [die]
  reset-ticks
  while [transY != 0] [transitionRow set transX min-pxcor ifelse transY > 0 [set transY (0 - transY)] [set transY -1 - transY]]
  set transY 0 
  transitionRow
  tick
  wait 0.2
  resize-world -1 1 -1 1
  tick
  resize-world -10 10 -10 10
  tick
  resize-world -1 1 -1 1
  tick
  wait 2 
  ca
  reset-ticks
  resize-world -120 120 -120 120
  tick
  set was-down? false
  wait 1 
  set coreStress 1
  set-default-shape Depots "box"
  set-default-shape lasers "square"
  set-default-shape relays "relay"
  set-default-shape miners "pentagon"
  set-default-shape powerPlants "powerPlant"
  ;speculative missile design Cloud?
  set-default-shape fighters "fighter"
  set data 200
  set buttonColor 54
  set menuColor 97
  set tColor 61.5
  reset-ticks
  ask patches [set pcolor 2]
  crt 1 [set hidden? true] ;Mouse turtle
  repeat 19 [wait 0.1 ask patches [set pcolor pcolor - 0.1] tick]
    set running true
  wait 0.5 
  import-pcolors "grey_bg_2.jpg"
  ask patches with [(pycor >= 74 and pxcor >= 50) or pycor <= -92] [set bgStore pcolor]   
  create-cores 1 [set shape "target" set size 4 set color 97 set energy 200 set construction 100 set aoe 15 set actualAOE 15 set activate 1 set health 200 set connected? true
    while [depotGenCounter < 117] [ask one-of patches with [distance myself >= depotGenCounter + 4 and distance myself < depotGenCounter + 8] [sprout-Depots 1 [set color green set size 2]]
      set depotGenCounter depotGenCounter + 4]]
  create-ranges 1 [set shape "circle" set color [153 255 153 60] set size 10 set hidden? true]
  ask Depots [set dataSource random 40 + 100 set initial dataSource]
  ask patches [set id 0 set active false]
  button -120 -112 -120 -92 98 1
  ask patches with [pxcor < -112 and pycor < -92] [set pcolor 98]
  ask patch -116 -107 [sprout 1 [set shape "hammer" set color 34 set size 12]]
  button -120 -60 85 120 98 3
  ask turtles [if breed = depots and id != 0 [die]]
  ask turtles with [xcor <= -59 and ycor >= 84] [die]
  ask patch -97 114 [set plabel "Status:"]
  set running true
  create-addons 1 [set size 10 set shape "x" set color red set menuItem? 1
    setxy -105 -105]
  create-relays 1 [set size 10 set color sky set pulseDir -0.1
    setxy -85 -105 set menuItem? 1 set uniqueID 1]
  create-miners 1 [set size 10 set color green
    setxy -55 -105 set menuItem? 1 set uniqueID 2]
  create-addons 1 [set size 10 set shape "dataChip" set uniqueID 6 set color 54
    setxy -55 -110 set menuItem? 1]
  create-powerPlants 1 [set size 10 set color 1
    setxy -25 -105 set menuItem? 1 set uniqueID 3]
  create-lasers 1 [set size 10 set color red
    setxy 5 -105 set menuItem? 1 set uniqueID 4]
  create-addons 20 [set size 2 set shape "circle" set color red set menuItem? 1
    setxy 5 -105 set heading 0]
 ; create-missiles 1 [set size 10 set color 26
 ;   setxy 35 -105 set menuItem? 1 set uniqueID 5]
  create-addons 1 [set size 10 set color 3 set menuItem? 1 
    setxy 52 -100 set shape "save"]
  create-addons 1 [set size 10 set menuItem? 1
    setxy 63 -101 set shape "pause"]
  create-addons 1 [set size 10 set menuItem? 1
    setxy 57.5 -114 set shape "arrow" set heading 270 set color red]
  create-addons 1 [set size 10 set menuItem? 1 set heading 0 setxy -85 -107.5 set color green set shape "arrow" set uniqueID 20]
  create-addons 2 [set size 10 set menuItem? 1 set shape "sell" setxy -60 -107.5 set uniqueID 21]
  ask turtles [set connected? false]
  ask core 1 [set connected? true]
  ask turtles with [menuItem? = 1] [set hidden? true]
  ask turtles with [menuItem? != 1] [set maxHealth health]
  set survivalTime 0
  set was-down? true
  ;bad fix is bad (and non-existant, I gave up)
  game
end
;buy = 0 open build menu buy = 1 open upgrade menu    
to mouseClick2 [buy? what]
  let is-down? mouse-down? 
  if clickTest [
    set buying? 1
    ask patches with [id = 1] [set id 0] 
    ask patches with [pycor <= -92] [set pcolor bgStore]
    ask turtles with [pycor <= -92 and who > 0 and menuItem? = 0 and who != 33] [set hidden? true]
    button -120 117 -120 -92 97 2
    let bottom -120
     let roof -95
    if buy? = 0 [ask turtles with [menuItem? = 1 and (uniqueID < 20) ] [set hidden? false]
     button -110 -100 -120 -100 16 11
     button -95 -75 bottom roof 105 6
     button -65 -45 bottom roof 105 7
     button -35 -15 bottom roof 105 8
     button -5 15 bottom roof 105 9
     ;button 25 45 bottom roof 105 10
       set was-down? is-down?
     ]
     button 48 56 -107 -95 105 -2
     button 58 67 -107 -95 105 -3
     button 48 67 -118 -110 105 -4  
     
     if buy? = 1 [
       ask turtles with [menuItem? = 1 and (breed = addons and shape != "x" and shape != "circle" and shape != "datachip") ] [set hidden? false]
       ask turtle id-HelperWho
       [ifelse activate = 1 and breed != relays [button -95 -75 bottom roof 105 12] 
         [ask turtles with [who = 63] 
           [set hidden? true]]]
       ifelse id-HelperWho != 1 
       [button -70 -50 bottom roof 105 13] 
       [ask addons with [shape = "sell"] [set hidden? true]]
       set was-down? false
       ]
    ]
end


;buySuccess? = 1 can be used to check potential purchase


;units 1 - relays 2 - miners 3 - powerPlant 4 - lasers 5 - missiles
to mouseClickBuy [unit]
  let is-down? mouse-down?
  
  if clickTest [
    set buySuccess? 1
    ask turtles with [buyState? = 1] [die]
    ask ranges with [who != 32] [die]
     if unit = 1 [ifelse data >= 20 
       [set currentCost 20
         create-relays 1 [set color sky set pulseDir -1 set shape "relay_dormant" set aoe 12 set actualAOE 12]] 
       [set buyErrorHold 20 
         ask patch 110 -112 [set plabel "Not enough."] set buySuccess? 0]]
     if unit = 2 [ifelse data >= 50 
         [set currentCost 50
         create-miners 1 [set color green set aoe 0 set actualAOE 6]]
       [set buyErrorHold 20 
         ask patch 110 -112 [set plabel "Not enough."] set buySuccess? 0]]
     if unit = 3 [ifelse data >= 100 
       [set currentCost 100
         create-powerPlants 1 [set color 1 set aoe 8 set actualAOE 0]]
       [set buyErrorHold 20 
         ask patch 110 -112 [set plabel "Not enough."] set buySuccess? 0]]
     if unit = 4 [ifelse data >= 70 
       [set currentCost 70
         create-lasers 1 [set color red set aoe 0 set actualAOE 20]]
       [set buyErrorHold 20 
         ask patch 110 -112 [set plabel "Not enough."] set buySuccess? 0]]
     if unit = 5 [ifelse data >= 120 
       [set currentCost 120
         create-missiles 1 [set color 26 set aoe 0 set actualAOE 40]]
       [set buyErrorHold 20 
         ask patch 110 -112 [set plabel "Not enough."] set buySuccess? 0]]
     if buySuccess? = 1 
     [ask max-one-of turtles [who] 
       [set size 3 set hidden? false
       set buyState? 1
       set validBuy? 0]
       ask turtles with [aoe > 0 and who != [who] of max-one-of turtles [who]] [hatch-ranges 1 [set size aoe * 2 set shape "circle" set color [153 255 153 60] set uniqueID -1]]
       set buyClickGlobalSub 0
       ]
  ]
  set was-down? is-down?
end
to mouseClickCloseBuild 
  let is-down? mouse-down?
  ifelse clickTest [
  ask turtles with [buyState? = 1] [die]
  set buying? 0
  ask patches with [id >= 2 or id <= 0] [set id 0]
  ask turtles with [pycor <= -92 and breed != ranges] [set hidden? false]
  ask patches with [pycor <= -92] [set pcolor bgStore set plabel ""]
  ask turtles with [menuItem? = 1] [set hidden? true]
  button -120 -112 -120 -92 97 1
  set was-down? true]
  [set was-down? is-down?]
end

to mouseClickCancelBuy
  let is-down? mouse-down?
  ifelse clickTest[
    set was-down? false
    ask ranges [set hidden? true]
    set buyState? 0
    set buySuccess? 0
    ask turtles with [buyState? = 1] [die]
    ask turtles with [uniqueID = -1] [die]
    ]
  [set was-down? is-down?]
end

to mouseClickGeneral 
  let is-down? mouse-down?
  ifelse clickTest [
    set id-ing? 0
    ask ranges [set hidden? true]
    ask patches with [pycor >= 74 and pxcor >= 50] [set pcolor bgStore set plabel ""]
    ask turtles with [xcor >= 74 and ycor >= 50] [set hidden? false]
    ask patches with [id = 5] [set id 0]
    set was-down? false
  ]
  [set was-down? is-down?]
end

to mouseClickIdentify [species who?]
  let # first sort (who?) ;filter unit?
  let is-down? mouse-down?
  ifelse clickTest [
    set id-ing? 1
    set id-HelperWho #
    set id-HelperSpecies species
    ask turtles with [xcor >= 49 and ycor >= 74] [set hidden? true]
    ask range 32 [ifelse [uniqueID] of turtle id-HelperWho = 666 [set color [255 153 153 60]] [set color [153 255 153 60]] setxy [xcor] of turtle # [ycor] of turtle # set hidden? false set size 2 * [actualAOE] of turtle #]
    button 50 120 75 120 97 5
    ask patch 110 115 [set plabel (word (capitalize (first (butlast (word (species))))) (butfirst (butlast (word (species)))))]
    set was-down? true
  ]
  [set was-down? is-down?]
end

to mouseClickPlace
  let is-down? mouse-down?
  ifelse clickTest [ask turtles with [buyState? = 1] 
    [if count turtles in-radius 3 <= 3 [ 
        if id = 0 [;optional...
      set worth currentCost / 2
      set buyState? 0
      set maxHealth 100
      set connected? false
      set data data - currentCost
      ask turtles with [uniqueID = -1] [die]
      ask turtles with [activate = 1 and connected?] [if distance myself <= aoe [ask myself [set building? 1 set connected? true]
          create-link-to myself]]
      ;if not any? links with [end2 = myself] [set connected? false]
      
     set buySuccess? 0 
     ask ranges [set hidden? true]]]
    
    set was-down? false]]
  [set was-down? is-down?]
end

to mouseClickEndGame
  let is-down? mouse-down?
  ifelse clickTest [set endGameOK 1
  set was-down? false]
  [set was-down? is-down?]
end

; ID Compendium for buttons
; 1 . Build Initial State
; 2 . Build Open State (w/ Buy / Upgrade Parameter)
; 
; 5-10. unit buttons
; 11. cancel

to game 
  if Music? [every 1.0 [if round timer mod 109 = 0 [carefully [if soundCheck = 0 [soundx:play-soundfile (word soundx:current-dir "Theme.wav") -2 0.0 set soundCheck 1]] []]]
     if round timer mod 109 = 50 [set soundCheck 0]]
  ifelse paused = 0  
  [ifelse running [
    ask patches [if id >= 1 and id < 6 and id != 2 [ifelse active [set pcolor menuColor + 1] [set pcolor menuColor]]
      if id = 2 and pxcor < -100 [ifelse active [set pcolor menuColor + 1] [set pcolor menuColor]]
      if (id >= 6 and id < 14) or (id <= -2 and id >= -4) [ifelse active [set pcolor 106] [set pcolor 105]]
      if id = 11 [ifelse active [set pcolor 17] [set pcolor 16]]
    ]
    if id-ing? = 1 [    ifelse id-HelperSpecies != depots [
    carefully [ask patch 110 100 [set plabel (word "Level " (([level] of turtle id-HelperWho) + 1))]] [show error-message set id-ing? 0]
    carefully [ask patch 110 85 [set plabel (word "Health " [health] of turtle id-HelperWho)]] []
    carefully [ask range 32 [setxy [xcor] of turtle id-HelperWho [ycor] of turtle id-HelperWho]] []]
    [carefully [ask patch 110  85 [set plabel (word "Data: " [dataSource] of turtle id-HelperWho "/" [initial] of turtle id-HelperWho) ]] []]]
    
    ask addon 37 [ifelse outin = 1 [set ycor -114] [set ycor -110]]
    ask patch -65 105 [set plabel (word "Core Energy  " [energy] of core 1)]
    ask patch -76 95 [set plabel (word "Data  " data)] 
    ask turtles with [uniqueID = 3] [rt 3]
    ask Depots [set color 110 + 9 / 140 * dataSource]
    ask relays [set color color + pulseDir
      if round color = 97 [set pulseDir -.1]
      if round color = 93 [set pulseDir .1]] 
    
    ask turtles with [buyState? = 1] [setxy mouse-xcor mouse-ycor
      set connected? false
      if count turtles in-radius 3 <= 2 and id != 0 [set validBuy? 1]
      if ycor > -100 [
      if mouse-down? [set was-down? true]
      every 0.2 [mouseClickPlace]]]
    
     if buyErrorHold > 0 [set buyErrorHold buyErrorHold - 1]
      if buySuccess? = 1 [ask range 32 [setxy mouse-xcor mouse-ycor 
          set hidden? false 
          set size [actualAOE] of (max-one-of turtles with [breed != ranges] [who]) * 2]]
    ask turtle 0 [setxy mouse-xcor mouse-ycor
      if id = 0 [ask patches with [id != 0] [set active false] set bCheckSound 0]
      if id != 0 and id != 2 [if bCheckSound = 0 [carefully [soundx:play-soundfile  word soundx:current-dir "button.wav" 0 0][]] set bCheckSound 1] 
      if id = 1 [let x id ask patches with [id = x] [set active true]
        if mouse-down? [set was-down? true] 
        every 0.2 [mouseClick2 0 0]]
      if id = 2 [if xcor >= -112 [set bCheckSound 0]
        ask patch 100 -100 [set plabel ""]
        ask patch 88 -112 [set plabel ""]
        ask patch 100 -112 [set plabel ""]
        if xcor < -112 [ask patches with [pxcor <= -112 and id = 2] [set active true]
        if mouse-down? [set was-down? true]
        every 0.2 [mouseClickCloseBuild set was-down? false]]]
      if (id > 5 and id <= 13) or (id <= -2 and id >= -4) or id = 2 [if id != 2 [let x id ask patches with [id = x] [set active true]]
        ifelse id != 11 and id > 5 and id < 12 [ask patch 93 -112 [set plabel-color 3 set plabel "Cost: "]] [ask patch 93 -112 [set plabel ""]]
        if buyErrorHold != 0 [ask patch 93 -112 [set plabel ""] ask patch 105 -112 [set plabel ""]]
        let wordx 105 let wordy -100 let costx 105 let costy -112
        if id = 6 [ask patch wordx wordy [set plabel "Relay"]
          if buyErrorHold = 0 [ask patch costx costy [set plabel "20"] ask patch 110 -112 [set plabel ""]]]
        if id = 7 [ask patch wordx wordy [set plabel "Miner"]
          if buyErrorHold = 0 [ask patch costx costy [set plabel "50"] ask patch 110 -112 [set plabel ""]]]
        if id = 8 [ask patch wordx wordy [set plabel "Reactor"]
          if buyErrorHold = 0 [ask patch costx costy [set plabel "100"] ask patch 110 -112 [set plabel ""]]]
        if id = 9 [ask patch wordx wordy [set plabel "Laser"]
          if buyErrorHold = 0 [ask patch costx costy [set plabel "70"] ask patch 110 -112 [set plabel ""]]]
        if id = 10 [ask patch wordx wordy [set plabel "Missile"]
          if buyErrorHold = 0 [ask patch costx costy [set plabel "120"] ask patch 110 -112 [set plabel ""]]]
        if id = 0 or id = 1 or id = 2 [ask patch wordx wordy [set plabel ""] ask patch costx costy [set plabel ""] ask patch 93 -112 [set plabel ""]]
        if id = 11 [ask patch wordx wordy [set plabel "Cancel"] ask patch costx costy [set plabel ""]]
        if id = -2 [ask patch wordx wordy [set plabel "Save"] ask patch costx costy [set plabel ""]]
        if id = -3 [ask patch wordx wordy [set plabel "Pause"] ask patch costx costy [set plabel ""]]
        if id = -4 [ask patch wordx wordy [set plabel "Main Menu"] ask patch costx costy [set plabel ""]]
        if id = 12 [ask patch wordx wordy [set plabel "Upgrade" if buyErrorHold = 0 [ask patch 110 -112 [set plabel ""]]] 
          set coreMax 9 set minerMax 2 set laserMax 4 set relayMax 0
          set coreMulti 20 set minerMulti 50 set laserMulti 40 set relayMulti 0
          ifelse [level] of turtle id-HelperWho <  runresult (word (butlast (word id-HelperSpecies)) "Max")
           [if buyErrorHold = 0 [ask patch costx costy [ask patch 93 -112 [set plabel "Cost: " set plabel-color 3]
               set plabel (50 + (([level] of turtle id-HelperWho) + 1) * runresult (word (butlast (word (id-HelperSpecies))) "multi"))]]]
           [if buyErrorHold = 0 [ask patch costx costy [set plabel "MAXED"] ask patch 93 -112 [set plabel ""]]]]
        if id = 13 [ask patch wordx wordy [set plabel "Sell"]
          ask patch costx costy [carefully [set plabel [worth] of turtle id-HelperWho] [set plabel "" mouseClickCloseBuild set was-down? false]]]
        ask patch wordx wordy [set plabel-color 3]
        ask patch costx costy [set plabel-color 3]
        ]
      ifelse id = 7 [ask addons [set outin 1]] [ask addons [set outin 0]]
      if id = 11 [if mouse-down? [set was-down? true] 
        every 0.2 [mouseClickCancelBuy]]
      if buying? = 1 [let x id ask patches with [id != x] [set active false]
        set buyClickGlobalSub (id - 5)]
         ;111  
      if xcor > -105 and (ycor > -100 or buying? = 0) and not any? turtles with [buyState? = 1] [
      ifelse count turtles in-radius 2 with [who > 0 and breed != ranges and breed != addons and menuItem? = 0 and (construction >= 0 or breed = depots or uniqueID = 666)] >= 1 ;and 
      ;count turtles in-radius 2 with [who > 0 and breed != ranges and breed != addons and menuItem? = 0 and construction > 0] <= 3;turtles-here > 1 
      ;SDFJLKSJDLKJSDLFK AAAAAAAAAHGGHHG
      [ifelse id-ing? = 0 [ 
          set dummyY [who] of (turtles in-radius 3) with [who > 0 and breed != ranges and breed != addons and menuItem? = 0]
        if mouse-down? [set was-down? true]
        every 0.2 [mouseClickCloseBuild
                    carefully [mouseClickIdentify ([breed] of turtle first sort dummyY) dummyY] [print error-message]
                    ifelse ([breed] of turtle first sort dummyY != depots  and [uniqueID] of turtle first sort dummyY != 666) 
                     [mouseClick2 1 dummyY] [set was-down? false]]] 
      [if mouse-down? [set was-down? true set dummyY [who] of (turtles in-radius 3) with [who > 0 and breed != ranges and breed != addons and menuItem? = 0]]
                    mouseClickCloseBuild
                    carefully [mouseClickIdentify ([breed] of turtle first sort dummyY) dummyY] [print error-message]
                    ifelse ([breed] of turtle first sort dummyY != depots  and [uniqueID] of turtle first sort dummyY != 666) 
                     [mouseClick2 1 dummyY] [set was-down? false]]
        ]
      [if mouse-down? [set was-down? true] 
        every 0.2 [mouseClickGeneral 
          if buying? != 1 [mouseClickCloseBuild set was-down? false]]
      ]]
    ]
    if buyClickGlobalSub != 0 [let ided [id] of patch mouse-xcor mouse-ycor
      if mouse-down? [set was-down? true]
      if [pcolor] of patch mouse-xcor mouse-ycor = 106 and ided > 0 and ided < 12 [mouseClickBuy buyClickGlobalSub]
      if ided = -2 [mouseClickSave]
      if ided = -3 [mouseClickPause]
      if ided = -4 [mouseClickBack]
      if ided = 12 [mouseClickUpgrade]
      if ided = 13 [mouseClickSell]    
      ]
    
    ask depots with [dataSource < 0] [set dataSource 0 ask first [end2] of links with [end1 = myself] [set mC mC - 1]]
    if bPulse = 16 [ask links with [dead? = 0] [set color 5] ask links with [dead? = 1] [set color 0]]
    ifelse bPulse <= 0 [set bPulse 20 
      set survivalTime survivalTime + 1
      ask turtles with [uniqueID != 666] [if health < maxHealth [set health health + 1]]
      ask links with [dead? = 0 and pulser? = 0] [ifelse laser? = 0 [set color sky] [set color red]]
      ask turtles with [who > 0 and breed != ranges and breed != depots and breed != cores and uniqueID != 666 and menuItem? = 0 and shape != "hammer"] [
        if building? = 1 and construction < 100 and connected? [
          if breed = relays [set construction construction + 5 ask cores [set energy energy - 5]]
          if breed = miners [set construction construction + 4 ask cores [set energy energy - 10]
            set color construction / 20 + 60]
          if breed = powerPlants [set construction construction + 2.5 ask cores [set energy energy - 20]
            set color construction / 10 - 0.01]
          if breed = lasers [set construction construction + 3 ask cores [set energy energy - 12]
            set color construction / 20 + 10]
          if breed = missiles [set construction construction + 2 ask cores [set energy energy - 30]]]
        if construction >= 100 [if connected? [set activate 1] 
          set health 100;????
          let dummy [other-end] of links with [end2 = myself or end1 = myself]
          foreach sort dummy [if [breed] of ? = miners [
              
              ]]
          if reserve <= 10 and connected? [set reserve reserve + 1]
          if not connected? [if reserve > -1 [set reserve reserve - 1]]
          ifelse reserve = -1 [set activate 0] [
          set construction construction + 1
          if breed = relays [ifelse not any? links with [end1 = myself and pulser? = 0] 
            [ask links with [end2 = myself] [set pulser? 1]]
            [ask links with [end2 = myself] [set pulser? 0]]]
          if breed = lasers [if any? turtles with [uniqueID = 666 and distance myself < [actualAOE] of myself] 
            [ask links with [end2 = myself] [set pulser? 0]
              ask cores [set energy energy - count links with [end2 = myself] * 4] 
              if attack? = 0
              [
                let targets turtles with [uniqueID = 666 and distance myself < [actualAOE] of myself]
                let target one-of targets
                if not any? targets [ask links with [end2 = myself] [set pulser? 1]]
                create-link-to target [set thickness 0.5 set laser? 1]
                ask target [set HPdrain HPdrain + [level] of myself + 1]
                set attack? 1]
              ;FOR CUTTING OFF OUT OF RANGE THINGS
              if attack? = 1 [ask links with [end1 = myself] [if link-length > [actualAOE] of end1 
                [ask end2 [set HPdrain HPdrain - [level] of other-end - 1 ask other-end [set attack? 0 ask links with [end2 = myself] [set pulser? 1]]] die]
                ]
              ]]]]
          ]
        if construction = 101 [if breed = miners [ask depots with [distance myself < [actualAOE] of myself] 
            [create-link-to myself ask myself [set mC mC + 1]]]
            if breed = relays 
            [if breed = relays [set shape "relay"]
              ask links with [end2 = myself] [set pulser? 1]
              let a turtles with [distance myself < 12 and (activate = 0 or not connected?) and (breed = powerPlants or actualAOE > 0) and uniqueID != 666]
              if any? a
              [create-links-to a 
                   ask a [set connected? true]
                ask links with [end2 = myself] [set pulser? 0]]
              ;TO DO LIMIT FOR RELAY CONNECTIONS
                ask a [set connected? true set building? 1 ask myself [set conN conN + 1]]]
            
            if breed = powerPlants [set uniqueID 3 set size 4 set color 85
              ask links with [end2 = myself] [set pulser? 1]]
            
            ]
        if construction = 103 [ 
            if breed = lasers [ask links with [end2 = myself] [set pulser? 1]]
          ]
            ask turtles with [menuItem? = 0 and activate = 1] [
      if breed = miners [foreach sort links with [end2 = myself and end1 != cores and end1 != relays] [ask [end1] of ? 
        [if breed != cores and breed != relays
         [if dataSource > 0 [ask links with [end1 = myself] [ask end2 [set data data + mC * ([level] of self + 1)]]]]]
        foreach sort links with [end2 = myself] [ask ? [if [breed] of end1 != cores and [breed] of end1 != relays [ask end1 [if dataSource >= 1 [set dataSource dataSource - 0.5];WHY DOES THIS GET CALLED TWICE?
              if dataSource <= 0 [ask links with [end1 = myself] [ask end2 [ask links with [end2 = myself] [set pulser? 1]] set dead? 1]]]]]]]] 
      if breed = powerPlants [ask cores [ifelse (energy + ([level] of myself + 1) * 4) <= 999 [set energy energy + ([level] of myself + 1) * 4] [set energy 999]]]
      if breed = lasers []
      if breed = missiles []]]
      ask turtles with [uniqueID = 666] [ifelse id != 0 or (pxcor <= -60 and pycor > 75) [set hidden? true] [set hidden? false]
        if health <= 0 [foreach sort links with [end2 = myself] [ask ? [ask end1 [set attack? 0] 
              ask end2 [if id-HelperWho = [who] of self [ask range 32 [set hidden? true] 
                  ask patches with [pycor > 80 and pxcor > 100] [set plabel "" set pcolor bgStore]]
                ask turtles with [breed = relays or breed = miners or breed = lasers or breed = missiles and menuItem? != 1]
    [if not empty? sort out-link-neighbors [if not connectDetector [who] of self [set connected? false]]]
    ifelse breed = lasers
       [ask links with [end1 = myself] [ask end2 [set hpDrain hpDrain - [level] of turtle id-HelperWho - 1]
           die] die]
      [ask links with [end1 = myself] [set pulser? 1 die]]
      
      foreach sort turtles with [breed = relays and menuItem? != 1] 
     [ask ? [ifelse connectDetector [who] of ? [set connected? true][set connected? false]]]          
              die]]]]
        set health health - hpDrain * (20 - round enemyWaveID / 100)
        ifelse attacking? = 0
        [let targets turtles with [menuItem? != 1 and who != 0 and breed != depots and breed != ranges and uniqueID != 666 and construction > 10 and distance myself < [actualAOE] of myself]
        if any? targets [let tar one-of targets create-link-to tar [set laser? 1] set attacking? 1]]
        [ask links with [end1 = myself] [ask other-end [
              ifelse health <= 0 [ask myself [ask other-end [set attacking? 0]] ifelse breed = cores [set energy -1000] [die]]
              [foreach sort links with [end2 = myself] 
                [ask [end2] of ? [set health (health - (1 + (1 * wavesSurvived / 10)))]]
                ]]]]]]
    
    
      [set bPulse bPulse - 1]

    ask core 1 [if energy <= 0 [set running false]
      ifelse energy >= 500 [set coreStress 2 set color 95 ]
        [ifelse energy >= 200 [set coreStress 2 set color 96]
           [ifelse energy >= 100 [set coreStress 4 set color 98]
             [ifelse energy >= 40 [set coreStress 8 set color 18]
               [if energy < 10 [set coreStress 16 set color 15]]]]]
      
      ifelse energyGenCounter = 0 [ifelse (energy + 16 / coreStress) <= 999 [set energy energy + 16 / coreStress] [set energy 999] set energyGenCounter 20 - (level + 1)]
      [set energyGenCounter energyGenCounter - 1]
    ]
    ifelse survivalTime = 50 and bPulse = 0 [launchWave fighters 5 1 set wavesSurvived wavesSurvived + 1]
    [if survivalTime > 90
       [if (survivalTime mod (50 - round (wavesSurvived / 10))) = 0 and bPulse = 0 
         [launchWave fighters 5 + wavesSurvived (wavesSurvived + 1) set wavesSurvived wavesSurvived + 1]]]
    
    if bPulse mod 2 = 0 [
    ask turtles with [breed = fighters or breed = bombers] [let goal turtles with [menuItem? != 1 and who != 0 and breed != depots and breed != ranges and uniqueID != 666 and construction > 10 and distance myself < [actualAOE] of myself - 0.5]
      ifelse any? goal [if attacking? = 0 [set heading towards one-of goal]]
      [set heading towards core 1 fd .1]]]
    
    tick
    game]
  
  [endSequence 
   set restart restart + 1 
   setup]]
    [ask patches with [id = -3] [ifelse active [set pcolor 106] [set pcolor 105]]      
      ask turtle 0 [setxy mouse-xcor mouse-ycor
        
        ifelse id = -3 [carefully [if bCheckSound = 0 [soundx:play-soundfile  word soundx:current-dir "button.wav" 0 0] set bCheckSound 1] []
          ask patches with [id = -3] [set active true]
          if mouse-down? [set was-down? true]
          mouseClickPause]
        [ask patches with [id = -3] [set active false] set bCheckSound 0]
        if count turtles in-radius 1 > 1 and count turtles in-radius 1 <= 3
      [if id-ing? = 0 [set dummyY [who] of (turtles in-radius 4) with [who > 0 and breed != ranges and breed != addons]]
        if mouse-down? [set was-down? true]
        every 0.2 [mouseClickCloseBuild
          carefully [mouseClickIdentify ([breed] of turtle first sort dummyY) dummyY] []
          mouseClick2 1 dummyY]]]
    tick
    game]
end


to launchWave [etype number wave]
  let x random 8
  crt number [set heading x * 45;set heading random 180 
    set size 5 set color 125
    set breed etype set shape "fighter"
    set enemyWaveID wave
    set uniqueID 666
    if etype = fighters [set actualAOE 10 set connected? false]
    set health 95 + wave * 5]
  let a turtles with [enemyWaveID = wave]
  ask a [rt who mod number * 5 fd 10 set heading x * 45 + random 20 - random 20
    fd max-pxcor * sqrt 2 - 0.5 rt 180 set heading towards core 1
  ;ifelse x mod 2 = 0 [ask a [fd max-pxcor]] [ask a [fd max-pxcor * sqrt 2 - 0.5]]
  ifelse random 2 = 1 [rt 90 fd random 8 rt -90 fd random 8] [rt -90 fd random 8 rt -90 fd random 8]
    set heading towards core 1 + random 10 - random 10 fd 8 set heading towards core 1]
  ;while [round [xcor] of turtles with [enemyWaveID = wave] != max-pxcor or
  ;round [xcor] of turtles with [enemyWaveID = wave] != min-pxcor or
  ;round [ycor] of turtles with [enemyWaveID = wave] != max-pycor or
  ;round [ycor] of turtles with [enemyWaveID = wave] != min-pycor]
  ;[ask turtles with [enemyWaveID = wave] [fd 1]]
  ;This is a mess of random things I lost track OOPS
  
end

to mouseClickUpgrade
  let is-down? mouse-down?
  if clickTest [
    if not is-string? [plabel] of patch 105 -112 [
      ifelse data >= [plabel] of patch 105 -112 [
    carefully [set data data - [plabel] of patch 105 -112] []
    ask turtle id-HelperWho [if level < runresult (word (butlast (word ([breed] of self))) ("Max")) [set level level + 1 
        if [breed] of self = cores [set aoe aoe + 1 set actualAOE actualAOE + 1 set health health + 20]
        if [breed] of self = lasers [set actualAOE actualAOE + 2 set health health + 10 ask range 32 [set size size + 4]]
      ]]]
      [ask patch 110 -112 [set plabel "Not enough" set plabel-color 3]
       ask patch 105 -112 [set plabel ""]
       ask patch 100 -112 [set plabel ""]
       set buyErrorHold 20
        ]
    ]]
  set was-down? is-down?
end
to mouseClickSell
  let is-down? mouse-down?
  ifelse clickTest [
    set data data + [worth] of turtle id-HelperWho
    set id-ing? 0
    ask range 32 [set hidden? true]
    ask turtles with [breed = relays or breed = miners or breed = lasers or breed = missiles and menuItem? != 1]
    [if not empty? sort out-link-neighbors [if not connectDetector [who] of self [set connected? false]]]
    ask ranges [set hidden? false] ask patches with [pycor > 80 and pxcor > 100] [set plabel ""]
    ask turtle id-HelperWho [ifelse breed = lasers
       [ask links with [end1 = myself] [ask end2 [set hpDrain hpDrain - [level] of turtle id-HelperWho - 1]
           die]
       die]
      [ask links with [end1 = myself] [set pulser? 1 die]]
        ask links with [end2 = myself] [set pulser? 1 die]
        die]
      foreach sort turtles with [breed = relays and menuItem? != 1] 
     [ask ? [ifelse connectDetector [who] of ? [set connected? true][set connected? false]]]    
  ]
  [set was-down? is-down?]
end

to-report connectDetector [turtleNum]
  let sources filter [[breed] of ? = cores or [breed] of ? = powerPlants] sort [in-link-neighbors] of turtle turtleNum
  let connections (sort ([in-link-neighbors] of turtle turtleNum) with [breed = relays])
  let con? false
    ifelse not empty? sources [report true]
     [ifelse not empty? connections 
       [foreach connections [
           if connectDetector [who] of ? [set con? true]]
       ifelse con? [report true] [report false]]
       [report false]]
end
@#$#@#$#@
GRAPHICS-WINDOW
344
10
782
469
120
120
1.78
1
16
1
1
1
0
0
0
1
-120
120
-120
120
1
1
1
ticks
30.0

TEXTBOX
42
36
192
66
Rule 1: Don't spam the mouse clicks...
12
0.0
1

TEXTBOX
42
81
192
137
Rule 2: Click again if something doesn't register.
12
0.0
1

BUTTON
52
189
115
222
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
137
189
200
222
go
goScreen
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
205
22
308
55
Music?
Music?
1
1
-1000

TEXTBOX
193
67
343
157
The music is quite loud.\nFeel free to switch it off \nbefore anything is pressed,\nor you'll have to listen through\nit once, sorry!
12
0.0
1

TEXTBOX
39
62
189
90
_______________________
11
0.0
1

TEXTBOX
38
121
188
139
________________________
11
0.0
1

TEXTBOX
40
13
190
31
_______________________
11
0.0
1

TEXTBOX
68
360
218
430
Also I apologize for the small screen/ any mis-aligned text. Turning Screen-Res on will resize the window to 1080x720, but not fix text. 
11
0.0
1

SWITCH
64
298
183
331
Screen-Res
Screen-Res
0
1
-1000

@#$#@#$#@
## .Defend

.Defend is a defense game, as the title would suggest. Protect your core from losing all its health or expending all its energy.

## Unit Details

Relays are one way. They will not transmit energy backwards if a new power plant is built down the line.

## Controls

All controls are click-based, and with hours of aggravation, most of it works! Enjoy.

## Disclaimer

The difficulty scaling in the game is way out of sync. Also, this qualifies as the beta version, with limited features.


## Credits and Resources

Alpha Tester: Simon Chen
Soundx extension: https://github.com/eyalof . Thanks, Mister!
Background Music: https://www.youtube.com/watch?v=xaJnPv18r70

## Bugs
Clicking to place units will not always work on the first try. Oftentimes the ranges will disappear as well if this bug occurs.
A general click will not work in the paused state.
Ranges are occassionally left visible when opening/closing the menu.
Depots are unidentifiable unless the menu is first opened upon starting the game.

##Features to add
Missile tower
More reliable health regeneration, perhaps a tower for healing. 
More reasonable scaling of difficulty and pricing.
Fast foward state.
New enemy types: Bomber, Kamikaze?
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

core0
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -2674135 true false 120 120 60
Circle -955883 true false 15 210 60
Circle -2674135 true false 19 215 52
Circle -1184463 true false 26 224 38

core1
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60
Circle -955883 true false 9 204 72
Circle -2674135 true false 14 210 62
Circle -1184463 true false 20 218 50
Circle -1184463 true false 255 135 30

core2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 62 61 180
Circle -16777216 true false 90 90 120
Circle -2674135 true false 120 120 60
Circle -955883 true false 3 198 85
Circle -2674135 true false 7 203 76
Circle -1184463 true false 12 210 66
Circle -955883 true false 238 118 34
Circle -2674135 true false 243 124 25
Circle -2674135 true false 253 129 16
Circle -1184463 true false 252 131 12

core3
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 62 61 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60
Circle -955883 true false 9 204 72
Circle -2674135 true false 16 212 58
Circle -1184463 true false 23 221 44
Circle -955883 true false 225 105 60
Circle -2674135 true false 231 112 48
Circle -2674135 true false 253 129 16
Circle -1184463 true false 239 118 38
Circle -1184463 true false 74 33 27

core4
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -2674135 true false 70 30 36
Circle -7500403 true true 62 61 180
Circle -16777216 true false 90 90 120
Circle -2674135 true false 120 120 60
Circle -16777216 true false 16 212 58
Circle -2674135 true false 24 220 42
Circle -1184463 true false 28 226 34
Circle -955883 true false 218 98 74
Circle -2674135 true false 223 104 64
Circle -2674135 true false 253 129 16
Circle -1184463 true false 234 113 48
Circle -1184463 true false 74 33 27
Circle -1184463 true false 21 119 26
Circle -1184463 true false 226 221 31

core5
false
0
Circle -7500403 true true -1 1 300
Circle -16777216 true false 30 30 240
Circle -2674135 true false 74 31 26
Circle -7500403 true true 62 61 180
Circle -16777216 true false 90 90 120
Circle -2674135 true false 120 120 60
Circle -16777216 true false 16 212 58
Circle -2674135 true false 24 220 42
Circle -1184463 true false 28 226 34
Circle -955883 true false 226 105 62
Circle -2674135 true false 236 115 42
Circle -2674135 true false 253 129 16
Circle -1184463 true false 241 120 34
Circle -1184463 true false 79 38 16
Circle -1184463 true false 228 223 26
Circle -2674135 true false 17 116 37
Circle -1184463 true false 21 119 26

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

datachip
false
5
Rectangle -7500403 true false 75 30 225 270
Line -16777216 false 210 30 210 195
Line -16777216 false 90 30 90 195
Line -16777216 false 90 195 210 195
Rectangle -10899396 true true 120 34 200 45
Rectangle -10899396 true true 120 62 200 75
Rectangle -10899396 true true 120 93 200 105
Line -16777216 false 90 210 90 255
Line -16777216 false 105 210 105 255
Line -16777216 false 120 210 120 255
Line -16777216 false 135 210 135 255
Line -16777216 false 165 210 165 255
Line -16777216 false 180 210 180 255
Line -16777216 false 195 210 195 255
Line -16777216 false 210 210 210 255
Rectangle -7500403 true false 84 232 219 236
Rectangle -16777216 false false 101 172 112 184
Rectangle -10899396 true true 99 170 114 185

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fighter
true
0
Polygon -7500403 true true 105 30 60 270 150 90 240 270 195 30 150 210

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

hammer
false
1
Polygon -11221820 true false 147 294 152 294 152 300 182 299 189 294 167 93 203 82 213 71 212 55 227 71 226 49 209 25 200 31 202 61 149 73 152 106 169 289
Polygon -6459832 true false 128 87 145 292 161 297 174 296 180 290 156 82
Polygon -2674135 true true 125 89 146 293 162 296 138 88
Polygon -7500403 true false 60 21 55 26 56 36 67 102 71 106 78 106 86 104 93 101 95 96 93 88 96 85 102 91 110 93 176 84 190 78 202 71 207 65 208 55 205 29 216 37 223 47 229 53 233 62 232 47 228 33 222 20 208 8 184 5 151 6 110 14 94 17 87 23 85 30 83 30 80 22 76 19 71 19

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

laser1
true
0
Rectangle -11221820 true false 147 -438 152 299

laser2
true
0
Rectangle -13791810 true false 147 -438 152 299

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pause
false
0
Rectangle -2674135 true false 75 45 120 255
Rectangle -2674135 true false 180 45 225 255

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

play
false
0
Polygon -2674135 true false 75 60 75 255 255 150

powerplant
true
0
Circle -7500403 true true 11 12 277
Polygon -1184463 true false 150 150 148 288 158 290 165 289 174 288 185 285 199 280 208 275 219 270 227 266 238 257 252 244 263 230
Polygon -1184463 true false 150 150 150 13 160 13 170 14 184 16 197 20 207 24 215 29 230 37 242 46 255 59 263 71 273 87 277 97
Polygon -1184463 true false 150 150 32 79 23 96 17 111 13 128 12 145 12 162 15 181 21 205 27 216 35 227

relay
false
9
Circle -1 true false 0 0 300
Circle -13791810 true true 42 42 216

relay_dormant
false
9
Circle -7500403 true false 0 0 300
Circle -13791810 true true 42 42 216

save
false
0
Rectangle -7500403 true true 75 105 225 255
Line -16777216 false 210 105 210 180
Line -16777216 false 90 105 90 180
Line -16777216 false 90 180 210 180
Rectangle -1 true false 120 122 200 135
Rectangle -10899396 true false 99 155 114 170

sell
false
0
Circle -2674135 true false 33 33 234
Circle -10899396 true false 108 69 85
Circle -10899396 true false 104 152 85
Circle -2674135 true false 83 150 88
Circle -2674135 true false 131 69 88
Polygon -10899396 true false 123 42 157 251 173 256 137 50
Circle -10899396 true false 132 210 26
Circle -10899396 true false 142 70 26

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

title1
false
0
Rectangle -7500403 true true 75 240 105 270

title2
false
0
Polygon -7500403 false true 43 31 83 31 109 32 135 35 163 40 189 49 213 62 231 82 244 109 248 149 246 181 240 211 226 234 205 249 181 259 150 266 117 270 84 272 42 272

title3
false
0
Line -7500403 true 225 45 60 45
Line -7500403 true 60 45 60 270
Line -7500403 true 60 270 240 270
Line -7500403 true 62 151 232 151

title4
false
0
Line -7500403 true 225 45 75 45
Line -7500403 true 75 45 75 270
Line -7500403 true 75 165 210 165

title5
false
0
Line -7500403 true 75 35 75 270
Line -7500403 true 75 34 225 270
Line -7500403 true 225 270 225 36

titlespace
false
0
Rectangle -7500403 true true 45 210 255 255

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.1.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 135 165
Line -7500403 true 150 150 165 165

@#$#@#$#@
0
@#$#@#$#@
