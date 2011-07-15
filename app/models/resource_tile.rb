class ResourceTile < ActiveRecord::Base
  versioned
  acts_as_api
  
  belongs_to :megatile
  belongs_to :world
  
  validates_uniqueness_of :x, :scope => [:y, :world_id]
  validates_uniqueness_of :y, :scope => [:x, :world_id]
  
  #todo: Add validations for tree_species, zoned_use, and primary_use to be sure that they're in one of the below
  
  Verbiage = {:tree_species => {
                :coniferous => "Coniferous",
                :deciduous => "Deciduous",
                :mixed => "Mixed"
               },
              :zoned_uses => {
                :development => "Development",
                :dev => "Development",
                :agriculture => "Agriculture",
                :ag => "Agriculture",
                :logging => "Logging",
                :park => "Park"
              },
              :primary_uses => {
                :pasture => "Agriculture/Pasture",
                :crops => "Agriculture/Cultivated Crops",
                :housing => "Housing",
                :logging => "Logging",
                :industry => "Industry",
              }
             } #Verbiage
  
  
  def clear_resources
    self.primary_use = nil
    self.people_density = nil
    self.housing_density = nil
    self.tree_density = nil
    self.tree_species = nil
    self.tree_size = nil
    self.development_intensity = nil
  end
  
  def clear_resources!
    clear_resources
    save!
  end
    
  api_accessible :resource_base do |template|
    template.add :id
    template.add :x
    template.add :y
    template.add :type
    template.add :updated_at
  end
  
  api_accessible :resource, :extend => :resource_base do |template|
    #pass
  end
  
  def can_be_bulldozed?
    false
  end
  
  def can_be_clearcut?
    false
  end
  
  def get_price
    
    #MatLab equation:
    #lntotalprice=bdum.*coeff(1,1)+lntotalacres.*coeff(1,2)+lntot2.*coeff(1,3)+lnfrontage.*coeff(1,4)+lnf2.*coeff(1,5)+lnlakesize.*coeff(1,6);
    #lntotalprice=lntotalprice+lnlake2.*coeff(1,7)+sone.*coeff(1,8)+stwo.*coeff(1,9)+szero.*coeff(1,10)+10.24;
    #totalprice=exp(lntotalprice);
    
    coeff=[1.113921,0.2421629,0.0017476,0.0879644,0.0144558,0.249173,0.0058711,-0.046306,0.0342448,0.0038761,10.24675];
    
    bdum = 0.0
    if self.housing_density != nil && self.housing_density != 0
      bdum = 1.0
    end
    
    lntotalacres = 1.0
    lntot2 = lntotalacres ** 2
    
    lnfrontage = 0.0
    if self.frontage != nil
      lnfrontage = self.frontage
    end
    lnf2 = lnfrontage ** 2
    
    lnlakesize = 0.0
    if self.lakesize != nil
      lnlakesize = self.lakesize
    end
    lnlake2 = lnlakesize ** 2
    
    sone = stwo = szero = 0.0
    case self.soil
      when 0
        szero = 1.0
      when 1
        sone = 1.0
      when 2
        stwo = 1.0
    end
    
    lntotalprice = bdum*coeff[0]+lntotalacres*coeff[1]+lntot2*coeff[2]+lnfrontage*coeff[3]+lnf2*coeff[4]+lnlakesize*coeff[5]+lnlake2*coeff[6]+sone*coeff[7]+stwo*coeff[8]+szero*coeff[9]+10.24;
    totalprice = Math.exp(lntotalprice)
    return totalprice
  end
  
end
