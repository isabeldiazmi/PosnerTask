% Isabel Diaz Miranda
% June 20th, 2017

% Posner Task

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Experimental parameters

clear all; 
rand('state', sum(100*clock)); % randomizes the internal clock of the computer, so the order won't be the same
Screen('Preference', 'SkipSyncTests', 1); % if you are displaying many things at the same time, Matlab synchronizes what is happening with what the subject is seeing

ErrorDelay = 1; % time in between errors [sec]
interTrialInterval = 0.5; 

nTrialsPerBlock = 10; 
nUnvalidCues = 2;
validCues = ones(1,nTrialsPerBlock - nUnvalidCues);
unvalidCues = zeros(1,nUnvalidCues);

KbName('UnifyKeyNames'); 
Key1 = KbName('LeftArrow'); 
Key2 = KbName('RightArrow'); % indicate key inputs
corrkey = [80, 79]; % left and right arrow

spaceKey = KbName('space'); 
escKey = KbName('ESCAPE'); % esc to leave the experiment

gray = [127 127 127]; 
white = [255 255 255]; 
black = [0 0 0];
bgcolor = white; 
textcolor = black;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Sound feedback
% BeepFreq = [800 1300 2000]; BeepDur = [.1 .1 .1];
% Beep1 = MakeBeep(BeepFreq(1), BeepDur(1));
% Beep2 = MakeBeep(BeepFreq(2), BeepDur(2));
% Beep3 = MakeBeep(BeepFreq(3), BeepDur(3));
% Beep4 = [Beep1 Beep2 Beep3];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Login prompt and open file for writing data out
prompt = {'Outputfile', 'Subject''s number:', 'age', 'gender', 'group', 'Num of Blocks'}; % input tags
defaults = {'PosnerTask', '98', '18', 'F', 'control' , '3'}; % default answers for the tags
answer = inputdlg(prompt, 'ChoiceRT', 2, defaults); % titles
[output, subid, subage, gender, group, nBlocks] = deal(answer{:}); % all input variables are strings
outputname = [output gender subid group subage '.xls'];
nblocks = str2num(nBlocks); % convert string to number for subsequent reference

if exist(outputname) == 2 % check to avoid overiding an existing file
    fileproblem = input('That file already exists! Append a .x (1), overwrite (2), or break (3/default)?');
    if isempty(fileproblem) | fileproblem == 3
        return;
    elseif fileproblem == 1
        outputname = [outputname '.x'];
    end
end
outfile = fopen(outputname,'w'); % open a file for writing data out
fprintf(outfile, 'subjectID\t age\t gender\t group\t blockNumber\t trialNumber\t validCue\t answer\t accuracy\t reactionTime\t \n'); %column names for the excel

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Screen parameters
[mainwin, screenrect] = Screen(0, 'OpenWindow');
Screen('FillRect', mainwin, bgcolor);
center = [screenrect(3)/2 screenrect(4)/2]; % [y x]
Screen(mainwin, 'Flip');

% Load images
im = imread('Default.png'); 
default = Screen('MakeTexture', mainwin, im);
im = imread('Cue.png'); 
cue = Screen('MakeTexture', mainwin, im);
im = imread('Target.png'); 
target = Screen('MakeTexture', mainwin, im);
im = imread('Fixation.png'); 
fixation = Screen('MakeTexture', mainwin, im);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Experimental instructions, wait for a spacebar response to start
Screen('FillRect', mainwin ,bgcolor);
Screen('TextSize', mainwin, 24);
Screen('DrawText',mainwin,['Cueing experiment:'] ,center(1)-350,center(2)-60,textcolor);
Screen('DrawText',mainwin,['You will see a fixation point and two boxes.'] ,center(1)-350,center(2)-30,textcolor);
Screen('DrawText', mainwin, ['Determine the target location with the left or right arrow.'], center(1)-350, center(2), textcolor);
Screen('DrawText',mainwin,['Press spacebar to start the experiment.'] ,center(1)-350,center(2)+60,textcolor);

Screen('Flip',mainwin);

keyIsDown = 0;
while 1
    [keyIsDown, secs, keyCode] = KbCheck;
    if keyIsDown
        if keyCode(spaceKey)
            break;
        elseif keyCode(escKey)
            ShowCursor;
            fclose(outfile);
            Screen('CloseAll');
            return;
        end
    end
end
WaitSecs(0.3);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Block loop

%for a = 1:str2num(nBlocks)
    Screen('FillRect', mainwin, bgcolor);
%     Screen('TextSize', mainwin, 24);
%     text = strcat('Block No. ', nBlocks);
%     Screen('DrawText', mainwin, text, center(1)-350,center(2)+60, textcolor);
%     
%     keyIsDown = 0;
%     while 1
%         [keyIsDown, secs, keyCode] = KbCheck;
%         if keyIsDown
%             if keyCode(spaceKey)
%                 break;
%             elseif keyCode(escKey)
%                 ShowCursor;
%                 fclose(outfile);
%                 Screen('CloseAll');
%                 return;
%             end
%         end
%     end
%       
    blockTrials = horzcat(validCues,unvalidCues); % concatenates the arrays of cues
    blockTrials = blockTrials(randperm(length(blockTrials))); % mixes the new array
    
    % Trial loop
    for i = 1:nTrialsPerBlock;
        c = blockTrials(i); % indicates if the cue is valir or invalid
        s = randperm(2,1)-1; % indicates if the cue will be on the right or left side
        
        Screen('DrawTexture', mainwin, fixation, [], [center(1)-9 center(2)-10 center(1)+9 center(2)+10]) % [left top right bottom]
        Screen('DrawTexture', mainwin, default, [], [center(1)-400 center(2)-50 center(1)-300 center(2)+50]) 
        Screen('DrawTexture', mainwin, default, [], [center(1)+300 center(2)-50 center(1)+400 center(2)+50]) 
        Screen('Flip', mainwin);
        
        WaitSecs(1);
        
        if c == 1
            if s == 1
                Screen('DrawTexture', mainwin, fixation, [], [center(1)-9 center(2)-10 center(1)+9 center(2)+10]) % [left top right bottom]
                Screen('DrawTexture', mainwin, default, [], [center(1)-400 center(2)-50 center(1)-300 center(2)+50]) 
                Screen('DrawTexture', mainwin, cue, [], [center(1)+300 center(2)-50 center(1)+400 center(2)+50]) 
                Screen('Flip', mainwin);

                WaitSecs(0.5);

                Screen('DrawTexture', mainwin, fixation, [], [center(1)-9 center(2)-10 center(1)+9 center(2)+10]) % [left top right bottom]
                Screen('DrawTexture', mainwin, default, [], [center(1)-400 center(2)-50 center(1)-300 center(2)+50]) 
                Screen('DrawTexture', mainwin, target, [], [center(1)+300 center(2)-50 center(1)+400 center(2)+50]) 
                Screen('Flip', mainwin);
            else
                Screen('DrawTexture', mainwin, fixation, [], [center(1)-9 center(2)-10 center(1)+9 center(2)+10]) % [left top right bottom]
                Screen('DrawTexture', mainwin, cue, [], [center(1)-400 center(2)-50 center(1)-300 center(2)+50]) 
                Screen('DrawTexture', mainwin, default, [], [center(1)+300 center(2)-50 center(1)+400 center(2)+50]) 
                Screen('Flip', mainwin);

                WaitSecs(0.5);

                Screen('DrawTexture', mainwin, fixation, [], [center(1)-9 center(2)-10 center(1)+9 center(2)+10]) % [left top right bottom]
                Screen('DrawTexture', mainwin, target, [], [center(1)-400 center(2)-50 center(1)-300 center(2)+50]) 
                Screen('DrawTexture', mainwin, default, [], [center(1)+300 center(2)-50 center(1)+400 center(2)+50]) 
                Screen('Flip', mainwin);
            end
        else
            if s == 1
                Screen('DrawTexture', mainwin, fixation, [], [center(1)-9 center(2)-10 center(1)+9 center(2)+10]) % [left top right bottom]
                Screen('DrawTexture', mainwin, cue, [], [center(1)-400 center(2)-50 center(1)-300 center(2)+50]) 
                Screen('DrawTexture', mainwin, default, [], [center(1)+300 center(2)-50 center(1)+400 center(2)+50]) 
                Screen('Flip', mainwin);

                WaitSecs(0.5);

                Screen('DrawTexture', mainwin, fixation, [], [center(1)-9 center(2)-10 center(1)+9 center(2)+10]) % [left top right bottom]
                Screen('DrawTexture', mainwin, default, [], [center(1)-400 center(2)-50 center(1)-300 center(2)+50]) 
                Screen('DrawTexture', mainwin, target, [], [center(1)+300 center(2)-50 center(1)+400 center(2)+50]) 
                Screen('Flip', mainwin);
            else
                Screen('DrawTexture', mainwin, fixation, [], [center(1)-9 center(2)-10 center(1)+9 center(2)+10]) % [left top right bottom]
                Screen('DrawTexture', mainwin, default, [], [center(1)-400 center(2)-50 center(1)-300 center(2)+50]) 
                Screen('DrawTexture', mainwin, cue, [], [center(1)+300 center(2)-50 center(1)+400 center(2)+50]) 
                Screen('Flip', mainwin);

                WaitSecs(0.5);

                Screen('DrawTexture', mainwin, fixation, [], [center(1)-9 center(2)-10 center(1)+9 center(2)+10]) % [left top right bottom]
                Screen('DrawTexture', mainwin, target, [], [center(1)-400 center(2)-50 center(1)-300 center(2)+50]) 
                Screen('DrawTexture', mainwin, default, [], [center(1)+300 center(2)-50 center(1)+400 center(2)+50]) 
                Screen('Flip', mainwin);
            end
        end 
        
        timeStart = GetSecs; % now record  response (at the same time that the participant is doing the experiment)
        keyIsDown = 0; 
        correct = 0; 
        rt = 0;
        answer = -1;
        
        while 1
            [keyIsDown, secs, keyCode] = KbCheck;
            FlushEvents('keyDown');
            if keyIsDown
                nKeys = sum(keyCode);
                if nKeys == 1 
                    rt = 1000.*(GetSecs-timeStart); % reaction time (now - time when the question was asked)
                    keypressed=find(keyCode);
                    Screen('Flip', mainwin);
                    break;
                elseif keyCode(escKey)
                    ShowCursor; 
                    fclose(outfile);  
                    Screen('CloseAll'); 
                    return
                end
                keyIsDown=0; keyCode=0;
            end
        end
        
        if keypressed == corrkey(1) && s == 0
            correct = 1; 
            answer = 0;
        elseif keypressed == corrkey(2) && s == 1
            correct = 1; 
            answer = 1;
        else
            WaitSecs(ErrorDelay);
        end
        
        Screen('FillRect', mainwin ,bgcolor); 
        Screen('Flip', mainwin);
        
        fprintf(outfile, '%s\t %s\t %s\t %s\t %s\t %d\t %d\t %d\t %d\t %6.2f\t \n', subid, ..., %s for string, d for integer, f for float, t for tab
            subage, gender, group, '1', i, c, answer, correct, rt);
        
        WaitSecs(interTrialInterval);
    end % end of trial loop
%end % end of block loop