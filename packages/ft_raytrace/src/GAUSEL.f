      SUBROUTINE GAUSEL(A,N,B)
      DIMENSION A(N,N),B(N)
      DO 1 K=1,N
      L=K
      DO 2 I=K,N
      IF(ABS(A(I,K)).GT.ABS(A(L,K))) L=I
    2 CONTINUE
      DO 3 J=K,N
      TEMP=A(K,J)
      A(K,J)=A(L,J)
    3 A(L,J)=TEMP
      TEMP=B(K)
      B(K)=B(L)
      B(L)=TEMP
      DO 4 I=K+1,N
      FACTOR=A(I,K)/A(K,K)
      DO 5 J=K+1,N
    5 A(I,J)=A(I,J)-FACTOR*A(K,J)
    4 B(I)=B(I)-FACTOR*B(K)
    1 CONTINUE
      B(N)=B(N)/A(N,N)
      DO 6 I=N-1,1,-1
      SUM=0.
      DO 7 J=I+1,N
    7 SUM=SUM+A(I,J)*B(J)
    6 B(I)=(B(I)-SUM)/A(I,I)
      RETURN
      END