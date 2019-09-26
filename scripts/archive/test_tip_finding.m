R0_micron = quat2rotm([-0.164260002794;
    0.71900852327;
    0.425817093802;
    -0.524142344762]');
H0_micron = transformation (R0_micron, [0.0622229067677;-0.0882902962951;-0.101782143389]);

R0_rob = quat2rotm([-0.232252234817;
    0.941867571073;
    -0.241214037767;
    0.0275711074685]');
H0_rob = transformation(R0_rob, [0.00353781556826;0.00529671686416;-0.124098882281]);

R2_micron = quat2rotm([0.603191899254
    -0.426100387944
    -0.673828648749
    0.0235147654147]');
H2_micron = transformation(R2_micron, [0.0658159706547
    -0.0666234984066
    -0.111180498486]);
    
R2_rob= quat2rotm([-0.231108939262
    0.811400463224
    0.507738261233
    -0.174412741946]');
H2_rob = transformation(R2_rob,[-0.0177722112723;0.0106641065738;-0.120769676779]);

H12_micron = inv(H2_micron)*H0_micron
H12_rob = inv(H2_rob)*H0_rob