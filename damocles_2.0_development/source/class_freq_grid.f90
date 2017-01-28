!----------------------------------------------------------------------------------------!
!  this module declares the frequency grid derived type object                           !
!  subroutine establishes the frequency grid that will store the resultant line profile  !
!----------------------------------------------------------------------------------------!

MODULE class_freq_grid

    USE class_line
    USE class_geometry
    USE class_dust

    IMPLICIT NONE

    TYPE freq_grid_obj
        INTEGER ::  n_bins                      !number of frequency bins

        REAL    ::  fmax                        !maximum frequency in frequency grid
        REAL    ::  fmin                        !minimum frequency in frequency grid
        REAL    ::  bin_width                   !size of a step in the (linear) frequency grid

        REAL,DIMENSION(:,:),ALLOCATABLE :: bin  !array of frequency bins
    END TYPE freq_grid_obj

    TYPE(freq_grid_obj) nu_grid

contains

    !This subroutine constructs a linear frequency grid.
    !As packets escape the grid, they will be added (according to their weight) to a bin in the frequency grid.
    !It is constructed at the start of the simulation in order to store packet data cumulativley as the RT progreses.
    SUBROUTINE construct_freq_grid()

        PRINT*, 'Constructing frequency grid...'

        ALLOCATE(nu_grid%bin(nu_grid%n_bins,2))

        !set maximum and minimum frequency range for bins in frequency grid
        !if doing a doublet, then the min and max are set to be as large as possible based on the wavelengths of interest
        !maximum is set to be (arbitrarily) 5 times larger than the frequency obtained by shifting by v_max towards the blue
        !minimum is set to be (arbitrarily) 5 times smaller than the frequency obtained by shifting by v_max towards the red
        !this is to allow for frequency being shifted beyond the theoretical for a single scattering event due to multiple scatterings
        IF (lg_doublet) THEN
            IF (line%doublet_wavelength_2>line%doublet_wavelength_1) THEN
                nu_grid%fmax=5*((c*10**9/line%doublet_wavelength_1)/(1-MAX(dust_geometry%v_max,2000.0)*10**3/c))        !arbitrary factor of 5 to compensate for multiple scatterings
                nu_grid%fmin=0.2*((c*10**9/line%doublet_wavelength_2)/(1+MAX(dust_geometry%v_max,2000.0)*10**3/c))        !as above
            ELSE
                nu_grid%fmax=5*((c*10**9/line%doublet_wavelength_2)/(1-MAX(dust_geometry%v_max,2000.0)*10**3/c))        !arbitrary factor of 5 to compensate for multiple scatterings
                nu_grid%fmin=0.2*((c*10**9/line%doublet_wavelength_1)/(1+MAX(dust_geometry%v_max,2000.0)*10**3/c))        !as above
            END IF
        ELSE
            nu_grid%fmax=5*(line%frequency/(1-MAX(dust_geometry%v_max,2000.0)*10**3/c))
                                                                                                !
            nu_grid%fmin=0.2*(line%frequency/(1+MAX(dust_geometry%v_max,2000.0)*10**3/c))                !as above
        END IF
        nu_grid%bin_width=(nu_grid%fmax-nu_grid%fmin)/nu_grid%n_bins

        !calculate the frequency bins for the resultant line profile to be stored in
        DO ii=1,nu_grid%n_bins
            nu_grid%bin(ii,1)=nu_grid%fmin+((ii-1)*nu_grid%bin_width)
            nu_grid%bin(ii,2)=nu_grid%fmin+((ii)*nu_grid%bin_width)
        END DO

    END SUBROUTINE construct_freq_grid

END MODULE class_freq_grid
