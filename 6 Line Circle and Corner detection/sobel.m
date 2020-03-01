clear
clc

name='lane.jpeg';
myimage=double(rgb2gray(imread(name)));
figure(1)
imshow(myimage, [0 255]);

figure(2)
imshow(mysobel(myimage),[0 255])

%figure(3)
%BW1 = edge(myimage,'Sobel');
%imshow(BW1)

function y=mysobel(myimage)
    Gx = [-1 0 1;%gradient in x direction
          -2 0 2;
          -1 0 1];
    Gy = [-1 -2 -1;%gradient in y direction
           0  0  0;
           1  2  1];
    [row,col]=size(myimage);
    mag=zeros(row,col);%gradient magnitude image init
    for i=2:row-1%ignore border
        for j=2:col-1%ignore border
            Sx=sum(sum(Gx.*myimage(i-1:i+1,j-1:j+1)));
            Sy=sum(sum(Gy.*myimage(i-1:i+1,j-1:j+1)));
            mag(i,j)=sqrt(Sx.^2+Sy.^2);%gradiant magnitude image
        end
    end
    threshold=255*.9;%threshold
    outputimage=zeros(row,col);%output image init
    %%{
    for i=1:row
        for j= 1:col
            if mag(i,j)>threshold
                outputimage(i,j)=mag(i,j);%if over threshold keep
            else
                outputimage(i,j)=0;%else throw away
            end
        end
    end
    %}
    y=outputimage;%output image after threshold
    %y=mag;
end
