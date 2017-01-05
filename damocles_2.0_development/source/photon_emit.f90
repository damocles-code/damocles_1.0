MODULE emit_photon

    USE common
    use input
    USE initialise
    USE vector_functions

    IMPLICIT NONE

contains

    SUBROUTINE emit_photon(nu_p,dir_cart,pos_cart,iG_axis,lgactive,w)

        INTEGER               ::  ixx,iyy,izz

        REAL,INTENT(INOUT)    ::  nu_p,dir_cart(3)
        REAL,INTENT(OUT)      ::  pos_cart(3),w
        INTEGER,INTENT(OUT)   ::  iG_axis(3),lgactive


        REAL    ::  random(5)
        REAL    ::  pos_sph(3)
        REAL    ::  dir_sph(2)
        REAL    ::  los,v_p,vel_vect(3),v

        INTEGER ::  idP_thread,freqid,i_dir

        CALL RANDOM_NUMBER(random)

        w=1         !w is weight of photon - energy scaled when doppler shifted
        lgactive=0  !automatically inactive until declared active
        idP_thread=idP_thread+1

        !assign the photon a unique id for tracking (variable = idP)

        pos_sph(:)=(/ (random(1)*shell_width+RSh(iSh,1)),(2*random(2)-1),random(3)*2*pi/)       !position of emitter idP - spherical coords - system SN - RF
        pos_cart(:)=cartr(pos_sph(1),ACOS(pos_sph(2)),pos_sph(3))

        dir_sph(:)=(/ (2*random(4))-1,random(5)*2*pi /)                        !direction of photon idP - spherical coords - system PT - CMF
        dir_cart(:)=cart(ACOS(dir_sph(1)),dir_sph(2))

        IF ((pos_sph(1) > gas_geometry%R_min) .AND. (pos_sph(1) < gas_geometry%R_max)) THEN                       !If the photon lies inside the radial bounds of the supernova then it is processed

            v_p=gas_geometry%v_max*((pos_sph(1)/gas_geometry%R_max)**gas_geometry%v_power)                           !velocity of emitter idP calculated from radius

            vel_vect=normalise(pos_cart)*v_p

            nu_p=line%frequency
            lgactive=1

            call lorentz_trans(vel_vect,nu_p,dir_cart,w,"emsn")




            !CALCULATE WHICH CELL EMITTER & PHOTON ARE IN
            DO ixx=1,mothergrid%n_cells(1)
                IF ((pos_cart(1)*1e15-mothergrid%x_div(ixx))<0) THEN                        !identify grid axis that lies just beyond position of emitter in each direction
                    iG_axis(1)=ixx-1                                       !then the grid cell id is the previous one
                    EXIT
                END IF
                IF (ixx==mothergrid%n_cells(1)) THEN
                    iG_axis(1)=mothergrid%n_cells(1)
                END IF

            END DO
            DO iyy=1,mothergrid%n_cells(2)
                IF ((pos_cart(2)*1e15-mothergrid%y_div(iyy))<0) THEN
                    iG_axis(2)=iyy-1
                    EXIT
                END IF
                IF (iyy==mothergrid%n_cells(2)) THEN
                    iG_axis(2)=mothergrid%n_cells(2)
                END IF

            END DO
            DO izz=1,mothergrid%n_cells(3)
                IF ((pos_cart(3)*1e15-mothergrid%z_div(izz))<0) THEN
                    iG_axis(3)=izz-1
                    EXIT
                END IF
                IF (izz==mothergrid%n_cells(3)) THEN
                    iG_axis(3)=mothergrid%n_cells(3)
                END IF
            END DO

        ELSE                                                    !If the photon lies outside the bounds of the SN then it is inactive and not processed
            n_inactive=n_inactive+1                             !add 1 to number of inactive photons
            PRINT*,'inactive photon',n_inactive,iDoublet
        END IF
        
        
        IF (ANY(iG_axis == 0)) lgactive=0

    END SUBROUTINE emit_photon

END MODULE
