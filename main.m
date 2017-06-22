clc; close all; clear;

% Change the image value here 
template = imread ('data/template/1.jpg');

template_resize = imresize (template, [150 150]);

BW = rgb2gray (template_resize);

BW = single (BW);

best = [0 0 0];

for n=1:3
    filename = int2str (n);
    s = strcat (filename, '.jpg');
    s  = strcat ('data/test/', s);
    test = imread (s);
    test = imresize (test, [500 500]);
    BW_test = rgb2gray (test);
    BW_test = single (BW_test);
    
    [ftemp, dtemp] = vl_sift (BW);
    [ftest, dtest] = vl_sift (BW_test);

    [matches, scores] = vl_ubcmatch (dtemp, dtest);

    best (1, n) = norm (matches);
end

[val, loc] = max (best);

switch loc
    case 1
        announce = 'Its a Cat!';
        disp (announce)
    case 2
        announce = 'Its a Ducking!';
        disp (announce)
    case 3
        announce = 'Its a Penguin!';
        disp (announce);
end

view_name = int2str (loc);
view_name = strcat (view_name, '.jpg');
view_name  = strcat ('data/test/', view_name);
view = imread (view_name);
text = insertText (view, [0 0], announce);
imshow (text);