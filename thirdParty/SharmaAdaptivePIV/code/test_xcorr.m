for i = 1:100
  l = randi(10, 1);
  A = randi(256, l, l)-1;
  B = randi(256, l, l)-1;
  C1 = xcorr2(A, B);
  C2 = xcorr_fp(A, B);
  assert(all(all(C1 == C2)));
end
disp('PASSED')