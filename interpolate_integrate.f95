program interpolate_integrate
use splines
implicit none

!variable declaration
character(len=256) :: filename,line
integer :: num_data,num_comm,iiostat,i
real(dp),allocatable :: x(:),y(:),z(:)
real(dp) :: A,var

!opening remarks
write(*,*) "This program will integrate an entire set of values by first employing"
write(*,*) "cubic splines. The input is a file containing comments at the top, denoted by #,"
write(*,*) "followed by x and y values. The output is the value of the integral over"
write(*,*) "the entire domain"
write(*,*) " "
write(*,*) "Author: ALimbo"
write(*,*) " "
write(*,*) "What is the name of the input file?"
read(*,'(a)') filename
filename=adjustl(filename)
open(unit=74,file=filename)

!get number of data points, including comments
num_data=0
num_comm=0
do
    read(74,'(a)',iostat=iiostat) line
    if (iiostat/=0) exit
    if (line(1:1) == '#') then 
        num_comm=num_comm+1
        cycle
    end if
    num_data=num_data+1
end do
close(74)
write(*,*) "Number of data points: ",num_data

!allocate arrays
allocate(x(0:num_data))
allocate(y(0:num_data))
allocate(z(0:num_data))

!read the actual data
open(unit=76,file=filename)
do i=1,num_comm
    read(76,*)
end do
do i=1,num_data
    read(76,*) x(i),y(i)
end do
close(76)

call spline3_coef(size(x),x,y,z)
call MC_integral(size(x),maxval(x),minval(x),x,y,z,A,var)

write(*,*) "integral calculated successfully"
write(*,*) A,var

!*****************************************************
contains
    subroutine MC_integral(num_data,ux,lx,xd,y,z,A,var)
    implicit none
    !variable declaration
    real(dp),intent(in) :: ux,lx
    integer,intent(in) :: num_data
    real(dp),dimension(0:num_data),intent(in) :: xd,y,z
    real(dp) :: summ,summ_squared,x,f,sigma_f
    integer,parameter :: big_N=1000000
    integer :: i
    real(dp),intent(out) :: A,var
    !calculate integral
    summ=0.0
    summ_squared=0.0
    do i=1,big_N
        call random_number(x)
        x=lx+x*(ux-lx)
        f=spline3_eval(num_data,xd,y,z,x)
        summ=summ+f
        summ_squared=summ_squared+(f*f)
    end do
    A=ux*(1./big_N)*summ
    sigma_f=((1./big_N)*summ_squared)-(((1./big_N)*summ)**2.)
    var=((1./big_N)**3.)*sigma_f*(ux)**2.
    end subroutine
end program
