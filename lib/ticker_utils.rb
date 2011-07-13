require 'matrix_utils'
require 'narray'


HabitatOutput = Struct.new(:count, :population, :habitat)

#compute the habitat for black-billed cuckoo
def compute_habitat_cuckoo(matrix)

#BBC=(decid+conifer+mixed); %%%Make landscape that is not water
#BBC=bwconncomp(BBC,4);%%%%%%%find edge of this landscape
#bbcstats=regionprops(BBC,'Area');%%%find the area
#idBBC=find([bbcstats.Area]>1);%%%see if area exist
#BBC2=ismember(labelmatrix(BBC),idBBC);%%%label matrix of BBC2
#BBC=bwperim(BBC2);%%find paramters
#BBC3=(decid+mixed);%%%%make landscape of just suitable habitat
#BBC=BBC3==1&BBC==1; %%%%%%suitable habitat + Parameter
#BBCsize=sum(BBC);
#BBCsize=sum(BBCsize,2);  %%%%%%%%%%%amount of habitat for BBCrequire 'matrix_utils'
  
  mx_decid = matrix.eq(1)
  mx_conifer = matrix.eq(2)
  mx_mixed = matrix.eq(3)

  mx_trees = mx_decid + mx_conifer + mx_mixed
	mx_decid_mixed = mx_decid + mx_mixed


	mx_bwcc = bwcc_New(mx_trees)
	mx_perim = bwperim(mx_trees)
	
	
  mx_habitat = NArray.byte(matrix.shape[0], matrix.shape[1])
  mx_habitat.fill!(0)
	count = 0
	
	
  #print_Matrix perim, 5, 5
  #puts "--------------\n"
	
	mx_bwcc.PixelIdxList.each{ |val|
		#puts "length = #{val.length}\n"
		if(val.length>1 && mx_trees[val[0][0],val[0][1]]!=0)
			val.each{ |point|
			  #puts "point #{point[0]}, #{point[1]}\n"
			  if(mx_perim[point[0],point[1]]!=0 && mx_decid_mixed[point[0],point[1]]!=0)
					count = count + 1
					mx_habitat[point[0],point[1]] = 1
				end
			}
		end
	}
	
	#density 0.25 p/10 ha
	population = count * 0.404 * 0.25 / 10 * 2;
	#puts "Count = #{count}\n"
	output = HabitatOutput.new(count, population, mx_habitat)
	return output

end


#compute the habitat for flycatchers
def compute_habitat_flycatchers(matrix)

#LF=(decid+mixed); %%%flycatchers can live in decid and mixed forest
#LF=bwconncomp(LF,4);%%%%%%%%%%Designate patches
#lfstats=regionprops(LF,'Area'); %%calcualte size of patches
#idLF = find([lfstats.Area] > 0);%%%%%%%%%%%%select patches greater than a given size
#LF2 = ismember(labelmatrix(LF), idLF);%%%%%%%%%%%put those on a new matrix
#PLF2=bwperim(LF2);%%%%%%%%%%%%%%Take off parameters 
#LF= PLF2==0 & LF2==1;%%%%Core area for Flycatcher
#LFsize=sum(LF);
#LFsize=sum(LFsize); %%%%%%Amount of flycatcher forest
  
  mx_decid = matrix.eq(1)
  mx_mixed = matrix.eq(3)

	mx_decid_mixed = mx_decid + mx_mixed

	mx_bwcc = bwcc_New(mx_decid_mixed)
	mx_perim = bwperim(mx_decid_mixed)
	
  mx_habitat = NArray.byte(matrix.shape[0], matrix.shape[1])
  mx_habitat.fill!(0)
	count = 0
		
	mx_bwcc.PixelIdxList.each{ |val|
		#puts "length = #{val.length}\n"
		if(val.length>0 && mx_decid_mixed[val[0][0],val[0][1]]!=0)
			val.each{ |point|
			  #puts "point #{point[0]}, #{point[1]}\n"
			  if(mx_perim[point[0],point[1]]==0)
					count = count + 1
					mx_habitat[point[0],point[1]] = 1
				end
			}
		end
	}
	
	
	#density 15p/10ha
	population = count * 0.404 * 15 / 10 * 2;
	#puts "Count = #{count}\n"
	output = HabitatOutput.new(count, population, mx_habitat)
	return output

end


#compute the habitat for woodthursh
def compute_habitat_woodthursh(matrix)

#WT=LF; %%%%%%%wood thursh has same properties as Flycather but bigger minimum size
#WT=bwconncomp(WT,4);%%designate patches
#wfstats=regionprops(WT,'Area'); %%calcualte size of patches
#idWT = find([wfstats.Area] > 2);%%%%%%%%%%%%select patches greater than 2 acres needed as minimum core patch size
#WT = ismember(labelmatrix(WT), idWT);%%%%%%%%%%%put those on a new matrix
#WTsize=sum(WT);
#WTsize=sum(WTsize);


	mx_lf = compute_habitat_flycatchers(matrix)
	mx_bwcc = bwcc_New(mx_lf.habitat)
	#mx_perim = bwperim(mx_decid_mixed)
	
	
  mx_habitat = NArray.byte(matrix.shape[0], matrix.shape[1])
  mx_habitat.fill!(0)
	count = 0
		
	mx_bwcc.PixelIdxList.each{ |val|
		#puts "length = #{val.length}\n"
		if(val.length>2 && mx_lf.habitat[val[0][0],val[0][1]]!=0)
			val.each{ |point|
			  #puts "point #{point[0]}, #{point[1]}\n"
				count = count + 1
				mx_habitat[point[0],point[1]] = 1
			}
		end
	}
	
	#density 2.3p/10ha
	population = count * 0.404 * 2.3 / 10 * 2;
	#puts "Count = #{count}\n"
	output = HabitatOutput.new(count, population, mx_habitat)
	return output

end


#compute the habitat for chickadees
def compute_habitat_chickadees(matrix)

#C=bwconncomp(Conifer,4);%%%%%%create patches for Conifer
#cstats=regionprops(C,'Area');%%%%%Measure of patch area conifer
#idC = find([cstats.Area] > 5);%%%%%%%%%%%%select patches greater than 5 acres
#C2 = ismember(labelmatrix(C), idC);%%%%%%%%%%%put those on a new matrix
#BC=C2;
#BCsize=sum(C2);
#BCsize=sum(BCsize); %%% Amout of land with Chickadees on it
  
  mx_conifer = matrix.eq(2)
	mx_bwcc = bwcc_New(mx_conifer)
	
  mx_habitat = NArray.byte(matrix.shape[0], matrix.shape[1])
  mx_habitat.fill!(0)
	count = 0
		
	mx_bwcc.PixelIdxList.each{ |val|
		#puts "length = #{val.length}\n"
		if(val.length>5 && mx_conifer[val[0][0],val[0][1]]!=0)
			val.each{ |point|
			  #puts "point #{point[0]}, #{point[1]}\n"
				count = count + 1
				mx_habitat[point[0],point[1]] = 1
			}
		end
	}
	
	#density 0.4 p/10 ha
	population = count * 0.404 * 0.4 / 10 * 2;
	#puts "Count = #{count}\n"
	output = HabitatOutput.new(count, population, mx_habitat)
	return output

end


#compute the habitat for warbler
def compute_habitat_warbler(matrix)

#CW=conifer+mixed;%%%%%%%%%CW uses mixed and conifer 
#CW=bwconncomp(CW,4);%%%%%%%%%%Designate patches
#cwstats=regionprops(CW,'Area'); %%calcualte size of patches
#idCW = find([cwstats.Area] > 0);%%%%%%%%%%%%select patches greater than a given size
#CW2 = ismember(labelmatrix(CW), idCW);%%%%%%%%%%%put those on a new matrix
#PCW2=bwperim(CW2);%%%%%%%%%%%%%%Take off parameters 
#CW= PCW2==0 & CW2==1;%%%%Core area for Warbler
#CWsize=sum(CW);
#CWsize=sum(CWsize); %%%%%%Amount of Warbler forest
  
  
  mx_conifer = matrix.eq(2)
  mx_mixed = matrix.eq(3)

	mx_conifer_mixed = mx_conifer + mx_mixed

	mx_bwcc = bwcc_New(mx_conifer_mixed)
	mx_perim = bwperim(mx_conifer_mixed)
	
  mx_habitat = NArray.byte(matrix.shape[0], matrix.shape[1])
  mx_habitat.fill!(0)
	count = 0
		
		
	mx_bwcc.PixelIdxList.each{ |val|
		#puts "length = #{val.length}\n"
		if(val.length>0 && mx_conifer_mixed[val[0][0],val[0][1]]!=0)
			val.each{ |point|
			  #puts "point #{point[0]}, #{point[1]}\n"
			  if(mx_perim[point[0],point[1]]==0)
					count = count + 1
					mx_habitat[point[0],point[1]] = 1
				end
			}
		end
	}
	
	#density 1 pair/10 ha
	population = count * 0.404 * 1 / 10 * 2;
	#puts "Count = #{count}\n"
	output = HabitatOutput.new(count, population, mx_habitat)
	return output

end

#Code to estimate boardfeet of timber for each cell
# matrix contain the size of the trees
TimberOutput = Struct.new(:bfdt, :bfct, :bfmt, :tree_size)
def compute_timber(decid, conifer, mixed, years)

	mx_decid = decid.dup.to_f
	mx_conifer = conifer.dup.to_f
	mx_mixed = mixed.dup.to_f
		
	#%%%%%Set number of trees per cell%%%%%%%%%% Numbers from FIA data 

	#DenseDS=(Decid<8&Decid>=5)*350;  %%%Density of small trees decid
	dense_ds = (mx_decid.lt(8) & mx_decid.ge(5)).to_f * 350
	#DenseDM=(Decid<10&Decid>=8)*167; %%%Density of medium trees decid
	dense_dm = (mx_decid.lt(10) & mx_decid.ge(8)).to_f * 167
	#DenseDL=(Decid>=10)*133; %%%%%%Density of large trees decid
	dense_dl = (mx_decid.ge(10)).to_f * 133

	#DenseCS=(Conifer<8&Conifer>=5)*303;%%%Density of small trees conifer
	dense_cs = (mx_conifer.lt(8) & mx_conifer.ge(5)).to_f * 303
	#DenseCM=(Conifer<10&Decid>=8)*139;%%%%%%Density of medium trees conifer
	dense_cm = (mx_conifer.lt(10) & mx_conifer.ge(8)).to_f * 139
	#DenseCL=(Conifer>=10)*97; %%%%%%Density of large trees conifer
	dense_cl = (mx_conifer.ge(10)).to_f * 97


	#DenseMS=(Mixed<8&Mixed>=5)*235;%%%Density of small trees mixed
	dense_ms = (mx_mixed.lt(8) & mx_mixed.ge(5)).to_f * 235
	#DenseMM=(Mixed<10&Mixed>=8)*156;%%%%%%%Density of medium trees mixed
	dense_mm = (mx_mixed.lt(10) & mx_mixed.ge(8)).to_f * 156
	#DenseML=(Mixed>=10)*141; %%%%%%%Density of large trees mixed
	dense_ml = (mx_mixed.ge(10)).to_f * 141


	#DenseD=DenseDS+DenseDM+DenseDL; %%%%Landscape of Decid trees
	dense_d = dense_ds + dense_dm + dense_dl
	#DenseC=DenseCS+DenseCM+DenseCL; %%%%Landscape of Conifer trees
	dense_c = dense_cs + dense_cm + dense_cl
	#DenseM=DenseMS+DenseMM+DenseML;%%%%%%%Landscape of Mixed trees
	dense_m = dense_ms + dense_mm + dense_ml


	#%%%%%%%%%%%%%%%%Estimate Board Feet Per Tree
	#BFD=exp(log(Decid)*2.77922-2.70244+.008);%%%%%%Board Feet per tree Decid
	bfd = NMath.exp( NMath.log( mx_decid ) * 2.77922 - 2.70244 + 0.008 )
	#BFC=exp(log(Conifer)*2.77922-2.70244+.1689889);%%%%%%Board Feet per tree Conifer
	bfc = NMath.exp( NMath.log( mx_conifer ) * 2.77922 - 2.70244 + 0.1689889 )
	#BFM=exp(log(Mixed)*2.77922-2.70244);%%%%%%Board Feet per tree Mixed
	bfm = NMath.exp( NMath.log( mx_mixed ) * 2.77922 - 2.70244 )

	
	#%%%%%%%%%%%%Estimate total board feet per cell
	#BFDT=BFD.*DenseD;
	bfdt = bfd * dense_d
	#BFCT=BFC.*DenseC;
	bfcf = bfc * dense_c
	#BFMT=BFM.*DenseM;
	bfmt = bfm * dense_m

  #print_Matrix bfdt, 5, 5
  #puts "--------------\n"
  #print_Matrix bfcf, 5, 5
  #puts "--------------\n"
  #print_Matrix bfmt, 5, 5
  #puts "--------------\n"
  
	
	
  width = mx_decid.shape[0]
  height = mx_decid.shape[1]	
	#%%%%%%%%%%%%%%%%%%%%%%%%Time step%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

	#%%%%%%loop through and estimate for each cell incremental growth in DBH
	#%%%%%Loop is used as 0 values go to infinity otherwise - there is probably
	#%%%%%a much better way to do this. Values are estiamted values of PRI
	#for T=1:35;
	for t in (1..years) 

		#for j=1:n
		#for q=1:n
		#    if Decid(j,q)==0
		#        Decid(j,q)==0;
		#    else
		#Decid(j,q)=2.7072.*Decid(j,q).^-.5431.*.97829.^Decid(j,q)+Decid(j,q); %%%%incremental gain in dbh Decid
		#    end
		#end
		#end
		#for j=1:n
		#for q=1:n
		#    if Conifer(j,q)==0
		#        Conifer(j,q)==0;
		#    else
		#Conifer(j,q)=2.980519.*Conifer(j,q).^-.53609.*.96803.^Conifer(j,q)+Conifer(j,q);%%%%%incremental gain in dbh Cprams
		#    end
		#end
		#end
		#for j=1:n
		#for q=1:n
		#    if Mixed(j,q)==0
		#        Mixed(j,q)==0;
		#    else
		#Mixed(j,q)=2.844009.*Mixed(j,q).^-.543955.*.97316.^Mixed(j,q)+Mixed(j,q);%%%%%%% incrmental gain in Mixed
		#    end
		#end
		#end
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
	
	
		#%%%%%%%%%%%%%%%%Estimate Board Feet Per Tree
		#BFD=exp(log(Decid)*2.77922-2.70244+.008);%%%%%%Board Feet per tree Decid
		bfd = NMath.exp( NMath.log( mx_decid ) * 2.77922 - 2.70244 + 0.008 )
		#BFC=exp(log(Conifer)*2.77922-2.70244+.1689889);%%%%%%Board Feet per tree Conifer
		bfc = NMath.exp( NMath.log( mx_conifer ) * 2.77922 - 2.70244 + 0.1689889 )
		#BFM=exp(log(Mixed)*2.77922-2.70244);%%%%%%Board Feet per tree Mixed
		bfm = NMath.exp( NMath.log( mx_mixed ) * 2.77922 - 2.70244 )

		#%%%%%%%%%%%%Estimate total board feet per cell
		#BFDT=BFD.*DenseD;
		bfdt = bfd * dense_d
		#BFCT=BFC.*DenseC;
		bfcf = bfc * dense_c
		#BFMT=BFM.*DenseM;
		bfmt = bfm * dense_m



		#end
		end
		
	#Treesize=Conifer+Mixed+Decid;
	tree_size =  mx_conifer + mx_mixed + mx_decid
 
  output = TimberOutput.new(bfdt, bfcf, bfmt, tree_size)
  return output
  

end


