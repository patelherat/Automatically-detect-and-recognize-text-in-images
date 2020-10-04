function recognize_text()
    %STEP 1
    colorImage = imread('handicapSign.jpg');        %reads the image
    
    I = rgb2gray(colorImage);                       %converts RGB image to grayscale
    
%     points = detectHarrisFeatures(I);
%     figure, imshow(I);
%     hold on;
%     x = points.selectStrongest(600);
%     plot(x);
%     %y = bwlabel(I(round(x.Location)));
%     %figure, imshow(y);
%     %plot(points.Location);    %500, 600, 750
%     %plot(points.selectUniform(500, [949, 1239]));
%     hold off;

    % Detect MSER regions.
    [mserRegions, mserConnComp] = detectMSERFeatures(I, ...     
    'RegionAreaRange',[200 8000],'ThresholdDelta', 4);                   %detect MSER features and returns MSERRegions object, parameters are area range and threshold
    
    figure, imshow(I);
    hold on;
    plot(mserRegions, 'showPixelList', true,'showEllipses', false);      %plots the MSER Regions
    title('MSER regions');
    hold off;
    
%     count1 = 0;
%     count2 = 0;
    %ans = (round(mserRegions.Location(1,:)) && round(points.Location(1, :))) && (round(mserRegions.Location(1,:)) && round(points.Location(1, :)));
%     for ms = 1 : size(mserRegions.Location, 1)
%         for p = 1 : size(points.Location, 1)
%             count1 = count1 + 1;
%             if (round(mserRegions.Location(ms, 1)) == round(points.Location(p, 1))) && (round(mserRegions.Location(ms, 2)) == round(points.Location(p, 2)))
%                 count2 = count2 + 1;
%             end
%         end
%     end
    
    %STEP 2
    % Use regionprops to measure MSER properties
    mserStats = regionprops(mserConnComp, 'BoundingBox', 'Eccentricity', ...   
        'Solidity', 'Extent', 'Euler', 'Image');                            %measure properties of image regions

    % Compute the aspect ratio using bounding box data.
    bbox = vertcat(mserStats.BoundingBox);                                  %concatenate arrays vertically
    w = bbox(:,3);                                                  %takes in the 3rd and 4th parameter(width and height)
    h = bbox(:,4);
    aspectRatio = w./h;                                             %calculates aspect ratio(width/height)

    % Threshold the data to determine which regions to remove. These thresholds
    % may need to be tuned for other images.
    filterIdx = aspectRatio' > 3; 
    filterIdx = filterIdx | [mserStats.Eccentricity] > 0.995 ;          %to detect straight lines in letters
    filterIdx = filterIdx | [mserStats.Solidity] < .3;                  %it is less for alphabets
    filterIdx = filterIdx | [mserStats.Extent] < 0.2 | [mserStats.Extent] > 0.9;  
    filterIdx = filterIdx | [mserStats.EulerNumber] < -4;  % < -4, 0     %number of objects in the region minus the number of holes in those objects

    % Remove regions
    mserStats(filterIdx) = [];          
    mserRegions(filterIdx) = [];

    % Show remaining regions
    figure
    imshow(I)
    hold on
    plot(mserRegions, 'showPixelList', true,'showEllipses',false)       %image after step 2
    title('After Removing Non-Text Regions Based On Geometric Properties')
    hold off
    
    %STEP 3
    % Get a binary image of the a region, and pad it to avoid boundary effects
    % during the stroke width computation.
    regionImage = mserStats(6).Image;                               %processing for one random object in the image
    regionImage = padarray(regionImage, [1 1]); 

    % Compute the stroke width image.
    distanceImage = bwdist(~regionImage);                   %distance transform of binary image 
    skeletonImage = bwmorph(regionImage, 'thin', inf);      %performs morphological operations on binary images

    strokeWidthImage = distanceImage;
    strokeWidthImage(~skeletonImage) = 0;

    % Show the region image alongside the stroke width image. 
    figure
    subplot(1,2,1)
    imagesc(regionImage)
    title('Region Image')

    subplot(1,2,2)
    imagesc(strokeWidthImage)
    title('Stroke Width Image')

    % Compute the stroke width variation metric 
    strokeWidthValues = distanceImage(skeletonImage);   
    strokeWidthMetric = std(strokeWidthValues)/mean(strokeWidthValues);

    % Threshold the stroke width variation metric
    strokeWidthThreshold = 0.4;                             %this threshold needs to be changed for different font styles
    strokeWidthFilterIdx = strokeWidthMetric > strokeWidthThreshold;

    % Process the remaining regions
    for j = 1:numel(mserStats)

        regionImage = mserStats(j).Image;                           %stores property 'Image' in regionImage
        regionImage = padarray(regionImage, [1 1], 0);              %pads array

        distanceImage = bwdist(~regionImage);
        skeletonImage = bwmorph(regionImage, 'thin', inf);

        strokeWidthValues = distanceImage(skeletonImage);

        strokeWidthMetric = std(strokeWidthValues)/mean(strokeWidthValues);        %calculates metric(standard deviation/mean)

        strokeWidthFilterIdx(j) = strokeWidthMetric > strokeWidthThreshold;

    end

    % Remove regions based on the stroke width variation
    mserRegions(strokeWidthFilterIdx) = [];
    mserStats(strokeWidthFilterIdx) = [];

    % Show remaining regions
    figure
    imshow(I)
    hold on
    plot(mserRegions, 'showPixelList', true,'showEllipses',false)               %plots the MSER regions left after non-text removal
    title('After Removing Non-Text Regions Based On Stroke Width Variation')
    hold off
 
    %STEP 4
    % Get bounding boxes for all the regions
    bboxes = vertcat(mserStats.BoundingBox); 

    % Convert from the [x y width height] bounding box format to the [xmin ymin
    % xmax ymax] format for convenience.
    xmin = bboxes(:,1);                         %calculates xmin, ymin, xmax, ymax for every character
    ymin = bboxes(:,2);
    xmax = xmin + bboxes(:,3) - 1;
    ymax = ymin + bboxes(:,4) - 1;

    % Expand the bounding boxes by a small amount.
    expansionAmount = 0.02;
    xmin = (1-expansionAmount) * xmin;                  
    ymin = (1-expansionAmount) * ymin;
    xmax = (1+expansionAmount) * xmax;
    ymax = (1+expansionAmount) * ymax;

    % Clip the bounding boxes to be within the image bounds
    xmin = max(xmin, 1);                    %gives maximum number from the 2 inputs
    ymin = max(ymin, 1);
    xmax = min(xmax, size(I,2));            %gives minimum number from the 2 inputs
    ymax = min(ymax, size(I,1));

    % Show the expanded bounding boxes
    expandedBBoxes = [xmin ymin xmax-xmin+1 ymax-ymin+1];
    IExpandedBBoxes = insertShape(colorImage,'Rectangle',expandedBBoxes,'LineWidth',3); %inserts rectangle shape in image with linewidth 3

    figure
    imshow(IExpandedBBoxes)
    title('Expanded Bounding Boxes Text')

    % Compute the overlap ratio
    overlapRatio = bboxOverlapRatio(expandedBBoxes, expandedBBoxes);   %computes boundingbox overlap ratio with itself

    % Set the overlap ratio between a bounding box and itself to zero to
    % simplify the graph representation.
    n = size(overlapRatio,1); 
    overlapRatio(1:n+1:n^2) = 0;

    % Create the graph
    g = graph(overlapRatio);                                            %creates graph with undirected edges

    % Find the connected text regions within the graph
    componentIndices = conncomp(g);                                     %finds connected graph components

    % Merge the boxes based on the minimum and maximum dimensions.
    xmin = accumarray(componentIndices', xmin, [], @min); %applies the function handle 'min' to each subset of elements in xmin that have identical subscripts in componentIndices'.
    ymin = accumarray(componentIndices', ymin, [], @min);
    xmax = accumarray(componentIndices', xmax, [], @max);
    ymax = accumarray(componentIndices', ymax, [], @max);

    % Compose the merged bounding boxes using the [x y width height] format.
    textBBoxes = [xmin ymin xmax-xmin+1 ymax-ymin+1];

    % Remove bounding boxes that only contain one text region
    numRegionsInGroup = histcounts(componentIndices);               %histogram bin counts
    textBBoxes(numRegionsInGroup == 1, :) = [];                     %removes text region with only one object

    % Show the final text detection result.
    ITextRegion = insertShape(colorImage, 'Rectangle', textBBoxes,'LineWidth',3);       %inserts shape in image

    figure
    imshow(ITextRegion)
    title('Detected Text')

    %STEP 5
    ocrtxt = ocr(I, textBBoxes);                                %recognize text using optical character recognition
    [ocrtxt.Text]                                               %displays the final output(i.e. recognized text)
    recognizedText = ocrtxt.Text;    
    figure;
    imshow(colorImage);
    text(800, 250, recognizedText, 'BackgroundColor', [1 1 1]); %displays ouput in the image at a particular position(it has to be set differently for other image)
end