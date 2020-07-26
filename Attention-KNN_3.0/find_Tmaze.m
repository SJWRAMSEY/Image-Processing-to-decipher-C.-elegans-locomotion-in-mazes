function [T_maze]=find_Tmaze(min_x,min_y,max_x,max_y,boundary)
%% 
%min_x,min_y,max_x,max_y;
x1 = max_x -min_x;
x2 = floor( (3/8)*x1 );
x3 = floor( (1/4)*x1 );
y1 = floor( 0.28*(max_y -min_y) );
y2 = floor( (1-0.28)*(max_y -min_y));

T_maze_1 = [ 1*ones( length([1:x1]),1 ),[1:x1]' ];
T_maze_2 = [ y1*ones( length([1:x2]),1 ),[x2:-1:1]' ];
T_maze_3 = [ y1*ones( length([x1:-1:x2+x3]),1 ),[x1:-1:x2+x3]' ];
T_maze_4 = [ (y1+y2)*ones( length([x2+x3:-1:x2]),1 ),[x2+x3:-1:x2]'];

T_maze_5 = [ [y1:-1:1]',1*ones( length([y1:-1:1]),1 ) ];
T_maze_6 = [ [y1+y2:-1:y1]',x2*ones( length([y1+y2:-1:y1]),1 ) ];
T_maze_7 = [ [y1:y1+y2]',(x2+x3)*ones( length([y1:y1+y2]),1 ) ];
T_maze_8 = [ [1:y1]',x1*ones( length([1:y1]),1 ) ];

T_maze = [T_maze_1;T_maze_8;T_maze_3;T_maze_7;T_maze_4;T_maze_6;T_maze_2;T_maze_5 ];

end

