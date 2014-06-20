%Detection of Face on the basis of skin color
clear all;
close all;
clc
vid = videoinput('winvideo', 1);
set(vid, 'ReturnedColorSpace', 'rgb');
myI = getsnapshot(vid);
%myI=imread('baby15.jpg');
imshow(myI)

cform = makecform('srgb2lab');
J = applycform(myI,cform);
%figure;imshow(J);
K=J(:,:,2);
%figure;imshow(K);
L=graythresh(J(:,:,2));
BW1=im2bw(J(:,:,2),L);
%figure;imshow(BW1);
M=graythresh(J(:,:,3));
%figure;imshow(J(:,:,3));
BW2=im2bw(J(:,:,3),M);
%figure;imshow(BW2);
O=BW1.*BW2;
%figure;imshow(O);karo cntinue
% Bounding box
P=bwlabel(O,8);
BB=regionprops(P,'Boundingbox');
BB1=struct2cell(BB);
BB2=cell2mat(BB1);

[s1 s2]=size(BB2);
mx=0;
for k=3:4:s2-1
    p=BB2(1,k)*BB2(1,k+1);
    if p>mx & (BB2(1,k)/BB2(1,k+1))<1.8
        mx=p;
        j=k;
    end
end
figure,imshow(myI);
hold on;
rectangle('Position',[BB2(1,j-2),BB2(1,j-1),BB2(1,j),BB2(1,j+1)],'EdgeColor','w' )
a=BB2(1,j-2);
b=BB2(1,j-1);
c=BB2(1,j);
d=BB2(1,j+1);
ax=[a b c d]
fg=imcrop(myI,ax);
figure;
imshow(fg);

imwrite(fg,'fg.jpg','jpg');
f=imread('fg.jpg');


figure;
imshow(f);
fd=[1 1 c d/2]
fs=imcrop(f,fd)
figure;
imshow(fs);
EyeMap = rgb2ycbcr(fs);

figure;
imshow(EyeMap)


%Finding EyeMapC
y = double(EyeMap(:,:,1));
Cb = double(EyeMap(:,:,2));
Cr = double(EyeMap(:,:,3));

Q = Cb.^2;
R = (255-Cr).^2;
G = Cb./Cr;
%Eye Map for Crominance
EMC=(Q+R+G);
EMC1 = EMC.^9;

SE=strel('disk',4);
UP=imdilate(y,SE);
Down=imerode(y,SE);
EML = 2*Down-2*UP;

EMAP =8100*EML.*EML.*EMC1;


%figure;
%subplot(1,4,1), imagesc(Q);title ('Cb^2');axis off;
%subplot(1,4,2), imagesc(R);title ('(Cr-complement)^2');axis off;
%subplot(1,4,3), imagesc(G);title ('Cb/Cr');axis off;
%subplot(1,4,4), imagesc(EMC);title ('EMC'); axis off;
%colormap(gray);


figure;
subplot(1,4,1), imagesc(UP);title ('Dilation'); axis off;
subplot(1,4,2), imagesc(Down);title ('Erosion'); axis off;
subplot(1,4,3), imagesc(EML);title ('EML'); axis off;
subplot(1,1,1), imagesc(EMAP);title ('EMAP'); axis off;
colormap(gray);

%a=[50,50,100,100];

%E=imcrop(EMAP);

BW = edge(EMAP,'sobel');

        


% fill any holes, so that regionprops can be used to estimate
% the area enclosed by each of the boundaries
bw = imfill(BW,'holes');

[B,L] = bwboundaries(bw,'holes');

% Display the label matrix and draw each boundary
imshow(label2rgb(L, @jet, [.5 .5 .5]))
hold on
for k = 1:length(B)
  boundary = B{k};
  imshow(fs);
  plot(boundary(:,2), boundary(:,1), 'w', 'LineWidth', 2)
end

stats = regionprops(L,'Area','Centroid');

threshold = 0.95;

% loop over the boundaries
for k = 1:length(B)

  % obtain (X,Y) boundary coordinates corresponding to label 'k'
  boundary = B{k};

  % compute a simple estimate of the object's perimeter
  delta_sq = diff(boundary).^2;
  perimeter = sum(sqrt(sum(delta_sq,2)));

  % obtain the area calculation corresponding to label 'k'
  area = stats(k).Area;

  % compute the roundness metric
  metric = 4*pi*area/perimeter^2;

  % display the results
  %metric_string = sprintf('%2.4f',metric);

  % mark objects above the threshold with a black circle
  if metric > threshold
    centroid = stats(k).Centroid;
    plot(centroid(1),centroid(2),'ro');
  end
end


    