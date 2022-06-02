!traveling salesman initialization and energy functions
MODULE travel_sales
  USE globals
  IMPLICIT NONE
  PRIVATE
  PUBLIC ts_init,path_len,dist

  INTEGER,ALLOCATABLE :: glob_ord(:),min_ord(:),max_ord(:)
  REAL(8) :: min_len=1.0D+308,max_len=0.0,avg_len=0.0
CONTAINS
  !traveling salesman initialization problem
  SUBROUTINE ts_init()
    INTEGER :: i,j
    REAL(8) :: num_perms=1
    REAL(8) :: start,finish,est_time

    ALLOCATE(cust_locs(num_customers,prob_dim))
    !each customer is given a random 2D location on a 1x1 grid
    DO i=1,num_customers
      DO j=1,prob_dim
        CALL random_number(cust_locs(i,prob_dim))
      ENDDO
    ENDDO

    ALLOCATE(glob_ord(num_customers))
    ALLOCATE(min_ord(num_customers))
    ALLOCATE(max_ord(num_customers))

    !compute number of permutations and initialize the first permutation (just ordered)
    DO i=1,num_customers
      num_perms=num_perms*i
      glob_ord(i)=i
    ENDDO

    WRITE(*,'(A,ES16.8)')'Number of possible paths: ',num_perms

    !find minimum path length brute force wise (only if estimated time is under 100 seconds)
    est_time=num_perms*num_customers*prob_dim*2.0E-09
    WRITE(*,'(A,ES16.8,A)')'Estimated brute force calculation time ',est_time,' seconds'
    IF(est_time .LE. 1.0E+03)THEN
      CALL CPU_TIME(start)
      CALL find_min(1)
      CALL CPU_TIME(finish)
      WRITE(*,'(A,ES16.8)')'Average path length: ',avg_len/num_perms
      WRITE(*,'(A,ES16.8)')'Minimum path length: ',min_len
      WRITE(*,'(A,ES16.8)')'Maximum path length: ',max_len
      WRITE(*,'(A,13I2)')'Minimum path: ',min_ord
      !WRITE(*,'(A,13I2)')'Maximum path: ',max_ord
      WRITE(*,'(A,ES16.8,A)')'Brute force optimization finished in: ',finish-start,' seconds'
    ENDIF
  ENDSUBROUTINE ts_init

  RECURSIVE SUBROUTINE find_min(i)
    INTEGER,INTENT(IN) :: i
    INTEGER :: j, t
    REAL(8) :: cur_len=0
    IF(i == num_customers)THEN
      !compute current permutations path length
      cur_len=path_len(glob_ord)
      avg_len=avg_len+cur_len
      !if it is less than the current minimum length, set the current minimum length to it.
      IF(cur_len .LE. min_len)THEN
        min_len=cur_len
        min_ord=glob_ord
      ENDIF
      IF(cur_len .GE. max_len)THEN
        max_len=cur_len
        max_ord=glob_ord
      ENDIF
    ELSE
      DO j = i, num_customers
        t = glob_ord(i)
        glob_ord(i) = glob_ord(j)
        glob_ord(j) = t
        call find_min(i + 1)
        t = glob_ord(i)
        glob_ord(i) = glob_ord(j)
        glob_ord(j) = t
      ENDDO
    ENDIF
  ENDSUBROUTINE find_min

  FUNCTION path_len(state_ord)
    INTEGER,INTENT(IN) :: state_ord(num_customers)
    INTEGER :: i
    REAL(8) :: path_len
    path_len=0
    DO i=1,num_customers-1
      path_len=path_len+dist(cust_locs(state_ord(i),:),cust_locs(state_ord(i+1),:))
    ENDDO
  ENDFUNCTION path_len

  FUNCTION dist(loc1,loc2)
    REAL(8),INTENT(IN) :: loc1(:),loc2(:)
    INTEGER :: dim_prob,i
    REAL(8) :: dist
    dim_prob=SIZE(loc1)
    dist=0
    DO i=1,dim_prob
      dist=dist+(loc1(i)-loc2(i))**2
    ENDDO
    dist=SQRT(dist)
  ENDFUNCTION dist
END MODULE travel_sales