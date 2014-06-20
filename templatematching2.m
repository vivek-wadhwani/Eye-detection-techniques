% detects a target in image

close all;
clear all;

%imagname = input('\n Enter the name of the image file (filename.ext) : ','s');
%INPUT IMAGE
w = imread('image30.jpg');
w = im2double(w);
sizw = size(w);

figure
imshow(w)
title('Input Image')
pause(2.5);
close;

%TARGET IMAGE
t = imread('ae.jpg');
t = im2double(t);
sizt = size(t);
figure
imshow(t)

title('Target Image')

pause(2.5);
close;

%COVERTING BOTH IMAGE INTO GRAYSCALE
ww = rgb2gray(w);
tt = rgb2gray(t);

%DETECTING EDGE OF BOTH IMAGES AFTER CONVERTING GRAYSCALE TO BINARY IMAGE 
tedge = edge(tt);
wedge = edge(ww);

%FILTER DATA OF TEMPLATE IMAGE WITH 2 DIMENSIONAL FILTER IN MATRIX OF INPUT IMAGE
%USES CORRELATION AND GIVES CENTRAL PART OF CORRELATION AS OUTPUT
out = filter2(tedge,wedge);

%FINDS LARGEST ELEMENT IN OUTPUT OF CORRELATION
o = max(max(out));
output = (1/o)*out;

%FIND VALUE WHOSE VALUE IS 1
pixel = find(output == 1);

%ROUNDING THE VALUE TO 0 AND REMAINING AS ARRAY OF CORRELATED RESULT W.R.T INPUT IMAGE
pcolumn = fix(pixel / sizw(1));

%FINDS THE MODULO AFTER DIVISION
prow = mod(pixel,sizw(1));

%ROUNDING SIZE OF Target image
rdis = fix(sizt(1)/2);
cdis = fix(sizt(2)/2);

%SUBTRACTING BOTH ROUNDED VALUES OF CORRELATED RESULT W.R.T INPUT IMAGE AND OF TARGET IMAGE
cmin = pcolumn - cdis;
cmax = pcolumn + cdis;
rmin = prow - rdis;
rmax = prow + rdis;
c = [cmin cmin cmax cmax];

r = [rmin rmax rmax rmin];

%RECEIVING MATCHED PORTION IN INPUT IMAGE ACCORDING TO TARGET IMAGE AFTER SPECIFYING POLYGONAL REGION OF INTEREST(ROI)
m = roipoly(ww,c,r);

%FINDING THE BORDER LINE OR BOUNDARY OF MATCHED REGION USING PERIMETER OF BOUNDED IMAGE
BWoutline = bwperim(m);
Segout = w;
Segout(BWoutline) = 255;
figure, imshow(Segout), title('outlined original image');

%CONNECTING LABELS WITH OBJECT TO TEMPLATE MATCHED IMAGE TO SEARCH FOR BOUNDING BOX USING REGIONPROPS() FUNCTION
%IT GIVES RESULT IN STRUCTURE FORM
P=bwlabel(m,8);
BB=regionprops(P,'Boundingbox');

%COVERTING THE RESULT OF REGIONPROPS TO CELL AND THE TO MATRIX TO GET COORDINATES OF BOX
BB1=struct2cell(BB);
BB2=cell2mat(BB1);

%CROPING THE IMAGE ACCORDING TO COORDINATES FROM INPUT IMAGE
%THIS IS MATCHED TEMPLATE IMAGE IN INPUT ACCORDING TO TARGET IMAGE AND IS CROPPED TO DO FURTHER CALCULATIONS THAT IS %DETECTING EYE
I=imcrop(w,BB2);
imwrite(I,'i.jpg','jpg')
figure;
imshow(I)

%CONVERTING THE RGB COLORSPACE OF IMAGE TO GRAYSCALE FORM
i=rgb2gray(I);

%DETECTING EDGE IN IMAGE USING SOBEL EDGE DETECTION
BW = edge(i,'sobel');
figure, imshow(BW), title('binary gradient mask');

%DEFINING STRUCTURAL ELEMENT OF LINE FOR DOING DILATION EROSION ON GRAYSCALED FORM CROPPED IMAGE
se90 = strel('line', 7, 1800);
se0 = strel('line', 1.5, 200);

%DILATING THE IMAGE
BWsdil = imdilate(BW, [se90 se0]);
figure, imshow(BWsdil), title('dilated gradient mask');

%FILLING THE UNWANTED HOLES IN DILATED IMAGE
BWdfill = imfill(BWsdil, 'holes');
figure, imshow(BWdfill);
title('binary image with filled holes');

%CLEARS THE BORDER BY SUPPRESSES THE STRUCTURES THAT ARE LIGHTER THAN THEIR SURROUNDINGS AND THAT ARE CONNECTED TO THE %BORDER
BWnobord = imclearborder(BWdfill, 8);
figure, imshow(BWnobord), title('cleared border image');

%DEFENING STRUCTURAL ELEMENT FOR DIAMOND FOR ERODING THE IMAGE
seD = strel('diamond',1);

%ERODING THE IMAGE FOR GETING PERFECT RESULT
BWfinal = imerode(BWnobord,seD);
%BWfinal = imerode(BWfinal,seD);
figure, imshow(BWfinal), title('segmented image');
imwrite(BWfinal,'bw.jpg','jpg')
I1=imread('bw.jpg')
J=imread('ae5.jpg');

%K1=imadd(I1,J)
%figure;

%imshow(K1)
%FINDING PERIMETER OF ERODED IMAGE SO THAT WE CAN DETECT EYES
BWoutline = bwperim(J);
imwrite(BWfinal,'bw.jpg','jpg')
Segout = I;
Segout(BWoutline) = 255;
figure, imshow(Segout), title('outlined original image');

%CONNECTING LABELS TO OBJECT
P1=bwlabel(BWfinal,8);
BW = P1 > 0;

%FINDING CENTROIDS IN IMAGES USING REGIOPROPS
s = regionprops(BW, BWfinal, {'Centroid','WeightedCentroid'});
imshow(Segout)
title('eye');
hold on
numObj = numel(s);
%PLOTING CIRCLE ON CENTER POINT OF DETECTED CENTROIDS AND THUS WE GET DETECTED EYES IN CROPPED IMAGE OF INPUT IMAGE
for k = 1 : numObj
    plot(s(k).WeightedCentroid(1), s(k).WeightedCentroid(2), 'g*');
    plot(s(k).Centroid(1), s(k).Centroid(2), 'yo');
end
hold off

