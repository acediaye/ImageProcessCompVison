clear
clc
%%{
myimage=double(imread('interfere.pgm'));
figure(1);
subplot(2,2,1)
imshow(uint8(myimage),[]);
title('original image')

F = fft2(myimage); % fast fourier transform
F = fftshift(F); % center FFT
%figure(5),imshow(uint8(255.*abs(F)),[]);
F = abs(F); % get the magnitude of complex numbers
F = log(F+1); % use log, for scaling, +1 since log(0) is undefined
F = mat2gray(F); % use mat2gray to scale the image between 0 and 1
subplot(2,2,2)
imshow(uint8(255.*F),[]); % display the scaled shifted FFT
title('image in frequency domain')

[row,col]=size(myimage);
rowcenter=row/2;
colcenter=col/2;
filter=zeros(row,col);
freq=[];
for i=1:row
    for j=1:col
        if uint8(255*F(i,j))>220%high spikes in freq
            if 254<=i && i<=258 && 254<=j && j<=258%center of freq domain
            else%not center of freq domain
                txt=sprintf("%d %d\n",i,j);%print x,y
                temp=sqrt((256-i)^2+(256-j)^2);%print freq
                freq=[freq,temp];%apend all freqencies
            end
        end
    end
end
freq0=floor(min(freq));%inner freqency
freq1=ceil(max(freq));%outer frequency
for i=1:row%low pass filter + high pass filter
    for j=1:col
        if sqrt((i-rowcenter)^2+(j-colcenter)^2) <= freq0%distance radius for inner circle
            filter(i,j)=1;%inside small circle is 1
        elseif sqrt((i-rowcenter)^2+(j-colcenter)^2) >= freq1%distance radius for outer circle
            filter(i,j)=1;%outside large circle is 1
        else
            filter(i,j)=0.01;
        end%circular band between 2 circles value is 1/100
    end
end
subplot(2,2,3)
imshow(uint8(255.*filter),[]);%show band reject filter
title('band reject filter');

filterimage=filter.*F;%combine filter with image
subplot(2,2,4)
imshow(uint8(255.*filterimage),[])%display filter with the image
title('filter + image')

outputimage=ifft2(ifftshift(filter.*fftshift(fft2(myimage))));%want raw fft+shifted image, not scaled one
figure(2)
imshow(uint8(abs(outputimage)),[])%shows absolute inverse FFT 
title('output image')
%}
%figure,imshow(uint8(fftshift(fft2(myimage))))
%{
A=[151 222 160  88;
    79  24  23 197;
   143  78 152  92;
    84 123  71 209];
fft2(A);
%}
%{
I=im2double(imread('interfere.pgm'));
F=fftshift(fft2(I));
figure(1)
plot(abs(F))
IF=ifft2(ifftshift(F));
figure(2), imshow(IF)
%}
