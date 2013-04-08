function C = xcorr_fp(A, B)
  assert(size(A, 1) > size(B, 1))
  assert(size(A, 2) > size(B, 2))
  muls = 0;

  C = zeros(size(A, 1) - size(B, 1) + 1, size(A, 2) - size(B, 2) + 1);
  for i = 1:(size(C, 1))
    for j = 1:(size(C, 2))
      for m = 1:(size(A, 1))
        for n = 1:(size(A, 2))
          ma = m + i - size(B, 1);
          na = n + j - size(B, 2);
          if (ma <= size(A, 1)) && (na <= size(A, 2)) && ma > 0 && na > 0
            C(i, j) = C(i, j) + A(ma, na) * B(m, n);
            muls = muls+1;
          end
        end
      end
    end
  end
  muls
end

