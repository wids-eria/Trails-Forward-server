require 'narray'
require 'matrix_utils'

module Tickers
  class TreeTicker
    def self.tick(world)

      # get tree data for world
      @old_tree_size = NArray.float(world.width, world.height)
      @decid = NArray.float(world.width, world.height)
      @conifer = NArray.float(world.width, world.height)
      @mixed = NArray.float(world.width, world.height)
      @old_tree_size.fill!(0.0)
      @decid.fill!(0.0)
      @conifer.fill!(0.0)
      @mixed.fill!(0.0)

      ResourceTile.where(:world_id => world.id).find_in_batches do |group|
        group.each do |rt|
          x = rt.x
          y = rt.y
          case rt.tree_species
          when ResourceTile.verbiage[:tree_species][:deciduous]
            @decid[x,y] = rt.tree_size
            @old_tree_size[x,y] = rt.tree_size
          when ResourceTile.verbiage[:tree_species][:coniferous]
            @conifer[x,y] = rt.tree_size
            @old_tree_size[x,y] = rt.tree_size
          when ResourceTile.verbiage[:tree_species][:mixed]
            @mixed[x,y] = rt.tree_size
            @old_tree_size[x,y] = rt.tree_size
          end
        end
      end


      # compute the tree growth
      result = compute_timber @decid, @conifer, @mixed, 1

      # debug code
      # puts "Old Tree Size"
      # print_Matrix @old_tree_size, @old_tree_size.shape[0], @old_tree_size.shape[1]
      # puts "New Tree Size"
      # print_Matrix result.tree_size, result.tree_size.shape[0], result.tree_size.shape[0]


      # update the trees
      LandTile.where(:world_id => world.id).find_in_batches do |group|
        group.each do |rt|
          x = rt.x
          y = rt.y
          case rt.tree_species
          when ResourceTile.verbiage[:tree_species][:deciduous]
            rt.tree_size = result.tree_size[x,y]
          when ResourceTile.verbiage[:tree_species][:coniferous]
            rt.tree_size = result.tree_size[x,y]
          when ResourceTile.verbiage[:tree_species][:mixed]
            rt.tree_size = result.tree_size[x,y]
          end
          rt.save!
        end
      end

    end


    # Code to estimate boardfeet of timber for each cell
    # matrix contain the size of the trees
    TimberOutput = Struct.new(:bfdt, :bfct, :bfmt, :tree_size)
    def self.compute_timber(decid, conifer, mixed, years)

      mx_decid = decid.dup.to_f
      mx_conifer = conifer.dup.to_f
      mx_mixed = mixed.dup.to_f

      # %%%%%Set number of trees per cell%%%%%%%%%% Numbers from FIA data

      # DenseDS=(Decid<8&Decid>=5)*350;  %%%Density of small trees decid
      dense_ds = (mx_decid.lt(8) & mx_decid.ge(5)).to_f * 350
      # DenseDM=(Decid<10&Decid>=8)*167; %%%Density of medium trees decid
      dense_dm = (mx_decid.lt(10) & mx_decid.ge(8)).to_f * 167
      # DenseDL=(Decid>=10)*133; %%%%%%Density of large trees decid
      dense_dl = (mx_decid.ge(10)).to_f * 133

      # DenseCS=(Conifer<8&Conifer>=5)*303;%%%Density of small trees conifer
      dense_cs = (mx_conifer.lt(8) & mx_conifer.ge(5)).to_f * 303
      # DenseCM=(Conifer<10&Decid>=8)*139;%%%%%%Density of medium trees conifer
      dense_cm = (mx_conifer.lt(10) & mx_conifer.ge(8)).to_f * 139
      # DenseCL=(Conifer>=10)*97; %%%%%%Density of large trees conifer
      dense_cl = (mx_conifer.ge(10)).to_f * 97


      # DenseMS=(Mixed<8&Mixed>=5)*235;%%%Density of small trees mixed
      dense_ms = (mx_mixed.lt(8) & mx_mixed.ge(5)).to_f * 235
      # DenseMM=(Mixed<10&Mixed>=8)*156;%%%%%%%Density of medium trees mixed
      dense_mm = (mx_mixed.lt(10) & mx_mixed.ge(8)).to_f * 156
      # DenseML=(Mixed>=10)*141; %%%%%%%Density of large trees mixed
      dense_ml = (mx_mixed.ge(10)).to_f * 141


      # DenseD=DenseDS+DenseDM+DenseDL; %%%%Landscape of Decid trees
      dense_d = dense_ds + dense_dm + dense_dl
      # DenseC=DenseCS+DenseCM+DenseCL; %%%%Landscape of Conifer trees
      dense_c = dense_cs + dense_cm + dense_cl
      # DenseM=DenseMS+DenseMM+DenseML;%%%%%%%Landscape of Mixed trees
      dense_m = dense_ms + dense_mm + dense_ml


      # %%%%%%%%%%%%%%%%Estimate Board Feet Per Tree
      # BFD=exp(log(Decid)*2.77922-2.70244+.008);%%%%%%Board Feet per tree Decid
      bfd = NMath.exp( NMath.log( mx_decid ) * 2.77922 - 2.70244 + 0.008 )
      # BFC=exp(log(Conifer)*2.77922-2.70244+.1689889);%%%%%%Board Feet per tree Conifer
      bfc = NMath.exp( NMath.log( mx_conifer ) * 2.77922 - 2.70244 + 0.1689889 )
      # BFM=exp(log(Mixed)*2.77922-2.70244);%%%%%%Board Feet per tree Mixed
      bfm = NMath.exp( NMath.log( mx_mixed ) * 2.77922 - 2.70244 )


      # %%%%%%%%%%%%Estimate total board feet per cell
      # BFDT=BFD.*DenseD;
      bfdt = bfd * dense_d
      # BFCT=BFC.*DenseC;
      bfcf = bfc * dense_c
      # BFMT=BFM.*DenseM;
      bfmt = bfm * dense_m

      # print_Matrix bfdt, 5, 5
      # puts "--------------\n"
      # print_Matrix bfcf, 5, 5
      # puts "--------------\n"
      # print_Matrix bfmt, 5, 5
      # puts "--------------\n"



      width = mx_decid.shape[0]
      height = mx_decid.shape[1]
      # %%%%%%%%%%%%%%%%%%%%%%%%Time step%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

      # %%%%%%loop through and estimate for each cell incremental growth in DBH
      # %%%%%Loop is used as 0 values go to infinity otherwise - there is probably
      # %%%%%a much better way to do this. Values are estiamted values of PRI
      # for T=1:35;
      for t in (1..years)

        # for j=1:n
        # for q=1:n
        #    if Decid(j,q)==0
        #        Decid(j,q)==0;
        #    else
        # Decid(j,q)=2.7072.*Decid(j,q).^-.5431.*.97829.^Decid(j,q)+Decid(j,q); %%%%incremental gain in dbh Decid
        #    end
        # end
        # end
        # for j=1:n
        # for q=1:n
        #    if Conifer(j,q)==0
        #        Conifer(j,q)==0;
        #    else
        # Conifer(j,q)=2.980519.*Conifer(j,q).^-.53609.*.96803.^Conifer(j,q)+Conifer(j,q);%%%%%incremental gain in dbh Cprams
        #    end
        # end
        # end
        # for j=1:n
        # for q=1:n
        #    if Mixed(j,q)==0
        #        Mixed(j,q)==0;
        #    else
        # Mixed(j,q)=2.844009.*Mixed(j,q).^-.543955.*.97316.^Mixed(j,q)+Mixed(j,q);%%%%%%% incrmental gain in Mixed
        #    end
        # end
        # end
        for j in (0..width-1)
          for q in (0..height-1)
            if mx_decid[j,q] != 0
              mx_decid[j,q] = 2.7072 * mx_decid[j,q]**-0.5431 * 0.97829**mx_decid[j,q] + mx_decid[j,q]
            end
            if mx_conifer[j,q] != 0
              mx_conifer[j,q] = 2.980519 * mx_conifer[j,q]**-0.53609 * 0.96803**mx_conifer[j,q] + mx_conifer[j,q]
            end
            if mx_mixed[j,q] != 0
              mx_mixed[j,q] = 2.844009 * mx_mixed[j,q]**-0.543955 * 0.97316**mx_mixed[j,q] + mx_mixed[j,q]
            end
          end
        end


        # %%%%%%%%%%%%%%%%Estimate Board Feet Per Tree
        # BFD=exp(log(Decid)*2.77922-2.70244+.008);%%%%%%Board Feet per tree Decid
        bfd = NMath.exp( NMath.log( mx_decid ) * 2.77922 - 2.70244 + 0.008 )
        # BFC=exp(log(Conifer)*2.77922-2.70244+.1689889);%%%%%%Board Feet per tree Conifer
        bfc = NMath.exp( NMath.log( mx_conifer ) * 2.77922 - 2.70244 + 0.1689889 )
        # BFM=exp(log(Mixed)*2.77922-2.70244);%%%%%%Board Feet per tree Mixed
        bfm = NMath.exp( NMath.log( mx_mixed ) * 2.77922 - 2.70244 )

        # %%%%%%%%%%%%Estimate total board feet per cell
        # BFDT=BFD.*DenseD;
        bfdt = bfd * dense_d
        # BFCT=BFC.*DenseC;
        bfcf = bfc * dense_c
        # BFMT=BFM.*DenseM;
        bfmt = bfm * dense_m
        # end
      end

      # Treesize=Conifer+Mixed+Decid;
      tree_size =  mx_conifer + mx_mixed + mx_decid
      TimberOutput.new(bfdt, bfcf, bfmt, tree_size)
    end

  end
end
