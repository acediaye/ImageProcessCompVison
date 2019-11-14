clear 
clc

myimage=double(imread('flower.pgm'));
imshow(myimage)

[row,col]=size(myimage);
RGB=zeros(row,col,3);%create RGB image
R=RGB(:,:,1);%set R channel
G=RGB(:,:,2);%set G channel
B=RGB(:,:,3);%set B channel
%[red, blue, green, yellow, orange, purple, brown, black]
for i=1:row
    for j=1:col
        if 0<=myimage(i,j) && myimage(i,j)<round(255/8)*1
            %black 
        elseif round(255/8)*1<=myimage(i,j) && myimage(i,j)<round(255/8)*2
            R(i,j)=0.6471; G(i,j)=0.1647; B(i,j)=0.1647;%brown
        elseif round(255/8)*2<=myimage(i,j) && myimage(i,j)<round(255/8)*3
            R(i,j)=1; B(i,j)=1;%purple
        elseif round(255/8)*3<=myimage(i,j) && myimage(i,j)<round(255/8)*4
            R(i,j)=1; G(i,j)=0.6471;%orange
        elseif round(255/8)*4<=myimage(i,j) && myimage(i,j)<round(255/8)*5
            R(i,j)=1; G(i,j)=1;%yellow
        elseif round(255/8)*5<=myimage(i,j) && myimage(i,j)<round(255/8)*6
            G(i,j)=1;%green
        elseif round(255/8)*6<=myimage(i,j) && myimage(i,j)<round(255/8)*7
            B(i,j)=1;%blue
        elseif round(255/8)*7<=myimage(i,j)
            R(i,j)=1;%red
        end
    end
end
IMG=cat(3,R,G,B);%recombine 3 channels
imshow(IMG)
%{
RGB=rand(200,480,3);
R=RGB(:,:,1);
G=RGB(:,:,2);
B=RGB(:,:,3);
IMG=cat(3,R,G,B);
imshow(IMG)
%}

