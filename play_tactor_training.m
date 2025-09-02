function [tact_hist] = play_tactor_training(tact_hist, stim, pahandle, pahandleMaster)

% Author: James Ives | james.white1@bbk.ac.uk / james.ernest.ives@gmail.com
% Date: 13th May 2025
% Released under GNU GPL v3.0: https://www.gnu.org/licenses/gpl-3.0.html
% Open to collaboration—feel free to contact me!

% Fills the buffers for each of tactors with the appropriate intensity using
% f1 and f2.

% Grab some settings from tact_hist
num_tactors = tact_hist.settings.num_tactors;
phase = tact_hist.training.current_phase;

if num_tactors > 0
    % Fill the buffer
    PsychPortAudio('FillBuffer', pahandle, stim);
    PsychPortAudio('FillBuffer', pahandleMaster, stim);
end

% Depending on the number of tactors play in mono or stero
if num_tactors == 1
    PsychPortAudio('Volume', pahandle, f1);
    PsychPortAudio('Start', pahandle, 1, 0, 0);
elseif num_tactors == 2
    switch phase
        case 1
            f1 = 3; f2 = 0;
            PsychPortAudio('Volume', pahandle, [], [f1, f2]);
            PsychPortAudio('Start', pahandle, 1, 0, 0);
            PsychPortAudio('Start', pahandleMaster, 1, 0, 1);
            fprintf('Training - phase 1 — instensities: L=%d, R=%d\n', f1, f2);
            tact_hist.training.correct_response = 'Left';
        case 2
            f1 = 0; f2 = 3;
            PsychPortAudio('Volume', pahandle, [], [f1, f2]);
            PsychPortAudio('Start', pahandle, 1, 0, 0);
            PsychPortAudio('Start', pahandleMaster, 1, 0, 1);
            fprintf('Training - phase 2 — instensities: L=%d, R=%d\n', f1, f2);
            tact_hist.training.correct_response = 'Right';
        case 3
            f1 = 0; f2 = 0;
            PsychPortAudio('Volume', pahandle, [], [f1, f2]);
            PsychPortAudio('Start', pahandle, 1, 0, 0);
            PsychPortAudio('Start', pahandleMaster, 1, 0, 1);
            fprintf('Training - phase 3 — instensities: L=%d, R=%d\n', f1, f2);
            tact_hist.training.correct_response = 'Neither';
        case 4
             % For the practice the intensities are preselected
            switch tact_hist.training.practice_trial
                case 1
                    f1 = 0.5; f2 = 3;
                    tact_hist.training.correct_response = 'Right';
                case 2
                    f1 = 3; f2 = 0.5;
                    tact_hist.training.correct_response = 'Left';
                case 3
                    f1 = 0.5; f2 = 2.7;
                    tact_hist.training.correct_response = 'Right';
                case 4
                    f1 = 2.4; f2 = 0.5;
                    tact_hist.training.correct_response = 'Left';
                case 5
                    f1 = 0.5; f2 = 2;
                    tact_hist.training.correct_response = 'Right';
            end

            % Randomise which tactor gets the more intense and record
            PsychPortAudio('Volume', pahandle, [], [f1, f2]);
            fprintf('Training - phase 4 — instensities: L=%d, R=%d\n', f1, f2);
            
            PsychPortAudio('Start', pahandle, 1, 0, 0);
            PsychPortAudio('Start', pahandleMaster, 1, 0, 1);
        case 5
            f1 = 0; f2 = 0;
            PsychPortAudio('Volume', pahandle, [], [f1, f2]);
            PsychPortAudio('Start', pahandle, 1, 0, 0);
            PsychPortAudio('Start', pahandleMaster, 1, 0, 1);
            fprintf('Training - phase 5 — instensities: L=%d, R=%d\n', f1, f2);
            tact_hist.training.correct_response = 'Neither';
    end
    
elseif num_tactors == 0
    % Without tactors we just display the volumes on screen
    switch phase
        case 1
            f1 = 3; f2 = 0;
            fprintf('Training - phase 1 — instensities: L=%d, R=%d\n', f1, f2);
            tact_hist.training.correct_response = 'Left';
        case 2
            f1 = 0; f2 = 3;
            fprintf('Training - phase 2 — instensities: L=%d, R=%d\n', f1, f2);
            tact_hist.training.correct_response = 'Right';
        case 3
            f1 = 0; f2 = 0;
            fprintf('Training - phase 3 — instensities: L=%d, R=%d\n', f1, f2);
            tact_hist.training.correct_response = 'Neither';
        case 4
            % For the practice the intensities are preselected
            switch tact_hist.training.practice_trial
                case 1
                    f1 = 0.5; f2 = 3;
                    tact_hist.training.correct_response = 'Right';
                case 2
                    f1 = 3; f2 = 0.5;
                    tact_hist.training.correct_response = 'Left';
                case 3
                    f1 = 0.5; f2 = 2.7;
                    tact_hist.training.correct_response = 'Right';
                case 4
                    f1 = 2.4; f2 = 0.5;
                    tact_hist.training.correct_response = 'Left';
                case 5
                    f1 = 0.5; f2 = 2;
                    tact_hist.training.correct_response = 'Right';
            end

            try
            fprintf('Training - phase 4 — instensities: L=%d, R=%d\n', f1, f2);
            catch
            end

        case 5
            f1 = 0; f2 = 0;
            fprintf('Training - phase 5 — instensities: L=%d, R=%d\n', f1, f2);
            tact_hist.training.correct_response = 'Neither';
    end
end

end