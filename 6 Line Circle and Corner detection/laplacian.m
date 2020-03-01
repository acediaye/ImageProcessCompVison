clear 
clc

name='lane.jpeg';
myimage=double(rgb2gray(imread(name)));
figure(1)
imshow(myimage, [0 255]);

figure(2)
imshow(mylaplacian(myimage),[0 255])

function y=mylaplacian(myimage)
    kernal=[-1 -1 -1;
            -1  8 -1;
            -1 -1 -1];
    [row,col]=size(myimage);
    mag = zeros(row,col);
    for i=2:row-1
        for j=2:col-1
            S=sum(sum(kernal.*myimage(i-1:i+1,j-1:j+1)));
            mag(i,j)=S;
        end
    end
    threshold=255*.1;
    output=zeros(row,col);
    for i=1:row
        for j=1:col
            if mag(i,j)>threshold
                output(i,j)=mag(i,j);
            else
                output(i,j)=0;
            end
        end
    end
    y=output;
end
