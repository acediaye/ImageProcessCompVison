clear
clc

myimage = imread('pic1.ppm');
rawimage=myimage;
%myimage=rgb2gray(myimage);
R=myimage(:,:,1);
G=myimage(:,:,2);
B=myimage(:,:,3);
myimage=B;%blue

figure(1)
%subplot(2,1,1);
imshow(myimage)
title('raw')
%[counts graybins]=imhist(myimage)
%imhist(myimage)

myimage=imgaussfilt(myimage,4);
%myimage=imboxfilt(myimage,5);

figure(2)
%subplot(2,1,2);
imshow(Otsu(myimage))
title('Otsu')
%imshow(im2bw(myimage))

[row,col]=size(myimage);
X0=zeros(row,col);
X0(row/2,col/2)=1;%center of image, assumes lake
Xk1=X0;
count=0;
%extraction of connected components 
%Xk = (Xk-1 dilate B) and A
%until Xk = Xk-1
while 1
    count=count+1;
    Xk=and(dilation(Xk1),Otsu(myimage));
    if Xk==Xk1
        break;
    end
    Xk1=Xk;
end
count;
lakeimage=Xk;
figure(3)
imshow(lakeimage)
title('connected')

figure(4)
%subplot(2,1,2)
%imshow(erosion(Otsu(myimage)))
imshow(erosion(lakeimage));
title('erosion')

figure(5)
%whos myimage
%boundary extraction = A - (A erosde B)
%boundary=Otsu(myimage)-erosion(Otsu(myimage));
boundary=lakeimage-erosion(lakeimage);
imshow(boundary)
title('boundary')

%{
figure(3)
imshow(dilation(Otsu(myimage)));
title('dilation')
figure(4)
boundary=dilation(Otsu(myimage))-Otsu(myimage);
imshow(boundary)
title('boundary2')
%}

figure(6)
[row,col]=size(myimage);
final=rawimage;
for i=1:row
    for j=1:col
        if boundary(i,j)==1%transfer white boundary to final image
            final(i,j,1)=255; final(i,j,2)=255; final(i,j,3)=255;
        end
    end
end
imshow(final)
title('final')

function output=Otsu(myimage)
    %input: grayscale, output: binary image
    [row,col]=size(myimage);
    totalpixel=row*col;
    
    threshold=0; varmax=0; totsum=0; sum2=0; C1=0; C2=0;%C1: class 1 background, C2: class 2 foreground
    maxintensity=256; 
    histogram=zeros(1,maxintensity);%creating a histogram and initialize to 0

    for i=1:row%setting histogram up, for each bin [0 255] count number of pixels
        for j=1:col
            intensity = myimage(i,j);
            histogram(intensity+1)=histogram(intensity+1)+1;
        end
    end
    
    for i=1:maxintensity%cumulative sum*intensity
        totsum=totsum+i*histogram(i);
    end
    
    for i=1:maxintensity%for each intensity value 
        C1=C1+histogram(i);%set up C1: class 1
        if C1==0
        else%if C1 != 0
            C2=totalpixel-C1;%set up C2: class 2
        end
        
        sum2=sum2+i*histogram(i);%cumulative sum*intensity
        mu1=sum2/C1;%setting up mu 1 and mu 2
        mu2=(totsum-sum2)/C2;
        
        sigma=C1*C2*power(mu1-mu2,2);%setting up sigma
        
        if sigma>varmax%finding optimal threshold with maximum sigma
            threshold=i;
            varmax = sigma;
        end
    end
    
    outimage=zeros(row,col);%setting up output to be binary image
    for i=1:row
        for j=1:col
            if myimage(i,j)>threshold
                outimage(i,j)=1;%all values above threshold set to 1
            else
                outimage(i,j)=0;%else set to 0
            end
        end
    end
    output=outimage;
end

function output=erosion(myimage)
    %input: uint8 binary image, output: double binary image
    myimage=double(myimage);
    [row,col]=size(myimage);
    SE=[1 1 1;
        1 1 1;
        1 1 1];
    padimage = padarray(myimage,[1 1],0,'both');%pad all borders by 0
    %whos myimage
    %whos padimage
    mag=zeros(row,col);
    [row, col]=size(padimage);
    for i=2:row-1
        for j=2:col-1
            if isequal(padimage(i-1:i+1,j-1:j+1),SE)%erosion
            %if padimage(i-1,j-1)==SE(1,1) || padimage(i,j-1)==SE(1,2) ||
            %padimage(i+1,j-1)==SE(1,3) || padimage(i-1,j)==SE(2,1) ||
            %padimage(i,j)==SE(2,2) || padimage(i+1,j)==SE(2,3) ||
            %padimage(i-1,j+1)==SE(3,1) || padimage(i,j+1)==SE(3,2) ||
            %padimage(i+1,j+1)==SE(3,3)%dilation
                mag(i-1,j-1)=1;
            else
                mag(i-1,j-1)=0;
            end
        end
    end
    output=mag;
end

function output=dilation(myimage)
%input: uint8 binary image, output: double binary image
    myimage=double(myimage);
    [row,col]=size(myimage);
    SE=[1 1 1;
        1 1 1;
        1 1 1];
    padimage = padarray(myimage,[1 1],0,'both');%pad all borders by 0
    %whos myimage
    %whos padimage
    mag=zeros(row,col);
    [row, col]=size(padimage);
    for i=2:row-1
        for j=2:col-1
            if padimage(i-1,j-1)==SE(1,1) || padimage(i,j-1)==SE(1,2) || padimage(i+1,j-1)==SE(1,3) || ...
               padimage(i-1,j)==SE(2,1) || padimage(i,j)==SE(2,2) || padimage(i+1,j)==SE(2,3) || ...
               padimage(i-1,j+1)==SE(3,1) || padimage(i,j+1)==SE(3,2) || padimage(i+1,j+1)==SE(3,3)%dilation
                mag(i-1,j-1)=1;
            else
                mag(i-1,j-1)=0;
            end
        end
    end
    output=mag;
end

%{
function output=sobel(myimage)
    %input: grayscale, output: double grayscale image
    myimage=double(myimage);
    [row,col]=size(myimage);
    Gx=[-1 0 1;
        -2 0 2;
        -1 0 1];
    Gy=[-1 -2 -1;
         0  0  0;
         1  2  1];
    mag=zeros(row,col);
    %padimage = padarray(myimage,[1 1],0,'both');%pad all borders by 0
    %[row, col]=size(padimage);
    for i=1:row-2
        for j=1:col-2
            %S1=sum(sum(Gx.*padimage(i-1:i+1,j-1:j+1)));
            %S2=sum(sum(Gy.*padimage(i-1:i+1,j-1:j+1)));
            S1=sum(sum(Gx.*myimage(i:i+2,j:j+2)));
            S2=sum(sum(Gy.*myimage(i:i+2,j:j+2)));
            mag(i,j)=sqrt(S1^2 + S2^2);
        end
    end
    output=uint8(mag);
end
%}