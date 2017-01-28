!--------------------------------------------------------------------------!
!  this module declares line derived type object which contains properties !
!  of the line or doublet to be modelled                                   !
!--------------------------------------------------------------------------!

MODULE class_line

    IMPLICIT NONE

    TYPE line_obj
        REAL        ::  luminosity              !total luminosity of line       W/um
        REAL        ::  wavelength              !wavelength (nm) of the line being modelled
        REAL        ::  frequency               !frequency of the line to be modelled
        REAL        ::  doublet_wavelength_1    !wavelength (nm) of the first component of the doublet (if applic.)
        REAL        ::  doublet_wavelength_2    !wavelength (nm) of the second component of the doublet (if applic.)
        REAL        ::  doublet_ratio           !flux ratio between 2 components of doublet (wavelength_1/wavelength_2)

        INTEGER     ::  wav_bin                 !array index of nearest wavelength bin to rest frame wavelength being modelled
        INTEGER     ::  wav_bin_v               !array index of nearest wavelength bin to V band (547nm)
    END TYPE

    TYPE(line_obj)   :: line

END MODULE class_line

