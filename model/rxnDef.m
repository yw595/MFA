%%specify number of synthesis reactions
n_aadrain = 0;
synRxn_rat = [];
%%specify rxnNo. that is meant to be reversible
rev_rxnList = [3; 5; 7; 9; 11; 13; 15; 17; 19; 21; 23; 25; 27; 29; 32; 34; 36; 38; 40; 42; 44; 46; 57; 60; 62; 64; 66];
%%preference of basis reaction in order (rev -> fow -> biomass)
swap = [11; 13; 15; 17; 19; 21; 23; 25; 27; 29; 3; 32; 34; 36; 38; 40; 42; 44; 46; 5; 57; 60; 62; 64; 66; 7; 9; 1; 50; 58];
%%least preference of basis reaction
put_last = [2; 4; 6; 8; 10; 12; 14; 16; 18; 20; 22; 24; 26; 28; 31; 33; 35; 37; 39; 41; 43; 45; 56; 59; 61; 63; 65];
%%specify reactions that can have negative flux
rxnNeg = [];
%%specity reaction's basis value
basis = [
];
