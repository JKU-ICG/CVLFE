function lf = simulate_illumination( Dexpect, A, ilf )

lf = Dexpect * ( A * ilf(:) );

end