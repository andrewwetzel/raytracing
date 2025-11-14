! A simple test program in modern Fortran
program HelloTest
    ! This tells the compiler that all variables must be explicitly declared.
    ! It's excellent practice and prevents many common bugs.
    implicit none

    ! Declare an integer variable
    integer :: x
    real :: y

    ! Assign values
    x = 10
    y = 5.5

    ! Perform a calculation
    x = x * 2

    ! Print output to the console
    print *, 'Hello from Fortran!'
    print *, 'The integer value of x * 2 is: ', x
    print *, 'The real value of y is: ', y

end program HelloTest