!-----------------------------------------------------------------------------!
! DAMOCLES is a Monte Carlo radiative transfer code to model transfer of      !
! a single emission line or doublet through a cartesian grid of dust of       !
! multiple species and grain size distributions.                              !
!                                                                             !
! Copyright (C) 2017 Antonia Bevan                                            !
! Department of Physics and Astronomy                                         !
! University College London                                                   !
! London, WC1E 6BT, UK                                                        !
! antoniab@star.ucl.ac.uk                                                     !
!                                                                             !
! This program is free software; you can redistribute it and/or               !
! modify it under the terms of the GNU General Public License                 !
! as published by the Free Software Foundation; either version 2              !
! of the License, or (at your option) any later version. This requires        !
! that any chnages or improvements made to the program should also be         !
! made freely available.                                                      !
!                                                                             !
! This program is distributed in the hope that it will be useful,             !
! but WITHOUT ANY WARRANTY; without even the implied warranty of              !
! MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the               !
! GNU General Public License for more details.                                !
!                                                                             !
! DAMOCLES = Dust Affected Models Of Characteristic Line                      !
!            Emission in Supernovae                                           !
! Version 2.0                                                                 !
!-----------------------------------------------------------------------------!

!-----------------------------------------------------------------------------!
!  the main program is run from here                                          !
!    - the driver is included in a module such that it can be run             !
!      as a function using other languages/script e.g. a python wrapper       !
!-----------------------------------------------------------------------------!
PROGRAM DAMOCLES

    USE input
    USE initialise
    USE vector_functions
    USE driver

    implicit none

    CHARACTER(LEN=50)       ::  infile

    nargs=command_argument_count()
    IF (nargs==1) THEN
        call get_command_argument(1,infile)
        infile=trim(infile)
    ELSE IF (nargs==0) THEN
        infile='input.in'
    ELSE
        PRINT*,'too many input arguments - aborted'
        STOP
    END IF

    call run_code()

END PROGRAM
