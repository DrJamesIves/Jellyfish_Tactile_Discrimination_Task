function [centrePos, cx, cy, imgH, imgW, jellyLeftTex, jellyRightTex, leftPos, ...
    pcx, pcy, p_imgH, p_imgW,  preview_centrePos, preview_divisor, preview_jellyLeftTex, ...
    preview_jellyRightTex, preview_leftPos, preview_offset, preview_rightPos, ...
    preview_text_base_font_size, preview_text_y_offset, preview_starfishTex, ...
    preview_win, preview_rect, reward_video_path, ps_imgH, ps_imgW, rightPos, ...
    s_imgH, s_imgW, screen_rect, starfishTex, stim_dir, text, ...
    text_base_font_size, text_colour, text_y_offset, video_path, win,  winRect, x_screen_prop] = ...
    setup_jellyfish_visuals(bg_video_name, offset, reward_video_name, root, show_preview, transparent_stimuli)

% Author: James Ives | james.white1@bbk.ac.uk / james.ernest.ives@gmail.com
% Date: 29th July 2025
% Released under GNU GPL v3.0: https://www.gnu.org/licenses/gpl-3.0.html
% Open to collaboration—feel free to contact me!

Screen('Preference', 'SkipSyncTests', 1);   % Remove this after testing
AssertOpenGL;

% Determine preview screen size and open the preview screens
if show_preview
    preview_divisor = 4;                        % How small you'd like the preview to be 4 = 1/4
    screen_rect = Screen('Rect', 0);
    preview_width = screen_rect(3) / preview_divisor;
    preview_height = screen_rect(4) / preview_divisor;
    preview_rect = [0 0 preview_width preview_height];
    [preview_win, preview_rect] = Screen('OpenWindow', min(Screen('Screens')), ...
        [255 255 255], preview_rect);
end

% Open the main screen
screen_rect = Screen('Rect', max(Screen('Screens')));
[win, winRect] = Screen('OpenWindow', max(Screen('Screens')), [255 255 255]);
Screen('Flip', win);

% Proportion of width between preview and main screen
if show_preview
    x_screen_prop = preview_width / screen_rect(3);
end

% Allow blending for png stimuli
if transparent_stimuli
    Screen('BlendFunction', win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    if show_preview
        Screen('BlendFunction', preview_win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    end
end

% Centre the screen
[cx, cy] = RectCenter(winRect);
[pcx, pcy] = RectCenter(preview_rect);


%% On screen settings and variables
stim_dir = fullfile(root, 'stim');
video_path = fullfile(stim_dir, bg_video_name);
reward_video_path = fullfile(stim_dir, reward_video_name);
jellyLeftPath = fullfile(stim_dir, 'red-jelly-2.png');
jellyRightPath = fullfile(stim_dir, 'blue-jelly.png');
starfishPath = fullfile(stim_dir, 'orange_starfish.png');

% Load the jellyfish images
[jellyLeftImg, ~, alphaLeft] = imread(jellyLeftPath);
[jellyRightImg, ~, alphaRight] = imread(jellyRightPath);

% Resize the images for the preview window
preview_jellyLeftImg = imresize(jellyLeftImg, x_screen_prop);
preview_jellyRightImg = imresize(jellyRightImg, x_screen_prop);

% Note that these are free animations from Vecteezy but require attribution so when we
% write about them we need to include them in acknowledgements or somewhere. If we use
% a screenshot we MUST attribute the original crea  tor
% ocean scene - https://www.vecteezy.com/video/3439678-cartoon-background-underwater-sea-life
% Underwater Background Stock Videos by Seto Aquarista at Vecteezy
% Jellyfish - https://www.vecteezy.com/video/33532201-animated-jellyfish-icon-with-a-rotating-background
% Jellyfish Stock Images and Video by Gantar Pri08 at Vecteezy

% Starfish atribution - Brian Goff - Vecteezy
% Load the starfish image
[starfishImg, ~, alphaStarfish] = imread(starfishPath);

% Resize the images for the preview window
preview_starfishImg = imresize(starfishImg, x_screen_prop);

% If we are using transparent stimuli add this in
if transparent_stimuli
    % Add alpha (transparency) as 4th channel if it exists
    if ~isempty(alphaLeft)
        jellyLeftImg(:, :, 4) = alphaLeft;
    end
    if ~isempty(alphaRight)
        jellyRightImg(:, :, 4) = alphaRight;
    end
    if ~isempty(alphaStarfish)
        alphaStarfish(alphaStarfish == 127) = 0;
        alphaStarfish(alphaStarfish == 128) = 0;
        starfishImg(:, :, 4) = alphaStarfish;
    end
    
    % Resize for preview window
    p_alphaLeft = imresize(alphaLeft, x_screen_prop);
    p_alphaRight = imresize(alphaRight, x_screen_prop);
    p_alphaStarfish = imresize(alphaStarfish, x_screen_prop);
    
    % Add the alpha (transparency) to the preview image.
    preview_jellyLeftImg(:, :, 4) = p_alphaLeft;
    preview_jellyRightImg(:, :, 4) = p_alphaRight;
    preview_starfishImg(:, :, 4) = p_alphaStarfish;
end

% Make the textures
jellyLeftTex = Screen('MakeTexture', win, jellyLeftImg);
jellyRightTex = Screen('MakeTexture', win, jellyRightImg);
starfishTex = Screen('MakeTexture', win, starfishImg);

preview_jellyLeftTex = Screen('MakeTexture', preview_win, preview_jellyLeftImg);
preview_jellyRightTex = Screen('MakeTexture', preview_win, preview_jellyRightImg);
preview_starfishTex = Screen('MakeTexture', preview_win, preview_starfishImg);

% Positioning of the jellyfish, a higher offset means further from the middle
% Assumption on size is that both images will be the same
[imgH, imgW, ~] = size(jellyLeftImg);
[p_imgH, p_imgW, ~] = size(preview_jellyLeftImg);

% Starfish size
[s_imgH, s_imgW, ~] = size(starfishImg);
[ps_imgH, ps_imgW, ~] = size(preview_starfishImg);

preview_offset = round(offset * x_screen_prop);

leftPos = CenterRectOnPoint([0 0 imgW imgH], cx - offset, cy);
rightPos = CenterRectOnPoint([0 0 imgW imgH], cx + offset, cy);
centrePos = CenterRectOnPoint([0 0 s_imgW s_imgH], cx, cy);

preview_leftPos = CenterRectOnPoint([0 0 p_imgW p_imgH], pcx - preview_offset, pcy);
preview_rightPos = CenterRectOnPoint([0 0 p_imgW p_imgH], pcx + preview_offset, pcy);
preview_centrePos = CenterRectOnPoint([0 0 ps_imgW ps_imgH], pcx, pcy);

% Prep on screen text
Screen('TextFont', win, 'Arial');
Screen('TextStyle', win, 1);

Screen('TextFont', preview_win, 'Arial');
Screen('TextStyle', preview_win, 1);

text_base_font_size = 400;
preview_text_base_font_size = 80;

text_y_offset = round(cy * 0.8);
preview_text_y_offset = round(pcy);

text = '?';
text_colour = [0 0 128];

end