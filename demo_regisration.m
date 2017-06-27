clc; close all; clear;
clear;clc;close all;
T=pcread('test3.pcd');
test3=T.Location;
d=2;

%% standard PCA
disp('Performing standard PCA...');

PCA_test3=PCA(test3,d);
figure;hold on;

plot(PCA_test3(1:2:end,1),PCA_test3(1:2:end,2),'k.','MarkerSize',25);
axis off;

drawnow;
F = getframe(gcf);
[X, Map] = frame2im(F);

template = X;

template_resize = imresize (template, [150 150]);

BW = rgb2gray (template_resize);

BW = single (BW);

best = [0 0 0];

for n=1:4
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
src_select = 0;

switch loc
    case 1
        announce = 'Its a Cat!';
        src_select = 1;
        disp (announce)
    case 2
        announce = 'Its a Ducking!';
        src_select = 2;
        disp (announce)
    case 3
        announce = 'Its a Penguin!';
        src_select = 3;
        disp (announce);
    case 4
        announce = 'Its the Car Part！';
        src_select = 4;
        disp (announce)      
end

point_set_name = int2str(src_select);
view_name = int2str (loc);
view_name = strcat (view_name, '.jpg');
view_name  = strcat ('data/test/', view_name);
view = imread (view_name);
text = insertText (view, [0 0], announce);
imshow (text);

%% 4. Apply the ICP/CPD
p = strcat (point_set_name, '.pcd');
p  = strcat ('data/point_cloud/', p);
src = pcread(p);

source = test3';
target1=src.Location;
target = target1';


%% Run ICP (fast kDtree matching and extrapolation)

[Ricp Ticp ER t] = icp(target, source, 50, 'Matching', 'kDtree', 'Extrapolation', true);

% Transform data-matrix using ICP result
Dicp = Ricp * source + repmat(Ticp, 1, 9279);

% Plot model points blue and transformed points red
figure;hold on;
plot3(target(1,:),target(2,:),target(3,:),'bo',source(1,:),source(2,:),source(3,:),'r.');
axis equal;
xlabel('x'); ylabel('y'); zlabel('z');


% Plot the results
figure; hold on;
plot3(target(1,:),target(2,:),target(3,:),'bo',Dicp(1,:),Dicp(2,:),Dicp(3,:),'r.');
axis equal;
xlabel('x'); ylabel('y'); zlabel('z');

% 5. Get Final Transformation
trans = cat (2, Ricp, Ticp);
dummy = [0 0 0 1];
trans = cat (1, trans, dummy);

disp (trans);

%% Example 6. Rigid CPD point-set registration. Full options intialization.

% Set the options
target=target';
source=source';
opt.method='rigid'; % use rigid registration
opt.viz=1;          % show every iteration
opt.outliers=0.5;   % use 0.5 noise weight

opt.normalize=1;    % normalize to unit variance and zero mean before registering (default)
opt.scale=1;        % estimate global scaling too (default)
opt.rot=1;          % estimate strictly rotational matrix (default)
opt.corresp=0;      % do not compute the correspondence vector at the end of registration (default). Can be quite slow for large data sets.

opt.max_it=100;     % max number of iterations
opt.tol=1e-8;       % tolerance
opt.fgt=1;          % [0,1,2] if > 0, then use FGT. case 1: FGT with fixing sigma after it gets too small (faster, but the result can be rough)
                    %  case 2: FGT, followed by truncated Gaussian approximation (can be quite slow after switching to the truncated kernels, but more accurate than case 1)

 

% registering Y to X
Transform=cpd_register(target,source,opt);

figure,cpd_plot_iter(target, source); title('Before');
figure,cpd_plot_iter(target, Transform.Y);  title('After registering source to target');

