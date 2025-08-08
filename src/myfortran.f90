module myfortran_mod
  !////////////////////////////////////////////////////////////////
  ! Module containing the entrypoint subroutine in Fortran for Biomee simulation
  !----------------------------------------------------------------
  use, intrinsic :: iso_c_binding, only: c_double, c_int, c_char, c_bool
  use, intrinsic :: ieee_arithmetic

  implicit none

  private
  public :: biomee_f

contains

  subroutine biomee_f( &
    params_siml,       &
    nt_daily,          &
    n_lu,              &
    x,                 &
    init_lu,           &
    output_daily_tile  &
  ) bind(C, name = "biomee_f_")

    ! Array dimensions
    integer(kind=c_int), intent(in) :: nt_daily          ! Number of simulated days (0 for no daily output)
    integer(kind=c_int), intent(in) :: n_lu              ! Number of land use types
    !real(kind=c_double), dimension(n_lu,nvars_init_lu), intent(in) :: init_lu          ! Initial LU state
    real(kind=c_double), dimension(n_lu,5), intent(in) :: init_lu          ! Initial LU state
    real(kind=c_double), intent(in) :: x

    ! Naked arrays
    ! real(kind=c_double), dimension(nvars_params_siml), intent(in) :: params_siml
    real(kind=c_double), dimension(11), intent(in) :: params_siml

    ! Output arrays (naked) to be passed back to C/R
    ! real(kind=c_double), dimension(nt_daily,nvars_daily_tile, n_lu), intent(out) :: output_daily_tile
    real(kind=c_double), dimension(nt_daily,36, n_lu), intent(out) :: output_daily_tile

    call sleep(1)
    print *, "Fortran received:", x
    call sleep(1)

  end subroutine biomee_f
end module myfortran_mod
