function handle = draw_sq(c,s)
% c  = lower left corner
% s = side length
x = [c(1) c(1)+s c(1)+s c(1) c(1)];
y = [c(2) c(2) c(2)+s c(2)+s c(2)];
h = line(x,y);