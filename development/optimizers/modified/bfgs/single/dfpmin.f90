MODULE bfgs_function
CONTAINS

	SUBROUTINE dfpmin(p,gtol,iter,fret,func,dfunc)
	USE nrtype; USE nrutil, ONLY : nrerror,outerprod,unit_matrix,vabs
	IMPLICIT NONE
	INTEGER(I4B), INTENT(OUT) :: iter
	REAL(SP), INTENT(IN) :: gtol
	REAL(SP), INTENT(OUT) :: fret
	REAL(SP), DIMENSION(:), INTENT(INOUT) :: p
	INTERFACE
		FUNCTION func(p)
		USE nrtype
		IMPLICIT NONE
		REAL(SP), DIMENSION(:), INTENT(IN) :: p
		REAL(SP) :: func
		END FUNCTION func
!BL
		FUNCTION dfunc(p)
		USE nrtype
		IMPLICIT NONE
		REAL(SP), DIMENSION(:), INTENT(IN) :: p
		REAL(SP), DIMENSION(size(p)) :: dfunc
		END FUNCTION dfunc
	END INTERFACE
	INTEGER(I4B), PARAMETER :: ITMAX=200
	REAL(SP), PARAMETER :: STPMX=100.0_sp,EPS=epsilon(p),TOLX=4.0_sp*EPS
	INTEGER(I4B) :: its
	LOGICAL :: check
	REAL(SP) :: den,fac,fad,fae,fp,stpmax,sumdg,sumxi
	REAL(SP), DIMENSION(size(p)) :: dg,g,hdg,pnew,xi
	REAL(SP), DIMENSION(size(p),size(p)) :: hessin
	fp=func(p)
	g=dfunc(p)
	call unit_matrix(hessin)
	xi=-g
	stpmax=STPMX*max(vabs(p),real(size(p),sp))
	do its=1,ITMAX
		iter=its
		call lnsrch(p,fp,g,xi,pnew,fret,stpmax,check,func)
		fp=fret
		xi=pnew-p
		p=pnew

		if (maxval(abs(xi)/max(abs(p),1.0_sp)) < TOLX) RETURN
		dg=g
		g=dfunc(p)
		den=max(fret,1.0_sp)
		if (maxval(abs(g)*max(abs(p),1.0_sp)/den) < gtol) RETURN
		dg=g-dg
		hdg=matmul(hessin,dg)
		fac=dot_product(dg,xi)
		fae=dot_product(dg,hdg)
		sumdg=dot_product(dg,dg)
		sumxi=dot_product(xi,xi)
		if (fac**2 > EPS*sumdg*sumxi) then
			fac=1.0_sp/fac
			fad=1.0_sp/fae
			dg=fac*xi-fad*hdg
			hessin=hessin+fac*outerprod(xi,xi)-&
				fad*outerprod(hdg,hdg)+fae*outerprod(dg,dg)
		end if
		xi=-matmul(hessin,g)
	end do
	call nrerror('dfpmin: too many iterations')
	END SUBROUTINE dfpmin

	SUBROUTINE lnsrch(xold,fold,g,p,x,f,stpmax,check,func)
	USE nrtype; USE nrutil, ONLY : assert_eq,nrerror,vabs
	IMPLICIT NONE
	REAL(SP), DIMENSION(:), INTENT(IN) :: xold,g
	REAL(SP), DIMENSION(:), INTENT(INOUT) :: p
	REAL(SP), INTENT(IN) :: fold,stpmax
	REAL(SP), DIMENSION(:), INTENT(OUT) :: x
	REAL(SP), INTENT(OUT) :: f
	LOGICAL(LGT), INTENT(OUT) :: check
	INTERFACE
		FUNCTION func(x)
		USE nrtype
		IMPLICIT NONE
		REAL(SP) :: func
		REAL(SP), DIMENSION(:), INTENT(IN) :: x
		END FUNCTION func
	END INTERFACE
	REAL(SP), PARAMETER :: ALF=1.0e-4_sp,TOLX=epsilon(x)
	INTEGER(I4B) :: ndum
	REAL(SP) :: a,alam,alam2,alamin,b,disc,f2,fold2,pabs,rhs1,rhs2,slope,&
		tmplam
	ndum=assert_eq(size(g),size(p),size(x),size(xold),'lnsrch')
	check=.false.
	pabs=vabs(p(:))
	if (pabs > stpmax) p(:)=p(:)*stpmax/pabs
	slope=dot_product(g,p)
	alamin=TOLX/maxval(abs(p(:))/max(abs(xold(:)),1.0_sp))
	alam=1.0
	do
		x(:)=xold(:)+alam*p(:)
		f=func(x)
		if (alam < alamin) then
			x(:)=xold(:)
			check=.true.
			RETURN
		else if (f <= fold+ALF*alam*slope) then
			RETURN
		else
			if (alam == 1.0) then
				tmplam=-slope/(2.0_sp*(f-fold-slope))
			else
				rhs1=f-fold-alam*slope
				rhs2=f2-fold2-alam2*slope
				a=(rhs1/alam**2-rhs2/alam2**2)/(alam-alam2)
				b=(-alam2*rhs1/alam**2+alam*rhs2/alam2**2)/&
					(alam-alam2)
				if (a == 0.0) then
					tmplam=-slope/(2.0_sp*b)
				else
					disc=b*b-3.0_sp*a*slope
					if (disc < 0.0) THEN
disc = 0.001

END IF

					tmplam=(-b+sqrt(disc))/(3.0_sp*a)
				end if
				if (tmplam > 0.5_sp*alam) tmplam=0.5_sp*alam
			end if
		end if
		alam2=alam
		f2=f
		fold2=fold
		alam=max(tmplam,0.1_sp*alam)
	end do
	END SUBROUTINE lnsrch

END MODULE