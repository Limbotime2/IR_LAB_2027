module splines
implicit none

!parameters
integer,parameter :: dp=8

contains
    real(dp) function spline1(n,t,y,x)
    implicit none
    integer,intent(in) :: n
    integer :: i
    real(dp),dimension(0:n),intent(in) :: t,y
    real(dp),intent(in) :: x
    k: do i=n-1,0,-1
        if (x-t(i)>=0.0) then
            exit k
        end if
    end do k
    spline1=y(i)+((x-t(i))*((y(i+1)-y(i))/(t(i+1)-t(i))))
    end function spline1
!BLANK
    subroutine spline2_coef(n,t,y,z)
    implicit none
    integer,intent(in) :: n
    real(dp),dimension(0:n),intent(in) :: t,y
    real(dp),dimension(0:n),intent(out) :: z
    integer :: i
    !determine z_0 arbitrarily
    !one could use first degree spline for initialization
    z(0)=0.
    do i=0,n-1
        z(i+1)=-z(i)+2.*((y(i+1)-y(i))/(t(i+1)-t(i)))
    end do
    end subroutine spline2_coef
!BLANK
    real(dp) function spline2_eval(n,t,y,z,x)
    implicit none
    integer,intent(in) :: n
    real(dp),dimension(0:n),intent(in) :: t,y
    real(dp),dimension(0:n),intent(in) :: z
    real(dp),intent(in) :: x
    integer :: i,j
    real(dp) :: arg1,arg2,arg3,arg4,arg5
    k: do i=n-1,0,-1
        if (x-t(i)>=0.0) then
            j=i
            exit k
        end if
    end do k
    arg1=z(j+1)-z(j)
    arg2=2.*(t(j+1)-t(j))
    arg3=(x-t(j))*(x-t(j))
    arg4=z(j)*(x-t(j))
    arg5=y(j)
    spline2_eval=((arg1/arg2)*arg3)+arg4+arg5
    end function spline2_eval
!BLANK
    subroutine subbotin_tri_arrays(n,x,t,tau,y,h,a,d,c,b)
    implicit none
    integer,intent(in) :: n !must be even!
    real(dp),dimension(0:n) :: x,t
    real(dp),dimension(0:n-2+1),intent(out) :: tau,y
    integer :: i
    real(dp),dimension(0:n-1),intent(out) :: h
    real(dp),dimension(n),intent(out) :: d,b
    real(dp),dimension(n-1) :: a,c
    if (mod(n,2)==1) then
        write(*,*) "Error in Subbotin: n must be even"
        STOP
    end if
    !tau
    tau(0)=x(0)
    do i=1,n-2
        tau(i)=.5*(x(i)+x(i-1))
    end do
    tau(n-2+1)=x(n)
    !y_i
    y(0)=t(0)
    do i=1,n-2
        y(i)=t(2*i-1)
    end do
    y(n-2+1)=t(n)
    !h
    do i=0,n-1
        h(i)=x(i+1)-x(i)
    end do
    !first equation
    d(1)=3.*h(0)
    c(1)=h(0)
    b(1)=8.*(y(1)-y(0))
    !middle equations
    do i=1,n-1
        a(i)=h(i-1)
        d(i)=3.*(h(i-1)+h(i))
        c(i)=h(i)
        b(i)=8.*(y(i+1)-y(i))
    end do
    !last equation
    a(n-1)=h(n-2)
    d(n)=3.*h(n-1)
    b(n)=8.*(y(n+1)-y(n))
    end subroutine subbotin_tri_arrays
!BLANK
    real(dp) function subbotin_Q(n,y,z,x,tau,h,t)
    implicit none
    integer,intent(in) :: n
    real(dp),dimension(0:n+1),intent(in) :: y,tau
    real(dp),dimension(0:n),intent(in) :: z
    real(dp),intent(in) :: x
    real(dp),dimension(0:n-1),intent(in) :: h
    integer :: i
    real(dp),dimension(0:n),intent(in) :: t
    real(dp) :: arg1,arg2,arg3,arg4,arg5
    do i=n-1,0,-1
        if (x-t(i)>=0.) then
            exit
        end if
    end do
    arg1=y(i+1)
    arg2=.5*(z(i+1)+z(i))
    arg3=(x-tau(i+1))
    arg4=(1./(2.*h(i)))*(z(i+1)-z(i))
    arg5=(x-tau(i+1))**2.
    subbotin_Q=arg1+(arg2*arg3)+(arg4*arg5)
    end function subbotin_Q
!BLANK
    subroutine spline3_coef(n,t,y,z)
    implicit none
    integer,intent(in) :: n
    real(dp),dimension(0:n),intent(in) :: t,y
    real(dp),dimension(0:n),intent(out) :: z
    real(dp),dimension(0:n-1) :: h,b,u,v
    integer :: i
    do i=0,n-1
        h(i)=t(i+1)-t(i)
        b(i)=(y(i+1)-y(i))/h(i)
    end do
    u(1)=2.*(h(0)-h(1))
    v(1)=6.*(b(1)-b(0))
    do i=2,n-1
        u(i)=(2.*(h(i)+h(i-1)))-((h(i-1)*h(i-1))/u(i-1))
        v(i)=(6.*(b(i)-b(i-1)))-((h(i-1)*v(i-1))/u(i-1))
    end do
    z(n)=0.
    do i=n-1,1,-1
        z(i)=(v(i)-h(i)*z(i+1))/u(i)
    end do
    z(0)=0.0
    end subroutine spline3_coef
!BLANK
    real(dp) function spline3_eval(n,t,y,z,x)
    implicit none
    integer,intent(in) :: n
    real(dp),dimension(0:n),intent(in) :: t,y,z
    real(dp),intent(in) :: x
    real(dp) :: h,tmp
    integer :: i,j
    k: do i=n-1,0,-1
        if (x-t(i)>=0.) then
            j=i
            exit k
        end if
    end do k
    h=t(j+1)-t(i)
    tmp=(z(j)/2.)+(((x-t(j))*(z(j+1)-z(j)))/(6.*h))
    tmp=-(h/6.)*(z(j+1)+2.*z(j))+((y(j+1)-y(j))/h)+(x-t(j))*tmp
    spline3_eval=y(j)+(x-t(j))*tmp
    end function spline3_eval
!BLANK
    subroutine BSpline2_coef(n,t,y,a,h)
    implicit none
    integer,intent(in) :: n
    real(dp),dimension(0:n),intent(in) :: t,y
    real(dp),dimension(0:n+1),intent(out) :: a,h
    integer :: i
    real(dp) :: delta,gam,p,q,r
    do i=1,n
        h(i)=t(i)-t(i-1)
    end do
    h(0)=h(1)
    h(n+1)=h(n)
    delta=-1.0
    gam=2.*y(0)
    p=delta*gam
    q=2.0
    do i=1,n
        r=h(i+1)/h(i)
        delta=-r*delta
        gam=(-r*gam)+((r+1.)*y(i))
        p=p+gam*delta
        q=q+delta*delta
    end do
    a(0)=-p/q
    do i=1,n+1
        a(i)=(((h(i-1)+h(i))*y(i-1))-(h(i)*a(i-1)))/h(i-1)

    end do
    end subroutine BSpline2_coef
!BLANK
    real(dp) function BSpline2_eval(n,t,a,h,x)
    implicit none
    integer,intent(in) :: n
    real(dp),dimension(0:n),intent(in) :: t
    real(dp),dimension(0:n+1),intent(in) :: a,h
    real(dp),intent(in) :: x
    integer :: i
    real(dp) :: d,e
    do i=n-1,0,-1
        if (x-t(i)>=0.) then
            exit
        end if
    end do
    i=i+1
    d=(a(i+1)*(x-t(i-1))+a(i)*(t(i)-x+h(i+1)))/(h(i)+h(i+1))
    e=(a(i)*(x-t(i-1)+h(i-1))+a(i-1)*(t(i-1)-x+h(i)))/(h(i-1)+h(i))
    BSpline2_eval=(d*(x-t(i-1))+e*(t(i)-x))/h(i)
    end function BSpline2_eval

    
end module splines
    
