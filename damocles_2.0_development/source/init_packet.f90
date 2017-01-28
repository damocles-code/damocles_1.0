MODULE init_packet

    use globals
    use class_grid
    use input
    use initialise
    use vector_functions


    IMPLICIT NONE
    
contains

    SUBROUTINE emit_photon(nu_p,dir_cart,pos_cart,iG_axis,packet,w)


        use class_packet

        IMPLICIT NONE

        INTEGER               ::  ixx,iyy,izz

    
        REAL,INTENT(INOUT)    ::  nu_p,dir_cart(3)
        REAL,INTENT(OUT)      ::  pos_cart(3),w
        INTEGER,INTENT(OUT)   ::  iG_axis(3)
    
        REAL    ::  random(5),rand1(3)
        REAL    ::  pos_sph(3)
        REAL    ::  dir_sph(2)
        REAL    ::  v_p,vel_vect(3)

        CALL RANDOM_NUMBER(random)
    
        w=1         !w is weight of photon - energy scaled when doppler shifted
        packet%lg_active=0  !automatically inactive until declared active

        rand1=random(1:3)
    
        !initial position of packet is generated in both cartesian and spherical coordinates
        IF ((gas_geometry%clumped_mass_frac==1) .or. (gas_geometry%type == "arbitrary")) THEN
            !packets are emitted from grid cells
            pos_cart= (grid_cell(unit_vol_iD)%axis+rand1*grid_cell(unit_vol_iD)%width)
            pos_sph(1)=((pos_cart(1)**2+pos_cart(2)**2+pos_cart(3)**2)**0.5)*1e-15
            pos_sph(2)=ATAN(pos_cart(2)/pos_cart(1))
            pos_sph(3)=ACOS(pos_cart(3)*1e-15/pos_sph(1))
            pos_cart(:)=pos_cart(:)*1e-15
        ELSE
            !shell emissivity distribution
            pos_sph(:)=(/ (random(1)*shell_width+RSh(unit_vol_iD,1)),(2*random(2)-1),random(3)*2*pi/)       !position of emitter idP - spherical coords - system SN - RF
            pos_cart(:)=cartr(pos_sph(1),ACOS(pos_sph(2)),pos_sph(3))
        END IF
    
        !generate an initial propagation direction from an isotropic distribution
        !in comoving frame of emitting particle
        dir_sph(:)=(/ (2*random(4))-1,random(5)*2*pi /)
        dir_cart(:)=cart(ACOS(dir_sph(1)),dir_sph(2))


        !If the photon lies inside the radial bounds of the supernova
        !or if the photon is emitted from a clump or cell (rather than shell) then it is processed
        IF (((pos_sph(1) > gas_geometry%R_min) .AND. (pos_sph(1) < gas_geometry%R_max) .AND. (gas_geometry%clumped_mass_frac==0)) &
            & .OR. (gas_geometry%clumped_mass_frac==1) &
            & .OR. (gas_geometry%type == 'arbitrary')) THEN
       
            !calculate velocity of emitting particle from radial velocity distribution
            !velocity vector comes from radial position vector of particle
            v_p=gas_geometry%v_max*((pos_sph(1)/gas_geometry%R_max)**gas_geometry%v_power)
            vel_vect=normalise(pos_cart)*v_p
       
            nu_p=line%frequency
            packet%lg_active=1

            call lorentz_trans(vel_vect,nu_p,dir_cart,w,"emsn")

            !identify cell which contains emitting particle (and therefore packet)
            !!could be made more efficient but works...
            DO ixx=1,mothergrid%n_cells(1)
                IF ((pos_cart(1)*1e15-mothergrid%x_div(ixx))<0) THEN  !identify grid axis that lies just beyond position of emitter in each direction
                    iG_axis(1)=ixx-1                                  !then the grid cell id is the previous one
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
                    !PRINT*,pos_cart(3),mothergrid%z_div(izz)
                    EXIT
                END IF
                IF (izz==mothergrid%n_cells(3)) THEN
                    iG_axis(3)=mothergrid%n_cells(3)
                END IF
            END DO
       
            !check to ensure that for packets emitted from cells, the identified cell is the same as the original...
            IF ((gas_geometry%type == 'shell' .and. gas_geometry%clumped_mass_frac == 1) &
                &    .or.  (gas_geometry%type == 'arbitrary')) THEN

                IF ((iG_axis(1) /= grid_cell(unit_vol_iD)%id(1)) .and. &
                &   (iG_axis(2) /= grid_cell(unit_vol_iD)%id(2)) .and. &
                &   (iG_axis(3) /= grid_cell(unit_vol_iD)%id(3))) THEN
                    PRINT*,'cell calculation gone wrong in module init_packet. Aborted.'
                    STOP
                END IF
            END IF
        !If the photon lies outside the bounds of the SN then it is inactive and not processed
        ELSE
            !track total number of inactive photons
            n_inactive=n_inactive+1
            PRINT*,'inactive photon'
            packet%lg_active=0
        END IF

        IF (ANY(iG_axis == 0)) THEN
            packet%lg_active=0
            n_inactive=n_inactive+1
            PRINT*,'inactive photon'
        END IF

        IF (n_inactive/n_packets > 0.1) PRINT*, 'Warning: number of inactive packets greater than 10% of number requested.'

    END SUBROUTINE emit_photon
  
END MODULE init_packet
