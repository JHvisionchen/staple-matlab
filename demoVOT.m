function demoVOT()
% RUN_TRACKER  is the external function of the tracker - does initialization and calls trackerMain

    %% Read params.txt
    params = readParams('params.txt');
	%% load video info
    base_path = '/media/cjh/datasets/tracking/VOT/';
    year='2015';
    video = choose_video([base_path, 'vot', year, '/']);
    params.video=video;
    
	sequence_path = [base_path, 'vot', year, '/', video,'/'];
    img_path = [base_path, 'vot', year, '/', video];
    frames{1} = 1;
    start_frame = frames{1};
    
    params.bb_VOT = csvread([sequence_path 'groundtruth.txt']);
    region = params.bb_VOT(frames{1},:);
    n_imgs = length(params.bb_VOT);
    % read all the frames in the 'imgs' subfolder
    dir_content = dir(sequence_path);

    img_files = cell(n_imgs, 1);
    for ii = 1:n_imgs
        img_files{ii} = dir_content(ii+2).name;
    end
       
    img_files(1:start_frame-1)=[];

    im = imread([sequence_path img_files{1}]);
    % is a grayscale sequence ?
    if(size(im,3)==1)
        params.grayscale_sequence = true;
    end

    params.img_files = img_files;
    params.img_path = sequence_path;

    if(numel(region)==8)
        % polygon format
        [cx, cy, w, h] = getAxisAlignedBB(region);
    else
        x = region(1);
        y = region(2);
        w = region(3);
        h = region(4);
        cx = x+w/2;
        cy = y+h/2;
    end

    % init_pos is the centre of the initial bounding box
    params.init_pos = [cy cx];
    params.target_sz = round([h w]);
    [params, bg_area, fg_area, area_resize_factor] = initializeAllAreas(im, params);
    % in runTracker we do not output anything
	params.fout = -1;
	% start the actual tracking
	trackerMain(params, im, bg_area, fg_area, area_resize_factor);
    fclose('all');
end
