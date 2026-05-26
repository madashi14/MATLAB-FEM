function R = Rz_new(th)
%Rotazione attorno a x
R = [cos(th) -sin(th) 0;
    sin(th) cos(th) 0;
    0 0 1];
end
